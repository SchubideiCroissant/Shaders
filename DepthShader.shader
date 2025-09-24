Shader "Custom/DepthShader"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "Queue" = "Transparent" "RenderType" = "Opaque"  }
        Pass
        {
            Name "Depth"
            ZTest LEqual
            ZWrite On
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv: TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                //float4 uv   : TEXCOORD0;
                float4 screenSpace : TEXCOORD1; // Bildschirmkoordinaten
            };

            Varyings vert(Attributes v)
            {
                Varyings o;
                o.vertex = TransformObjectToHClip(v.positionOS.xyz);
                o.screenSpace = ComputeScreenPos(o.vertex); // berechnet aus Clip-Space die Bildschirmkoordinaten
                return o;
            }

            

            half4 frag(Varyings i) : SV_Target
            {
                float2 screenSpaceUV = i.screenSpace.xy / i.screenSpace.w; // uv liegt im Bereich (0,0) - (1,1)

                float rawDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV);
                float linearDepth = Linear01Depth(rawDepth, _ZBufferParams); // linearisieren: 0 = Near, 1 = Far


                return half4(linearDepth.xxx, 1); // xxx ist Graustufe
                //return half4(screenSpaceUV, 0, 1); // Objekt ändert Farbe je nach Position auf dem Bildschirm
            }


            ENDHLSL
        }
    }
}
