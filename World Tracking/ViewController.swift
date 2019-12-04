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
    
    func createConcrete(planeAnchor:ARPlaneAnchor)-> SCNNode{
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        // static body not accected by gravity
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        return concreteNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planAnchore = anchor as? ARPlaneAnchor else {
            return
        }
        let concreteNode = createConcrete(planeAnchor: planAnchore)
        node.addChildNode(concreteNode)
        scene.scene.rootNode.addChildNode(concreteNode)
        print("new flat surface detected")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planAnchore = anchor as? ARPlaneAnchor else {
            return
        }
        node.enumerateChildNodes{(childNode,_) in
            childNode.removeFromParentNode()
        }
        let concreteNode = createConcrete(planeAnchor: planAnchore)
        node.addChildNode(concreteNode)
        print("update")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        node.enumerateChildNodes{(childNode,_) in
            childNode.removeFromParentNode()
        }
        print("remove")
    }
    
    
    
    @IBAction func addCar(_ sender: Any) {
        guard let pointOfView = scene.pointOfView else {
            self.showAlert(message: "didnt detect anything")
            return
        }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation  + location
        
        let carScene = SCNScene(named: "Car-Scene.scn")
        //get car node from scene
        let frame = (carScene?.rootNode.childNode(withName: "frame",recursively: false))!

        frame.position = currentPositionOfCamera
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: frame, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        frame.physicsBody = body
        self.scene.scene.rootNode.addChildNode(frame)
    }
    
    
    
    
    func showAlert(message:String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

func +(left:SCNVector3,right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var degreesToRadians: Double {
        return Double(self) * .pi/180
    }
}


