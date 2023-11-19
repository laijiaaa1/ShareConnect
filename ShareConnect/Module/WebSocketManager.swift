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
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        }
    }
    weak var delegate: WebSocketManagerDelegate?
    
    private var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()
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
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}
