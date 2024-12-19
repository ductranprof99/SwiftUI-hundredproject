//
//  NavigationStackBootcamp.swift
//  hundredproject
//
//  Created by Duc Tran  on 19/12/24.
//

import SwiftUI
import Firebase

struct NavigationStackBootcamp: View {
    @State var path: [String] = []
    let fruits = ["Apple", "Orange", "Banana"]
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 40) {
                    // 1: Navigation link
                    ForEach(0..<10) { x in   // x is Int, hashable type
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
                        path.append(contentsOf: ["hohoho", "Nah", "Young man"])
                    }
                }
            }.navigationDestination(
                for: Int.self /* hasable_type vd: Int.self, String.self 8*/ , // matching 1
                destination: {
                    ChildNavigationStack(value: $0)
                }).navigationDestination(for: String.self,
                                         destination: { strVal in
                    Text(strVal)
                })
        }.onAppear {
            FirebaseEventLogging.shared.loggingScreen(.navigationStack)
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

#Preview {
    NavigationStackBootcamp()
}
