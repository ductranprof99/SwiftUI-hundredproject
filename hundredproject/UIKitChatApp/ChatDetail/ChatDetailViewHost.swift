//
//  ChatDetailViewHost.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import SwiftUI

struct ChatDetailViewHost: View {
    
    var body: some View {
        ViewControllerWrapper(controller: ChatDetailViewController.init())
    }
}

#Preview {
    ChatDetailViewHost()
}
