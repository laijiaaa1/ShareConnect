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

struct Reviews {
    let comment: String
    let userID: String
    let sellerID: String
    let image: String
    let productID: String
    let rating: Int
    let timestamp: Date
    
    init?(comment: String, userID: String, sellerID: String, image: String, productID: String, rating: Int, timestamp: Date) {
        self.comment = comment
        self.userID = userID
        self.sellerID = sellerID
        self.image = image
        self.productID = productID
        self.rating = rating
        self.timestamp = timestamp
    }
    init?(document: QueryDocumentSnapshot) {
        guard let data = document.data() as? [String: Any],
              let comment = data["comment"] as? String,
              let userID = data["userID"] as? String,
              let sellerID = data["sellerID"] as? String,
              let image = data["image"] as? String,
              let timestamp = data["timestamp"] as? Timestamp,
              let productID = data["productID"] as? String,
              let rating = data["rating"] as? Int
        else {
            return nil
        }
        
        self.init(comment: comment,
                  userID: userID,
                  sellerID: sellerID,
                  image: image,
                  productID: productID,
                  rating: rating,
                  timestamp: timestamp.dateValue())
    }
}

class SellerInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
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
            commendTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commendTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commendTableView.heightAnchor.constraint(equalToConstant: 600),
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
class CommendTableViewCell: UITableViewCell {
    var commendName = UILabel()
    var commendRating = UILabel()
    let commendRatingStar = UIImageView()
    var commendProduct = UILabel()
    let commendProductImage = UIImageView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(commendName)
        commendName.text = "Name"
        commendName.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        commendName.textColor = .black
        commendName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commendName.topAnchor.constraint(equalTo: contentView.topAnchor),
            commendName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
        ])
        contentView.addSubview(commendRating)
        commendRating.text = "4"
        commendRating.font = UIFont(name: "PingFangTC-Semibold", size: 20)
        commendRating.textColor = .black
        commendRating.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commendRating.topAnchor.constraint(equalTo: commendName.bottomAnchor, constant: 10),
            commendRating.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
        ])
        contentView.addSubview(commendRatingStar)
        commendRatingStar.image = UIImage(systemName: "star.fill")
        commendRatingStar.tintColor = .black
        commendRatingStar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commendRatingStar.centerYAnchor.constraint(equalTo: commendRating.centerYAnchor),
            commendRatingStar.leadingAnchor.constraint(equalTo: commendRating.trailingAnchor, constant: 10)
        ])
        contentView.addSubview(commendProduct)
        commendProduct.text = "Product"
        commendProduct.font = UIFont(name: "PingFangTC", size: 12)
        commendProduct.textColor = .black
        commendProduct.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commendProduct.topAnchor.constraint(equalTo: commendRating.bottomAnchor, constant: 10),
            commendProduct.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
        ])
        contentView.addSubview(commendProductImage)
        commendProductImage.image = UIImage(systemName: "star.fill")
        commendProductImage.layer.cornerRadius = 10
        commendProductImage.clipsToBounds = true
        commendProductImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commendProductImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            commendProductImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            commendProductImage.heightAnchor.constraint(equalToConstant: 80),
            commendProductImage.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
