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
import Kingfisher

struct Collection{
    var name: String
    var imageString: String
    var productId: String
    init(name: String, imageString: String, productId: String) {
        self.name = name
        self.imageString = imageString
        self.productId = productId
    }
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let imageString = dictionary["imageString"] as? String,
              let productId = dictionary["productId"] as? String else { return nil }
        self.init(name: name, imageString: imageString, productId: productId)
    }
}
class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if selectedButton == groupButton  {
            return groups.count
       } else {
           return products.count
       }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestCell", for: indexPath) as! MyRequestCell
        if selectedButton == groupButton {
            guard indexPath.row < groups.count else {
                cell.requestNameLabel.text = "N/A"
                cell.requestDescriptionLabel.text = "N/A"
                cell.requestDateLabel.text = "N/A"
                return cell
            }
            let group = groups[indexPath.row]
            cell.requestNameLabel.text = group.name
            cell.requestDescriptionLabel.text = group.description
            cell.requestDateLabel.text = group.startTime
            let imageURL = URL(string: group.image)
            cell.requestImageView.kf.setImage(with: imageURL)
            return cell
        } else {
            guard indexPath.row < products.count else {
                cell.requestNameLabel.text = "N/A"
                cell.requestDescriptionLabel.text = "N/A"
                cell.requestDateLabel.text = "N/A"
                return cell
            }
            let product = products[indexPath.row]
            cell.requestNameLabel.text = product.name
            cell.requestDescriptionLabel.text = product.sort
            cell.requestDateLabel.text = product.startTime
            let imageURL = URL(string: product.imageString)
            cell.requestImageView.kf.setImage(with: imageURL)
            return cell
        }
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            if self.selectedButton == self.groupButton {
                let group = self.groups[indexPath.row]
                self.deleteGroupFromDatabase(group)
                self.groups.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            } else {
                let product = self.products[indexPath.row]
                self.deleteProductFromDatabase(product)
                self.products.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            }
        }
        deleteAction.image = UIImage(systemName: "trash.fill")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    func deleteProductFromDatabase(_ product: Product) {
        let db = Firestore.firestore()
        //delete document
        db.collection("products").document(product.productId).delete()
    }
    //long press to delete collection
    @objc func longPressToDeleteCollection(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: collectionCollectionView)
            guard let indexPath = collectionCollectionView.indexPathForItem(at: point) else { return }
            let collection = collections[indexPath.row]
            deleteCollectionFromDatabase(collection)
            collections.remove(at: indexPath.row)
            collectionCollectionView.deleteItems(at: [indexPath])
        }
    }
   
    func deleteGroupFromDatabase(_ group: Group) {
        let db = Firestore.firestore()
        if group.owner == userId {
            db.collection("groups").document(group.documentId).delete()
        } else {
            db.collection("groups").document(group.documentId).updateData(["member": FieldValue.arrayRemove([userId])])
        }
    }
    func deleteCollectionFromDatabase(_ collection: Collection) {
        let db = Firestore.firestore()
        db.collection("collections").document(Auth.auth().currentUser!.uid).updateData(["collectedProducts": FieldValue.arrayRemove([collection.productId])])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedButton == groupButton {
            let selectedGroup = groups[indexPath.row]
            let subGroupViewController = SubGroupViewController()
            subGroupViewController.group = selectedGroup
            navigationController?.pushViewController(subGroupViewController, animated: true)
        } else {
            let selectedProduct = products[indexPath.row]
            let detailViewController = DetailViewController()
            detailViewController.product = selectedProduct
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .lightGray
        cell.nameLabel.text = collections[indexPath.item].name
        cell.imageView.kf.setImage(with: URL(string: collections[indexPath.row].imageString))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 20) / 3
        let cellHigh = cellWidth
        return CGSize(width: cellWidth, height: cellHigh)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCollection = collections[indexPath.item]
        let detailViewController = DetailViewController()
        detailViewController.product?.productId = selectedCollection.productId
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collection = collections[indexPath.item]
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill")) { (_) in
            self.deleteCollectionFromDatabase(collection)
            self.collections.remove(at: indexPath.item)
            self.collectionCollectionView.deleteItems(at: [indexPath])
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            return UIMenu(title: "Delete", image: nil, identifier: nil, options: [], children: [deleteAction])
        }
    }
    
    var requests: [Request] = []
    var products: [Product] = []
        var groups: [Group] = []
    var collections: [Collection] = []
    var supplies: [Supply] = []
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
    var selectedCollection: Collection?
    let userId = Auth.auth().currentUser?.uid
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        fetchGroups(userId: userId ?? "")
    }
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
        groupTableView.separatorStyle = .none
        groupTableView.showsVerticalScrollIndicator = false
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
        collectionCollectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionCollectionView)
        collectionCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionCollectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            collectionCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        let layout = UICollectionViewFlowLayout()
        collectionCollectionView.collectionViewLayout = layout
        collectionCollectionView.dataSource = self
        collectionCollectionView.delegate = self
        collectionCollectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
        }
        let recoderButton = UIButton()
        view.addSubview(recoderButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(recoderButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        fetchCollections(userId: userId!)
        fetchGroups(userId: userId!)
        fetchRequests(userId: userId!, dataType: "request")
        fetchRequests(userId: userId!, dataType: "supply")
    }
    func fetchRequests(userId: String, dataType: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        let productsCollection = db.collection("products")
        var query: Query
        if dataType == "request" {
            query = productsCollection.whereField("product.seller.sellerID", isEqualTo: userId).whereField("type", isEqualTo: "request")
        } else if dataType == "supply" {
            query = productsCollection.whereField("product.seller.sellerID", isEqualTo: userId).whereField("type", isEqualTo: "supply")
        } else {
            return
        }
        
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
    func fetchCollections(userId: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        let userCollectionReference = db.collection("collections").document(userId)
        
        userCollectionReference.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let collectedProducts = document.data()?["collectedProducts"] as? [[String: Any]] {
                    let collections = collectedProducts.compactMap { productData -> Collection? in
                        return self.parseCollectionData(productData: productData)
                    }
                    self.collections = collections
                    self.collectionCollectionView.reloadData()
                }
            } else {
                print("Document does not exist or there was an error")
            }
        }
    }
    func fetchGroups(userId: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        let productsGroup = db.collection("groups").whereField("members", arrayContains: userId)
        productsGroup.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                self.groups.removeAll()

                for document in querySnapshot!.documents {
                    let data = document.data()

                    if let group = self.parseGroupData(data: data, documentId: document.documentID) {
                        self.groups.append(group)
                    }
                }
                self.groupTableView.reloadData()
            }
        }
    }
    func parseGroupData(data: [String: Any], documentId: String) -> Group? {
        guard
            let name = data["name"] as? String,
            let description = data["description"] as? String,
            let sort = data["sort"] as? String,
            let startTime = data["startTime"] as? String,
            let endTime = data["endTime"] as? String,
            let require = data["require"] as? String,
            let numberOfPeople = data["numberOfPeople"] as? Int,
            let owner = data["owner"] as? String,
            let isPublic = data["isPublic"] as? Bool,
            let members = data["members"] as? [String],
            let image = data["image"] as? String,
            let createdTimestamp = data["created"] as? Timestamp
        else {
            return nil
        }

        var group = Group(
            documentId: documentId,
            name: name,
            description: description,
            sort: sort,
            startTime: startTime,
            endTime: endTime,
            require: require,
            numberOfPeople: numberOfPeople,
            owner: owner,
            isPublic: isPublic,
            members: members,
            image: image,
            created: createdTimestamp.dateValue()
        )
        group.invitationCode = data["invitationCode"] as? String

        return group
    }

    func parseCollectionData(productData: [String: Any]) -> Collection? {
        guard
            let productId = productData["productId"] as? String,
            let name = productData["name"] as? String,
            let price = productData["price"] as? String,
            let imageString = productData["imageString"] as? String
        else {
            return nil
        }
        let collection = Collection(name: name, imageString: imageString , productId: productId)
        return collection
    }
    @objc func recoderButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RecoderViewController") as! RecoderViewController
        navigationController?.pushViewController(vc, animated: true)
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
        let description = productData["Description"] as? String ?? ""
        let sort = productData["Sort"] as? String ?? ""
        let quantity = productData["Quantity"] as? Int ?? 1
        let use = productData["Use"] as? String ?? ""
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
        fetchGroups(userId: userId ?? "")
    }
    @objc func collectionButtonTapped() {
        animateLineViewTransition(to: collectionButton)
        animateViewTransition(to: collectionCollectionView)
        fetchCollections(userId: userId ?? "")
    }
    @objc func requestButtonTapped() {
        animateLineViewTransition(to: requestButton)
        animateViewTransition(to: groupTableView)
        fetchRequests(userId: userId ?? "", dataType: "request")
    }
    @objc func supplyButtonTapped() {
        animateLineViewTransition(to: supplyButton)
        animateViewTransition(to: groupTableView)
        fetchRequests(userId: userId ?? "", dataType: "supply")
    }
    func animateLineViewTransition(to button: UIButton) {
        button.isSelected.toggle()
        if button.isSelected {
            selectedButton?.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            selectedButton = button
            UIView.animate(withDuration: 0.3) {
                self.lineView.frame.origin.x = button.frame.origin.x
            }
            //other button turn to white
            if button == groupButton {
                collectionButton.setTitleColor(.black, for: .normal)
                collectionButton.backgroundColor = .white
                requestButton.setTitleColor(.black, for: .normal)
                requestButton.backgroundColor = .white
                supplyButton.setTitleColor(.black, for: .normal)
                supplyButton.backgroundColor = .white
            }else if button == collectionButton {
                groupButton.setTitleColor(.black, for: .normal)
                groupButton.backgroundColor = .white
                requestButton.setTitleColor(.black, for: .normal)
                requestButton.backgroundColor = .white
                supplyButton.setTitleColor(.black, for: .normal)
                supplyButton.backgroundColor = .white
            }else if button == requestButton {
                groupButton.setTitleColor(.black, for: .normal)
                groupButton.backgroundColor = .white
                collectionButton.setTitleColor(.black, for: .normal)
                collectionButton.backgroundColor = .white
                supplyButton.setTitleColor(.black, for: .normal)
                supplyButton.backgroundColor = .white
            }else if button == supplyButton {
                groupButton.setTitleColor(.black, for: .normal)
                groupButton.backgroundColor = .white
                collectionButton.setTitleColor(.black, for: .normal)
                collectionButton.backgroundColor = .white
                requestButton.setTitleColor(.black, for: .normal)
                requestButton.backgroundColor = .white
            }
        }else if !button.isSelected{
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
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
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .white
        nameLabel.alpha = 0.8
        nameLabel.layer.cornerRadius = 10
        nameLabel.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
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
            requestImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            requestImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestImageView.heightAnchor.constraint(equalToConstant: 80),
            requestImageView.widthAnchor.constraint(equalToConstant: 80),
            requestNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            requestNameLabel.leadingAnchor.constraint(equalTo: requestImageView.trailingAnchor, constant: 20),
            requestDescriptionLabel.topAnchor.constraint(equalTo: requestNameLabel.bottomAnchor, constant: 10),
            requestDescriptionLabel.leadingAnchor.constraint(equalTo: requestImageView.trailingAnchor, constant: 20),
            requestDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            requestDateLabel.topAnchor.constraint(equalTo: requestDescriptionLabel.bottomAnchor, constant: 10),
            requestDateLabel.leadingAnchor.constraint(equalTo: requestImageView.trailingAnchor, constant: 20),
            requestDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        requestNameLabel.numberOfLines = 0
        requestImageView.layer.cornerRadius = 10
        requestImageView.layer.masksToBounds = true
        requestDescriptionLabel.numberOfLines = 0
        requestDateLabel.numberOfLines = 0
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
