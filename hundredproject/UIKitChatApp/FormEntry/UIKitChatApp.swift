//
//  UIKitChatApp.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import SwiftUI
import UIKit

struct UIKitChatApp: View{
    var body: some View {
        ViewControllerWrapper(controller: ChatAppViewController.init())
    }
}

#Preview {
    UIKitChatApp()
}


