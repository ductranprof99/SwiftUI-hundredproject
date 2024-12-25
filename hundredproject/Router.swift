//
//  Router.swift
//  hundredproject
//
//  Created by Duc Tran  on 20/12/24.
//

import SwiftUI
import Combine

enum ContentTab {
    case home
    case sub1
    case chatApp
}

final class Router: ObservableObject {
    @Published var navPath = NavigationPath()
    @Published var selectionTab: ContentTab = .home
    
    func navigate(_ destinations: Destination...) {
        destinations.forEach { destination in
            navPath.append(destination)
        }
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
    
}
