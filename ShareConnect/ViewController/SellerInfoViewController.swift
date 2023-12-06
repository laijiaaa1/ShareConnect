//
//  SellerInfo.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/25.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class SellerInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let commendTitleLabel = UILabel()
    var sellerID: String?
    var sellerRating = UILabel()
    let productTitleLabel = UILabel()
    var sellerProduct = UILabel()
    let sellerProductImage = UIImageView()
    let commendTableView = UITableView()
    var commendList: [Reviews] = []
    var commend: Reviews?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SELLER INFO"
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = CustomColors.B1
        view.addSubview(commendTableView)
        view.addSubview(commendTitleLabel)
        view.addSubview(productTitleLabel)
        commendTableView.backgroundColor = CustomColors.B1
        commendTableView.separatorStyle = .none
        commendTitleLabel.text = "ALL REVIEWS"
        commendTitleLabel.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        commendTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        commendTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commendTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            commendTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commendTitleLabel.heightAnchor.constraint(equalToConstant: 60),
            commendTableView.topAnchor.constraint(equalTo: commendTitleLabel.bottomAnchor, constant: 10),
            commendTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commendTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            commendTableView.heightAnchor.constraint(equalToConstant: 600)
        ])
        commendTableView.delegate = self
        commendTableView.dataSource = self
        commendTableView.register(CommendTableViewCell.self, forCellReuseIdentifier: "CommendTableViewCell")
        fetchReview()
    }
    func fetchReview() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let reviewsCollection = Firestore.firestore().collection("reviews")
        reviewsCollection.whereField("sellerID", isEqualTo: sellerID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching reviews: \(error.localizedDescription)")
                return
            }
            self.commendList = querySnapshot?.documents.compactMap { document in
                return Reviews(document: document)
            } ?? []
            DispatchQueue.main.async {
                self.commendTableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commendList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commendTableView.dequeueReusableCell(withIdentifier: "CommendTableViewCell", for: indexPath) as! CommendTableViewCell
        let commend = commendList[indexPath.row]
        cell.backgroundColor = CustomColors.B1
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 1
        cell.commendName.text = commend.comment
        cell.commendRating.text = String(commend.rating)
        cell.commendProduct.text = commend.productID
        cell.commendProductImage.kf.setImage(with: URL(string: commend.image))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
