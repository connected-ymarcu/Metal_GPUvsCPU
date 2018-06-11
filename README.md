# Metal_GPUvsCPU
This is a mini experimental project!
The goal is running a simple subtraction computation on both GPU and CPU in order to compare the computation time.
First time using Metal so I took some notes that might be useful for anyone who wants to know the basics of metal implementation.

### Things You Need to Create in Order to Compute a Function on GPU
1. **MTLDevice**: GPU interface
2. **MTLBuffer**: make a buffer consist of data (array) as an input to GPU - first buffer sent, is what kernal function takes as an input (ex. input vertex_array [[ stage_in ]])
3. **MTLComputePipelineState**: configure and set the shader function (vertex/fragment/kernel) - holds compiled shader code
4. **MTLCommandQueue**: list of render commands to execute later on GPU
5. **MTLRenderPassDescriptor** (optional): setup the drawable (color)
6. **MTLCommandBuffer**: container that stores encoded commands
7. **MTLComputeCommandEncoder**: provide MTLBuffer and MTLComputePipelineState created earlier (drawPrimitives tells GPU to draw)
8. Commit MTLCommandBuffer


### Definitions and Notes
* Can NOT pass data directly to GPU, got to pass it through metal buffer
* Metal Best Practices Guide states that we should always avoid creating buffers when our data is less than 4 KB (up to a thousand Floats, for example). In this case we should simply use the setBytes() function instead of creating a buffer.
* Posix_memalign: shared memory between CPU and GPU (combination of buffers and pointers - magic)
* SIMD: Single instruction, multiple data
* Kernel: kernel's responsibilities include managing the system's resources (the communication between hardware and software components).


### Useful Resources
* [Understand Metal in 16 minutes](https://academy.realm.io/posts/swift-summit-simon-gladman-metal/)
* [Ray Wenderlich - 3D cube](https://www.raywenderlich.com/146416/metal-tutorial-swift-3-part-2-moving-3d)
* [Computation on GPU Fundamental](https://developer.apple.com/documentation/metal/compute_processing/hello_compute)
* [Calculating Threadgroup and Grid Sizes](https://developer.apple.com/documentation/metal/compute_processing/calculating_threadgroup_and_grid_sizes)
* [List of Sample codes](http://metalbyexample.com/)
* [Sample code - 1D GPU computation](https://stackoverflow.com/questions/35985353/metal-shading-language-console-output)
