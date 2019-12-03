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
    let config = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [
            ARSCNDebugOptions.showWorldOrigin,
            ARSCNDebugOptions.showFeaturePoints
        ]
        sceneView.session.run(config)
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tabGestureRecognizer)
    }
    
    @IBAction func play(_ sender: Any) {
        self.addNode()
    }
    
    @IBAction func reset(_ sender: Any) {
        
    }
    
    func addNode(){
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "jf", recursively: false)
        jellyFishNode?.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
//        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
//        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        node.position = SCNVector3(0,0,-1)
//        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didnt touch anything")
        }else{
            let results = hitTest.first!
            let geometry = results.node.geometry
            print(geometry)
        }
        
    }
    
}


