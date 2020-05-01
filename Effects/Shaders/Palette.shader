Shader "Hidden/Valax321/Palette"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #include "Packages/com.valax321.postprocessing/Effects/Shaders/EffectLib.hlsl"
    
    #define COLORS 32

    static const float bayer2x2[] = {-0.5, 0.16666666, 0.5, -0.16666666};

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    TEXTURE2D_SAMPLER2D(_Palette, sampler_Palette);
    
    float2 _PaletteSize;
    
    float _Dithering;
    uint _Downsampling;
    float _Opacity;

    float4 Frag(VaryingsDefault input) : SV_Target
    {
        // Input sample
        const uint2 pss = (uint2)(input.texcoord * _ScreenParams.xy) / _Downsampling;
        
        float4 col = saturate(_MainTex.Load(int3(pss * _Downsampling, 0)));

        // Linear -> sRGB
        #ifndef UNITY_COLORSPACE_GAMMA
        col.rgb = LinearToSRGB(col.rgb);
        #endif

        // Dithering (2x2 bayer)
        const float dither = bayer2x2[(pss.y & 1) * 2 + (pss.x & 1)];
        col.rgb += dither * _Dithering;

        const float maxColor = COLORS - 1.0;
        const float halfColX = 0.5 / _PaletteSize.x;
        const float halfColY = 0.5 / _PaletteSize.y;
        const float threshold = maxColor / COLORS;
        
        float xOffset = halfColX + col.r * threshold / COLORS;
        float yOffset = halfColY + col.g * threshold;
        float cell = floor(col.b * maxColor);
        float2 lutPos = float2(cell / COLORS + xOffset, yOffset);
        float4 rgb_d = SAMPLE_TEXTURE2D(_Palette, sampler_MainTex, lutPos);

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
