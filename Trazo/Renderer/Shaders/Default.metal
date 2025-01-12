//
//  Default.metal
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

#import <metal_stdlib>
using namespace metal;

struct Uniforms {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct InstanceUniforms {
    float4x4 modelMatrix;
};

struct VertexInput {
    float2 position [[attribute(0)]];
};

struct VertexOutput {
    float4 position [[position]];
};

vertex VertexOutput vertex_shader(
                                  VertexInput input [[stage_in]],
                                  constant float4x4* modelMatrices [[buffer(1)]],
                                  ushort iid [[instance_id]])
{
    auto position = modelMatrices[iid] * float4(input.position, 0, 1);
    return {
        .position = position
    };
}

fragment half4 fragment_shader(constant VertexOutput& in) {
    return half4(0.3, 0.2, 1, 0.1);
}
