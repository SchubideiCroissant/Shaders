

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

    float3 pos = IN.positionOS;

    float2 p = float2(pos.x, pos.z);
    float2 os = _Center.xy;
    float rad = length(p - os);
    float decay = 1 / (rad  + 1);
    

    float t = _Time.y * _Speed;
    float ripple = sin(rad * _Frequency - t)*decay * _Strength + _Depth;

    pos += normalize(IN.normalOS) * ripple;

    OUT.positionHCS = TransformObjectToHClip(float4(pos, 1.0));
    OUT.uv = IN.uv;
    OUT.ripple = ripple;
    return OUT;
}

half4 frag(Varyings IN) : SV_Target
{
    float brightness = saturate(0.5 + IN.ripple);
    return half4(_Color.rgb * brightness, 1.0);
}