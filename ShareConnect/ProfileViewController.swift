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

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    let profileImageView = UIImageView()
    let settingProfileButton = UIButton()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        fetchGroups(userId: userId ?? "")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColors.B1
        tabBarController?.tabBar.backgroundColor = CustomColors.B1
        view.addSubview(profileImageView)
        collectionCollectionView.backgroundColor = CustomColors.B1
        requestTableView.backgroundColor = CustomColors.B1
        supplyTableView.backgroundColor = CustomColors.B1
        groupTableView.backgroundColor = CustomColors.B1
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Luna"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -10),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
        let labels = [groupButton, collectionButton, requestButton, supplyButton]
        labels.forEach { (label) in
            label.backgroundColor = .white
            label.titleLabel?.font = UIFont.systemFont(ofSize: 16)
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
        view.addSubview(lineView)
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
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
        fetchUserData(userId: userId!)
        fetchCollections(userId: userId!)
        fetchGroups(userId: userId!)
        fetchRequests(userId: userId!, dataType: "request")
        fetchRequests(userId: userId!, dataType: "supply")
        view.addSubview(settingProfileButton)
        settingProfileButton.translatesAutoresizingMaskIntoConstraints = false
        settingProfileButton.setImage(UIImage(named: "icons8-setting-96(@3×)"), for: .normal)
        settingProfileButton.tintColor = .black
        settingProfileButton.addTarget(self, action: #selector(settingProfileButtonTapped), for: .touchUpInside)
        settingProfileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingProfileButton.widthAnchor.constraint(equalToConstant: 30),
            settingProfileButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingProfileButton)
    }
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
        db.collection("products").document(product.productId).delete()
    }
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
    
    @objc func settingProfileButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingProfileVC = storyboard.instantiateViewController(withIdentifier: "SettingProfileViewController") as! SettingProfileViewController
        navigationController?.pushViewController(settingProfileVC, animated: true)
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
