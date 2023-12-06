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
}
