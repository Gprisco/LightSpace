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
    
    init(at position: SCNVector3, radius: CGFloat, color: UIColor) {
        self.sphereGeometry = SCNSphere(radius: radius)
        
        //Material Configuration
        let material = SCNMaterial()
        
        material.diffuse.contents = color
        material.diffuse.intensity = 1.0
        material.emission.contents = color
        material.emission.intensity = 0.8
        material.shininess = 1.0
        
        self.sphereGeometry.materials = [material]
        
        super.init()
        
        let sphereNode = SCNNode(geometry: self.sphereGeometry)
        sphereNode.position = position
        
        sphereNode.categoryBitMask = 2
        
        self.addChildNode(sphereNode)
    }
}
