
//----------------------------------------------------------------------------------------------------------
// HimoToon FX-Shader-Library
// https://github.com/himoqiuhan/FX-Shader-Library
// Copyright (c) 2025 楸涵. All rights reserved.
// Licensed under the MIT License 
// You may not use this file except in compliance with the License.You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
//----------------------------------------------------------------------------------------------------------

#ifndef HIMOTOON_FX_COMMON_INCLUDED
#define HIMOTOON_FX_COMMON_INCLUDED

float4 Hexagon(float2 p) 
{
    float2 q = float2(p.x * 2.0 * 0.5773503, p.y + p.x * 0.5773503);
                
    float2 pi = floor(q);
    float2 pf = frac(q);
                
    float v = fmod(pi.x + pi.y, 3.0);
                
    float ca = step(1.0, v);
    float cb = step(2.0, v);
    float2 ma = step(pf.xy, pf.yx);
                
    // 到边界的距离
    float e = dot(ma, 1.0 - pf.yx + ca * (pf.x + pf.y - 1.0) + cb * (pf.yx - 2.0 * pf.xy));
                
    // 到中心的距离
    p = float2(q.x + floor(0.5 + p.y / 1.5), 4.0 * p.y / 3.0) * 0.5 + 0.5;
    float f = length((frac(p) - 0.5) * float2(1.0, 0.85));
                
    return float4(pi + ca - cb * ma, e, f);
}

float2 CalculatePolarCoordinatesEx(float2 uv, float2 center, float radiusScale, float angleOffset)
{
    float2 dir = uv - center;
    
    // 计算半径并应用缩放
    float radius = length(dir) * radiusScale;
    
    // 计算角度并应用偏移
    float angle = atan2(dir.y, dir.x);
    angle = angle / (2.0 * 3.1415926) + 0.5 + angleOffset;
    
    // 确保角度在0-1范围内
    angle = frac(angle);
    
    return float2(radius, angle);
}

float2 CalculatePolarCoordinates(float2 uv, float2 center)
{
    return CalculatePolarCoordinatesEx(uv, center, 1.0, 0.0);
}

float Luminance(half3 color)
{
    return dot(color, half3(0.2126729f, 0.7151522f, 0.072175f));
}

#endif
