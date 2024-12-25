//
//  MessageView.swift
//  hundredproject
//
//  Created by Duc Tran  on 13/12/24.
//

import SwiftUI

struct MessageModel: Equatable {
    let isMyMessage: Bool
    let message: String
    let photoURL: String
    let createAt: Date
    let isRed: Bool
}

struct MessageView: View {
    var message: MessageModel
    
    var body: some View {
        HStack {
            if message.isMyMessage {
                Spacer()
            }
            VStack {
                if message.photoURL.isEmpty {
                    Text(message.message)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .foregroundStyle(message.isMyMessage ? .white : .black)
                } else {
                    AsyncImage(url: URL(string: message.photoURL)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 150, maxWidth: 250, minHeight: 150, maxHeight: 300)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 200) // Fixed size for placeholder
                    }
                }
            }.clipShape(BubbleShape(myMessage: message.isMyMessage)).background {
                BubbleShape(myMessage: message.isMyMessage)
                    .fill(message.isMyMessage ? Color.blue : Color.gray.opacity(0.2))
            }.padding(message.isMyMessage ? .trailing : .leading, 15)
            if !message.isMyMessage {
                Spacer()
            }
        }.padding(.horizontal, 10)
    }
}

#Preview {
    VStack {
        MessageView(message: MessageModel(
            isMyMessage: true,
            message: "Hello! This is my message,Hello! This is my message,Hello! This is my message,Hello! This is my message,Hello! This is my message,Hello! This is my message,Hello! This is my messageHello! This is my messageHello! This is my message",
            photoURL: "",
            createAt: Date(),
            isRed: false
        ))
        
        MessageView(message: MessageModel(
            isMyMessage: true,
            message: "",
            photoURL: "https://picsum.photos/id/237/200/300",
            createAt: Date(),
            isRed: false
        ))
        MessageView(message: MessageModel(
            isMyMessage: false,
            message: "",
            photoURL: "https://picsum.photos/id/237/200/300",
            createAt: Date(),
            isRed: false
        ))
        MessageView(message: MessageModel(
            isMyMessage: false,
            message: "Hi! This is a response",
            photoURL: "",
            createAt: Date(),
            isRed: false
        ))
    }
}
