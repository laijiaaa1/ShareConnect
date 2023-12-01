//
//  ChatlistViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct ChatItem {
    var name: String
    var time: String
    var message: String
    var profileImageUrl: String
    var unreadCount: Int
    var chatRoomID: String
}

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatDelegate {
    func didSelectChatRoom(_ chatRoomID: String) {
        let chatViewController = ChatViewController()
        chatViewController.chatRoomID = chatRoomID
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    var chatItems = [ChatItem]()
    var firestore = Firestore.firestore()
    var processedUserIDs = Set<String>()
    let tableView = UITableView()
    var sellerID = ""
    var chatRoomID: String?
    var chatRoomDocument: DocumentReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchChatData()
        tabBarController?.tabBar.isHidden = true
    }

    func setupUI() {
        navigationItem.title = "Chat List"
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        view.addSubview(tableView)
    }
    func fetchChatData() {
           firestore.collection("chatRooms").getDocuments { [weak self] (snapshot, error) in
               guard let self = self else { return }

               if let error = error {
                   print("Error getting chat rooms: \(error.localizedDescription)")
                   return
               }

               if let documents = snapshot?.documents {
                   for document in documents {
                       let userID = document.documentID
                       self.chatItems.append(ChatItem(name: userID, time: "", message: "", profileImageUrl: "", unreadCount: 0, chatRoomID: document.documentID))
                   }
                   for chatItem in self.chatItems {
                       self.fetchLatestMessage(for: chatItem.name)
                   }
               }
           }
       }

    func fetchLatestMessage(for userID: String) {
        firestore.collection("chatRooms").document(userID).collection("messages").order(by: "timestamp", descending: true).limit(to: 1).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting latest message: \(error.localizedDescription)")
                return
            }

            if let document = snapshot?.documents.first {
                let data = document.data()

                if let text = data["text"] as? String,
                   let isMe = data["isMe"] as? Bool,
                   let name = data["name"] as? String,
                   let timestampString = data["timestamp"] as? Timestamp,
                   let profileImageUrl = data["profileImageUrl"] as? String,
                let chatRoomID = data["chatRoomID"] as? String{
                    let timestamp = timestampString.dateValue()
                    let message = ChatMessage(text: text,
                                              isMe: isMe,
                                              timestamp: timestampString,
                                              profileImageUrl: profileImageUrl, name: name, chatRoomID: chatRoomID)
                    self.didReceiveNewMessage(message)
                }
            }
        }
    }

    func didReceiveNewMessage(_ message: ChatMessage) {
        if let existingChatIndex = chatItems.firstIndex(where: { $0.name == message.name }) {
            chatItems[existingChatIndex].message = message.text
            chatItems[existingChatIndex].time = message.timestamp.description
            chatItems[existingChatIndex].unreadCount += 1
        } else {
            let chatItem = ChatItem(name: message.name,
                                    time: message.timestamp.description,
                                    message: message.text,
                                    profileImageUrl: message.profileImageUrl,
                                    unreadCount: 1, chatRoomID: message.chatRoomID)
            chatItems.append(chatItem)
        }

        tableView.reloadData()
    }

    // MARK: - UITableView Data Source and Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as? ChatListCell ?? ChatListCell()
        let chatItem = chatItems[indexPath.row]
        cell.nameLabel.text = chatItem.name
        cell.timeLabel.text = chatItem.time.description
        cell.avatarImageView.kf.setImage(with: URL(string: chatItem.profileImageUrl))
        cell.messageLabel.text = chatItem.message
        cell.unreadLabel.text = "\(chatItem.unreadCount)"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatItem = chatItems[indexPath.row]
        let chatViewController = ChatViewController()
        chatViewController.buyerID = chatItem.chatRoomID
        fetchRoom(chatRoomID: chatItem.chatRoomID)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    func fetchRoom(chatRoomID: String) {
        firestore.collection("chatRooms").document(chatRoomID).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error getting chat room document: \(error.localizedDescription)")
                return
            }

            if let document = documentSnapshot, document.exists {
                self.chatRoomDocument = document.reference

                let chatViewController = ChatViewController()
                chatViewController.buyerID = chatRoomID
                chatViewController.sellerID = Auth.auth().currentUser?.uid
                chatViewController.chatRoomDocument = self.chatRoomDocument
                chatViewController.chatRoomID = chatRoomID
                chatViewController.createOrGetChatRoomDocument()
                self.navigationController?.pushViewController(chatViewController, animated: true)
            } else {
                print("Chat room document does not exist")
            }
        }
    }

}

class ChatListCell: UITableViewCell {
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let messageLabel = UILabel()
    let avatarImageView = UIImageView()
    let unreadLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.text = "name"
        nameLabel.frame = CGRect(x: 10, y: 10, width: 100, height: 20)
        contentView.addSubview(nameLabel)

        timeLabel.text = "time"
        contentView.addSubview(timeLabel)
        timeLabel.textAlignment = .right
        timeLabel.textColor = .gray
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])

        messageLabel.text = "message"
        contentView.addSubview(messageLabel)
        messageLabel.textColor = .gray
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            messageLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            messageLabel.widthAnchor.constraint(equalToConstant: 200),
            messageLabel.heightAnchor.constraint(equalToConstant: 20)
        ])

        contentView.addSubview(avatarImageView)
        avatarImageView.image = UIImage(named: "wait")
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50)
        ])

        contentView.addSubview(unreadLabel)
        unreadLabel.text = "1"
        unreadLabel.textColor = .white
        unreadLabel.backgroundColor = .red
        unreadLabel.layer.cornerRadius = 10
        unreadLabel.layer.masksToBounds = true
        unreadLabel.textAlignment = .center
        unreadLabel.font = UIFont.systemFont(ofSize: 12)
        unreadLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unreadLabel.widthAnchor.constraint(equalToConstant: 20),
            unreadLabel.heightAnchor.constraint(equalToConstant: 20),
            unreadLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            unreadLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
