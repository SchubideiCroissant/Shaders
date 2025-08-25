Shader "Custom/SphereRipple"
{

    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Strength("Amplitude", Range(0,2)) = 0.05
        _Depth("Depth (Base Offset)",  Range(-0.2,0.2)) = 0.0
        _Frequency("Frequency", Range(0,50)) = 3
        _Speed("Speed",     Range(0,20)) = 2
        _Decay("Decay Strength", Range(1,5)) = 1
        _ImpactPointOS("Impact (Object)", Vector) = (0,0,1,0)

    }

        SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Geometry" "RenderType" = "Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _Strength;
                float _Decay;
                float _Depth;
                float _Frequency;
                float _Speed;
                float4 _ImpactPointOS;
               CBUFFER_END
            #include "SphereRipple.hlsl"
            ENDHLSL
        }
    }
}
