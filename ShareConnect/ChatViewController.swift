//
//  ChatViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/19.
//

import UIKit

class ChatViewController: UIViewController, WebSocketManagerDelegate {

    var cart: [Seller: [Product]]?
    var sellerID: String?
    
    let tableView = UITableView()
    let messageTextField = UITextField()
    let sendButton = UIButton()

    var chatMessages = [ChatMessage]()
    let webSocketManager = WebSocketManager()
    var cartString = ""
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "CHATROOM"
        setupUI()
        webSocketManager.delegate = self
        //anto send message to seller
        if let sellerID = sellerID {
            setUserWebSocketID(sellerID)
        }
        //to send shopping cart to seller
        if let cart = cart {
            sendShoppingCartToSeller()
            sendMessage(cartString)
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

    @objc private func sendButtonTapped() {
        if let message = messageTextField.text, !message.isEmpty {
            sendMessage(message)
            messageTextField.text = ""
        }
    }

    func didReceiveMessage(_ message: String) {
        let chatMessage = ChatMessage(text: message, isMe: false)
        chatMessages.append(chatMessage)
        tableView.reloadData()
    }

    func sendMessage(_ message: String) {
        let chatMessage = ChatMessage(text: message, isMe: true)
        chatMessages.append(chatMessage)
        tableView.reloadData()

        // Get the WebSocket ID of the seller
        guard let sellerWebSocketID = webSocketManager.userWebSocketID else {
            print("Error: Seller WebSocket ID is not set.")
            return
        }
        webSocketManager.send(message: message, to: sellerWebSocketID)
    }
    func setUserWebSocketID(_ sellerID: String){
        webSocketManager.userWebSocketID = sellerID
    }
    func sendShoppingCartToSeller() {
        guard let cart = cart else {
            print("Shopping cart or sellerID is nil.")
            return
        }

        // Get the WebSocket ID of the seller
        guard let sellerWebSocketID = webSocketManager.userWebSocketID else {
            print("Error: Seller WebSocket ID is not set.")
            return
        }

        let cartString = convertCartToString(cart)
        let message = "New order from seller \(sellerWebSocketID): \(cartString)"
        webSocketManager.send(message: message, to: sellerWebSocketID)
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

          // Align user's messages to the right and seller's messages to the left
          cell.label.textAlignment = chatMessage.isMe ? .right : .left

          cell.label.text = chatMessage.text
          cell.backgroundColor = chatMessage.isMe ? .lightGray : .white
          cell.label.textColor = chatMessage.isMe ? .white : .black
        cell.label.numberOfLines = 0
          return cell
      }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

class ChatMessageCell: UITableViewCell {
    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(label)
            label.frame = contentView.bounds
            label.numberOfLines = 0 // Allow multiple lines for long messages
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ChatMessage {
    let text: String
    let isMe: Bool
}
