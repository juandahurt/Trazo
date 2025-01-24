//
//  Default.metal
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

#import <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 projectionMatrix;
    float4x4 modelMatrix;
};

struct VertexInput {
    float2 position [[attribute(0)]];
    float2 textCoordiante [[attribute(1)]];
};

struct VertexOutput {
    float4 position [[position]];
    float2 textCoordinate;
};

vertex VertexOutput vertex_shader(VertexInput input [[stage_in]])
{
    auto position = float4(input.position, 0, 1);
    return {
        .position = position,
        .textCoordinate = input.textCoordiante
    };
}

fragment half4 fragment_shader(
                               VertexOutput in [[stage_in]],
                               texture2d<half> texture [[texture(3)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    half4 color = texture.sample(textureSampler, in.textCoordinate);
    return color;
}



kernel void blend_textures(
    texture2d<half, access::read> canvasTexture [[texture(0)]],
    texture2d<half, access::read> brushTexture [[texture(1)]],
    texture2d<half, access::write> outputTexture [[texture(2)]],
    uint2 gid [[thread_position_in_grid]],
    constant uint2& offset [[buffer(3)]]
) {
    // Map to global canvas position
    uint2 global_gid = gid + offset;

    // Ensure the thread is within bounds
    if (global_gid.x >= canvasTexture.get_width() || global_gid.y >= canvasTexture.get_height()) {
        return;
    }

    // Blend the brush and canvas colors
    half4 canvasColor = canvasTexture.read(global_gid);
    half4 brushColor = brushTexture.read(gid); // Brush texture is always small
    half4 blendedColor = mix(canvasColor, brushColor, brushColor.a);

    // Write to the output texture
    outputTexture.write(blendedColor, global_gid);
}
