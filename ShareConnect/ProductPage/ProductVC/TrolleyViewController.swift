//
//  TrolleyViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import ProgressHUD

protocol TrolleyCellDelegate: AnyObject {
    func didSelectSeller(sellerID: String)
    func quantityChanged(forProduct product: Product, newQuantity: Int)
}
class TrolleyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TrolleyCellDelegate {
    func didSelectSeller(sellerID: String) {
        print("Selected seller: \(sellerID)")
    }
    var selectedSellerID: String?
    var cart: [Seller: [Product]] = [:] {
        didSet {
            saveCartToFirestore(cart)
            tableView.reloadData()
        }
    }
    var orderIDs: [Order] = []
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    var chatRoomID: String!
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        navigationItem.title = "TROLLEY"
        view.backgroundColor = .black
        let backPicture = UIImageView()
        backPicture.image = UIImage(named: "3")
        backPicture.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(backPicture)
        tableView.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrolleyCell.self, forCellReuseIdentifier: "TrolleyCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.heightAnchor.constraint(equalToConstant: 400),
            tableView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        let checkoutButton = UIButton(type: .system)
        checkoutButton.setTitle("Confirm Order", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.backgroundColor = UIColor(named: "G3")
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
        checkoutButton.startAnimatingPressActions()
        view.addSubview(checkoutButton)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            checkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutButton.widthAnchor.constraint(equalToConstant: 320)
        ])
        loadCartFromFirestore()
    }
    @objc func refresh() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    func addToCart(product: Product) {
        let seller = Seller(sellerID: product.seller.sellerID, sellerName: product.seller.sellerName)
        if var sellerProducts = cart[seller] {
            if let existingProductIndex = sellerProducts.firstIndex(where: { $0.productId == product.productId }) {
                sellerProducts[existingProductIndex].quantity += 1
            } else {
                var mutableProduct = product
                mutableProduct.quantity = 1
                sellerProducts.append(mutableProduct)
            }
            cart[seller] = sellerProducts
        } else {
            cart[seller] = [product]
        }
        saveCartToFirestore(cart)
    }
    func saveCartToFirestore(_ cart: [Seller: [Product]]) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let cartCollection = Firestore.firestore().collection("carts")
        let userCartDocument = cartCollection.document(currentUserID)
        let cartData = cart.map { (seller, products) in
            let encodedProducts = try? JSONEncoder().encode(products)
            return ["sellerID": seller.sellerID, "products": encodedProducts as Any]
        }
        userCartDocument.setData(["buyerID": currentUserID, "cart": cartData])
    }
    func loadCartFromFirestore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let cartCollection = Firestore.firestore().collection("carts")
        let userCartDocument = cartCollection.document(currentUserID)
        userCartDocument.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists,
                  let buyerID = document.data()?["buyerID"] as? String,
                  let cartData = document.data()?["cart"] as? [[String: Any]] else {
                return
            }
            let cart = cartData.reduce(into: [Seller: [Product]]()) { result, dict in
                guard let sellerID = dict["sellerID"] as? String,
                      let encodedProducts = dict["products"] as? Data,
                      let products = try? JSONDecoder().decode([Product].self, from: encodedProducts) else {
                    return
                }
                let seller = Seller(sellerID: sellerID, sellerName: "Seller:\(sellerID)")
                result[seller] = products
            }
            self.cart = cart
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrolleyCell", for: indexPath) as! TrolleyCell
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        let seller = Array(cart.keys)[indexPath.section]
        let cartItems = cart[seller] ?? []
        cell.setupUI(seller: seller, cartItems: cartItems, delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let seller = Array(cart.keys)[section]
        return cart[seller]?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return cart.keys.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let seller = Array(cart.keys)[section]
        let headerView = UIView()
        headerView.backgroundColor = .black
        let sellerNameLabel = UILabel()
        sellerNameLabel.text = seller.sellerName
        sellerNameLabel.textColor = UIColor(named: "G2")
        headerView.addSubview(sellerNameLabel)
        sellerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sellerNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            sellerNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            sellerNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            sellerNameLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        selectedSellerID = seller.sellerID
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let seller = Array(cart.keys)[indexPath.section]
        let cartItems = cart[seller] ?? []
        let product = cartItems[indexPath.row]
        let productDetailVC = DetailViewController()
        productDetailVC.product = product
        navigationController?.pushViewController(productDetailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let seller = Array(cart.keys)[indexPath.section]
        var cartItems = cart[seller] ?? []
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard indexPath.row < cartItems.count else {
                completionHandler(false)
                return
            }
            cartItems.remove(at: indexPath.row)
            self?.cart[seller] = cartItems
            if cartItems.isEmpty {
                let indexSet = IndexSet(integer: indexPath.section)
                self?.cart.removeValue(forKey: seller)
            }
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    @objc func checkoutButtonTapped() {
        guard let sellerID = selectedSellerID else {
            print("Seller ID is nil.")
            return
        }
        if cart.isEmpty {
            print("Cart is empty.")
            return
        } else {
            let chatList = ChatListViewController()
            chatList.sellerID = sellerID
            let checkoutVC = ChatViewController()
            checkoutVC.cart = self.cart
            checkoutVC.sellerID = sellerID
            checkoutVC.buyerID = Auth.auth().currentUser?.uid ?? ""
            checkoutVC.chatRoomID = chatRoomID
            createOrderRecord { [weak self] orderID in
                guard let self = self else { return }
                let orderConfirmationVC = RecoderViewController()
                orderConfirmationVC.orderID = self.orderIDs
                self.clearShoppingCart()
            }
            DispatchQueue.main.async {
                ProgressHUD.succeed("Order Success", delay: 1.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationController?.pushViewController(checkoutVC, animated: true)
                }
            }
        }
    }
    func createOrderRecord(completion: @escaping (String) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid, let sellerID = selectedSellerID else {
            print("User ID or Seller ID is nil.")
            return
        }
        let ordersCollection = Firestore.firestore().collection("orders")
        var newOrderRef: DocumentReference?
        newOrderRef = ordersCollection.addDocument(data: [
            "buyerID": currentUserID,
            "sellerID": sellerID,
            "image": cart.first.map { $0.value.first?.imageString } as Any,
            "createdAt": FieldValue.serverTimestamp(),
            "cart": encodeCart()
        ]) { error in
            if let error = error {
                print("Error creating order record: \(error.localizedDescription)")
                return
            }
            completion(newOrderRef?.documentID ?? "")
        }
    }
    func clearShoppingCart() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let cartCollection = Firestore.firestore().collection("carts")
        let userCartDocument = cartCollection.document(currentUserID)
        userCartDocument.delete { error in
            if let error = error {
                print("Error clearing shopping cart: \(error.localizedDescription)")
            }
        }
        cart = [:]
        tableView.reloadData()
    }
    func encodeCart() -> [[String: Any]] {
        var encodedCart: [[String: Any]] = []
        for (seller, products) in cart {
            let encodedProducts = products.map { product in
                [
                    "Name": product.name,
                    "Price": product.price
                ]
            }
            let encodedSeller: [String: Any] = [
                "sellerID": seller.sellerID,
                "sellerName": seller.sellerName
            ]
            encodedCart.append([
                "seller": encodedSeller,
                "products": encodedProducts
            ])
        }
        return encodedCart
    }
    func getSellerID() -> String? {
        guard let sellerID = selectedSellerID else { return nil }
        return sellerID
    }
    func quantityChanged(forProduct product: Product, newQuantity: Int) {
        if let seller = cart.keys.first(where: { $0.sellerID == product.seller.sellerID }),
           var sellerProducts = cart[seller],
           let productIndex = sellerProducts.firstIndex(where: { $0.productId == product.productId }) {
            sellerProducts[productIndex].quantity = newQuantity
            cart[seller] = sellerProducts
            saveCartToFirestore(cart)
        }
    }
}
