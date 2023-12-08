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
        let textAttributes = [NSAttributedString.Key.font:UIFont(name: "GeezaPro-Bold", size: 20)]
        view.backgroundColor = CustomColors.B1
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
        textFieldShouldReturn(searchTextField)
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
        searchTextField.frame = CGRect(x: 30, y: 100, width: 330, height: 44)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24))
        imageView.image = UIImage(named: "icons8-search-90(@3×)")
        leftView.addSubview(imageView)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let rightImageView = UIImageView(frame: CGRect(x: 10, y: 12, width: 18, height: 18))
        rightImageView.image = UIImage(named: "icons8-filter-48(@3×)")
        rightView.addSubview(rightImageView)
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .always
        searchTextField.backgroundColor = .white
        view.addSubview(searchTextField)
    }
    func groupClass() {
        let views = [productView, placeView, courseView, foodView]
        let labels = ["Product", "Place", "Course", "Food"]
        let images = ["icons8-camping-tent-72(@3×)", "icons8-room-72(@3×)", "icons8-course-72(@3×)", "icons8-pizza-five-eighths-32"]
        for i in 0..<4 {
            views[i].backgroundColor = .white
            views[i].frame = CGRect(x: 30 + 88 * i, y: 170, width: 70, height: 70)
            views[i].layer.cornerRadius = 10
            views[i].layer.masksToBounds = true
            views[i].layer.borderWidth = 1
            view.addSubview(views[i])
            let imageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 40, height: 40))
            imageView.image = UIImage(named: images[i])
            views[i].addSubview(imageView)
            let label = UILabel(frame: CGRect(x: 30 + 90 * i, y: 250, width: 70, height: 20))
            label.text = labels[i]
            label.font = UIFont(name: "GeezaPro-Bold", size: 15)
            label.textAlignment = .center
            view.addSubview(label)
            let button = UIButton(frame: CGRect(x: 30 + 88 * i, y: 170, width: 70, height: 70))
            button.tag = i
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            view.addSubview(button)
        }
        let line = UIView(frame: CGRect(x: 0, y: 280, width: view.frame.width, height: 1))
        line.backgroundColor = .lightGray
        view.addSubview(line)
    }
    func hotGroup() {
        let hotCollectionLabel = UILabel(frame: CGRect(x: 30, y: 310, width: 160, height: 20))
        hotCollectionLabel.text = "Hot Collections"
        hotCollectionLabel.font = UIFont(name: "GeezaPro-Bold", size: 18)
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
        let line2 = UIView(frame: CGRect(x: 0, y: 530, width: view.frame.width, height: 1))
        line2.backgroundColor = .lightGray
        view.addSubview(line2)
    }
    func browsHistory() {
        browsingHistory.frame = CGRect(x: 30, y: 560, width: 160, height: 20)
        browsingHistory.text = "Browsing History"
        browsingHistory.font = UIFont(name: "GeezaPro-Bold", size: 18)
        view.addSubview(browsingHistory)
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        let historyScrollView = UIScrollView(frame: CGRect(x: 30, y: 600, width: view.frame.width - 60, height: 150))
        view.addSubview(historyScrollView)
        self.browsingHistoryCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: browsingHistoryItems.count * 320, height: Int(historyScrollView.frame.height)), collectionViewLayout: layout2)
        historyScrollView.addSubview(browsingHistoryCollection)
        browsingHistoryCollection.backgroundColor = .clear
        browsingHistoryCollection.showsHorizontalScrollIndicator = false
        historyScrollView.showsHorizontalScrollIndicator = false
        let historyTotalWidth = CGFloat(browsingHistoryItems.count) * 320
        historyScrollView.contentSize = CGSize(width: historyTotalWidth, height: browsingHistoryCollection.frame.height)
    }
    func chatList() {
        chatListButton.setImage(UIImage(named: "icons8-chat-24(@1×)"), for: .normal)
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
                imageButton.setTitleColor(.black, for: .normal)
                imageButton.layer.cornerRadius = 10
                imageButton.layer.borderWidth = 1
                imageButton.titleLabel?.font = UIFont(name: "GeezaPro-Bold", size: 15)
                imageButton.tag = indexPath.row
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
            vc.productID = browsingHistoryItems[sender.tag].2
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func searchProductByName(searchString: String, completion: @escaping ([Product]) -> Void) {
        let db = Firestore.firestore()
        let groupsCollection = db.collection("products")
        let query = groupsCollection
            .whereField("product.Name", isGreaterThanOrEqualTo: searchString)
            .whereField("product.Name", isLessThan: searchString + "\u{f8ff}")
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            } else {
                var searchResults: [Product] = []
                for document in snapshot!.documents {
                    let data = document.data()
                    if let product = self.parseProductData(productData: data) {
                        searchResults.append(product)
                    }
                }
                completion(searchResults)
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
    func fetchGroupData() {
        DispatchQueue.global().async { [weak self] in
            let groupsRef = Firestore.firestore().collection("groups").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching public groups: \(error.localizedDescription)")
                } else {
                    self?.groups.removeAll()
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let group = Group(data: data, documentId: document.documentID) {
                            self?.groups.append(group)
                        }
                    }
                    self?.groups.sort(by: { $0.members.count > $1.members.count })
                    DispatchQueue.main.async {
                        self?.hotCollection.reloadData()
                    }
                }
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchString = textField.text, !searchString.isEmpty {
            searchProductByName(searchString: searchString) { [weak self] products in
                let searchResultsViewController = SearchResultsViewController()
                searchResultsViewController.searchResults = products
                self?.navigationController?.pushViewController(searchResultsViewController, animated: true)
            }
        }
        textField.resignFirstResponder()
        return true
    }
}
