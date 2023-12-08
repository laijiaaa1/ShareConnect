//
//  ChatRoomCell.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/9.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import MapKit
import CoreLocation

class TextCell: UITableViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let image: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var chatMessage: ChatMessage?
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        timestampLabel.text = ""
        nameLabel.text = ""
        image.image = nil
        messageLabel.text = ""
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(label)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(messageLabel)
        image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        image.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
        timestampLabel.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -20).isActive = true
        timestampLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: -5).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
        messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    func configure(with chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        label.text = chatMessage.text
        nameLabel.text = chatMessage.buyerID == Auth.auth().currentUser?.uid ? chatMessage.name ?? "Buyer" :  "Seller"
        image.kf.setImage(with: URL(string: chatMessage.profileImageUrl))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
        timestampLabel.textColor = .gray
        //        timestampLabel.textAlignment = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .right : .left
    }
}
class ImageCell: UITableViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let image: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let imageURLpost: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    var chatMessage: ChatMessage?
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        timestampLabel.text = ""
        nameLabel.text = ""
        image.image = nil
        imageURLpost.image = nil
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(label)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(imageURLpost)
        NSLayoutConstraint.activate([
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            image.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
            label.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            timestampLabel.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -20),
            timestampLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: -5),
            imageURLpost.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15),
            imageURLpost.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageURLpost.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            imageURLpost.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    func configure(with chatMessage: ChatMessage) {
        label.text = chatMessage.text
        nameLabel.text = chatMessage.name
        image.kf.setImage(with: URL(string: chatMessage.profileImageUrl))
        imageURLpost.kf.setImage(with: URL(string: chatMessage.imageURL ?? ""))
    }
}
class MapCell: UITableViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let image: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let map: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 15
        map.layer.masksToBounds = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    var chatMessage: ChatMessage?
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        timestampLabel.text = ""
        nameLabel.text = ""
        image.image = nil
        map.mapType = .standard
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(label)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(map)
        NSLayoutConstraint.activate([
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            image.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
            label.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            timestampLabel.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -20),
            timestampLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: -5),
            map.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15),
            map.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            map.widthAnchor.constraint(lessThanOrEqualToConstant: 50),
            map.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    func configure(with chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        label.text = chatMessage.text
        nameLabel.text = chatMessage.name
        image.kf.setImage(with: URL(string: chatMessage.profileImageUrl))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap(_:)))
        label.addGestureRecognizer(tapGesture)
    }
    @objc func openMap(_ gesture: UITapGestureRecognizer) {
        guard let mapLink = chatMessage?.text, let url = URL(string: mapLink) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
