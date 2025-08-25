

struct Attributes // Mesh -> Vert
{
    float3 positionOS : POSITION;
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

    float3 posOS = IN.positionOS;
    float3 nOS = normalize(IN.normalOS);

// Kugelzentrum im OS (oft (0,0,0))
    float3 cOS = float3(0, 0, 0);

// Richtungen vom Zentrum zur aktuellen Position und zum Einschlag
    float3 vDir = normalize(posOS - cOS);
    float3 iVec = _ImpactPointOS.xyz - cOS;
    float iLen2 = max(dot(iVec, iVec), 1e-8);
    float3 iDir = iVec * rsqrt(iLen2);

// Winkel (Radiant) als „rad“
    float cosA = clamp(dot(vDir, iDir), -1.0, 1.0);
    float rad = acos(cosA);
// Rest wie gehabt
    float t = _Time.y * _Speed;
    float decay = 1 / pow((rad * _Decay + 1),2);
    float ripple = sin(rad * _Frequency - t)*decay * _Strength + _Depth;

// Offset entlang der lokalen Normale und in Clip
    posOS += nOS * ripple;
    OUT.positionHCS = TransformObjectToHClip(float4(posOS, 1));

    OUT.uv = IN.uv;
    OUT.ripple = ripple;
    return OUT;
}

half4 frag(Varyings IN) : SV_Target
{
    float brightness = saturate(0.4 + IN.ripple);
    return half4(_Color.rgb * brightness, 1.0);
}