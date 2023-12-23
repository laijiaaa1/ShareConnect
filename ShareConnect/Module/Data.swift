//
//  Data.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation
import FirebaseFirestore

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
struct UserData: Codable, Hashable {
    var userID: String
    var username: String
}
struct Supply: Codable {
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
    var audioURL: String?
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

struct Group {
    var documentId: String
    var name: String
    var description: String
    var sort: String
    var startTime: String
    var endTime: String
    var require: String
    var numberOfPeople: Int
    var owner: String
    var isPublic: Bool
    var members: [String]
    var image: String
    var invitationCode: String?
    var created: Date
    mutating func addMember(userId: String) {
        if !members.contains(userId) {
            members.append(userId)
        }
    }
}
extension Group {
    init?(data: [String: Any], documentId: String) {
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
        self.documentId = documentId
        self.name = name
        self.description = description
        self.sort = sort
        self.startTime = startTime
        self.endTime = endTime
        self.require = require
        self.numberOfPeople = numberOfPeople
        self.owner = owner
        self.isPublic = isPublic
        self.members = members
        self.image = image
        self.invitationCode = data["invitationCode"] as? String
        self.created = createdTimestamp.dateValue()
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
struct ChatItem {
    var name: String
    var time: Date
    var message: String
    var profileImageUrl: String
    var unreadCount: Int
    var chatRoomID: String
    var sellerID: String
    var buyerID: String
}

enum CurrentUserRole {
    case seller
    case buyer
}
