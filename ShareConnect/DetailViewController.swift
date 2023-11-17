//
//  DetailViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/17.
//

import UIKit

class DetailViewController: UIViewController {
    
    let titleLabel = UILabel()
    let detailImage = UIImageView()
    let price = UILabel()
    let priceImage = UIImageView()
    let addCartButton = UIButton()
    let chatButton = UIButton()
    
    let availabilityView = UIView()
    let availability = UILabel()
    
    let descriptionView = UIView()
    let descriptionLabel = UILabel()
    let descriptionButton = UIButton()
    
    let otherView = UIView()
    let otherLabel = UILabel()
    let otherButton = UIButton()
    
    let collectionButton = UIButton()
    let shareButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.B1
        setupView()
        
    }
    
    func setupView() {
        view.addSubview(titleLabel)
        titleLabel.text = "Title"
        titleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 30)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(detailImage)
        detailImage.image = UIImage(named: "wait")
        detailImage.contentMode = .scaleAspectFit
        detailImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            detailImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailImage.heightAnchor.constraint(equalToConstant: 160),
            detailImage.widthAnchor.constraint(equalToConstant: 320)
        ])
        view.addSubview(priceImage)
        priceImage.image = UIImage(named: "price")
        priceImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceImage.topAnchor.constraint(equalTo: detailImage.bottomAnchor, constant: 30),
            priceImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            priceImage.heightAnchor.constraint(equalToConstant: 30),
            priceImage.widthAnchor.constraint(equalToConstant: 30)
        ])
        view.addSubview(price)
        price.text = "800 / Day"
        price.font = UIFont(name: "PingFangTC-Semibold", size: 15)
        price.textColor = .black
        price.translatesAutoresizingMaskIntoConstraints = false
        price.centerYAnchor.constraint(equalTo: priceImage.centerYAnchor).isActive = true
        price.leadingAnchor.constraint(equalTo: priceImage.trailingAnchor, constant: 30).isActive = true
        
        view.addSubview(addCartButton)
        addCartButton.setImage(UIImage(named: "icons8-buy-72(@3×)"), for: .normal)
        addCartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addCartButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            addCartButton.leadingAnchor.constraint(equalTo: price.trailingAnchor, constant: 100),
            addCartButton.heightAnchor.constraint(equalToConstant: 30),
            addCartButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        view.addSubview(chatButton)
        chatButton.setImage(UIImage(named: "icons8-chat-72(@3×)"), for: .normal)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatButton.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            chatButton.leadingAnchor.constraint(equalTo: addCartButton.trailingAnchor, constant: 30),
            chatButton.heightAnchor.constraint(equalToConstant: 30),
            chatButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        view.addSubview(collectionButton)
        collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
        collectionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 40),
            collectionButton.heightAnchor.constraint(equalToConstant: 30),
            collectionButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        view.addSubview(shareButton)
        shareButton.setImage(UIImage(named: "icons8-share-72(@3×)"), for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            shareButton.leadingAnchor.constraint(equalTo: collectionButton.trailingAnchor, constant: 30),
            shareButton.heightAnchor.constraint(equalToConstant: 30),
            shareButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        view.addSubview(availabilityView)
        availabilityView.backgroundColor = .white
        availabilityView.layer.cornerRadius = 10
        availabilityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            availabilityView.topAnchor.constraint(equalTo: priceImage.bottomAnchor, constant: 30),
            availabilityView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            availabilityView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            availabilityView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        availabilityView.addSubview(availability)
        availability.text = "Availability"
        availability.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        availability.textColor = .black
        availability.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            availability.centerYAnchor.constraint(equalTo: availabilityView.centerYAnchor),
            availability.leadingAnchor.constraint(equalTo: availabilityView.leadingAnchor, constant: 30)
        ])

        
        let dateImage = UIImageView()
        availabilityView.addSubview(dateImage)
        dateImage.image = UIImage(named: "icons8-today-72(@3×)")
        dateImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateImage.centerYAnchor.constraint(equalTo: availability.centerYAnchor),
            dateImage.widthAnchor.constraint(equalToConstant: 30),
            dateImage.heightAnchor.constraint(equalToConstant: 30),
            dateImage.trailingAnchor.constraint(equalTo: availabilityView.trailingAnchor, constant: -30)
        ])
        
        view.addSubview(descriptionView)
        descriptionView.backgroundColor = .white
        descriptionView.layer.cornerRadius = 10
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionView.topAnchor.constraint(equalTo: availabilityView.bottomAnchor, constant: 30),
            descriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            descriptionView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        descriptionView.addSubview(descriptionLabel)
        descriptionLabel.text = "Product details"
        descriptionLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        descriptionLabel.textColor = .black
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.centerYAnchor.constraint(equalTo: descriptionView.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 30)
        ])
        descriptionView.addSubview(descriptionButton)
        descriptionButton.setImage(UIImage(named: "icons8-next-72(@3×)"), for: .normal)
        descriptionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionButton.centerYAnchor.constraint(equalTo: descriptionView.centerYAnchor),
            descriptionButton.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: -30),
            descriptionButton.heightAnchor.constraint(equalToConstant: 20),
            descriptionButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        view.addSubview(otherView)
        otherView.backgroundColor = .white
        otherView.layer.cornerRadius = 10
        otherView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherView.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 30),
            otherView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            otherView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            otherView.heightAnchor.constraint(equalToConstant: 80)
        ])
        otherView.addSubview(otherLabel)
        otherLabel.text = "Other remark"
        otherLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        otherLabel.textColor = .black
        otherLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherLabel.centerYAnchor.constraint(equalTo: otherView.centerYAnchor),
            otherLabel.leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: 30)
        ])
        otherView.addSubview(otherButton)
        otherButton.setImage(UIImage(named: "icons8-next-72(@3×)"), for: .normal)
        otherButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherButton.centerYAnchor.constraint(equalTo: otherView.centerYAnchor),
            otherButton.trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -30),
            otherButton.heightAnchor.constraint(equalToConstant: 20),
            otherButton.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
}
