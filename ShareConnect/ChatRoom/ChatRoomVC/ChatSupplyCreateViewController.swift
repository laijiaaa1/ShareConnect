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
    var buyer: String!
    private var chatManager = ChatManager.shared
    var firestore: Firestore!
    var chatRoomDocument: DocumentReference!
    let tableView = UITableView()
    var products: [Product] = []
    var supplies: [Supply] = []
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MY SUPPLY"
        navigationController?.navigationBar.tintColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(handleUIRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        tableView.register(SupplyTableViewCell.self, forCellReuseIdentifier: "SupplyTableViewCell")
        fetchRequests(userId: Auth.auth().currentUser!.uid, dataType: "supply")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.heightAnchor.constraint(equalToConstant: 650)
        ])
        let createNewButton = UIButton()
        createNewButton.setTitle("Create New", for: .normal)
        createNewButton.startAnimatingPressActions()
        createNewButton.backgroundColor = UIColor(named: "G3")
        createNewButton.layer.cornerRadius = 10
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
    @objc func createNewButtonTapped() {
        let vc = CreateSupplyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerLabel = UILabel()
        headerLabel.text = "Choose your supply to chat !"
        headerLabel.textColor = UIColor(named: "G3")
        headerLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        headerView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        headerView.backgroundColor = .black
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupplyTableViewCell", for: indexPath) as! SupplyTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.backgroundColor = .black
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
            vc.buyerID = self?.buyer
            vc.sellerID = Auth.auth().currentUser!.uid
            vc.cart = [seller: productArray]
            self?.navigationController?.popViewController(animated: true)
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
                    if let product = FirestoreService.shared.parseProductData(productData: data){
                        self.products.append(product)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}
class SupplyTableViewCell: MyRequestCell {
}
