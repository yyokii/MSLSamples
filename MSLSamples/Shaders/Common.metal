//
//  Common.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

#include <metal_stdlib>
using namespace metal;


float3 rgb(float r, float g, float b) {
    float3 rgb = float3(r / 255.0, g / 255.0, b / 255.0);
    return rgb;
}

float4 circle(float2 uv, float2 pos, float rad, float3 color) {
    float d = length(pos - uv) - rad;
    
    // https://cpprefjp.github.io/reference/algorithm/clamp.html
    float t = clamp(d, 0.0, 1.0);
    return float4(color, 1.0 - t);
}
