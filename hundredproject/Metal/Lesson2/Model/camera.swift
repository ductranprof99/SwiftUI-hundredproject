//
//  camera.swift
//  hundredproject
//
//  Created by Duc Tran  on 8/12/24.
//

import Foundation

class Camera {
    var position: vector_float3
    var eulers: vector_float3
    
    var vecForwards: vector_float3 = [0.0, 0.0, 0.0]
    var right: vector_float3 = [0.0, 0.0, 0.0]
    var up: vector_float3 = [0.0, 0.0, 0.0]
    
    init(position: vector_float3, eulers: vector_float3) {
        self.position = position
        self.eulers = eulers
    }
    
    func updateVectors() {
        vecForwards = [
            cos(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0),
            sin(eulers[2] * .pi / 180.0) * sin(eulers[1] * .pi / 180.0),
            cos(eulers[1] * .pi / 180.0)
        ]
        
        let globUp: vector_float3 = [0.0, 0.0, 1.0]
        right = simd.cross(globUp, vecForwards)
        up = simd.cross(vecForwards, right)

    }
}
