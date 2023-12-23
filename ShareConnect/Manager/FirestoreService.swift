//
//  FirestoreService.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/20.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct BrowsingRecord {
    let name: String
    let image: String
    let price: String
    let type: String
    let timestamp: Date
    let productId: String
}
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
                self.db.collection("users").document(uid).collection("browsingHistory").document(document.documentID).delete{ error in
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
        
        // Use a where clause to filter by productID
        let query = productsCollection.whereField("product.productId", isEqualTo: productID)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting product document: \(error.localizedDescription)")
                completion(nil)
            } else if let document = querySnapshot?.documents.first {
                let data = document.data()
                
                // Parse product data and create a Product object
                if let product = self.parseProductData(productData: data) {
                    completion(product)
                } else {
                    completion(nil)
                }
            } else {
                // Product document not found
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
}
