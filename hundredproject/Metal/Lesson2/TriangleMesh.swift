//
//  TriangleMesh.swift
//  hundredproject
//
//  Created by Duc Tran  on 8/12/24.
//

import MetalKit

class TriangleMesh{
    
    let vertexBuffer: MTLBuffer
    
    init(metalDevice: MTLDevice) {
        
        let vertices: [Vertex] = [
            Vertex(color: [1, 0, 0, 1], position: [-1, 0, -1]),
            Vertex(color: [0, 1, 0, 1],position: [1, 0, -1]),
            Vertex(color: [0, 0, 1, 1], position: [0, 0, 1])
        ]
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
    }
}
