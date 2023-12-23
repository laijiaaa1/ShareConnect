//
//  Recoder_Re.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/3.
//

import Foundation
import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

extension RecoderViewController {
    class RecoderTableViewCell: UITableViewCell {
        var order: Order? {
            didSet {
                updateUI()
            }
        }
        let nameLabel = UILabel()
        let productImageView = UIImageView()
        let returnButton = UIButton()
        let backView = UIView()
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        func setupUI() {
            backView.backgroundColor = .white
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
            contentView.backgroundColor = .black
            backView.layer.cornerRadius = 10
            backView.layer.masksToBounds = true
            contentView.addSubview(backView)
            backView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
            productImageView.image = UIImage(named: "product")
            productImageView.layer.cornerRadius = 10
            productImageView.layer.masksToBounds = true
            backView.addSubview(productImageView)
            productImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                productImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
                productImageView.widthAnchor.constraint(equalToConstant: 80),
                productImageView.heightAnchor.constraint(equalToConstant: 80)
            ])
            nameLabel.text = "Product Name"
            nameLabel.font = UIFont.systemFont(ofSize: 16)
            nameLabel.textColor = .black
            backView.addSubview(nameLabel)
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 10),
                nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
                nameLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
                nameLabel.heightAnchor.constraint(equalToConstant: 30)
            ])
            if returnButton.isSelected {
                returnButton.setTitle("Return", for: .normal)
                returnButton.setTitleColor(UIColor(named: "G5"), for: .normal)
                returnButton.backgroundColor = .white
                returnButton.layer.cornerRadius = 5
                returnButton.layer.borderWidth = 1
                returnButton.layer.borderColor = UIColor(named: "G3")?.cgColor
                returnButton.layer.masksToBounds = true
                backView.addSubview(returnButton)
                returnButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    returnButton.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),
                    returnButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
                    returnButton.widthAnchor.constraint(equalToConstant: 80),
                    returnButton.heightAnchor.constraint(equalToConstant: 30)
                ])
            } else {
                returnButton.setTitle("Remind", for: .normal)
                returnButton.setTitleColor(UIColor(named: "G5"), for: .normal)
                returnButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                returnButton.backgroundColor = .white
                returnButton.layer.cornerRadius = 5
                returnButton.layer.borderWidth = 1
                returnButton.layer.borderColor = UIColor(named: "G3")?.cgColor
                returnButton.layer.masksToBounds = true
                backView.addSubview(returnButton)
                returnButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    returnButton.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),
                    returnButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
                    returnButton.widthAnchor.constraint(equalToConstant: 80),
                    returnButton.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
        }
        func updateUI() {
            guard let order = order else { return }
            nameLabel.text = order.orderID
            productImageView.kf.setImage(with: URL(string: order.image))
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
