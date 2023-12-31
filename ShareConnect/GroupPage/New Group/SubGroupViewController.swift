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
    var lineViewLeadingConstraint: NSLayoutConstraint!
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
        let position = stackView.frame.origin.x
        self.lineViewLeadingConstraint.constant = position
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        button1.setTitleColor(.white, for: .normal)
        button2.setTitleColor(.lightGray, for: .normal)
        fetchRequestsForUser(type: .request)
        collectionView.reloadData()
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
        if type == .request {
            ProductManager.shared.fetchProductsForGroup(type: .request, groupId: group?.documentId) { products in
                self.allRequests = products
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        } else if type == .supply {
            ProductManager.shared.fetchProductsForGroup(type: .supply, groupId: group?.documentId) { products in
                self.allSupplies = products
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}
