//
//  Glow.swift
//  LightSpace
//
//  Created by Giovanni Prisco on 11/12/2019.
//  Copyright © 2019 Giovanni Prisco. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

extension ViewController {
    public func addGlowTechnique(node: SCNNode, sceneView: ARSCNView) {
        node.categoryBitMask = 2;
        
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                
                let technique = SCNTechnique(dictionary: dict2)
                
                sceneView.technique = technique
            }
        }
    }
}
