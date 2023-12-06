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

class MyRequestCell: UITableViewCell {
    let requestImageView = UIImageView()
    let requestNameLabel = UILabel()
    let requestDescriptionLabel = UILabel()
    let requestDateLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(requestImageView)
        contentView.addSubview(requestNameLabel)
        contentView.addSubview(requestDescriptionLabel)
        contentView.addSubview(requestDateLabel)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = CustomColors.B1
        requestImageView.translatesAutoresizingMaskIntoConstraints = false
        requestNameLabel.translatesAutoresizingMaskIntoConstraints = false
        requestDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        requestDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            requestImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            requestImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestImageView.heightAnchor.constraint(equalToConstant: 80),
            requestImageView.widthAnchor.constraint(equalToConstant: 80),
            requestNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            requestNameLabel.leadingAnchor.constraint(equalTo: requestImageView.trailingAnchor, constant: 20),
            requestDescriptionLabel.topAnchor.constraint(equalTo: requestNameLabel.bottomAnchor, constant: 10),
            requestDescriptionLabel.leadingAnchor.constraint(equalTo: requestImageView.trailingAnchor, constant: 20),
            requestDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            requestDateLabel.topAnchor.constraint(equalTo: requestDescriptionLabel.bottomAnchor, constant: 10),
            requestDateLabel.leadingAnchor.constraint(equalTo: requestImageView.trailingAnchor, constant: 20),
            requestDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        requestNameLabel.numberOfLines = 0
        requestImageView.layer.cornerRadius = 10
        requestImageView.layer.masksToBounds = true
        requestDescriptionLabel.numberOfLines = 0
        requestDateLabel.numberOfLines = 0
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
