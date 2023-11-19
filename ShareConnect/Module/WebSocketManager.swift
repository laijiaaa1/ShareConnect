//
//  WebSocketManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/19.
//

import Foundation
import Starscream

protocol WebSocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

class WebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        print("didReceive event: \(event)")
    }
    weak var delegate: WebSocketManagerDelegate?

    private var socket: WebSocket!
    var userWebSocketID: String?
    
    init() {
        let url = URL(string: "ws://localhost:3000")!
        socket = WebSocket(request: URLRequest(url: url))
        socket.delegate = self
        socket.connect()
    }

    func send(message: String) {
        
           guard let userWebSocketID = userWebSocketID else {
               print("Error: User WebSocket ID is not set.")
               return
           }
        
           let messageToSend = "Message for user \(userWebSocketID): \(message)"
           socket.write(string: messageToSend)
       }
    func send(message: String, to recipientID: String) {
           
              let messageToSend = "Message for user \(recipientID): \(message)"
              socket.write(string: messageToSend)
        
       }

    func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocket connected")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket disconnected with error: \(error?.localizedDescription ?? "Unknown error")")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received message: \(text)")
        delegate?.didReceiveMessage(text)
    }
}
