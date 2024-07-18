//
//  ContentView.swift
//  hundredproject
//
//  Created by Duc Tran  on 9/7/24.
//

import SwiftUI

struct ContentView: View {
    @State var selection: ContentViewData? = nil
    
    let listView: [ContentViewData] = [
        .transitionAndBlur,
        .dummy,
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(self.listView) { view in
                    NavigationLink {
                        getChildNavigationView(view)
                    } label: {
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
                    }
                }
            }
            .navigationTitle("Navigation")
        }
        
    }
    
    func getChildNavigationView(_ viewData: ContentViewData) -> some View {
        switch viewData {
        case .transitionAndBlur:
            return TransitionAndBlur()
        case .dummy:
            return TransitionAndBlur()
        }
    }
}

#Preview {
    ContentView()
}
