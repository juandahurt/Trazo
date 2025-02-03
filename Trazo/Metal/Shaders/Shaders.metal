//
//  Shaders.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

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
                                      uint vid [[vertex_id]])
{
    return {
        .position = float4(positions[vid], 0, 1),
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


// MARK: - Grayscale points
struct GrayScalePoint {
    float4 position [[position]];
    float pointSize [[point_size]];
};

vertex GrayScalePoint gray_scale_point_vert(constant float2* positions [[buffer(0)]], uint vid [[vertex_id]]) {
    return {
        .position = float4(positions[vid], 0, 1),
        .pointSize = 15
    };
}

fragment float4 gray_scale_point_frag(
                                      GrayScalePoint pointData [[stage_in]],
                                      float2 pointCoord [[point_coord]])
{
    float2 center = float2(0.5, 0.5);
    float dist = distance(center, pointCoord);
    float alpha = smoothstep(0.5, 0, dist);
    return float4(alpha, alpha, alpha, alpha);
}

// MARK: - Colorization
kernel void colorize(
                     texture2d<float, access::read> grayscaleTexture [[texture(0)]],
                     texture2d<float, access::write> outputTexture [[texture(1)]],
                     constant float3& color [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    float alpha = grayscaleTexture.read(gid).a;
    float4 newColor = float4(alpha * color[0], alpha * color[1], alpha * color[2], alpha);
    outputTexture.write(newColor, gid);
}

// MARK: - Merge
kernel void merge_textures(
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
