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
        // the number of groups based on user data
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestCell", for: indexPath) as! MyRequestCell

        // Check if the index is within the bounds of the array
        guard indexPath.row < requests.count else {
            // Handle the case where the index is out of bounds
            return cell
        }

        // Access the request at the corresponding index
        let request = requests[indexPath.row]

        // Update the cell based on the request data
        cell.requestNameLabel.text = request.items[0].name
        

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

            // Assuming 'seller.sellerID' is the correct path in your Firestore structure
            let query = productsCollection.whereField("seller.sellerID", isEqualTo: userId)

            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.products.removeAll()

                    for document in querySnapshot!.documents {
                        // Use nil-coalescing to provide an empty dictionary if document.data() is nil
                        let data = document.data() ?? [:]

                        if let product = self.parseProductData(data) {
                            self.products.append(product)
                        }
                    }

                    // Reload your table or collection view after the loop
                    self.groupTableView.reloadData()
                }
            }
        }
    // Method to convert Firestore data to Request object
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

        // Convert itemsData to an array of Product objects
        let items = itemsData.compactMap { productData in
            return parseProductData(productData)
        }

        return Request(
            requestID: requestID,
            buyerID: buyerID,
            items: items,
            selectedSellerID: selectedSellerID,
            status: status
        )
    }

    func parseProductData(_ data: [String: Any]) -> Product? {
        guard
            let name = data["name"] as? String,
            let price = data["price"] as? String,
            let startTime = data["startTime"] as? String,
            let imageString = data["imageString"] as? String,
            let sellerData = data["seller"] as? [String: Any],
            let seller = parseSellerData(sellerData),
            let itemTypeString = data["itemType"] as? String,
            let itemType = ProductType(rawValue: itemTypeString)
        else {
            return nil
        }

        // Optional fields
        let description = data["description"] as? String
        let sort = data["sort"] as? String
        let quantity = data["quantity"] as? String
        let use = data["use"] as? String
        let endTime = data["endTime"] as? String

        return Product(
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
            itemType: itemType
        )
    }

    // Method to parse Seller data
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
    
    // Function to update lineView position with animation
    func animateLineViewTransition(to button: UIButton) {
        // Update selectedButton
        selectedButton?.setTitleColor(.black, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        selectedButton = button
        
        // Animate the movement of the lineView
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = button.frame.origin.x
        }
    }
    
    // Function to animate view transition
    func animateViewTransition(to newView: UIView) {
        UIView.animate(withDuration: 0.3) {
            // Fade out all views
            self.groupTableView.alpha = 0
            self.collectionCollectionView.alpha = 0
            self.requestTableView.alpha = 0
            self.supplyTableView.alpha = 0
        } completion: { _ in
            // Hide all views after animation completion
            self.groupTableView.isHidden = true
            self.collectionCollectionView.isHidden = true
            self.requestTableView.isHidden = true
            self.supplyTableView.isHidden = true
            
            // Show the selected view
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
