#include <metal_stdlib>

using namespace metal;

kernel void fill_color(texture2d<float, access::write> output [[texture(0)]],
                       constant float4& color [[buffer(1)]],
                       uint2 gid [[thread_position_in_grid]])
{
    output.write(color, gid);
}

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

vertex GrayScalePoint grayscale_point_vert(DrawablePoint point [[stage_in]],
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

fragment float4 grayscale_point_frag(
                                      GrayScalePoint pointData [[stage_in]],
                                      float2 pointCoord [[point_coord]])
//                                      texture2d<float, access::sample> shapeTexture [[texture(0)]],
//                                      texture2d<float, access::sample> granularityTexture [[texture(1)]])
{
    // TODO: implement with shape and granularity textures
//    constexpr sampler defaultSampler(coord::normalized, address::clamp_to_edge, filter::linear);
//    float granAlpha = granularityTexture.sample(defaultSampler, pointCoord).a;
//    float shapeAlpha = shapeTexture.sample(defaultSampler, pointCoord).a;
//    float alpha = granAlpha * shapeAlpha * pointData.opacity;
    float alpha = 1;
    return float4(alpha, alpha, alpha, 0.3);
}

kernel void colorize(
                     texture2d<float, access::read> inputTexture [[texture(0)]],
                     texture2d<float, access::write> outputTexture [[texture(1)]],
                     constant float4& color [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    float alpha = inputTexture.read(gid).a * color[3];
    float4 newColor = float4(alpha * color[0], alpha * color[1], alpha * color[2], alpha);
    outputTexture.write(newColor, gid);
}

kernel void merge(
                  texture2d<float, access::read> sourceTexture [[texture(0)]],
                  texture2d<float, access::read> destTexture [[texture(1)]],
                  texture2d<float, access::write> resultTexture [[texture(2)]],
                  uint2 gid [[thread_position_in_grid]])
{
    float4 srcPixel = sourceTexture.read(gid);
    float4 destPixel = destTexture.read(gid);
    
    float srcAlpha = srcPixel.a;
    
    float r = srcPixel[0] + destPixel[0] * (1 - srcAlpha);
    float g = srcPixel[1] + destPixel[1] * (1 - srcAlpha);
    float b = srcPixel[2] + destPixel[2] * (1 - srcAlpha);
    float a = srcPixel[3] + destPixel[3] * (1 - srcAlpha);
    
    resultTexture.write(float4(r, g, b, a), gid);
}
