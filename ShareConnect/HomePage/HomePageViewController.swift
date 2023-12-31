//
//  ViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/14.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Kingfisher

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let chatListButton = UIButton()
    let searchTextField = UITextField()
    let productView = UIView()
    let placeView = UIView()
    let courseView = UIView()
    let foodView = UIView()
    let hotItems = [("", "icons8-camp-64"),
                    ("", "icons8-camp-64"),
                    ("", "icons8-camp-64"),
                    ("", "icons8-camp-64"),
                    ("", "icons8-camp-64")]
    var groups: [Group] = []
    let browsingHistory = UILabel()
    var browsingHistoryItems = [
        ("", "icons8-camp-64", ""),
        ("", "icons8-camp-64", ""),
        ("", "icons8-camp-64", ""),
        ("", "icons8-camp-64", ""),
        ("", "icons8-camp-64", "")]
    let hotCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 150), collectionViewLayout: UICollectionViewFlowLayout())
    var browsingHistoryCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 800, height: 150), collectionViewLayout: UICollectionViewFlowLayout())
    let db = Firestore.firestore()
    var searchResults: [Product] = []
    var searchSupply: [Product] = []
    var searchTimer: Timer?
    override func viewWillAppear(_ animated: Bool) {
        browsingHistoryCollection.reloadData()
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        browsingHistoryCollection.reloadData()
        view.backgroundColor = .black
        let backPicture = UIImageView()
        backPicture.image = UIImage(named: "9")
        backPicture.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(backPicture)
        view.sendSubviewToBack(backPicture)
        searchProduct()
        groupClass()
        hotGroup()
        browsHistory()
        listenForBrowsingHistory()
        chatList()
        browsingHistoryCollection.register(HistoryCell.self, forCellWithReuseIdentifier: "cell")
        hotCollection.delegate = self
        hotCollection.dataSource = self
        browsingHistoryCollection.delegate = self
        browsingHistoryCollection.dataSource = self
        searchTextField.delegate = self
        fetchGroupData()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func chatListButtonClick() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as? ChatListViewController ?? ChatListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func searchProduct() {
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 22
        searchTextField.layer.masksToBounds = true
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24))
        imageView.image = UIImage(named: "icons8-search-90(@3×)")
        leftView.addSubview(imageView)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        searchTextField.backgroundColor = .white
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(searchTextField)
            NSLayoutConstraint.activate([
                searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
                searchTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    func groupClass() {
        let labels = ["Product", "Place", "Course", "Food"]
        let images = ["icons8-camping-tent-72(@3×)", "icons8-room-72(@3×)", "icons8-course-72(@3×)", "icons8-pizza-five-eighths-32"]
        for i in 0..<4 {
            let containerView = UIView()
            containerView.backgroundColor = .white
            containerView.layer.cornerRadius = 10
            containerView.layer.masksToBounds = true
            containerView.layer.borderWidth = 1
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.widthAnchor.constraint(equalToConstant: 70),
                containerView.heightAnchor.constraint(equalToConstant: 70),
                containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 170),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30 + CGFloat(88 * i))
            ])
            let imageView = UIImageView()
            imageView.image = UIImage(named: images[i])
            imageView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            let label = UILabel()
            label.text = labels[i]
            label.font = UIFont(name: "GeezaPro-Bold", size: 15)
            label.textAlignment = .center
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 70),
                label.heightAnchor.constraint(equalToConstant: 20),
                label.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30 + CGFloat(88 * i))
            ])
            let button = UIButton()
            button.tag = i
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 70),
                button.heightAnchor.constraint(equalToConstant: 70),
                button.topAnchor.constraint(equalTo: view.topAnchor, constant: 170),
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30 + CGFloat(88 * i))
            ])
        }
    }
    func hotGroup() {
        let hotCollectionLabel = UILabel(frame: CGRect(x: 30, y: 310, width: 160, height: 20))
        hotCollectionLabel.text = "Hot Collections"
        hotCollectionLabel.font = UIFont(name: "GeezaPro-Bold", size: 18)
        hotCollectionLabel.textColor = .white
        view.addSubview(hotCollectionLabel)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let hotScrollView = UIScrollView(frame: CGRect(x: 30, y: 350, width: view.frame.width - 60, height: 150))
        view.addSubview(hotScrollView)
        hotScrollView.addSubview(hotCollection)
        let totalWidth = CGFloat(hotItems.count) * 160
        hotScrollView.contentSize = CGSize(width: totalWidth, height: hotCollection.frame.height)
        hotCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        hotCollection.backgroundColor = .clear
        hotScrollView.showsHorizontalScrollIndicator = false
        hotCollection.showsHorizontalScrollIndicator = false
    }
    func browsHistory() {
        browsingHistory.frame = CGRect(x: 30, y: 560, width: 160, height: 20)
        browsingHistory.text = "Browsing History"
        browsingHistory.textColor = .white
        browsingHistory.font = UIFont(name: "GeezaPro-Bold", size: 18)
        view.addSubview(browsingHistory)
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        let historyScrollView = UIScrollView(frame: CGRect(x: 30, y: 600, width: view.frame.width - 60, height: 150))
        view.addSubview(historyScrollView)
        self.browsingHistoryCollection = UICollectionView(frame: CGRect(x: 0,
                                                                        y: 0,
                                                                        width: browsingHistoryItems.count * 320,
                                                                        height: Int(historyScrollView.frame.height)),
                                                          collectionViewLayout: layout2)
        historyScrollView.addSubview(browsingHistoryCollection)
        browsingHistoryCollection.backgroundColor = .clear
        browsingHistoryCollection.showsHorizontalScrollIndicator = false
        historyScrollView.showsHorizontalScrollIndicator = false
        let historyTotalWidth = CGFloat(browsingHistoryItems.count) * 320
        historyScrollView.contentSize = CGSize(width: historyTotalWidth, height: browsingHistoryCollection.frame.height)
    }
    func chatList() {
        chatListButton.setImage(UIImage(named: "icons8-message-24(@1×)"), for: .normal)
        chatListButton.frame.size = CGSize(width: 30, height: 30)
        chatListButton.startAnimatingPressActions()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chatListButton)
        chatListButton.addTarget(self, action: #selector(chatListButtonClick), for: .touchUpInside)
        view.addSubview(chatListButton)
    }
    func listenForBrowsingHistory() {
        FirestoreService.shared.listenForBrowsingHistoryChanges { [weak self] browsingRecords in
            DispatchQueue.global().async {
                self?.browsingHistoryItems = browsingRecords.map { ($0.name, $0.image, $0.productId) }
                DispatchQueue.main.async {
                    self?.browsingHistoryCollection.reloadData()
                }
            }
        }
    }
    @objc func buttonClick(sender: UIButton) {
        let groupViewController = GroupViewController()
        sender.startAnimatingPressActions()
        switch sender.tag {
        case 0:
            groupViewController.sort = "product"
        case 1:
            groupViewController.sort = "place"
        case 2:
            groupViewController.sort = "course"
        case 3:
            groupViewController.sort = "food"
        default:
            groupViewController.sort = ""
        }
        navigationController?.pushViewController(groupViewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hotCollection {
            return groups.count
        } else if collectionView == browsingHistoryCollection {
            return browsingHistoryItems.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1
        if collectionView == hotCollection {
            if indexPath.row < groups.count {
                let xpoint = CGFloat(indexPath.item) * 160
                cell.frame = CGRect(x: xpoint, y: 0, width: 150, height: 150)
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
                imageView.contentMode = .scaleToFill
                imageView.kf.setImage(with: URL(string: groups[indexPath.row].image))
                cell.addSubview(imageView)
                let label = UILabel(frame: CGRect(x: 0, y: 100, width: 150, height: 30))
                label.text = groups[indexPath.row].name
                label.font = UIFont(name: "GeezaPro-Bold", size: 15)
                label.textColor = .black
                label.backgroundColor = .white
                label.alpha = 0.5
                label.layer.cornerRadius = 10
                label.layer.masksToBounds = true
                label.textAlignment = .center
                cell.addSubview(label)
                let imageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
                imageButton.tag = indexPath.row
                imageButton.addTarget(self, action: #selector(imageButtonClick), for: .touchUpInside)
                cell.addSubview(imageButton)
                return cell
            }
        } else {
            if indexPath.row < browsingHistoryItems.count {
                let browsingRecord = browsingHistoryItems[indexPath.row]
                let xpoint = CGFloat(indexPath.item) * 320
                cell.frame = CGRect(x: xpoint, y: 0, width: 150, height: 150)
                let view = UIView()
                let viewPoint = CGFloat(indexPath.item) * 320
                view.frame = CGRect(x: 20+viewPoint, y: 28, width: 100, height: 100)
                view.layer.cornerRadius = 10
                view.layer.borderWidth = 1
                collectionView.addSubview(view)
                let historyXpoint = CGFloat(indexPath.item) * 320
                cell.frame = CGRect(x: historyXpoint, y: 0, width: 310, height: 150)
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                imageView.layer.cornerRadius = 10
                imageView.layer.borderWidth = 1
                imageView.layer.masksToBounds = true
                imageView.kf.setImage(with: URL(string: browsingRecord.1))
                view.addSubview(imageView)
                let label = UILabel(frame: CGRect(x: 100, y: 50, width: 150, height: 20))
                label.text = browsingRecord.0
                label.font = UIFont(name: "GeezaPro-Bold", size: 15)
                label.textAlignment = .center
                label.backgroundColor = .white
                cell.addSubview(label)
                let imageButton = UIButton(frame: CGRect(x: 230, y: 80, width: 60, height: 30))
                imageButton.setTitle("Detail", for: .normal)
                imageButton.setTitleColor(.white, for: .normal)
                imageButton.layer.cornerRadius = 10
                imageButton.backgroundColor = UIColor(named: "G3")
                imageButton.titleLabel?.font = UIFont(name: "GeezaPro-Bold", size: 15)
                imageButton.tag = indexPath.row
                imageButton.startAnimatingPressActions()
                imageButton.addTarget(self, action: #selector(imageButtonClick), for: .touchUpInside)
                cell.addSubview(imageButton)
                return cell
            }
        }
        return cell
    }
    @objc func imageButtonClick(sender: UIButton) {
        if sender.superview?.superview == hotCollection {
            let vc = SubGroupViewController()
            vc.group = groups[sender.tag]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            let provideVC = storyboard.instantiateViewController(withIdentifier: "ProvideViewController") as! ProvideViewController
            let productID = browsingHistoryItems[sender.tag].2
            fetchProductDetails(for: productID) { product in
                vc.product = product
                provideVC.product = product
                if product?.itemType == .request {
                    self.navigationController?.pushViewController(provideVC, animated: true)
                } else if product?.itemType == .supply {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    func fetchProductDetails(for productID: String, completion: @escaping (Product?) -> Void) {
        FirestoreService.shared.getProductDetails(productID: productID) { product in
            completion(product)
        }
    }
    func searchProductByName(searchString: String, completion: @escaping (_ searchResults: [Product], _ searchSupply: [Product]) -> Void) {
        let groupsCollection = db.collection("products")
        let query = groupsCollection
            .whereField("product.Name", isGreaterThanOrEqualTo: searchString)
            .whereField("product.Name", isLessThan: searchString + "\u{f8ff}")
        query.getDocuments { [self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([], [])
                return
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    if let product = FirestoreService.shared.parseProductData(productData: data){
                        if product.itemType == .request {
                            searchResults.append(product)
                        } else if product.itemType == .supply {
                            searchSupply.append(product)
                        }
                    }
                }
                completion(searchResults, searchSupply)
            }
        }
    }
    func fetchGroupData() {
        Firestore.firestore().collection("groups").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching public groups: \(error.localizedDescription)")
                return
            }
            // 將document轉換為Group物件，並存入groups陣列中，compactMap篩選掉nil
            self.groups = querySnapshot?.documents.compactMap { document in
                let data = document.data()
                return Group(data: data, documentId: document.documentID)
            } ?? []
            self.groups.sort { $0.members.count > $1.members.count }
            DispatchQueue.main.async {
                self.hotCollection.reloadData()
            }
        }
    }
}
class HistoryCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension HomePageViewController: UITextFieldDelegate {
    // 點擊鍵盤上的Return鍵時，將觸發 textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchString = textField.text, !searchString.isEmpty {
            searchProductByName(searchString: searchString) { [weak self] searchResults, searchSupply in
                let searchResultsViewController = SearchResultsViewController()
                searchResultsViewController.searchResults = searchResults
                searchResultsViewController.searchSupply = searchSupply
                self?.navigationController?.pushViewController(searchResultsViewController, animated: true)
            }
        }
        // 調用resignFirstResponder，鍵盤關閉
        textField.resignFirstResponder()
        return true
    }
}
