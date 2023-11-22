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

class TrolleyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TrolleyCellDelegate{
    func didSelectSeller(sellerID: String) {
        print("Selected seller: \(sellerID)")
    }
    
    var selectedSellerID: String?
    var cart: [Seller: [Product]] = [:] {
        didSet {
            saveCartToUserDefaults()
            tableView.reloadData()
        }
    }
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    var chatRoomID: String!
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        navigationItem.title = "Trolley"
        view.backgroundColor = CustomColors.B1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrolleyCell.self, forCellReuseIdentifier: "TrolleyCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.heightAnchor.constraint(equalToConstant: 600),
            tableView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        let checkoutButton = UIButton(type: .system)
        checkoutButton.setTitle("CONFIRM ORDER", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.backgroundColor = .black
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
        view.addSubview(checkoutButton)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        if let savedCartData = UserDefaults.standard.array(forKey: "carts") as? [[String: Data]] {
            cart = savedCartData.reduce(into: [Seller: [Product]]()) { result, dict in
                guard let encodedSeller = dict["seller"],
                      let encodedProducts = dict["products"],
                      let seller = try? JSONDecoder().decode(Seller.self, from: encodedSeller),
                      let products = try? JSONDecoder().decode([Product].self, from: encodedProducts) else {
                    return
                }
                result[seller] = products
            }
        }
    }
    @objc func refresh() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    func addToCart(product: Product) {
        let seller = product.seller
        if var sellerProducts = cart[seller] {
            sellerProducts.append(product)
            cart[seller] = sellerProducts
        } else {
            cart[seller] = [product]
        }
    }
    func saveCartToUserDefaults() {
        let encodedCart = try? JSONEncoder().encode(cart)
        UserDefaults.standard.set(encodedCart, forKey: "cart")
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrolleyCell", for: indexPath) as! TrolleyCell
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
        headerView.backgroundColor = .white
        let sellerNameLabel = UILabel()
        sellerNameLabel.text = seller.sellerName
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
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if cartItems.isEmpty {
                let indexSet = IndexSet(integer: indexPath.section)
                self?.cart.removeValue(forKey: seller)
                tableView.deleteSections(indexSet, with: .automatic)
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

        createChatRoom(with: sellerID) { [weak self] chatRoomID in
            guard let self = self else { return }

            let checkoutVC = ChatViewController()
            checkoutVC.cart = self.cart
            checkoutVC.sellerID = sellerID
            checkoutVC.chatRoomID = chatRoomID
//            checkoutVC.createOrGetChatRoomDocument()
//            checkoutVC.startListeningForChatMessages()
            self.navigationController?.pushViewController(checkoutVC, animated: true)
        }
    }

    func createChatRoom(with sellerID: String?, completion: @escaping (String) -> Void) {
       
        let chatRoomCollection = Firestore.firestore().collection("chatRooms")
        let newChatRoomRef = chatRoomCollection.addDocument(data: [
                    "buyerID": Auth.auth().currentUser?.uid ?? "",
                    "sellerID": sellerID ?? "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "cart": encodeCart(),
                ])
            chatRoomID = newChatRoomRef.documentID
            let messagesCollection = newChatRoomRef.collection("messages")

            let initialMessage = "Hello!"
            messagesCollection.addDocument(data: ["text": initialMessage, "isMe": false, "timestamp": FieldValue.serverTimestamp()])

            completion(chatRoomID)
    }
    func encodeCart() -> [[String: Any]] {
        var encodedCart: [[String: Any]] = []

        for (seller, products) in cart {
            let encodedProducts = products.map { product in
                [
                    "Name": product.name,
                    "Price": product.price,
                ]
            }

            let encodedSeller: [String: Any] = [
                "sellerID": seller.sellerID,
                "sellerName": seller.sellerName,
            ]

            encodedCart.append([
                "seller": encodedSeller,
                "products": encodedProducts,
            ])
        }

        return encodedCart
    }
    func getSellerID() -> String? {
        guard let sellerID = selectedSellerID else { return nil }
        return sellerID
    }
}
class TrolleyCell: UITableViewCell {
    weak var delegate: TrolleyCellDelegate?
    var sellerID: String?
    var number: Int = 1 {
        didSet {
            numberLabel.text = "\(number)"
        }
    }
    let backView = UIView()
    let imageViewUP = UIImageView()
    let nameLabel = UILabel()
    let numberLabel = UILabel()
    let priceLabel = UILabel()
    let quantityLabel = UILabel()
    let minusButton = UIButton()
    let plusButton = UIButton()
    let selectSellerButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(selectSellerButtonTapped), for: .touchUpInside)
        return button
    }()
    @objc func selectSellerButtonTapped() {
        guard let sellerID = sellerID else { return }
        delegate?.didSelectSeller(sellerID: sellerID)
    }
    func setupUI(seller: Seller, cartItems: [Product], delegate: TrolleyCellDelegate) {
        self.sellerID = seller.sellerID
        self.delegate = delegate
        if let product = cartItems.first {
            nameLabel.text = product.name
            priceLabel.text = "NT$ \(product.price)"
            imageViewUP.kf.setImage(with: URL(string: product.imageString))
            quantityLabel.text = "\(product.quantity)"
        }
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backView.heightAnchor.constraint(equalToConstant: 140),
            backView.widthAnchor.constraint(equalToConstant: 140)
        ])
        backView.addSubview(imageViewUP)
        imageViewUP.layer.cornerRadius = 10
        imageViewUP.layer.masksToBounds = true
        imageViewUP.layer.borderWidth = 1
        imageViewUP.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageViewUP.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10),
            imageViewUP.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
            imageViewUP.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
            imageViewUP.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10)
        ])
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageViewUP.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: imageViewUP.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        numberLabel.text = "\(number)"
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = .white
        numberLabel.layer.cornerRadius = 10
        numberLabel.layer.masksToBounds = true
        numberLabel.layer.borderWidth = 1
        contentView.addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            numberLabel.widthAnchor.constraint(equalToConstant: 100),
            numberLabel.heightAnchor.constraint(equalToConstant: 30),
            numberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(.black, for: .normal)
        minusButton.backgroundColor = .white
        minusButton.layer.cornerRadius = 10
        minusButton.layer.masksToBounds = true
        minusButton.layer.borderWidth = 1
        contentView.addSubview(minusButton)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minusButton.topAnchor.constraint(equalTo: numberLabel.topAnchor),
            minusButton.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            minusButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.black, for: .normal)
        plusButton.backgroundColor = .white
        plusButton.layer.cornerRadius = 10
        plusButton.layer.masksToBounds = true
        plusButton.layer.borderWidth = 1
        contentView.addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: numberLabel.topAnchor),
            plusButton.trailingAnchor.constraint(equalTo: numberLabel.trailingAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        contentView.addSubview(selectSellerButton)
        selectSellerButton.layer.cornerRadius = 10
        selectSellerButton.layer.masksToBounds = true
        selectSellerButton.layer.borderWidth = 1
        selectSellerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectSellerButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            selectSellerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            selectSellerButton.widthAnchor.constraint(equalToConstant: 30),
            selectSellerButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    @objc func minusButtonTapped() {
        number = max(1, number - 1)
    }
    @objc func plusButtonTapped() {
        number += 1
    }
}
