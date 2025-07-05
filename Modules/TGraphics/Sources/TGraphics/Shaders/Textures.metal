#include <metal_stdlib>

using namespace metal;

kernel void fill_color(texture2d<float, access::write> output [[texture(0)]],
                       constant float4& color [[buffer(1)]],
                       uint2 gid [[thread_position_in_grid]])
{
    output.write(color, gid);
}

kernel void merge_textures(
                           texture2d<float, access::read> sourceTexture [[texture(0)]],
                           texture2d<float, access::read> destTexture [[texture(1)]],
                           texture2d<float, access::write> resultTexture [[texture(2)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float4 srcPixel = sourceTexture.read(gid);
    float4 destPixel = destTexture.read(gid);
    
    float srcAlpha = srcPixel.a;
    
    float r = srcPixel[0] + destPixel[0] * (1 - srcAlpha);
    float g = srcPixel[1] + destPixel[1] * (1 - srcAlpha);
    float b = srcPixel[2] + destPixel[2] * (1 - srcAlpha);
    float a = srcPixel[3] + destPixel[3] * (1 - srcAlpha);
    
    resultTexture.write(float4(r, g, b, a), gid);
}

kernel void colorize(
                     texture2d<float, access::read> grayscaleTexture [[texture(0)]],
                     texture2d<float, access::write> outputTexture [[texture(1)]],
                     constant float4& color [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    float alpha = grayscaleTexture.read(gid).a * color[3];
    float4 newColor = float4(alpha * color[0], alpha * color[1], alpha * color[2], alpha);
    outputTexture.write(newColor, gid);
}


kernel void subtract_texture(
                           texture2d<float, access::read> textureA [[texture(0)]],
                           texture2d<float, access::read> textureB [[texture(1)]],
                           texture2d<float, access::write> outputTexture [[texture(2)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float alphaToSubstract = textureB.read(gid).a;
    float4 oldColor = textureA.read(gid);
    float4 newColor = oldColor * (1 - alphaToSubstract);
    outputTexture.write(newColor, gid);
}
