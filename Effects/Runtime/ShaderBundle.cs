using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Valax321.PostProcess.Runtime
{
    #if PACKAGE_DEV
    [CreateAssetMenu(menuName = "Valax321/Post Processing/Shader Bundle")]
    #endif
    public class ShaderBundle : ScriptableObject
    {
        [SerializeField] private Shader[] m_shaders;
    }
}
