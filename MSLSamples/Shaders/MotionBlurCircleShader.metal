//
//  MotionBlurCircleShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/11.
//

#include <metal_stdlib>
#include "Common.h"

using namespace metal;


/*
 https://www.shadertoy.com/view/XdXXz4
 */

float4 circle(float2 p, float2 center, float radius) {
    return mix(float4(1,1,1,0), float4(1,0,0,1), smoothstep(radius + 0.005, radius - 0.005, length(p - center)));
}

float4 scene(float2 uv, float t) {
    return circle(uv, float2(0, sin(t * 16.0) * (sin(t) * 0.5 + 0.5) * 0.5), 0.07);
}

fragment float4 fragment_motion_blur_circle(float4 pixPos [[position]],
                                    constant float2& res [[buffer(0)]],
                                    constant float& time[[buffer(1)]]) {
    float2 resol = res.xy / float2(6,1);
    float2 coord = mod(pixPos.xy, resol);
    float view = floor(pixPos.x / resol.x);
    
    float2 uv = coord / resol;
    uv = uv * 2.0 - float2(1);
    uv.x *= resol.x / resol.y;
        
    float frametime = (60. / (floor(view / 2.) + 1.));
    float modifiedTime = floor((time + 3.) * frametime) / frametime;
    float4 mainCol = scene(uv, modifiedTime);
    
    float4 blurCol = float4(0,0,0,0);
    for(int i = 0; i < 32; i++)
    {
        if ((i < 8 || view >= 2.0) && (i < 16 || view >= 4.0))
        {
            blurCol += scene(uv, modifiedTime - float(i) * (1. / 15. / 32.));
        }
    }
    blurCol /= pow(2., floor(view / 2.) + 3.);
    
    if (mod(view, 2.) == 0.)
        return mainCol;
    else
        return blurCol;
}
