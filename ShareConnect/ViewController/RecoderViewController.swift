//
//  RecoderViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/23.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

class RecoderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var order: Order?
    var orderID: [Order] = []
    let rentalButton = UIButton()
    let loanButton = UIButton()
    let stackView = UIStackView()
    let tableView = UITableView()
    var isCompleted = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
        navigationItem.title = "RECODER"
        rentalButton.setTitle("Rental Items", for: .normal)
        loanButton.setTitle("On Loan", for: .normal)
        rentalButton.setTitleColor(.white, for: .normal)
        loanButton.setTitleColor(.white, for: .normal)
        rentalButton.addTarget(self, action: #selector(rentalButtonTapped), for: .touchUpInside)
        loanButton.addTarget(self, action: #selector(loanButtonTapped), for: .touchUpInside)
        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        stackView.addArrangedSubview(rentalButton)
        stackView.addArrangedSubview(loanButton)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(RecoderTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        fetchOrdersFromFirestore(isRenter: true)
    }
    @objc func rentalButtonTapped() {
        rentalButton.isSelected = true
        loanButton.isSelected = false
        rentalButton.setTitleColor(UIColor(named: "G3"), for: .normal)
        rentalButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loanButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loanButton.setTitleColor(.lightGray, for: .normal)
        fetchOrdersFromFirestore(isRenter: true)
    }
    @objc func loanButtonTapped() {
        rentalButton.isSelected = false
        loanButton.isSelected = true
        rentalButton.setTitleColor(.lightGray, for: .normal)
        loanButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        rentalButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loanButton.setTitleColor(UIColor(named: "G3"), for: .normal)
        fetchOrdersFromFirestore(isRenter: false)
    }
    func fetchOrdersFromFirestore(isRenter: Bool) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let ordersCollection = Firestore.firestore().collection("orders")
        let fieldToFilter = isRenter ? "buyerID" : "sellerID"
        ordersCollection.whereField(fieldToFilter, isEqualTo: currentUserID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let querySnapshot = querySnapshot else {
                return
            }
            if let error = error {
                print("Error fetching orders: \(error.localizedDescription)")
                return
            }
            self.orderID = querySnapshot.documents.compactMap { Order(document: $0) }
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderID.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecoderTableViewCell
        cell.order = orderID[indexPath.row]
        cell.returnButton.setTitle("Return", for: .normal)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        if rentalButton.isSelected {
            cell.returnButton.setTitle("Return", for: .normal)
            cell.returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
            cell.returnButton.isEnabled = !orderID[indexPath.row].isCompleted
        } else if loanButton.isSelected {
            cell.returnButton.setTitle("Remind", for: .normal)
            cell.returnButton.addTarget(self, action: #selector(remindButtonTapped), for: .touchUpInside)
        }

        if orderID[indexPath.row].isCompleted {
            cell.returnButton.setTitle("Completed", for: .normal)
            cell.returnButton.backgroundColor = .lightGray
            cell.returnButton.isEnabled = false
        } else {
            fetchReviewFromFireStore(for: orderID[indexPath.row].orderID) { hasReview in
                DispatchQueue.main.async {
                    if hasReview {
                        cell.returnButton.setTitle("Done", for: .normal)
                        cell.returnButton.backgroundColor = .black
                        cell.returnButton.layer.borderColor = UIColor.black.cgColor
                        cell.returnButton.setTitleColor(.white, for: .normal)
                        cell.returnButton.isEnabled = false
                    } else {
                        cell.returnButton.setTitle("Return", for: .normal)
                        cell.returnButton.backgroundColor = .white
                        cell.returnButton.layer.borderColor = UIColor.black.cgColor
                        cell.returnButton.setTitleColor(.black, for: .normal)
                        cell.returnButton.isEnabled = true
                    }
                }
            }
        }

        return cell
    }

    func fetchReviewFromFireStore(for orderID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let reviewsCollection = Firestore.firestore().collection("reviews")
        reviewsCollection.whereField("userID", isEqualTo: currentUserID).whereField("productID", isEqualTo: orderID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching reviews: \(error.localizedDescription)")
                completion(false)
                return
            }

            let hasReview = !(querySnapshot?.documents.isEmpty ?? false) 
            completion(hasReview)
        }
    }

    @objc func remindButtonTapped() {
        if let orderID = order?.orderID {
            scheduleLocalNotification(for: orderID)
        }
    }
    func scheduleLocalNotification(for orderID: String) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to return the item for order \(orderID)!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder_\(orderID)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
            }
        }
        )}
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    @objc func returnButtonTapped(_ sender: UIButton) {
        sender.startAnimatingPressActions()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CommendViewController") as! CommendViewController
        let selectedOrder = orderID[selectedIndexPath.row]
        vc.productName = selectedOrder.orderID
        vc.productImage = selectedOrder.image
        vc.productID = selectedOrder.orderID
        vc.sellerID = selectedOrder.sellerID
        navigationController?.pushViewController(vc, animated: true)
    }
}
