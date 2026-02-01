#include <metal_stdlib>

using namespace metal;

struct stroke_fragment_input {
    float4 position [[position]];
    float opacity;
    float2 uv;
    float4 color;
};

vertex stroke_fragment_input stroke_vert(constant float2* positions             [[buffer(0)]],
                                           constant float4x4& projectionMatrix  [[buffer(1)]],
                                           constant float& opacity              [[buffer(2)]],
                                           constant float4x4* transforms        [[buffer(3)]],
                                           constant float2* uv                  [[buffer(4)]],
                                           constant float4& color               [[buffer(5)]],
                                           uint vertexId                        [[vertex_id]],
                                           uint instanceId                      [[instance_id]])
{
    float4 position = projectionMatrix * /*modelMatrix **/ transforms[instanceId] * float4(positions[vertexId], 0, 1);
    return {
        .position = position,
        .opacity = opacity,
        .uv = uv[vertexId],
        .color = color
    };
}

fragment float4 stroke_frag(stroke_fragment_input input                    [[stage_in]],
                                     texture2d<float, access::sample> shapeTexture  [[texture(0)]])
//                                      texture2d<float, access::sample> granularityTexture [[texture(1)]])
{
    constexpr sampler defaultSampler(coord::normalized, address::clamp_to_edge, filter::linear);
//    float granAlpha = granularityTexture.sample(defaultSampler, pointData.uv).a;
//    float shapeAlpha = shapeTexture.sample(defaultSampler, pointData.uv).a;
    float alpha = /*granAlpha **/ /*shapeAlpha **/ input.opacity;
    return float4(input.color[0], input.color[1], input.color[2], alpha);
}
