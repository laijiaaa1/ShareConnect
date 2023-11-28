//
//  SubGroupViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/26.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class SubGroupViewController: SearchViewController {
    var group: Group?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func fetchRequestsForUser(type: ProductType, usification: String ) {
        usification == "request" ? (currentButtonType = .request) : (currentButtonType = .supply)
        guard let groupId = group?.documentId else {
            print("Group ID is nil.")
            return
        }

        let db = Firestore.firestore()
        let productsCollection = db.collection("productsGroup").whereField("product.groupID", isEqualTo: groupId)

        productsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if self.currentButtonType == .request {
                    self.allRequests.removeAll()
                } else if self.currentButtonType == .supply {
                    self.allSupplies.removeAll()
                }

                for document in querySnapshot!.documents {
                    let productData = document.data()

                    if let productTypeRawValue = productData["type"] as? String,
                       let productType = ProductType(rawValue: productTypeRawValue),
                       let product = self.parseProductData(productData: productData) {
                        
                        if productType == type && product.itemType == type {
                            print("Appending \(type): \(product)")
                            if type == .request {
                                self.allRequests.append(product)
                            } else if type == .supply {
                                self.allSupplies.append(product)
                            }
                        }
                    } else {
                        print("Error parsing product type")
                    }
                }

                if type == .request {
                    self.allRequests.sort(by: { $0.startTime < $1.startTime })
                } else if type == .supply {
                    self.allSupplies.sort(by: { $0.startTime < $1.startTime })
                }

                print("All requests: \(self.allRequests)")
                print("All supplies: \(self.allSupplies)")

                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
