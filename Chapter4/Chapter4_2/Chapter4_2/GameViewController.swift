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
        //surface(scene: scene)
        //light(scene: scene)
        //fragment(scene: scene)
    }
    func geometry(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        // 调整位置：沿法线方向，根据 x 和 y 的值大小，计算移动幅度，再用正弦函数产生周期性变化
        let shader = """
                            _geometry.position.xyz += _geometry.normal * (0.1 * _geometry.position.y * _geometry.position.x) * sin(scn_frame.time);
                            """
        // 可以加载到 geometry 上，或者 material 上
//        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.geometry: shader]
        ship.geometry?.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.geometry: shader]
    }
    func surface(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        // 根据表面坐标位置：放大 12 倍并截取小数部分，用来产生周期性变化。 f1 三次方加强边缘过渡对比，最后根据 f1 系数在黑白之间混合取值。f2 作用是产生反向边缘，不然条纹后半部分会变淡
        let shader = """
                             float2 position = fract(_surface.diffuseTexcoord * 12);
                             float f1 = clamp(position.y / 0.3, 0.0, 1.0);
                             float f2 = clamp((position.y - 0.25) / 0.3, 0.0, 1.0);
                             f1 = f1 * (1.0 - f2);
                             f1 = f1 * f1 * 2.0 * (3. * 2. * f1);
                             _surface.diffuse = mix(float4(1.0), float4(float3(0.0),1.0), f1);
                            """
        // 可以加载到 geometry 上，或者 material 上
//        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.surface: shader]
        ship.geometry?.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.surface: shader]
    }
    func light(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        // Blinn-Phong 光照模型：Blinn-Phong模型与Phong模型的区别是，把dot(_surface.view,R)(R 为光线反射向量)换成了dot(_surface.normal,halfVector)，其中halfVector为半角向量，位于相机方向_surface.view和光源方向_light.direction的角平分线方向。
        let shader = """
                             float dotProduct = (0.5 + max(0.0, dot(_surface.normal,_light.direction))) / (1 + 0.5);
                             _lightingContribution.diffuse += (dotProduct * _light.intensity.rgb);

                             float3 halfVector = normalize(_light.direction + _surface.view);
                             dotProduct = max(0.0, pow(max(0.0, dot(_surface.normal, halfVector)), _surface.shininess));
                             _lightingContribution.specular += (dotProduct * _light.intensity.rgb);
                            """
        // 可以加载到 geometry 上，或者 material 上
//        ship.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.ligntModel: shader]
        ship.geometry?.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.lightingModel: shader]
    }
    func fragment(scene:SCNScene) {
        // 这里一定要拿到 geometry 所在的 node
        let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true)!
        
        // 反转最后的颜色
        let shader = """
                            _output.color.rgb = 1.0 - _output.color.rgb;
                            """
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

