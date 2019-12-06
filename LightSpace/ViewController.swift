//
//  ViewController.swift
//  LightSpace
//
//  Created by Giovanni Prisco on 06/12/2019.
//  Copyright © 2019 Giovanni Prisco. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var cameraPosition: SCNVector3!
    var viewTouching: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.touchesBegan([UITouch()], with: nil)
        sceneView.touchesEnded([UITouch()], with: nil)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pov = sceneView.pointOfView else { return }
        
        let transform = pov.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)

        //Using the + function declared outside this class
        self.cameraPosition = orientation + location
        
        print(cameraPosition!)
        
        if self.viewTouching {
            let sphereNode = Sphere(at: sceneSpacePosition(inFrontOf: self.sceneView.pointOfView!, atDistance: 1.0), radius: 0.02)
            sceneView.scene.rootNode.addChildNode(sphereNode)
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.viewTouching.toggle()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.viewTouching.toggle()
    }
}

//function to sum 2 vectors
func +(lhv: SCNVector3, rhv: SCNVector3) -> SCNVector3 {
     return SCNVector3(lhv.x + rhv.x, lhv.y + rhv.y, lhv.z + rhv.z)
}

//Calculate the position in space based on the given point of view
func sceneSpacePosition(inFrontOf node: SCNNode, atDistance distance: Float) -> SCNVector3 {
    let localPosition = SCNVector3(x: 0, y: 0, z: -distance)
    let scenePosition = node.convertPosition(localPosition, to: nil)
    // to: nil is automatically scene space
    return scenePosition
}
