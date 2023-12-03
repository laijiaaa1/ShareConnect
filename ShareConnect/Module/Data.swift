//
//  Data.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation
import FirebaseFirestore

struct Product: Codable, Equatable {
    var productId: String
    var name: String
    var price: String
    var startTime: String
    var imageString: String
    var description: String
    var sort: String
    var quantity: Int
    var use: String
    var endTime: String
    var seller: Seller
    var itemType: ProductType
    var isCollected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case productId, name, price, startTime, imageString, description, sort, quantity, use, endTime, seller, itemType
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
           return lhs.productId == rhs.productId
       }
    
    init(productId: String, name: String, price: String, startTime: String, imageString: String, description: String, sort: String, quantity: Int, use: String, endTime: String, seller: Seller, itemType: ProductType) {
        self.productId = productId
        self.name = name
        self.price = price
        self.startTime = startTime
        self.imageString = imageString
        self.description = description
        self.sort = sort
        self.quantity = quantity
        self.use = use
        self.endTime = endTime
        self.seller = seller
        self.itemType = itemType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decode(String.self, forKey: .productId)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(String.self, forKey: .price)
        startTime = try container.decode(String.self, forKey: .startTime)
        imageString = try container.decode(String.self, forKey: .imageString)
        description = try container.decode(String.self, forKey: .description)
        sort = try container.decode(String.self, forKey: .sort)
        quantity = try container.decode(Int.self, forKey: .quantity)
        use = try container.decode(String.self, forKey: .use)
        endTime = try container.decode(String.self, forKey: .endTime)
        seller = try container.decode(Seller.self, forKey: .seller)
        itemType = try container.decode(ProductType.self, forKey: .itemType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(productId, forKey: .productId)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(imageString, forKey: .imageString)
        try container.encode(description, forKey: .description)
        try container.encode(sort, forKey: .sort)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(use, forKey: .use)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(seller, forKey: .seller)
        try container.encode(itemType, forKey: .itemType)
    }
}

struct Seller: Hashable, Codable {
    var sellerID: String
    var sellerName: String
    
    enum CodingKeys: String, CodingKey {
        case sellerID, sellerName
    }
    
    init(sellerID: String, sellerName: String) {
        self.sellerID = sellerID
        self.sellerName = sellerName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sellerID = try container.decode(String.self, forKey: .sellerID)
        sellerName = try container.decode(String.self, forKey: .sellerName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sellerID, forKey: .sellerID)
        try container.encode(sellerName, forKey: .sellerName)
    }
}

//struct Product: Codable {
//    var productId: String
//    var name: String
//    let price: String
//    let startTime: String
//    var imageString: String
//    let description: String
//    let sort: String
//    var quantity: String
//    let use: String
//    let endTime: String
//    let seller: Seller
//    let itemType: ProductType
//
//    init(productId: String, name: String, price: String, startTime: String, imageString: String, description: String, sort: String, quantity: String, use: String, endTime: String, seller: Seller, itemType: ProductType) {
//        self.productId = productId
//        self.name = name
//        self.price = price
//        self.startTime = startTime
//        self.imageString = imageString
//        self.description = description
//        self.sort = sort
//        self.quantity = quantity
//        self.use = use
//        self.endTime = endTime
//        self.seller = seller
//        self.itemType = itemType
//    }
//}

enum ProductType: String, Codable {
    case request
    case supply
}

extension ProductType {
    init?(rawValue: String) {
        switch rawValue {
        case "request": self = .request
        case "supply": self = .supply
        default: return nil
        }
    }
}

//struct Seller: Hashable, Codable {
//    var sellerID: String
//    var sellerName: String
//}
//extension Seller {
//    init?(data: [String: Any]) {
//        guard
//            let sellerID = data["sellerID"] as? String,
//            let sellerName = data["sellerName"] as? String
//        else {
//            return nil
//        }
//
//        self.sellerID = sellerID
//        self.sellerName = sellerName
//    }
//}

struct Request: Codable {
    let requestID: String
    let buyerID: String
    let items: [Product]
    let selectedSellerID: String?
    let status: RequestStatus
}

enum RequestStatus: String, Codable {
    case open
    case closed
    
    init?(rawValue: String) {
        switch rawValue {
        case "open":
            self = .open
        case "closed":
            self = .closed
        default:
            return nil
        }
    }
}

protocol TrolleyCellDelegate: AnyObject {
    func didSelectSeller(sellerID: String)
}

struct UserData: Codable, Hashable {
    var userID: String
    var username: String
}

struct Supply: Codable{
    let supplyID: String
    let sellerID: String
    let items: [Product]
    let status: SupplyStatus
}

enum SupplyStatus: String, Codable {
    case open
    case closed
    
    init?(rawValue: String) {
        switch rawValue {
        case "open":
            self = .open
        case "closed":
            self = .closed
        default:
            return nil
        }
    }
}

struct ChatMessage {
    let text: String
    let isMe: Bool
    let timestamp: Timestamp
    let profileImageUrl: String
    let name: String
    let chatRoomID: String
    let sellerID: String
    let buyerID: String
    let imageURL: String?
    var isLocation: Bool?
    var mapLink: String?
}
struct User {
    let uid: String
    let name: String
    let email: String
    let profileImageUrl: String
}

struct Collection{
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
