//
//  Colorful.metal
//  Chapter3_2
//
//  Created by CoderXu on 2020/10/7.
//

//  Referene: http://glslsandbox.com/e#36858.0

#include <metal_stdlib>
using namespace metal;

#include <SceneKit/scn_metal>
// 自己定义的顶点输入结构体：顶点位置、纹理坐标
struct VertexInput {
    float3 position  [[attribute(SCNVertexSemanticPosition)]];
    float2 texCoords [[attribute(SCNVertexSemanticTexcoord0)]];
    float3 normal [[attribute(SCNVertexSemanticNormal)]];
};

// 自己定义的Node输入结构体
struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
};


// 自己定义的输入输出结构体：变换后的位置、纹理坐标
struct ColorInOut
{
    float4 position [[ position ]];
    float2 texCoords;
};

// 顶点着色器函数。
vertex ColorInOut scnVertexShader(VertexInput          in       [[ stage_in ]],
                                  constant NodeBuffer& scn_node [[ buffer(0) ]])
{
    ColorInOut out;
    //将顶点沿法线方向进行移动，然后再进行 MVP 变换
    out.position = scn_node.modelViewProjectionTransform * float4(in.position + 5.0f * in.normal, 1.0);
    //纹理坐标直接传递给片元着色器使用，不做更改
    out.texCoords = in.texCoords;
    
    return out;
}




// // 这个结构体由 SceneKit 提供，包含了当前帧画面的常用信息。使用时名称必须是 scn_frame
//struct SCNSceneBuffer {
//    float4x4    viewTransform;
//    float4x4    inverseViewTransform; // view space to world space
//    float4x4    projectionTransform;
//    float4x4    viewProjectionTransform;
//    float4x4    viewToCubeTransform; // view space to cube texture space (right-handed, y-axis-up)
//    float4      ambientLightingColor;
//    float4      fogColor;
//    float3      fogParameters; // x: -1/(end-start) y: 1-start*x z: exponent
//    float       time;     // system time elapsed since first render with this shader
//    float       sinTime;  // precalculated sin(time)
//    float       cosTime;  // precalculated cos(time)
//    float       random01; // random value between 0.0 and 1.0
//};



// 片元着色器函数。注意 SCNSceneBuffer 是系统提供的当前帧内的常量，名称必须是 scn_frame
fragment half4 scnFragmentShader(ColorInOut in          [[ stage_in] ],
                                 constant   SCNSceneBuffer& scn_frame [[buffer(0)]])
{
    float time = scn_frame.time;
    float2 uv = in.texCoords * 4;
    
    // 以下公式由 http://glslsandbox.com/e#36858.0 改写而来，看不懂具体算法没有关系，主要是足够酷炫😎
    float i0=1.2;
    float i1=0.95;
    float i2=1.5;
    float2 i4=float2(0.0,0.0);
    for(int s=0;s<4;s++)
    {
        float2 r;
        r=float2(cos(uv.y*i0-i4.y+time/i1),sin(uv.x*i0+i4.x+time/i1))/i2;
        r+=float2(-r.y,r.x)*0.2;
        uv.xy+=r;
        
        i0*=1.93;
        i1*=1.25;
        i2*=1.7;
        i4+=r.xy*1.0+0.5*time*i1;
    }
    float r=sin(uv.x-time)*0.5+0.5;
    float b=sin(uv.y+time)*0.5+0.5;
    float g=sin((sqrt(uv.x*uv.x+uv.y*uv.y)+time))*0.5+0.5;
    half3 c=half3(r,g,b);
    return half4(c,1.0);
}
