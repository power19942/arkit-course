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
    
   
    @IBOutlet weak var planeLabel: UILabel!
    @IBOutlet weak var scene: ARSCNView!
    let config = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scene.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        config.planeDetection = .horizontal
        self.scene.session.run(config)
        self.scene.delegate = self
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.scene.addGestureRecognizer(tapRec)
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let sceneView = sender.view else {
            return
        }
        let touchLocation = sender.location(in: sceneView)
        var hitTestResult = self.scene.hitTest(touchLocation,types:.existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            self.addProtal(hitTest: hitTestResult.first!)
        }
    }
    
    func addProtal(hitTest:ARHitTestResult){
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = (portalScene?.rootNode.childNode(withName: "Portal", recursively: false))!
        let transform = hitTest.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
                
        portalNode.position = SCNVector3(planeXposition, planeYposition, planeZposition)
        self.scene.scene.rootNode.addChildNode(portalNode)
        self.addPlane(nodeName: "roof", portalNode: portalNode, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode, imageName: "bottom")
        self.addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "back")
        self.addWalls(nodeName: "rightWall", portalNode: portalNode, imageName: "sideA")
        self.addWalls(nodeName: "leftWall", portalNode: portalNode, imageName: "sideB")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "sideDoorA")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "sideDoorB")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.planeLabel.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.planeLabel.isHidden = true
        }
    }
    
    func addPlane(nodeName:String,portalNode:SCNNode,imageName:String){
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName)")
        child?.renderingOrder = 200
    }
    
    
    func addWalls(nodeName:String,portalNode:SCNNode,imageName:String){
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName)")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false){
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    

}


