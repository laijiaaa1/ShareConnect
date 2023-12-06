//
//  SubGroupViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/26.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import MJRefresh
import Kingfisher

class SubGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ClassCollectionViewCellDelegate {
    var selectedIndexPath: IndexPath?
    var allRequests: [Product] = []
    var allSupplies: [Product] = []
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let lineView = UIView()
    let button1 = UIButton()
    let button2 = UIButton()
    var usification: String?
    var currentButtonType: ProductType = .request
    var group: Group?
    let classCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ClassCollectionViewCell.self, forCellWithReuseIdentifier: "classCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 180, height: 300)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override func viewWillAppear(_ animated: Bool) {
        fetchRequestsForUser(type: .request)
    }
    override func viewDidLoad() {
        view.backgroundColor = CustomColors.B1
        super.viewDidLoad()
        loadSavedCollections()
        tabBarController?.tabBar.backgroundColor = CustomColors.B1
        collectionView.showsVerticalScrollIndicator = false
        setupUI()
        navigationItem.title = "SHARECONNECT"
        navigationController?.navigationBar.isHidden = false
        collectionView.delegate = self
        collectionView.dataSource = self
        classCollectionView.delegate = self
        classCollectionView.dataSource = self
        let userID = Auth.auth().currentUser?.uid ?? ""
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    func loadSavedCollections() {
        let savedCollections = UserDefaults.standard.array(forKey: "SavedCollections") as? [[String: Any]] ?? []
        collectionView.reloadData()
    }
    @objc func refresh() {
        let userID = Auth.auth().currentUser?.uid ?? ""
        if currentButtonType == .request {
            fetchRequestsForUser(type: .request)
        } else if currentButtonType == .supply {
            fetchRequestsForUser(type: .supply)
        }
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if collectionView == classCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ClassCollectionViewCell
            cell?.updateUI()
        }
        if collectionView == self.collectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell {
                guard let name = cell.product?.name else { return }
                let image = cell.product?.imageString ?? ""
                let price = cell.product?.price ?? ""
                let type = cell.product?.itemType ?? .request
                let productId = cell.product?.productId ?? ""
                FirestoreService.shared.addBrowsingRecord(name: name, image: image, price: price, type: type.rawValue, productId: productId)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProvideViewController") as! ProvideViewController
                let deVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                vc.product = cell.product
                deVC.product = cell.product
                if currentButtonType == .request {
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if currentButtonType == .supply{
                    self.navigationController?.pushViewController(deVC, animated: true)
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == classCollectionView {
            return 1
        }
        if collectionView == collectionView {
            if currentButtonType == .request {
                return allRequests.count
            } else if currentButtonType == .supply {
                return allSupplies.count
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == classCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classCell", for: indexPath) as! ClassCollectionViewCell
            cell.currentButtonType = currentButtonType
            cell.delegate = self
            cell.updateUI()
            return cell
        }
        if collectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
            if currentButtonType == .request {
                cell.product = allRequests[indexPath.item]
            } else if currentButtonType == .supply {
                cell.product = allSupplies[indexPath.item]
            }
            return cell
        }
        return UICollectionViewCell()
    }
    func didSelectClassification(_ classification: String, forType type: ProductType) {
        fetchDataForSort(classification: classification, type: type)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2
        let cellHeight = collectionView.frame.height / 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    @objc func button1Action() {
        currentButtonType = .request
        lineView.center.x = button1.center.x
        button1.setTitleColor(.black, for: .normal)
        button2.setTitleColor(.lightGray, for: .normal)
        fetchRequestsForUser(type: .request)
        collectionView.reloadData()
    }
    @objc func button2Action() {
        currentButtonType = .supply
        lineView.center.x = button2.center.x
        button1.setTitleColor(.lightGray, for: .normal)
        button2.setTitleColor(.black, for: .normal)
        
        fetchRequestsForUser(type: .supply)
        
        collectionView.reloadData()
    }
    func setupUI() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        button1.setTitle("Request", for: .normal)
        button1.setTitleColor(.black, for: .normal)
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        button2.setTitle("Available", for: .normal)
        button2.setTitleColor(.black, for: .normal)
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
        classCollectionView.backgroundColor = CustomColors.B1
        classCollectionView.translatesAutoresizingMaskIntoConstraints = false
        classCollectionView.showsHorizontalScrollIndicator = false
        view.addSubview(classCollectionView)
        NSLayoutConstraint.activate([
            classCollectionView.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            classCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            classCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            classCollectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 600, height: 40)
        classCollectionView.collectionViewLayout = layout
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        view.addSubview(collectionView)
        collectionView.backgroundColor = CustomColors.B1
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: classCollectionView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        scrollView.contentSize = CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
    func fetchRequestsForUser(type: ProductType) {
        guard let groupId = group?.documentId else {
            print("Group ID is nil.")
            return
        }
        let db = Firestore.firestore()
        let productsCollection = db.collection("productsGroup").whereField("product.groupID", isEqualTo: groupId)
        productsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if self.currentButtonType == .request {
                    self.allRequests.removeAll()
                } else if self.currentButtonType == .supply {
                    self.allSupplies.removeAll()
                }
                for document in querySnapshot!.documents {
                    let productData = document.data()
                    if let productTypeRawValue = productData["type"] as? String,
                       let productType = ProductType(rawValue: productTypeRawValue),
                       let product = self.parseProductData(productData: productData) {
                        if productType == type && product.itemType == type {
                            print("Appending \(type): \(product)")
                            if type == .request {
                                self.allRequests.append(product)
                            } else if type == .supply {
                                self.allSupplies.append(product)
                            }
                        }
                    } else {
                        print("Error parsing product type")
                    }
                }
                if type == .request {
                    self.allRequests.sort(by: { $0.startTime < $1.startTime })
                } else if type == .supply {
                    self.allSupplies.sort(by: { $0.startTime < $1.startTime })
                }
                print("All requests: \(self.allRequests)")
                print("All supplies: \(self.allSupplies)")
                
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    func parseProductData(productData: [String: Any]) -> Product? {
        guard let product = productData["product"] as? [String: Any],
              let productId = product["productId"] as? String,
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
        guard let sellerID = sellerData?["sellerID"] as? String,
              let sellerName = sellerData?["sellerName"] as? String,
              let itemType = productData["type"] as? String
        else {
            print("Error: Failed to parse seller or itemType")
            return nil
        }
        let description = product["Description"] as? String ?? ""
        let sort = product["Sort"] as? String ?? ""
        let quantity = product["Quantity"] as? Int ?? 0
        let use = product["Use"] as? String ?? ""
        let seller = Seller(sellerID: sellerID, sellerName: sellerName)
        let newProduct = Product(
            productId: productId,
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
            itemType: ProductType(rawValue: itemType)!
        )
        return newProduct
    }
    func fetchDataForSort(classification: String, type: ProductType) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        productsCollection.getDocuments { (querySnapshot, error) in
            if self.currentButtonType == .request {
                self.allRequests.removeAll()
            } else if self.currentButtonType == .supply {
                self.allSupplies.removeAll()
            }
            for document in querySnapshot!.documents {
                let productData = document.data()
                if let productTypeRawValue = productData["type"] as? String,
                   let productType = ProductType(rawValue: productTypeRawValue),
                   let product = self.parseProductData(productData: productData) {
                    if productType == type {
                        if product.itemType == type {
                            print("Appending \(type): \(product)")
                            if type == .request {
                                if product.sort == classification {
                                    self.allRequests.append(product)
                                }
                            } else if type == .supply {
                                if product.sort == classification {
                                    self.allSupplies.append(product)
                                }
                            }
                        }
                    } else {
                        print("Skipped product with unknown type: \(productType)")
                    }
                } else {
                    print("Error parsing product type")
                }
            }
            if type == .request {
                self.allRequests.sort(by: { $0.startTime < $1.startTime })
            } else if type == .supply {
                self.allSupplies.sort(by: { $0.startTime < $1.startTime })
            }
            print("All requests: \(self.allRequests)")
            print("All supplies: \(self.allSupplies)")
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}
//class SearchCollectionViewCell: UICollectionViewCell {
//    let underView = UIView()
//    let imageView = UIImageView()
//    let priceLabel = UILabel()
//    let button = UIButton()
//    let dateLabel = UILabel()
//    let nameLabel = UILabel()
//    let collectionButton = UIButton()
//    var isCollected = false
//    var product: Product? {
//        didSet {
//            print("Request didSet")
//            updateUI()
//        }
//    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    func setupUI() {
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.backgroundColor = .yellow
//        imageView.layer.cornerRadius = 10
//        imageView.layer.masksToBounds = true
//        contentView.addSubview(imageView)
//        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -20),
//            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6)
//        ])
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel.text = "Name"
//        nameLabel.font = UIFont.systemFont(ofSize: 12)
//        contentView.addSubview(nameLabel)
//        NSLayoutConstraint.activate([
//            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            nameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
//            nameLabel.heightAnchor.constraint(equalToConstant: 15)
//        ])
//        priceLabel.translatesAutoresizingMaskIntoConstraints = false
//        priceLabel.text = "$ 0.00"
//        priceLabel.font = UIFont.systemFont(ofSize: 12)
//        contentView.addSubview(priceLabel)
//        NSLayoutConstraint.activate([
//            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
//            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            priceLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width),
//            priceLabel.heightAnchor.constraint(equalToConstant: 15)
//        ])
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//        dateLabel.text = "Date"
//        dateLabel.font = UIFont.systemFont(ofSize: 12)
//        contentView.addSubview(dateLabel)
//        NSLayoutConstraint.activate([
//            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
//            dateLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
//            dateLabel.heightAnchor.constraint(equalToConstant: 15)
//        ])
////        button.translatesAutoresizingMaskIntoConstraints = false
////        button.setTitleColor(.black, for: .normal)
////        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
////        button.backgroundColor = .white
////        button.layer.borderWidth = 1
////        button.layer.cornerRadius = 10
////        contentView.addSubview(button)
////        NSLayoutConstraint.activate([
////            button.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
////            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
////            button.heightAnchor.constraint(equalToConstant: 30),
////            button.widthAnchor.constraint(equalToConstant: 100)
////        ])
//        contentView.addSubview(collectionButton)
//        collectionButton.translatesAutoresizingMaskIntoConstraints = false
//        collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
//        NSLayoutConstraint.activate([
//            collectionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            collectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
//            collectionButton.heightAnchor.constraint(equalToConstant: 30),
//            collectionButton.widthAnchor.constraint(equalToConstant: 30)
//        ])
//        collectionButton.addTarget(self, action: #selector(addCollection), for: .touchUpInside)
//    }
//    @objc func addCollection() {
//        isCollected.toggle()
//        
//        guard let currentUserID = Auth.auth().currentUser?.uid,
//              let productID = product?.productId,
//              let productName = product?.name,
//              let productImageString = product?.imageString,
//              let productPrice = product?.price else {
//            return
//        }
//        let db = Firestore.firestore()
//        let userCollectionReference = db.collection("collections").document(currentUserID)
//        if isCollected {
//            let collectedProductData: [String: Any] = [
//                "productId": productID,
//                "name": productName,
//                "imageString": productImageString,
//                "price": productPrice
//            ]
//            userCollectionReference.setData([
//                "collectedProducts": FieldValue.arrayUnion([collectedProductData])
//            ], merge: true) { error in
//                if let error = error {
//                    print("Error updating document: \(error)")
//                } else {
//                    print("Document successfully updated with new collection.")
//                }
//            }
//            collectionButton.setImage(UIImage(named: "icons9-bookmark-72(@3×)"), for: .normal)
//            addToLocalStorage(productData: collectedProductData)
//        } else {
//            let removedProductData: [String: Any] = [
//                "productId": productID
//            ]
//            
//            userCollectionReference.updateData([
//                "collectedProducts": FieldValue.arrayRemove([removedProductData])
//            ]) { error in
//                if let error = error {
//                    print("Error updating document: \(error)")
//                } else {
//                    print("Document successfully updated with removed collection.")
//                }
//            }
//            collectionButton.setImage(UIImage(named: "icons8-bookmark-72(@3×)"), for: .normal)
//            removeFromLocalStorage(productID: productID)
//        }
//        
//    }
//    func addToLocalStorage(productData: [String: Any]) {
//        var savedCollections = UserDefaults.standard.array(forKey: "SavedCollections") as? [[String: Any]] ?? []
//        savedCollections.append(productData)
//        UserDefaults.standard.set(savedCollections, forKey: "SavedCollections")
//    }
//
//    // Update local storage when removing from collection
//    func removeFromLocalStorage(productID: String) {
//        var savedCollections = UserDefaults.standard.array(forKey: "SavedCollections") as? [[String: Any]] ?? []
//        savedCollections.removeAll { $0["productId"] as? String == productID }
//        UserDefaults.standard.set(savedCollections, forKey: "SavedCollections")
//    }
//    func updateUI() {
//        if let product = product {
//            nameLabel.text = product.name
//            priceLabel.text = "$\(product.price)"
//            dateLabel.text = product.startTime.description
//            if let url = URL(string: product.imageString) {
//                imageView.kf.setImage(with: url)
//            }
//        }
//    }
//}

//class ClassCollectionViewCell: UICollectionViewCell {
//    let buttonsStackView = UIStackView()
//    let textLabel = UILabel()
//    let productClassification = ["Camping", "Tableware", "Activity props", "Party", "Electronics", "Others"]
//    var allRequests: [Product] = []
//    var allSupplies: [Product] = []
//    var currentButtonType: ProductType? {
//        didSet {
//            updateUI()
//        }
//    }
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//        updateUI()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    func setupUI() {
//        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
//        buttonsStackView.axis = .horizontal
//        buttonsStackView.alignment = .center
//        buttonsStackView.distribution = .fillProportionally
//        contentView.addSubview(buttonsStackView)
//        NSLayoutConstraint.activate([
//            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
//            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
//            //            buttonsStackView.heightAnchor.constraint(equalToConstant: 300),
//            //            buttonsStackView.widthAnchor.constraint(equalToConstant: 700)
//        ])
//    }
//    func updateUI() {
//        for subview in buttonsStackView.arrangedSubviews {
//            buttonsStackView.removeArrangedSubview(subview)
//            subview.removeFromSuperview()
//        }
//        
//        for classification in productClassification {
//            let button = UIButton()
//            
//            button.setTitle(classification, for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.addTarget(self, action: #selector(classificationButtonTapped(_:)), for: .touchUpInside)
//            buttonsStackView.addArrangedSubview(button)
//        }
//    }
//    weak var delegate: ClassCollectionViewCellDelegate?
//    @objc func classificationButtonTapped(_ sender: UIButton) {
//        if let classificationText = sender.currentTitle {
//            print("Tapped Classification: \(classificationText)")
//            if let delegate = delegate, let currentButtonType = currentButtonType {
//                delegate.didSelectClassification(classificationText, forType: currentButtonType)
//                
//            }
//        }
//    }
//}
