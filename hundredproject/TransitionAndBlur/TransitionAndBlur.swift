//
//  TransitionAndBlur.swift
//  hundredproject
//
//  Created by Duc Tran  on 17/7/24.
//

import SwiftUI

struct TransitionAndBlur: View {
    @State var show = false
    var body: some View {
        VStack {
            
            Text("Transition and blur")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(TintShapeStyle())
                .tint(.red)
            
            SlipperCard(isAllowClick: $show)
                .frame(width: show ? 400 : 300,
                       height: show ? 600 : 300)
                .clipped()
                .blur(radius: show ? 0 : 30)
                .opacity(self.show ? 0.9 : 0.3)
                .shadow(radius: 10)
                .animation(.spring, value: 30)
            
            Button(action: {
                withAnimation {
                    self.show.toggle()
                }
            }) {
                if self.show {
                   Text("Hide")
                } else {
                    Text("Show")
                }
            }
        }
    }
}

#Preview {
    TransitionAndBlur()
}
