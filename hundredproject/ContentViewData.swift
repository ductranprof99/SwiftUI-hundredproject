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
    case dummy
    
    var buttonName: String {
        switch self {
        case .transitionAndBlur:
            return "Transition And Blur"
        case .combineView:
            return "Combine multi element"
        case .game2048:
            return "2048"
        case .dummy:
            return "Dummy page"
        }
    }
    
    @ViewBuilder var childNavigationView: some View {
        switch self {
        case .transitionAndBlur:
            TransitionAndBlur()
        case .combineView:
            CombineViewPage()
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
        case .dummy:
            return [:]
        }
    }
    
    var id: Self {
        return self
    }
}
