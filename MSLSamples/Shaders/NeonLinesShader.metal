//
//  NeonLinesShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/14.
//

#include <metal_stdlib>
using namespace metal;

/*
 https://www.shadertoy.com/view/WdscR4
 */

#define PI 3.1415926535
#define TAU 6.2831853071

float line(float2 A, float2 B, float2 C, float thickness) {
    float2 AB = B-A;
    float2 AC = C-A;

    float t = dot(AC, AB) / dot(AB, AB);
    t = min(1.0, max(0.0, t));
    
    float2 Q = A + t * AB;
    
    float dist = length(Q-C);
    return smoothstep(-0.01, -dist, -thickness) + smoothstep(-0.02, dist, thickness);
}

fragment float4 fragment_neon_lines(float4 pixPos [[position]],
                                    constant float2& res [[buffer(0)]],
                                    constant float& time[[buffer(1)]]) {
    float2 uv = (pixPos.xy -.5*res.xy)/res.y;

    float3 color = float3(0.0);
    
    for (int i = 0; i < 20; ++i) {
        float r = 0.5 - sin(time + float(i) * 0.8 * PI) * 0.1;
        float angle = time * 0.2 + float(i+1) * 0.1 * PI;

        float2 dir = float2(cos(angle), sin(angle)) * r;

        float2 A = -dir * 0.5;
        float2 B = -dir * 0.3;

        float t = time * 0.5 + float(i) * 0.1 * TAU;
        float3 rgb = float3(
            sin(t          ) * 0.5 + 0.5,
            sin(t + PI/2.0) * 0.5 + 0.5,
            sin(t + PI      ) * 0.5 + 0.5
        );

        color += line(A, B, uv, 0.001) * rgb;
    }
    
    color = color * 0.4 + sqrt(color*color / (color*color + 1.0)) * 0.6;

    return float4(float3(color), 1.0);
}
