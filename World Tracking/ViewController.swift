//
//  ViewController.swift
//  World Tracking
//
//  Created by opstudios on 12/1/19.
//  Copyright © 2019 opstudios. All rights reserved.
//

import UIKit
import ARKit

enum BitMaskCategory : Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController,ARSCNViewDelegate,SCNPhysicsContactDelegate {
    
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let config = ARWorldTrackingConfiguration()
    var power:Float = 20
    var Target:SCNNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.session.run(config)
        self.sceneView.delegate = self
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapRec)
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }
    // trigger when touch the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    @IBAction func addTargets(_ sender: Any) {
        self.addEgg(x: 5, y: 0, z: -40)
        self.addEgg(x: 0, y: 0, z: -40)
        self.addEgg(x: -5, y: 0, z: -40)
    }
    
    func addEgg(x:Float,y:Float,z:Float){
        let eggScene = SCNScene(named: "Media.scnassets/egg.scn")
        let eggNode = (eggScene?.rootNode.childNode(withName: "egg", recursively: false))!
        eggNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode, options: nil))
        eggNode.position = SCNVector3(x,y,z)
        eggNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        eggNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        self.sceneView.scene.rootNode.addChildNode(eggNode)
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeA
        }else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            self.Target = nodeB
        }
        
//        let spark = SCNParticleSystem(named: "Media.scnassets/Spark.skn", inDirectory: nil)
//        spark?.loops = false
//        spark?.particleLifeSpan = 4
//        spark?.emitterShape = Target?.geometry
//        let sparkNode = SCNNode()
//        sparkNode.addParticleSystem(spark!)
//        sparkNode.position = contact.contactPoint
//        self.sceneView.scene.rootNode.addChildNode(sparkNode)
        Target?.removeFromParentNode()
    }
    
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {
            return
        }
        let pointOfView = sceneView.pointOfView!
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let position = orientation + location
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x*power,orientation.y*power,orientation.z*power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        self.sceneView.scene.rootNode.addChildNode(bullet)
        bullet.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 2.0),
            SCNAction.removeFromParentNode()
        ]))
    }
    
    
    
}

func +(left:SCNVector3,right:SCNVector3)->SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
