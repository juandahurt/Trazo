//
//  Default.metal
//  Trazo
//
//  Created by Juan Hurtado on 31/12/24.
//

#import <metal_stdlib>
using namespace metal;

struct VertexInput {
    float2 position [[attribute(0)]];
};

struct VertexOutput {
    float4 position [[position]];
};

vertex VertexOutput vertex_shader(VertexInput input [[stage_in]]) {
    return {
        .position = float4(input.position, 0, 1)
    };
}

fragment half4 fragment_shader(constant VertexOutput& in) {
    return half4(0.3, 0.2, 1, 0.1);
}
