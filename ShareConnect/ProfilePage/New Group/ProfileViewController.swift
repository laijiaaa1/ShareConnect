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
import FirebaseDatabase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate & UINavigationControllerDelegate, ProfileViewModelDelegate {
    var requests: [Request] = []
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
    var userId = Auth.auth().currentUser?.uid
    let profileImageView = UIImageView()
    let settingProfileButton = UIButton()
    var viewModel: ProfileViewModel = ProfileViewModel()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.fetchGroups(userId: userId ?? "")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.configureUIElements(nameLabel: nameLabel,
                                      profileImageView: profileImageView,
                                      groupTableView: groupTableView,
                                      collectionCollectionView: collectionCollectionView,
                                      navigationController: navigationController ?? UINavigationController())
        view.backgroundColor = .black
        tabBarController?.tabBar.backgroundColor = .black
        let backPicture = UIImageView()
        backPicture.image = UIImage(named: "4")
        backPicture.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(backPicture)
        view.sendSubviewToBack(backPicture)
        view.addSubview(profileImageView)
        collectionCollectionView.backgroundColor = .black
        requestTableView.backgroundColor = .black
        supplyTableView.backgroundColor = .black
        groupTableView.backgroundColor = .black
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        // change profile image
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImageView.isUserInteractionEnabled = true
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.textColor = .white
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
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
        requestButton.setTitle("Demand", for: .normal)
        supplyButton.setTitle("Supply", for: .normal)
        let buttons = [groupButton, collectionButton, requestButton, supplyButton]
        buttons.forEach { (button) in
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
            button.startAnimatingPressActions()
        }
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
            groupTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            groupTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
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
        let recoderButton = UIButton()
        view.addSubview(recoderButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(recoderButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .white
        viewModel.fetchUserData(userId: userId!)
        viewModel.fetchGroups(userId: userId!)
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
    @objc func recoderButtonTapped() {
        viewModel.recorderButtonTapped()
    }
    @objc func handleSelectProfileImageView() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func viewModelDidUpdateData() {
        groupTableView.reloadData()
        collectionCollectionView.reloadData()
       }
    // select the image and upload to profileImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFormPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFormPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFormPicker = originalImage
        }
        if let selectedImage = selectedImageFormPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func uploadFirebase() {
        guard let image = profileImageView.image else { return }
        guard image.jpegData(compressionQuality: 0.3) != nil else { return }
        RegistrationManager.shared.uploadProfileImage(image) { imageUrl in
            let values = ["profileImageUrl": imageUrl]
            if let userId = self.userId {
                Database.database().reference().child("users").child(userId).updateChildValues(values) { (error, ref) in
                    if let error = error {
                        print("Failed to save user info into db:", error)
                        return
                    }
                    print("Successfully saved user info to db")
                }
            } else {
                print("User ID is nil.")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedButton == groupButton {
            return viewModel.groupsCount
        } else {
            return viewModel.productsCount
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestCell", for: indexPath) as! MyRequestCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 10
        cell.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderWidth = 10
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.backgroundColor = .black
        if selectedButton == groupButton {
            guard indexPath.row < viewModel.groupsCount else {
                cell.requestNameLabel.text = "N/A"
                cell.requestDescriptionLabel.text = "N/A"
                cell.requestDateLabel.text = "N/A"
                return cell
            }
            let group = viewModel.group(at: indexPath.row)
            cell.requestNameLabel.text = group?.name
            cell.requestDescriptionLabel.text = group?.description
            cell.requestDateLabel.text = group?.startTime
            let imageURL = URL(string: group?.image ?? "")
            cell.requestImageView.kf.setImage(with: imageURL)
            return cell
        } else {
            guard indexPath.row < viewModel.productsCount else {
                cell.requestNameLabel.text = "N/A"
                cell.requestDescriptionLabel.text = "N/A"
                cell.requestDateLabel.text = "N/A"
                return cell
            }
            let product = viewModel.product(at: indexPath.row)
            cell.requestNameLabel.text = product?.name
            cell.requestDescriptionLabel.text = product?.sort
            cell.requestDateLabel.text = product?.startTime
            let imageURL = URL(string: product?.imageString ?? "")
            cell.requestImageView.kf.setImage(with: imageURL)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            if self.selectedButton == self.groupButton {
                let group = self.viewModel.group(at: indexPath.row)
                self.deleteGroupFromDatabase(group!)
                self.viewModel.groups.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            } else {
                let product =  self.viewModel.product(at: indexPath.row)
                self.deleteProductFromDatabase(product!)
                self.viewModel.products.remove(at: indexPath.row)
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
        db.collection("products").whereField("product.productId", isEqualTo: product.productId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    db.collection("products").document(document.documentID).delete()
                }
            }
        }
    }
    @objc func longPressToDeleteCollection(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: collectionCollectionView)
            guard let indexPath = collectionCollectionView.indexPathForItem(at: point) else { return }
            let collection = viewModel.collection(at: indexPath.row)!
            deleteCollectionFromDatabase(collection)
            viewModel.collections.remove(at: indexPath.row)
            collectionCollectionView.deleteItems(at: [indexPath])
        }
    }
    func deleteGroupFromDatabase(_ group: Group) {
        let db = Firestore.firestore()
        if group.owner == userId {
            db.collection("groups").document(group.documentId).delete()
            db.collection("users").document(userId ?? "").updateData(["groups": FieldValue.arrayRemove([group.documentId])])
            viewModel.fetchGroups(userId: userId ?? "")
        } else {
            db.collection("groups").document(group.documentId).updateData(["members": FieldValue.arrayRemove([userId as Any])])
            db.collection("users").document(userId ?? "").updateData(["groups": FieldValue.arrayRemove([group.documentId])])
            viewModel.fetchGroups(userId: userId ?? "")
        }
    }
    func deleteCollectionFromDatabase(_ collection: Collection) {
        let db = Firestore.firestore()

        db.collection("collections").document(userId ?? "").updateData([
            "collectedProducts": FieldValue.arrayRemove([collection.productId])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedButton == groupButton {
            let selectedGroup = viewModel.group(at: indexPath.row)
            let subGroupViewController = SubGroupViewController()
            subGroupViewController.group = selectedGroup
            navigationController?.pushViewController(subGroupViewController, animated: true)
        } else {
                let selectedProduct = viewModel.product(at: indexPath.row)
            if selectedProduct?.itemType == .request {
                let provideViewController = ProvideViewController()
                provideViewController.product = selectedProduct
                navigationController?.pushViewController(provideViewController, animated: true)
            } else {
                let detailViewController = DetailViewController()
                detailViewController.product = selectedProduct
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.collectionsCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.backgroundColor = .black
        cell.nameLabel.text = viewModel.collection(at: indexPath.row)?.name
        cell.imageView.kf.setImage(with: URL(string: viewModel.collection(at: indexPath.row)?.imageString ?? ""))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 20) / 3
        let cellHigh = cellWidth
        return CGSize(width: cellWidth, height: cellHigh)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCollection = viewModel.collection(at: indexPath.row)
        let detailViewController = DetailViewController()
        let products = viewModel.products
        let product = products.first(where: { $0.productId == selectedCollection?.productId })
        detailViewController.product = product
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let collection = viewModel.collection(at: indexPath.row)!
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill")) { (_) in
            self.deleteCollectionFromDatabase(collection)
            self.viewModel.collections.remove(at: indexPath.row)
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
        viewModel.fetchGroups(userId: userId ?? "")
    }
    @objc func collectionButtonTapped() {
        animateLineViewTransition(to: collectionButton)
        animateViewTransition(to: collectionCollectionView)
        viewModel.fetchCollections(userId: userId ?? "")
    }
    @objc func requestButtonTapped() {
        animateLineViewTransition(to: requestButton)
        animateViewTransition(to: groupTableView)
        viewModel.fetchRequests(userId: userId ?? "", dataType: "request")
    }
    @objc func supplyButtonTapped() {
        animateLineViewTransition(to: supplyButton)
        animateViewTransition(to: groupTableView)
        viewModel.fetchRequests(userId: userId ?? "", dataType: "supply")
    }
    func animateLineViewTransition(to button: UIButton) {
        button.isSelected.toggle()
        if button.isSelected {
            selectedButton?.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(named: "G3")
            selectedButton = button
            UIView.animate(withDuration: 0) {
                self.lineView.frame.origin.x = button.frame.origin.x
            }
            if button == groupButton {
                collectionButton.setTitleColor(.black, for: .normal)
                collectionButton.backgroundColor = .white
                requestButton.setTitleColor(.black, for: .normal)
                requestButton.backgroundColor = .white
                supplyButton.setTitleColor(.black, for: .normal)
                supplyButton.backgroundColor = .white
            } else if button == collectionButton {
                groupButton.setTitleColor(.black, for: .normal)
                groupButton.backgroundColor = .white
                requestButton.setTitleColor(.black, for: .normal)
                requestButton.backgroundColor = .white
                supplyButton.setTitleColor(.black, for: .normal)
                supplyButton.backgroundColor = .white
            } else if button == requestButton {
                groupButton.setTitleColor(.black, for: .normal)
                groupButton.backgroundColor = .white
                collectionButton.setTitleColor(.black, for: .normal)
                collectionButton.backgroundColor = .white
                supplyButton.setTitleColor(.black, for: .normal)
                supplyButton.backgroundColor = .white
            } else if button == supplyButton {
                groupButton.setTitleColor(.black, for: .normal)
                groupButton.backgroundColor = .white
                collectionButton.setTitleColor(.black, for: .normal)
                collectionButton.backgroundColor = .white
                requestButton.setTitleColor(.black, for: .normal)
                requestButton.backgroundColor = .white
            }
        }
    }
    func animateViewTransition(to newView: UIView) {
        UIView.animate(withDuration: 0.2) {
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
