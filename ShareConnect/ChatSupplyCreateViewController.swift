//
//  ChatSupplyCreateViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher

class ChatSupplyCreateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var product: Product?
    private var chatManager = ChatManager.shared
    var firestore: Firestore!
    var chatRoomDocument: DocumentReference!
    let tableView = UITableView()
    var products: [Product] = []
    var supplies: [Supply] = []
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Supply"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(handleUIRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.backgroundColor = CustomColors.B1
        tableView.register(SupplyTableViewCell.self, forCellReuseIdentifier: "SupplyTableViewCell")
        fetchRequests(userId: Auth.auth().currentUser!.uid, dataType: "supply")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 600),
        ])
        let createNewButton = UIButton()
        createNewButton.setTitle("Create New", for: .normal)
        createNewButton.backgroundColor = .black
        createNewButton.layer.cornerRadius = 15
        view.addSubview(createNewButton)
        createNewButton.setTitleColor(.white, for: .normal)
        createNewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createNewButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            createNewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createNewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createNewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createNewButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        createNewButton.addTarget(self, action: #selector(createNewButtonTapped), for: .touchUpInside)
        tableView.reloadData()
    }
    @objc private func handleUIRefresh() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    @objc func createNewButtonTapped(){
        let vc = CreateSupplyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplyTableViewCell", for: indexPath) as! SupplyTableViewCell
        guard indexPath.row < products.count else {
            cell.requestNameLabel.text = "N/A"
            cell.requestDescriptionLabel.text = "N/A"
            cell.requestDateLabel.text = "N/A"
            return cell
        }
        let product = products[indexPath.row]
        cell.requestNameLabel.text = product.name
        cell.requestDescriptionLabel.text = product.sort
        cell.requestDateLabel.text = product.startTime
        let imageURL = URL(string: product.imageString)
        cell.requestImageView.kf.setImage(with: imageURL)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < products.count else {
            print("Invalid indexPath.")
            return
        }
        
        let selectedProduct = products[indexPath.row]
        let seller = selectedProduct.seller
        let sellerID = seller.sellerID
        let productArray = [selectedProduct]
        
        chatManager.createOrGetChatRoomDocument(buyerID: Auth.auth().currentUser!.uid, sellerID: sellerID) { [weak self] (documentReference, error) in
            if let error = error {
                print("Error creating chat room document: \(error.localizedDescription)")
                return
            }
            guard let documentReference = documentReference else {
                print("Document reference is nil.")
                return
            }
            self?.chatRoomDocument = documentReference
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.chatRoomDocument = documentReference
            vc.chatRoomID = documentReference.documentID
            vc.buyerID = sellerID
            vc.sellerID = Auth.auth().currentUser!.uid
            vc.cart = [seller: productArray]
            self?.navigationController?.pushViewController(vc, animated: false)
        }
    }
    func fetchRequests(userId: String, dataType: String) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        var query: Query
        if dataType == "request" {
            query = productsCollection.whereField("product.seller.sellerID", isEqualTo: userId).whereField("type", isEqualTo: "request")
        } else if dataType == "supply" {
            query = productsCollection.whereField("product.seller.sellerID", isEqualTo: userId).whereField("type", isEqualTo: "supply")
        } else {
            return
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                self.products.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let product = self.parseProductData(productData: data) {
                        self.products.append(product)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func parseRequestData(_ data: [String: Any]) -> Request? {
        guard
            let requestID = data["requestID"] as? String,
            let buyerID = data["buyerID"] as? String,
            let itemsData = data["items"] as? [[String: Any]],
            let selectedSellerID = data["selectedSellerID"] as? String,
            let statusString = data["status"] as? String,
            let status = RequestStatus(rawValue: statusString)
        else {
            return nil
        }
        let items = itemsData.compactMap { productData in
            return parseProductData(productData: productData)
        }
        return Request(
            requestID: requestID,
            buyerID: buyerID,
            items: items,
            selectedSellerID: selectedSellerID,
            status: status
        )
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
        //        let itemTypeRawValue = product["type"] as? String
        guard let sellerID = sellerData?["sellerID"] as? String,
              let sellerName = sellerData?["sellerName"] as? String,
              let itemType = productData["type"] as? String
        else {
            print("Error: Failed to parse seller or itemType")
            return nil
        }
        let description = productData["Description"] as? String ?? ""
        let sort = productData["Sort"] as? String ?? ""
        let quantity = productData["Quantity"] as? Int ?? 1
        let use = productData["Use"] as? String ?? ""
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
            itemType: .supply
        )
        return newProduct
    }
    func parseSellerData(_ data: [String: Any]) -> Seller? {
        guard
            let sellerID = data["sellerID"] as? String,
            let sellerName = data["sellerName"] as? String
        else {
            return nil
        }
        return Seller(sellerID: sellerID, sellerName: sellerName)
    }
}
class SupplyTableViewCell: MyRequestCell {
}
