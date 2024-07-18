//
//  ContentViewButtonStyle.swift
//  hundredproject
//
//  Created by Duc Tran  on 9/7/24.
//

import SwiftUI

struct ContentViewButtonStyle: ButtonStyle {
    let isDisabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 200, alignment: Alignment.center)
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.white)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(style: StrokeStyle(lineWidth: 2, dash: [1.0])))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
