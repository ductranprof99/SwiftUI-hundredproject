//
//  ContentView.swift
//  hundredproject
//
//  Created by Duc Tran  on 9/7/24.
//

import SwiftUI

struct ContentView: View {
    @State var selection: Destination? = nil
    @ObservedObject var router = Router()

    var body: some View {
        if #available(iOS 18, *) {
            TabView(selection: $router.selectionTab) {
                Tab("numba wan", systemImage: "house.fill", value: ContentTab.home) {
                    tabHome
                }
                Tab("numba choo", systemImage: "arcade.stick.and.arrow.up.and.arrow.down", value: ContentTab.sub1) {
                    tab2
                }
                Tab("Chat", systemImage: "message.circle", value: ContentTab.chatApp) {
                    tabChat
                }
            }.environmentObject(router)
        } else {
            TabView(selection: $router.selectionTab) {
                tabHome
                tab2
                tabChat
            }.environmentObject(router)
        }
        
    }
    
    @ViewBuilder var tabHome: some View {
        NavigationStack(path: $router.navPath) {
            if #available(iOS 18, *) {
                HomeTabViewMain()
            } else {
                HomeTabViewMain()
                    .tag(ContentTab.home)
                    .tabItem {
                        Label(title: {
                            Text("numba wan")
                        }, icon: {
                            Image(systemName: "house.fill")
                        })
                    }
            }
        }
    }
    
    @ViewBuilder var tab2: some View {
        NavigationStack(path: $router.navPath) {
            if #available(iOS 18, *) {
                TabViewNavigate()
            } else {
                TabViewNavigate()
                    .tag(ContentTab.sub1)
                    .tabItem {
                        Label(title: {
                            Text("numba choo")
                        }, icon: {
                            Image(systemName: "tray.and.arrow.down.fill")
                        })
                    }
            }
        }
    }

    @ViewBuilder var tabChat: some View {
        NavigationStack(path: $router.navPath) {
            if #available(iOS 18, *) {
                ChatView()
            } else {
                ChatView()
                    .tag(ContentTab.chatApp)
                    .tabItem {
                        Label(title: {
                            Text("numba choo")
                        }, icon: {
                            Image(systemName: "message.circle")
                        })
                    }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
