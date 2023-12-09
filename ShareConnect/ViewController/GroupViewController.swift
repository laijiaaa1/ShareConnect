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

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let groupImage = UIImageView()
    let groupButton = UIButton()
    let groupNameLabel = UILabel()
    let groupMemberNumberLabel = UILabel()
    let tableView = UITableView()
    var groups: [Group] = []
    var group: Group?
    let searchTextField = UITextField()
    let currentUser = Auth.auth().currentUser?.uid
    var sort: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tabBarController?.tabBar.backgroundColor = .black
        tabBarController?.tabBar.barTintColor = .black
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "GroupTableViewCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .black
        if sort == "product" {
            fetchGroupData(sort: "product")
        } else if sort == "place" {
            fetchGroupData(sort: "place")
        } else if sort == "course" {
            fetchGroupData(sort: "course")
        } else if sort == "food" {
            fetchGroupData(sort: "food")
        }
        tableView.backgroundColor = .black
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 22
        searchTextField.layer.masksToBounds = true
        searchTextField.frame = CGRect(x: 30, y: 100, width: 330, height: 44)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24))
        imageView.image = UIImage(named: "icons8-search-90(@3×)")
        leftView.addSubview(imageView)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let rightImageView = UIImageView(frame: CGRect(x: 10, y: 12, width: 18, height: 18))
        rightImageView.image = UIImage(named: "icons8-filter-48(@3×)")
        rightView.addSubview(rightImageView)
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .always
        searchTextField.backgroundColor = .white
        view.addSubview(searchTextField)
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func searchTextFieldDidChange() {
        searchGroupsByName(searchString: searchTextField.text ?? "", completion: { (groups) in
            self.groups = groups
            self.tableView.reloadData()
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell", for: indexPath) as! GroupTableViewCell
        let group = groups[indexPath.row]
        cell.backgroundColor = .black
        cell.groupNameLabel.text = group.name
        cell.groupMemberNumberLabel.text = "Members: + \(group.members.count.description)"
        cell.groupImage.kf.setImage(with: URL(string: group.image))
        cell.addGroupHandler = {
            if !group.members.contains(self.currentUser ?? "") {
                Firestore.firestore().collection("groups").document(group.documentId).updateData(["members": FieldValue.arrayUnion([self.currentUser ?? ""])])
                Firestore.firestore().collection("users").document(self.currentUser ?? "").updateData(["groups": FieldValue.arrayUnion([group.documentId])])
                cell.groupMemberNumberLabel.text = "Members: + \(group.members.count.description)"
            }
            self.fetchGroupData(sort: self.sort ?? "")
        }
        if ((group.members.contains(currentUser ?? "")) == true) {
            cell.groupButton.setTitle("Joined", for: .normal)
            cell.groupButton.backgroundColor = .lightGray
            cell.groupButton.layer.borderWidth = 0
            cell.groupButton.alpha = 0.5
            cell.groupButton.isEnabled = false
        } else {
            groupButton.setTitle("        +", for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var group = groups[indexPath.row]
        if group.isPublic {
            let subGroupViewController = SubGroupViewController()
            subGroupViewController.group = group
            navigationController?.pushViewController(subGroupViewController, animated: true)
        } else {
            showInvitationCodeAlert(group: group) { isCodeCorrect in
                if isCodeCorrect {
                    let subGroupViewController = SubGroupViewController()
                    subGroupViewController.group = group
                    self.navigationController?.pushViewController(subGroupViewController, animated: true)
                } else {
                    print("Incorrect invitation code")
                }
            }
        }
    }
    func fetchGroupData(sort: String) {
        let sort = sort
        let groupsRef = Firestore.firestore().collection("groups")
        let query = groupsRef.whereField("isPublic", isEqualTo: true).whereField("sort", isEqualTo: sort)
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
    func searchGroupsByName(searchString: String, completion: @escaping ([Group]) -> Void) {
        let db = Firestore.firestore()
        let groupsCollection = db.collection("groups")
        let query = groupsCollection
            .whereField("name", isGreaterThanOrEqualTo: searchString)
            .whereField("name", isLessThan: searchString + "\u{f8ff}")
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error searching groups: \(error.localizedDescription)")
                completion([])
            } else {
                var searchResults: [Group] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let group = self.parseGroupData(data: data, documentId: document.documentID) {
                        searchResults.append(group)
                    }
                }
                completion(searchResults)
            }
        }
    }
    func parseGroupData(data: [String: Any], documentId: String) -> Group? {
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
        var group = Group(
            documentId: documentId,
            name: name,
            description: description,
            sort: sort,
            startTime: startTime,
            endTime: endTime,
            require: require,
            numberOfPeople: numberOfPeople,
            owner: owner,
            isPublic: isPublic,
            members: members,
            image: image,
            created: createdTimestamp.dateValue()
        )
        group.invitationCode = data["invitationCode"] as? String
        return group
    }
}

extension GroupViewController {
    func showInvitationCodeAlert(group: Group, completion: @escaping (Bool) -> Void) {
        var mutableGroup = group
        let alertController = UIAlertController(title: "Enter Invitation Code", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Invitation Code"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        let joinAction = UIAlertAction(title: "Join", style: .default) { _ in
            if let invitationCode = alertController.textFields?.first?.text {
                if invitationCode == mutableGroup.invitationCode {
                    completion(true)
                    mutableGroup.addMember(userId: self.currentUser!)
                    if let index = self.groups.firstIndex(where: { $0.documentId == mutableGroup.documentId }) {
                        self.groups[index] = mutableGroup
                    }
                } else {
                    print("Invalid invitation code")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(joinAction)
        present(alertController, animated: true, completion: nil)
    }
}
