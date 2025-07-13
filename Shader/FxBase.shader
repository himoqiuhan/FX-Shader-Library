
//----------------------------------------------------------------------------------------------------------
// HimoToon FX-Shader-Library
// https://github.com/himoqiuhan/FX-Shader-Library
// Copyright (c) 2025 楸涵. All rights reserved.
// Licensed under the MIT License 
// You may not use this file except in compliance with the License.You may obtain a copy of the License at
// http://opensource.org/licenses/MIT
//----------------------------------------------------------------------------------------------------------

Shader "HimoToon/FX/FxBase"
{
    Properties
    {
        [HDR]_Color ("Overall Color", Color) = (1,1,1,1)
//        [Toggle(_HIGH_QUALITY_UV_FLOW)]_HighQualityUVFlow("High Quality UV Flow", Float) = 1.0
//        [Toggle(_USE_SCREEN_SPACE_UV)]_UseScreenSpaceUV("Use Screen Space UV (Flow with 'High Quality Flow')", Float) = 0.0
        
//        [Space(20)]
//        [Header(Color)]
        _PolarCoordinatesParams("(RG)Polar Coordinate Center (B)Radius Scale (A)Angle Offset", Vector) = (0.5,0.5,1,0)
        _MainTex ("Main Texture", 2D) = "white" {}
        [Toggle]_UseMainRChannelAsAlpha("Use Main Texture R Channel As Alpha", Float) = 0.0
        [HDR]_MainColor ("Main Color", Color) = (1,1,1,1)
        
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        [HDR]_SecondaryColor ("Secondary Color", Color) = (1,1,1,1)
        [Enum(Add, 0, Multiply, 1)]_SecondaryTexBlendMode ("Secondary Texture Blend Mode", Float) = 0.0
        _ColorTexFlowParam ("Main(RG) Secondary(BA) Texture Flow", Vector) = (0,0,0,0)
        
//        [Space(20)]
//        [Header(Noise)]
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseTexParams ("(RG)Disturbance (BA)Texture Flow", Vector) = (0,0,0,0)
        
//        [Space(20)]
//        [Header(Mask)]
        _MaskTex ("Mask Texture", 2D) = "white" {}
//        _MaskNoiseInfluence ("Mask Noise Influence", Range(0, 1)) = 0.0
        _MaskTexParams ("(RG)Texture Flow (B)Noise Influence (A)", Vector) = (0,0,0,0)
        
//        [Space(20)]
//        [Header(Dissolve)]
        _DissolveTex ("Dissolve Texture", 2D) = "white" {}
//        [Enum(SelfUV, 0, MainTexUV, 1)]_DissolveControlMode ("Dissolve Control Mode", Float) = 1.0
//        _DissolveNoiseInfluence ("Dissolve Noise Influence", Range(0, 1)) = 0.0
        _DissolveTexFlowParams ("(RG)Dissolve Texture Flow (B)Dissolve Control Mode (A)Dissolve Noise Influence", Vector) = (0,0,1,0)
        
        _DissolveParams ("(R)Threshold (G)Edge Softness (B)BrightenEdgeOn (A)EdgeWidth", Vector) = (0,0,0,0)
//        _DissolveThreshold ("Dissolve Threshold", Range(0, 1)) = 0.0
//        _DissolveEdgeSoftness ("Dissolve Edge Hardness", Range(0, 1)) = 0.0
//        [Toggle]_DissolveBrightEdgeOn ("Dissolve Bright Edge On", Float) = 0.0
//        _DissolveEdgeWidth ("Dissolve Edge Width", Range(0, 1)) = 0.0
        
        [HDR]_DissolveEdgeColor ("Dissolve Color", Color) = (1,1,1,1)
        
//        [Space(20)]
//        [Header(Soft Particle)]
//        [Toggle(_DEPTH_FADE_ON)]_DepthFadeOn ("Depth Fade On", Float) = 0.0
        _DepthFadeThreshold ("Depth Fade Threshold", Range(0, 10)) = 1.0
        _InverseDepthFade("Inverse depth fade", Float) = 0.0
        
//        [Space(20)]
//        [Header(Fresnel)]
        _FresnelParams ("(R)On (G)Intensity (B)Pow (A)Color Mode(0 Replace, 0.5 Add, 1 Multiply)", Vector) = (0, 1, 1, 0)
        [HDR]_FresnelInnerColor ("Fresnel Inner Color", Color) = (1,1,1,1)
        [HDR]_FresnelOuterColor ("Fresnel Outer Color", Color) = (1,1,1,1)
        
        _CyberpunkHexagonColor("Cyberpunk Hexagon Color",Color) = (1,1,1,1)
        _CyberpunkHexagonParams0("(R)Hexagon On (G)Tiling", Vector) = (0.0, 1.0, 0, 0)
        _CyberpunkHexagonParams1("(R)Edge Thickness (G)Edge Softness (B)Inverse Hexagon (A)Color Mode", Vector) = (0.1, 0.0, 0, 0)
        
//        [Space(20)]
//        [Header(Blending state)]
        [Enum(UnityEngine.Rendering.BlendOp)] _Blend("Blend Op", Float) = 0.0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Blend Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Blend Dst", Float) = 0.0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", Float) = 2.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", Float) = 4.0
        [Enum(Off, 0, On, 1)]_ZWrite("ZWrite", Float) = 1.0
//        [Toggle(_ALPHATEST_ON)] _AlphaClip("Enable Alpha Clip", Float) = 0.0
        _AlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 0.5
        
//        [Space(20)]
//        [Header(Stencil state)]
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comp", Float) = 8.0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp("Stencil Operation", Float) = 2.0
        [Int]_Stencil("Stencil", Range(0, 255)) = 0.0
        [Int]_ReadMask("Stencil Read Mask", Range(0, 255)) = 255.0
        [Int]_WriteMask("Stencil Write Mask", Range(0, 255)) = 255.0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
        }
        
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }
            
            BlendOp [_Blend]
            Blend [_SrcBlend] [_DstBlend]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Cull [_Cull]
            
            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                Pass [_StencilOp]
                ReadMask [_ReadMask]
                WriteMask [_WriteMask]
            }
            
            HLSLPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "FxCommon.hlsl"
        #if defined(_DEPTH_FADE_ON)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        #endif
        #if defined(_USE_WORLD_PROJECTION_UV)
            #include "Assets/Resources/Shader/Landscape/ShaderLibrary/TriplanarMappingUtility.hlsl"
        #endif
            

            // -------------------------------------
            // Quality Keywords
            #pragma multi_compile _ _HIGH_QUALITY_UV_FLOW
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _DEPTH_FADE_ON
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ _USE_SCREEN_SPACE_UV _USE_WORLD_PROJECTION_UV
            #pragma shader_feature _USE_POLAR_COORDINATES
            #pragma shader_feature _USE_SECONDARY_TEXTURE

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _SecondaryTex_ST;
            float4 _NoiseTex_ST;
            float4 _MaskTex_ST;
            float4 _DissolveTex_ST;
            float4 _ColorTexFlowParam;
            float4 _NoiseTexParams;
            float4 _MaskTexParams;
            float4 _DissolveTexFlowParams;
            float4 _DissolveParams;
            float4 _FresnelParams;
            float4 _PolarCoordinatesParams;
            half4 _Color;
            half4 _MainColor;
            half4 _SecondaryColor;
            half4 _DissolveEdgeColor;
            half4 _FresnelInnerColor;
            half4 _FresnelOuterColor;
            float _UseMainRChannelAsAlpha;
            float _SecondaryTexBlendMode;            
            float _DepthFadeThreshold;
            float _InverseDepthFade;
            float _AlphaClipThreshold;
            CBUFFER_END

        #if defined(_USE_WORLD_PROJECTION_UV)
            float4x4 _ScreenToWorld[2];
        #endif
        
            TEXTURE2D(_MainTex);                    SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskTex);                    SAMPLER(sampler_MaskTex);
            TEXTURE2D(_SecondaryTex);               SAMPLER(sampler_SecondaryTex);
            TEXTURE2D(_NoiseTex);                   SAMPLER(sampler_NoiseTex);
            TEXTURE2D(_DissolveTex);                SAMPLER(sampler_DissolveTex);
        #if defined(_USE_WORLD_PROJECTION_UV)
        #if !defined(_DEPTH_FADE_ON)
            TEXTURE2D(_CameraDepthTexture);
        #endif
            TEXTURE2D(_GBuffer2);
            SamplerState my_point_clamp_sampler;
        #endif
            
            #define _MainTexUVFlow _ColorTexFlowParam.xy
            #define _SecondaryTexUVFlow _ColorTexFlowParam.zw

            #define _NoiseTexDisturbance _NoiseTexParams.xy
            #define _NoiseTexUVFlow _NoiseTexParams.zw

            #define _MaskTexUVFlow _MaskTexParams.xy
            #define _MaskNoiseInfluence _MaskTexParams.z

            #define _DissolveTexFlow _DissolveTexFlowParams.xy
            #define _DissolveControlMode _DissolveTexFlowParams.z
            #define _DissolveNoiseInfluence _DissolveTexFlowParams.w
            #define _DissolveThreshold _DissolveParams.x
            #define _DissolveEdgeSoftness _DissolveParams.y
            #define _DissolveBrightEdgeOn _DissolveParams.z
            #define _DissolveEdgeWidth _DissolveParams.w

            #define _FresnelColorOn _FresnelParams.x
            #define _FresnelIntensity _FresnelParams.y
            #define _FresnelPow _FresnelParams.z
            #define _FresnelColorMode _FresnelParams.w

            #define noiseUV paramUV.xy
            #define maskUV paramUV.zw

            #define _PolarCoordinateCenter _PolarCoordinatesParams.xy
            #define _PolarCoordinateRadiusScale _PolarCoordinatesParams.z
            #define _PolarCoordinateAngleOffset _PolarCoordinatesParams.w
            

        #if defined(_USE_WORLD_PROJECTION_UV)
            #ifdef _GBUFFER_NORMALS_OCT
            half3 UnpackNormal(half3 pn)
            {
                half2 remappedOctNormalWS = half2(Unpack888ToFloat2(pn));          // values between [ 0, +1]
                half2 octNormalWS = remappedOctNormalWS.xy * half(2.0) - half(1.0);// values between [-1, +1]
                return half3(UnpackNormalOctQuadEncode(octNormalWS));              // values between [-1, +1]
            }

            #else
            half3 UnpackNormal(half3 pn)
            { return pn; }                                                        // values between [-1, +1]
            #endif
        #endif

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float3 normalOS         : NORMAL;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS       : SV_POSITION;
                float4 colorUV          : TEXCOORD0;
                float4 paramUV          : TEXCOORD1;
                float2 dissolveUV       : TEXCOORD2;
                float4 screenUV         : TEXCOORD3;
                float3 normalWS         : TEXCOORD4;
                float3 positionWS       : TEXCOORD5;
            };

            Varyings VertexProgram(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexPositions = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS.xyz);
                output.positionCS = vertexPositions.positionCS;
                output.colorUV.xy = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                output.colorUV.zw = input.uv * _SecondaryTex_ST.xy + _SecondaryTex_ST.zw;
                output.noiseUV = input.uv * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                output.maskUV = input.uv * _MaskTex_ST.xy + _MaskTex_ST.zw;
                output.dissolveUV = input.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
            #if !defined(_HIGH_QUALITY_UV_FLOW)
                output.colorUV += _ColorTexFlowParam * _Time.y;
                output.paramUV += float4(_NoiseTexUVFlow, _MaskTexUVFlow) * _Time.y;
                output.dissolveUV += _DissolveTexFlow * _Time.y;
            #endif
                output.screenUV = vertexPositions.positionNDC;
                output.normalWS = vertexNormalInput.normalWS;
                output.positionWS = vertexPositions.positionWS;
                return output;
            }

            half4 FragmentProgram(Varyings input) : SV_Target
            {
                half4 finalColor = _Color;
                float2 screenUV = input.screenUV.xy / input.screenUV.w;
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(input.positionWS));

            #if defined(_USE_SCREEN_SPACE_UV)
                input.colorUV = float4(screenUV, screenUV);
                input.paramUV = float4(screenUV, screenUV);
                input.dissolveUV.xy = screenUV;
            #elif defined(_USE_WORLD_PROJECTION_UV)
                half4 gbuffer2 = SAMPLE_TEXTURE2D_X_LOD(_GBuffer2, my_point_clamp_sampler, screenUV, 0);
                float d        = SAMPLE_TEXTURE2D_X_LOD(_CameraDepthTexture, my_point_clamp_sampler, screenUV, 0).x; // raw depth value has UNITY_REVERSED_Z applied on most platforms.
                float4 positionWS = mul(_ScreenToWorld[0], float4(input.positionCS.xy, d, 1.0));
                positionWS.xyz *= rcp(positionWS.w);
                float3 normalWS = normalize(UnpackNormal(gbuffer2.xyz));
                TriplanarParams triplanarParams = GetTriplanarParams(positionWS, normalWS, (float3)1.0 , float4(1.0, 1.0, 0.0, 0.0), 1);
                float2 triplanarUV = lerp(
                                        lerp(triplanarParams.uv_XY, triplanarParams.uv_ZY, triplanarParams.blendFactor_WithZY)
                                            , triplanarParams.uv_XZ,
                                            triplanarParams.blendFactor_WithXZ);
                input.colorUV.xy = triplanarUV * _MainTex_ST.xy + _MainTex_ST.zw;
                input.colorUV.zw = triplanarUV * _SecondaryTex_ST.xy + _SecondaryTex_ST.zw;
                input.maskUV = triplanarUV * _MaskTex_ST.xy + _MaskTex_ST.zw;
            #endif

            #if defined(_USE_POLAR_COORDINATES)
                input.colorUV.xy = CalculatePolarCoordinatesEx(input.colorUV.xy, _PolarCoordinateCenter, _PolarCoordinateRadiusScale, _PolarCoordinateAngleOffset)
                input.colorUV.zw = CalculatePolarCoordinatesEx(input.colorUV.xy, _PolarCoordinateCenter, _PolarCoordinateRadiusScale, _PolarCoordinateAngleOffset)
            #endif

            #if defined(_HIGH_QUALITY_UV_FLOW)
                input.colorUV += _ColorTexFlowParam * _Time.y;
                input.paramUV += float4(_NoiseTexUVFlow, _MaskTexUVFlow) * _Time.y;
                input.dissolveUV.xy += _DissolveTexFlow * _Time.y;
            #endif
                
                // Noise texture to disturb color UV
                float2 noiseTexUV = input.noiseUV;
                half noiseTexture = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseTexUV).r;
                float2 colorUVOffset = noiseTexture * _NoiseTexDisturbance.xy;
                
                // Color
                float2 mainTexUV = input.colorUV.xy + colorUVOffset;
                half4 mainTexColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainTexUV);
                if (_UseMainRChannelAsAlpha > 0.5)
                {
                    mainTexColor.a = mainTexColor.r;
                }
                half4 mainColor = mainTexColor * _MainColor;
            #if defined(_USE_SECONDARY_TEXTURE)
                float2 secondaryTexUV = input.colorUV.zw + colorUVOffset;
                half4 secondaryTexColor = SAMPLE_TEXTURE2D(_SecondaryTex, sampler_SecondaryTex, secondaryTexUV);
                half4 secondaryColor = secondaryTexColor * _SecondaryColor;
                // Blend secondary texture
                if (_SecondaryTexBlendMode < 0.5)
                {
                    finalColor.rgb *= mainColor.rgb * mainColor.a + secondaryColor.rgb * secondaryColor.a;
                    finalColor.a *= mainColor.a + secondaryColor.a;
                }
                else
                {
                    finalColor.rgb *= mainColor.rgb * mainColor.a + secondaryColor.rgb * secondaryColor.a;
                    finalColor.a *= mainColor.a + secondaryColor.a;
                }
                finalColor.a = saturate(finalColor.a);
            #else
                finalColor *= mainColor;
            #endif
                
                // Fresnel
                float vdotN = saturate(abs(dot(viewDirWS, input.normalWS)));
                half4 fresnelColor = lerp(_FresnelOuterColor, _FresnelInnerColor, saturate(pow(vdotN, rcp(_FresnelPow)) * _FresnelIntensity));
                if (_FresnelColorMode < 0.25)
                {
                    finalColor = lerp(finalColor, fresnelColor , _FresnelColorOn);
                }
                else if (_FresnelColorMode > 0.75)
                {
                    finalColor *= lerp(1.0, fresnelColor , _FresnelColorOn);
                }
                else
                {
                    finalColor += lerp(0.0, fresnelColor , _FresnelColorOn);
                }

                // Dissolve
                float2 dissolveUV = input.dissolveUV.xy + colorUVOffset * _DissolveNoiseInfluence;
                if (_DissolveControlMode > 0.5)
                {
                    dissolveUV = mainTexUV;
                }
                half dissolveTexValue = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, dissolveUV).r;
                half dissolveGradientFadeMask = smoothstep(_DissolveThreshold - _DissolveEdgeSoftness, _DissolveThreshold, dissolveTexValue);
                if (_DissolveBrightEdgeOn)
                {
                    half dissolveBrightEdgeMask = step(_DissolveThreshold - _DissolveEdgeSoftness - _DissolveEdgeWidth * 0.2, dissolveTexValue);
                    finalColor.a *= dissolveBrightEdgeMask;
                    dissolveBrightEdgeMask -= dissolveGradientFadeMask;
                    finalColor.rgb *= lerp(1.0, _DissolveEdgeColor.rgb, dissolveBrightEdgeMask);
                }
                else
                {
                    finalColor.a *= dissolveGradientFadeMask;
                }
                
                // Mask texture
                half maskTexAlpha = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.maskUV + colorUVOffset * _MaskNoiseInfluence).a;
                finalColor.a *= maskTexAlpha;
                
            #if defined(_ALPHATEST_ON)
                clip(finalColor.a - _AlphaClipThreshold);
            #endif
                
            #if defined(_DEPTH_FADE_ON)
                // Soft particle
                float sampleDepth = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                float sceneDepth = input.positionCS.w;
                float deltaDepth = (sampleDepth - sceneDepth);
                float depthFadeFactor = smoothstep(0, _DepthFadeThreshold, deltaDepth);
                if (_InverseDepthFade > 0.5)
                {
                    depthFadeFactor = 1.0 - depthFadeFactor;
                }
                finalColor.a *= depthFadeFactor;
            #endif
                
                return half4(finalColor.rgb, finalColor.a);
            }
            ENDHLSL
        }
    }

    CustomEditor "HimoToon.Editor.ShaderGUI.FxBaseShaderGUI"
}
