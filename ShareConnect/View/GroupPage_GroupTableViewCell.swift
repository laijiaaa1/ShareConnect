//
//  GroupPage_GroupTableViewCell.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/6.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher

class GroupTableViewCell: UITableViewCell {
    var addGroupHandler: (() -> Void)?
    var group: Group?
    var showInvitationCodeAlert: ((Group, @escaping (Bool) -> Void) -> Void)?
    let groupImage = UIImageView()
    let groupButton = UIButton()
    let groupNameLabel = UILabel()
    let groupMemberNumberLabel = UILabel()
    let groupMemberNumberImage = UIImageView()
    let backView = UIView()
    let currrentUser = Auth.auth().currentUser?.uid
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        groupImage.layer.cornerRadius = 10
        groupImage.layer.masksToBounds = true
        groupImage.layer.borderWidth = 1
        groupNameLabel.text = "Camping Group"
        groupMemberNumberLabel.text = "member：1"
        groupMemberNumberImage.backgroundColor = UIColor(named: "G3")
        groupMemberNumberImage.layer.cornerRadius = 10
        groupMemberNumberImage.layer.masksToBounds = true
        groupButton.setTitle("        +", for: .normal)
        groupButton.contentHorizontalAlignment = .center
        groupButton.addTarget(self, action: #selector(addGroup), for: .touchUpInside)
        groupButton.setTitleColor(.black, for: .normal)
        groupButton.backgroundColor = .white
        groupButton.layer.cornerRadius = 20
        groupButton.layer.borderWidth = 1
        groupButton.layer.masksToBounds = true
        backView.backgroundColor = .white
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        backView.layer.borderWidth = 1
        contentView.addSubview(backView)
        backView.addSubview(groupImage)
        backView.addSubview(groupNameLabel)
        backView.addSubview(groupMemberNumberLabel)
        backView.addSubview(groupButton)
        backView.addSubview(groupMemberNumberImage)
        backView.translatesAutoresizingMaskIntoConstraints = false
        groupImage.translatesAutoresizingMaskIntoConstraints = false
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        groupMemberNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        groupButton.translatesAutoresizingMaskIntoConstraints = false
        groupMemberNumberImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            groupImage.topAnchor.constraint(equalTo: backView.topAnchor),
            groupImage.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            groupImage.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            groupImage.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -80),
            groupNameLabel.topAnchor.constraint(equalTo: groupImage.bottomAnchor, constant: 15),
            groupNameLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            groupMemberNumberImage.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 15),
            groupMemberNumberImage.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            groupMemberNumberImage.widthAnchor.constraint(equalToConstant: 20),
            groupMemberNumberImage.heightAnchor.constraint(equalToConstant: 20),
            groupMemberNumberLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 15),
            groupMemberNumberLabel.leadingAnchor.constraint(equalTo: groupMemberNumberImage.trailingAnchor, constant: 10),
            groupButton.topAnchor.constraint(equalTo: groupImage.bottomAnchor, constant: 15),
            groupButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20),
            groupButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -20),
            groupButton.widthAnchor.constraint(equalToConstant: 80),
            groupButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    @objc func addGroup(_ sender: UIButton) {
        addGroupHandler?()
        sender.startAnimatingPressActions()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
