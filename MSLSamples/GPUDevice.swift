//
//  GPUDevice.swift
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

import Foundation
import Metal
import simd

typealias Acceleration = SIMD3<Float>

class GPUDevice {
    static let shared = GPUDevice()
    
    let device = MTLCreateSystemDefaultDevice()!
    var library : MTLLibrary! // makeFunction(name:)を用いてMTLFunctionオブジェクトを生成
    lazy var vertexFunction : MTLFunction = library.makeFunction(name: "vertexShader")!
    
    var resolutionBuffer : MTLBuffer! = nil
    var timeBuffer : MTLBuffer! = nil
    var volumeBuffer : MTLBuffer! = nil
    var touchedPositionBuffer : MTLBuffer! = nil

    private init() {
        library = device.makeDefaultLibrary()
        
        setUpBeffers()
    }
    
    func setUpBeffers() {
        resolutionBuffer = device.makeBuffer(length: 2 * MemoryLayout<Float>.size, options: [])
        timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        volumeBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        touchedPositionBuffer = device.makeBuffer(length: 2 * MemoryLayout<Float>.size, options: [])
    }
    
    func updateResolution(width: Float, height: Float) {
        // バッファの内容（[width, height]）を対象（resolutionBuffer.contents()）にデータサイズを指定してコピーする
        memcpy(resolutionBuffer.contents(), [width, height], MemoryLayout<Float>.size * 2)
    }
    
    func updateTime(_ time: Float) {
        updateBuffer(time, timeBuffer)
    }

    func updateVolume(_ volume: Float) {
        updateBuffer(volume, volumeBuffer)
    }
    
    func updateTouchedPosition(x : Float, y: Float) {
        memcpy(touchedPositionBuffer.contents(), [x, y], MemoryLayout<Float>.size * 2)
    }
    
    private func updateBuffer<T>(_ data:T, _ buffer: MTLBuffer) {
        let pointer = buffer.contents()
        let value = pointer.bindMemory(to: T.self, capacity: 1)
        value[0] = data
    }
}

