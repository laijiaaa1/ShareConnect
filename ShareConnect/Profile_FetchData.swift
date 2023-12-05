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
                    if let product = self.parseProductData(productData: data) {
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
                    if let product = self.parseProductData(productData: groupData) {
                        self.products.append(product)
                    }
                }
                completion()
            }
        }
    }
    func fetchCollections(userId: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
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
        guard let currentUserID = Auth.auth().currentUser?.uid else {
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
                    
                    if let group = self.parseGroupData(data: data, documentId: document.documentID) {
                        self.groups.append(group)
                    }
                }
                self.groupTableView.reloadData()
            }
        }
    }
    func parseGroupData(data: [String: Any], documentId: String) -> Group? {
        guard
            let name = data["name"] as? String,
            let description = data["description"] as? String,
            let sort = data["sort"] as? String,
            let startTime = data["startTime"] as? String,
            let endTime = data["endTime"] as? String,
            let require = data["require"] as? String,
            let numberOfPeople = data["numberOfPeople"] as? Int,
            let owner = data["owner"] as? String,
            let isPublic = data["isPublic"] as? Bool,
            let members = data["members"] as? [String],
            let image = data["image"] as? String,
            let createdTimestamp = data["created"] as? Timestamp
        else {
            return nil
        }
        var group = Group(
            documentId: documentId,
            name: name,
            description: description,
            sort: sort,
            startTime: startTime,
            endTime: endTime,
            require: require,
            numberOfPeople: numberOfPeople,
            owner: owner,
            isPublic: isPublic,
            members: members,
            image: image,
            created: createdTimestamp.dateValue()
        )
        group.invitationCode = data["invitationCode"] as? String
        return group
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
    func parseRequestData(_ data: [String: Any]) -> Request? {
        guard
            let requestID = data["requestID"] as? String,
            let buyerID = data["buyerID"] as? String,
            let itemsData = data["items"] as? [[String: Any]],
            let selectedSellerID = data["selectedSellerID"] as? String,
            let statusString = data["status"] as? String,
            let status = RequestStatus(rawValue: statusString)
        else {
            return nil
        }
        let items = itemsData.compactMap { productData in
            return parseProductData(productData: productData)
        }
        return Request(
            requestID: requestID,
            buyerID: buyerID,
            items: items,
            selectedSellerID: selectedSellerID,
            status: status
        )
    }
    func parseProductData(productData: [String: Any]) -> Product? {
        guard let product = productData["product"] as? [String: Any],
              let productId = product["productId"] as? String,
              let name = product["Name"] as? String,
              let price = product["Price"] as? String,
              let imageString = product["image"] as? String,
              let startTimeString = product["Start Time"] as? String,
              let startTime = product["Start Time"] as? String,
              let endTimeString = product["End Time"] as? String,
              let endTime = product["End Time"] as? String else {
            print("Error: Missing required fields in product data")
            return nil
        }
        let sellerData = product["seller"] as? [String: Any]
        guard let sellerID = sellerData?["sellerID"] as? String,
              let sellerName = sellerData?["sellerName"] as? String,
              let itemType = productData["type"] as? String
        else {
            print("Error: Failed to parse seller or itemType")
            return nil
        }
        let description = productData["Description"] as? String ?? ""
        let sort = productData["Sort"] as? String ?? ""
        let quantity = productData["Quantity"] as? Int ?? 1
        let use = productData["Use"] as? String ?? ""
        let seller = Seller(sellerID: sellerID, sellerName: sellerName)
        let newProduct = Product(
            productId: productId,
            name: name,
            price: price,
            startTime: startTime,
            imageString: imageString,
            description: description,
            sort: sort,
            quantity: quantity,
            use: use,
            endTime: endTime,
            seller: seller,
            itemType: .request
        )
        return newProduct
    }
    func parseSellerData(_ data: [String: Any]) -> Seller? {
        guard
            let sellerID = data["sellerID"] as? String,
            let sellerName = data["sellerName"] as? String
        else {
            return nil
        }
        return Seller(sellerID: sellerID, sellerName: sellerName)
    }
}
