Shader "Hidden/Valax321/EightColor"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #include "Packages/com.valax321.postprocessing/Effects/Shaders/EffectLib.hlsl"

    static const float bayer2x2[] = {-0.5, 0.16666666, 0.5, -0.16666666};

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float4 _Palette[8];
    float _Dithering;
    uint _Downsampling;
    float _Opacity;

    float4 Frag(VaryingsDefault input) : SV_Target
    {
        // Input sample
        const uint2 pss = (uint2)(input.texcoord * _ScreenParams.xy) / _Downsampling;
        
        float4 col = _MainTex.Load(int3(pss * _Downsampling, 0)); // Dafuq

        // Linear -> sRGB
        #ifndef UNITY_COLORSPACE_GAMMA
        col.rgb = LinearToSRGB(col.rgb);
        #endif

        // Dithering (2x2 bayer)
        const float dither = bayer2x2[(pss.y & 1) * 2 + (pss.x & 1)];
        col.rgb += dither * _Dithering;

        // Alias for each color
        const float3 c1 = _Palette[0].rgb;
        const float3 c2 = _Palette[1].rgb;
        const float3 c3 = _Palette[2].rgb;
        const float3 c4 = _Palette[3].rgb;
        const float3 c5 = _Palette[4].rgb;
        const float3 c6 = _Palette[5].rgb;
        const float3 c7 = _Palette[6].rgb;
        const float3 c8 = _Palette[7].rgb;

        // Euclidean distance
        const float d1 = distance(c1, col.rgb);
        const float d2 = distance(c2, col.rgb);
        const float d3 = distance(c3, col.rgb);
        const float d4 = distance(c4, col.rgb);
        const float d5 = distance(c5, col.rgb);
        const float d6 = distance(c6, col.rgb);
        const float d7 = distance(c7, col.rgb);
        const float d8 = distance(c8, col.rgb);

        // Best fit search
        float4 rgb_d = float4(c1, d1);
        rgb_d = rgb_d.a < d2 ? rgb_d : float4(c2, d2);
        rgb_d = rgb_d.a < d3 ? rgb_d : float4(c3, d3);
        rgb_d = rgb_d.a < d4 ? rgb_d : float4(c4, d4);
        rgb_d = rgb_d.a < d5 ? rgb_d : float4(c5, d5);
        rgb_d = rgb_d.a < d6 ? rgb_d : float4(c6, d6);
        rgb_d = rgb_d.a < d7 ? rgb_d : float4(c7, d7);
        rgb_d = rgb_d.a < d8 ? rgb_d : float4(c8, d8);

        // Opacity
        col.rgb = lerp(col.rgb, rgb_d.rgb, _Opacity);

        // sRGB -> Linear
        #ifndef UNITY_COLORSPACE_GAMMA
        col.rgb = SRGBToLinear(col.rgb);
        #endif

        return col;
	}

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}
