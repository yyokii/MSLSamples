//
//  NeonCurveShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/09.
//

#include <metal_stdlib>
using namespace metal;

/*
 https://www.shadertoy.com/view/ftS3zD
 */
float DistancePointToLine(float2 p, float2 A, float2 B) {
    float l2 = distance(A, B);
    l2 *= l2;
    if (l2 == 0.0f)
        return distance(p, A);
    
    float t = max(0.0f, min(1.0f, dot(p - A, B - A) / l2));
    float2 projection = A + t * (B - A);
    return distance(p, projection);
}

fragment float4 fragment_neon_curve(float4 pixPos [[position]],
                                    constant float2& res [[buffer(0)]],
                                    constant float& time[[buffer(1)]]) {
    //[-1;1]
    float2 uv = pixPos.xy / (res.xy / 2.0) - 1.0;
    uv.x *= res.x/res.y;
    
    float3 col = float3(0, 0, 0);
    float dx = 0.1;
    for (float x = -1.5f-dx; x<=1.5f+dx; x+=dx){
        float2 lineA_1 = float2(x, cos((x+time)*4.0f)/5.0f);
        float2 lineB_1 = float2(x+dx, sin((x+time+dx)*3.0f)/5.0f);
        float p = DistancePointToLine(uv, lineA_1, lineB_1);
        
        col += float3(0.01f/p)*float3(abs((cos(time)+1.0)/5.0f),0.2f,0.7f);
    }
    
    float4 fragColor = float4(col, 1.0);
    return fragColor;
}
