//
//  ViewController.swift
//  World Tracking
//
//  Created by opstudios on 12/1/19.
//  Copyright © 2019 opstudios. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController , ARSCNViewDelegate{
    
   
    @IBOutlet weak var scene: ARSCNView!
    let config = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scene.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        self.config.planeDetection = .horizontal
        self.scene.session.run(config)
        self.scene.delegate = self

    }
    
    func createLava(planeAnchor:ARPlaneAnchor)-> SCNNode{
        let lavaNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        lavaNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "lava")
        lavaNode.geometry?.firstMaterial?.isDoubleSided = true
        lavaNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        lavaNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        return lavaNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planAnchore = anchor as? ARPlaneAnchor else {
            return
        }
        let lavaNode = createLava(planeAnchor: planAnchore)
        node.addChildNode(lavaNode)
        scene.scene.rootNode.addChildNode(lavaNode)
        print("new flat surface detected")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planAnchore = anchor as? ARPlaneAnchor else {
            return
        }
        node.enumerateChildNodes{(childNode,_) in
            childNode.removeFromParentNode()
        }
        let lavaNode = createLava(planeAnchor: planAnchore)
        node.addChildNode(lavaNode)
        print("update")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        node.enumerateChildNodes{(childNode,_) in
            childNode.removeFromParentNode()
        }
        print("remove")
    }
    

}

extension Int {
    var degreesToRadians: Double {
        return Double(self) * .pi/180
    }
}


