//
//  RecoderViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct Order {
    let orderID: String
    let buyerID: String
    let sellerID: String
    let image: String
    let createdAt: Date
    let cart: [[String: Any]]
    
    init?(document: QueryDocumentSnapshot) {
        guard let data = document.data() as? [String: Any],
              let orderID = document.documentID as? String,
              let buyerID = data["buyerID"] as? String,
              let sellerID = data["sellerID"] as? String,
              let image = data["image"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let cart = data["cart"] as? [[String: Any]]
        else {
            return nil
        }
        
        self.orderID = orderID
        self.buyerID = buyerID
        self.sellerID = sellerID
        self.image = image
        self.createdAt = createdAtTimestamp.dateValue()
        self.cart = cart
    }
}


class RecoderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var orderID: [Order] = []
 
    let rentalButton = UIButton()
    let loanButton = UIButton()
    let stackView = UIStackView()
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.B1
        navigationItem.title = "RECODER"
        
        rentalButton.setTitle("Rental Items", for: .normal)
        loanButton.setTitle("On Loan", for: .normal)
        rentalButton.setTitleColor(.black, for: .normal)
        loanButton.setTitleColor(.black, for: .normal)
        
        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        stackView.addArrangedSubview(rentalButton)
        stackView.addArrangedSubview(loanButton)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(RecoderTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = CustomColors.B1
        tableView.separatorStyle = .none
        
        fetchOrdersFromFirestore()
        
    }
    func fetchOrdersFromFirestore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }

        let ordersCollection = Firestore.firestore().collection("orders")

        // Assuming you have a field in the order documents that specifies the buyer ID
        ordersCollection.whereField("buyerID", isEqualTo: currentUserID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let querySnapshot = querySnapshot else {
                return
            }

            if let error = error {
                print("Error fetching orders: \(error.localizedDescription)")
                return
            }

            self.orderID = querySnapshot.documents.compactMap { document in
                return Order(document: document)
            }
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return orderID.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecoderTableViewCell
            cell.order = orderID[indexPath.row]
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 150
        }
}

class RecoderTableViewCell: UITableViewCell{
    
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
        
        backView.backgroundColor = .white
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
        backView.addSubview(productImageView)
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10),
            productImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        nameLabel.text = "Product Name"
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        backView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
            nameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        returnButton.setTitle("Return", for: .normal)
        returnButton.setTitleColor(.black, for: .normal)
        returnButton.backgroundColor = .white
        returnButton.layer.cornerRadius = 5
        returnButton.layer.borderWidth = 1
        returnButton.layer.masksToBounds = true
        backView.addSubview(returnButton)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            returnButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -10),
            returnButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
            returnButton.widthAnchor.constraint(equalToConstant: 80),
            returnButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
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
