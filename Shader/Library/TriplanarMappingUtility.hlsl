
//----------------------------------------------------------------------------------------------------------
// HimoToon FX-Shader-Library
// https://github.com/himoqiuhan/FX-Shader-Library
// Copyright (c) 2025 楸涵. All rights reserved.
// Licensed under the MIT License 
// You may not use this file except in compliance with the License.You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
//----------------------------------------------------------------------------------------------------------

#ifndef HIMOTOON_HLSL_TRIPLANAR_MAPPING_UTILITY_INCLUDED
#define HIMOTOON_HLSL_TRIPLANAR_MAPPING_UTILITY_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

float CheapContrast(float value, float contrast)
{
    float sub = 0 - contrast;
    float add = contrast + 1;
    float output = saturate(lerp(sub, add, value));
    return output;
}

struct TriplanarParams
{
    float2 uv_XZ;
    float2 uv_XY;
    float2 uv_ZY;
    float blendFactor_WithZY;
    float blendFactor_WithXZ;
#ifdef _NORMALMAP
    float3 vertexNormalWS;
    float3x3 TBN;
#endif
};

TriplanarParams GetTriplanarParams(float3 positionWS, float3 normalWS, float3 scale, float4 tillingOffset, float blendContrast
    #ifdef _NORMALMAP
    , float3x3 TBN
    #endif
)
{
    TriplanarParams triplanarParams;
    triplanarParams.uv_XZ = (positionWS.xz * scale.xz) * tillingOffset.xy + tillingOffset.zw;
    triplanarParams.uv_XY = (positionWS.xy * scale.xy) * tillingOffset.xy + tillingOffset.zw;
    triplanarParams.uv_ZY = (positionWS.zy * scale.zy) * tillingOffset.xy + tillingOffset.zw;

    float3 normalizedNormalWS = NormalizeNormalPerPixel(abs(normalWS));
    triplanarParams.blendFactor_WithZY = CheapContrast(normalizedNormalWS.x, blendContrast);
    triplanarParams.blendFactor_WithXZ = CheapContrast(normalizedNormalWS.y, blendContrast);

#ifdef _NORMALMAP
    triplanarParams.vertexNormalWS = normalizedNormalWS;
    triplanarParams.TBN = TBN;
#endif
    return triplanarParams;
}

float Sign(float x)
{
    return x > 0 ? 1.0 : -1.0;
}

float3 Sign(float3 x)
{
    return float3(Sign(x.x), Sign(x.y), Sign(x.z));
}

#define TRIPLANAR_SAMPLE_TEXTURE2D(texture, sampler, triplanarParams, finalColor) \
    half4 color_XZ = SAMPLE_TEXTURE2D(texture, sampler, triplanarParams.uv_XZ); \
    half4 color_XY = SAMPLE_TEXTURE2D(texture, sampler, triplanarParams.uv_XY); \
    half4 color_ZY = SAMPLE_TEXTURE2D(texture, sampler, triplanarParams.uv_ZY); \
    finalColor = lerp( \
        lerp(color_XY, color_ZY, triplanarParams.blendFactor_WithZY) \
        , color_XZ, triplanarParams.blendFactor_WithXZ)

#define SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE(texture, sampler, uv, TBN, outNormalWS) \
    outNormalWS.xyz = TransformTangentToWorldDir(UnpackNormal(SAMPLE_TEXTURE2D(texture, sampler, uv)), TBN)

#define SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE_WITH_SCALE(texture, sampler, uv, TBN, scale, outNormalWS) \
outNormalWS = TransformTangentToWorldDir(UnpackNormalScale(SAMPLE_TEXTURE2D(texture, sampler, uv), scale), TBN)

