//
//  Shaders.swift
//  Trazo
//
//  Created by Juan Hurtado on 26/01/25.
//

#include <metal_stdlib>

using namespace metal;

kernel void fill_color(texture2d<float, access::write> output [[texture(0)]], constant float4& color [[buffer(1)]], uint2 gid [[thread_position_in_grid]]) {
    output.write(color, gid);
}
