//
//  ProvideViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProvideViewController: SelectedViewController {
    private var chatManager = ChatManager.shared
    private var chatRoomListener: ListenerRegistration?
    var firestore: Firestore!
    var chatRoomDocument: DocumentReference!
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
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
    override func setup() {
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
        priceLabel.textColor = .white
        priceLabel.frame = CGRect(x: 90, y: 70, width: 130, height: 30)
        priceLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        infoView.addSubview(priceLabel)
        availabilityView.backgroundColor = .white/*UIColor(named: "G7")*/
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
        itemView.backgroundColor = .white/*UIColor(named: "G7")*/
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
        nameLabel.backgroundColor = .white/*UIColor(named: "G7")*/
        numberLabel.layer.cornerRadius = 10
        numberLabel.layer.masksToBounds = true
        numberLabel.textAlignment = .center
        numberLabel.layer.borderWidth = 1
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
        addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
        addButton.backgroundColor = .white
        addButton.layer.cornerRadius = 10
        addButton.layer.masksToBounds = true
        addButton.layer.borderWidth = 1
        addButton.startAnimatingPressActions()
        infoView.addSubview(addButton)
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
        minusButton.startAnimatingPressActions()
        infoView.addSubview(minusButton)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minusButton.centerYAnchor.constraint(equalTo: quantity.centerYAnchor),
            minusButton.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            minusButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        trolleyButton.setTitle("Chat with the requester", for: .normal)
        trolleyButton.setTitleColor(.white, for: .normal)
        trolleyButton.titleLabel?.font = UIFont(name: "PingFangTC-Semibold", size: 20)
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
        closeButton.imageView?.tintColor = UIColor(named: "G3")
        closeButton.backgroundColor = .white/*UIColor(named: "G7")*/
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
    @objc override func trolleyButtonTapped() {
        guard let seller = product?.seller, let product = product else {
            print("Seller or product is nil.")
            return
        }
        let sellerID = seller.sellerID
        let productArray = [product]
        ChatManager.shared.createOrGetChatRoomDocument(buyerID: Auth.auth().currentUser!.uid, sellerID: sellerID) { [weak self] (documentReference, error) in
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
            guard let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {
                print("Failed to instantiate ChatViewController.")
                return
            }
            vc.chatRoomDocument = documentReference
            vc.chatRoomID = documentReference.documentID
            vc.buyerID = sellerID
            vc.sellerID = Auth.auth().currentUser!.uid
            vc.cart = [seller: productArray]
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
