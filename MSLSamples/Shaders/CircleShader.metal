//
//  CircleShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

#include <metal_stdlib>
#include "Common.h"

using namespace metal;

/*
 https://www.shadertoy.com/view/XsjGDt
 */

float4 circle(float2 uv, float2 pos, float rad, float3 color) {
    float d = length(pos - uv) - rad;
    
    // https://cpprefjp.github.io/reference/algorithm/clamp.html
    float t = clamp(d, 0.0, 1.0);
    return float4(color, 1.0 - t);
}

fragment float4 fragment_circle(float4 pixPos [[position]],
                              constant float2& res [[buffer(0)]]) {
    
    float2 uv = pixPos.xy;
    float2 center = res.xy * 0.5;
    
    float radius = 0.25 * res.y;

    // Background layer
    float4 layer1 = float4(rgb(210.0, 222.0, 228.0), 1.0);
    
    // Circle
    float3 red = rgb(225.0, 95.0, 60.0);
    float4 layer2 = circle(uv, center, radius, red);
    
    // Blend the two
    float4 fragColor = mix(layer1, layer2, layer2.a);
    return fragColor;
}
