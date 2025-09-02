
struct Attributes // Mesh -> Vert
{
    float3 positionOS : POSITION; // Objektraum
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Varyings // Vert: OUT
{
    float4 positionHCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float ripple : TEXCOORD1;
};

Varyings vert(Attributes IN)
{
    Varyings OUT;
    float t = _Time.y * _Speed;
    //World Position
    
    float3 posWS = TransformObjectToWorld(IN.positionOS);
    float3 nWS = normalize(TransformObjectToWorldNormal(IN.normalOS)); 
    float rad = distance(posWS, _ImpactPointWS.xyz);
    float decay = 1 / (rad + 1);
    float ripple = sin(rad * _Frequency - t) * decay * _Strength + _Depth;
    posWS += nWS * ripple;
    OUT.positionHCS = TransformWorldToHClip(posWS);
    
   
    // Object-Variante
    /*
    float3 posOS = IN.positionOS;
    float3 nOS = normalize(IN.normalOS);
    float3 impactOS = _ImpactPointWS.xyz; // oder float3(0,0,0) = Objektzentrum
    float rad = distance(posOS, impactOS);
    float decay = 1 / (rad + 1);
    float ripple = sin(rad * _Frequency - t) * decay * _Strength + _Depth;
    posOS += nOS * ripple;
    OUT.positionHCS = TransformObjectToHClip(float4(posOS, 1));
    */
    
    
    OUT.uv = IN.uv;
    OUT.ripple = ripple;
    return OUT;
}

half4 frag(Varyings IN) : SV_Target
{
    float brightness = saturate(0.5 + IN.ripple);
    return half4(_Color.rgb * brightness, 1.0);
}
