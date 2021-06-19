//
//  Shaders.metal
//  Chapter5_1
//
//  Created by CoderXu on 2020/10/8.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
// 公共头文件
#import "ShaderTypes.h"

using namespace metal;

// 这里我们不再需要 SceneKit 了，所以不再需要导入相关头文件了


typedef struct
{
    // 顶点位置来源指定，来自顶点attribute(0),VertexAttributePosition就是ShaderTypes.h中定义的，值为 0
    // 具体数值由 Renderer.swift 中通过 Mesh (Mesh 就是顶点组成的网格)传递给 GPU，我们这里是从 GPU 里取
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    // 顶点着色器与片元着色器的输入输出，[[position]] 表示提供给 GPU 用来显示最后的位置
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

// 顶点着色器，Vertex in [[stage_in]] 表示系统自动按照指定格式，从 GPU 拿到当前顶点的数据
// Vertex 和 Uniforms 的具体数值，我们在 Renderer.swift 中传递到 GPU 上了，见 `draw(in view: MTKView)` 方法
vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    // MVP 变换
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}

// 片元着色器，ColorInOut in [[stage_in]] 表示系统自动处理了顶点着色器的输出，并传递给片元着色器
// Uniforms 和 texture2d<half> colorMap 的具体数值，我们在 Renderer.swift 中传递到 GPU 上了，见 `draw(in view: MTKView)` 方法
fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
{
    // 采样器，用来读取图像上指定位置的颜色
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    // 用采样器，读取目标图片在当前片元处的颜色信息
    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

    return float4(colorSample);
}
