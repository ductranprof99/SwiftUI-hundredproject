//
//  SocketConnector.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

//
//  SocketConnector.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import Foundation
import SocketIO

final class ChatSocketIOConnection {
    var host: String
    var manager: SocketManager
    var socket: SocketIOClient
    private var room: String?
    private var name: String?
    
    init(host: String) {
        self.host = host
        manager = SocketManager(socketURL: URL(string: self.host)!, config: [.log(true), .compress, .forceWebsockets(true)])
        socket = manager.defaultSocket
    }
    
    func connect(room: String, name: String) {
        self.room = room
        self.name = name
        socket.connect(withPayload: ["room": room, "name": name])
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func listen(
        onConnect: @escaping (String) -> Void,
        onReceiveMessage: @escaping (String, String) -> Void,
        onDisconnect: @escaping (String) -> Void,
        onTyping: @escaping (String) -> Void,
        onNotTyping: @escaping () -> Void
    ) {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self = self, let room = self.room else { return }
            onConnect("Connected to server and joined room: \(room)")
        }
        
        socket.on("message") { data, ack in
            guard let messageData = data[0] as? [String: Any],
                  let name = messageData["name"] as? String,
                  let message = messageData["message"] as? String else {
                return
            }
            onReceiveMessage(name, message)
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            onDisconnect("Disconnected from server")
        }
        
        socket.on("typing") { data, ack in
            guard let typingData = data[0] as? [String: Any],
                  let name = typingData["name"] as? String else {
                return
            }
            onTyping("\(name) is typing...")
        }
        
        socket.on("not_typing") {data, ack in // member typing
            guard data[0] is Double else { return }
            onNotTyping()
        }
    }
    
    func sendMessage(message: String) {
        socket.emit("message", ["data": message])
    }
    
    func startTyping() {
        socket.emit("typing")
    }
    
    func endTyping() {
        socket.emit("not_typing")
    }
}
