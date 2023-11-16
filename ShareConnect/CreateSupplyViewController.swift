//
//  CreateSupplyViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import JGProgressHUD
import FirebaseStorage

class CreateSupplyViewController: CreateRequestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Create Supply"
    }
 
   @objc override func doneButtonTapped() {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let user = Auth.auth().currentUser
        let imageName = UUID().uuidString

        let storageRef = storage.reference().child("images/\(imageName).jpg")

        if let imageURL = uploadButton.backgroundImage(for: .normal), let imageData = imageURL.jpegData(compressionQuality: 0.1) {
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error)")
                        } else if let downloadURL = url {
                            var requestData: [String: Any] = [:]
                            requestData["image"] = downloadURL.absoluteString

                            for i in 0..<self.requestTableView.numberOfSections {
                                for j in 0..<self.requestTableView.numberOfRows(inSection: i) {
                                    let indexPath = IndexPath(row: j, section: i)
                                    if let cell = self.requestTableView.cellForRow(at: indexPath) as? RequestCell {
                                        let key = cell.requestLabel.text ?? ""
                                        let value = cell.textField.text ?? ""
                                        requestData[key] = value
                                    }
                                }
                            }

                            let uid = user!.uid
                            db.collection("users").document(uid).collection("supply").addDocument(data: requestData) { error in
                                if let error = error {
                                    print("Error writing document: \(error)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }


}
