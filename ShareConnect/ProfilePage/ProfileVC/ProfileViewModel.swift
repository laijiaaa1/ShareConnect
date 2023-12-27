//
//  Fetch.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/3.
//
import FirebaseFirestore
import Kingfisher
import FirebaseAuth

protocol ProfileViewModelDelegate: AnyObject {
    func viewModelDidUpdateData()
}
class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?
    var products: [Product] = []
    var groups: [Group] = []
    var collections: [Collection] = []
    var nameLabel: UILabel?
    var profileImageView: UIImageView?
    var groupTableView: UITableView?
    var collectionCollectionView: UICollectionView?
    var navigationController: UINavigationController?
    private func notifyDelegate() {
        delegate?.viewModelDidUpdateData()
    }
    func configureUIElements(nameLabel: UILabel, profileImageView: UIImageView, groupTableView: UITableView, collectionCollectionView: UICollectionView, navigationController: UINavigationController) {
        self.nameLabel = nameLabel
        self.profileImageView = profileImageView
        self.groupTableView = groupTableView
        self.collectionCollectionView = collectionCollectionView
        self.navigationController = navigationController
    }
    // Fetch User Data
    func fetchUserData(userId: String) {
        FirestoreService.shared.fetchUserData(userId: userId) { [weak self] (name, email, profileImageUrl) in
            self?.updateUI(name: name, profileImageUrl: profileImageUrl)
        }
    }
    private func updateUI(name: String, profileImageUrl: String) {
        nameLabel?.text = name
        profileImageView?.kf.setImage(with: URL(string: profileImageUrl))
    }
    // Fetch Requests
    func fetchRequests(userId: String, dataType: String) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        FirestoreService.shared.fetchRequests(userId: userId, dataType: dataType) { [weak self] products in
            self?.products = products
            self?.fetchGroupProducts(for: userId, dataType: dataType, completion: {
                self?.groupTableView?.reloadData()
            })
        }
    }
    // Fetch Group Products
    func fetchGroupProducts(for userId: String, dataType: String, completion: @escaping () -> Void) {
        FirestoreService.shared.fetchGroupProducts(userId: userId, dataType: dataType) { [weak self] products in
            self?.products += products
            completion()
        }
    }
    // Fetch Collections
    func fetchCollections(userId: String) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        FirestoreService.shared.fetchCollections(userId: userId) { [weak self] collections in
            self?.collections = collections
            self?.collectionCollectionView?.reloadData()
        }
    }
    // Fetch Groups
    func fetchGroups(userId: String) {
        FirestoreService.shared.fetchGroups(userId: userId) { [weak self] groups in
            self?.groups = groups
            self?.groupTableView?.reloadData()
        }
    }
    // Parse Collection Data
    func parseCollectionData(productData: [String: Any]) -> Collection? {
        return FirestoreService.shared.parseCollectionData(productData: productData)
    }
    // Recorder Button Tapped
    @objc func recorderButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "RecoderViewController") as? RecoderViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    var productsCount: Int {
        return products.count
    }
    var groupsCount: Int {
        return groups.count
    }
    var collectionsCount: Int {
        return collections.count
    }
    func product(at index: Int) -> Product? {
        guard index < products.count else {
            return nil
        }
        return products[index]
    }
    func group(at index: Int) -> Group? {
        guard index < groups.count else {
            return nil
        }
        return groups[index]
    }
    func collection(at index: Int) -> Collection? {
        guard index < collections.count else {
            return nil
        }
        return collections[index]
    }
}
