//
//  SelectedViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/17.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import ProgressHUD

class SelectedViewController: UIViewController {
    var product: Product?
    var cart: [Seller: [Product]] = [:]
    let backImage = UIImageView()
    let backView = UIView()
    let infoView = UIView()
    let nameLabel = UILabel()
    let priceView = UIImageView()
    let priceLabel = UILabel()
    let availabilityView = UIView()
    let availability = UILabel()
    let itemLabel = UILabel()
    let itemView = UIView()
    let itemInfo = UILabel()
    var quantity = UILabel()
    let numberLabel = UILabel()
    let addButton = UIButton()
    let minusButton = UIButton()
    let trolleyButton = UIButton()
    let closeButton = UIButton()
    var selectedQuantity: Int = 1 {
        didSet {
            numberLabel.text = "\(selectedQuantity)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let product = product, let imageURL = URL(string: product.imageString) {
            backImage.kf.setImage(with: imageURL)
            priceLabel.text = product.price
            availability.text = "\(product.startTime)"
            itemInfo.text = product.name
        } else {
            print("Failed to load image: product or imageString is nil or invalid")
        }
    }
    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc func trolleyButtonTapped() {
        if cart.isEmpty {
            print("Cart is empty")
            addProductToCart()
        } else {
            alertUserOnlyAddOneProduct()
        }
    }
    func addProductToCart() {
        guard var product = product else {
            print("Product is nil")
            return
        }
       updateCart(with: &product)
        saveCartToFirestore(cart)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let trolleyViewController = storyboard.instantiateViewController(identifier: "TrolleyViewController") as? TrolleyViewController {
            DispatchQueue.main.async {
                ProgressHUD.succeed("Add Success", delay: 1.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationController?.pushViewController(trolleyViewController, animated: true)
                }
            }
        }
    }
    func updateCart(with product: inout Product) {
        if var sellerProducts = cart[product.seller] {
            if let existingProductIndex = sellerProducts.firstIndex(where: { $0.productId == product.productId }) {
                sellerProducts[existingProductIndex].quantity += selectedQuantity
            } else {
                product.quantity = selectedQuantity
                sellerProducts.append(product)
            }
            cart[product.seller] = sellerProducts
        } else {
            product.quantity = selectedQuantity
            cart[product.seller] = [product]
        }
    }
    func alertUserOnlyAddOneProduct() {
        let alert = UIAlertController(title: "Add Product", message: "You already have other product in your cart. Do you want to add and cover it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.addProductToCart()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true)
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
    func setup() {
        backImage.frame = CGRect(x: 0, y: 0, width: view.frame.width , height: view.frame.height / 2)
        backImage.layer.cornerRadius = 15
        backImage.layer.masksToBounds = true
        view.addSubview(backImage)
        backView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        backView.backgroundColor = UIColor(red: 228/255, green: 220/255, blue: 209/255, alpha: 0.5)
        view.addSubview(backView)
        infoView.frame = CGRect(x: 0, y: 250, width: view.frame.width, height: view.frame.height - 250)
        infoView.backgroundColor = .black
        infoView.layer.cornerRadius = 15
        infoView.layer.masksToBounds = true
        view.addSubview(infoView)
        priceView.frame = CGRect(x: 40, y: 70, width: 30, height: 30)
        priceView.image = UIImage(named: "icons8-price-50 (1)")
        infoView.addSubview(priceView)
        priceLabel.frame = CGRect(x: 90, y: 70, width: 130, height: 30)
        priceLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        priceLabel.textColor = .white
        infoView.addSubview(priceLabel)
        availabilityView.backgroundColor = .white
        availabilityView.layer.cornerRadius = 10
        infoView.addSubview(availabilityView)
        availabilityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            availabilityView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 30),
            availabilityView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            availabilityView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            availabilityView.heightAnchor.constraint(equalToConstant: 70)
        ])
        let dateImage = UIImageView()
        availabilityView.addSubview(dateImage)
        dateImage.image = UIImage(named: "icons8-today-72(@3×)-1")
        dateImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateImage.centerYAnchor.constraint(equalTo: availabilityView.centerYAnchor),
            dateImage.widthAnchor.constraint(equalToConstant: 30),
            dateImage.heightAnchor.constraint(equalToConstant: 30),
            dateImage.leadingAnchor.constraint(equalTo: availabilityView.leadingAnchor, constant: 10)
        ])
        availabilityView.addSubview(availability)
        availability.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        availability.textColor = .black
        availability.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            availability.centerYAnchor.constraint(equalTo: availabilityView.centerYAnchor),
            availability.leadingAnchor.constraint(equalTo: dateImage.trailingAnchor, constant: 30)
        ])
        itemLabel.text = "Item"
        itemLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        itemLabel.textColor = .white
        infoView.addSubview(itemLabel)
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemLabel.topAnchor.constraint(equalTo: availabilityView.bottomAnchor, constant: 60),
            itemLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
        ])
        itemView.backgroundColor = .white /*UIColor(named: "G2")*/
        itemView.layer.cornerRadius = 10
        infoView.addSubview(itemView)
        itemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemView.centerYAnchor.constraint(equalTo: itemLabel.centerYAnchor),
            itemView.leadingAnchor.constraint(equalTo: itemLabel.trailingAnchor, constant: 30),
            itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            itemView.heightAnchor.constraint(equalToConstant: 70)
        ])
        itemView.addSubview(itemInfo)
        itemInfo.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        itemInfo.textColor = .black
        itemInfo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemInfo.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
            itemInfo.leadingAnchor.constraint(equalTo: itemView.leadingAnchor, constant: 30)
        ])
        quantity.text = "Quantity"
        quantity.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        quantity.textColor = .white
        infoView.addSubview(quantity)
        quantity.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quantity.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 60),
            quantity.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
        ])
        numberLabel.text = "1"
        numberLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        numberLabel.textColor = .white
        numberLabel.layer.cornerRadius = 10
        numberLabel.layer.masksToBounds = true
        numberLabel.textAlignment = .center
        infoView.addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: quantity.centerYAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: quantity.trailingAnchor, constant: 30),
            numberLabel.widthAnchor.constraint(equalToConstant: 150),
            numberLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        addButton.backgroundColor = .white
        addButton.layer.cornerRadius = 10
        addButton.layer.masksToBounds = true
        addButton.layer.borderWidth = 1
        infoView.addSubview(addButton)
        addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
        addButton.startAnimatingPressActions()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.centerYAnchor.constraint(equalTo: quantity.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: -30),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(.black, for: .normal)
        minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        minusButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        minusButton.backgroundColor = .white
        minusButton.layer.cornerRadius = 10
        minusButton.layer.masksToBounds = true
        minusButton.layer.borderWidth = 1
        infoView.addSubview(minusButton)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.startAnimatingPressActions()
        NSLayoutConstraint.activate([
            minusButton.centerYAnchor.constraint(equalTo: quantity.centerYAnchor),
            minusButton.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            minusButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        trolleyButton.setTitle("Add to trolley", for: .normal)
        trolleyButton.setTitleColor(.white, for: .normal)
        trolleyButton.backgroundColor = UIColor(named: "G3")
        trolleyButton.layer.cornerRadius = 10
        trolleyButton.layer.masksToBounds = true
        trolleyButton.layer.borderWidth = 1
        trolleyButton.startAnimatingPressActions()
        infoView.addSubview(trolleyButton)
        trolleyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trolleyButton.topAnchor.constraint(equalTo: quantity.bottomAnchor, constant: 50),
            trolleyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            trolleyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            trolleyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        trolleyButton.addTarget(self, action: #selector(trolleyButtonTapped), for: .touchUpInside)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.imageView?.tintColor = .white
        closeButton.backgroundColor = UIColor(named: "G3")
        closeButton.layer.cornerRadius = 30
        closeButton.layer.masksToBounds = true
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: infoView.topAnchor, constant: -20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 60),
            closeButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.startAnimatingPressActions()
    }
    @objc func add() {
        selectedQuantity += 1
    }
    @objc func minus() {
        selectedQuantity = max(1, selectedQuantity - 1)
    }
}
