//
//  Shader.metal
//  Chapter6_1
//
//  Created by CoderXu on 2021/6/20.
//

#include <metal_stdlib>
//导入 RealityKit 的头文件
#include <RealityKit/RealityKit.h>

using namespace metal;

[[visible]]//shader 的修饰符
void changeGeometry(realitykit::geometry_parameters params)
{
    //将模型的顶点坐标沿法线移动 0.05 米
    float3 offset = params.geometry().normal() * 0.05;
    params.geometry().set_model_position_offset(offset);
}

[[visible]]//shader 的修饰符
void changeSurface(realitykit::surface_parameters params)
{
    //将表面颜色强制改为红色
    params.surface().set_base_color(half3(1,0,0));
    params.surface().set_roughness(1.0);
}
