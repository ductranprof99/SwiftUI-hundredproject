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
    
    lazy var socket: SocketIOClient = {
        let manager = SocketManager(socketURL: URL(string: self.host)!, config: [.log(true), .compress])
        let socket = manager.defaultSocket
        return socket
    }()
    
    init(host: String) {
        self.host = host
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func listen(
        onConnect: @escaping(String) -> Void,
        onReceiveMessage: @escaping(String) -> Void,
        onDisconnect: @escaping(String) -> Void,
        onTyping: @escaping(String) -> Void,
        onNotTyping: @escaping(String) -> Void
    ) {
        socket.on("message") {data, ack in
            guard data[0] is Double else { return }
            onReceiveMessage("")
        }
        socket.on("connect") {data, ack in // new member in chat room thingies
            guard data[0] is Double else { return }
            onConnect("")
        }
        socket.on("disconnect") {data, ack in // new member leave
            guard data[0] is Double else { return }
            onDisconnect("")
        }
        socket.on("typing") {data, ack in // member typing
            guard data[0] is Double else { return }
            onTyping("")
        }
        socket.on("not_typing") {data, ack in // member typing
            guard data[0] is Double else { return }
            onNotTyping("")
        }
    }
    
    func sendMessage(message: String) {
        socket.emit("message", ["message": message])
    }
    
    func startTyping() {
        socket.emit("typing")
    }
    
    func endTyping() {
        socket.emit("not_typing")
    }
}
