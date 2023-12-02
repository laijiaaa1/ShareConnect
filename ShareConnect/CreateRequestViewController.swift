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

class CreateRequestViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    let requestTableView = UITableView()
    let uploadButton = UIButton()
    let requestSelectSegment = UISegmentedControl()
    let doneButton = UIButton()
    var groupOptions: [String: Any] = [:]
    var selectedGroupID: String?
    var selectedGroupName: String?
    var selectedGroup: String? {
        didSet {
            updateSelectedGroupUI()
        }
    }
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
            requestTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
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
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 320),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    @objc func doneButtonTapped() {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let user = Auth.auth().currentUser
        let imageName = UUID().uuidString
        let productId = UUID().uuidString
        let storageRef = storage.reference().child("images/\(imageName).jpg")
        if let imageURL = uploadButton.backgroundImage(for: .normal), let imageData = imageURL.jpegData(compressionQuality: 0.1) {
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
                                "sellerName": user?.email ?? "",
                                
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
                                name: productData["name"] as? String ?? "",
                                price: productData["price"] as? String ?? "",
                                startTime: productData["endTime"] as? String ?? "",
                                imageString: productData["image"] as? String ?? "",
                                description: productData["description"] as? String ?? "",
                                sort: productData["sort"] as? String ?? "",
                                quantity: productData["quantity"] as? Int ?? 1,
                                use: productData["use"] as? String ?? "",
                                endTime: productData["endTime"] as? String ?? "",
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

                if let groups = data?["groups"] as? [String: Any] {
                   
                    var groupsSelect = groups
                    self.groupOptions = groupsSelect
                    self.showGroupOptions()
                } else {
                    print("Groups field is not of expected type [String: Any]")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    func showGroupOptions() {
        let alertController = UIAlertController(title: "Select Group", message: nil, preferredStyle: .actionSheet)

        for (groupId, groupInfo) in groupOptions {
            if let groups = groupInfo as? [String: Any],
               let groupId = groups["groupId"] as? String,
                let groupName = groups["groupName"] as? String {
                let action = UIAlertAction(title: groupName, style: .default) { [weak self] _ in
                    print("Selected group: \(groupName)")
                    self?.selectedGroupID = groupId
                    self?.selectedGroup = groupName
                    self?.updateSelectedGroupUI()
                }
                alertController.addAction(action)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }


    func updateSelectedGroupUI() {
        if let selectedGroupID = selectedGroupID,let selectedGroupName = selectedGroup {
            groupHeaderLabel.text = "Selected Group: \(selectedGroupName)"
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
            if indexPath.row == 3 {
                cell.textField.inputView = timePicker
                cell.textField.tag = 1
            } else if indexPath.row == 4 {
                cell.textField.inputView = timePicker
                cell.textField.tag = 2
            }
        }
        if indexPath.row == 8 && selectedGroupID != nil {
               cell.requestLabel.text = "Group"
               cell.textField.text = selectedGroupID
               cell.textField.isEnabled = false
               cell.addBtn.isHidden = true
           }
        cell.addBtn.tag = indexPath.row
        return cell
    }
    @objc func timePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = formatter.string(from: sender.date)
        print(timeString)
        if let startCell = findCellWithTag(1) {
            startCell.textField.text = timeString
            startCell.textField.resignFirstResponder()
        }
        if let endCell = findCellWithTag(2) {
            endCell.textField.text = timeString
            endCell.textField.resignFirstResponder()
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
class RequestCell: UITableViewCell {
    let requestLabel = UILabel()
    let addBtn = UIButton()
    let textField = UITextField()
    var isExpanded: Bool = false {
        didSet {
            updateCellHeight()
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isHidden = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        contentView.addSubview(addBtn)
        contentView.addSubview(requestLabel)
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            requestLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            requestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            requestLabel.widthAnchor.constraint(equalToConstant: 100),
            requestLabel.heightAnchor.constraint(equalToConstant: 20),
            addBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            addBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            addBtn.widthAnchor.constraint(equalToConstant: 20),
            addBtn.heightAnchor.constraint(equalToConstant: 20),
            textField.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
        addBtn.addTarget(self, action: #selector(addBtnTapped), for: .touchUpInside)
    }
    @objc func addBtnTapped() {
        isExpanded = !isExpanded
    }
    private func updateCellHeight() {
        let newHeight: CGFloat = isExpanded ? 100 : 50
        frame.size.height = newHeight
        textField.isHidden = !isExpanded
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
