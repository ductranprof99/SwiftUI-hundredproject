//
//  MetalLesson1.swift
//  hundredproject
//
//  Created by Duc Tran  on 26/8/24.
//

import SwiftUI
import MetalKit

struct MetalLesson1: UIViewRepresentable {
    func makeCoordinator() -> MetalLesson1Renderer {
        MetalLesson1Renderer(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MetalLesson1>) -> MTKView {
        let view = MTKView()
        view.delegate = context.coordinator
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            view.device = metalDevice
        }
        
        view.framebufferOnly = false
        view.drawableSize = view.frame.size
        return view
    }
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MetalLesson1>) {
    }
}

#Preview {
    MetalLesson1()
}
