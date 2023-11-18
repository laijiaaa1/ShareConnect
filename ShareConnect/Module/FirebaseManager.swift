//
//  FirebaseManager.swift
//  Pods
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation
import FirebaseFirestore

public class FirebaseManager {

    static let shared = FirebaseManager() // Singleton instance

    private let db = Firestore.firestore()

    // Fetch products from Firestore
    func fetchProducts(completion: @escaping ([Product]?, Error?) -> Void) {
        let productsCollection = db.collection("products")

        productsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var products: [Product] = []

                for document in querySnapshot!.documents {
                    if let productData = document.data() ?? nil,
                       let product = self.parseProductData(productData: productData) {
                        products.append(product)
                    }
                }

                completion(products, nil)
            }
        }
    }
    private func parseProductData(productData: [String: Any]) -> Product? {
        guard
            let name = productData["name"] as? String,
            let price = productData["price"] as? String,
            let startTime = productData["startTime"] as? String,
            let endTime = productData["endTime"] as? String,
            let description = productData["description"] as? String,
            let sort = productData["sort"] as? String,
            let quantity = productData["quantity"] as? String,
            let use = productData["use"] as? String,
            let imageString = productData["image"] as? String,
            let sellerData = productData["seller"] as? [String: Any],
            let sellerID = sellerData["sellerID"] as? String,
            let sellerName = sellerData["sellerName"] as? String,
            let typeRawValue = productData["type"] as? String,
            let type = ProductType(rawValue: typeRawValue)
        else {
            print("Error: Missing required fields in product data")
            return nil
        }

        let seller = Seller(sellerID: sellerID, sellerName: sellerName)

        return Product(
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
            itemType: type
        )
    }
    // Fetch products for a specific user based on product type
    func fetchProductsForUser(productType: ProductType, completion: @escaping ([Product]?, Error?) -> Void) {
        let productsCollection = db.collection("products")

        productsCollection
            .whereField("type", isEqualTo: productType.rawValue)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    var products: [Product] = []

                    for document in querySnapshot!.documents {
                        if let productData = document.data() ?? nil,
                            let product = self.parseProductData(productData: productData) {
                            products.append(product)
                        }
                    }

                    completion(products, nil)
                }
            }
    }
}

