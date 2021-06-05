//
//  Simple.metal
//  Chapter3_1
//
//  Created by CoderXu on 2020/10/7.
//

//默认的头文件
#include <metal_stdlib>
using namespace metal;
//与 SceneKit 配合使用时，需要的头文件
#include <SceneKit/scn_metal>

// 自己定义的顶点输入结构体：float3 position 是类型和变量名。
// [[attribute(SCNVertexSemanticPosition)]]表示这个值来自一个特殊的地方：SceneKit，取的是模型的顶点位置信息。也就是说只要这么写了，SceneKit 在运行时，会自动把模型的顶点位置信息赋值到这里。同理 SCNVertexSemanticNormal 则表示取法线信息。整个过程是自动的，无需我们再编写其他代码处理。
struct VertexInput {
    float3 position [[attribute(SCNVertexSemanticPosition)]];
};

// 自己定义的输入输出结构体：vertexShader 函数的输出，会被处理后自动作为 fragmentShader 函数的输入。float4 position 是类型和变量名。
// [[position]]表示这个值从 vertexShader 函数输出后，需要交给 SceneKit 作为顶点的位置信息处理，这个位置是即将在屏幕上显示的位置（投影空间）
struct ColorInOut
{
    float4 position [[position]];
};

// 自己定义的Node输入结构体：这里是固定写法，只要写上float4x4 modelViewProjectionTransform;就能从 SceneKit 中自动获取当前 node 的 MVP 矩阵
// 注意：这个结构体的类型名可以自己定义，内部要使用的值也可以按需要获取，但是使用时的变量名必须是：scn_node，也就是使用时必须是constant MyNodeData& scn_node [[buffer(0/1/2/3...)]]
struct MyNodeData
{
    float4x4 modelViewProjectionTransform;
    //float2x3 boundingBox;
};

/*
 Metal Shader 的基本结构：vertexShader 函数和 fragmentShader 函数，最前面分别是`vertex`和`fragment`关键字。
 在 Shader 中，[[]]表示有特殊用途（来自系统，或需要交给系统处理），内部的关键字是固定的，表明具体用途。
 [[stage_in]]可以简单理解为：系统自动选了一个顶点/片元，输入到顶点/片元着色器中；
 [[buffer(0)]]可以简单理解为这个参数是通过 0 号 buffer 通道传递过来的，就像去银行办理业务，0 号窗口是空的，就会排到 0 号窗口；0 号有人正在使用，会使用 1 号窗口……
 */

// 顶点着色器函数，输出为 ColorInOut 类型，输入为 VertexInput 类型的变量 in，和 MyNodeData 类型的变量指针 scn_node，前面的 constant 表示只读
vertex ColorInOut vertexShader(VertexInput in [[stage_in]], constant MyNodeData& scn_node [[buffer(0)]])
{
    ColorInOut out;
    // 将模型空间的顶点补全为 float4 类型，进行 MVP 变换
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    return out;
}

// 片元着色器函数，输出为 half4，输入为 ColorInOut 类型的变量 in
fragment half4 fragmentShader(ColorInOut in [[stage_in]])
{
    // 返回的是颜色 RGBA，(0.5, 0.5, 1.0, 1.0)是蓝紫色
    return half4(0.5, 0.5, 1.0, 1.0);
}
