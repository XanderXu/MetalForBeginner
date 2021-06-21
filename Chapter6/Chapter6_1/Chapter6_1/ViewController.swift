//
//  ViewController.swift
//  Chapter6_1
//
//  Created by CoderXu on 2021/6/20.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        //打印 boxAnchor 层级结构，找到真正的 ModelEntity
        if let modelEntity = boxAnchor.findEntity(named: "simpBld_root") as? ModelEntity {
            assignGeometryShader(to:modelEntity)
        }
    }
    func assignGeometryShader(to modelEntry: ModelEntity) {
        guard var model = modelEntry.model else { return }
        guard let library = MTLCreateSystemDefaultDevice()?.makeDefaultLibrary() else { return }
        let geometryModifier = CustomMaterial.GeometryModifier(named: "changeGeometry", in: library)
        let surfaceShader = CustomMaterial.SurfaceShader(named: "changeSurface", in: library)
        let ms = model.materials.map({ base in
            try! CustomMaterial(from: base, surfaceShader: surfaceShader, geometryModifier: geometryModifier)
        })
        model.materials = ms
        modelEntry.model = model// 所有的component都是结构体，即值类型，重新赋值回去才能生效
//        modelEntry.components[ModelComponent.self] = model//与 modelEntry.model = model 等价
    }
}
