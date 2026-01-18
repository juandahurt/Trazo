#include <metal_stdlib>

using namespace metal;

struct GrayScalePoint {
    float4 position [[position]];
    float opacity;
    float2 uv;
    float3 color;
};

vertex GrayScalePoint grayscale_point_vert(constant float2* positions [[buffer(0)]],
                                            constant float4x4& modelMatrix [[buffer(1)]],
                                            constant float4x4& projectionMatrix [[buffer(2)]],
                                            constant float& opacity [[buffer(3)]],
                                           constant float4x4* transforms [[buffer(4)]],
                                           constant float2* uv [[buffer(5)]],
                                           constant float3& color [[buffer(6)]],
                                           uint vertexId [[vertex_id]],
                                           uint instanceId [[instance_id]])
{
    float4 position = projectionMatrix * modelMatrix * transforms[instanceId] * float4(positions[vertexId], 0, 1);
    return {
        .position = position,
        .opacity = opacity,
        .uv = uv[vertexId],
        .color = color
    };
}

fragment float4 grayscale_point_frag(
                                      GrayScalePoint pointData [[stage_in]])
//                                      texture2d<float, access::sample> shapeTexture [[texture(0)]],
//                                      texture2d<float, access::sample> granularityTexture [[texture(1)]])
{
    constexpr sampler defaultSampler(coord::normalized, address::clamp_to_edge, filter::linear);
//    float granAlpha = granularityTexture.sample(defaultSampler, pointData.uv).a;
//    float shapeAlpha = shapeTexture.sample(defaultSampler, pointData.uv).a;
    float alpha = /*granAlpha * shapeAlpha * */pointData.opacity;
    return float4(pointData.color[0], pointData.color[1], pointData.color[2], alpha);
}
