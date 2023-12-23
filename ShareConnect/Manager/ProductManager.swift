//
//  ProductManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import FirebaseFirestore
import FirebaseAuth

class ProductManager {
    static let shared = ProductManager()
    var allRequests: [Product] = []
    var allSupplies: [Product] = []

    private init() {}

    func fetchProductsForGroup(type: ProductType, groupId: String?, completion: @escaping ([Product]) -> Void) {
        guard let groupId = groupId else {
            print("Group ID is nil.")
            completion([])
            return
        }

        let db = Firestore.firestore()
        let productsCollection = db.collection("productsGroup").whereField("product.groupID", isEqualTo: groupId)

        productsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.allRequests.removeAll()
                self.allSupplies.removeAll()

                for document in querySnapshot!.documents {
                    let productData = document.data()

                    if let productTypeRawValue = productData["type"] as? String,
                        let productType = ProductType(rawValue: productTypeRawValue),
                        let product = FirestoreService.shared.parseProductData(productData: productData) {
                        if productType == type && product.itemType == type {
                            print("Appending \(type): \(product)")
                            if type == .request {
                                self.allRequests.append(product)
                            } else if type == .supply {
                                self.allSupplies.append(product)
                            }
                        }
                    } else {
                        print("Error parsing product type")
                    }
                }

                if type == .request {
                    self.allRequests.sort(by: { $0.startTime < $1.startTime })
                } else if type == .supply {
                    self.allSupplies.sort(by: { $0.startTime < $1.startTime })
                }

                print("All requests: \(self.allRequests)")
                print("All supplies: \(self.allSupplies)")

                completion(type == .request ? self.allRequests : self.allSupplies)
            }
        }
    }
}
