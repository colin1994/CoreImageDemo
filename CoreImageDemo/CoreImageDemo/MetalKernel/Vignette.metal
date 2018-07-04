//
//  Vignette.metal
//  CoreImageDemo
//
//  Created by Colin on 2018/7/3.
//  Copyright © 2018年 Colin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {
    float4 vignetteMetal(sample_t image, float2 center, float radius, float alpha, destination dest) {
        // 计算出当前点与中心的距离
        float distance2 = distance(dest.coord(), center);
        
        // 根据距离计算出暗淡程度
        float darken = 1.0 - (distance2 / radius * alpha);
        // 返回该像素点最终的色值
        image.rgb *= darken;
        
        return image.rgba;
    }
}}
