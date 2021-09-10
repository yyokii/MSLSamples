//
//  ColorfulCirclesShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/10.
//

#include <metal_stdlib>
#include "Common.h"

using namespace metal;

/*
 https://www.shadertoy.com/view/4s2yW1
 
 元のソースではinoutを利用しているが、それをmetalに落とし込む方法に苦戦したので、値渡し引数に渡し関数が値を返すようにしています。
 */

float2 Rotate(float2 p, float a ) {
    return cos( a ) * p + sin( a ) * float2( p.y, -p.x );
}

float Circle(float2 p, float r ) {
    return ( length( p / r ) - 1.0 ) * r;
}

float Rand(float2 c ) {
    return fract( sin( dot( c.xy, float2( 12.9898, 78.233 ) ) ) * 43758.5453 );
}

float saturate( float x ) {
    return clamp( x, 0.0, 1.0 );
}

float3 BokehLayer( float3 color, float2 p, float3 c )
{
    float wrap = 450.0;
    if ( mod( floor( p.y / wrap + 0.5 ), 2.0 ) == 0.0 ) {
        p.x += wrap * 0.5;
    }
    
    float2 p2 = mod( p + 0.5 * wrap, wrap ) - 0.5 * wrap;
    float2 cell = floor( p / wrap + 0.5 );
    float cellR = Rand( cell );
        
    c *= fract( cellR * 3.33 + 3.33 );
    float radius = mix( 30.0, 70.0, fract( cellR * 7.77 + 7.77 ) );
    p2.x *= mix( 0.9, 1.1, fract( cellR * 11.13 + 11.13 ) );
    p2.y *= mix( 0.9, 1.1, fract( cellR * 17.17 + 17.17 ) );
    
    float sdf = Circle( p2, radius );
    float circle = 1.0 - smoothstep( 0.0, 1.0, sdf * 0.04 );
    float glow     = exp( -sdf * 0.025 ) * 0.3 * ( 1.0 - circle );
    return color += c * ( circle + glow );
}

fragment float4 fragment_colorful_circles(float4 pixPos [[position]],
                                    constant float2& res [[buffer(0)]],
                                    constant float& time[[buffer(1)]]) {
    float2 uv = pixPos.xy / res.xy;
    float2 p = ( 2.0 * pixPos.xy - res.xy ) / res.x * 1000.0;
    
    // background
    float3 color = mix( float3( 0.3, 0.1, 0.3 ), float3( 0.1, 0.4, 0.5 ), dot( uv, float2( 0.2, 0.7 ) ) );

    float modifiedTime = time - 15.0;
    
    float2 rotatedP = Rotate( p, 0.2 + modifiedTime * 0.03 );
    float3 bokehLayerColor = BokehLayer( color, rotatedP + float2( -50.0 * modifiedTime +  0.0, 0.0  ), 3.0 * float3( 0.4, 0.1, 0.2 ) );
    rotatedP = Rotate( rotatedP, 0.3 - modifiedTime * 0.05 );
    bokehLayerColor = BokehLayer( bokehLayerColor, rotatedP + float2( -70.0 * modifiedTime + 33.0, -33.0 ), 3.5 * float3( 0.6, 0.4, 0.2 ) );
    rotatedP = Rotate( rotatedP, 0.5 + modifiedTime * 0.07 );
    bokehLayerColor = BokehLayer( bokehLayerColor, rotatedP + float2( -60.0 * modifiedTime + 55.0, 55.0 ), 3.0 * float3( 0.4, 0.3, 0.2 ) );
    rotatedP = Rotate( rotatedP, 0.9 - modifiedTime * 0.03 );
    bokehLayerColor = BokehLayer( bokehLayerColor, rotatedP + float2( -25.0 * modifiedTime + 77.0, 77.0 ), 3.0 * float3( 0.4, 0.2, 0.1 ) );
    rotatedP = Rotate( rotatedP, 0.0 + modifiedTime * 0.05 );
    bokehLayerColor = BokehLayer( bokehLayerColor, rotatedP + float2( -15.0 * modifiedTime + 99.0, 99.0 ), 3.0 * float3( 0.2, 0.0, 0.4 ) );

    return float4( bokehLayerColor, 1.0 );
}
