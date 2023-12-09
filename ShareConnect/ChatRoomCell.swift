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
    let timestampLabel: UILabel = {
        let timestampLabel = UILabel()
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        return timestampLabel
    }()
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .gray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    let image: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 15
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()
    var chatMessage: ChatMessage?
    override func prepareForReuse() {
        super.prepareForReuse()
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
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(messageLabel)
//        let isMe = Auth.auth().currentUser?.uid
//        if isMe == chatMessage?.buyerID {
//            messageLabel.textAlignment = .right
//            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
//            image.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
//            messageLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
//            timestampLabel.trailingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -20).isActive = true
//            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
//            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
//            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
//            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
//            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
//            
//        } else {
//            messageLabel.textAlignment = .left
//            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
//            image.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
//            messageLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 15).isActive = true
//            timestampLabel.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 20).isActive = true
//            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
//            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
//            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
//            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
//            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
//        }
    }
    func configure(with chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        messageLabel.text = chatMessage.text
        nameLabel.text = chatMessage.name
        image.kf.setImage(with: URL(string: chatMessage.profileImageUrl))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
        timestampLabel.textColor = .gray
    }
}
class ImageCell: UITableViewCell {
    let timestampLabel: UILabel = {
        let timestampLabel = UILabel()
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        return timestampLabel
    }()
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .gray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
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
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(imageURLpost)
//        let isMe = chatMessage?.buyerID == Auth.auth().currentUser?.uid
//        if isMe == true {
//            timestampLabel.textAlignment = .right
//            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
//            image.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
//            timestampLabel.trailingAnchor.constraint(equalTo: imageURLpost.leadingAnchor, constant: -20).isActive = true
//
//            imageURLpost.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
//            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
//            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
//            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            imageURLpost.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            imageURLpost.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
//            imageURLpost.widthAnchor.constraint(equalToConstant: 80).isActive = true
//            nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
//            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
//        } else {
//            timestampLabel.textAlignment = .left
//            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
//            image.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
//            imageURLpost.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 15).isActive = true
//            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
//            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
//            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            timestampLabel.leadingAnchor.constraint(equalTo: imageURLpost.trailingAnchor, constant: 20).isActive = true
//            imageURLpost.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
//            imageURLpost.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
//            imageURLpost.widthAnchor.constraint(equalToConstant: 80).isActive = true
//            nameLabel.centerXAnchor.constraint(equalTo: image.centerXAnchor).isActive = true
//            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
//        }
    }
    func configure(with chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        nameLabel.text = chatMessage.name
        image.kf.setImage(with: URL(string: chatMessage.profileImageUrl))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
        timestampLabel.textColor = .gray
    }
}
class MapCell: UITableViewCell {
    let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()
    let timestampLabel: UILabel = {
        let timestampLabel = UILabel()
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        return timestampLabel
    }()
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .gray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
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
        messageLabel.text = ""
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
        contentView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(map)
        let isMe = chatMessage?.buyerID == Auth.auth().currentUser?.uid
        if isMe == true {
            messageLabel.textAlignment = .right
           
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            image.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
            map.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
            map.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
            map.widthAnchor.constraint(equalToConstant: 150).isActive = true
            map.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
            timestampLabel.trailingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -20).isActive = true
            timestampLabel.textAlignment = .right
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
            nameLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -15).isActive = true
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
        } else {
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
            image.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 15).isActive = true
            image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            nameLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 15).isActive = true
            map.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
            map.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
            map.widthAnchor.constraint(equalToConstant: 150).isActive = true
            map.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 15).isActive = true
           
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
            timestampLabel.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 20).isActive = true
            timestampLabel.textAlignment = .left
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
            nameLabel.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 15).isActive = true
        }
    }
    func configure(with chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        messageLabel.text = chatMessage.text
        messageLabel.isUserInteractionEnabled = true
        nameLabel.text = chatMessage.name
        image.kf.setImage(with: URL(string: chatMessage.profileImageUrl))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap(_:)))
        messageLabel.addGestureRecognizer(tapGesture)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
        timestampLabel.textColor = .gray
    }
    @objc func openMap(_ gesture: UITapGestureRecognizer) {
        guard let mapLink = chatMessage?.text, let url = URL(string: mapLink) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
