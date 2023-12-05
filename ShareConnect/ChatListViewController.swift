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
    var sellerID: String
    var buyerID: String
}

enum CurrentUserRole {
    case seller
    case buyer
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
    var sellerID: String?
    var buyerID: String?
    var chatRoomID: String?
    var chatRoomDocument: DocumentReference?
    var userFetchID = Auth.auth().currentUser!.uid
    var currentUserRole: CurrentUserRole = .seller
    lazy var roleToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Roll Seller", for: .normal)
        button.addTarget(self, action: #selector(toggleRole), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchChatData()
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = .black
    }
    func setupUI() {
        navigationItem.title = "CHAT LIST"
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        view.addSubview(tableView)
        view.addSubview(roleToggleButton)
        roleToggleButton.backgroundColor = .black
        roleToggleButton.setTitleColor(.white, for: .normal)
        roleToggleButton.layer.cornerRadius = 10
        roleToggleButton.clipsToBounds = true
        roleToggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roleToggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roleToggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            roleToggleButton.widthAnchor.constraint(equalToConstant: 320),
            roleToggleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    @objc func toggleRole() {
        if currentUserRole == .seller {
            currentUserRole = .buyer
        } else {
            currentUserRole = .seller
        }
        if currentUserRole == .seller {
            sellerID = Auth.auth().currentUser!.uid
            buyerID = chatRoomDocument?.documentID.contains("buyer") ?? false ? chatRoomDocument?.documentID : ""
        } else {
            buyerID = Auth.auth().currentUser!.uid
            sellerID = chatRoomDocument?.documentID.contains("seller") ?? false ? chatRoomDocument?.documentID : ""
        }
        updateButtonTitle()
        chatItems.removeAll()
        fetchChatData()
    }
    func updateButtonTitle() {
        if currentUserRole == .seller {
            roleToggleButton.setTitle("Switch to Buyer", for: .normal)
        } else {
            roleToggleButton.setTitle("Switch to Seller", for: .normal)
        }
    }
    func fetchChatData() {
        firestore.collection("users").document(userFetchID).getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting user documents: \(error.localizedDescription)")
                return
            }
            if let document = documentSnapshot, document.exists {
                guard let chatRoomIDs = document["chatRooms"] as? [String] else {
                    print("No chatRoomIDs found for the user.")
                    return
                }
                let dispatchGroup = DispatchGroup()
                for chatRoomID in chatRoomIDs {
                    dispatchGroup.enter()
                    self.fetchLatestMessage(for: document.documentID, chatRoomID: chatRoomID) { message in
                        let chatItem = ChatItem(
                            name: document.documentID,
                            time: message.timestamp.description,
                            message: message.text,
                            profileImageUrl: message.profileImageUrl,
                            unreadCount: 1,
                            chatRoomID: chatRoomID,
                            sellerID: message.sellerID,
                            buyerID: message.buyerID
                        )
                        self.chatItems.append(chatItem)
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    func fetchLatestMessage(for userID: String, chatRoomID: String, completion: @escaping (ChatMessage) -> Void) {
        firestore.collection("chatRooms").document(chatRoomID).collection("messages").order(by: "timestamp", descending: true).limit(to: 1).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting latest message: \(error.localizedDescription)")
                return
            }
            guard let document = snapshot?.documents.first else {
                print("No document found for chat room \(chatRoomID)")
                return
            }
            let data = document.data()
            guard let text = data["text"] as? String,
                  let isMe = data["isMe"] as? Bool,
                  let name = data["name"] as? String,
                  let timestampString = data["timestamp"] as? Timestamp,
                  let profileImageUrl = data["profileImageUrl"] as? String,
                  let sellerID = data["seller"] as? String,
                  let buyerID = data["buyer"] as? String,
                  let imageURL = data["imageURL"] as? String else {
                print("Incomplete data in the message document for chat room \(chatRoomID)")
                return
            }
            if (self.currentUserRole == .seller && sellerID == self.sellerID) || (self.currentUserRole == .buyer && buyerID == self.buyerID) {
                let timestamp = timestampString.dateValue()
                let message = ChatMessage(text: text,
                                          isMe: isMe,
                                          timestamp: timestampString,
                                          profileImageUrl: profileImageUrl,
                                          name: name,
                                          chatRoomID: chatRoomID,
                                          sellerID: sellerID,
                                          buyerID: buyerID,
                                          imageURL: imageURL)
                completion(message)
            }
        }
    }
    func didReceiveNewMessage(_ message: ChatMessage) {
        if let existingChatIndex = chatItems.firstIndex(where: { $0.chatRoomID == message.chatRoomID }) {
            chatItems[existingChatIndex].message = message.text
            chatItems[existingChatIndex].time = message.timestamp.description
            chatItems[existingChatIndex].unreadCount += 1
        } else {
            let chatItem = ChatItem(name: message.name,
                                    time: message.timestamp.description,
                                    message: message.text,
                                    profileImageUrl: message.profileImageUrl,
                                    unreadCount: 1, chatRoomID: message.chatRoomID, sellerID: message.sellerID, buyerID: message.buyerID)
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
        cell.nameLabel.text = chatItem.sellerID == Auth.auth().currentUser?.uid ? chatItem.buyerID : chatItem.sellerID
        cell.timeLabel.text = chatItem.time
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
        chatViewController.chatRoomID = chatItem.chatRoomID
        chatViewController.buyerID = chatItem.buyerID
        chatViewController.sellerID = chatItem.sellerID
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    func fetchRoom(chatRoomID: String) {
        firestore.collection("chatRooms").document(chatRoomID).collection("messages").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting chat room documents: \(error.localizedDescription)")
                return
            }
            if let firstDocument = querySnapshot?.documents.first {
                let chatViewController = ChatViewController()
                chatViewController.chatRoomDocument = firstDocument.reference
                chatViewController.chatRoomID = chatRoomID
                chatViewController.buyerID = Auth.auth().currentUser?.uid
                chatViewController.sellerID = firstDocument.get("seller") as? String
                chatViewController.fetchUserData()
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
        messageLabel.text = "message"
        contentView.addSubview(messageLabel)
        messageLabel.textColor = .gray
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 30),
            messageLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: -10),
            messageLabel.widthAnchor.constraint(equalToConstant: 200),
            messageLabel.heightAnchor.constraint(equalToConstant: 20)
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
