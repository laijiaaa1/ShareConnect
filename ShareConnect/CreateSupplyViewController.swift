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
//import JGProgressHUD

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
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if let imageURL = self.uploadButton.backgroundImage(for: .normal), let imageData = imageURL.jpegData(compressionQuality: 0.1) {
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
                                    }
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                //                self.hud.textLabel.text = "Success"
                //                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                //                self.hud.show(in: self.view)
                //                self.hud.dismiss(afterDelay: 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    //                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
//    @objc override func doneButtonTapped() {
//        let db = Firestore.firestore()
//        let storage = Storage.storage()
//        let user = Auth.auth().currentUser
//        let imageName = UUID().uuidString
//        let productId = UUID().uuidString
//        let storageRef = storage.reference().child("images/\(imageName).jpg")
//        if let imageURL = uploadButton.backgroundImage(for: .normal), let imageData = imageURL.jpegData(compressionQuality: 0.1) {
//            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    print("Error uploading image: \(error)")
//                } else {
//                    storageRef.downloadURL { (url, error) in
//                        if let error = error {
//                            print("Error getting download URL: \(error)")
//                        } else if let downloadURL = url {
//                            var productData: [String: Any] = [:]
//                            productData["productId"] = productId
//                            productData["image"] = downloadURL.absoluteString
//                            productData["seller"] = [
//                                "sellerID": user?.uid ?? "",
//                                "sellerName": user?.email ?? ""
//                            ]
//                            for i in 0..<self.requestTableView.numberOfSections {
//                                for j in 0..<self.requestTableView.numberOfRows(inSection: i) {
//                                    let indexPath = IndexPath(row: j, section: i)
//                                    if let cell = self.requestTableView.cellForRow(at: indexPath) as? RequestCell {
//                                        let key = cell.requestLabel.text ?? ""
//                                        let value = cell.textField.text ?? ""
//                                        productData[key] = value
//                                    }
//                                }
//                            }
//                            let supplyProduct = Product(
//                                productId: productData["productId"] as? String ?? "",
//                                name: productData["name"] as? String ?? "",
//                                price: productData["price"] as? String ?? "",
//                                startTime: productData["startTime"] as? String ?? "",
//                                imageString: productData["image"] as? String ?? "",
//                                description: productData["description"] as? String ?? "",
//                                sort: productData["sort"] as? String ?? "",
//                                quantity: productData["quantity"] as? Int ?? 1,
//                                use: productData["use"] as? String ?? "",
//                                endTime: productData["endTime"] as? String ?? "",
//                                seller: Seller(
//                                    sellerID: user?.uid ?? "",
//                                    sellerName: user?.email ?? ""
//                                ),
//                                itemType: .supply
//                            )
//                            db.collection("products").addDocument(data: [
//                                "type": ProductType.supply.rawValue,
//                                "product": productData
//                            ]) { error in
//                                if let error = error {
//                                    print("Error writing document: \(error)")
//                                } else {
//                                    print("Document successfully written!")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
////        hud.textLabel.text = "Success"
////        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
////        hud.show(in: view)
////        hud.dismiss(afterDelay: 1.0)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//}
