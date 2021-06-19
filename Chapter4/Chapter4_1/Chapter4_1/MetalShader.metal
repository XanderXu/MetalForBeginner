//
//  MetalShader.metal
//  Chapter4_1
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
    out.uv = (float2(1,1) + in.position.xy * float2(1,-1)) * 0.5;
    return out;
};

fragment half4 fragmentShader(out_vertex_t in [[stage_in]],
                              constant   SCNSceneBuffer& scn_frame [[buffer(0)]],
                              texture2d<float, access::sample> normalSampler [[texture(0)]],
                              texture2d<float, access::sample> colorSampler [[texture(1)]])
{
    //将 uv 从[0，1] 调整宽高比与屏幕比例相同，并按时间进行移动，1.8 是控制整体缩放倍数即雨滴的大小
    float2 new_uv = fract((in.uv - 0.5) / (float2(scn_frame.viewportSize.y/scn_frame.viewportSize.x,1.0)*1.8) - float2(0.0,scn_frame.time*0.1));
    
    constexpr sampler s = sampler(coord::normalized,
                                  r_address::clamp_to_edge,
                                  t_address::clamp_to_edge,
                                  filter::linear);
    //获取法线方向
    float3 normal = normalSampler.sample(s, new_uv).rgb;
    //gamma 校正。因为我们读取了 sRGB 图片，并将 RGB 值当做法线方向，需要先校正 gamma(这里其实是对解码过的真实值重新进行了 gamma 编码)。
    normal = pow(normal, 0.45);
    //将法线范围从[0，1]转到[-1，1]
    normal = normal * 2 - 1;
    //将要显示的颜色采样坐标，与法线按 9:1 混合，以达到扭曲效果，同时过度处更平滑
    float2 mix_uv = mix(in.uv, normal.xy, 0.1);
    //按扭曲后坐标采样
    float3 rgb = colorSampler.sample(s, mix_uv).rgb;
    return half4(half3(rgb),1.0);
};
