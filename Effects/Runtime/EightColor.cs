using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.Scripting;

namespace Valax321.PostProcess.Runtime
{
    [Preserve]
    [Serializable]
    [UnityEngine.Rendering.PostProcessing.PostProcess(typeof(EightColorRenderer), PostProcessEvent.AfterStack, "Valax321/Eight Color")]
    public class EightColor : PostProcessEffectSettings
    {
        public ColorParameter color1 = new ColorParameter { value = new Color(0, 0, 0) };
        public ColorParameter color2 = new ColorParameter { value = new Color(1, 0, 0) };
        public ColorParameter color3 = new ColorParameter { value = new Color(1, 1, 0) };
        public ColorParameter color4 = new ColorParameter { value = new Color(1, 1, 0) };
        public ColorParameter color5 = new ColorParameter { value = new Color(0, 0, 1) };
        public ColorParameter color6 = new ColorParameter { value = new Color(1, 0, 1) };
        public ColorParameter color7 = new ColorParameter { value = new Color(0, 1, 1) };
        public ColorParameter color8 = new ColorParameter { value = new Color(1, 1, 1) };

        [Range(0, 0.5f)]
        public FloatParameter dithering = new FloatParameter { value = 0.05f };

        [Range(1, 32)]
        public IntParameter downsampling = new IntParameter { value = 1 };

        public IntParameter resolution = new IntParameter { value = 576 };

        [Range(0, 1)]
        public FloatParameter opacity = new FloatParameter { value = 0 };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value && opacity.value > 0;
        }
    }

    internal sealed class EightColorRenderer : PostProcessEffectRenderer<EightColor>
    {
        static class IDs
        {
            internal static readonly int Dithering = Shader.PropertyToID("_Dithering");
            internal static readonly int Downsampling = Shader.PropertyToID("_Downsampling");
            internal static readonly int InputTexture = Shader.PropertyToID("_InputTexture");
            internal static readonly int Opacity = Shader.PropertyToID("_Opacity");
            internal static readonly int Palette = Shader.PropertyToID("_Palette");
        }

        private Vector4[] palette = new Vector4[8];

        public override void Render(PostProcessRenderContext context)
        {

            var resScale = Mathf.Max(1, Mathf.RoundToInt(context.height / (float)settings.resolution));
            
            palette[0] = settings.color1;
            palette[1] = settings.color2;
            palette[2] = settings.color3;
            palette[3] = settings.color4;
            palette[4] = settings.color5;
            palette[5] = settings.color6;
            palette[6] = settings.color7;
            palette[7] = settings.color8;

            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Valax321/EightColor"));
            sheet.properties.SetVectorArray(IDs.Palette, palette);
            sheet.properties.SetFloat(IDs.Dithering, settings.dithering);
            #if UNITY_EDITOR
            sheet.properties.SetInt(IDs.Downsampling, settings.downsampling * (context.isSceneView ? 1 : resScale));
            #else
            sheet.properties.SetInt(IDs.Downsampling, settings.downsampling * resScale);
            #endif
            sheet.properties.SetFloat(IDs.Opacity, settings.opacity);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}