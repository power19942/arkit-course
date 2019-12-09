//
//  ViewController.swift
//  World Tracking
//
//  Created by opstudios on 12/1/19.
//  Copyright © 2019 opstudios. All rights reserved.
//

import UIKit
import ARKit
import Each

class ViewController: UIViewController,ARSCNViewDelegate {
    
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let config = ARWorldTrackingConfiguration()
    var power:Float = 1.0
    var timer = Each(0.05).seconds
    var basketAdded :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        self.config.planeDetection = .horizontal
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.run(config)
        self.sceneView.delegate = self
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapRec)
        tapRec.cancelsTouchesInView = false
    }
    // trigger when touch the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.basketAdded == true {
            timer.perform(closure: {()-> NextStep in
                self.power = self.power + 1
                return .continue
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.basketAdded == true{
            self.timer.stop()
            self.shootBall()
        }
        self.power = 1
    }
    
    
    
    func shootBall(){
        guard let pointOfView = self.sceneView.pointOfView else { return }
        self.removeOtherBall()
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let position = location + orientation
        let ball = SCNNode(geometry: SCNSphere(radius: 0.2))
        ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "ball")
        ball.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
        ball.physicsBody = body
        ball.name = "Basketball"
        // control power when ball hit the basket
        body.restitution = 0.2
        ball.physicsBody?.applyForce(SCNVector3(orientation.x*power, orientation.y*power, orientation.z*power), asImpulse: true)
        
        self.sceneView.scene.rootNode.addChildNode(ball)
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        let touchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        if !hitTest.isEmpty {
            self.addBasket(hitTestResult:hitTest.first!)
        }
    }
    
    func addBasket(hitTestResult:ARHitTestResult){
        if basketAdded == false {
            let backetScene = SCNScene(named: "Basketball.scnassets/Basketball.scn")
            let basketNode = backetScene?.rootNode.childNode(withName: "Basket", recursively: false)
            let positionOfPlane = hitTestResult.worldTransform.columns.3
            let xPosition = positionOfPlane.x
            let yPosition = positionOfPlane.y
            let zPosition = positionOfPlane.z
            basketNode?.position = SCNVector3(xPosition,yPosition,zPosition)
            // have body but not affected with other forces like gravity
            basketNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketNode!, options: [
                // treat box and torus as seprate shapes
                SCNPhysicsShape.Option.keepAsCompound:true,
                // high level of detaisl
                SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron
            ]))
            self.sceneView.scene.rootNode.addChildNode(basketNode!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                self.basketAdded = true
            }
        }
    }
    
    deinit {
        self.timer.stop()
    }
    
    func removeOtherBall(){
        self.sceneView.scene.rootNode.enumerateChildNodes{(node,_) in
            if node.name == "Basketball"{
                node.removeFromParentNode()
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARPlaneAnchor else {
                return
            }
            DispatchQueue.main.async {
                self.planeDetected.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.planeDetected.isHidden = true
            }
        }
        
        
        
    }
}

func +(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
