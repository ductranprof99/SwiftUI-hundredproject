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
    func onNotTyping(message: String) -> Void
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
    func onNotTyping(message: String) {
        
    }
}

final class ChatNetworkManager {
    static let instance = ChatNetworkManager()
    
    private let __defaultHost = "http://127.0.0.1:10000"
    
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
        if let url = URL(string: host + "/ping") {
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
    
    func createRoom(onFinish: @escaping () -> Void, onError: @escaping () -> Void){
        if let url = URL(string: host + "/room") {
            
        }
    }
    
    func getRoom(onFinish: @escaping () -> Void, onError: @escaping () -> Void){
        if let url = URL(string: host + "/room") {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                
            }
            task.resume()
        }
    }
    
    func connect() {
        self.connector.connect()
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
