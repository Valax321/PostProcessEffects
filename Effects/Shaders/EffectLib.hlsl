#ifndef VALAX_EFFECTLIB_H
#define VALAX_EFFECTLIB_H

// These are from Colours.hlsl in the core render pipeline package

// sRGB
float SRGBToLinear(float c)
{
    float linearRGBLo  = c / 12.92;
    float linearRGBHi  = PositivePow((c + 0.055) / 1.055, 2.4);
    float linearRGB    = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
    return linearRGB;
}

float2 SRGBToLinear(float2 c)
{
    float2 linearRGBLo  = c / 12.92;
    float2 linearRGBHi  = PositivePow((c + 0.055) / 1.055, float2(2.4, 2.4));
    float2 linearRGB    = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
    return linearRGB;
}

float3 SRGBToLinear(float3 c)
{
    float3 linearRGBLo  = c / 12.92;
    float3 linearRGBHi  = PositivePow((c + 0.055) / 1.055, float3(2.4, 2.4, 2.4));
    float3 linearRGB    = (c <= 0.04045) ? linearRGBLo : linearRGBHi;
    return linearRGB;
}

float4 SRGBToLinear(float4 c)
{
    return float4(SRGBToLinear(c.rgb), c.a);
}

float LinearToSRGB(float c)
{
    float sRGBLo = c * 12.92;
    float sRGBHi = (PositivePow(c, 1.0/2.4) * 1.055) - 0.055;
    float sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
    return sRGB;
}

float2 LinearToSRGB(float2 c)
{
    float2 sRGBLo = c * 12.92;
    float2 sRGBHi = (PositivePow(c, float2(1.0/2.4, 1.0/2.4)) * 1.055) - 0.055;
    float2 sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
    return sRGB;
}

float3 LinearToSRGB(float3 c)
{
    float3 sRGBLo = c * 12.92;
    float3 sRGBHi = (PositivePow(c, float3(1.0/2.4, 1.0/2.4, 1.0/2.4)) * 1.055) - 0.055;
    float3 sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
    return sRGB;
}

float4 LinearToSRGB(float4 c)
{
    return float4(LinearToSRGB(c.rgb), c.a);
}

#endif