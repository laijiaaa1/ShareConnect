//
//  CreateViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit

class CreateViewController: UIViewController {
    
    let greenBackColor = UIColor(red: 183/255, green: 234/255, blue: 24/255, alpha: 1.0)
    let myRequestView = UIView()
    let myRequestLabel = UILabel()
    let myRequestButton = UIButton()
    let mySupplyView = UIView()
    let mySupplyLabel = UILabel()
    let mySupplyButton = UIButton()
    let createGroupView = UIView()
    let createGroupLabel = UILabel()
    let createGroupButton = UIButton()
    override func viewDidLoad() {
        view.backgroundColor = CustomColors.B1
        super.viewDidLoad()
        navigationItem.title = "SHARECONNECT"
        myRequestView.layer.cornerRadius = 50
        myRequestView.backgroundColor = .yellow
        myRequestView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myRequestView)
        mySupplyView.layer.cornerRadius = 50
        mySupplyView.backgroundColor = .yellow
        mySupplyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mySupplyView)
        createGroupView.layer.cornerRadius = 50
        createGroupView.backgroundColor = .yellow
        createGroupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createGroupView)
        myRequestButton.setTitle("My request", for: .normal)
        myRequestButton.backgroundColor = greenBackColor
        myRequestButton.setTitleColor(.black, for: .normal)
        myRequestButton.layer.cornerRadius = 25
        myRequestButton.translatesAutoresizingMaskIntoConstraints = false
        mySupplyButton.setTitle("My supply", for: .normal)
        mySupplyButton.backgroundColor = greenBackColor
        mySupplyButton.setTitleColor(.black, for: .normal)
        mySupplyButton.layer.cornerRadius = 25
        mySupplyButton.translatesAutoresizingMaskIntoConstraints = false
        createGroupButton.layer.cornerRadius = 25
        createGroupButton.translatesAutoresizingMaskIntoConstraints = false
        createGroupButton.setTitle("Create group", for: .normal)
        createGroupButton.backgroundColor = greenBackColor
        createGroupButton.setTitleColor(.black, for: .normal)
        createGroupButton.addTarget(self, action: #selector(createGroupButtonTapped), for: .touchUpInside)
        myRequestButton.addTarget(self, action: #selector(myRequestButtonTapped), for: .touchUpInside)
        mySupplyButton.addTarget(self, action: #selector(mySupplyButtonTapped), for: .touchUpInside)
        myRequestView.addSubview(myRequestButton)
        mySupplyView.addSubview(mySupplyButton)
        createGroupView.addSubview(createGroupButton)
        NSLayoutConstraint.activate([
            myRequestView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            myRequestView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            myRequestView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            myRequestView.heightAnchor.constraint(equalToConstant: 100),
            myRequestButton.centerXAnchor.constraint(equalTo: myRequestView.centerXAnchor),
            myRequestButton.topAnchor.constraint(equalTo: myRequestView.topAnchor, constant: 70),
            myRequestButton.widthAnchor.constraint(equalTo: myRequestView.widthAnchor, multiplier: 0.8),
            myRequestButton.heightAnchor.constraint(equalToConstant: 50),
            mySupplyView.topAnchor.constraint(equalTo: myRequestView.bottomAnchor, constant: 80),
            mySupplyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            mySupplyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            mySupplyView.heightAnchor.constraint(equalToConstant: 100),
            mySupplyButton.centerXAnchor.constraint(equalTo: mySupplyView.centerXAnchor),
            mySupplyButton.topAnchor.constraint(equalTo: mySupplyView.topAnchor, constant: 70),
            mySupplyButton.widthAnchor.constraint(equalTo: mySupplyView.widthAnchor, multiplier: 0.8),
            mySupplyButton.heightAnchor.constraint(equalToConstant: 50),
            createGroupView.topAnchor.constraint(equalTo: mySupplyView.bottomAnchor, constant: 80),
            createGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createGroupView.heightAnchor.constraint(equalToConstant: 100),
            createGroupButton.centerXAnchor.constraint(equalTo: createGroupView.centerXAnchor),
            createGroupButton.topAnchor.constraint(equalTo: createGroupView.topAnchor, constant: 70),
            createGroupButton.widthAnchor.constraint(equalTo: createGroupView.widthAnchor, multiplier: 0.8),
            createGroupButton.heightAnchor.constraint(equalToConstant: 50),
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
