//
//  ChatViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import MapKit
import CoreLocation

protocol ChatDelegate: AnyObject {
    func didReceiveNewMessage(_ message: ChatMessage)
    func didSelectChatRoom(_ chatRoomID: String)
}
class ChatViewController: UIViewController, MKMapViewDelegate {
    var cart: [Seller: [Product]]?
    var sellerID: String?
    var buyerID: String?
    let tableView = UITableView()
    let messageTextField = UITextField()
    let sendButton = UIButton()
    var chatMessages = [ChatMessage]()
    var cartString = ""
    var firestore: Firestore = Firestore.firestore()
    var chatRoomDocument: DocumentReference!
    var chatRoomListener: ListenerRegistration!
    var chatRoomID: String!
    var chatRoomMessageListener: ListenerRegistration!
    var seller: Seller?
    var currentUser: User?
    weak var chatListDelegate: ChatDelegate?
    var imagePicker: UIImagePickerController?
    var selectedImage: UIImage?
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    var existingChatRooms: [String: Bool] = [:]
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = .black
    }
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        fetchUserData()
        navigationItem.title = "CHATROOM"
        navigationController?.navigationBar.isHidden = false
        setupUI()
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.allowsEditing = true
        tableView.separatorStyle = .none
        if let cart = cart {
            convertCartToString(cart)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        chatListDelegate?.didSelectChatRoom(chatRoomID)
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        let userCollection = Firestore.firestore().collection("users")
        userCollection.document(userID).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            if let document = documentSnapshot, document.exists {
                let userData = document.data()
                if let uid = document.documentID as? String,
                   let name = userData?["name"] as? String,
                   let email = userData?["email"] as? String,
                   let profileImageUrl = userData?["profileImageUrl"] as? String {
                    self.currentUser = User(uid: uid, name: name, email: email, profileImageUrl: profileImageUrl)
                    self.createOrGetChatRoomDocument()
                }
            } else {
                print("User document does not exist.")
            }
        }
    }
    @objc func addButtonTapped() {
        let vc = ChatSupplyCreateViewController()
        vc.buyer = buyerID
        navigationController?.pushViewController(vc, animated: true)
    }
    func createOrGetChatRoomDocument() {
        guard let buyerID = buyerID, let sellerID = sellerID else {
            print("Buyer ID or Seller ID is nil.")
            return
        }
        let chatRoomsCollection = firestore.collection("chatRooms")
        let usersCollection = firestore.collection("users")
        let sortedUserIDs = [buyerID, sellerID].sorted()
        let chatRoomID = sortedUserIDs.joined(separator: "_")
        var existingChatRoomIDs = Set(existingChatRooms.keys)
        if existingChatRoomIDs.contains(chatRoomID) {
            chatRoomsCollection.document(chatRoomID).getDocument { [weak self] (documentSnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting chat room document: \(error.localizedDescription)")
                    return
                }
                if let document = documentSnapshot, document.exists {
                    self.chatRoomDocument = document.reference
                    self.chatRoomID = chatRoomID
                    self.startListeningForChatMessages()
                    self.sendMessageToFirestore(self.cartString, isMe: true)
                } else {
                    print("Error: Existing chat room ID does not correspond to an existing chat room.")
                }
            }
        } else {
            self.checkIfChatRoomExistsInUser(usersCollection, userID: buyerID, chatRoomID: chatRoomID) { [weak self] exists in
                guard let self = self else { return }
                if exists {
                    chatRoomsCollection.document(chatRoomID).getDocument { [weak self] (documentSnapshot, error) in
                        guard let self = self else { return }
                        if let error = error {
                            print("Error getting chat room document: \(error.localizedDescription)")
                            return
                        }
                        if let document = documentSnapshot, document.exists {
                            let documentData = document.data()
                            if let text = documentData?["text"] as? String,
                               let isMe = documentData?["isMe"] as? Bool,
                               let name = documentData?["name"] as? String,
                               let timestampString = documentData?["timestamp"] as? Timestamp,
                               let profileImageUrl = documentData?["profileImageUrl"] as? String,
                               let chatRoomID = documentData?["chatRoomID"] as? String,
                               let sellerID = documentData?["seller"] as? String,
                               let buyerID = documentData?["buyer"] as? String,
                               let imageURL = documentData?["imageURL"] as? String {
                                let timestamp = timestampString.dateValue()
                                let message = ChatMessage(
                                    text: text,
                                    isMe: isMe,
                                    timestamp: timestampString,
                                    profileImageUrl: profileImageUrl,
                                    name: name,
                                    chatRoomID: chatRoomID,
                                    sellerID: sellerID,
                                    buyerID: buyerID,
                                    imageURL: imageURL
                                )
                                self.chatMessages.append(message)
                            }
                            self.chatRoomDocument = document.reference
                            self.chatRoomID = chatRoomID
                            self.startListeningForChatMessages()
                            self.sendMessageToFirestore(self.cartString, isMe: true)
                        } else {
                            print("Error: Existing chat room ID does not correspond to an existing chat room.")
                        }
                    }
                } else {
                    chatRoomsCollection.document(chatRoomID).setData(["createdAt": FieldValue.serverTimestamp()])
                    self.updateUserChatRoomData(usersCollection, userID: buyerID, chatRoomID: chatRoomID)
                    self.updateUserChatRoomData(usersCollection, userID: sellerID, chatRoomID: chatRoomID)
                    self.chatRoomDocument = chatRoomsCollection.document(chatRoomID)
                    self.startListeningForChatMessages()
                    self.sendMessageToFirestore(self.cartString, isMe: true)
                    self.existingChatRooms[chatRoomID] = true
                    existingChatRoomIDs.insert(chatRoomID)
                }
            }
        }
    }
    func checkIfChatRoomExistsInUser(_ collection: CollectionReference, userID: String, chatRoomID: String, completion: @escaping (Bool) -> Void) {
        collection.document(userID).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let document = documentSnapshot, document.exists {
                if let chatRooms = document["chatRooms"] as? [String], chatRooms.contains(chatRoomID) {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                print("Error: User document does not exist.")
                completion(false)
            }
        }
    }
    func didSelectChatRoom(_ chatRoomID: String) {
        self.chatRoomID = chatRoomID
        createOrGetChatRoomDocument()
    }
    private func updateUserChatRoomData(_ collection: CollectionReference, userID: String, chatRoomID: String) {
        collection.document(userID).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            if let document = documentSnapshot, document.exists {
                var userData = document.data() ?? [:]
                if var chatRooms = userData["chatRooms"] as? [String] {
                    chatRooms.append(chatRoomID)
                    userData["chatRooms"] = chatRooms
                } else {
                    userData["chatRooms"] = [chatRoomID]
                }
                collection.document(userID).setData(userData) { error in
                    if let error = error {
                        print("Error updating user document: \(error.localizedDescription)")
                    } else {
                        print("User document updated successfully.")
                    }
                }
            } else {
                print("Error: User document does not exist.")
            }
        }
    }
    func startListeningForChatMessages() {
        guard let chatRoomDocument = chatRoomDocument else {
            print("Chat room document is nil.")
            return
        }
        let messagesCollection = chatRoomDocument.collection("messages")
        chatRoomMessageListener = messagesCollection.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error listening for chat messages: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No documents in the chat messages collection.")
                return
            }
            self.chatMessages.removeAll()
            for document in documents {
                let data = document.data()
                if let text = data["text"] as? String,
                   let isMe = data["isMe"] as? Bool,
                   let timestamp = data["timestamp"] as? Timestamp,
                   let name = data["name"] as? String,
                   let profileImageUrl = data["profileImageUrl"] as? String,
                   let buyerID = data["buyer"] as? String,
                   let sellerID = data["seller"] as? String,
                   let chatRoomID = data["chatRoomID"] as? String,
                   let imageURL = data["imageURL"] as? String {
                    let chatMessage = ChatMessage(text: text, isMe: isMe, timestamp: timestamp, profileImageUrl: profileImageUrl, name: name, chatRoomID: chatRoomID, sellerID: sellerID, buyerID: buyerID, imageURL: imageURL)
                    self.chatMessages.append(chatMessage)
                }
            }
            self.chatMessages.sort { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
            self.tableView.reloadData()
        }
    }
    private func setupUI() {
        view.backgroundColor = CustomColors.B1
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = CustomColors.B1
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 100)
        messageTextField.placeholder = "Type your message here..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.backgroundColor = .white
        messageTextField.frame = CGRect(x: 100, y: view.bounds.height - 80, width: view.bounds.width - 140, height: 40)
        view.addSubview(messageTextField)
        let imageButton = UIButton(type: .system)
        imageButton.setImage(UIImage(named: "icons8-unsplash-30(@1×)"), for: .normal)
        imageButton.tintColor = .black
        imageButton.setTitleColor(.black, for: .normal)
        imageButton.frame = CGRect(x: 50, y: view.bounds.height - 80, width: 50, height: 50)
        imageButton.addTarget(self, action: #selector(imageButtonTapped), for: .touchUpInside)
        view.addSubview(imageButton)
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = .black
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.frame = CGRect(x: view.bounds.width - 50, y: view.bounds.height - 80, width: 50, height: 50)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        let locationButton = UIButton(type: .system)
        locationButton.setImage(UIImage(named: "icons8-map-24(@1×)"), for: .normal)
        locationButton.tintColor = .black
        locationButton.setTitleColor(.black, for: .normal)
        locationButton.frame = CGRect(x: 10, y: view.bounds.height - 80, width: 50, height: 50)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        view.addSubview(locationButton)
    }
    @objc func locationButtonTapped() {
        let mapViewController = MapSelectionViewController()
        mapViewController.delegate = self
//        mapViewController.modalPresentationStyle = .fullScreen
//        present(mapViewController, animated: true, completion: nil)
        navigationController?.pushViewController(mapViewController, animated: true)
        
    }
    @objc func imageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                imagePicker.sourceType = .camera
                self?.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        let galleryAction = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            imagePicker.sourceType = .photoLibrary
            self?.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(galleryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    @objc func sendButtonTapped() {
        guard let message = messageTextField.text else { return }
        if let selectedImage = selectedImage {
            uploadFixedImage(selectedImage) { [weak self] (imageURL) in
                self?.sendMessageToFirestore(message, isMe: true, imageURL: imageURL, location: self?.currentLocation)
                self?.selectedImage = nil
                self?.imageView.image = nil
            }
        } else {
            sendMessageToFirestore(message, isMe: true, location: currentLocation)
        }
        messageTextField.text = ""
        currentLocation = nil
        selectedImage = nil
        imageView.image = nil
    }
    func uploadFixedImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let resizedImage = image.resized(toSize: CGSize(width: 50, height: 50)) else {
            completion("")
            return
        }
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            completion("")
            return
        }
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                print("Error uploading image: \(error?.localizedDescription ?? "")")
                completion("")
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "")")
                    completion("")
                    return
                }
                completion(downloadURL.absoluteString)
            }
        }
    }
    func sendMessageToFirestore(_ message: String, isMe: Bool, imageURL: String? = nil, location: CLLocationCoordinate2D? = nil) {
        guard let chatRoomDocument = chatRoomDocument else {
            print("Chat room document is nil.")
            return
        }
        let messagesCollection = chatRoomDocument.collection("messages")
        var messageData: [String: Any] = [
            "text": message,
            "isMe": isMe,
            "timestamp": FieldValue.serverTimestamp(),
            "name": currentUser?.name ?? "",
            "profileImageUrl": currentUser?.profileImageUrl ?? "",
            "buyer": currentUser?.uid ?? "",
            "seller": buyerID ?? "",
            "chatRoomID": chatRoomID ?? "",
            "imageURL": imageURL ?? ""
        ]
        if let location = location {
            let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
            messageData["location"] = geoPoint
            messageData["isLocation"] = true
            let mapLink = "https://maps.apple.com/?q=\(location.latitude),\(location.longitude)"
            messageData["text"] = mapLink
        }
        messagesCollection.addDocument(data: messageData) { [weak self] (error) in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
            self?.tableView.reloadData()
        }
    }
    func sendLocationToFirestore(_ coordinate: CLLocationCoordinate2D) {
        guard let chatRoomDocument = chatRoomDocument else {
            print("Chat room document is nil.")
            return
        }
        let location = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        sendMessageToFirestore("\(location)", isMe: true, location: coordinate)
    }
    func convertCartToString(_ cart: [Seller: [Product]]) -> String {
        for (seller, products) in cart {
            cartString.append("Talk with: \(seller.sellerName)\n")
            for product in products {
                cartString.append(" - Product: \(product.name)\n")
                cartString.append("   Quantity: \(product.quantity ?? 1)\n")
                cartString.append("   Price: \(product.price)\n")
            }
            cartString.append("\n")
        }
        return cartString
    }
}
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatMessageCell
        let chatMessage = chatMessages[indexPath.row]
        cell.backgroundColor = CustomColors.B1
        cell.configure(with: chatMessage)
        cell.label.text = chatMessage.text
        //        cell.label.textAlignment = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .right : .left
        cell.label.textColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .black : .white
        cell.label.backgroundColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? UIColor(named: "G1") : UIColor(named: "G2")
        cell.label.numberOfLines = 0
        cell.label.layer.cornerRadius = 10
        cell.label.layer.masksToBounds = true
        if let imageURL = URL(string: chatMessage.profileImageUrl) {
            cell.image.kf.setImage(with: imageURL)
            let isMe = chatMessage.buyerID == Auth.auth().currentUser?.uid
            if chatMessage.isMe == true {
                cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
                cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40).isActive = true
                cell.image.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
                cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
                cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
                cell.label.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor, constant: -15).isActive = true
                cell.label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
                cell.label.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
                cell.label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10).isActive = true
                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
                cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.label.leadingAnchor, constant: -20).isActive = true
                cell.timestampLabel.topAnchor.constraint(equalTo: cell.label.bottomAnchor, constant: -5).isActive = true
                cell.imageURLpost.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor, constant: -10).isActive = true
            } else {
                cell.image.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
                cell.image.trailingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40).isActive = true
                cell.image.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
                cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
                cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
                cell.label.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor, constant: 15).isActive = true
                cell.label.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
                cell.label.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
                cell.label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -10).isActive = true
                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
                cell.timestampLabel.leadingAnchor.constraint(equalTo: cell.label.trailingAnchor, constant: 20).isActive = true
                cell.timestampLabel.topAnchor.constraint(equalTo: cell.label.bottomAnchor, constant: -5).isActive = true
                cell.imageURLpost.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor, constant: 10).isActive = true
            }
        }
        if let imageURLpost = URL(string: chatMessage.imageURL ?? "") {
            cell.imageURLpost.kf.setImage(with: imageURLpost)
        }
        cell.nameLabel.text = chatMessage.buyerID == Auth.auth().currentUser?.uid ? currentUser?.name ?? "Buyer" : seller?.sellerName ?? "Seller"
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        cell.timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
        cell.timestampLabel.textColor = .gray
        //        cell.timestampLabel.textAlignment = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .right : .left
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = 80
        let dynamicHeight = calculateDynamicHeight(for: indexPath)
        return max(dynamicHeight, minHeight)
    }
    private func calculateDynamicHeight(for indexPath: IndexPath) -> CGFloat {
        let content = chatMessages[indexPath.row].text
        let font = UIFont.systemFont(ofSize: 15)
        let boundingBox = CGSize(width: tableView.bounds.width - 40, height: .greatestFiniteMagnitude)
        let size = content.boundingRect(with: boundingBox, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(size.height) + 35
    }
}
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            imageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            imageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
class ChatMessageCell: UITableViewCell {
    var label = UILabel()
    var timestampLabel = UILabel()
    var nameLabel = UILabel()
    var image = UIImageView()
    var imageURLpost = UIImageView()
    var chatMessage: ChatMessage?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.addSubview(label)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(image)
        contentView.addSubview(imageURLpost)
        contentView.backgroundColor = CustomColors.B1
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        image.layer.cornerRadius = 15
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        image.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        imageURLpost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageURLpost.widthAnchor.constraint(equalToConstant: 80),
            imageURLpost.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    func configure(with chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
        if chatMessage.isLocation ?? true, !chatMessage.text.isEmpty {
            label.text = "📍 Location"
            label.textColor = .blue
            label.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap(_:)))
            label.addGestureRecognizer(tapGesture)
        } else if let imageURL = URL(string: chatMessage.imageURL ?? "") {
            image.kf.setImage(with: imageURL)
        } else {
            label.text = chatMessage.text
            label.textColor = .black
            label.isUserInteractionEnabled = false
        }
    }
    @objc func openMap(_ gesture: UITapGestureRecognizer) {
        guard let mapLink = chatMessage?.text, let url = URL(string: mapLink) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
extension ChatViewController: MapSelectionDelegate {
    func didSelectLocation(_ coordinate: CLLocationCoordinate2D) {
        sendLocationToFirestore(coordinate)
    }
}

extension ChatViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        currentLocation = location
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
