//
//  ContentViewData.swift
//  hundredproject
//
//  Created by Duc Tran  on 9/7/24.
//

import SwiftUI

enum ContentViewData: Identifiable {
    case transitionAndBlur
    case combineView
    case game2048
    case metalLevel1
    case reactiveX1
    case chatUIKit
    case dummy
    
    var buttonName: String {
        switch self {
        case .transitionAndBlur:
            return "Transition And Blur"
        case .combineView:
            return "Combine multi element"
        case .game2048:
            return "2048"
        case .metalLevel1:
            return "Metal lesson 1"
        case .reactiveX1:
            return "Reactive x lesson 1"
        case .chatUIKit:
            return "UIKit chatapp"
        case .dummy:
            return "Dummy page"
        }
    }
    
    @ViewBuilder var childNavigationView: some View {
        switch self {
        case .transitionAndBlur:
            TransitionAndBlur()
        case .combineView:
            if #available(iOS 17.0, *) {
                CombineViewPage()
            } else {
                EmptyView()
            }
        case .chatUIKit:
            UIKitChatApp()
        default:
            EmptyView()
        }
    }
    
    var eventParam: [String: Any] {
        switch self {
        case .transitionAndBlur:
            return [
                "view": "Transition and Blur",
                "view_number": 1
            ]
        case .combineView:
            return [
                "view": "Combined multiple view",
                "view_number": 2
            ]
        case .game2048:
            return [
                "view": "2048",
                "view_number": 3
            ]
        case .metalLevel1:
            return [
                "view": "Metal lesson 1",
                "view_number": 4
            ]
        case .reactiveX1:
            return [
                "view": "Reactive x lesson 1",
                "view_number": 5
            ]
        case .chatUIKit:
            return [
                "view": "UIKit chatapp",
                "view_number": 6
            ]
        default:
            return [:]
        }
    }
    
    var id: Self {
        return self
    }
}
