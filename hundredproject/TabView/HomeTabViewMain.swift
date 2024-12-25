//
//  HomeTabViewMain.swift
//  hundredproject
//
//  Created by Duc Tran  on 25/12/24.
//

import SwiftUI

struct HomeTabViewMain: View {
    @EnvironmentObject var router: Router
    
    let listView: [Destination] = [
        .transitionAndBlur,
        .combineView,
        .metalLevel1,
        .chatUIKit,
        .chatSwiftUI,
        .navigationBootcampStack
    ]
    
    
    var body: some View {
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

#Preview {
    HomeTabViewMain()
}
