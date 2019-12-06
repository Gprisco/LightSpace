//
//  Sphere.swift
//  LightSpace
//
//  Created by Giovanni Prisco on 06/12/2019.
//  Copyright © 2019 Giovanni Prisco. All rights reserved.
//

import ARKit
import SceneKit

class Sphere: SCNNode {
    let sphereGeometry: SCNSphere
    
    required init?(coder: NSCoder) {
        fatalError("No init.")
    }
    
    init(at position: SCNVector3, radius: CGFloat) {
        self.sphereGeometry = SCNSphere(radius: radius)
        
        super.init()
        
        let sphereNode = SCNNode(geometry: self.sphereGeometry)
        sphereNode.position = position
        
        self.addChildNode(sphereNode)
    }
}
