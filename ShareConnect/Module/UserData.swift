//
//  UserData.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/24.
//

import Foundation
import FirebaseFirestore

struct UserData: Codable, Hashable {
    var userID: String
    var username: String
}
struct User {
    let uid: String
    let name: String
    let email: String
    let profileImageUrl: String
}

struct Collection {
    var name: String
    var imageString: String
    var productId: String
    init(name: String, imageString: String, productId: String) {
        self.name = name
        self.imageString = imageString
        self.productId = productId
    }
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let imageString = dictionary["imageString"] as? String,
              let productId = dictionary["productId"] as? String else { return nil }
        self.init(name: name, imageString: imageString, productId: productId)
    }
}

struct Commend {
    var comment: String
    var rating: Int
    var image: String
    var sellerID: String
    var buyerID: String
    var productID: String
    var time: String
}

struct BrowsingRecord: Codable {
    let name: String
    let image: String
    let price: String
    let type: String
    let timestamp: Date
    let productId: String
}

struct Reviews {
    let comment: String
    let userID: String
    let sellerID: String
    let image: String
    let productID: String
    let rating: Int
    let timestamp: Date
    init?(comment: String, userID: String, sellerID: String, image: String, productID: String, rating: Int, timestamp: Date) {
        self.comment = comment
        self.userID = userID
        self.sellerID = sellerID
        self.image = image
        self.productID = productID
        self.rating = rating
        self.timestamp = timestamp
    }
    init?(document: QueryDocumentSnapshot) {
        guard let data = document.data() as? [String: Any],
              let comment = data["comment"] as? String,
              let userID = data["userID"] as? String,
              let sellerID = data["sellerID"] as? String,
              let image = data["image"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let productID = data["productID"] as? String,
              let rating = data["rating"] as? Int
        else {
            return nil
        }
        self.init(comment: comment,
                  userID: userID,
                  sellerID: sellerID,
                  image: image,
                  productID: productID,
                  rating: rating,
                  timestamp: timestamp.dateValue())
    }
}

struct Order {
    let orderID: String
    let buyerID: String
    let sellerID: String
    let image: String
    let createdAt: Date
    let cart: [[String: Any]]
    let isCompleted: Bool
    init?(document: QueryDocumentSnapshot) {
        guard let data = document.data() as? [String: Any],
              let orderID = document.documentID as? String,
              let buyerID = data["buyerID"] as? String,
              let sellerID = data["sellerID"] as? String,
              let image = data["image"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let cart = data["cart"] as? [[String: Any]]
        else {
            return nil
        }
        self.orderID = orderID
        self.buyerID = buyerID
        self.sellerID = sellerID
        self.image = image
        self.createdAt = createdAtTimestamp.dateValue()
        self.cart = cart
        if let isCompleted = data["isCompleted"] as? Bool {
            self.isCompleted = isCompleted
        } else {
            self.isCompleted = false
        }
    }
}
