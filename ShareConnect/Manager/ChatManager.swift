//
//  ChatManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import Foundation
import FirebaseFirestore

class ChatManager {
       static let shared = ChatManager()
       private var firestore = Firestore.firestore()
       private var seller: Seller?
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
                   let buyerID = data["buyer"] as? String,
                   let sellerID = data["seller"] as? String,
                   let chatRoomID = data["chatRoomID"] as? String,
                   let audioURL = data["audioURL"] as? String,
                   let imageURL = data["imageURL"] as? String {
                    print("Download URL: \(audioURL)")
                    let chatMessage = ChatMessage(text: text,
                                                  isMe: isMe,
                                                  timestamp: timestamp,
                                                  profileImageUrl: profileImageUrl,
                                                  name: name,
                                                  chatRoomID: chatRoomID,
                                                  sellerID: sellerID,
                                                  buyerID: buyerID,
                                                  imageURL: imageURL,
                                                  audioURL: audioURL)
                    chatMessages.append(chatMessage)
                }
            }
            completion(chatMessages, nil)
        }
    }
}
