//
//  ElectroLineNoiseShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/15.
//

#include <metal_stdlib>
using namespace metal;

/*
 https://www.shadertoy.com/view/4scGWj
 */

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
float3 random3(float3 c) {
    float j = 4096.0*sin(dot(c,float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}

/* skew constants for 3d simplex functions */
//#define float F3 = 0.3333333;
#define F3 0.3333333
#define G3 0.1666667


/* 3d simplex noise */
float simplex3d(float3 p) {
    /* 1. find current tetrahedron T and it's four vertices */
    /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
    /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
    
    /* calculate s and x */
    float3 s = floor(p + dot(p, float3(F3)));
    float3 x = p - s + dot(s, float3(G3));
    
    /* calculate i1 and i2 */
    float3 e = step(float3(0.0), x - x.yzx);
    float3 i1 = e*(1.0 - e.zxy);
    float3 i2 = 1.0 - e.zxy*(1.0 - e);
    
    /* x1, x2, x3 */
    float3 x1 = x - i1 + G3;
    float3 x2 = x - i2 + 2.0*G3;
    float3 x3 = x - 1.0 + 3.0*G3;
    
    /* 2. find four surflets and store them in d */
    float4 w, d;
    
    /* calculate surflet weights */
    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);
    
    /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
    w = max(0.6 - w, 0.0);
    
    /* calculate surflet components */
    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);
    
    /* multiply d by w^4 */
    w *= w;
    w *= w;
    d *= w;
    
    /* 3. return the sum of the four surflets */
    return dot(d, float4(52.0));
}

float noise(float3 m) {
    return   0.5333333*simplex3d(m)
    +0.2666667*simplex3d(2.0*m)
    +0.1333333*simplex3d(4.0*m)
    +0.0666667*simplex3d(8.0*m);
}

fragment float4 fragment_electro_line_noise(float4 pixPos [[position]],
                                 constant float2& res [[buffer(0)]],
                                 constant float& time[[buffer(1)]]) {
    float2 uv = pixPos.xy / res.xy;
    uv = uv * 2. -1.;
    
    float2 p = pixPos.xy/res.x;
    float3 p3 = float3(p, time*0.4);
    
    float intensity = noise(float3(p3*12.0+12.0));
    
    float t = clamp((uv.x * -uv.x * 0.16) + 0.15, 0., 1.);
    float y = abs(intensity * -t + uv.y);
    
    float g = pow(y, 0.2);
    
    float3 col = float3(1.70, 1.48, 1.78);
    col = col * -g + col;
    col = col * col;
    col = col * col;

    return float4(col, 1);
}
