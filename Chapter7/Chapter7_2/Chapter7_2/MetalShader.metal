//
//  MetalShader.metal
//  Chapter7_2
//
//  Created by CoderXu on 2020/10/25.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>


struct custom_vertex_t
{
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

struct out_vertex_t
{
    float4 position [[position]];
    float2 uv;
};

vertex out_vertex_t vertexShader(custom_vertex_t in [[stage_in]])
{
    out_vertex_t out;
    out.position = in.position;
    //反转 y 轴，并调整取值范围，从 NDC 坐标[-1～+1]到 uv 坐标[0～1]
    out.uv = float2( (in.position.x + 1.0) * 0.5, 1.0 - (in.position.y + 1.0) * 0.5 );
    return out;
};

fragment half4 fragmentShader(out_vertex_t in [[stage_in]],
                              constant   SCNSceneBuffer& scn_frame [[buffer(0)]],
                              texture2d<float, access::sample> normalSampler [[texture(0)]],
                              texture2d<float, access::sample> colorSampler [[texture(1)]])
{
    float2 new_uv = fract((in.uv - 0.5)/(float2(scn_frame.viewportSize.y/scn_frame.viewportSize.x,1.0)*2) + 0.5 - float2(0.0,scn_frame.time*0.1));
    
    constexpr sampler s = sampler(coord::normalized,
                                  r_address::clamp_to_edge,
                                  t_address::clamp_to_edge,
                                  filter::linear);
    float3 normal = normalSampler.sample(s, float2(new_uv.x, 1-new_uv.y)).rgb;
    normal = normal * 2.0;
    float3 rgb = colorSampler.sample(s, mix(in.uv, normal.xy, 0.1)).rgb;
    return half4(half3(rgb),1.0);
};
