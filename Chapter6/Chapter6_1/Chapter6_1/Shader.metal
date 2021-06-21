//
//  Shader.metal
//  Chapter6_1
//
//  Created by CoderXu on 2021/6/20.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;



[[visible]]
void changeGeometry(realitykit::geometry_parameters params)
{
    float3 offset = params.geometry().normal() * 0.05;
    params.geometry().set_model_position_offset(offset);
}

[[visible]]
void changeSurface(realitykit::surface_parameters params)
{
    params.surface().set_base_color(half3(1,0,0));
    params.surface().set_roughness(1.0);
}
