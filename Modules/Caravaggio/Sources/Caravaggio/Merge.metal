#include <metal_stdlib>

using namespace metal;

struct TileRect {
    uint2 origin;
    uint2 size;
};

kernel void merge(
                  texture2d<float, access::read> sourceTexture  [[texture(0)]],
                  texture2d<float, access::read> destTexture    [[texture(1)]],
                  texture2d<float, access::write> resultTexture [[texture(2)]],
                  constant TileRect* tiles                      [[buffer(0)]],
                  uint2 tid                                     [[thread_position_in_threadgroup]],
                  uint2 tgID                                    [[threadgroup_position_in_grid]]
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
    float4 srcPixel = sourceTexture.read(pixel);
    float4 destPixel = destTexture.read(pixel);
    
    float srcAlpha = srcPixel.a;
    
    float r = srcPixel[0] + destPixel[0] * (1 - srcAlpha);
    float g = srcPixel[1] + destPixel[1] * (1 - srcAlpha);
    float b = srcPixel[2] + destPixel[2] * (1 - srcAlpha);
    float a = srcPixel[3] + destPixel[3] * (1 - srcAlpha);
    
    resultTexture.write(float4(r, g, b, a), pixel);
}
