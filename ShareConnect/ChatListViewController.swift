//
//  ChatlistViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import FirebaseCore

struct ChatItem {
    var name: String
    var time: String
    var message: String
    var avatarName: String
    var unreadCount: Int
}

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    var chatItems = [ChatItem(name: "name", time: "time", message: "message", avatarName: "wait", unreadCount: 1)]
//
//    //fack data
//    func fackData() {
//        for i in 0...10 {
//            let chatItem = ChatItem(name: "name\(i)", time: "time\(i)", message: "message\(i)", avatarName: "wait", unreadCount: i)
//            chatItems.append(chatItem)
//        }
//    }
    var chatItems = [ChatItem]()
    var buyerID: String?
    var sellerID: String?
    var chatRoomID: String?
    let firestore = Firestore.firestore()
    func fetchChatRooms() {
           let chatRoomsCollection = firestore.collection("chatRooms")
           
           // Fetch chat room documents for buyers
           chatRoomsCollection.whereField("buyerID", isEqualTo: buyerID).getDocuments { [weak self] (querySnapshot, error) in
               self?.processFetchedChatRooms(querySnapshot, error)
           }

           // Fetch chat room documents for sellers
           chatRoomsCollection.whereField("sellerID", isEqualTo: sellerID).getDocuments { [weak self] (querySnapshot, error) in
               self?.processFetchedChatRooms(querySnapshot, error)
           }
       }

       func processFetchedChatRooms(_ querySnapshot: QuerySnapshot?, _ error: Error?) {
           guard let snapshot = querySnapshot, error == nil else {
               print("Error fetching chat rooms: \(error?.localizedDescription ?? "")")
               return
           }

           for document in snapshot.documents {
               let chatRoom = document.data()
               let name = chatRoom["name"] as? String ?? ""
               let time = chatRoom["time"] as? String ?? ""
               let message = chatRoom["message"] as? String ?? ""
               let avatarName = chatRoom["avatarName"] as? String ?? ""
               let unreadCount = chatRoom["unreadCount"] as? Int ?? 0
               let buyerID = chatRoom["buyerID"] as? String ?? ""
               let sellerID = chatRoom["sellerID"] as? String ?? ""

               let chatItem = ChatItem(name: name, time: time, message: message, avatarName: avatarName, unreadCount: unreadCount)
               self.chatItems.append(chatItem)
           }

           // Reload table view data after fetching chat rooms
           self.tableView.reloadData()
       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as? ChatListCell ?? ChatListCell()
        let chatItem = chatItems[indexPath.row]
           cell.nameLabel.text = chatItem.name
           cell.timeLabel.text = chatItem.time
           cell.messageLabel.text = chatItem.message
           cell.avatarImageView.image = UIImage(named: chatItem.avatarName)
           cell.unreadLabel.text = "\(chatItem.unreadCount)"
           
           return cell
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 150
//    }
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat List"
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")

        fetchChatRooms()
        view.addSubview(tableView)
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
        nameLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
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
        avatarImageView.layer.cornerRadius = 20
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
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
