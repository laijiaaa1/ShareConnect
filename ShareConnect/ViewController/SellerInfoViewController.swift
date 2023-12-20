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
        view.backgroundColor = .black
        view.addSubview(commendTableView)
        view.addSubview(commendTitleLabel)
        view.addSubview(productTitleLabel)
        commendTableView.backgroundColor = .black
        commendTableView.separatorStyle = .none
        commendTitleLabel.text = "ALL REVIEWS"
        commendTitleLabel.textColor = .white
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
        blockUser()
    }
    func blockUser() {
        let actionsButton = UIButton()
        view.addSubview(actionsButton)
        actionsButton.setImage(UIImage(named: "icons8-error-96"), for: .normal)
        actionsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionsButton.centerYAnchor.constraint(equalTo: commendTitleLabel.centerYAnchor),
            actionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            actionsButton.widthAnchor.constraint(equalToConstant: 30),
            actionsButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        actionsButton.addTarget(self, action: #selector(showActionsMenu), for: .touchUpInside)
    }
    @objc func showActionsMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let blockAction = UIAlertAction(title: "Block Seller", style: .destructive) { _ in
            self.showBlockConfirmation()
        }
        alert.addAction(blockAction)
        let reportAction = UIAlertAction(title: "Report Seller", style: .destructive) { _ in
            self.showReportConfirmation()
        }
        alert.addAction(reportAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    func showBlockConfirmation() {
        let confirmationAlert = UIAlertController(title: "Block Seller", message: "Are you sure you want to block this seller?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.blockSeller()
        }
        confirmationAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction(cancelAction)
        present(confirmationAlert, animated: true, completion: nil)
    }
    func showReportConfirmation() {
        let confirmationAlert = UIAlertController(title: "Report Seller", message: "Are you sure you want to report this seller?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.showReportOptions()
        }
        confirmationAlert.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction(cancelAction)
        present(confirmationAlert, animated: true, completion: nil)
    }
    func showReportOptions() {
        let reportOptionsAlert = UIAlertController(title: "Select a reason for reporting", message: nil, preferredStyle: .actionSheet)
        let reasons = ["Inappropriate Content", "Fraud", "Harassment", "Other"]
        for reason in reasons {
            let action = UIAlertAction(title: reason, style: .default) { _ in
                if reason == "Other" {
                    self.showCustomReasonInput()
                } else {
                    self.submitReport(reason: reason)
                }
            }
            reportOptionsAlert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        reportOptionsAlert.addAction(cancelAction)
        present(reportOptionsAlert, animated: true, completion: nil)
    }
    func showCustomReasonInput() {
        let customReasonAlert = UIAlertController(title: "Enter your custom reason", message: nil, preferredStyle: .alert)
        customReasonAlert.addTextField { textField in
            textField.placeholder = "Type your reason here"
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            if let customReason = customReasonAlert.textFields?.first?.text, !customReason.isEmpty {
                self.submitReport(reason: customReason)
            } else {
                print("Custom reason is empty.")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        customReasonAlert.addAction(submitAction)
        customReasonAlert.addAction(cancelAction)
        present(customReasonAlert, animated: true, completion: nil)
    }
    func blockSeller() {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let sellerID = sellerID else {
            return
        }
        let blockedUsersCollection = Firestore.firestore().collection("blockedUsers")
        blockedUsersCollection.document(currentUserID).setData([sellerID: true], merge: true) { error in
            if let error = error {
                print("Error blocking user: \(error.localizedDescription)")
                return
            }
            print("Successfully blocked user.")
        }
    }
    func submitReport(reason: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let sellerID = sellerID else {
            return
        }
        let reportsCollection = Firestore.firestore().collection("reports")
        let reportData: [String: Any] = [
            "reporterID": currentUserID,
            "sellerID": sellerID,
            "reason": reason,
            "timestamp": FieldValue.serverTimestamp()
        ]
        reportsCollection.addDocument(data: reportData) { error in
            if let error = error {
                print("Error submitting report: \(error.localizedDescription)")
                return
            }
            print("Successfully submitted report.")
        }
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
