#include <metal_stdlib>

using namespace metal;

struct present_fragment_input {
    float4 position [[position]];
    float2 text_coord;
};

vertex present_fragment_input present_vert(
                                      constant float2* positions            [[buffer(0)]],
                                      constant float2* text_coords          [[buffer(1)]],
                                      constant float4x4& camera_matrix      [[buffer(2)]],
                                      constant float4x4& proj_matrix        [[buffer(3)]],
                                      uint vid                              [[vertex_id]])
{
    float4 position = proj_matrix * camera_matrix * float4(positions[vid], 0, 1);
    return {
        .position = position,
        .text_coord = text_coords[vid]
    };
}


fragment float4 present_frag(
                             present_fragment_input input                   [[stage_in]],
                             texture2d<float, access::sample> texture       [[texture(3)]])
{
    constexpr sampler s;
    float4 color = texture.sample(s, input.text_coord);
    return color;
}
