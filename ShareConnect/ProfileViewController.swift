//
//  ProfileViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestCell", for: indexPath) as! MyRequestCell
        
        guard indexPath.row < products.count else {
            cell.requestNameLabel.text = "N/A"
            cell.requestDescriptionLabel.text = "N/A"
            cell.requestDateLabel.text = "N/A"
            return cell
        }
        
        let product = products[indexPath.row]
        cell.requestNameLabel.text = product.name
        cell.requestDescriptionLabel.text = product.description
        cell.requestDateLabel.text = product.startTime
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //  the number of collection items based on user data
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        // Placeholder: Customize the cell based on user data
        cell.backgroundColor = .lightGray
        cell.nameLabel.text = "Item \(indexPath.item + 1)"
        return cell
    }
    var requests: [Request] = []
    var products: [Product] = []
    //    var groups: [Group] = []
    //    var collections: [Collection] = []
    //    var supplies: [Supply] = []
    let headerImage = UIImageView()
    let nameLabel = UILabel()
    let stackView = UIStackView()
    let lineView = UIView()
    let groupButton = UIButton()
    let collectionButton = UIButton()
    let requestButton = UIButton()
    let supplyButton = UIButton()
    let settingButton = UIButton()
    let logoutButton = UIButton()
    let groupTableView = UITableView()
    let collectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let requestTableView = UITableView()
    let supplyTableView = UITableView()
    var selectedButton: UIButton?
    let userId = Auth.auth().currentUser!.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.B1
        tabBarController?.tabBar.backgroundColor = CustomColors.B1
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Luna"
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        // 4 buttons stack view
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.addArrangedSubview(groupButton)
        stackView.addArrangedSubview(collectionButton)
        stackView.addArrangedSubview(requestButton)
        stackView.addArrangedSubview(supplyButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 5),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        // Setting buttons
        let labels = [groupButton, collectionButton, requestButton, supplyButton]
        labels.forEach { (label) in
            label.backgroundColor = .white
            label.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            label.setTitleColor(.black, for: .normal)
        }
        groupButton.setTitle("Group", for: .normal)
        collectionButton.setTitle("Collection", for: .normal)
        requestButton.setTitle("Request", for: .normal)
        supplyButton.setTitle("Supply", for: .normal)
        groupButton.addTarget(self, action: #selector(groupButtonTapped), for: .touchUpInside)
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        supplyButton.addTarget(self, action: #selector(supplyButtonTapped), for: .touchUpInside)
        // Line view
        view.addSubview(lineView)
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
        // Group Table View
        view.addSubview(groupTableView)
        groupTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            groupTableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            groupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            groupTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        groupTableView.dataSource = self
        groupTableView.delegate = self
        groupTableView.register(MyRequestCell.self, forCellReuseIdentifier: "MyRequestCell")
        // Collection Collection View
        collectionCollectionView.isHidden = true
        view.addSubview(collectionCollectionView)
        collectionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            collectionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        // Add this configuration for collectionCollectionView
        let layout = UICollectionViewFlowLayout()
        collectionCollectionView.collectionViewLayout = layout
        collectionCollectionView.dataSource = self
        collectionCollectionView.delegate = self
        collectionCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            fetchRequests(userId: userId)
        }
    }
    func fetchRequests(userId: String) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        
        let query = productsCollection.whereField("product.seller.sellerID", isEqualTo: userId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                self.products.removeAll()
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    if let product = self.parseProductData(productData: data) {
                        self.products.append(product)
                    }
                }
                self.groupTableView.reloadData()
            }
        }
    }
    func parseRequestData(_ data: [String: Any]) -> Request? {
        guard
            let requestID = data["requestID"] as? String,
            let buyerID = data["buyerID"] as? String,
            let itemsData = data["items"] as? [[String: Any]],
            let selectedSellerID = data["selectedSellerID"] as? String,
            let statusString = data["status"] as? String,
            let status = RequestStatus(rawValue: statusString)
        else {
            return nil
        }
        let items = itemsData.compactMap { productData in
            return parseProductData(productData: productData)
        }
        
        return Request(
            requestID: requestID,
            buyerID: buyerID,
            items: items,
            selectedSellerID: selectedSellerID,
            status: status
        )
    }
    
    func parseProductData(productData: [String: Any]) -> Product? {
        guard let product = productData["product"] as? [String: Any],
              //              let productId = product["productId"] as? String,
              let name = product["Name"] as? String,
              let price = product["Price"] as? String,
              let imageString = product["image"] as? String,
              let startTimeString = product["Start Time"] as? String,
              let startTime = product["Start Time"] as? String,
              let endTimeString = product["End Time"] as? String,
              let endTime = product["End Time"] as? String else {
            print("Error: Missing required fields in product data")
            return nil
        }
        let sellerData = product["seller"] as? [String: Any]
        //        let itemTypeRawValue = product["type"] as? String
        guard let sellerID = sellerData?["sellerID"] as? String,
              let sellerName = sellerData?["sellerName"] as? String,
              let itemType = productData["type"] as? String
        else {
            print("Error: Failed to parse seller or itemType")
            return nil
        }
        let description = productData["Description"] as? String ?? ""
        let sort = productData["Sort"] as? String ?? ""
        let quantity = productData["Quantity"] as? String ?? ""
        let use = productData["Use"] as? String ?? ""
        let seller = Seller(sellerID: sellerID, sellerName: sellerName)
        let newProduct = Product(
            //            productId: productId,
            name: name,
            price: price,
            startTime: startTime,
            imageString: imageString,
            description: description,
            sort: sort,
            quantity: quantity,
            use: use,
            endTime: endTime,
            seller: seller,
            itemType: .request
        )
        return newProduct
    }
    func parseSellerData(_ data: [String: Any]) -> Seller? {
        guard
            let sellerID = data["sellerID"] as? String,
            let sellerName = data["sellerName"] as? String
        else {
            return nil
        }
        return Seller(sellerID: sellerID, sellerName: sellerName)
    }
    @objc func groupButtonTapped() {
        animateLineViewTransition(to: groupButton)
        animateViewTransition(to: groupTableView)
        fetchRequests(userId: userId)
    }
    @objc func collectionButtonTapped() {
        animateLineViewTransition(to: collectionButton)
        animateViewTransition(to: collectionCollectionView)
    }
    @objc func requestButtonTapped() {
        animateLineViewTransition(to: requestButton)
        animateViewTransition(to: requestTableView)
    }
    @objc func supplyButtonTapped() {
        animateLineViewTransition(to: supplyButton)
        animateViewTransition(to: supplyTableView)
    }
    func animateLineViewTransition(to button: UIButton) {
        selectedButton?.setTitleColor(.black, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        selectedButton = button
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = button.frame.origin.x
        }
    }
    func animateViewTransition(to newView: UIView) {
        UIView.animate(withDuration: 0.3) {
            self.groupTableView.alpha = 0
            self.collectionCollectionView.alpha = 0
            self.requestTableView.alpha = 0
            self.supplyTableView.alpha = 0
        } completion: { _ in
            self.groupTableView.isHidden = true
            self.collectionCollectionView.isHidden = true
            self.requestTableView.isHidden = true
            self.supplyTableView.isHidden = true
            newView.alpha = 1
            newView.isHidden = false
        }
    }
}
class CollectionCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
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
        requestImageView.translatesAutoresizingMaskIntoConstraints = false
        requestNameLabel.translatesAutoresizingMaskIntoConstraints = false
        requestDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        requestDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            requestImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            requestImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            requestNameLabel.topAnchor.constraint(equalTo: requestImageView.bottomAnchor, constant: 10),
            requestNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestDescriptionLabel.topAnchor.constraint(equalTo: requestNameLabel.bottomAnchor, constant: 10),
            requestDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            requestDateLabel.topAnchor.constraint(equalTo: requestDescriptionLabel.bottomAnchor, constant: 10),
            requestDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            requestDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        requestNameLabel.numberOfLines = 0
        requestDescriptionLabel.numberOfLines = 0
        requestDateLabel.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
