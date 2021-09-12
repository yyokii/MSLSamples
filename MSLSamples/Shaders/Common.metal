//
//  Common.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

#include <metal_stdlib>
using namespace metal;

float deg2rad(float num) {
    return num * M_PI_F / 180.0;
}

float mod(float a, float b) {
    return a - b * floor(a / b);
}

float2 mod(float2 a, float2 b) {
    return a - b * floor(a / b);
}

float3 rgb(float r, float g, float b) {
    float3 rgb = float3(r / 255.0, g / 255.0, b / 255.0);
    return rgb;
}
