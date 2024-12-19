//
//  renderScence.swift
//  hundredproject
//
//  Created by Duc Tran  on 8/12/24.
//

import Foundation

class RenderScene {
    var player: Camera
    var triangles: [SimpleComponent]
    
    init() {
        player = .init(position: [1.0, 2.0, 1.0],
                       eulers: [0, 90.0, 315.0])
        triangles = [
            .init(position: [3.0, 0.0, 0.0],
                  eulers: [0.0, 0.0, 0.0])
        ]
    }
    
    func update() {
        player.updateVectors()
        for triangle in triangles {
            triangle.eulers.x += 0.01
            if triangle.eulers.x > 360 {
                triangle.eulers.x -= 360
            }
        }
    }
}
