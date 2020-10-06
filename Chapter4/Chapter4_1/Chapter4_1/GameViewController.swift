//
//  GameViewController.swift
//  Chapter4_1
//
//  Created by CoderXu on 2020/10/6.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the box node
        let box1 = scene.rootNode.childNode(withName: "box1", recursively: true)!
        let box2 = scene.rootNode.childNode(withName: "box2", recursively: true)!
        let box3 = scene.rootNode.childNode(withName: "box3", recursively: true)!
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        
        let box3_worldTransform = box1.simdTransform * box2.simdTransform * box3.simdTransform
        print(box3_worldTransform)
        print(box3.simdWorldTransform)//与自带的simdWorldTransform比较
        print("==================")
        //simd_float4x4([[0.99999994, 0.0, 0.0, 0.0], [0.0, 0.99999994, 0.0, 0.0], [0.0, 0.0, 0.99999994, 0.0], [2.5, 3.5, 2.5, 1.0]])
        //simd_float4x4([[0.99999994, 0.0, 0.0, 0.0], [0.0, 0.99999994, 0.0, 0.0], [0.0, 0.0, 0.99999994, 0.0], [2.5, 3.5, 2.5, 1.0]])
        
        let inverseBox3_worldTransform = simd_inverse(box3.simdTransform) * simd_inverse(box2.simdTransform) * simd_inverse(box1.simdTransform)
        print(inverseBox3_worldTransform)
        print(simd_inverse(box3_worldTransform))
        //simd_float4x4([[0.99999994, 0.0, 0.0, 0.0], [0.0, 0.99999994, 0.0, 0.0], [0.0, 0.0, 0.99999994, 0.0], [-2.4999998, -3.4999998, -2.4999998, 0.9999999]])
        //simd_float4x4([[1.0000001, 0.0, 0.0, 0.0], [0.0, 1.0000001, 0.0, 0.0], [0.0, 0.0, 1.0000001, 0.0], [-2.5, -3.5000002, -2.5, 1.0]])
    }
    
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}


