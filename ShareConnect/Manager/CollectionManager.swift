//
//  CollectionManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class CollectionManager {
    static let shared = CollectionManager()
    private let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    func toggleCollectionStatus(for user: String, product: Product, completion: @escaping (Bool, Error?) -> Void) {
        let userCollectionReference = db.collection("collections").document(user)
        userCollectionReference.getDocument { (document, error) in
            if let document = document, document.exists {
                self.updateCollection(for: userCollectionReference, product: product, completion: completion)
            } else {
                userCollectionReference.setData(["collectedProducts": []]) { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        self.updateCollection(for: userCollectionReference, product: product, completion: completion)
                    }
                }
            }
        }
    }
    private func updateCollection(for reference: DocumentReference, product: Product, completion: @escaping (Bool, Error?) -> Void) {
        let productData: [String: Any] = [
                  "productId": product.productId,
                  "name": product.name,
                  "price": product.price,
                  "startTime": product.startTime,
                  "imageString": product.imageString,
                  "description": product.description,
                  "sort": product.sort,
                  "quantity": product.quantity,
                  "use": product.use,
                  "endTime": product.endTime,
                  "seller": [
                      "sellerID": product.seller.sellerID,
                      "sellerName": product.seller.sellerName
                  ],
                  "itemType": product.itemType.rawValue
              ]
        if product.isCollected {
            reference.updateData([
                "collectedProducts": FieldValue.arrayRemove([productData])
            ]) { error in
                completion(error == nil, error)
            }
        } else {
            reference.updateData([
                "collectedProducts": FieldValue.arrayUnion([productData])
            ]) { error in
                completion(error == nil, error)
            }
        }
    }
}
