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

struct GrayScalePoint {
    float4 position [[position]];
    float pointSize [[point_size]];
    float opacity;
};

struct DrawablePoint {
    float2 position [[attribute(0)]];
    float size [[attribute(1)]];
};

vertex GrayScalePoint gray_scale_point_vert(DrawablePoint point [[stage_in]],
                                            constant float4x4& modelMatrix [[buffer(1)]],
                                            constant float4x4& projectionMatrix [[buffer(2)]],
                                            constant float& opacity [[buffer(3)]])
{
    float4 position = projectionMatrix * modelMatrix * float4(point.position, 0, 1);
    return {
        .position = position,
        .pointSize = point.size,
        .opacity = opacity
    };
}

fragment float4 gray_scale_point_frag(
                                      GrayScalePoint pointData [[stage_in]],
                                      float2 pointCoord [[point_coord]])
{
    float radius = 0.3;
    float2 center = float2(0.5, 0.5);
    float dist = distance(center, pointCoord);
    if (dist <= radius) {
        return float4(1, 1, 1, 1) * pointData.opacity;
    }
    
    float alpha = smoothstep(0.5, radius, dist) * pointData.opacity;
    return float4(alpha, alpha, alpha, alpha);
}
