#include <metal_stdlib>

using namespace metal;

struct TileRect {
    uint2 origin;
    uint2 size;
};

kernel void fill_color(texture2d<float, access::write> output   [[texture(0)]],
                       constant float4& color                   [[buffer(1)]],
                       constant TileRect* tiles                 [[buffer(0)]],
                       uint2 tid                                [[thread_position_in_threadgroup]],
                       uint2 tgID                               [[threadgroup_position_in_grid]]
                       ) {
    constexpr uint threadsPerTG = 16;
    constexpr uint tgPerTile    = 4;
    
    uint tileID = tgID.x / tgPerTile;
    
    uint tgLocalX = tgID.x % tgPerTile;
    uint tgLocalY = tgID.y;
    
    TileRect tile = tiles[tileID];
    
    uint2 blockOrigin = uint2(
                              tgLocalX * threadsPerTG,
                              tgLocalY * threadsPerTG
                              );
    
    uint2 localPixel = blockOrigin + tid;
    
    if (localPixel.x >= tile.size.x ||
        localPixel.y >= tile.size.y)
        return;
    
    uint2 pixel = tile.origin + localPixel;
    output.write(color, pixel);
}
