using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.Scripting;

namespace Valax321.PostProcess.Runtime
{
    [Preserve]
    [Serializable]
    [PostProcess(typeof(DynamicFogRenderer), PostProcessEvent.BeforeStack, "Valax321/Dynamic Fog")]
    public class DynamicFog : PostProcessEffectSettings
    {
        [Tooltip("Fog ramp texture, mapping distance on the x axis to distance from the camera. RGB is fog color, A is fog opacity.")]
        public TextureParameter fogRamp = new TextureParameter {defaultState = TextureParameterDefault.Transparent};
        
        [Tooltip("Color multiplied with Fog Ramp.")]
        public ColorParameter fogColor = new ColorParameter {value = Color.white};
        
        [Tooltip("Fog end distance, in units from the camera.")]
        public FloatParameter fogEndDistance = new FloatParameter {value = 1000};
        
        [Tooltip("Ignore the skybox when rendering fog. Currently broken.")]
        public BoolParameter ignoreSkybox = new BoolParameter { value = true };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value && fogRamp.value && fogColor.value.a > 0;
        }
    }

    internal sealed class DynamicFogRenderer : PostProcessEffectRenderer<DynamicFog>
    {
        private static readonly int FogColor = Shader.PropertyToID("_FogColor");
        private static readonly int FogDistance = Shader.PropertyToID("_FogDistance");
        private static readonly int ClipToWorld = Shader.PropertyToID("_ClipToWorld");
        private static readonly int FogRamp = Shader.PropertyToID("_FogRamp");

        public override DepthTextureMode GetCameraFlags()
        {
            return DepthTextureMode.Depth;
        }

        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Valax321/DynamicFog"));
            sheet.properties.SetColor(FogColor, settings.fogColor);
            sheet.properties.SetFloat(FogDistance, settings.fogEndDistance);
            sheet.properties.SetTexture(FogRamp, settings.fogRamp);
            
            var p = GL.GetGPUProjectionMatrix(context.camera.projectionMatrix, false);// Unity flips its 'Y' vector depending on if its in VR, Editor view or game view etc... (facepalm)
            p[2, 3] = p[3, 2] = 0.0f;
            p[3, 3] = 1.0f;
            var clipToWorld = Matrix4x4.Inverse(p * context.camera.worldToCameraMatrix) * Matrix4x4.TRS(new Vector3(0, 0, -p[2,2]), Quaternion.identity, Vector3.one);
            
            sheet.properties.SetMatrix(ClipToWorld, clipToWorld);

            if (settings.ignoreSkybox)
            {
                sheet.EnableKeyword("IGNORE_SKYBOX");
            }
            else
            {
                sheet.DisableKeyword("IGNORE_SKYBOX");
            }
            
            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}