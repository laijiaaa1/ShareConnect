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

class CreateGroupViewController: CreateRequestViewController {
    var isGroupPublic: Bool = true
    var groupData: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
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
        return 8
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? RequestCell ?? RequestCell()
        cell.requestLabel.text = "name"
        cell.addBtn.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        cell.addBtn.tintColor = .black
        var requestLabels = ["Name", "Description", "Sort", "Start Time", "End Time", "Require", "Number of people", "Invitation Code"]
        if indexPath.row < requestLabels.count {
            let info = requestLabels[indexPath.row]
            cell.requestLabel.text = info
        }
//        if !isGroupPublic {
//            var requestLabels = ["Name", "Description", "Sort", "Start Time", "End Time", "Require", "Number of people"]
//            if indexPath.row < requestLabels.count {
//                let info = requestLabels[indexPath.row]
//                cell.requestLabel.text = info
//            }
//               }
        if indexPath.row == 1{
            cell.textField.tag = 3
        }else if indexPath.row == 2{
            cell.textField.tag = 4
        }else if indexPath.row == 5{
            cell.textField.tag = 5
        }else if indexPath.row == 7{
            cell.textField.tag = 7
        }
      
        
        if indexPath.row == 3 || indexPath.row == 4 {
            let timePicker = UIDatePicker()
            timePicker.datePickerMode = .dateAndTime
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)
            if indexPath.row == 3 {
                cell.textField.inputView = timePicker
                cell.textField.tag = 1
            } else if indexPath.row == 4 {
                cell.textField.inputView = timePicker
                cell.textField.tag = 2
            }
        }
        if indexPath.row == 6 {
            let stepper = UIStepper()
            stepper.minimumValue = 0
            stepper.maximumValue = 1000
            stepper.stepValue = 1
            stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
            cell.textField.inputView = stepper
            cell.textField.tag = 6
            cell.textField.text = "10"
        } else {
            cell.textField.keyboardType = .default
        }
        if !isGroupPublic && indexPath.row == 7 {
                   // Configure the cell for the invitation code
                   cell.textField.placeholder = "Enter Invitation Code"
                   cell.textField.tag = 7 // Assign a unique tag for the invitation code field
               }
        cell.addBtn.tag = indexPath.row 
        return cell
    }
    @objc func stepperValueChanged(sender: UIStepper) {
        if let cell = findCellWithTag(6) {
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
           let code = findCellWithTag(7)?.textField.text ?? ""
           let minLength = 6
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

           let groupsRef = Firestore.firestore().collection("groups")
           groupData = [
               "name": findCellWithTag(0)?.textField.text ?? "",
                "description": findCellWithTag(3)?.textField.text ?? "",
                "sort": findCellWithTag(4)?.textField.text ?? "",
                "startTime": findCellWithTag(1)?.textField.text ?? "",
                "endTime": findCellWithTag(2)?.textField.text ?? "",
                "require": findCellWithTag(5)?.textField.text ?? "",
               "numberOfPeople": Int(findCellWithTag(6)?.textField.text ?? "") ?? 1,
                "owner": user.uid,
                "isPublic": isGroupPublic,
                "members": [user.uid],
               "image": groupData["image"] ?? "",
                "created": Date(),
           ]
        if !isGroupPublic {
            groupData["invitationCode"] = findCellWithTag(7)?.textField.text ?? ""
              }

           groupsRef.addDocument(data: groupData) { error in
               if let error = error {
                   print("Error creating group: \(error.localizedDescription)")
               } else {
                   print("Group created and saved to Firestore.")
               }
           }
       }
}
