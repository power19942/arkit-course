//
//  ViewController.swift
//  World Tracking
//
//  Created by opstudios on 12/1/19.
//  Copyright © 2019 opstudios. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var counter = 0.0
    let configuration = ARWorldTrackingConfiguration()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                       ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func add(_ sender: Any) {
        //let cylinderNode = SCNNode(geometry: SCNCylinder(radius: 0.05, height: 0.05))
        //cylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        let doorNode = SCNNode(geometry: SCNPlane(width: 0.03, height: 0.06))
        doorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        let boxNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
//        node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
//        node.geometry = SCNCapsule(capRadius: 0.1/2 ,height: 0.3/2)
//        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.1/4)
        node.geometry = SCNPyramid(width: 0.1, height: 0.08, length: 0.1)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        node.position = SCNVector3(0.0,0.0,-0.2)
        boxNode.position = SCNVector3(0,-0.05,0)
        doorNode.position = SCNVector3(0, 0, 0.06)
        self.sceneView.scene.rootNode.addChildNode(node)
        node.addChildNode(boxNode)
        boxNode.addChildNode(doorNode)
        //self.sceneView.scene.rootNode.addChildNode(cylinderNode)
    }
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    func restartSession(){
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes{(node,_) in
            node.removeFromParentNode()
        }
        
        self.sceneView.session.run(configuration, options: [
            .resetTracking,.removeExistingAnchors
        ])
    }
    
    func randomNumbers(firstNum:CGFloat,secondNum:CGFloat) -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNum - secondNum) +
        min(firstNum,secondNum)
    }


}

