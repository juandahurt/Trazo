#include <metal_stdlib>

using namespace metal;

struct stroke_fragment_input {
    float4 position [[position]];
    float opacity;
    float2 uv;
    float4 color;
};

struct drawable_point {
    float2 position;
    float size;
    float opacity;
    float angle;
};

vertex stroke_fragment_input stroke_vert(constant float2* vertices            [[buffer(0)]],
                                         constant float4x4& projectionMatrix  [[buffer(1)]],
                                         constant float& opacity              [[buffer(2)]],
                                         constant drawable_point* points      [[buffer(3)]],
                                         constant float2* uv                  [[buffer(4)]],
                                         constant float4& color               [[buffer(5)]],
                                         uint vertexId                        [[vertex_id]],
                                         uint instanceId                      [[instance_id]])
{
        drawable_point p = points[instanceId];
        float cosA = cos(p.angle);
        float sinA = sin(p.angle);
        
        float4x4 scale = float4x4(
            float4(p.size, 0, 0, 0),
            float4(0, p.size, 0, 0),
            float4(0, 0, 1, 0),
            float4(0, 0, 0, 1)
        );
        float4x4 rotation = float4x4(
            float4( cosA, sinA, 0, 0),
            float4(-sinA, cosA, 0, 0),
            float4(0,     0,    1, 0),
            float4(0,     0,    0, 1)
        );
        float4x4 translation = float4x4(
            float4(1, 0, 0, 0),
            float4(0, 1, 0, 0),
            float4(0, 0, 1, 0),
            float4(p.position.x, p.position.y, 0, 1)
        );
        
        float4x4 transform = translation * rotation * scale;
        float4 position = projectionMatrix * transform * float4(vertices[vertexId], 0, 1);
        
        return {
            .position = position,
            .opacity = p.opacity,
            .uv = uv[vertexId],
            .color = color
        };;
}

fragment float4 stroke_frag(stroke_fragment_input input                         [[stage_in]],
                            texture2d<float, access::sample> shapeTexture       [[texture(0)]],
                            texture2d<float, access::sample> granularityTexture [[texture(1)]])
{
    constexpr sampler defaultSampler(coord::normalized, address::clamp_to_edge, filter::linear);
    float granAlpha = granularityTexture.sample(defaultSampler, input.uv).a;
    float shapeAlpha = shapeTexture.sample(defaultSampler, input.uv).a;
    float alpha = granAlpha * shapeAlpha * input.opacity;
    return float4(input.color[0], input.color[1], input.color[2], alpha);
}
