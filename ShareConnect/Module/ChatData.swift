//
//  ChatData.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/24.
//

import Foundation
import FirebaseFirestore

struct ChatItem: Codable {
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
