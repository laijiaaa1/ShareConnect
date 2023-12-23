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

class SubGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
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
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 180, height: 300)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .black
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    override func viewWillAppear(_ animated: Bool) {
        fetchRequestsForUser(type: .request)
        tabBarController?.tabBar.backgroundColor = .black
        tabBarController?.tabBar.barTintColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
    }
    override func viewDidLoad() {
        view.backgroundColor = .black
        super.viewDidLoad()
        loadSavedCollections()
        collectionView.showsVerticalScrollIndicator = false
        setupUI()
        navigationItem.title = "SHARECONNECT"
        navigationController?.navigationBar.isHidden = false
        collectionView.delegate = self
        collectionView.dataSource = self
        let userID = Auth.auth().currentUser?.uid ?? ""
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        fetchRequestsForUser(type: .request)
        fetchRequestsForUser(type: .supply)
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
        if collectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchCollectionViewCell
            if currentButtonType == .request {
                cell.product = allRequests[indexPath.item]
            } else if currentButtonType == .supply {
                cell.product = allSupplies[indexPath.item]
            }
            cell.isCollected = cell.product?.isCollected ?? false
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2
        let cellHeight = collectionView.frame.height / 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    @objc func button1Action() {
        currentButtonType = .request
        lineView.center.x = button1.center.x
        button1.setTitleColor(.white, for: .normal)
        button2.setTitleColor(.lightGray, for: .normal)
        fetchRequestsForUser(type: .request)
        collectionView.reloadData()
    }
    @objc func button2Action() {
        currentButtonType = .supply
        lineView.center.x = button2.center.x
        button1.setTitleColor(.lightGray, for: .normal)
        button2.setTitleColor(.white, for: .normal)
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
        button1.setTitle("Required", for: .normal)
        button1.setTitleColor(.white, for: .normal)
        button1.backgroundColor = .black
        button1.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        button2.setTitle("Available", for: .normal)
        button2.setTitleColor(.white, for: .normal)
        button2.backgroundColor = .black
        button2.addTarget(self, action: #selector(button2Action), for: .touchUpInside)
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        lineView.backgroundColor = .white
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.center.x = button1.center.x
        view.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineView.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            lineView.heightAnchor.constraint(equalToConstant: 2)
        ])
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 600, height: 40)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        view.addSubview(collectionView)
        collectionView.backgroundColor = .black
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: lineView.bottomAnchor),
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
                       let product = FirestoreService.shared.parseProductData(productData: productData){
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
}
