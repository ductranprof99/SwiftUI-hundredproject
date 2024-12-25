//
//  TabViewNavigate.swift
//  hundredproject
//
//  Created by Duc Tran  on 23/12/24.
//

import SwiftUI

struct TabViewNavigate: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            VStack {
                Button("Append Router and poproot") {
                    router.navigate(.simpleoView(text: "Another simpleo"))
                }
            }.navigationDestination(for: Destination.self) {
                if case let .simpleoView(text) = $0 {
                    ChildNavigationDemoTabView(text: text)
                }
            }
        }
    }
}

struct ChildNavigationDemoTabView: View {
    @EnvironmentObject var router: Router
    let text: String
    
    var body: some View {
        Button(text) {
            router.navigateToRoot()
            router.selectionTab = .home
        }
    }
}

#Preview {
    TabViewNavigate()
}
