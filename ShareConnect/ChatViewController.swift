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
        tableView.register(TextCell.self, forCellReuseIdentifier: "textCell")
        tableView.register(ImageCell.self, forCellReuseIdentifier: "imageCell")
        tableView.register(MapCell.self, forCellReuseIdentifier: "mapCell")
        tableView.register(VoiceCell.self, forCellReuseIdentifier: "voiceCell")

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
                   let audioURL = data["audioURL"] as? String,
                   let imageURL = data["imageURL"] as? String
                 {
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
        messageTextField.placeholder = "Type your message here..."
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
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func startRecording() {
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                isRecording = true
                updateUIForRecording(true)
            } catch {
                print("錄音失敗")
            }
        }

        func stopRecording() {
            audioRecorder.stop()
            audioRecorder = nil
            isRecording = false
            updateUIForRecording(false)
            audioFileURL = audioFileURL ?? getDocumentsDirectory().appendingPathComponent("recording.wav")
        }

        func updateUIForRecording(_ isRecording: Bool) {
            if isRecording {
                   voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
                   voiceButton.tintColor = .red
               } else {
                   voiceButton.setImage(UIImage(systemName: "mic"), for: .normal)
                   voiceButton.tintColor = .white
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
            }
        } else {
            sendMessageToFirestore(message, isMe: true, location: nil)
        }
        messageTextField.text = ""
        currentLocation = nil
        selectedImage = nil
        imageView.image = nil
    }
    func uploadFixedImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let resizedImage = image.resized(toSize: CGSize(width: 300, height: 300)) else {
            completion("")
            return
        }
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.1) else {
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
    func uploadAudioToFirebase() {
        guard let audioFileURL = audioFileURL else {
               print("Error: audioFileURL is nil.")
               return
           }

           guard let audioData = try? Data(contentsOf: audioFileURL) else {
               print("Error creating audio data.")
               return
           }
let audioStorageRef = Storage.storage().reference().child("audio")
        let audioRef = audioStorageRef.child(UUID().uuidString + ".wav")
        audioRef.putData(audioData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else {
                print("Self is nil.")
                return
            }
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }
            audioRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Unable to get download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.saveAudioMessageToDatabase(downloadURL: downloadURL.absoluteString)
            }
        }
    }
    func saveAudioMessageToDatabase(downloadURL: String) {
        guard let chatRoomDocument = chatRoomDocument else {
            print("Chat room document is nil.")
            return
        }
        let messagesCollection = chatRoomDocument.collection("messages")
        let audioMessage = [
            "text": downloadURL,
            "audioURL": downloadURL,
            "isMe": true,
            "timestamp": FieldValue.serverTimestamp(),
            "name": currentUser?.name ?? "",
            "profileImageUrl": currentUser?.profileImageUrl ?? "",
            "buyer": currentUser?.uid ?? "",
            "seller": buyerID ?? "",
            "chatRoomID": chatRoomID ?? "",
            "imageURL": nil ?? "",
        ] as [String : Any]
        messagesCollection.addDocument(data: audioMessage) { [weak self] (error) in
            if let error = error {
                print("Error sending audio message: \(error.localizedDescription)")
                return
            }
            self?.tableView.reloadData()
        }
    }

}
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }

    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        guard
            let cell = gesture.view?.superview?.superview as? ImageCell,
            let chatMessage = cell.chatMessage,
            let imageUrl = chatMessage.imageURL,
            let originalImage = cell.imageURLpost.image
        else { return }

        let newImageView = UIImageView(image: originalImage)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let promptLabel = UILabel()
        promptLabel.text = "Tap to dismiss"
        promptLabel.textColor = UIColor(named: "G3")
        promptLabel.font = UIFont(name: "PingFangTC", size: 16)
        newImageView.addSubview(promptLabel)
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            promptLabel.bottomAnchor.constraint(equalTo: newImageView.bottomAnchor, constant: -180),
            promptLabel.centerXAnchor.constraint(equalTo: newImageView.centerXAnchor)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleZoomGesture(_:)))
        newImageView.addGestureRecognizer(pinch)

        view.addSubview(newImageView)
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }

    @objc func handleZoomGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }

        if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            view.transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            gestureRecognizer.scale = 1.0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = chatMessages[indexPath.row]
        if chatMessages[indexPath.row].imageURL != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            let chatMessage = chatMessages[indexPath.row]
            cell.backgroundColor = .black
            cell.configure(with: chatMessage)
          
            if let imagePost = URL(string: chatMessage.imageURL ?? "") {
                cell.imageURLpost.kf.setImage(with: imagePost)
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            cell.imageURLpost.addGestureRecognizer(tap)
          
            //            let isMe = chatMessage.buyerID == Auth.auth().currentUser?.uid
            //            if isMe == true {
            cell.timestampLabel.textAlignment = .right
            cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
            cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40).isActive = true
            cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.imageURLpost.leadingAnchor, constant: -20).isActive = true
            cell.imageURLpost.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor, constant: -15).isActive = true
            cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            cell.imageURLpost.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            cell.imageURLpost.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
            cell.imageURLpost.widthAnchor.constraint(equalToConstant: 80).isActive = true
            cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
            cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
            //            } else {
            //                cell.timestampLabel.textAlignment = .left
            //                cell.image.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
            //                cell.image.trailingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40).isActive = true
            //                cell.imageURLpost.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor, constant: 15).isActive = true
            //                cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            //                cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            //                cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            //                cell.timestampLabel.leadingAnchor.constraint(equalTo: cell.imageURLpost.trailingAnchor, constant: 20).isActive = true
            //                cell.imageURLpost.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            //                cell.imageURLpost.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
            //                cell.imageURLpost.widthAnchor.constraint(equalToConstant: 80).isActive = true
            //                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
            //                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
            //            }
            return cell
        } else if chatMessage.audioURL != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "voiceCell", for: indexPath) as! VoiceCell
            cell.backgroundColor = .black
               let audioURL = chatMessage.audioURL
            print("Audio URL: \(audioURL)")
            cell.configure(with: audioURL, chatMessage: chatMessage)
            NSLayoutConstraint.activate([
                cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40),
                cell.image.widthAnchor.constraint(equalToConstant: 30),
                cell.image.heightAnchor.constraint(equalToConstant: 30),
                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor),
                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5),
                cell.backView.heightAnchor.constraint(equalToConstant: 50),
                cell.backView.widthAnchor.constraint(equalToConstant: 200),
                cell.backView.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor,constant: -20),
                cell.backView.topAnchor.constraint(equalTo: cell.image.topAnchor, constant: 5),
                cell.playButton.centerYAnchor.constraint(equalTo: cell.backView.centerYAnchor),
                cell.playButton.leadingAnchor.constraint(equalTo: cell.backView.leadingAnchor, constant: 20),
                cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.backView.bottomAnchor, constant: -5),
                cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.backView.leadingAnchor, constant: -20)
            ])
            cell.backView.backgroundColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? UIColor(named: "G4") : UIColor(named: "G5")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
            let chatMessage = chatMessages[indexPath.row]
            cell.backgroundColor = .black
            cell.configure(with: chatMessage)
            cell.messageLabel.text = chatMessage.text
            cell.messageLabel.textColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .white : .white
            cell.messageLabel.textAlignment = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .center : .center
            //        let isMe = Auth.auth().currentUser?.uid
            //            if isMe == chatMessage.buyerID{
            NSLayoutConstraint.activate([
                cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40),
                cell.messageLabel.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor, constant: -15),
                cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.messageLabel.leadingAnchor, constant: -20),
                cell.image.widthAnchor.constraint(equalToConstant: 30),
                cell.image.heightAnchor.constraint(equalToConstant: 30),
                cell.messageLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5),
                cell.messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 180),
                cell.messageLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
                cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor),
                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5),
            ])
            //            } else {
            //                cell.messageLabel.textAlignment = .left
            //                cell.image.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10).isActive = true
            //                cell.image.trailingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40).isActive = true
            //                cell.messageLabel.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor, constant: 15).isActive = true
            //                cell.timestampLabel.leadingAnchor.constraint(equalTo: cell.messageLabel.trailingAnchor, constant: 20).isActive = true
            //                cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
            //                cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
            //                cell.messageLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
            //                cell.messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
            //                cell.messageLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            //                cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
            //                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
            //                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
            //            }
            
