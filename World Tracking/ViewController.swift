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
        
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        
        earthParent.position = SCNVector3(0,0,-1)
        venusParent.position = SCNVector3(0,0,-1)

        let earth = planet(geometry: SCNSphere(radius: 0.2), position: SCNVector3(0.9,0,0),diffuse: "Earth day", specular: "Earth Specular", emission: "Earth Emission", normal: "Earth Normal")
        
        let moon = planet(geometry: SCNSphere(radius: 0.05), position: SCNVector3(0.5,0,0),diffuse: "Moon", specular: "", emission: "", normal: "")
        
        let venus = planet(geometry: SCNSphere(radius: 0.15), position: SCNVector3(-0.9,0,0),diffuse: "Venus Atmosphere", specular: "", emission: "Venus Serface", normal: "String")
        
        let sun = planet(geometry: SCNSphere(radius: 0.35), position: SCNVector3(0,0,-1),diffuse: "Sun diffuse", specular: "Sun Atmosphere", emission: "String", normal: "String")
        //self.sceneView.scene.rootNode.addChildNode(earth)
        
        self.sceneView.scene.rootNode.addChildNode(sun)
        self.sceneView.scene.rootNode.addChildNode(earthParent)
        self.sceneView.scene.rootNode.addChildNode(venusParent)
        
        earth.addChildNode(moon)
        earthParent.addChildNode(earth)
        venusParent.addChildNode(venus)
        self.sceneView.autoenablesDefaultLighting = true
        let sunAction = SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 5)
        let sunForever = SCNAction.repeatForever(sunAction)
        
        let earthAction = SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 10)
        let earthForever = SCNAction.repeatForever(earthAction)
        
        let venusAction = SCNAction.rotateBy(x: 0, y: 360.degreesToRadians, z: 0, duration: 5)
        let venusForever = SCNAction.repeatForever(venusAction)
        
        moon.runAction(earthForever)
        earth.runAction(earthForever)
        venus.runAction(venusForever)
        earthParent.runAction(earthForever)
        venusParent.runAction(venusForever)
        sun.runAction(sunForever)
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
