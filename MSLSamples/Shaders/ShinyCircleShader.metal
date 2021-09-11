//
//  ShinyCircleShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/11.
//

#include <metal_stdlib>
using namespace metal;

/*
 https://www.shadertoy.com/view/ltBXRc
 */

float2x2 rotate2d(float angle) {
    return float2x2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}

float variation(float2 v1, float2 v2, float strength, float speed, float time) {
    return sin(
        dot(normalize(v1), normalize(v2)) * strength + time * speed
    ) / 100.0;
}

float3 paintCircle (float2 uv, float2 center, float rad, float width, float time) {
    
    float2 diff = center-uv;
    float len = length(diff);

    len += variation(diff, float2(0.0, 1.0), 5.0, 2.0, time);
    len -= variation(diff, float2(1.0, 0.0), 5.0, 2.0, time);
    
    float circle = smoothstep(rad-width, rad, len) - smoothstep(rad, rad+width, len);
    return float3(circle);
}


fragment float4 fragment_shiny_circle(float4 pixPos [[position]],
                                    constant float2& res [[buffer(0)]],
                                    constant float& time[[buffer(1)]]) {
    float2 uv = pixPos.xy / res.xy;
    uv.x *= 1.5;
    uv.x -= 0.25;
    
    float3 color;
    float radius = 0.35;
    float2 center = float2(0.5);
    
    //paint color circle
    color = paintCircle(uv, center, radius, 0.1, time);
    
    //color with gradient
    float2 v = rotate2d(time) * uv;
    color *= float3(v.x, v.y, 0.7-v.y*v.x);
    
    //paint white circle
    color += paintCircle(uv, center, radius, 0.01, time);
    
    return float4(color, 1.0);
}
