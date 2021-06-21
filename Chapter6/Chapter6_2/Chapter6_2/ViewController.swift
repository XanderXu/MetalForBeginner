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
    }
}
extension ViewController {
    func filterProcess(_ context: ARView.PostProcessContext) {
        let sourceColor = CIImage(mtlTexture: context.sourceColorTexture)!
        
        guard let thermal = CIFilter(name: "CIThermal") else { return }
        thermal.setValue(sourceColor, forKey: "inputImage")
//        thermal?.inputImage = sourceColor
        
        let destination = CIRenderDestination(mtlTexture: context.targetColorTexture,
                                              commandBuffer: context.commandBuffer)
        
        destination.isFlipped = false
        
        _ = try? self.ciContext?.startTask(toRender: thermal.outputImage!, to: destination)
    }
    func mpsProcess(_ context: ARView.PostProcessContext) {
        if self.bloomTexture == nil {
            self.bloomTexture = self.makeTexture(matching: context.sourceColorTexture)
        }
        let brightness = MPSImageThresholdToZero(device: context.device,
                                                 thresholdValue: 0.2,
                                                 linearGrayColorTransform: nil)
        brightness.encode(commandBuffer: context.commandBuffer,
                          sourceTexture: context.sourceColorTexture,
                          destinationTexture: bloomTexture!)
        let gaussianBlur = MPSImageGaussianBlur(device: context.device, sigma: 9.0)
        gaussianBlur.encode(commandBuffer: context.commandBuffer,
                            inPlaceTexture: &bloomTexture!)
        
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
        let blitEncoder = context.commandBuffer.makeBlitCommandEncoder()
        blitEncoder?.copy(from: context.sourceColorTexture, to: context.targetColorTexture)
        blitEncoder?.endEncoding()
        
        skRenderer?.update(atTime: context.time)
        
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
        
        skRenderer.scene?.backgroundColor = .clear
        return skRenderer
    }
}
