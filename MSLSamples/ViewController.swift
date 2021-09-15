//
//  ViewController.swift
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

import MetalKit
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var metalView: MTKView!
    
    private let gpu = GPUDevice.shared
    private let scaleFactor = UIScreen.main.scale
    private let startDate = Date()
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var commandQueue : MTLCommandQueue! = nil
    private var pipelineState : MTLRenderPipelineState! = nil
    private var volumeLevel : Float = 0.0
    private var touched = CGPoint(x: 0.0, y: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMetal()
    }
    
    private func setupMetal() {
        metalView.device = gpu.device
        metalView.delegate = self
        metalView.depthStencilPixelFormat = .invalid // 深度のフォーマットは未設定（デフォルト）
        metalView.framebufferOnly = false
        
        commandQueue = gpu.device.makeCommandQueue()
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = GPUDevice.shared.vertexFunction
        pipelineStateDescriptor.fragmentFunction = gpu.library.makeFunction(name: "fragment_electro_line_noise")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! gpu.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension ViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        gpu.updateResolution(width: Float(size.width), height: Float(size.height))
    }
    
    func draw(in view: MTKView) {
        _ = semaphore.wait(timeout: .distantFuture)
        guard
            let renderPassDesicriptor = metalView.currentRenderPassDescriptor,
            let currentDrawable = metalView.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesicriptor) else {
                semaphore.signal()
                return
            }
        gpu.updateTime(Float(Date().timeIntervalSince(startDate)))
        gpu.updateVolume(volumeLevel)
        gpu.updateTouchedPosition(x: Float(scaleFactor * touched.x), y: Float(scaleFactor * touched.y))
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setFragmentBuffer(gpu.resolutionBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(gpu.timeBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(gpu.volumeBuffer, offset: 0, index: 2)
        renderEncoder.setFragmentBuffer(gpu.touchedPositionBuffer, offset: 0, index: 3)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.addScheduledHandler { [weak self] (_) in
            guard let self = self else { return }
            self.semaphore.signal()
        }
        
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
