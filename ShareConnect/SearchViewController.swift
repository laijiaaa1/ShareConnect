//
//  SearchViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SearchCollectionViewCell
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.product = cell.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRequests.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
        let cellWidth = collectionView.frame.width / 2
        let cellHeight = collectionView.frame.height / 2
        let xPosition = CGFloat(indexPath.item % 2) * cellWidth
        let yPosition = CGFloat(indexPath.item / 2) * cellHeight
        
        cell.frame = CGRect(x: xPosition, y: yPosition, width: cellWidth, height: cellHeight)
        if indexPath.item < allRequests.count {
            cell.product = allRequests[indexPath.item]
        } else {
            cell.product = nil
        }
        
        return cell
    }
    
    var selectedIndexPath: IndexPath?
    
    var allRequests: [Product] = []
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let lineView = UIView()
    let button1 = UIButton()
    let button2 = UIButton()
    let buttonClassification = UIButton()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override func viewDidLoad() {
        view.backgroundColor = CustomColors.B1
        super.viewDidLoad()
        setupUI()
        navigationItem.title = "SHARECONNECT"
        collectionView.delegate = self
        collectionView.dataSource = self
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser()
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
    }
    @objc func refresh() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser()
        collectionView.reloadData()
    }
    func setupUI() {
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        //        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        button1.setTitle("Request", for: .normal)
        button1.setTitleColor(.black, for: .normal)
        button1.layer.borderWidth = 1
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        
        button2.setTitle("Available", for: .normal)
        button2.setTitleColor(.black, for: .normal)
        button2.layer.borderWidth = 1
        button2.addTarget(self, action: #selector(button2Action), for: .touchUpInside)
        
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.center.x = button1.center.x
        view.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineView.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            lineView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        buttonClassification.backgroundColor = .white
        buttonClassification.translatesAutoresizingMaskIntoConstraints = false
        buttonClassification.layer.borderWidth = 1
        buttonClassification.layer.cornerRadius = 20
        buttonClassification.setTitle("Class", for: .normal)
        buttonClassification.setTitleColor(.black, for: .normal)
        view.addSubview(buttonClassification)
        NSLayoutConstraint.activate([
            buttonClassification.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 10),
            buttonClassification.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonClassification.widthAnchor.constraint(equalToConstant: 60),
            buttonClassification.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = CustomColors.B1
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: buttonClassification.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scrollView.contentSize = CGSize(width: view.frame.width, height: lineView.frame.origin.y + collectionView.frame.height)
    }
    @objc func button1Action() {
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = 0
        }
        
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser()
    }
    
    @objc func button2Action() {
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame.origin.x = self.view.frame.width / 2
        }
        let userID = Auth.auth().currentUser?.uid ?? ""
        fetchRequestsForUser()
    }
    
    func fetchRequestsForUser() {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        
        productsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.allRequests.removeAll()
                
                for document in querySnapshot!.documents {
                    let productData = document.data()
                    
                    if let productTypeRawValue = productData["type"] as? String,
                       let productType = ProductType(rawValue: productTypeRawValue),
                       let product = self.parseProductData(productData: productData) {
                        
                        if (productType == .request && product.itemType == .request) ||
                            (productType == .supply && product.itemType == .supply) {
                            self.allRequests.append(product)
                        } else {
                            print("Skipped product with type \(productType) and itemType \(product.itemType)")
                        }
                    } else {
                        print("Error parsing product type")
                    }
                }
                print("Fetched products: \(self.allRequests)")
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
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

}
class SearchCollectionViewCell: UICollectionViewCell {
    let underView = UIView()
    let imageView = UIImageView()
    let priceLabel = UILabel()
    let button = UIButton()
    let dateLabel = UILabel()
    let nameLabel = UILabel()
    let collectionButton = UIButton()
    
    var product: Product? {
        didSet {
            print("Request didSet")
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = 10
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6)
        ])
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            nameLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = "$ 0.00"
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            priceLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            priceLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "Date"
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            dateLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Provide", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 15),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    func updateUI() {
        if let product = product {
            nameLabel.text = product.name
            priceLabel.text = "$\(product.price)"
            dateLabel.text = product.startTime.description
            
            if let url = URL(string: product.imageString) {
                imageView.kf.setImage(with: url)
            }
        }
    }
}
