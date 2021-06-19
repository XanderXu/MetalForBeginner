//
//  GameViewController.swift
//  Chapter4_2
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
        
        scnView.isPlaying = true
        
        geometry(scene: scene)
//        surface(scene: scene)
//        light(scene: scene)
//        fragment(scene: scene)
    }
    func geometry(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        guard let path = Bundle.main.path(forResource: "geometry", ofType: "shaderModifier", inDirectory: nil),
            let shader = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return
            }
            
        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.geometry: shader]
        // 参数从外部赋值
        ship.geometry?.setValue(Float(0.1), forKey: "Amplitude")
    }
    func surface(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        guard let path = Bundle.main.path(forResource: "surface", ofType: "shaderModifier", inDirectory: nil),
            let shader = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return
            }
        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.surface: shader]
        // 参数从外部赋值
        ship.geometry?.setValue(Float(12), forKey: "Scale")
        ship.geometry?.setValue(Float(0.25), forKey: "Width")
        ship.geometry?.setValue(Float(0.3), forKey: "Blend")
    }
    func light(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        guard let path = Bundle.main.path(forResource: "light", ofType: "shaderModifier", inDirectory: nil),
            let shader = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return
            }
        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.lightingModel: shader]
        // 参数从外部赋值
        ship.geometry?.setValue(Float(0.5), forKey: "WrapFactor")
    }
    func fragment(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        guard let path = Bundle.main.path(forResource: "fragment", ofType: "shaderModifier", inDirectory: nil),
            let shader = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                return
            }
        // 可以加载到 geometry 上，或者 material 上
//        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.fragment: shader]
        ship.geometry?.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.fragment: shader]
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

