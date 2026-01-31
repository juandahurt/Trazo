#include <metal_stdlib>

using namespace metal;

struct merge_fragment_input {
    float4 position     [[position]];
    float2 text_coord;
};

vertex merge_fragment_input merge_vert(
                                       constant float2* positions   [[buffer(0)]],
                                       constant float2* text_coords  [[buffer(1)]],
                                       uint vid                     [[vertex_id]]) {
    return {
        .position = float4(positions[vid], 0, 1),
        .text_coord = text_coords[vid]
    };
}

fragment float4 merge_frag(
                           merge_fragment_input input                   [[stage_in]],
                           texture2d<float, access::sample> texture     [[texture(0)]]) {
    constexpr sampler s;
    float4 color = texture.sample(s, input.text_coord);
    return color;
}
