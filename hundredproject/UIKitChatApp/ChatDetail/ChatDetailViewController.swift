//
//  ChatDetailViewController.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import UIKit

final class ChatDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ChatNetworkManager.instance.delegate = self
        ChatNetworkManager.instance.connect(
            room: UIKitChatSaveInfo.instance.chatRoom,
            name: UIKitChatSaveInfo.instance.username
        )
        
    }

    @IBAction func test(_ sender: Any) {
        ChatNetworkManager.instance.sendMessage(message: "asdfsdf")
    }
    
    
}

extension ChatDetailViewController: ChatNetworkManagerDelegate {
    func onTyping(message: String) {
    }
        
    func onConnect(message: String) {
        print(message)
    }
    
    func onDisconnect(message: String) {
    }
    
    func onReceiveMessage(message: String) {
    }
}
