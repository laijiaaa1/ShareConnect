//
//  ImageManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseStorage
import ProgressHUD

class RegistrationManager {
    static let shared = RegistrationManager()
    let db = Firestore.firestore()
    private init() {}
    func registerUser(email: String?, password: String, name: String, profileImage: UIImage?, completion: @escaping (Bool) -> Void) {
        ProgressHUD.animate("Please wait...", .ballVerticalBounce)
        Auth.auth().createUser(withEmail: email ?? "", password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(false)
            } else {
                if let profileImage = profileImage {
                    self.uploadProfileImage(profileImage) { imageUrl in
                        self.updateUserData(email: email, name: name, imageUrl: imageUrl) { success in
                            completion(success)
                        }
                    }
                } else {
                    self.updateUserData(email: email, name: name, imageUrl: nil) { success in
                        completion(success)
                    }
                }
            }
        }
    }
    private func updateUserData(email: String?, name: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        guard !uid.isEmpty else {
            print("Unable to get UID")
            completion(false)
            return
        }
        var userData: [String: Any] = ["name": name]
        if let email = email, !email.isEmpty {
            userData["email"] = email
        }
        if let imageUrl = imageUrl {
            userData["profileImageUrl"] = imageUrl
        }
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User data updated successfully")
                if let uid = Auth.auth().currentUser?.uid {
                    Messaging.messaging().subscribe(toTopic: uid)
                }
                completion(true)
            }
        }
    }
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else {
                        guard let url = url else {
                            return
                        }
                        completion(url.absoluteString)
                    }
                }
            }
        }
    }
}
