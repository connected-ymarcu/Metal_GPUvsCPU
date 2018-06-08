//
//  ViewController.swift
//  gpuCalculator
//
//  Created by Yasaman Marcu on 2018-06-05.
//  Copyright © 2018 Yasaman Marcu. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
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
    
}
