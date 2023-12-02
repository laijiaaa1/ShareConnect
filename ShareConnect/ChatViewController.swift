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
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = .black
    }
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
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
        navigationController?.pushViewController(vc, animated: true)
    }
    // Add a property to keep track of existing chat rooms
    var existingChatRooms: [String: Bool] = [:]

    // ...

    // Modify the createOrGetChatRoomDocument method
    func createOrGetChatRoomDocument() {
        guard let buyerID = buyerID, let sellerID = sellerID else {
            print("Buyer ID or Seller ID is nil.")
            return
        }

        let chatRoomsCollection = firestore.collection("chatRooms")
        let usersCollection = firestore.collection("users")

        // Check both combinations of buyer-to-seller and seller-to-buyer
        let chatRoomID1 = "\(buyerID)_\(sellerID)"
        let chatRoomID2 = "\(sellerID)_\(buyerID)"

        if existingChatRooms[chatRoomID1] == true || existingChatRooms[chatRoomID2] == true {
            // User is already part of the chat room, no need to create a new one
            self.chatRoomID = existingChatRooms[chatRoomID1] == true ? chatRoomID1 : chatRoomID2
            chatRoomsCollection.document(self.chatRoomID).getDocument { [weak self] (documentSnapshot, error) in
                if let error = error {
                    print("Error getting chat room document: \(error.localizedDescription)")
                    return
                }

                if let document = documentSnapshot, document.exists {
                    self?.chatRoomDocument = document.reference
                    self?.startListeningForChatMessages()
                    self?.sendMessageToFirestore(self!.cartString, isMe: true)
                    // add field array for users, add buyer and seller
                    self?.updateUserChatRoomData(usersCollection, userID: buyerID, chatRoomID: self!.chatRoomID)
                    self?.updateUserChatRoomData(usersCollection, userID: sellerID, chatRoomID: self!.chatRoomID)
                } else {
                    print("Error: Existing chat room ID does not correspond to an existing chat room.")
                }
            }
        } else {
            let newChatRoomID = "\(buyerID)_\(sellerID)"
            chatRoomsCollection.document(newChatRoomID).setData(["createdAt": FieldValue.serverTimestamp()])
            self.updateUserChatRoomData(usersCollection, userID: buyerID, chatRoomID: newChatRoomID)
            self.updateUserChatRoomData(usersCollection, userID: sellerID, chatRoomID: newChatRoomID)
            self.chatRoomDocument = chatRoomsCollection.document(newChatRoomID)
            self.startListeningForChatMessages()
            self.sendMessageToFirestore(self.cartString, isMe: true)
            existingChatRooms[newChatRoomID] = true
        }
    }
    func didSelectChatRoom(_ chatRoomID: String) {
        self.chatRoomID = chatRoomID
        createOrGetChatRoomDocument()
    }


    private func updateUserChatRoomData(_ collection: CollectionReference, userID: String, chatRoomID: String) {
        // If the user has a chat room, add the chat room to the user's chat room array.
        // If not, create a new array with the chat room.
        collection.document(userID).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists {
                var userData = document.data() ?? [:]
                
                if var chatRooms = userData["chatRooms"] as? [String] {
                    // User already has chat rooms, add the new chat room
                    chatRooms.append(chatRoomID)
                    userData["chatRooms"] = chatRooms
                } else {
                    // User doesn't have chat rooms, create a new array with the chat room
                    userData["chatRooms"] = [chatRoomID]
                }
                
                // Update the user document with the modified data
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
                   let imageURL = data["imageURL"] as? String{
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
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 200)
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
            imageView.bottomAnchor.constraint(equalTo: tableView.topAnchor),
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
        present(mapViewController, animated: true, completion: nil)
    }
    @objc func imageButtonTapped() {
        present(imagePicker!, animated: true, completion: nil)
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
            "imageURL": imageURL ?? "",
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
            cartString.append("Seller: \(seller.sellerName)\n")
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
        cell.label.textAlignment = chatMessage.isMe ? .right : .left
        cell.label.textColor = chatMessage.isMe ? .black : .black
        cell.label.numberOfLines = 0
        if let imageURL = URL(string: chatMessage.profileImageUrl) {
            cell.image.kf.setImage(with: imageURL)
        }
        if let imageURLpost = URL(string: chatMessage.imageURL ?? "") {
            cell.imageURLpost.kf.setImage(with: imageURLpost)
        }
        cell.nameLabel.text = chatMessage.isMe ? currentUser?.name ?? "User" : currentUser?.name ?? "User"
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        cell.timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
        cell.timestampLabel.textColor = .gray
        cell.timestampLabel.textAlignment = chatMessage.isMe ? .right : .left
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = 60
        let dynamicHeight = calculateDynamicHeight(for: indexPath)
        return max(dynamicHeight, minHeight)
    }
    private func calculateDynamicHeight(for indexPath: IndexPath) -> CGFloat {
        let content = chatMessages[indexPath.row].text
        let font = UIFont.systemFont(ofSize: 17)
        let boundingBox = CGSize(width: tableView.bounds.width - 40, height: .greatestFiniteMagnitude)
        let size = content.boundingRect(with: boundingBox, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(size.height) + 25
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
            contentView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        image.layer.cornerRadius = 15
        timestampLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        image.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        imageURLpost.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            timestampLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            timestampLabel.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
            imageURLpost.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageURLpost.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
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
           } else {
               label.text = chatMessage.text
               label.textColor = .black
               label.isUserInteractionEnabled = false
           }
           if let imageURL = URL(string: chatMessage.imageURL ?? "") {
               image.kf.setImage(with: imageURL)
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
