Shader "Custom/PlaneRipple"
{

    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Strength("Strength (Amplitude)", Range(0,2)) = 0.05
        _Depth("Depth (Base Offset)",  Range(-0.2,0.2)) = 0.0
        _Frequency("Frequency", Range(0,10)) = 3
        _Speed("Speed",     Range(0,20)) = 2
        _Center("Center XZ (osX,osY)", Vector) = (0,0,0,0)
        _Decay("Decay Strength", Range(1,20)) = 1
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
                float4 _Center; // .xz = Zentrum im Objekt auf XZ
               CBUFFER_END
            #include "PlaneRipple.hlsl"
            ENDHLSL
        }
    }
}
