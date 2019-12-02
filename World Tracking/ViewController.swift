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
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        sceneView.session.run(config)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let earth = SCNNode()
        earth.geometry = SCNSphere(radius: 0.2)
        earth.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Earth day")
        earth.geometry?.firstMaterial?.specular.contents = UIImage(named: "Earth Specular")
        earth.geometry?.firstMaterial?.emission.contents = UIImage(named: "Earth Emission")
        earth.geometry?.firstMaterial?.normal.contents = UIImage(named: "Earth Normal")
        earth.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(earth)
        self.sceneView.autoenablesDefaultLighting = true
        let action = SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        earth.runAction(forever)
    }

}


extension Int {
    var degreesToRadians: CGFloat { return CGFloat(Double(self) * .pi/180)}
}
