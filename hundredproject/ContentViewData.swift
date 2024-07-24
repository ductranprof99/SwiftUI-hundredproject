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
    case dummy
    
    var buttonName: String {
        switch self {
        case .transitionAndBlur:
            return "Transition And Blur"
        case .combineView:
            return "Combine multi element"
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
        case .dummy:
            EmptyView()
        }
    }
    
    var id: Self {
        return self
    }
}
