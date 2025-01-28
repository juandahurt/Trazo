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
