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
    
    func setInfo(username: String? = nil, chatRoom: String? = nil) -> Bool {
        guard username != nil || chatRoom != nil else { return false }
        if username != nil {
            self.username = username!
        }
        if chatRoom != nil {
            self.chatRoom = chatRoom!
        }
        return true
    }
}
