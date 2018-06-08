//
//  Shader.metal
//  gpuCalculator
//
//  Created by Yasaman Marcu on 2018-06-06.
//  Copyright © 2018 Yasaman Marcu. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void shader(device int *printBuffer [[ buffer(0) ]],
                   uint id [[ thread_position_in_grid ]]) {
    
    printBuffer[id] = 98123;
}

kernel void compute(const device float *inVector [[ buffer(0) ]],
                    device float *outVector [[ buffer(1) ]],
                    device float *sizeOfArray [[ buffer(2) ]],
                    uint id [[ thread_position_in_grid ]])
{
    outVector[id] = (fabs(inVector[id]-outVector[id])/12.3)*0.123;
}
