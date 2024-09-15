//
//  UIKitChatSaveInfo.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import Foundation

final class UIKitChatSaveInfo {
    static let instance = UIKitChatSaveInfo()
    
    var username = ""
    var chatRoom = ""
    
    func clear() -> Bool {
        username = ""
        chatRoom = ""
        return true
    }
    
    func setInfo(username: String, chatRoom: String) -> Bool {
        self.username = username
        self.chatRoom = chatRoom
        return true
    }
}
