//
//  SearchPage_SearchCollectionViewCell.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/6.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class SearchCollectionViewCell: UICollectionViewCell {
    let underView = UIView()
    let imageView = UIImageView()
    let priceLabel = UILabel()
    let button = UIButton()
    let dateLabel = UILabel()
    let nameLabel = UILabel()
    let collectionButton = UIButton()
    var isCollected = false
    var product: Product? {
        didSet {
            print("Request didSet")
            updateUI()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6)
        ])
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            nameLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = "$ 0.00"
        priceLabel.textColor = .white
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            priceLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            priceLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "Date"
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dateLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            dateLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        contentView.addSubview(collectionButton)
        collectionButton.translatesAutoresizingMaskIntoConstraints = false
        collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
        NSLayoutConstraint.activate([
            collectionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            collectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            collectionButton.heightAnchor.constraint(equalToConstant: 30),
            collectionButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        collectionButton.addTarget(self, action: #selector(addCollection), for: .touchUpInside)
    }
    @objc func addCollection() {
        isCollected.toggle()
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let productID = product?.productId,
              let productName = product?.name,
              let productImageString = product?.imageString,
              let productPrice = product?.price else {
            return
        }
        let db = Firestore.firestore()
        let userCollectionReference = db.collection("collections").document(currentUserID)
        
        userCollectionReference.getDocument { (document, error) in
            if let document = document, document.exists {
                updateCollection()
            } else {
                userCollectionReference.setData(["collectedProducts": []]) { error in
                    if let error = error {
                        print("Error creating document: \(error)")
                    } else {
                        print("Document successfully created.")
                        updateCollection()
                    }
                }
            }
        }
        func updateCollection() {
            let productData: [String: Any] = [
                "productId": productID,
                "name": productName,
                "imageString": productImageString,
                "price": productPrice
            ]
            product?.isCollected = isCollected
            if isCollected {
                userCollectionReference.updateData([
                    "collectedProducts": FieldValue.arrayUnion([productData])
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated with new collection.")
                        self.collectionButton.setImage(UIImage(named: "icons9-bookmark-72(@3×)"), for: .normal)
                    }
                }
            } else {
                let removedProductData: [String: Any] = ["productId": productID]
                userCollectionReference.updateData([
                    "collectedProducts": FieldValue.arrayRemove([removedProductData])
                ]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated with removed collection.")
                        self.collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
                    }
                }
            }
        }
    }
    func updateUI() {
        if let product = product {
            nameLabel.text = product.name
            priceLabel.text = "$\(product.price)"
            dateLabel.text = product.startTime.description
            isCollected = product.isCollected
            if let url = URL(string: product.imageString) {
                imageView.kf.setImage(with: url)
            }
        }
    }
}
