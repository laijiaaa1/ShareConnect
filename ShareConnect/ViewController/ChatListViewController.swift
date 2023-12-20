//
//  ChatlistViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
        button.setTitle("Roll", for: .normal)
        button.startAnimatingPressActions()
        button.addTarget(self, action: #selector(toggleRole), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        currentUserRole == .seller ? (sellerID = Auth.auth().currentUser!.uid) : (buyerID = Auth.auth().currentUser!.uid)
        fetchChatData()
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = .white
        view.backgroundColor = .black
    }
    func setupUI() {
        navigationItem.title = "CHAT LIST"
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75)
        ])
        tableView.delegate = self
        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        view.addSubview(roleToggleButton)
        roleToggleButton.backgroundColor = UIColor(named: "G3")
        roleToggleButton.setTitleColor(.white, for: .normal)
        roleToggleButton.layer.cornerRadius = 10
        roleToggleButton.clipsToBounds = true
        roleToggleButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roleToggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roleToggleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
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
            chatItems.removeAll()
        } else {
            roleToggleButton.setTitle("Switch to Seller", for: .normal)
            chatItems.removeAll()
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
                            time: message.timestamp.dateValue(),
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
            chatItems[existingChatIndex].time = message.timestamp.dateValue()
            chatItems[existingChatIndex].unreadCount += 1
        } else {
            let chatItem = ChatItem(name: message.name,
                                    time: message.timestamp.dateValue(),
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
        cell.backgroundColor = .black
        let otherUserID = currentUserRole == .seller ? chatItem.buyerID : chatItem.sellerID
        getUserName(for: otherUserID) { userName in
            DispatchQueue.main.async {
                cell.nameLabel.text = userName ?? "User"
                cell.avatarImageView.kf.setImage(with: URL(string: chatItem.profileImageUrl))
                cell.messageLabel.text = chatItem.message
                cell.unreadLabel.text = "\(chatItem.unreadCount)"
                let dateString = chatItem.time
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = dateFormatter.date(from: dateFormatter.string(from: dateString)) {
                    dateFormatter.dateFormat = "HH:mm"
                    let formattedTime = dateFormatter.string(from: date)
                    cell.timeLabel.text = formattedTime
                } else {
                    print("Error converting date string to Date.")
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatItem = chatItems[indexPath.row]
        let chatViewController = ChatViewController()
        chatViewController.chatRoomID = chatItem.chatRoomID
        chatViewController.buyerID = chatItem.buyerID
        chatViewController.sellerID = chatItem.sellerID
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    func getUserName(for userID: String, completion: @escaping (String?) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        let userDocument = usersCollection.document(userID)
        userDocument.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let document = documentSnapshot, document.exists else {
                print("No user found for ID: \(userID)")
                completion(nil)
                return
            }
            if let userName = document["name"] as? String {
                completion(userName)
            } else {
                print("User document does not contain a 'name' field.")
                completion(nil)
            }
        }
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
