//
//  Router.swift
//  hundredproject
//
//  Created by Duc Tran  on 20/12/24.
//

import SwiftUI
import Combine

final class Router: ObservableObject {
    @Published var navPath = NavigationPath()
    
    func navigate(_ destinations: Destination...) {
        destinations.forEach { destination in
            navPath.append(destination)
        }
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot(isGrand: Bool = false) {
        navPath.removeLast(navPath.count)
    }
    
}
