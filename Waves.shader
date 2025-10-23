Shader "Custom/Waves"
{
    // Lit Shader
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}


         _BaseMap_ST("Base Map Tiling/Offset", Vector) = (1,1,0,0)
         _BaseMap2_ST("Foam Map Tiling/Offset", Vector) = (1,1,0,0)
        
        _BaseMap2("Foam Map", 2D) = "white"{}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Smoothness("Smoothness", Range(0,1)) = 0.5
        _BumpMap("Normal Map", 2D) = "bump" {}
        _Amplitude("Amplitude", Range(0,5)) = 1.0
        _Frequency("Frequency", Range(0,5)) = 1.0
        _Speed("Speed",     Range(0,10)) = 1.0
        _TextureSpeed("Texture Speed", Range(0,1)) = 0.0
        _Decay("Decay Strength", Range(1,5)) = 1.0
        _Noise("Noise Strength", Range(0,1)) = 1.0
        _ImpactPointWS("Wave Spawnpoint", Vector) = (0,0,0,0)
        _FoamWidth("Foam Width", Range(0,1)) = 1.0
    }

        SubShader
        {
            // Transparent Shader
            Tags { "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            Pass
            {
                Name "ForwardLit"
                Tags { "LightMode" = "UniversalForward" }

                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

                TEXTURE2D(_CameraDepthTexture);
                SAMPLER(sampler_CameraDepthTexture);

                TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
                TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap);

                TEXTURE2D(_BaseMap2); SAMPLER(sampler_BaseMap2);
                TEXTURE2D(_BumpMap2); SAMPLER(sampler_BumpMap2);

                float4 _BaseMap_ST;
                float4 _BaseMap2_ST;

                float4 _BaseColor;
                float _Metallic;
                float _Smoothness;
                float _BumpScale;
                float _Amplitude;
                float _Speed;
                float _Frequency;
                float _Decay;
                float _Noise;
                float _TextureSpeed;
                float _FoamWidth;
                float3 _ImpactPointWS;

                struct Attributes {
                    float4 positionOS : POSITION;
                    float3 normalOS   : NORMAL;
                    float4 tangentOS  : TANGENT;
                    float2 uv         : TEXCOORD0;
                };

                struct Varyings {
                    float4 positionHCS : SV_POSITION;
                    float3 positionWS  : TEXCOORD0;
                    float3 normalWS    : TEXCOORD1;
                    float4 tangentWS   : TEXCOORD2;
                    float2 uv          : TEXCOORD3;
                    float wave_height  : TEXCOORD4;
                    float wave_worldY : TEXCOORD5;   
                    float4 screenSpace : TEXCOORD6;
                };

                // Magic Numbers
                float hash(float2 p) {
                    return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
                }

                Varyings vert(Attributes v)
                {
                    Varyings o;
                    
                    // Objekt -> Welt
                    float3 posWS = TransformObjectToWorld(v.positionOS.xyz);
                    float3 nWS = TransformObjectToWorldNormal(v.normalOS);
                    // --- Wellenform ---
                    float t = _Time.y * _Speed;
                    float t_speed = _Time.y * _TextureSpeed;

                    float rnd = hash(posWS.xz); 
                    float wave = 0;
                    float rad = distance(posWS, _ImpactPointWS.xyz);

                    
                    // float decay = exp(-_Decay * rad);
                    
                    wave += sin(rad * _Frequency - t) * _Amplitude * 0.9; // Ripple
                    wave += sin((posWS.x + posWS.z) * (_Frequency * 0.7) - t * 1.3) * (_Amplitude * 0.9); // Schraege Welle
                    wave += _Noise * sin(posWS.z * (_Frequency * 1.5) - t * 0.6 + rnd * 6.28) * (_Amplitude * 0.4); // Noise - Welle

                    wave += sin(posWS.z * (_Frequency * 1.5) + t) * (_Amplitude * 0.55); 
                    //wave += sin(posWS.x * (_Frequency * 1.5) - t * 0.6 + rnd * 6.28) * (_Amplitude * 0.3);

                    //wave = sin((posWS.x + posWS.z) * _Frequency + t ) * _Amplitude + rnd;
                    

                    // Vertex im Welt-Raum entlang der Normalen verschieben, zeigt bei Plane standartmäßig in Y - Richtung
                    posWS += nWS * wave;
                    o.positionHCS = TransformWorldToHClip(posWS);
                    o.wave_height = wave; 
                    o.wave_worldY = posWS.y;
                                      
                    // F�r Material usw.
                    float3 tWS = TransformObjectToWorldDir(v.tangentOS.xyz);
                    o.positionWS = posWS;
                    o.tangentWS = float4(normalize(tWS), v.tangentOS.w);
                    o.normalWS = nWS;

                    // Textur-Scroll
                    v.uv += v.uv + t_speed;
                    o.uv = v.uv;

                    // berechnet aus Clip-Space die Bildschirmkoordinaten
                    o.screenSpace = ComputeScreenPos(o.positionHCS);
                    
                    return o;

                }

                half4 frag(Varyings i) : SV_Target
                {
                                
                    float2 baseUV = TRANSFORM_TEX(i.uv, _BaseMap);
                    float2 foamUV = TRANSFORM_TEX(i.uv, _BaseMap2);


                    float2 screenSpaceUV = i.screenSpace.xy / i.screenSpace.w;

                    float rawDepthScene = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV);
                    float sceneEyeDepth = LinearEyeDepth(rawDepthScene, _ZBufferParams); 

                    float waterDeviceDepth = i.positionHCS.z / i.positionHCS.w;           
                    float waterEyeDepth = LinearEyeDepth(waterDeviceDepth, _ZBufferParams);

                    // 4) Difference between  eye depth of the scene geometry and of the water surface fragment
                    float diff = abs(sceneEyeDepth - waterEyeDepth);
                    diff *= 100000.0; // Scales the Variable, to around ~ 0.01 to 1
                    float foamMask = 1.0 - smoothstep(0.0, _FoamWidth, diff);
                    foamMask = saturate(foamMask);

                    float waveFactor = saturate((i.wave_height / (_Amplitude )) * 0.5 + 0.5); // normalize 0 - 1
                    // Albedo
                    float4 albedoSample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseUV) * _BaseColor;
                    float4 foamSample = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, foamUV);

                    // Foam on Top of Waves
                    float foamTopMask = smoothstep(0.95, 1.0, waveFactor); // Heigh-Limit for the foam                  
                    float3 foamColor = foamSample.rgb;


                    // Normal Map (Tangent Space -> World Space)
                    float3 nTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv));
                    nTS.xy *= _BumpScale;
                    nTS = normalize(nTS);

                    float3 N = normalize(i.normalWS);
                    float3 T = normalize(i.tangentWS.xyz);
                    float3 B = normalize(cross(N, T) * i.tangentWS.w);
                    float3x3 TBN = float3x3(T, B, N);
                    float3 nWS = normalize(mul(nTS, TBN));

                    // Lighting
                    float3 V = normalize(GetWorldSpaceViewDir(i.positionWS));
                    Light mainLight = GetMainLight();
                    float3 L = normalize(mainLight.direction);
                    float NdotL = saturate(dot(nWS, L));

                    // Simple PBR-ish shading
                    float3 diffuse = albedoSample * NdotL * mainLight.color;
                    float3 specular = pow(saturate(dot(nWS, normalize(L + V))), 16.0 * _Smoothness) * _Metallic * mainLight.color;

              
                    float3 baseColor = diffuse + specular;
                    float3 foamMix = lerp(baseColor, foamColor, foamTopMask);
                    float3 finalColor = lerp(foamMix, float3(1.0, 1.0, 1.0), foamMask); // foamMask bleibt für Rand-Schaum

                    // H�he der Welle steuert Alpha-Kanal

                    return half4(finalColor, waveFactor);

                }
                ENDHLSL
            }
        }
}
