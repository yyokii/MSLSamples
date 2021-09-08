//
//  PalettesShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

#include <metal_stdlib>
using namespace metal;


/*
 https://www.shadertoy.com/view/XsjGDt
 */

float3 pal(float t, float3 a, float3 b, float3 c, float3 d) {
    return a + b*cos( 6.28318*(c*t+d) );
}


fragment float4 fragment_palettes(float4 pixPos [[position]],
                              constant float2& res [[buffer(0)]]) {
    float2 p = pixPos.xy / res.xy;
    
    float3 col = pal(p.x, float3(0.5,0.5,0.5), float3(0.5,0.5,0.5), float3(1.0,1.0,1.0), float3(0.0,0.33,0.67));
    
    if( p.y>(1.0/7.0) ) col = pal( p.x, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.0,0.10,0.20) );
    if( p.y>(2.0/7.0) ) col = pal( p.x, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,1.0),float3(0.3,0.20,0.20) );
    if( p.y>(3.0/7.0) ) col = pal( p.x, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,1.0,0.5),float3(0.8,0.90,0.30) );
    if( p.y>(4.0/7.0) ) col = pal( p.x, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(1.0,0.7,0.4),float3(0.0,0.15,0.20) );
    if( p.y>(5.0/7.0) ) col = pal( p.x, float3(0.5,0.5,0.5),float3(0.5,0.5,0.5),float3(2.0,1.0,0.0),float3(0.5,0.20,0.25) );
    if( p.y>(6.0/7.0) ) col = pal( p.x, float3(0.8,0.5,0.4),float3(0.2,0.4,0.2),float3(2.0,1.0,1.0),float3(0.0,0.25,0.25) );
    
    // band
    float f = fract(p.y*7.0);
    // borders
    col *= smoothstep( 0.49, 0.47, abs(f-0.5) );
    // shadowing
    col *= 0.5 + 0.5*sqrt(4.0*f*(1.0-f));
    
    float4 fragColor = float4(col, 1.0);
    return fragColor;
}
