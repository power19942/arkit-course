//
//  ViewController.swift
//  World Tracking
//
//  Created by opstudios on 12/1/19.
//  Copyright © 2019 opstudios. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion

class ViewController: UIViewController , ARSCNViewDelegate{
    
    
    
    @IBOutlet weak var scene: ARSCNView!
    let config = ARWorldTrackingConfiguration()
    let motionManager = CMMotionManager()
    var vehicle = SCNPhysicsVehicle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scene.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        self.config.planeDetection = .horizontal
        self.scene.session.run(config)
        self.scene.delegate = self
        self.setupAccelerometer()
        
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
        let chassis = (carScene?.rootNode.childNode(withName: "chassis",recursively: false))!
        let rearLeft = chassis.childNode(withName: "rearLeftParent", recursively: false)!
        let rearRight = chassis.childNode(withName: "rearRightParent", recursively: false)!
        let frontLeft = chassis.childNode(withName: "frontLeftParent", recursively: false)!
        let frontRight = chassis.childNode(withName: "frontRightParent", recursively: false)!

        
        let v_rerLeftWheel = SCNPhysicsVehicleWheel(node: rearLeft)
        let v_rerRightWheel = SCNPhysicsVehicleWheel(node: rearRight)
        let v_frontLeftWheel = SCNPhysicsVehicleWheel(node: frontLeft)
        let v_frontRightWheel = SCNPhysicsVehicleWheel(node: frontRight)
        
        
        chassis.position = currentPositionOfCamera
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: chassis, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        chassis.physicsBody = body
        self.vehicle = SCNPhysicsVehicle(chassisBody: chassis.physicsBody!, wheels: [
            v_rerRightWheel,v_rerLeftWheel,v_frontRightWheel,v_frontLeftWheel
        ])
        self.scene.scene.physicsWorld.addBehavior(self.vehicle)
        self.scene.scene.rootNode.addChildNode(chassis)
    }
    
    
    func setupAccelerometer(){
        if motionManager.isAccelerometerAvailable {
            // update 60 time per second
            motionManager.accelerometerUpdateInterval = 1/60
            motionManager.startAccelerometerUpdates(to: .main, withHandler: {(accelerometerData,error) in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                }
                self.accelerometerDidChange(acceleration: accelerometerData!.acceleration)
            })
        }else{
            showAlert(message: "Accelerometer Not Available")
        }
    }
    
    func accelerometerDidChange(acceleration:CMAcceleration){
        print(acceleration.x)
        print(acceleration.y)
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


