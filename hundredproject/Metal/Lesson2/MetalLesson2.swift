//
//  MetalLesson2.swift
//  hundredproject
//
//  Created by Duc Tran  on 8/12/24.
//

import SwiftUI
import MetalKit

struct MetalLesson2: UIViewRepresentable {
    func makeCoordinator() -> RendererLesson2 {
        RendererLesson2(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MetalLesson2>) -> MTKView {
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
    
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<MetalLesson2>) {
    }
}

#Preview {
    MetalLesson2()
}
