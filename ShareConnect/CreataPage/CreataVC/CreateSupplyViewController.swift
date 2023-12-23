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
import FirebaseStorage
import ProgressHUD

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
        if let imageURL = self.uploadButton.backgroundImage(for: .normal),
           let imageData = imageURL.jpegData(compressionQuality: 0.1) {
            ProgressHUD.animate("Please wait...", .ballVerticalBounce)
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                } else {
                    storageRef.downloadURL { [self] (url, error) in
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
                            DispatchQueue.main.async {
                                for i in enterData.indices {
                                    let indexPath = IndexPath(row: i, section: 0)
                                    if let cell = self.requestTableView.cellForRow(at: indexPath) as? RequestCell {
                                        let key = cell.requestLabel.text ?? ""
                                        let value = enterData[i]
                                        productData[key] = value
                                    }
                                }
                                if let selectedGroupID = self.selectedGroupID,
                                   let selectedGroupName = self.selectedGroup {
                                    productData["groupID"] = selectedGroupID
                                    productData["groupName"] = selectedGroupName
                                }
                                let demandProduct = Product(
                                    productId: productData["productId"] as? String ?? "",
                                    name: productData["Name"] as? String ?? "",
                                    price: productData["Price"] as? String ?? "",
                                    startTime: productData["End Time"] as? String ?? "",
                                    imageString: productData["image"] as? String ?? "",
                                    description: productData["Description"] as? String ?? "",
                                    sort: productData["Sort"] as? String ?? "",
                                    quantity: productData["Quantity"] as? Int ?? 1,
                                    use: productData["Use"] as? String ?? "",
                                    endTime: productData["End Time"] as? String ?? "",
                                    seller: Seller(
                                        sellerID: user?.uid ?? "",
                                        sellerName: user?.email ?? ""
                                    ),
                                    itemType: .supply
                                )
                                let collectionName: String = selectedGroupID != nil ? "productsGroup" : "products"
                                db.collection(collectionName).addDocument(data: [
                                    "type": ProductType.supply.rawValue,
                                    "product": productData
                                ]) { error in
                                    if let error = error {
                                        print("Error writing document: \(error)")
                                    } else {
                                        print("Document successfully written!")
                                    }
                                    DispatchQueue.main.async {
                                        ProgressHUD.succeed("Success", delay: 1.5)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