#define TRIPLANAR_SAMPLE_NORMAL_TEXTURE2D(texture, sampler, triplanarParams, finalNormal) \
    half3 color_ZY = 0; \
    half3 color_XZ = 0; \
    half3 color_XY = 0; \
    SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE(texture, sampler, triplanarParams.uv_ZY, triplanarParams.TBN, color_ZY); \
    SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE(texture, sampler, triplanarParams.uv_XZ, triplanarParams.TBN, color_XZ); \
    SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE(texture, sampler, triplanarParams.uv_XY, triplanarParams.TBN, color_XY); \
    color_ZY = color_ZY.zyx; \
    color_XZ = color_XZ.xyz; \
    color_XY *= half3(-1,1,1); \
    float3 vertexNormalWS = triplanarParams.vertexNormalWS; \
    float3 sign = Sign(vertexNormalWS); \
    float3 normal_ZY = (float3(vertexNormalWS.x * color_ZY.x, vertexNormalWS.y + color_ZY.y, vertexNormalWS.z + color_ZY.z * sign.x)); \
    float3 normal_XZ = (float3(vertexNormalWS.x + color_XZ.x * sign.y, vertexNormalWS.y * color_XZ.y, vertexNormalWS.z + color_XZ.z)); \
    float3 normal_XY = (float3(vertexNormalWS.x + color_XY.x * sign.z, vertexNormalWS.y + color_XY.y, vertexNormalWS.z * color_XY.z)); \
    float3 triplanarNormalTS = lerp( \
        lerp(normal_XY, normal_ZY, triplanarParams.blendFactor_WithZY) \
            , normal_XZ, triplanarParams.blendFactor_WithXZ); \
    finalNormal.xyz = TransformWorldToTangentDir(triplanarNormalTS, triplanarParams.TBN, true)

#define TRIPLANAR_SAMPLE_NORMAL_TEXTURE2D_WITH_SCALE(texture, sampler, triplanarParams, scale, finalNormal) \
    half3 color_ZY = 0; \
    half3 color_XZ = 0; \
    half3 color_XY = 0; \
    SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE_WITH_SCALE(texture, sampler, triplanarParams.uv_ZY, triplanarParams.TBN, scale, color_ZY); \
    SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE_WITH_SCALE(texture, sampler, triplanarParams.uv_XZ, triplanarParams.TBN, scale, color_XZ); \
    SAMPLE_NORMAL_TEXTURE_TO_WORLDSPACE_WITH_SCALE(texture, sampler, triplanarParams.uv_XY, triplanarParams.TBN, scale, color_XY); \
    color_ZY = color_ZY.zyx; \
    color_XZ = color_XZ.xyz; \
    color_XY *= half3(-1,1,1); \
    float3 vertexNormalWS = triplanarParams.vertexNormalWS; \
    float3 sign = Sign(vertexNormalWS); \
    float3 normal_ZY = (float3(vertexNormalWS.x * color_ZY.x, vertexNormalWS.y + color_ZY.y, vertexNormalWS.z + color_ZY.z * sign.x)); \
    float3 normal_XZ = (float3(vertexNormalWS.x + color_XZ.x * sign.y, vertexNormalWS.y * color_XZ.y, vertexNormalWS.z + color_XZ.z)); \
    float3 normal_XY = (float3(vertexNormalWS.x + color_XY.x * sign.z, vertexNormalWS.y + color_XY.y, vertexNormalWS.z * color_XY.z)); \
    float3 triplanarNormalTS = lerp( \
        lerp(normal_XY, normal_ZY, triplanarParams.blendFactor_WithZY) \
        , normal_XZ, triplanarParams.blendFactor_WithXZ); \
    finalNormal.xyz = TransformWorldToTangentDir(triplanarNormalTS, triplanarParams.TBN, true)

half SampleOcclusionTriplanar(TriplanarParams params)
{
    #ifdef _OCCLUSIONMAP
        half4 color = 0;
        TRIPLANAR_SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap, params, color);
        half occ = color.g;
        return LerpWhiteTo(occ, _OcclusionStrength);
    #else
        return half(1.0);
    #endif
}

half3 SampleNormalTriplanar(TriplanarParams params, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = half(1.0))
{
#ifdef _NORMALMAP
    half4 n = 0;
    #if BUMP_SCALE_NOT_SUPPORTED
        TRIPLANAR_SAMPLE_NORMAL_TEXTURE2D(bumpMap, sampler_bumpMap, params, n);
    #else
        TRIPLANAR_SAMPLE_NORMAL_TEXTURE2D_WITH_SCALE(bumpMap, sampler_bumpMap, params, scale, n);
    #endif
    return n;
#else
    return half3(0.0h, 0.0h, 1.0h);
#endif
}

half3 SampleEmissionTriplanar(TriplanarParams params, half3 emissionColor, TEXTURE2D_PARAM(emissionMap, sampler_emissionMap))
{
#ifndef _EMISSION
    return 0;
#else
    half4 emissionTextureColor = 0;
    TRIPLANAR_SAMPLE_TEXTURE2D(emissionMap, sampler_emissionMap, params, emissionTextureColor);
    return emissionTextureColor.rgb * emissionColor;
#endif
}

#endif
