//
//  ViewController.swift
//  gpuCalculator
//
//  Created by Yasaman Marcu on 2018-06-05.
//  Copyright © 2018 Yasaman Marcu. All rights reserved.
//
import Foundation
import UIKit
import Metal

import MetalKit
import ModelIO
import GameplayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        computeSomething()
    }
    
    func computeSimpleFunc() {
        // GPU interface
        let device: MTLDevice! = MTLCreateSystemDefaultDevice()

        // shader function
        let defaultLibrary: MTLLibrary! = device.makeDefaultLibrary()
        let kernalFunction = defaultLibrary.makeFunction(name: "shader")!
        let computePipelineState: MTLComputePipelineState! = try! device.makeComputePipelineState(function: kernalFunction) // holds the compiled shader code

        let commandQueue: MTLCommandQueue! = device.makeCommandQueue() // queue up a list of commands
        let commandBuffer: MTLCommandBuffer! = commandQueue.makeCommandBuffer() // stores the encoded commands
        let computeCommandEncoder: MTLComputeCommandEncoder! = commandBuffer.makeComputeCommandEncoder() // encodes to byte code

        let resultdata: [Int] = [0]
        let buffer: MTLBuffer! = device.makeBuffer(bytes: resultdata, length: MemoryLayout<Int>.stride, options: [])    // 8 bits

        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setBuffer(buffer, offset: 0, index: 0)

//        let w = computePipelineState.threadExecutionWidth   // 32
//        let h = computePipelineState.maxTotalThreadsPerThreadgroup/w // 1024/32
//        let threadgroupsPerGrid = MTLSizeMake(w, h, 1)
//        let threadsPerThreadgroup = MTLSize(width: 1024/w,height: 1024/h,depth: 1)

        let threadgroupsPerGrid = MTLSize(width:1, height:1, depth:1)
        let threadsPerThreadgroup = MTLSize(width:1,height:1,depth:1)
        computeCommandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        computeCommandEncoder.endEncoding()

        commandBuffer.addCompletedHandler {commandBuffer in
            let executionDuration = commandBuffer.gpuEndTime - commandBuffer.gpuStartTime
            print("time: \(executionDuration) seconds")
            let data = NSData(bytes: buffer.contents(), length: MemoryLayout<NSInteger>.stride)
            var out: NSInteger = 0
            data.getBytes(&out, length: MemoryLayout<NSInteger>.stride)
            print("data: \(out)")
        }

        commandBuffer.commit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var count = 10
    
    func computeSomething () {
        guard let device = MTLCreateSystemDefaultDevice() else { fatalError() }
        guard let queue = device.makeCommandQueue() else { fatalError() }
        
        // computation
        var inputVector:[Float] = [Float](repeating: 0, count: count)
        for (index, _) in inputVector.enumerated() { inputVector[index] = Float(index) }
        inputVector = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: inputVector) as! [Float]
        var outputVector = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: inputVector) as! [Float]
        
        // GPU calcuation
        let length = count * MemoryLayout<Float>.size
        guard let outBuffer = device.makeBuffer(bytes: inputVector, length: length, options: []) else { fatalError() }
        let inBuffer = device.makeBuffer(bytes: outputVector, length: length, options: [])
        let inSizeBuffer = device.makeBuffer(bytes: [Float(count)], length: length, options: [])
        
        let library: MTLLibrary! = device.makeDefaultLibrary()
        let function = library.makeFunction(name: "compute")!
        let computePipelineState = try! device.makeComputePipelineState(function: function)
        
        guard let commandBuffer = queue.makeCommandBuffer() else { fatalError() }
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else { fatalError() }
        encoder.setComputePipelineState(computePipelineState)
        encoder.setBuffer(inBuffer, offset: 0, index: 0)
        encoder.setBuffer(outBuffer, offset: 0, index: 1)
        encoder.setBuffer(inSizeBuffer, offset: 0, index: 2)
        let w = computePipelineState.threadExecutionWidth
        
        var widthSize: Int!
        if count <= w {
            widthSize = Int(ceil(Double(count) / Double(w) ))
        } else {
            widthSize = count/w
        }
        
        
        let size = MTLSize(width: widthSize, height: 1, depth: 1)
        encoder.dispatchThreadgroups(size, threadsPerThreadgroup: size)
        encoder.endEncoding()
        
        commandBuffer.addCompletedHandler {commandBuffer in
            let executionDuration = commandBuffer.gpuEndTime - commandBuffer.gpuStartTime
            print("GPU time: \(executionDuration) seconds")
            
            let result = outBuffer.contents().bindMemory(to: Float.self, capacity: self.count)
            var data = [Float](repeating:0, count: self.count)
            for i in 0 ..< self.count { data[i] = result[i] }
//            print(data.map { $0 })
        }
        
        commandBuffer.commit()
        
        let t2 = CFAbsoluteTimeGetCurrent()
        outputVector = computeOnCPU(input: inputVector, output: outputVector)
        let t3 = CFAbsoluteTimeGetCurrent()
        print("CPU time: \(t3 - t2) seconds")
    }
    
    func computeOnCPU(input: [Float], output: [Float]) -> [Float]{
        var bla = [Float?](repeating: nil, count: count)
        for (index, _) in input.enumerated() {
            bla[index] = (abs(input[index]-output[index])/12.3)*0.123
        }
        return bla as! [Float]
    }
    
    func renderImage() {
        guard let url = Bundle.main.url(forResource: "teapot", withExtension: "obj") else { fatalError() }
        let asset = MDLAsset(url: url)
        let voxelArray = MDLVoxelArray(asset: asset, divisions: 10, patchRadius: 0)
        if let data = voxelArray.voxelIndices() {
            data.withUnsafeBytes { (voxels: UnsafePointer<MDLVoxelIndex>) -> Void in
                let count = data.count / MemoryLayout<MDLVoxelIndex>.size
                var voxelIndex = voxels
                for _ in 0..<count {
                    let position = voxelArray.spatialLocation(ofIndex: voxelIndex.pointee)
                    //                    print(position)
                    voxelIndex = voxelIndex.successor()
                }
            }
        }
    }
    
}


