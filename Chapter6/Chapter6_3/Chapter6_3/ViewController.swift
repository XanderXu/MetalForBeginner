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
    var ciContext: CIContext?
    var lastImage: CIImage?
    
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
        imageView.isHidden = true
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
        self.ciContext = CIContext(mtlDevice: device)
    }
    
    func postProcess(_ context: ARView.PostProcessContext) {
        //在屏幕中央显示风格迁移后的图片效果，需要打开 imageView.isHidden = false
//        styleTransfer(context)
        // 全屏缩放裁剪，全屏显示风格迁移后的图片效果
        scaleCropStyleTransfer(context)
    }
}
extension ViewController {
    func styleTransfer(_ context: ARView.PostProcessContext) {
        //借用 mps 将源图像输出到屏幕上
        let brightness = MPSImageThresholdToZero(device: context.device,
                                                 thresholdValue: 0,
                                                 linearGrayColorTransform: nil)
        brightness.encode(commandBuffer: context.commandBuffer,
                          sourceTexture: context.sourceColorTexture,
                          destinationTexture: context.targetColorTexture)
        
        if inFlight {//上一帧没处理完，不再处理下一帧
            return
        }
        
        guard let model = self.model else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            self.inFlight = false
            DispatchQueue.main.async(execute: {
                guard let results = finishedRequest.results as? [VNPixelBufferObservation] ,let observation = results.first else {
                    return
                }
                self.imageView.image = UIImage(ciImage: CIImage(cvImageBuffer: observation.pixelBuffer))
            })
        }
        
        //转换并翻转，以供 CoreML 识别处理
        guard let ciImage = CIImage(mtlTexture: context.sourceColorTexture, options: nil)?.oriented(.downMirrored) else { return }
        inFlight = true
        try? VNImageRequestHandler(ciImage: ciImage, options: [:]).perform([request])
    }
    
    func scaleCropStyleTransfer(_ context: ARView.PostProcessContext) {
        if let lastImage = lastImage {
            //创建CIRenderDestination
            let destination = CIRenderDestination(mtlTexture: context.targetColorTexture,commandBuffer: context.commandBuffer)
            //保持图像朝向
            destination.isFlipped = false
            _ = try? self.ciContext?.startTask(toRender: lastImage, to: destination)
        }
        if inFlight {//上一帧没处理完，不再处理下一帧
            return
        }
        
        let sourceColor = CIImage(mtlTexture: context.sourceColorTexture)!
        let scale = 512.0/sourceColor.extent.height
        let scaledWidth = scale * sourceColor.extent.width
        
        guard let model = self.model else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            self.inFlight = false
            DispatchQueue.main.async(execute: {
                guard let results = finishedRequest.results as? [VNPixelBufferObservation] ,let observation = results.first else {
                    return
                }
                let ciimage = CIImage(cvImageBuffer: observation.pixelBuffer)
                //裁剪放大到全屏，保存
                let affine = CIFilter(name: "CIAffineTransform")!
                affine.setValue(ciimage.cropped(to:CGRect(x: 0, y: 0, width: scaledWidth, height: 512)), forKey: "inputImage")
                let trans = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
                affine.setValue(trans, forKey: "inputTransform")
                
                self.lastImage = affine.outputImage
            })
        }
        
        
        //创建缩放滤镜
        let lanczos = CIFilter(name: "CILanczosScaleTransform")!
        lanczos.setValue(sourceColor, forKey: "inputImage")
        lanczos.setValue(scale, forKey: "inputScale")
        lanczos.setValue(1, forKey: "inputAspectRatio")
        //纯色图片
        let constant = CIFilter(name: "CIConstantColorGenerator")!
        constant.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor")
        //混合成 512*512图片，左边为缩小后的图像，右边为空白透明
        let maximum = CIFilter(name: "CIMaximumCompositing")!
        maximum.setValue(lanczos.outputImage, forKey: "inputImage")
        maximum.setValue(constant.outputImage?.cropped(to: CGRect(x: 0, y: 0, width: 512, height: 512)), forKey: "inputBackgroundImage")
        
        inFlight = true
        try? VNImageRequestHandler(ciImage: maximum.outputImage!, options: [:]).perform([request])
    }
}
