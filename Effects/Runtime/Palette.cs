using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.Scripting;

namespace Valax321.PostProcess.Runtime
{
    [Preserve, Serializable]
    [PostProcess(typeof(PaletteRenderer), PostProcessEvent.AfterStack, "Valax321/Palette")]
    public sealed class Palette : PostProcessEffectSettings
    {
        public TextureParameter palette = new TextureParameter { defaultState = TextureParameterDefault.Lut2D };
        
        [Range(0, 0.5f)]
        public FloatParameter dithering = new FloatParameter { value = 0.05f };

        [Range(1, 32)]
        public IntParameter downsampling = new IntParameter { value = 1 };

        public IntParameter resolution = new IntParameter { value = 576 };

        [Range(0, 1)]
        public FloatParameter opacity = new FloatParameter { value = 0 };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value && palette.value && opacity > 0;
        }
    }

    internal sealed class PaletteRenderer : PostProcessEffectRenderer<Palette>
    {
        private static int PaletteTexture = Shader.PropertyToID("_Palette");
        private static int Dithering = Shader.PropertyToID("_Dithering");
        private static int Downsampling = Shader.PropertyToID("_Downsampling");
        private static int Opacity = Shader.PropertyToID("_Opacity");
        private static int PaletteSize = Shader.PropertyToID("_PaletteSize");
        
        public override void Render(PostProcessRenderContext context)
        {
            var resScale = Mathf.Max(1, Mathf.RoundToInt(context.height / (float)settings.resolution));
            
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Valax321/Palette"));
            
            sheet.properties.SetVector(PaletteSize, new Vector4(settings.palette.value.width, settings.palette.value.height));
            
            sheet.properties.SetTexture(PaletteTexture, settings.palette.value);
            sheet.properties.SetFloat(Dithering, settings.dithering.value);
#if UNITY_EDITOR
            sheet.properties.SetInt(Downsampling, settings.downsampling * (context.isSceneView ? 1 : resScale));
#else
            sheet.properties.SetInt(Downsampling, settings.downsampling * resScale);
#endif
            sheet.properties.SetFloat(Opacity, settings.opacity);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
