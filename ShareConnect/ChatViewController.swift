//
//  ChatViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/19.
//

import UIKit

class ChatViewController: UIViewController, WebSocketManagerDelegate {

    var cart: [Seller: [Product]]?

    let tableView = UITableView()
    let messageTextField = UITextField()
    let sendButton = UIButton()

    var chatMessages = [ChatMessage]()
    let webSocketManager = WebSocketManager()

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        webSocketManager.delegate = self
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
        webSocketManager.send(message: message)
    }

    func sendShoppingCartToSeller() {
        // Check if there is a shopping cart information
        guard let cart = cart else {
            print("Shopping cart is empty.")
            return
        }

        // Convert the shopping cart information to a string
        let cartString = convertCartToString(cart)

        // Get the WebSocket ID of the seller
        guard let sellerWebSocketID = webSocketManager.userWebSocketID else {
            print("Error: Seller WebSocket ID is not set.")
            return
        }

        // Create a message containing the shopping cart information
        let message = "New order: \(cartString)"

        // Use WebSocketManager to send the message to the seller
        webSocketManager.send(message: message, to: sellerWebSocketID)
    }

    // Add this method to convert the cart to a string
    private func convertCartToString(_ cart: [Seller: [Product]]) -> String {
        // Implement your logic to convert the cart to a string
        // For example, you can iterate through the sellers and products and build a formatted string
        // Return a formatted string representation of the cart
        return "Formatted string representation of the cart"
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
          cell.backgroundColor = chatMessage.isMe ? .green : .white
          return cell
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
