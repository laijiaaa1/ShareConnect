//
//  SetProfileViewModel.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SettingProfileViewModel {
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        let user = Auth.auth().currentUser

        guard let currentUser = user else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
            return
        }

        let db = Firestore.firestore()
        let userCollection = db.collection("users")
        let userDocument = userCollection.document(currentUser.uid)

        userDocument.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                currentUser.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
