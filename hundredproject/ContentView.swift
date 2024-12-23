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
                $0.childNavigationView
            }
            .navigationTitle("Navigation")
        }.environmentObject(router)
        
    }
}

#Preview {
    ContentView()
}
