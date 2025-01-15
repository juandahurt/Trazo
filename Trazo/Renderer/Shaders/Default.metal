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
};

struct InstanceUniforms {
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

vertex VertexOutput vertex_shader(
                                  VertexInput input [[stage_in]],
                                  constant float4x4* modelMatrices [[buffer(1)]],
                                  constant Uniforms& uniforms [[buffer(2)]],
                                  ushort iid [[instance_id]])
{
    auto position = uniforms.projectionMatrix * modelMatrices[iid] * float4(input.position, 0, 1);
    return {
        .position = position,
        .textCoordinate = input.textCoordiante
    };
}

fragment half4 fragment_shader(VertexOutput in [[stage_in]], texture2d<half> texture [[texture(3)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    half4 color = texture.sample(textureSampler, in.textCoordinate);
    return half4(0.3, 0.2, 1, color.a);
//    return color;
}
