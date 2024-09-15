//
//  ChatMessageModels.swift
//  hundredproject
//
//  Created by Duc Tran  on 16/9/24.
//

import MessageKit
import Foundation

struct UserSender: SenderType {
    var senderId: String
    var displayName: String
}

struct ChatMessage: MessageType {
    var sender: any MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
}
