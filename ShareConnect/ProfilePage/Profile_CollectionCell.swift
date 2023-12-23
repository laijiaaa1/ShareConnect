//
//  File.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/3.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher

extension ProfileViewController {
    class CollectionCell: UICollectionViewCell {
        let imageView = UIImageView()
        let nameLabel = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        func setupUI() {
            contentView.addSubview(imageView)
            contentView.addSubview(nameLabel)
            nameLabel.font = UIFont.systemFont(ofSize: 12)
            nameLabel.textColor = .black
            nameLabel.textAlignment = .center
            nameLabel.backgroundColor = .white
            nameLabel.alpha = 0.8
            nameLabel.layer.cornerRadius = 10
            nameLabel.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: 100),
                imageView.widthAnchor.constraint(equalToConstant: 100),
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            nameLabel.textAlignment = .center
            nameLabel.numberOfLines = 0
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
