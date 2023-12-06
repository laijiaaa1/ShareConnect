//
//  CreateRequestViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import DatePicker
import JGProgressHUD

class CreateRequestViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    let requestTableView = UITableView()
    let uploadButton = UIButton()
    let requestSelectSegment = UISegmentedControl()
    let doneButton = UIButton()
    var groupOptions: [(String, String)] = []
    let hud = JGProgressHUD()
    var sortPicker: UIPickerView?
    var usePicker: UIPickerView?
    var selectedGroupID: String?
    var selectedGroupName: String?
    var selectedGroup: String?
    private lazy var groupHeaderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .lightGray
        return label
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = .black
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = CustomColors.B1
        navigationItem.title = "Create request"
        uploadButton.backgroundColor = .clear
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadButton)
        uploadButton.setTitle("+", for: .normal)
        uploadButton.setTitleColor(.black, for: .normal)
        uploadButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        uploadButton.layer.cornerRadius = 10
        uploadButton.layer.borderWidth = 1
        uploadButton.layer.borderColor = UIColor.black.cgColor
        uploadButton.layer.masksToBounds = true
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            uploadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadButton.widthAnchor.constraint(equalToConstant: 320),
            uploadButton.heightAnchor.constraint(equalToConstant: 160)
        ])
        requestSelectSegment.insertSegment(withTitle: "Public", at: 0, animated: true)
        requestSelectSegment.insertSegment(withTitle: "Group", at: 1, animated: true)
        requestSelectSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(requestSelectSegment)
        requestSelectSegment.selectedSegmentIndex = 0
        requestSelectSegment.layer.cornerRadius = 10
        requestSelectSegment.addTarget(self, action: #selector(requestSelectSegmentTapped), for: .valueChanged)
        NSLayoutConstraint.activate([
            requestSelectSegment.topAnchor.constraint(equalTo: uploadButton.bottomAnchor, constant: 20),
            requestSelectSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            requestSelectSegment.widthAnchor.constraint(equalToConstant: 320),
            requestSelectSegment.heightAnchor.constraint(equalToConstant: 40)
        ])
        requestTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(requestTableView)
        requestTableView.delegate = self
        requestTableView.dataSource = self
        requestTableView.layer.cornerRadius = 10
        requestTableView.backgroundColor = CustomColors.B1
        requestTableView.register(UITableViewCell.self, forCellReuseIdentifier: "requestCell")
        NSLayoutConstraint.activate([
            requestTableView.topAnchor.constraint(equalTo: requestSelectSegment.bottomAnchor, constant: 20),
            requestTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            requestTableView.widthAnchor.constraint(equalToConstant: 320),
            requestTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        doneButton.backgroundColor = .black
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 320),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        sortPicker = UIPickerView()
              usePicker = UIPickerView()
              sortPicker?.delegate = self
              usePicker?.delegate = self
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func doneButtonTapped() {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let user = Auth.auth().currentUser
        let imageName = UUID().uuidString
        let productId = UUID().uuidString
        let storageRef = storage.reference().child("images/\(imageName).jpg")
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if let imageURL = self.uploadButton.backgroundImage(for: .normal), let imageData = imageURL.jpegData(compressionQuality: 0.1) {
                    storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading image: \(error)")
                        } else {
                            storageRef.downloadURL { [self] (url, error) in
                                if let error = error {
                                    print("Error getting download URL: \(error)")
                                } else if let downloadURL = url {
                                    var productData: [String: Any] = [:]
                                    productData["productId"] = productId
                                    productData["image"] = downloadURL.absoluteString
                                    productData["seller"] = [
                                        "sellerID": user?.uid ?? "",
                                        "sellerName": user?.email ?? ""
                                    ]
                                    for i in 0..<self.requestTableView.numberOfSections {
                                        for j in 0..<self.requestTableView.numberOfRows(inSection: i) {
                                            let indexPath = IndexPath(row: j, section: i)
                                            if let cell = self.requestTableView.cellForRow(at: indexPath) as? RequestCell {
                                                let key = cell.requestLabel.text ?? ""
                                                let value = cell.textField.text ?? ""
                                                productData[key] = value
                                            }
                                        }
                                    }
                                    if let selectedGroupID = self.selectedGroupID,
                                       let selectedGroupName = self.selectedGroup {
                                        productData["groupID"] = selectedGroupID
                                        productData["groupName"] = selectedGroupName
                                    }
                                    let demandProduct = Product(
                                        productId: productData["productId"] as? String ?? "",
                                        name: productData["Name"] as? String ?? "",
                                        price: productData["Price"] as? String ?? "",
                                        startTime: productData["End Time"] as? String ?? "",
                                        imageString: productData["image"] as? String ?? "",
                                        description: productData["Description"] as? String ?? "",
                                        sort: productData["Sort"] as? String ?? "",
                                        quantity: productData["Quantity"] as? Int ?? 1,
                                        use: productData["Use"] as? String ?? "",
                                        endTime: productData["End Time"] as? String ?? "",
                                        seller: Seller(
                                            sellerID: user?.uid ?? "",
                                            sellerName: user?.email ?? ""
                                        ),
                                        itemType: .request
                                    )
                                    let collectionName: String = selectedGroupID != nil ? "productsGroup" : "products"
                                    
                                    db.collection(collectionName).addDocument(data: [
                                        "type": ProductType.request.rawValue,
                                        "product": productData
                                    ]) { error in
                                        if let error = error {
                                            print("Error writing document: \(error)")
                                        } else {
                                            print("Document successfully written!")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.hud.textLabel.text = "Success"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 1.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    @objc func uploadButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true)
            }
            alertController.addAction(cameraAction)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        }
        alertController.addAction(photoLibraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        uploadButton.setBackgroundImage(info[UIImagePickerController.InfoKey.originalImage] as? UIImage, for: .normal)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func requestSelectSegmentTapped() {
        if requestSelectSegment.selectedSegmentIndex == 0 {
            print("public")
            selectedGroupID = nil
        } else {
            print("group")
            fetchUserGroups()
        }
        requestTableView.reloadData()
    }
    func fetchUserGroups() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let document = document, document.exists {
                let data = document.data()
                if let groupIDs = data?["groups"] as? [String] {
                    var groupOptions: [(String, String)] = []
                    let dispatchGroup = DispatchGroup()
                    for groupID in groupIDs {
                        dispatchGroup.enter()
                        db.collection("groups").document(groupID).getDocument { (groupDocument, groupError) in
                            defer {
                                dispatchGroup.leave()
                            }
                            if let groupDocument = groupDocument, groupDocument.exists {
                                let groupData = groupDocument.data()
                                if let groupName = groupData?["name"] as? String {
                                    groupOptions.append((groupID, groupName))
                                }
                            } else {
                                print("Group document does not exist for groupID: \(groupID)")
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        self.groupOptions = groupOptions
                        self.showGroupOptions()
                    }
                } else {
                    print("Groups field is not of the expected type [String]")
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    func showGroupOptions() {
        let alertController = UIAlertController(title: "Select Group", message: nil, preferredStyle: .actionSheet)

        for (groupId, groupName) in groupOptions {
            let action = UIAlertAction(title: groupName, style: .default) { [weak self] _ in
                self?.updateSelectedGroupUI(groupId: groupId, groupName: groupName)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    func updateSelectedGroupUI(groupId: String, groupName: String) {
        selectedGroupID = groupId
        selectedGroup = groupName
        if let selectedGroupID = selectedGroupID, let selectedGroup = selectedGroup {
            groupHeaderLabel.text = "Selected Group: \(selectedGroup)"
            if requestTableView.tableHeaderView == nil {
                requestTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: requestTableView.bounds.size.width, height: 50))
                requestTableView.tableHeaderView?.addSubview(groupHeaderLabel)
                groupHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    groupHeaderLabel.leadingAnchor.constraint(equalTo: requestTableView.tableHeaderView!.leadingAnchor, constant: 16),
                    groupHeaderLabel.trailingAnchor.constraint(equalTo: requestTableView.tableHeaderView!.trailingAnchor, constant: -16),
                    groupHeaderLabel.topAnchor.constraint(equalTo: requestTableView.tableHeaderView!.topAnchor),
                    groupHeaderLabel.bottomAnchor.constraint(equalTo: requestTableView.tableHeaderView!.bottomAnchor, constant: -16)
                ])
                groupHeaderLabel.textAlignment = .center
                groupHeaderLabel.textColor = .black
                groupHeaderLabel.backgroundColor = CustomColors.B1
                groupHeaderLabel.font = UIFont.systemFont(ofSize: 12)
            }
        } else {
            requestTableView.tableHeaderView = nil
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedGroupID != nil ? 9 : 8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? RequestCell ?? RequestCell()
        cell.requestLabel.text = "name"
        cell.addBtn.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        cell.addBtn.tintColor = .black
        cell.textField.delegate = self

        let requestLabels = ["Name", "Description", "Sort", "Start Time", "End Time", "Quantity", "Use", "Price"]
        if indexPath.row < requestLabels.count {
            let info = requestLabels[indexPath.row]
            cell.requestLabel.text = info
        }
        if indexPath.row == 3 || indexPath.row == 4 {
            let timePicker = UIDatePicker()
            timePicker.datePickerMode = .dateAndTime
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)
            timePicker.tag = indexPath.row
            cell.textField.tag = indexPath.row
            cell.textField.inputView = timePicker
        }
        if indexPath.row == 8 && selectedGroupID != nil {
            cell.requestLabel.text = "Group"
            cell.textField.text = selectedGroupName
            cell.textField.isEnabled = false
            cell.addBtn.isHidden = true
        }
        cell.addBtn.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    @objc func timePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = formatter.string(from: sender.date)
        print(timeString)

        if sender.tag == 3, let startCell = findCellWithTag(3) {
            startCell.textField.text = timeString
        } else if sender.tag == 4, let endCell = findCellWithTag(4) {
            endCell.textField.text = timeString
        }
    }
    func findCellWithTag(_ tag: Int) -> RequestCell? {
        for i in 0..<requestTableView.numberOfSections {
            for j in 0..<requestTableView.numberOfRows(inSection: i) {
                let indexPath = IndexPath(row: j, section: i)
                if let cell = requestTableView.cellForRow(at: indexPath) as? RequestCell, cell.textField.tag == tag {
                    return cell
                }
            }
        }
        return nil
    }
}
