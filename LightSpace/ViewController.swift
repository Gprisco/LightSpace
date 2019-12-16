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

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var colorButton: UIButton!
}

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var undoButton: UIButton!
    @IBOutlet var collectionViewBackground: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    var cameraPosition: SCNVector3!
    var viewTouching: Bool! = false
    var selectedColor: UIColor = .red
    var appendedNodes: [SCNNode] = []
    var nodesInScene: [[SCNNode]] = []
    
    let colors: [UIColor] = [
        .black,
        .white,
        .red,
        .yellow,
        .green,
        .brown,
        .cyan,
        .orange,
        .magenta
    ]
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.colorButton.tintColor = self.colors[indexPath.item]
        cell.colorButton.addTarget(self, action: #selector(onColorChange), for: .touchUpInside)
        
        if self.selectedColor == self.colors[indexPath.item] {
            cell.colorButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        }
        else {
            cell.colorButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        }
        
        return cell
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        sceneView.debugOptions = .showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                
                let technique = SCNTechnique(dictionary: dict2)
                
                sceneView.technique = technique
            }
        }
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
        
        collectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        
        collectionViewBackground.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
        collectionViewBackground.layer.cornerRadius = 20.0
        
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.sizeThatFits(CGSize(width: 64.0, height: 64.0))
        
        undoButton.setImage(UIImage(systemName: "arrow.uturn.left"), for: .normal)
        undoButton.tintColor = .white
        undoButton.sizeThatFits(CGSize(width: 64.0, height: 64.0))
        undoButton.isEnabled = false
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

        //Using the + function declared outside this class to execute an addition between 2 vectors
        self.cameraPosition = orientation + location
        
        if self.viewTouching {
            let sphereNode = Sphere(at: sceneSpacePosition(inFrontOf: self.sceneView.pointOfView!, atDistance:0.15), radius: 0.004, color: self.selectedColor)
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            self.appendedNodes.append(sphereNode)
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
        self.nodesInScene.append(self.appendedNodes)
        self.appendedNodes.removeAll()
        self.undoButton.isEnabled = self.nodesInScene.count > 0
    }
    
    @IBAction func onDelete(_ sender: Any) {
        self.sceneView.scene.rootNode.enumerateChildNodes( { (existingNode, _) in
            existingNode.removeFromParentNode()
        })
    }
    
    @IBAction func onUndo(_ sender: UIButton) {
        for node in self.nodesInScene.last! {
            node.removeFromParentNode()
        }
        self.nodesInScene.popLast()!
        self.undoButton.isEnabled = self.nodesInScene.count > 1
    }
    
    @objc func onColorChange(_ sender: UIButton) {
        self.selectedColor = sender.tintColor
        self.collectionView.reloadData()
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
