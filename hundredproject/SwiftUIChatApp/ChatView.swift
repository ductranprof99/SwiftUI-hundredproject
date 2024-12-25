//
//  ChatView.swift
//  hundredproject
//
//  Created by Duc Tran  on 13/12/24.
//

import SwiftUI
import Combine

struct ChatView: View {
    @State private var messages: [MessageModel] = []
    @State private var messagePublisher: PassthroughSubject<[MessageModel], Never> = .init()
    @State private var isLoading = false
    @State private var page = 1
    @Namespace private var bottomID
    let batching = 20
    
    var body: some View {
            if #available(iOS 17.0, *) {
                messageScrollView.onChange(of: messages) {
                    
                }
            } else {
                messageScrollView.onReceive(messagePublisher) { newMessages in
                    
                }
            }
    }
    
    @ViewBuilder var messageScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LoadMoreView().onAppear {
                    loadMoreMessage()
                }
                LazyVStack {
                }
                Color.clear
                    .frame(height: 1)
                    .id(bottomID)
            }.onAppear {
                loadMoreMessage()
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }
    
    func loadMoreMessage() {
        isLoading = true
    }
    
    func updateMessage(newMessages: [MessageModel]) {
        messages.append(contentsOf: newMessages)
        messagePublisher.send(newMessages)
    }
}

#Preview {
    ChatView()
}
