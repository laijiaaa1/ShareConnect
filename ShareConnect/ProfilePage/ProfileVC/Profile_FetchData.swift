//
//  Fetch.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/3.
//
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher

extension ProfileViewController {
    func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        userCollection.document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let email = data?["email"] as? String ?? ""
                let profileImageUrl = data?["profileImageUrl"] as? String ?? ""
                self.nameLabel.text = name
                self.profileImageView.kf.setImage(with: URL(string: profileImageUrl))
            } else {
                print("Document does not exist")
            }
        }
    }
    func fetchRequests(userId: String, dataType: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        var query: Query
        if dataType == "request" {
            query = productsCollection
                .whereField("product.seller.sellerID", isEqualTo: userId)
                .whereField("type", isEqualTo: "request")
        } else if dataType == "supply" {
            query = productsCollection
                .whereField("product.seller.sellerID", isEqualTo: userId)
                .whereField("type", isEqualTo: "supply")
        } else {
            return
        }
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                self.products.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let product = FirestoreService.shared.parseProductData(productData: data) {
                        self.products.append(product)
                    }
                }
                self.fetchGroupProducts(for: userId, dataType: dataType, completion: {
                    self.groupTableView.reloadData()
                })
            }
        }
    }
    func fetchGroupProducts(for userId: String, dataType: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let groupProductsCollection = db.collection("productsGroup")
        var groupQuery: Query
        if dataType == "request" {
            groupQuery = groupProductsCollection
                .whereField("product.seller.sellerID", isEqualTo: userId)
                .whereField("type", isEqualTo: "request")
        } else if dataType == "supply" {
            groupQuery = groupProductsCollection
                .whereField("product.seller.sellerID", isEqualTo: userId)
                .whereField("type", isEqualTo: "supply")
        } else {
            return
        }
        groupQuery.getDocuments { (groupQuerySnapshot, groupError) in
            if let groupError = groupError {
                print("Error getting group documents: \(groupError.localizedDescription)")
            } else {
                for groupDocument in groupQuerySnapshot!.documents {
                    let groupData = groupDocument.data()
                    if let product = FirestoreService.shared.parseProductData(productData: groupData) {
                        self.products.append(product)
                    }
                }
                completion()
            }
        }
    }
    func fetchCollections(userId: String) {
        guard (Auth.auth().currentUser?.uid) != nil else {
            return
        }
        let db = Firestore.firestore()
        let userCollectionReference = db.collection("collections").document(userId)
        userCollectionReference.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let collectedProducts = document.data()?["collectedProducts"] as? [[String: Any]] {
                    let collections = collectedProducts.compactMap { productData -> Collection? in
                        return self.parseCollectionData(productData: productData)
                    }
                    self.collections = collections
                    self.collectionCollectionView.reloadData()
                }
            } else {
                print("Document does not exist or there was an error")
            }
        }
    }
    func fetchGroups(userId: String) {
        guard (Auth.auth().currentUser?.uid) != nil else {
            return
        }
        let db = Firestore.firestore()
        let productsGroup = db.collection("groups").whereField("members", arrayContains: userId)
        productsGroup.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                self.groups.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let group = GroupDataManager.shared.parseGroupData(data: data, documentId: document.documentID) {
                        self.groups.append(group)
                    }
                }
                self.groupTableView.reloadData()
            }
        }
    }
    func parseCollectionData(productData: [String: Any]) -> Collection? {
        guard
            let productId = productData["productId"] as? String,
            let name = productData["name"] as? String,
            let price = productData["price"] as? String,
            let imageString = productData["imageString"] as? String
        else {
            return nil
        }
        let collection = Collection(name: name, imageString: imageString , productId: productId)
        return collection
    }
    @objc func recoderButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RecoderViewController") as! RecoderViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
