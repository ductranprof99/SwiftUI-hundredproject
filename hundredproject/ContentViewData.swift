//
//  ContentViewData.swift
//  hundredproject
//
//  Created by Duc Tran  on 9/7/24.
//

import Foundation

enum ContentViewData: Identifiable {
    case transitionAndBlur
    case dummy
    
    var buttonName: String {
        switch self {
        case .transitionAndBlur:
            return "Transition And Blur"
        case .dummy:
            return "Dummy page"
        }
    }
    
    var id: Self {
        return self
    }
}
