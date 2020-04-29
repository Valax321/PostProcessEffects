Shader "Hidden/Valax321/DynamicFog"
{
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
			#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
			
			#pragma shader_feature _ IGNORE_SKYBOX

			TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
			// _CameraNormalsTexture contains the view space normals transformed
			// to be in the 0...1 range.
			TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
			
			// Fog ramp texture
			TEXTURE2D_SAMPLER2D(_FogRamp, sampler_FogRamp);
			
			float4 _FogColor;
			half _FogDistance;
			float4x4 _ClipToWorld;
			
			struct Varyings
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoordStereo : TEXCOORD1;
            #if STEREO_INSTANCING_ENABLED
                uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
            #endif
                float3 worldDirection : COLOR0;
            };
            
            Varyings Vert(AttributesDefault v)
            {
                Varyings o;
                o.vertex = float4(v.vertex.xy, 0.0, 1.0);
                o.texcoord = TransformTriangleVertexToUV(v.vertex.xy);
            
            #if UNITY_UV_STARTS_AT_TOP
                o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
            #endif
            
                o.texcoordStereo = TransformStereoScreenSpaceTex(o.texcoord, 1.0);
                
                float4 clip = float4(v.vertex.xy, 0.0, 1.0);
				o.worldDirection = mul(_ClipToWorld, clip) - _WorldSpaceCameraPos;
            
                return o;
            }

			float4 Frag(Varyings i) : SV_Target
			{
			    float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
				float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoord));
				float3 wp = i.worldDirection * depth;
				
				float fogRange = saturate(length(wp) / _FogDistance);
				
				float4 fogColor = SAMPLE_TEXTURE2D(_FogRamp, sampler_FogRamp, float2(fogRange, 0.5)) * _FogColor;
				#if IGNORE_SKYBOX
				return lerp(color, fogColor, fogColor.a * (float)(_ProjectionParams.z >= depth));
				#else
				return lerp(color, fogColor, fogColor.a);
				#endif
			}
            ENDHLSL
        }
    }
}