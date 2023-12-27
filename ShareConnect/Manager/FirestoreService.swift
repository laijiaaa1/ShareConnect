//
//  FirestoreService.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/20.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private init() {}
    func addBrowsingRecord(name: String, image: String, price: String, type: String, productId: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        let data: [String: Any] = [
            "Name": name,
            "image": image,
            "Price": price,
            "type": type,
            "timestamp": FieldValue.serverTimestamp(),
            "productId": productId
        ]
        db.collection("users").document(uid).collection("browsingHistory").whereField("productId", isEqualTo: productId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            }
            for document in snapshot!.documents {
                self.db.collection("users").document(uid).collection("browsingHistory").document(document.documentID).delete { error in
                    if let error = error {
                        print("Error delete document: \(error.localizedDescription)")
                    }
                }
            }
            self.db.collection("users").document(uid).collection("browsingHistory").addDocument(data: data) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Document added successfully!")
                }
            }
        }
    }
    func listenForBrowsingHistoryChanges(completion: @escaping ([BrowsingRecord]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        db.collection("users").document(uid).collection("browsingHistory").order(by: "timestamp", descending: true).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error listening for browsing history changes: \(error.localizedDescription)")
            } else {
                var browsingRecords: [BrowsingRecord] = []
                for document in snapshot!.documents {
                    let data = document.data()
                    if let name = data["Name"] as? String,
                       let productId = data["productId"] as? String,
                       let image = data["image"] as? String,
                       let price = data["Price"] as? String,
                       let type = data["type"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp {
                        let browsingRecord = BrowsingRecord(name: name, image: image, price: price, type: type, timestamp: timestamp.dateValue(), productId: productId)
                        browsingRecords.append(browsingRecord)
                    }
                }
                completion(browsingRecords)
            }
        }
    }
    func getProductDetails(productID: String, completion: @escaping (Product?) -> Void) {
        let productsCollection = db.collection("products")
        let query = productsCollection.whereField("product.productId", isEqualTo: productID)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting product document: \(error.localizedDescription)")
                completion(nil)
            } else if let document = querySnapshot?.documents.first {
                let data = document.data()
                if let product = self.parseProductData(productData: data) {
                    completion(product)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
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
            return nil }
        let sellerData = product["seller"] as? [String: Any]
        guard let sellerID = sellerData?["sellerID"] as? String,
              let sellerName = sellerData?["sellerName"] as? String,
              let itemType = productData["type"] as? String
        else {
            print("Error: Failed to parse seller or itemType")
            return nil
        }
        let description = product["Description"] as? String ?? ""
        let sort = product["Sort"] as? String ?? ""
        let quantity = product["Quantity"] as? Int ?? 0
        let use = product["Use"] as? String ?? ""
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
            itemType: ProductType(rawValue: itemType)!
        )
        return newProduct
    }
    func fetchUserData(userId: String, completion: @escaping (String, String, String) -> Void) {
        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        userCollection.document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let email = data?["email"] as? String ?? ""
                let profileImageUrl = data?["profileImageUrl"] as? String ?? ""
                completion(name, email, profileImageUrl)
            } else {
                print("Error fetching user data: \(error?.localizedDescription ?? "")")
            }
        }
    }
    // Fetch Requests
    func fetchRequests(userId: String, dataType: String, completion: @escaping ([Product]) -> Void) {
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
                print("Error fetching requests: \(error.localizedDescription)")
                completion([])
            } else {
                let products = querySnapshot?.documents.compactMap { document in
                    FirestoreService.shared.parseProductData(productData: document.data())
                } ?? []
                completion(products)
            }
        }
    }
    // Fetch Group Products
    func fetchGroupProducts(userId: String, dataType: String, completion: @escaping ([Product]) -> Void) {
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
                print("Error fetching group products: \(groupError.localizedDescription)")
                completion([])
            } else {
                let products = groupQuerySnapshot?.documents.compactMap { document in
                    FirestoreService.shared.parseProductData(productData: document.data())
                } ?? []
                completion(products)
            }
        }
    }
    // Fetch Collections
    func fetchCollections(userId: String, completion: @escaping ([Collection]) -> Void) {
        let db = Firestore.firestore()
        let userCollectionReference = db.collection("collections").document(userId)
        userCollectionReference.getDocument { (document, error) in
            if let error = error {
                print("Error fetching collections: \(error.localizedDescription)")
                completion([])
            } else if let document = document, document.exists {
                if let collectedProducts = document.data()?["collectedProducts"] as? [[String: Any]] {
                    let collections = collectedProducts.compactMap { productData -> Collection? in
                        FirestoreService.shared.parseCollectionData(productData: productData)
                    }
                    completion(collections)
                }
            } else {
                print("Collections document does not exist or there was an error")
                completion([])
            }
        }
    }
    // Fetch Groups
    func fetchGroups(userId: String, completion: @escaping ([Group]) -> Void) {
        let db = Firestore.firestore()
        let productsGroup = db.collection("groups").whereField("members", arrayContains: userId)
        productsGroup.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching groups: \(error.localizedDescription)")
                completion([])
            } else {
                let groups = querySnapshot?.documents.compactMap { document in
                    GroupDataManager.shared.parseGroupData(data: document.data(), documentId: document.documentID)
                } ?? []
                completion(groups)
            }
        }
    }
    // Parse Collection Data
    func parseCollectionData(productData: [String: Any]) -> Collection? {
        guard
            let productId = productData["productId"] as? String,
            let name = productData["name"] as? String,
            let price = productData["price"] as? String,
            let imageString = productData["imageString"] as? String
        else {
            return nil
        }
        return Collection(name: name, imageString: imageString , productId: productId)
    }
}
