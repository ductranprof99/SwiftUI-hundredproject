//
//  UIKitViewWrapper.swift
//  hundredproject
//
//  Created by Duc Tran  on 15/9/24.
//

import SwiftUI

struct ViewControllerWrapper: UIViewControllerRepresentable{
    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerWrapper>) -> UIViewController {
        guard let controller=controller else {
            return UIViewController()
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewControllerWrapper>) {
    }
    let controller:UIViewController?
    typealias UIViewControllerType = UIViewController
}
