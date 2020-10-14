//
//  GameViewController.swift
//  Chapter3_1
//
//  Created by CoderXu on 2020/10/4.
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
        
        func1(scene: scene)
//        func2(scene: scene)
//        func3(scene: scene)
    }
    
    func func1(scene:SCNScene) {
        for i in 0..<48 {
            // 计算行号和列号，类似 9 宫格布局
            var size: CGFloat = 0.7 //默认尺寸
            let num = i % 16 //第几个
            let line = i / 16 //第几行
            if line == 0 || line == 2 {
                //最上面一行，最下面一行缩小一些
                size = 0.6
            }

            // 创建平面
            let plane = SCNPlane(width: size, height: size)
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.9)
            plane.cornerRadius = 0.08
            let planeNode = SCNNode(geometry: plane)
            scene.rootNode.addChildNode(planeNode)

            // 计算角度
            let angles = simd_make_float3((Float(line) * 22.0 - 22.0) / 180.0 * .pi, 22.5 * Float(num) / 180.0 * .pi, 0)
            planeNode.simdEulerAngles = angles

            // 将planeNode沿自己坐标系的(0, 0, 2)方向平移 2 米
            planeNode.simdLocalTranslate(by: simd_make_float3(0, 0, 2))
        }
    }
    func func2(scene:SCNScene) {
        for i in 0..<48 {
            // 计算行号和列号，类似 9 宫格布局
            var size: CGFloat = 0.7 //默认尺寸
            let num = i % 16 //第几个
            let line = i / 16 //第几行
            if line == 0 || line == 2 {
                //最上面一行，最下面一行缩小一些
                size = 0.6
            }

            // 创建平面
            let plane = SCNPlane(width: size, height: size)
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.9)
            plane.cornerRadius = 0.08
            let planeNode = SCNNode(geometry: plane)
            scene.rootNode.addChildNode(planeNode)

            // 计算角度
            let angles = simd_make_float3((Float(line) * 22.0 - 22.0) / 180.0 * .pi, 22.5 * Float(num) / 180.0 * .pi, 0)
            planeNode.simdEulerAngles = angles

            // 计算位置，planeNode坐标下(0, 0, 2)点在平面父结点坐标中的位置
            let position = planeNode.simdConvertPosition(simd_make_float3(0, 0, 2), to: planeNode.parent)
            planeNode.simdPosition = position
        }
    }
    
    // 进阶版，球面均匀分布
    func func3(scene:SCNScene) {
        let positions = pointOnSphere(count: 48)
        let size: CGFloat = 0.6 //默认尺寸
        
        for position in positions {
            // 创建平面
            let plane = SCNPlane(width: size, height: size)
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.9)
            plane.cornerRadius = 0.08
            let planeNode = SCNNode(geometry: plane)
            scene.rootNode.addChildNode(planeNode)
            
            planeNode.simdPosition = position
            planeNode.simdLook(at: simd_float3.zero)
        }
        
    }
    func pointOnSphere(count: Int, radius: Float = 2) -> [simd_float3] {
        var points: [simd_float3] = []
        let inc = Float.pi * (sqrt(5) - 1)
        let off = 2.0 / Float(count)
        var y: Float,r: Float,phi: Float
        for i in 0..<count {
            y = Float(i) * off + off/2 - 1.0 //(2n-1)/N - 1,竖坐标成等差数列
            r = sqrt(1 - y*y)
            phi = Float(i) * inc//经度成等差数列
            let location = simd_float3(x: cos(phi)*r*radius, y: y*radius, z: sin(phi)*r*radius)
            points.append(location)
        }
        return points
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



