//
//  Renderer.swift
//  hundredproject
//
//  Created by Duc Tran  on 26/8/24.
//

import MetalKit

class MetalLesson1Renderer : NSObject, MTKViewDelegate {
    
    var parent: MetalLesson1
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    
    init(_ parent: MetalLesson1) {
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
    }
}
