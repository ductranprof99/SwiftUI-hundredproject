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
    
    let listView: [Destination] = [
        .transitionAndBlur,
        .combineView,
        .metalLevel1,
        .chatUIKit,
        .chatSwiftUI,
        .navigationBootcampStack
    ]
    
    var body: some View {
        if #available(iOS 18, *) {
            TabView(selection: $router.selectionTab) {
                Tab("numba wan", systemImage: "house.fill", value: ContentTab.home) {
                    tab1
                }
                Tab("numba choo", systemImage: "arcade.stick.and.arrow.up.and.arrow.down", value: ContentTab.sub1) {
                    TabViewNavigate()
                }
            }.environmentObject(router)
        } else {
            TabView(selection: $router.selectionTab) {
                tab1
                    .tag(ContentTab.home)
                    .tabItem {
                        Label(title: {
                            Text("numba wan")
                        }, icon: {
                            Image(systemName: "house.fill")
                        })
                    }
                TabViewNavigate()
                    .tag(ContentTab.sub1)
                    .tabItem {
                        Label(title: {
                            Text("numba choo")
                        }, icon: {
                            Image(systemName: "tray.and.arrow.down.fill")
                        })
                    }
            }.environmentObject(router)
        }
        
    }
    
    @ViewBuilder var tab1: some View {
        NavigationStack(path: $router.navPath) {
            List {
                ForEach(self.listView) { view in
                    NavigationLink(value: view){
                        HStack(alignment: .center) {
                            Spacer()
                            Label(
                                title: { Text(view.buttonName) },
                                icon: { Image(systemName: "flag.2.crossed") }
                            )
                            Spacer()
                        }
                        .frame(height: 40, alignment: .center)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(style: StrokeStyle(lineWidth: 2, dash: [1.0])))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .onTapGesture {
                            FirebaseEventLogging.shared.logging("click", parameters: ["touch": "Tap View inside"])
                        }
                    }
                }
            }.navigationDestination(for: Destination.self) {
                if !$0.isSubView {
                    $0.childNavigationView
                }
            }
            .navigationTitle("Navigation")
        }
    }
}

#Preview {
    ContentView()
}