//            cell.messageLabel.backgroundColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? UIColor(named: "G4") : UIColor(named: "G5")

            // 清除或重置 backgroundViewCloud，以防止重複使用時的問題
            for subview in cell.subviews {
                if subview is UIImageView {
                    subview.removeFromSuperview()
                }
            }
            let backgroundViewCloud = UIImageView()
            backgroundViewCloud.contentMode = .scaleToFill
            cell.addSubview(backgroundViewCloud)
            cell.sendSubviewToBack(backgroundViewCloud)
            backgroundViewCloud.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                backgroundViewCloud.topAnchor.constraint(equalTo: cell.messageLabel.topAnchor),
                backgroundViewCloud.leadingAnchor.constraint(equalTo: cell.messageLabel.leadingAnchor, constant: -15),
                backgroundViewCloud.bottomAnchor.constraint(equalTo: cell.messageLabel.bottomAnchor),
                backgroundViewCloud.trailingAnchor.constraint(equalTo: cell.messageLabel.trailingAnchor, constant: 15)
            ])
            if chatMessage.buyerID == Auth.auth().currentUser?.uid {
                backgroundViewCloud.image = UIImage(named: "S3")
            } else {
                backgroundViewCloud.image = UIImage(named: "S1")
            }
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.layer.cornerRadius = 10
            cell.messageLabel.layer.masksToBounds = true
            if let mapLink = cell.messageLabel.text, let url = URL(string: mapLink) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap(_:)))
                cell.messageLabel.isUserInteractionEnabled = true
                cell.messageLabel.addGestureRecognizer(tapGesture)
            }
            return cell
        }
    }
    
    @objc func openMap(_ gesture: UITapGestureRecognizer) {
        //gesture.view 獲取到正確的
        guard let tappedCell = gesture.view as? UILabel, let mapLink = tappedCell.text, let url = URL(string: mapLink) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        return ceil(size.height) + 50
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
