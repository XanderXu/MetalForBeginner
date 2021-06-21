//
//  ViewController.swift
//  Chapter6_2
//
//  Created by 许海峰 on 2021/6/21.
//

import UIKit
import RealityKit
import MetalPerformanceShaders
import SpriteKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        initPostEffect(arView: arView)
    }
    
    var ciContext: CIContext?
    
    var device: MTLDevice!
    var bloomTexture: MTLTexture!
    
    var skRenderer: SKRenderer?
    
    func initPostEffect(arView: ARView) {
        arView.renderCallbacks.prepareWithDevice = { [weak self] device in
            self?.prepareWithDevice(device)
        }
        arView.renderCallbacks.postProcess = { [weak self] context in
            self?.postProcess(context)
        }
    }
    func prepareWithDevice(_ device: MTLDevice) {
        self.ciContext = CIContext(mtlDevice: device)
        self.device = device
    }
    
    func postProcess(_ context: ARView.PostProcessContext) {
        filterProcess(context)
//        mpsProcess(context)
//        spriteProcess(context)
    }
}
extension ViewController {
    func filterProcess(_ context: ARView.PostProcessContext) {
        let sourceColor = CIImage(mtlTexture: context.sourceColorTexture)!
        
        //创建热点滤镜
        guard let thermal = CIFilter(name: "CIThermal") else { return }
        thermal.setValue(sourceColor, forKey: "inputImage")
//        thermal?.inputImage = sourceColor
        
        //创建CIRenderDestination
        let destination = CIRenderDestination(mtlTexture: context.targetColorTexture,
                                              commandBuffer: context.commandBuffer)
        //保持图像朝向
        destination.isFlipped = false
        
        _ = try? self.ciContext?.startTask(toRender: thermal.outputImage!, to: destination)
    }
    func mpsProcess(_ context: ARView.PostProcessContext) {
        if self.bloomTexture == nil {
            self.bloomTexture = self.makeTexture(matching: context.sourceColorTexture)
        }
        //将亮度0.2以下的区域置为0
        let brightness = MPSImageThresholdToZero(device: context.device,
                                                 thresholdValue: 0.2,
                                                 linearGrayColorTransform: nil)
        brightness.encode(commandBuffer: context.commandBuffer,
                          sourceTexture: context.sourceColorTexture,
                          destinationTexture: bloomTexture!)
        //剩余区域进行模糊
        let gaussianBlur = MPSImageGaussianBlur(device: context.device, sigma: 9.0)
        gaussianBlur.encode(commandBuffer: context.commandBuffer,
                            inPlaceTexture: &bloomTexture!)
        //将颜色与 bloom 叠加，最后写入到 targetColorTexture 中
        let add = MPSImageAdd(device: context.device)
        add.encode(commandBuffer: context.commandBuffer,
                   primaryTexture: context.sourceColorTexture,
                   secondaryTexture: bloomTexture!,
                   destinationTexture: context.targetColorTexture)
    }
    func makeTexture(matching texture: MTLTexture) -> MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.width = texture.width
        descriptor.height = texture.height
        descriptor.pixelFormat = texture.pixelFormat
        descriptor.usage = [.shaderRead, .shaderWrite]
        
        return device.makeTexture(descriptor: descriptor)!
    }
    
    func spriteProcess(_ context: ARView.PostProcessContext) {
        if skRenderer == nil {
            skRenderer = makeSkRenderer()
        }
        //将 sourceColorTexture 复制到 targetColorTexture
        let blitEncoder = context.commandBuffer.makeBlitCommandEncoder()
        blitEncoder?.copy(from: context.sourceColorTexture, to: context.targetColorTexture)
        blitEncoder?.endEncoding()
        //刷新 spriteKit 场景
        skRenderer?.update(atTime: context.time)
        
        //创建 RenderPass 以向 targetColorTexture 中写入数据，为了创建 RenderPass 需要先创建描述符
        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].loadAction = .load
        desc.colorAttachments[0].storeAction = .store
        desc.colorAttachments[0].texture = context.targetColorTexture
        
        skRenderer?.render(withViewport: CGRect(x: 0, y: 0,
                                                    width: context.targetColorTexture.width,
                                                    height: context.targetColorTexture.height),
                               commandBuffer: context.commandBuffer,
                               renderPassDescriptor: desc)
    }
    func makeSkRenderer() -> SKRenderer {
        let skRenderer = SKRenderer(device: device)
        skRenderer.scene = SKScene(fileNamed: "GameScene")
        skRenderer.scene?.scaleMode = .aspectFill
        //背景色为透明
        skRenderer.scene?.backgroundColor = .clear
        return skRenderer
    }
}
