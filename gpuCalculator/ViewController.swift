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
    var device: MTLDevice!
    
    // optional
    var renderPassDescriptor: MTLRenderPassDescriptor!
    var renderPipelineState: MTLRenderPipelineState!
    
    // Mandatory
    var threadsPerGroup:MTLSize!
    var numberOfThreadgroups:MTLSize!
    
    var defaultLibrary: MTLLibrary!
    var inBuffer: MTLBuffer!
    var outBuffer: MTLBuffer!
    var computePipelineState: MTLComputePipelineState!
    
    var commandQueue: MTLCommandQueue!
    var commandBuffer: MTLCommandBuffer!
    var computeCommandEncoder: MTLComputeCommandEncoder! //converts into byte code for buffer

    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device.makeDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        commandBuffer = commandQueue.makeCommandBuffer()
        computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        singleDimentionCalculation(kernalFunctionName: "shader")
        
        
//       doubleDimentionCalculation()
    }
    
    
    func doubleDimentionCalculation () {
        device = MTLCreateSystemDefaultDevice()
        
        // buffer
        let count = 1500
        let length = count * MemoryLayout< Float >.stride
        var myVector = [Float](repeating: 0, count: count)
        outBuffer = device.makeBuffer(bytes: myVector, length: length, options: [])
        for (index, _) in myVector.enumerated() { myVector[index] = Float(index) }
        inBuffer = device.makeBuffer(bytes: myVector, length: length, options: [])
        
        defaultLibrary = device.makeDefaultLibrary()!
        let kernalFunction = defaultLibrary.makeFunction(name: "kernal_function")
        computePipelineState = try! device.makeComputePipelineState(function: kernalFunction!)
        
        // thread groups
        let size = MTLSize(width: count, height: 1, depth: 1)
        //        let w = computePipelineState.threadExecutionWidth
        //        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        //        threadsPerGroup = MTLSizeMake(w, h, 1)
        //        numberOfThreadgroups = MTLSize(width: 1024/w,
        //                                       height: 1024/h,
        //                                       depth: 1)
        
        
        
        commandQueue = device.makeCommandQueue()
        commandBuffer = commandQueue.makeCommandBuffer()
        computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        computeCommandEncoder.setBuffer(inBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBuffer(outBuffer, offset: 0, index: 1)
        computeCommandEncoder.dispatchThreadgroups(size, threadsPerThreadgroup: size)
        computeCommandEncoder.endEncoding()
        commandBuffer.commit()
        
        let result = outBuffer.contents().bindMemory(to: Float.self, capacity: count)
        var data = [Float](repeating:0, count: count)
        for i in 0 ..< count { data[i] = result[i] }
        print(data.map { $0 })
        
    }
    
    func singleDimentionCalculation (kernalFunctionName: String) {
        do
        {
            computePipelineState = try device.makeComputePipelineState(function: defaultLibrary.makeFunction(name: kernalFunctionName)!)
            computeCommandEncoder.setComputePipelineState(computePipelineState)
            let resultdata = [Int](repeating: 0, count: 1)
            outBuffer = device.makeBuffer(bytes: resultdata, length: 1 * MemoryLayout<Int>.stride, options: [])
            computeCommandEncoder.setBuffer(outBuffer, offset: 0, index: 0)
            
            let threadsPerGroup = MTLSize(width:1,height:1,depth:1)
            let numThreadgroups = MTLSize(width:1, height:1, depth:1)
            computeCommandEncoder?.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
            computeCommandEncoder?.endEncoding()
            
            commandBuffer?.addCompletedHandler {commandBuffer in
                let data = NSData(bytes: self.outBuffer.contents(), length: MemoryLayout<NSInteger>.stride)
                var out: NSInteger = 0
                data.getBytes(&out, length: MemoryLayout<NSInteger>.stride)
                print("data: \(out)")
            }
            
            commandBuffer?.commit()
            
        }
        catch
        {
            fatalError("newComputePipelineStateWithFunction failed ")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
