//
//  ClassViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class ClassViewController: UIViewController {

    let classProductButton = UIButton()
    let classPlaceButton = UIButton()
    var currentButtonType: ProductType = .request
    var allRequests: [Product] = []
    var allSupplies: [Product] = []
    var classification = ["place", "product"]
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = CustomColors.B1
        view.addSubview(classPlaceButton)
        view.addSubview(classProductButton)
        classPlaceButton.translatesAutoresizingMaskIntoConstraints = false
        classProductButton.translatesAutoresizingMaskIntoConstraints = false
        classPlaceButton.backgroundColor = .black
        classProductButton.backgroundColor = .black
        classPlaceButton.addTarget(self, action: #selector(classPlaceButtonAction), for: .touchUpInside)
        classProductButton.addTarget(self, action: #selector(classProductButtonAction), for: .touchUpInside)
        
        classPlaceButton.setTitle("Product", for: .normal)
        classProductButton.setTitle("Place", for: .normal)
        classPlaceButton.setTitleColor(.white, for: .normal)
        classProductButton.setTitleColor(.white, for: .normal)
        NSLayoutConstraint.activate([
            classPlaceButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            classPlaceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            classPlaceButton.widthAnchor.constraint(equalToConstant: 200),
            classPlaceButton.heightAnchor.constraint(equalToConstant: 200),
            classProductButton.topAnchor.constraint(equalTo: classPlaceButton.bottomAnchor, constant: 20),
            classProductButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            classProductButton.widthAnchor.constraint(equalToConstant: 200),
            classProductButton.heightAnchor.constraint(equalToConstant: 200),
        ])
    }

    @objc func classPlaceButtonAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SearchViewController") as! SearchViewController

        fetchDataForSort(classification: "place", type: .request)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func classProductButtonAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        fetchDataForSort(classification: "product", type: .request)

        navigationController?.pushViewController(vc, animated: true)
    }

    func fetchDataForSort(classification: String, type: ProductType) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
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
                        if productType == type {
                            if product.itemType == type {
                                print("Appending \(type): \(product)")
                                if type == .request {
                                   if product.sort == classification {
                                        self.allRequests.append(product)
                                    }
                                }
                            }
                        } else {
                            print("Skipped product with unknown type: \(productType)")
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
            }
        }
    }

    func parseProductData(productData: [String: Any]) -> Product? {
        guard let product = productData["product"] as? [String: Any],
              let productId = product["productId"] as? String,
              let name = product["Name"] as? String,
              let price = product["Price"] as? String,
              let imageString = product["image"] as? String,
              let startTimeString = product["Start Time"] as? String,
              let startTime = product["Start Time"] as? String,
              let endTimeString = product["End Time"] as? String,
              let endTime = product["End Time"] as? String else {
            print("Error: Missing required fields in product data")
            return nil
        }
        let sellerData = product["seller"] as? [String: Any]
        guard let sellerID = sellerData?["sellerID"] as? String,
              let sellerName = sellerData?["sellerName"] as? String,
              let itemType = productData["type"] as? String
        else {
            print("Error: Failed to parse seller or itemType")
            return nil
        }
        let description = product["Description"] as? String ?? ""
        let sort = product["Sort"] as? String ?? ""
        let quantity = product["Quantity"] as? String ?? ""
        let use = product["Use"] as? String ?? ""
        let seller = Seller(sellerID: sellerID, sellerName: sellerName)
        let newProduct = Product(
            productId: productId,
            name: name,
            price: price,
            startTime: startTime,
            imageString: imageString,
            description: description,
            sort: sort,
            quantity: quantity,
            use: use,
            endTime: endTime,
            seller: seller,
            itemType: ProductType(rawValue: itemType)!
        )
        return newProduct
    }
}
