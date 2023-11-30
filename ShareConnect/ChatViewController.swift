//
//  ChatViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/19.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct User {
    let uid: String
    let name: String
    let email: String
    let profileImageUrl: String
}

class ChatViewController: UIViewController {
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
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
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
        tableView.separatorStyle = .none
        if let sellerID = sellerID {
            createOrGetChatRoomDocument()
        }
        if let cart = cart {
            convertCartToString(cart)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
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

                       // After fetching user data, start listening for chat messages
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
    func createOrGetChatRoomDocument() {
        guard let buyerID = buyerID, let sellerID = sellerID else {
            print("Seller ID is nil.")
            return
        }
        let chatRoomID = "\(buyerID)_\(sellerID)"
        let chatRoomsCollection = firestore.collection("chatRooms")

        chatRoomsCollection.document(chatRoomID).getDocument { [weak self] (documentSnapshot, error) in
            if let error = error {
                print("Error getting chat room document: \(error.localizedDescription)")
                return
            }

            if let document = documentSnapshot, document.exists {
                self?.chatRoomDocument = document.reference
            } else {
                chatRoomsCollection.document(sellerID).setData(["createdAt": FieldValue.serverTimestamp()])
                self?.chatRoomDocument = chatRoomsCollection.document(sellerID)
            }
            self?.startListeningForChatMessages()
            self?.sendMessageToFirestore(self!.cartString, isMe: false)
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
                   let profileImageUrl = data["profileImageUrl"] as? String {
                    let chatMessage = ChatMessage(text: text, isMe: isMe, timestamp: timestamp, profileImageUrl: profileImageUrl, name: name)
                    self.chatMessages.append(chatMessage)
                }
            }

            // Sort messages based on timestamp
            self.chatMessages.sort { $0.timestamp.dateValue() < $1.timestamp.dateValue() }

            self.tableView.reloadData()
        }
    }

    func sendMessageToFirestore(_ message: String, isMe: Bool) {
           guard let chatRoomDocument = chatRoomDocument else {
               print("Chat room document is nil.")
               return
           }
           
           let messagesCollection = chatRoomDocument.collection("messages")
           
           messagesCollection.addDocument(data: [
               "text": message,
               "isMe": isMe,
               "timestamp": FieldValue.serverTimestamp(),
               "name": currentUser?.name,
               "profileImageUrl": currentUser?.profileImageUrl
               // Add other fields as needed
           ]) { [weak self] (error) in
               if let error = error {
                   print("Error sending message: \(error.localizedDescription)")
                   return
               }
               
               self?.tableView.reloadData()
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
        messageTextField.frame = CGRect(x: 20, y: view.bounds.height - 80, width: view.bounds.width - 120, height: 40)
        view.addSubview(messageTextField)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.frame = CGRect(x: view.bounds.width - 90, y: view.bounds.height - 80, width: 60, height: 40)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
    }
    @objc func sendButtonTapped() {
        guard let message = messageTextField.text else { return }
        sendMessageToFirestore(message, isMe: true)
        messageTextField.text = ""
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

           cell.label.text = chatMessage.text
           cell.label.textAlignment = chatMessage.isMe ? .right : .left
           cell.label.textColor = chatMessage.isMe ? .black : .black
           cell.label.numberOfLines = 0

           if let imageURL = URL(string: chatMessage.profileImageUrl) {
               cell.image.kf.setImage(with: imageURL)
           }

           cell.nameLabel.text = chatMessage.isMe ? "Me" : currentUser?.name ?? "Unknown User"

           let formatter = DateFormatter()
           formatter.dateFormat = "HH:mm"
           cell.timestampLabel.text = formatter.string(from: chatMessage.timestamp.dateValue())
           cell.timestampLabel.textColor = .gray
           cell.timestampLabel.textAlignment = chatMessage.isMe ? .right : .left

           return cell
       }
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }
}
class ChatMessageCell: UITableViewCell {
    var label = UILabel()
    var timestampLabel = UILabel()
    var nameLabel = UILabel()
    var image = UIImageView()
    
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
        
        label.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            timestampLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            nameLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            image.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}

struct ChatMessage {
    let text: String
    let isMe: Bool
    let timestamp: Timestamp
    let profileImageUrl: String
    let name: String
}
