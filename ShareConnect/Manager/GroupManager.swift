//
//  GroupManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher

class GroupDataManager {
    static let shared = GroupDataManager()
    private init() {}

    func fetchGroups(sort: String, completion: @escaping ([Group]) -> Void) {
        let groupsRef = Firestore.firestore().collection("groups")
        let query = groupsRef.whereField("isPublic", isEqualTo: true).whereField("sort", isEqualTo: sort)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching public groups: \(error.localizedDescription)")
                completion([])
            } else {
                var groups: [Group] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let group = Group(data: data, documentId: document.documentID) {
                        groups.append(group)
                    }
                }
                completion(groups)
            }
        }
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

    private func parseGroupData(data: [String: Any], documentId: String) -> Group? {
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
