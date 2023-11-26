//
//  GroupViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/17.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher

struct Group {
    var documentId: String
    var name: String
    var description: String
    var sort: String
    var startTime: String
    var endTime: String
    var require: String
    var numberOfPeople: Int
    var owner: String
    var isPublic: Bool
    var members: [String]
    var image: String
    var invitationCode: String?
    var created: Date
    
    mutating func addMember(userId: String) {
           if !members.contains(userId) {
               members.append(userId)
           }
       }
}

extension Group {
    init?(data: [String: Any], documentId: String) {
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
        self.documentId = documentId
        self.name = name
        self.description = description
        self.sort = sort
        self.startTime = startTime
        self.endTime = endTime
        self.require = require
        self.numberOfPeople = numberOfPeople
        self.owner = owner
        self.isPublic = isPublic
        self.members = members
        self.image = image
        self.invitationCode = data["invitationCode"] as? String
        self.created = createdTimestamp.dateValue()
    }
}

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let groupImage = UIImageView()
    let groupButton = UIButton()
    let groupNameLabel = UILabel()
    let groupMemberNumberLabel = UILabel()
    let tableView = UITableView()
    var groups: [Group] = []
    var group: Group?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "GroupTableViewCell")
        
        view.backgroundColor = CustomColors.B1
        tableView.frame = view.bounds
        fetchGroupData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath) as! GroupTableViewCell
        let group = groups[indexPath.row]
        cell.groupNameLabel.text = group.name
        cell.groupMemberNumberLabel.text = group.members.count.description
        cell.groupImage.kf.setImage(with: URL(string: group.image))
        cell.addGroupHandler = { [weak self] in
            guard let self = self, let userId = Auth.auth().currentUser?.uid else {
                return
            }

            if !group.members.contains(userId) {
                var updatedGroup = group
                updatedGroup.addMember(userId: userId)
                self.groups[indexPath.row] = updatedGroup

                self.tableView.reloadRows(at: [indexPath], with: .none)

                // Use the document ID directly
                self.updateGroupInFirestore(groupId: updatedGroup.documentId, updatedGroup: updatedGroup)
                self.updateUserInFirestore(userId: userId, updatedGroup: updatedGroup)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        let subGroupViewController = SubGroupViewController()
        subGroupViewController.group = group
        navigationController?.pushViewController(subGroupViewController, animated: true)
    }
    func fetchGroupData() {
        let groupsRef = Firestore.firestore().collection("groups")
        let query = groupsRef.whereField("isPublic", isEqualTo: true)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching public groups: \(error.localizedDescription)")
            } else {
                self.groups.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let group = Group(data: data, documentId: document.documentID) {
                        self.groups.append(group)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    private func updateGroupInFirestore(groupId: String, updatedGroup: Group) {
            let groupsRef = Firestore.firestore().collection("groups")

            let updatedData: [String: Any] = [
                "members": updatedGroup.members
            ]

            groupsRef.document(groupId).updateData(updatedData) { error in
                if let error = error {
                    print("Error updating group in Firestore: \(error.localizedDescription)")
                } else {
                    print("Group updated successfully in Firestore.")
                }
            }
        }
    private func updateUserInFirestore(userId: String, updatedGroup: Group) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        let groupId = "groupId"
        let userGroupsData: [String: Any] = [
            groupId: [
                "groupId": updatedGroup.documentId,
                "groupName": updatedGroup.name,
                "groupImage": updatedGroup.image,
                "groupDescription": updatedGroup.description,
                "groupSort": updatedGroup.sort,
                "groupOwner": updatedGroup.owner,
                "groupStartTime": updatedGroup.startTime,
                "groupEndTime": updatedGroup.endTime,
                "groupRequire": updatedGroup.require,
                "groupNumberOfPeople": updatedGroup.numberOfPeople,
                "groupIsPublic": updatedGroup.isPublic,
                "groupMembers": updatedGroup.members,
                "groupCreated": updatedGroup.created,
                "groupInvitationCode": updatedGroup.invitationCode ?? "" 
            ]
        ]

        userRef.updateData(["groups": userGroupsData], completion: { error in
            if let error = error {
                print("Error updating user in Firestore: \(error.localizedDescription)")
            } else {
                print("User updated successfully in Firestore.")
            }
        })
    }

}
    class GroupTableViewCell: UITableViewCell{
        var addGroupHandler: (() -> Void)?
        let groupImage = UIImageView()
        let groupButton = UIButton()
        let groupNameLabel = UILabel()
        let groupMemberNumberLabel = UILabel()
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            groupImage.backgroundColor = .yellow
            groupNameLabel.text = "Camping Group"
            groupMemberNumberLabel.text = "member：1"
            groupButton.setTitle("+", for: .normal)
            groupButton.addTarget(self, action: #selector(addGroup), for: .touchUpInside)
            groupButton.setTitleColor(.black, for: .normal)
            contentView.addSubview(groupImage)
            contentView.addSubview(groupNameLabel)
            contentView.addSubview(groupMemberNumberLabel)
            contentView.addSubview(groupButton)
            groupImage.translatesAutoresizingMaskIntoConstraints = false
            groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
            groupMemberNumberLabel.translatesAutoresizingMaskIntoConstraints = false
            groupButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                groupImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
                groupImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                groupImage.heightAnchor.constraint(equalToConstant: 100),
                groupImage.widthAnchor.constraint(equalToConstant: 100),
                groupNameLabel.topAnchor.constraint(equalTo: groupImage.bottomAnchor, constant: 20),
                groupNameLabel.leadingAnchor.constraint(equalTo: groupImage.leadingAnchor, constant: 20),
                groupMemberNumberLabel.topAnchor.constraint(equalTo: groupNameLabel.bottomAnchor, constant: 20),
                groupMemberNumberLabel.leadingAnchor.constraint(equalTo: groupImage.trailingAnchor, constant: 20),
                groupButton.topAnchor.constraint(equalTo: groupMemberNumberLabel.bottomAnchor, constant: 40),
                groupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                groupButton.heightAnchor.constraint(equalToConstant: 40),
                groupButton.widthAnchor.constraint(equalToConstant: 40),
                
            ])
        }
        @objc func addGroup(){
            addGroupHandler?()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

