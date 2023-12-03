//
//  SellerInfo_CommendTableViewCell.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/3.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

extension SellerInfoViewController {
    class CommendTableViewCell: UITableViewCell {
        var commendName = UILabel()
        var commendRating = UILabel()
        let commendRatingStar = UIImageView()
        var commendProduct = UILabel()
        let commendProductImage = UIImageView()
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(commendName)
            commendName.text = "Name"
            commendName.font = UIFont(name: "PingFangTC-Semibold", size: 20)
            commendName.textColor = .black
            commendName.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                commendName.topAnchor.constraint(equalTo: contentView.topAnchor),
                commendName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            ])
            contentView.addSubview(commendRating)
            commendRating.text = "4"
            commendRating.font = UIFont(name: "PingFangTC-Semibold", size: 20)
            commendRating.textColor = .black
            commendRating.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                commendRating.topAnchor.constraint(equalTo: commendName.bottomAnchor, constant: 10),
                commendRating.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
            ])
            contentView.addSubview(commendRatingStar)
            commendRatingStar.image = UIImage(systemName: "star.fill")
            commendRatingStar.tintColor = .black
            commendRatingStar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                commendRatingStar.centerYAnchor.constraint(equalTo: commendRating.centerYAnchor),
                commendRatingStar.leadingAnchor.constraint(equalTo: commendRating.trailingAnchor, constant: 10)
            ])
            contentView.addSubview(commendProduct)
            commendProduct.text = "Product"
            commendProduct.font = UIFont(name: "PingFangTC", size: 12)
            commendProduct.textColor = .black
            commendProduct.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                commendProduct.topAnchor.constraint(equalTo: commendRating.bottomAnchor, constant: 10),
                commendProduct.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
            ])
            contentView.addSubview(commendProductImage)
            commendProductImage.image = UIImage(systemName: "star.fill")
            commendProductImage.layer.cornerRadius = 10
            commendProductImage.clipsToBounds = true
            commendProductImage.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                commendProductImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                commendProductImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
                commendProductImage.heightAnchor.constraint(equalToConstant: 80),
                commendProductImage.widthAnchor.constraint(equalToConstant: 80)
            ])
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
