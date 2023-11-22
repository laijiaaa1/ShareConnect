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
                let productId = UUID().uuidString
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
                            var productData: [String: Any] = [:]
                                                        productData["productId"] = productId
                            productData["image"] = downloadURL.absoluteString
                            productData["seller"] = [
                                "sellerID": user?.uid ?? "",
                                "sellerName": user?.email ?? ""
                            ]
                            for i in 0..<self.requestTableView.numberOfSections {
                                for j in 0..<self.requestTableView.numberOfRows(inSection: i) {
                                    let indexPath = IndexPath(row: j, section: i)
                                    if let cell = self.requestTableView.cellForRow(at: indexPath) as? RequestCell {
                                        let key = cell.requestLabel.text ?? ""
                                        let value = cell.textField.text ?? ""
                                        productData[key] = value
                                    }
                                }
                            }
                            let supplyProduct = Product(
                                productId: productData["productId"] as? String ?? "",
                                name: productData["name"] as? String ?? "",
                                price: productData["price"] as? String ?? "",
                                startTime: productData["startTime"] as? String ?? "",
                                imageString: productData["image"] as? String ?? "",
                                description: productData["description"] as? String ?? "",
                                sort: productData["sort"] as? String ?? "",
                                quantity: productData["quantity"] as? String ?? "",
                                use: productData["use"] as? String ?? "",
                                endTime: productData["endTime"] as? String ?? "",
                                seller: Seller(
                                    sellerID: user?.uid ?? "",
                                    sellerName: user?.email ?? ""
                                ),
                                itemType: .supply
                            )
                            db.collection("products").addDocument(data: [
                                "type": ProductType.supply.rawValue,
                                "product": productData
                            ]) { error in
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
