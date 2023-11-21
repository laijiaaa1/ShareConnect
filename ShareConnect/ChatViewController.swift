//
//  ChatViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/19.
//

import UIKit
import FirebaseFirestore

class ChatViewController: UIViewController {
    var cart: [Seller: [Product]]?
    var sellerID: String?
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
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firestore = Firestore.firestore()
        navigationItem.title = "CHATROOM"
        setupUI()
        tableView.separatorStyle = .none
        if let sellerID = sellerID {
            createOrGetChatRoomDocument()
//            startListeningForChatMessages()
        }
        if let cart = cart {
            convertCartToString(cart)
        }
//        sendMessageToFirestore(cartString, isMe: false)
    }
    func createOrGetChatRoomDocument() {
            guard let sellerID = sellerID else {
                print("Seller ID is nil.")
                return
            }

            let chatRoomsCollection = firestore.collection("chatRooms")

            chatRoomsCollection.document(sellerID).getDocument { [weak self] (documentSnapshot, error) in
                if let error = error {
                    print("Error getting chat room document: \(error.localizedDescription)")
                    return
                }

                if let document = documentSnapshot, document.exists {
                    self?.chatRoomDocument = document.reference
                    self?.startListeningForChatMessages()
                    self?.sendMessageToFirestore(self!.cartString, isMe: false)
                } else {
                    chatRoomsCollection.document(sellerID).setData(["createdAt": FieldValue.serverTimestamp()])
                    self?.chatRoomDocument = chatRoomsCollection.document(sellerID)
                    self?.startListeningForChatMessages()
//                    self?.sendMessageToFirestore(self!.cartString, isMe: false)
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
                   let isMe = data["isMe"] as? Bool {
                    let chatMessage = ChatMessage(text: text, isMe: isMe)
                    self.chatMessages.append(chatMessage)
                }
            }

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
                "timestamp": FieldValue.serverTimestamp()
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
                cartString.append("   Quantity: \(product.quantity ?? "1")\n")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatMessageCell
        let chatMessage = chatMessages[indexPath.row]
        
        cell.label.textAlignment = chatMessage.isMe ? .right : .left
        
        cell.label.text = chatMessage.text
        //          cell.backgroundColor = chatMessage.isMe ? .lightGray : .white
        cell.backgroundColor = CustomColors.B1
        cell.label.textColor = chatMessage.isMe ? .black : .black
        cell.label.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}
class ChatMessageCell: UITableViewCell {
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.frame = contentView.bounds
        label.numberOfLines = 0
        label.backgroundColor = UIColor(named: "G1")
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.heightAnchor.constraint(equalToConstant: 200),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ChatMessage {
    let text: String
    let isMe: Bool
}
