//
//  SquareRippleAnimationShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/12.
//

#include <metal_stdlib>
#include "Common.h"

using namespace metal;

/*
 https://www.shadertoy.com/view/XsBfRW
 */
fragment float4 fragment_square_ripple_animation(float4 pixPos [[position]],
                                                 constant float2& res [[buffer(0)]],
                                                 constant float& time[[buffer(1)]]) {
    float aspect = res.y/res.x;
    float value;
    float2 uv = pixPos.xy / res.x;
    uv -= float2(0.5, 0.5*aspect);
    float rot = deg2rad(45.0);
    float2x2 m = float2x2(cos(rot), -sin(rot), sin(rot), cos(rot));
    uv  = m * uv;
    uv += float2(0.5, 0.5*aspect);
    uv.y+=0.5*(1.0-aspect);
    float2 pos = 10.0*uv;
    float2 rep = fract(pos);
    float dist = 2.0*min(min(rep.x, 1.0-rep.x), min(rep.y, 1.0-rep.y));
    float squareDist = length((floor(pos)+float2(0.5)) - float2(5.0) );
    
    float edge = sin(time-squareDist*0.5)*0.5+0.5;
    
    edge = (time-squareDist*0.5)*0.5;
    edge = 2.0*fract(edge*0.5);
    //value = 2.0*abs(dist-0.5);
    //value = pow(dist, 2.0);
    value = fract (dist*2.0);
    value = mix(value, 1.0-value, step(1.0, edge));
    //value *= 1.0-0.5*edge;
    edge = pow(abs(1.0-edge), 2.0);
    
    //edge = abs(1.0-edge);
    value = smoothstep( edge-0.05, edge, 0.95*value);
    
    
    value += squareDist*.1;
    //fragColor = float4(value);
    float4 output = mix(float4(1.0,1.0,1.0,1.0),float4(0.5,0.75,1.0,1.0), value);
    output.a = 0.25*clamp(value, 0.0, 1.0);
    
    return output;
}
