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


