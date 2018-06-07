//
//  Shader.metal
//  gpuCalculator
//
//  Created by Yasaman Marcu on 2018-06-06.
//  Copyright © 2018 Yasaman Marcu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// GPU function to calculate
kernel void kernal_function(const device float *inVector [[ buffer(0) ]],
                    device float *outVector [[ buffer(1) ]],
                    uint id [[ thread_position_in_grid ]])
{
    outVector[id] = 1.0 / (1.0 + exp(-inVector[id]));
}

kernel void shader(device int &printBuffer [[buffer(0)]],
                   uint id [[ thread_position_in_grid ]]) {
    
    printBuffer = 98123;
}
