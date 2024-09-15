//
//  File.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import Foundation
import SocketIO


protocol ChatNetworkManagerDelegate {
    func onConnect(message: String) -> Void
    func onReceiveMessage(message: String) -> Void
    func onDisconnect(message: String) -> Void
    func onTyping(message: String) -> Void
    func onNotTyping() -> Void
}

extension ChatNetworkManagerDelegate {
    func onConnect(message: String) {
        
    }
    func onReceiveMessage(message: String) {
        
    }
    func onDisconnect(message: String) {
        
    }
    func onTyping(message: String) {
        
    }
    func onNotTyping() {
        
    }
}

final class ChatNetworkManager {
    static let instance = ChatNetworkManager()
    
    private let __defaultHost = "http://127.0.0.1:10000/"
    
    private var __host: String? = nil
    
    lazy var connector: ChatSocketIOConnection = {
        return .init(host: self.host)
    }()
    
    var host: String {
        set {
            __host = newValue
        }
        
        get {
            return __host ?? __defaultHost
        }
    }
    
    var delegate: ChatNetworkManagerDelegate?
    
    func checkHost(onFinish: @escaping () -> Void, onError: @escaping () -> Void){
        if let url = URL(string: host + "ping") {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        print(json)
                    }
                    onFinish()
                } catch let error {
                    print(error.localizedDescription)
                    onError()
                }
            }
            task.resume()
        }
    }
    
    func joinOrCreateRoom(
        name: String,
        code: String? = nil,
        join: Bool = false,
        create: Bool = false,
        onFinish: @escaping (String?) -> Void,
        onError: @escaping (String) -> Void) {
        guard let url = URL(string: host + "/room") else {
            onError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "name": name,
            "code": code ?? "",
            "join": join,
            "create": create
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            onError("Failed to create request body")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                onError("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let success = json["success"] as? Bool, success {
                        onFinish(json["room_code"] as? String)
                    } else {
                        onError(json["error_message"] as? String ?? "Unknown error")
                    }
                }
            } catch {
                onError("Failed to parse response")
            }
        }
        task.resume()
    }
    
    func getRoom(room: String, name: String, onFinish: @escaping ([String: Any]) -> Void, onError: @escaping (String) -> Void) {
        guard let url = URL(string: host + "/room") else {
            onError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["room": room, "name": name]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            onError("Failed to create request body")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                onError("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let success = json["success"] as? Bool, success {
                        onFinish(json)
                    } else {
                        onError(json["error_message"] as? String ?? "Unknown error")
                    }
                }
            } catch {
                onError("Failed to parse response")
            }
        }
        task.resume()
    }
    
    func connect(room: String, name: String) {
        self.connector.connect(room: room, name: name)
        if let delegate = self.delegate {
            self.connector.listen(onConnect: delegate.onConnect,
                                  onReceiveMessage: delegate.onReceiveMessage,
                                  onDisconnect: delegate.onDisconnect,
                                  onTyping: delegate.onTyping,
                                  onNotTyping: delegate.onNotTyping)
        }
    }
    
    func disconnect() {
        self.connector.disconnect()
    }
    
    func sendMessage(message: String) {
        self.connector.sendMessage(message: message)
    }
    
    func startTyping() {
        self.connector.startTyping()
    }
    
    func endTyping() {
        self.connector.endTyping()
    }
}
