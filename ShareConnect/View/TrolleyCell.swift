//
//  TrolleyCell.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/6.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class TrolleyCell: UITableViewCell {
    var sellerID: String?
    weak var delegate: TrolleyCellDelegate?
    var seller: Seller?
    var products: [Product] = []
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
    @objc func selectSellerButtonTapped() {
        guard let sellerID = sellerID else { return }
        delegate?.didSelectSeller(sellerID: sellerID)
    }
    func setupUI(seller: Seller, cartItems: [Product], delegate: TrolleyCellDelegate) {
        self.seller = seller
        self.delegate = delegate
        self.products = cartItems
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
            nameLabel.topAnchor.constraint(equalTo: imageViewUP.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: imageViewUP.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
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
    }
    @objc func minusButtonTapped() {
        number = max(1, number - 1)
        updateQuantity()
    }
    @objc func plusButtonTapped() {
        number += 1
        updateQuantity()
    }
    func updateQuantity() {
        guard let product = products.first else {
            return
        }
        delegate?.quantityChanged(forProduct: product, newQuantity: number)
    }
}
