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
import AVFoundation
import AVKit
import Firebase
import FirebaseDatabase

protocol ChatDelegate: AnyObject {
    func didReceiveNewMessage(_ message: ChatMessage)
    func didSelectChatRoom(_ chatRoomID: String)
}
class ChatViewController: UIViewController, MKMapViewDelegate, AVAudioRecorderDelegate {
    var cart: [Seller: [Product]]?
    var sellerID: String?
    var buyerID: String?
    let tableView = UITableView()
    let messageTextField = UITextField()
    let sendButton = UIButton()
    let voiceButton = UIButton()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFileURL: URL!
    var audioStorageRef: StorageReference!
    var databaseRef: DatabaseReference!
    var audioURL: String?
    var isRecording = false
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
    private var currentImageURL: String?
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = .white
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
            convertCartToImageAndSendMessage(cart: cart)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        chatListDelegate?.didSelectChatRoom(chatRoomID)
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tableView.register(TextCell.self, forCellReuseIdentifier: "textCell")
        tableView.register(ImageCell.self, forCellReuseIdentifier: "imageCell")
        tableView.register(VoiceCell.self, forCellReuseIdentifier: "voiceCell")
        tableView.register(LeftImageCell.self, forCellReuseIdentifier: "leftImageCell")
        tableView.register(LeftVoiceCell.self, forCellReuseIdentifier: "leftVoiceCell")
        tableView.register(LeftTextCell.self, forCellReuseIdentifier: "lefttextCell")
        tableView.rowHeight = UITableView.automaticDimension
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func fetchUserData() {
        FirebaseManager.shared.fetchUserData { [weak self] currentUser in
            guard let self = self else { return }
            if let currentUser = currentUser {
                self.currentUser = currentUser
                self.createOrGetChatRoomDocument()
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
                               let imageURL = documentData?["imageURL"] as? String,
                               let audioURL = documentData?["audioURL"] as? String {
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
                                    imageURL: imageURL,
                                    audioURL: audioURL
                                )
                                self.chatMessages.append(message)
                            }
                            self.chatRoomDocument = document.reference
                            self.chatRoomID = chatRoomID
                            self.startListeningForChatMessages()
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
                   let audioURL = data["audioURL"] as? String,
                   let imageURL = data["imageURL"] as? String {
                    print("Download URL: \(audioURL)")
                    let chatMessage = ChatMessage(text: text, isMe: isMe, timestamp: timestamp, profileImageUrl: profileImageUrl, name: name, chatRoomID: chatRoomID, sellerID: sellerID, buyerID: buyerID, imageURL: imageURL, audioURL: audioURL)
                    self.chatMessages.append(chatMessage)
                }
            }
            self.chatMessages.sort { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
            self.tableView.reloadData()
        }
    }
    private func setupUI() {
        view.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .black
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 100)
        messageTextField.placeholder = "Type your message..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.backgroundColor = .white
        messageTextField.frame = CGRect(x: 130, y: view.bounds.height - 80, width: view.bounds.width - 180, height: 40)
        view.addSubview(messageTextField)
        let imageButton = UIButton(type: .system)
        imageButton.setImage(UIImage(named: "icons8-unsplash-30(@1×)"), for: .normal)
        imageButton.tintColor = .white
        imageButton.setTitleColor(.white, for: .normal)
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
        sendButton.tintColor = .white
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.frame = CGRect(x: view.bounds.width - 50, y: view.bounds.height - 80, width: 50, height: 50)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        let locationButton = UIButton(type: .system)
        locationButton.setImage(UIImage(named: "icons8-map-24(@1×)"), for: .normal)
        locationButton.startAnimatingPressActions()
        locationButton.tintColor = .white
        locationButton.setTitleColor(.white, for: .normal)
        locationButton.frame = CGRect(x: 10, y: view.bounds.height - 80, width: 50, height: 50)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        view.addSubview(locationButton)
        view.addSubview(voiceButton)
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        voiceButton.addTarget(self, action: #selector(voiceButtonTapped), for: .touchUpInside)
        voiceButton.tintColor = .white
        NSLayoutConstraint.activate([
            voiceButton.topAnchor.constraint(equalTo: imageButton.topAnchor),
            voiceButton.leadingAnchor.constraint(equalTo: imageButton.trailingAnchor, constant: -15),
            voiceButton.widthAnchor.constraint(equalToConstant: 50),
            voiceButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        voiceButton.addGestureRecognizer(longPressGesture)
    }
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            startRecording()
        } else if gesture.state == .ended {
            stopRecording()
            uploadAudioToFirebase()
        }
    }
    @objc func voiceButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    @objc func locationButtonTapped() {
        let mapViewController = MapSelectionViewController()
        mapViewController.delegate = self
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
                self?.sendMessageToFirestore(message, isMe: true, imageURL: imageURL, location: nil)
                self?.selectedImage = nil
                self?.imageView.image = nil
                self?.currentImageURL = nil
            }
        } else {
            sendMessageToFirestore(message, isMe: true, location: nil)
        }
        messageTextField.text = ""
        currentLocation = nil
        selectedImage = nil
        imageView.image = nil
        currentImageURL = nil
    }
    func uploadFixedImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        FirebaseManager.shared.uploadImage(image) { storageImageURL in
            completion(storageImageURL)
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
            "imageURL": imageURL ?? "",
            "audioURL": audioURL ?? ""
        ]
        if let location = location {
            let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
            messageData["location"] = geoPoint
            messageData["isLocation"] = true
            let mapLink = "https://maps.apple.com/?q=\(location.latitude),\(location.longitude)"
            messageData["text"] = mapLink
        } else {
            messageData["text"] = message
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
    //修改函數 convertCartToImage 以返回生成的圖像和相應的URL
    func convertCartToImage(cart: [Seller: [Product]], completion: @escaping (UIImage?, String?) -> Void) {
        let imageSize = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil, nil)
            return
        }
        // Set background color
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))
        for (seller, products) in cart {
            // Text attributes for seller's greeting
            let sellerGreetingAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .paragraphStyle: NSParagraphStyle(),
                .foregroundColor: UIColor.white
            ]
            // Seller's greeting text
            let sellerGreeting = "Hi, \(seller.sellerName).\n I'm interested in the following product:"
            (sellerGreeting as NSString).draw(at: CGPoint(x: 20, y: 30), withAttributes: sellerGreetingAttributes)
            var yOffset: CGFloat = 180
            for product in products {
                // Text attributes for product information
                let productAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20),
                    .foregroundColor: UIColor.white
                ]
                // Product information text
                let productText = "   Product: \(product.name)\n   Quantity: \(product.quantity ?? 1)\n   Price: \(product.price)"
                (productText as NSString).draw(at: CGPoint(x: 200, y: yOffset), withAttributes: productAttributes)
                // Fixed image size and position
                let imageRect = CGRect(x: 20, y: 140, width: 150, height: 150)  // Adjust the image size and position
                // Load and draw the product image with rounded corners
                if let imageURL = URL(string: product.imageString) {
                    KingfisherManager.shared.retrieveImage(with: imageURL, options: nil, progressBlock: nil) { result in
                        switch result {
                        case .success(let imageResult):
                            let productImage = imageResult.image
                            let roundedPath = UIBezierPath(roundedRect: imageRect, cornerRadius: 10.0).cgPath
                            context.addPath(roundedPath)
                            context.clip()
                            productImage.draw(in: imageRect)
                            // Notify completion with the generated image and a unique URL
                            let imageUUID = UUID().uuidString
                            let imageURL = "https://your-image-hosting-service.com/\(imageUUID).png"
                            // Store the current image URL
                            self.currentImageURL = imageURL
                            completion(UIGraphicsGetImageFromCurrentImageContext(), imageURL)
                        case .failure(let error):
                            print("Error loading product image: \(error.localizedDescription)")
                            completion(nil, nil)
                        }
                    }
                }
                // Adjust the vertical spacing between product and next product
                yOffset += 90
            }
        }
        // End the graphics context
        UIGraphicsEndImageContext()
        // Set the current image URL to nil after the image is generated
        currentImageURL = nil
    }
    func convertCartToImageAndSendMessage(cart: [Seller: [Product]]) {
        convertCartToImage(cart: cart) { [weak self] image, imageURL in
            // Ensure that the image URL matches the current image URL
            guard let currentImageURL = self?.currentImageURL, currentImageURL == imageURL else {
                // Image URL does not match the current one, ignore the completion
                return
            }
            if let image = image {
                FirebaseManager.shared.uploadImage(image) { storageImageURL in
                    self?.sendMessageToFirestore("", isMe: true, imageURL: storageImageURL, location: nil)
                }
            } else {
                // 處理圖像轉換失敗的情況
            }
        }
    }
}
