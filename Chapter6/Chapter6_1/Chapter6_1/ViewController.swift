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
        assignGeometryShader(to: boxAnchor.steelBox?.children.first as? ModelEntity)
    }
    func assignGeometryShader(to modelEntry: ModelEntity?) {
//        print(modelEntry, modelEntry?.model)
        guard var model = modelEntry?.model else { return }
        guard let library = MTLCreateSystemDefaultDevice()?.makeDefaultLibrary() else { return }
        let geometryModifier = CustomMaterial.GeometryModifier(named: "changeGeometry", in: library)
        let surfaceShader = CustomMaterial.SurfaceShader(named: "changeSurface", in: library)
        let ms = model.materials.map({ base in
            try! CustomMaterial(from: base, surfaceShader: surfaceShader, geometryModifier: geometryModifier)
        })
        model.materials = ms
    }
}
