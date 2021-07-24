//
//  ViewController.swift
//  Chapter6_3
//
//  Created by CoderXu on 2021/7/24.
//
//https://zhuanlan.zhihu.com/p/383237672
import UIKit
import RealityKit
import Vision
import CoreImage
import MetalPerformanceShaders
class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var imageView: UIImageView!//对性能要求较高可使用 MTKView
    var device: MTLDevice!
    var inFlight = false//每次只处理一帧
    let model:VNCoreMLModel? = {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        guard let styleModel = try? StyleBlue.init(configuration: config).model else{return nil}
        guard let model = try? VNCoreMLModel(for: styleModel) else { return nil}
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        initPostEffect(arView: arView)
        
    }
    func initPostEffect(arView: ARView) {
        arView.renderCallbacks.prepareWithDevice = { [weak self] device in
            self?.prepareWithDevice(device)
        }
        arView.renderCallbacks.postProcess = { [weak self] context in
            self?.postProcess(context)
        }
    }
    func prepareWithDevice(_ device: MTLDevice) {
        self.device = device
    }
    
    func postProcess(_ context: ARView.PostProcessContext) {
        //借用 mps 将源图像输出到屏幕上
        let brightness = MPSImageThresholdToZero(device: context.device,
                                                 thresholdValue: 0,
                                                 linearGrayColorTransform: nil)
        brightness.encode(commandBuffer: context.commandBuffer,
                          sourceTexture: context.sourceColorTexture,
                          destinationTexture: context.targetColorTexture)
        
        //在屏幕中央显示风格迁移后的图片效果
        styleTransfer(context)
    }
}
extension ViewController {
    func styleTransfer(_ context: ARView.PostProcessContext) {
        if inFlight {
            return
        }
        
        guard let model = self.model else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            DispatchQueue.main.async(execute: {
                guard let results = finishedRequest.results as? [VNPixelBufferObservation] ,let observation = results.first else {
                    return
                }
                self.imageView.image = UIImage(ciImage: CIImage(cvImageBuffer: observation.pixelBuffer))
                self.inFlight = false
            })
        }
        
        //转换并翻转，以供 CoreML 识别处理
        guard let ciImage = CIImage(mtlTexture: context.sourceColorTexture, options: nil)?.oriented(.downMirrored) else { return }
        try? VNImageRequestHandler(ciImage: ciImage, options: [:]).perform([request])
        inFlight = true
    }
}
