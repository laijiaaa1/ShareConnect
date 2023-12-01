//
//  ChatManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import Foundation
import FirebaseFirestore

class ChatManager {
    var cartString = ""
       static let shared = ChatManager()
       private var firestore = Firestore.firestore()
       private var seller: Seller? // Add a property to store the seller
       
       private init() {}
       
       func setSeller(_ seller: Seller) {
           self.seller = seller
       }
    func createOrGetChatRoomDocument(buyerID: String, sellerID: String, completion: @escaping (DocumentReference?, Error?) -> Void) {
        let chatRoomID = "\(buyerID)_\(sellerID)"
        let chatRoomsCollection = firestore.collection("chatRooms")
        
        chatRoomsCollection.document(chatRoomID).getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let document = documentSnapshot, document.exists {
                completion(document.reference, nil)
            } else {
                chatRoomsCollection.document(chatRoomID).setData(["createdAt": FieldValue.serverTimestamp()]) { error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    completion(chatRoomsCollection.document(chatRoomID), nil)
                }
            }
            self.startListeningForChatMessages(chatRoomDocument: chatRoomsCollection.document(chatRoomID)) { [weak self] (chatMessages, error) in
                if let error = error {
                    print("Error listening for chat messages: \(error.localizedDescription)")
                    return
                }
            }
//            self.sendMessageToFirestore(chatRoomDocument: chatRoomsCollection.document(chatRoomID), message: "Hello", isMe: true) { error in
//                if let error = error {
//                    print("Error sending message: \(error.localizedDescription)")
//                    return
//                }
//            }
        }
    }
    
    func startListeningForChatMessages(chatRoomDocument: DocumentReference, completion: @escaping ([ChatMessage], Error?) -> Void) -> ListenerRegistration {
        let messagesCollection = chatRoomDocument.collection("messages")
        
        return messagesCollection.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion([], error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([], nil)
                return
            }
            
            var chatMessages = [ChatMessage]()
            
            for document in documents {
                let data = document.data()
                if let text = data["text"] as? String,
                   let isMe = data["isMe"] as? Bool,
                   let timestamp = data["timestamp"] as? Timestamp,
                   let name = data["name"] as? String,
                   let profileImageUrl = data["profileImageUrl"] as? String,
                   let chatRoomID = data["chatRoomID"] as? String{
                    let chatMessage = ChatMessage(text: text, isMe: isMe, timestamp: timestamp, profileImageUrl: profileImageUrl, name: name, chatRoomID: chatRoomID)
                    chatMessages.append(chatMessage)
                }
            }
            
            completion(chatMessages, nil)
        }
    }
    
    func sendMessageToFirestore(chatRoomDocument: DocumentReference, message: String, isMe: Bool, completion: @escaping (Error?) -> Void) {
        let messagesCollection = chatRoomDocument.collection("messages")
        
        messagesCollection.addDocument(data: [
            "text": message,
            "isMe": isMe,
            "timestamp": FieldValue.serverTimestamp(),
            "name": isMe ? "Buyer" : seller?.sellerName ?? "",
        ]) { error in
            completion(error)
        }
    }
    func convertCartToString(_ cart: [Seller: [Product]]) -> String {
        for (seller, products) in cart {
            cartString.append("Seller: \(seller.sellerName)\n")
            
            for product in products {
                cartString.append(" - Product: \(product.name)\n")
                cartString.append("   Quantity: \(product.quantity ?? 1)\n")
                cartString.append("   Price: \(product.price)\n")
            }
            cartString.append("\n")
        }
        return cartString
    }
}
