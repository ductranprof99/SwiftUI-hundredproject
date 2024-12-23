//
//  NavigationStackBootcamp.swift
//  hundredproject
//
//  Created by Duc Tran  on 19/12/24.
//

import SwiftUI
import Firebase

struct NavigationStackBootcamp: View {
    @EnvironmentObject var router: Router
    
    let fruits = ["Apple", "Orange", "Banana"]
    
    var body: some View {
            ScrollView {
                VStack(spacing: 40) {
                    // 1: Navigation link
                    ForEach(0..<3) { x in   // x is Int, hashable type
                        NavigationLink(value: x) {
                            Text("Click me: \(x)")
                        }
                    }
                    
                    // 2: Different Hasable
                    ForEach(fruits, id: \.self) { fruit in
                        NavigationLink(value: fruit) {
                            Text("Click fruit: \(fruit)")
                        }
                    }
                    
                    // 3: Path
                    Button("Big Seque") {
                        router.navigate(
                            .simpleoView(text: "null"),
                            .simpleoView(text: "null2")
                        )
                    }
                    
                    Button("imma bec pro") {
                        router.navigateToRoot()
                    }
                }
            }.navigationDestination(
                for: Int.self /* hasable_type vd: Int.self, String.self 8*/ , // matching 1
                destination: {
                    ChildNavigationStack(value: $0)
            }).navigationDestination(for: String.self,
                                     destination: { strVal in
                Text(strVal)
            }).onAppear {
                FirebaseEventLogging.shared.loggingScreen(.navigationBootcampStack)
            }
    }
}

struct ChildNavigationStack: View {
    let value: Int
    
    init(value: Int) {
        self.value = value
        print("INIT Navigation: \(value)")
    }
    
    var body: some View {
        Text("\(value)")
    }
}

#Preview("Default State") {
    NavigationStackBootcamp()
        .environmentObject(Router())
}
