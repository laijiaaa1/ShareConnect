//
//  FirebaseManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let firestore = Firestore.firestore()
    private let storageRef = Storage.storage().reference()
    private init() {}
    func fetchUserData(completion: @escaping (User?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            completion(nil)
            return
        }
        let userCollection = firestore.collection("users")
        userCollection.document(userID).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let document = documentSnapshot, document.exists {
                let userData = document.data()
                if let uid = document.documentID as? String,
                   let name = userData?["name"] as? String,
                   let email = userData?["email"] as? String,
                   let profileImageUrl = userData?["profileImageUrl"] as? String {
                    let currentUser = User(uid: uid, name: name, email: email, profileImageUrl: profileImageUrl)
                    completion(currentUser)
                }
            } else {
                print("User document does not exist.")
                completion(nil)
            }
        }
    }
    func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let resizedImage = image.resized(toSize: CGSize(width: 400, height: 400)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.1) else {
            completion(nil)
            return
        }
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("images/\(imageName).jpg")
        imageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "")")
                    completion(nil)
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
}
