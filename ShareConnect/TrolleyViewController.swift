//
//  TrolleyViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import UIKit

class TrolleyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var request: RequestData?
    
//    var trolleyList: [Trolley] = []
    
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Trolley"
        view.backgroundColor = CustomColors.B1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrolleyCell.self, forCellReuseIdentifier: "TrolleyCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.heightAnchor.constraint(equalToConstant: 700),
            tableView.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrolleyCell", for: indexPath) as! TrolleyCell
        cell.setupUI()
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
}
class TrolleyCell: UITableViewCell {
    
    var number: Int = 1 {
        didSet {
            numberLabel.text = "\(number)"
        }
    }
    
    let numberLabel = UILabel()
    let priceLabel = UILabel()

    func setupUI() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backView.heightAnchor.constraint(equalToConstant: 100),
            backView.widthAnchor.constraint(equalToConstant: 100),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        let imageView = UIImageView()
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = "TrolleyCell"
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        let priceLabel = UILabel()
        priceLabel.text = "NT$ "
        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
        
        let minusButton = UIButton()
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
        
        let plusButton = UIButton()
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
    }
    
    @objc func plusButtonTapped() {
        number += 1
    }
}
