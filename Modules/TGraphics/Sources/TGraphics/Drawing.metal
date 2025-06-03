#include <metal_stdlib>

using namespace metal;

struct TextureOuput {
    float4 position [[position]];
    float2 textCoord;
};

vertex TextureOuput draw_texture_vert(
                                      constant float2* positions [[buffer(0)]],
                                      constant float2* textCoordinates [[buffer(1)]],
                                      constant float4x4& modelMatrix [[buffer(2)]],
                                      constant float4x4& projectionMatrix [[buffer(3)]],
                                      uint vid [[vertex_id]])
{
    float4 position = projectionMatrix * modelMatrix * float4(positions[vid], 0, 1);
    return {
        .position = position,
        .textCoord = textCoordinates[vid]
    };
}


fragment float4 draw_texture_frag(TextureOuput data [[stage_in]],
                                  texture2d<float, access::sample> texture [[texture(3)]])
{
    constexpr sampler s;
    float4 color = texture.sample(s, data.textCoord);
    return color;
}
