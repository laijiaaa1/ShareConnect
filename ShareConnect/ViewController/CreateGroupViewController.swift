//
//  CreateGroupViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import Kingfisher
import ProgressHUD

class CreateGroupViewController: CreateRequestViewController {
    var isGroupPublic: Bool = true
    var groupData: [String: Any] = [:]
    var groupClass = ["product", "place", "course", "food"]
    let groupPicker = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create Group"
        navigationController?.navigationBar.tintColor = .black
        requestSelectSegment.setTitle("Public", forSegmentAt: 0)
        requestSelectSegment.setTitle("Private", forSegmentAt: 1)
    }
    @objc override func requestSelectSegmentTapped() {
        if requestSelectSegment.selectedSegmentIndex == 0 {
            print("public")
            isGroupPublic = true
        } else {
            print("private")
            isGroupPublic = false
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? RequestCell ?? RequestCell()
        cell.requestLabel.text = "name"
        cell.addBtn.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        cell.addBtn.tintColor = .white
        cell.backgroundColor = .black
        cell.requestLabel.numberOfLines = 0
        cell.requestLabel.textColor = .white
        cell.textField.textColor = .white
        cell.requestLabel.frame = cell.contentView.bounds
        cell.requestLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        var requestLabels = ["Name", "Description", "Sort", "Require", "No. of people", "Invite Code(Private必填)"]
        if indexPath.row < requestLabels.count {
            let info = requestLabels[indexPath.row]
            cell.requestLabel.text = info
            cell.requestLabel.textColor = .white
            cell.textField.placeholder = "Enter \(info)"
            cell.textField.tag = indexPath.row
            cell.textField.isEnabled = true
            cell.textField.delegate = self
            if indexPath.row == 2 {
               
                groupPicker.delegate = self
                groupPicker.dataSource = self
                groupPicker.tag = indexPath.row
                cell.textField.tag = indexPath.row
                cell.textField.inputView = groupPicker
                print("sort:\(cell.textField.text)")
            }
            
        }
        if indexPath.row == 0 {
            cell.textField.tag = 0
        } else if indexPath.row == 1 {
            cell.textField.tag = 1
        } else if indexPath.row == 2 {
            cell.textField.tag = 2
        } else if indexPath.row == 3 {
            cell.textField.tag = 3
            
        }
        if indexPath.row == 4 {
            let stepper = UIStepper()
            stepper.minimumValue = 0
            stepper.maximumValue = 1000
            stepper.stepValue = 1
            stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
            cell.textField.inputView = stepper
            cell.textField.tag = 4
            cell.textField.text = "10"
        } else {
            cell.textField.keyboardType = .default
        }
        if !isGroupPublic && indexPath.row == 5 {
            cell.textField.placeholder = "Enter Invitation Code"
            cell.textField.tag = 5
        }
        cell.addBtn.tag = indexPath.row
        return cell
    }
    @objc func stepperValueChanged(sender: UIStepper) {
        if let cell = findCellWithTag(4) {
            cell.textField.text = "\(Int(sender.value))"
        }
    }
    @objc override func doneButtonTapped() {
        if isGroupPublic || (!isGroupPublic && isValidInvitationCode()) {
            uploadGroupImageAndSaveToFirebase()
        } else {
            print("Error: Invitation code is required for private groups.")
        }
    }
    func isValidInvitationCode() -> Bool {
        let code = findCellWithTag(5)?.textField.text ?? ""
        let minLength = 3
        if !code.isEmpty && code.count >= minLength{
            return true
        }
        return false
    }

    func uploadGroupImageAndSaveToFirebase() {
        guard let user = Auth.auth().currentUser else {
            print("Error: User is not authenticated.")
            return
        }
        guard let groupImage = uploadButton.backgroundImage(for: .normal),
              let imageData = groupImage.jpegData(compressionQuality: 0.1) else {
            print("Error: Unable to get group image data.")
            return
        }
        let imageName = UUID().uuidString
        let imageRef = Storage.storage().reference().child("group_images/\(imageName).jpg")
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error)")
            } else {
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                    } else if let downloadURL = url {
                        self.groupData["image"] = downloadURL.absoluteString
                        self.saveGroupToFirebase()
                    }
                }
            }
        }
    }
    func saveGroupToFirebase() {
        guard let user = Auth.auth().currentUser else {
            print("Error: User is not authenticated.")
            return
        }
        ProgressHUD.animate("Please wait...", .ballVerticalBounce)
        let groupsRef = Firestore.firestore().collection("groups")
        let userGroups = Firestore.firestore().collection("users").document(user.uid)
        groupData = [
            "name": findCellWithTag(0)?.textField.text ?? "",
            "description": findCellWithTag(1)?.textField.text ?? "",
            "sort": findCellWithTag(2)?.textField.text ?? "",
            "startTime": "",
            "endTime":  "",
            "require": findCellWithTag(3)?.textField.text ?? "",
            "numberOfPeople": Int(findCellWithTag(4)?.textField.text ?? "") ?? 1,
            "owner": user.uid,
            "isPublic": isGroupPublic,
            "members": [user.uid],
            "image": groupData["image"] ?? "",
            "created": Date()
        ]
        if !isGroupPublic {
            groupData["invitationCode"] = findCellWithTag(5)?.textField.text ?? ""
        }
        var newGroupDocRef: DocumentReference?
        newGroupDocRef = groupsRef.addDocument(data: groupData) { error in
            if let error = error {
                print("Error creating group: \(error.localizedDescription)")
            } else {
                let groupID = newGroupDocRef?.documentID
                userGroups.updateData(["groups": FieldValue.arrayUnion([groupID])]) { error in
                    if let error = error {
                        print("Error updating user's groups: \(error.localizedDescription)")
                    } else {
                        print("User's groups updated in Firestore.")
                    }
                }
                print("Group created and saved to Firestore.")
            }
        }
        DispatchQueue.main.async {
            ProgressHUD.succeed("Success", delay: 1.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if groupPicker.tag == 2 {
            return groupClass.count
        }
        return 0
    }
    override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if groupPicker.tag == 2 {
            return groupClass[row]
        }
        return nil
    }
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textFieldTag = groupPicker.tag
        if textFieldTag == 2 {
            if let cell = findCellWithTag(textFieldTag) {
                let selectedSort = groupClass[row]
                cell.textField.text = selectedSort
                requestTableView.reloadRows(at: [IndexPath(row: 0, section: textFieldTag)], with: .automatic)
                print("selectedSort: \(selectedSort)")
                let sortCell = findCellWithTag(2)
                sortCell?.textField.text = selectedSort
            }
        }
    }
}
