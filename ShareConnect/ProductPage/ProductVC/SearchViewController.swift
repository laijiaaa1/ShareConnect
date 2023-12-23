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

protocol ClassCollectionViewCellDelegate: AnyObject {
    func didSelectClassification(_ classification: String, forType type: ProductType)
}
class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ClassCollectionViewCellDelegate {
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
    var lineViewLeadingConstraint: NSLayoutConstraint!
    let classCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ClassCollectionViewCell.self, forCellWithReuseIdentifier: "classCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.tintColor = .white
        return collectionView
    }()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 180, height: 300)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    func fetchData() {
        if usification == "product" {
            fetchRequestsForUser(type: currentButtonType, usification: "product")
        } else if usification == "place" {
            fetchRequestsForUser(type: currentButtonType, usification: "place")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black
        fetchData()
    }
    override func viewDidLoad() {
        view.backgroundColor = .black
        super.viewDidLoad()
        loadSavedCollections()
        collectionView.showsVerticalScrollIndicator = false
        setupUI()
        navigationItem.title = "SHARECONNECT"
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
        if usification == "product" {
            if currentButtonType == .request {
                fetchRequestsForUser(type: .request, usification: "product")
            } else if currentButtonType == .supply {
                fetchRequestsForUser(type: .supply, usification: "product")
            }
        } else if usification == "place"{
            if currentButtonType == .request {
                fetchRequestsForUser(type: .request, usification: "place")
            } else if currentButtonType == .supply {
                fetchRequestsForUser(type: .supply, usification: "place")
            }
        }
        collectionView.reloadData()
        classCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if collectionView == classCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ClassCollectionViewCell
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
                } else if currentButtonType == .supply {
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
            if usification == "product" {
                if currentButtonType == .request {
                    return allRequests.count
                } else if currentButtonType == .supply {
                    return allSupplies.count
                }
                return 0
            } else if
                usification == "place"{
                if currentButtonType == .request {
                    return allRequests.count
                } else if currentButtonType == .supply {
                    return allSupplies.count
                }
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == classCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classCell", for: indexPath) as! ClassCollectionViewCell
            cell.currentButtonType = currentButtonType
            cell.delegate = self
            return cell
        }
        if collectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
            if usification == "product" {
                if currentButtonType == .request, allRequests.count > indexPath.item {
                    cell.product = allRequests[indexPath.item]
                } else if currentButtonType == .supply, allSupplies.count > indexPath.item  {
                    cell.product = allSupplies[indexPath.item]
                }
            } else if usification == "place" {
                if currentButtonType == .request, allRequests.count > indexPath.item {
                    cell.product = allRequests[indexPath.item]
                } else if currentButtonType == .supply, allSupplies.count > indexPath.item {
                    cell.product = allSupplies[indexPath.item]
                }
            }
            cell.isCollected = cell.product?.isCollected ?? false
            return cell
        }
        return UICollectionViewCell()
    }
    func didSelectClassification(_ classification: String, forType type: ProductType) {
        if usification == "product" {
            fetchDataForSort(classification: classification, type: type, usification: "product")
        } else if usification == "place" {
            fetchDataForSort(classification: classification, type: type, usification: "place")
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2
        let cellHeight = collectionView.frame.height / 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    @objc func button1Action() {
        currentButtonType = .request
          let position = stackView.frame.origin.x
          self.lineViewLeadingConstraint.constant = position
          UIView.animate(withDuration: 0.3) {
              self.view.layoutIfNeeded()
          }
        button1.setTitleColor(.white, for: .normal)
        button2.setTitleColor(.lightGray, for: .normal)
        if usification == "product" {
            fetchRequestsForUser(type: .request, usification: "product")
        } else {
            fetchRequestsForUser(type: .request, usification: "place")
        }
    }
    @objc func button2Action() {
        currentButtonType = .supply
           let position = stackView.frame.origin.x + stackView.frame.width / 2
           self.lineViewLeadingConstraint.constant = position
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
        button1.setTitleColor(.lightGray, for: .normal)
        button2.setTitleColor(.white, for: .normal)
        if usification == "place" {
            fetchRequestsForUser(type: .supply, usification: "place")
        } else {
            fetchRequestsForUser(type: .supply, usification: "product")
        }
    }
    func setupUI() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.backgroundColor = .black
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        button1.setTitle("Required", for: .normal)
        button1.startAnimatingPressActions()
        button1.setTitleColor(.white, for: .normal)
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        button2.setTitle("Available", for: .normal)
        button2.startAnimatingPressActions()
        button2.setTitleColor(.white, for: .normal)
        button2.addTarget(self, action: #selector(button2Action), for: .touchUpInside)
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        lineView.backgroundColor = .white
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 2),
            lineView.widthAnchor.constraint(equalToConstant: view.frame.width / 2)
        ])
        lineViewLeadingConstraint = lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        lineViewLeadingConstraint.isActive = true
        classCollectionView.backgroundColor = .black
        classCollectionView.tintColor = .white
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
        collectionView.backgroundColor = .black
        collectionView.tintColor = .white
        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: classCollectionView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        scrollView.contentSize = CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
    func fetchDataForSort(classification: String, type: ProductType, usification: String) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products").whereField("product.Use", isEqualTo: usification)
        productsCollection.getDocuments { (querySnapshot, error) in
            if self.currentButtonType == .request {
                self.allRequests.removeAll()
            } else if self.currentButtonType == .supply {
                self.allSupplies.removeAll()
            }
            let dispatchGroup = DispatchGroup()
            for document in querySnapshot!.documents {
                let productData = document.data()
                if let productTypeRawValue = productData["type"] as? String,
                   let productType = ProductType(rawValue: productTypeRawValue),
                   let product = FirestoreService.shared.parseProductData(productData: productData) {
                    dispatchGroup.enter()
                    self.isSellerBlocked(product.seller.sellerID) { isBlocked in
                        if !isBlocked && productType.rawValue == "request" && product.itemType == productType && product.sort == classification {
                            self.allRequests.append(product)
                        } else if productType.rawValue == "supply" && product.itemType == productType && product.sort == classification {
                            self.allSupplies.append(product)
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    print("Error parsing product type")
                }
            }
            dispatchGroup.notify(queue: .main) {
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
    func fetchRequestsForUser(type: ProductType, usification: String) {
        let db = Firestore.firestore()
        let productsCollection = db.collection("products").whereField("product.Use", isEqualTo: usification)
        productsCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if self.currentButtonType == .request {
                    self.allRequests.removeAll()
                } else if self.currentButtonType == .supply {
                    self.allSupplies.removeAll()
                }
                let dispatchGroup = DispatchGroup()
                var uniqueProductID = Set<String>()
                for document in querySnapshot!.documents {
                    let productData = document.data()
                    if let product = FirestoreService.shared.parseProductData(productData: productData){
                        dispatchGroup.enter()
                        self.isSellerBlocked(product.seller.sellerID) { isBlocked in
                            if !isBlocked && product.itemType == type && uniqueProductID.insert(product.productId).inserted{
                                if type == .request {
                                    self.allRequests.append(product)
                                } else if type == .supply {
                                    self.allSupplies.append(product)
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
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
    }
    func isSellerBlocked(_ sellerID: String, completion: @escaping (Bool) -> Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let blockedUsersCollection = Firestore.firestore().collection("blockedUsers")
            blockedUsersCollection.document(currentUserID).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    if let isBlocked = data?[sellerID] as? Bool, isBlocked {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
}
