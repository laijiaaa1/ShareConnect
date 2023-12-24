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
    let rentalButton = UIButton()
    let loanButton = UIButton()
    let stackView = UIStackView()
    let tableView = UITableView()
    var isCompleted = false
    let viewModel = RecoderViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
        navigationItem.title = "RECODER"
        rentalButton.setTitle("BORROWED IN", for: .normal)
        loanButton.setTitle("LENT OUT", for: .normal)
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
        rentalButton.setTitleColor(UIColor(named: "G5"), for: .normal)
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
        loanButton.setTitleColor(UIColor(named: "G5"), for: .normal)
        fetchOrdersFromFirestore(isRenter: false)
    }
    func fetchOrdersFromFirestore(isRenter: Bool) {
        viewModel.fetchOrdersFromFirestore(isRenter: isRenter) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecoderTableViewCell
        cell.order = viewModel.order(at: indexPath.row)
        cell.returnButton.setTitle("Return", for: .normal)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.contentView.backgroundColor = .black
        cell.backgroundColor = .black
        if rentalButton.isSelected {
            cell.returnButton.setTitle("Return", for: .normal)
            cell.returnButton.addTarget(self, action: #selector(returnButtonTapped), for: .touchUpInside)
            cell.returnButton.isEnabled = !viewModel.order(at: indexPath.row).isCompleted
        } else if loanButton.isSelected {
            cell.returnButton.setTitle("Remind", for: .normal)
            cell.returnButton.addTarget(self, action: #selector(remindButtonTapped), for: .touchUpInside)
        }
        if viewModel.order(at: indexPath.row).isCompleted {
            cell.returnButton.setTitle("Completed", for: .normal)
            cell.returnButton.backgroundColor = .lightGray
            cell.returnButton.isEnabled = false
        } else {
            viewModel.hasUserReviewedItem(at: indexPath.row) { hasReview in
                DispatchQueue.main.async {
                    if hasReview {
                        cell.returnButton.setTitle("Done", for: .normal)
                        cell.returnButton.backgroundColor = UIColor(named: "G3")
                        cell.returnButton.layer.borderColor = UIColor(named: "G3")?.cgColor
                        cell.returnButton.setTitleColor(.white, for: .normal)
                        cell.returnButton.isEnabled = false
                    } else {
                        cell.returnButton.setTitle("Return", for: .normal)
                        cell.returnButton.backgroundColor = .white
                        cell.returnButton.layer.borderColor = UIColor(named: "G3")?.cgColor
                        cell.returnButton.setTitleColor(UIColor(named: "G3"), for: .normal)
                        cell.returnButton.isEnabled = true
                    }
                }
            }
        }
        return cell
    }
    @objc func remindButtonTapped() {
        if (order?.orderID) != nil {}
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    @objc func returnButtonTapped(_ sender: UIButton) {
        sender.startAnimatingPressActions()
        guard (Auth.auth().currentUser?.uid) != nil else {
            return
        }
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CommendViewController") as! CommendViewController
        let selectedOrder = viewModel.order(at: selectedIndexPath.row)
        vc.viewModel.productName = selectedOrder.orderID
        vc.viewModel.productImage = selectedOrder.image
        vc.viewModel.productID = selectedOrder.orderID
        vc.viewModel.sellerID = selectedOrder.sellerID
        navigationController?.pushViewController(vc, animated: true)
    }
}
