//
//  CreateViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit

class CreateViewController: UIViewController {
    let greenBackColor = UIColor(red: 183/255, green: 234/255, blue: 24/255, alpha: 1.0)
    let myRequestView = UIImageView()
    let myRequestLabel = UILabel()
    let myRequestButton = UIButton()
    let mySupplyView = UIImageView()
    let mySupplyLabel = UILabel()
    let mySupplyButton = UIButton()
    let createGroupView = UIImageView()
    let createGroupLabel = UILabel()
    let createGroupButton = UIButton()
    override func viewDidLoad() {
        view.backgroundColor = CustomColors.B1
        super.viewDidLoad()
        navigationItem.title = "SHARECONNECT"
        myRequestView.layer.cornerRadius = 50
        myRequestView.image = UIImage(named: "request")
        myRequestView.contentMode = .scaleAspectFill
        myRequestView.layer.masksToBounds = true
        myRequestView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myRequestView)
        mySupplyView.layer.cornerRadius = 50
        mySupplyView.image = UIImage(named: "supply")
        mySupplyView.contentMode = .scaleAspectFill
        mySupplyView.layer.masksToBounds = true
        mySupplyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mySupplyView)
        createGroupView.layer.cornerRadius = 50
        createGroupView.image = UIImage(named: "group")
        createGroupView.contentMode = .scaleAspectFill
        createGroupView.layer.masksToBounds = true
        createGroupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createGroupView)
        myRequestButton.setTitle("My request", for: .normal)
        myRequestButton.backgroundColor = .black
        myRequestButton.setTitleColor(.white, for: .normal)
        myRequestButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        myRequestButton.layer.cornerRadius = 25
        myRequestButton.layer.borderWidth = 1
        myRequestButton.layer.borderColor = UIColor.black.cgColor
        myRequestButton.layer.shadowColor = UIColor.black.cgColor
        myRequestButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        myRequestButton.layer.shadowRadius = 4
        myRequestButton.layer.shadowOpacity = 0.5
        myRequestButton.translatesAutoresizingMaskIntoConstraints = false
        mySupplyButton.setTitle("My supply", for: .normal)
        mySupplyButton.backgroundColor = .black
        mySupplyButton.setTitleColor(.white, for: .normal)
        mySupplyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        mySupplyButton.layer.cornerRadius = 25
        mySupplyButton.translatesAutoresizingMaskIntoConstraints = false
        mySupplyButton.layer.borderWidth = 1
        mySupplyButton.layer.borderColor = UIColor.black.cgColor
        mySupplyButton.layer.shadowColor = UIColor.black.cgColor
        mySupplyButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        mySupplyButton.layer.shadowRadius = 4
        mySupplyButton.layer.shadowOpacity = 0.5
        createGroupButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createGroupButton.layer.cornerRadius = 25
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        createGroupButton.setTitle("Create group", for: .normal)
        createGroupButton.backgroundColor = .black
        createGroupButton.setTitleColor(.white, for: .normal)
        createGroupButton.layer.borderWidth = 1
        createGroupButton.layer.borderColor = UIColor.black.cgColor
        createGroupButton.layer.shadowColor = UIColor.black.cgColor
        createGroupButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        createGroupButton.layer.shadowRadius = 4
        createGroupButton.layer.shadowOpacity = 0.5
        createGroupButton.addTarget(self, action: #selector(createGroupButtonTapped), for: .touchUpInside)
        myRequestButton.addTarget(self, action: #selector(myRequestButtonTapped), for: .touchUpInside)
        mySupplyButton.addTarget(self, action: #selector(mySupplyButtonTapped), for: .touchUpInside)
        view.addSubview(myRequestButton)
        view.addSubview(mySupplyButton)
        view.addSubview(createGroupButton)
        NSLayoutConstraint.activate([
            myRequestView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            myRequestView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            myRequestView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            myRequestView.heightAnchor.constraint(equalToConstant: 150),
            myRequestButton.centerXAnchor.constraint(equalTo: myRequestView.centerXAnchor),
            myRequestButton.topAnchor.constraint(equalTo: myRequestView.bottomAnchor, constant: -40),
            myRequestButton.widthAnchor.constraint(equalTo: myRequestView.widthAnchor, multiplier: 0.8),
            myRequestButton.heightAnchor.constraint(equalToConstant: 50),
            mySupplyView.topAnchor.constraint(equalTo: myRequestView.bottomAnchor, constant: 60),
            mySupplyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            mySupplyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            mySupplyView.heightAnchor.constraint(equalToConstant: 150),
            mySupplyButton.centerXAnchor.constraint(equalTo: mySupplyView.centerXAnchor),
            mySupplyButton.topAnchor.constraint(equalTo: mySupplyView.bottomAnchor, constant: -40),
            mySupplyButton.widthAnchor.constraint(equalTo: mySupplyView.widthAnchor, multiplier: 0.8),
            mySupplyButton.heightAnchor.constraint(equalToConstant: 50),
            createGroupView.topAnchor.constraint(equalTo: mySupplyView.bottomAnchor, constant: 60),
            createGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createGroupView.heightAnchor.constraint(equalToConstant: 150),
            createGroupButton.centerXAnchor.constraint(equalTo: createGroupView.centerXAnchor),
            createGroupButton.topAnchor.constraint(equalTo: createGroupView.bottomAnchor, constant: -40),
            createGroupButton.widthAnchor.constraint(equalTo: createGroupView.widthAnchor, multiplier: 0.8),
            createGroupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    @objc func myRequestButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createRequestViewController = storyboard.instantiateViewController(withIdentifier: "CreateRequestViewController") as! CreateRequestViewController
        navigationController?.pushViewController(createRequestViewController, animated: true)
    }
    @objc func mySupplyButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createSupplyViewController = storyboard.instantiateViewController(withIdentifier: "CreateSupplyViewController") as! CreateSupplyViewController
        navigationController?.pushViewController(createSupplyViewController, animated: true)
    }
    @objc func createGroupButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createGroupViewController = storyboard.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        navigationController?.pushViewController(createGroupViewController, animated: true)
    }
}
