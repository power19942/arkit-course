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
    
   
    @IBOutlet weak var scene: ARSCNView!
    let config = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scene.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
        self.scene.session.run(config)
    }
    

}


