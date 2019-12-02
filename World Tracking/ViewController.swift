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

        let earth = planet(geometry: SCNSphere(radius: 0.2), position: SCNVector3(1.0,0,0),diffuse: "Earth day", specular: "Earth Specular", emission: "Earth Emission", normal: "Earth Normal")
        
        let venus = planet(geometry: SCNSphere(radius: 0.15), position: SCNVector3(-1.2,0,0),diffuse: "Venus Atmosphere", specular: "", emission: "Venus Serface", normal: "String")
        
        let sun = planet(geometry: SCNSphere(radius: 0.35), position: SCNVector3(0,0,-1),diffuse: "Sun diffuse", specular: "Sun Atmosphere", emission: "String", normal: "String")
        //self.sceneView.scene.rootNode.addChildNode(earth)
        self.sceneView.scene.rootNode.addChildNode(sun)
        sun.addChildNode(earth)
        sun.addChildNode(venus)
        self.sceneView.autoenablesDefaultLighting = true
        let action = SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        earth.runAction(forever)
        venus.runAction(forever)
        sun.runAction(forever)
    }
    
    func planet(geometry:SCNGeometry,position:SCNVector3,diffuse:String,specular:String,emission:String,normal:String) -> SCNNode {
        let planet = SCNNode()
        planet.geometry = geometry
        planet.geometry?.firstMaterial?.diffuse.contents = getImage(named: diffuse)
        planet.geometry?.firstMaterial?.specular.contents = getImage(named: specular)
        planet.geometry?.firstMaterial?.emission.contents = getImage(named: emission)
        planet.geometry?.firstMaterial?.normal.contents = getImage(named: normal)
        planet.position = position
        return planet
    }
    
    func getImage(named:String) -> UIImage? {
        return UIImage(named: named)
    }

}


extension Int {
    var degreesToRadians: CGFloat { return CGFloat(Double(self) * .pi/180)}
}
