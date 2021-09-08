//
//  VertexShader.metal
//  MSLSamples
//
//  Created by Higashihara Yoki on 2021/09/08.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertexShader(unsigned int vid [[ vertex_id ]]) {
    const float4x4 vertices = float4x4(float4(-1, -1, 0.0, 1),
                                       float4( 1, -1, 0.0, 1),
                                       float4(-1,  1, 0.0, 1),
                                       float4( 1,  1, 0.0, 1));
    return vertices[vid];
}
