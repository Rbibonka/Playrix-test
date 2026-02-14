Shader "Custom/GrassWind"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _WindStrength ("Wind Strength", Range(0,1)) = 0.2
        _WindSpeed ("Wind Speed", Range(0,10)) = 2.0
        _WindDirection ("Wind Direction", Vector) = (1,0,0,0)

        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags 
        { 
            "RenderType"="TransparentCutout"
            "Queue"="AlphaTest"
        }

        LOD 200
        Cull Off

        CGPROGRAM
        #pragma surface surf Standard vertex:vert addshadow fullforwardshadows
        #pragma target 3.0
        #pragma multi_compile_instancing

        sampler2D _MainTex;
        fixed4 _Color;

        float _WindStrength;
        float _WindSpeed;
        float4 _WindDirection;
        float _Cutoff;

        struct Input
        {
            float2 uv_MainTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full v)
        {
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

            // Высота вершины (0 внизу, 1 вверху)
            float heightFactor = saturate(v.texcoord.y);

            float time = _Time.y * _WindSpeed;

            // Несинхронность по позиции
            float wave = sin(time + worldPos.x * 0.5 + worldPos.z * 0.5);

            float2 windDir = normalize(_WindDirection.xz);

            float2 offset = windDir * wave * _WindStrength * heightFactor;

            v.vertex.xz += offset;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            clip(c.a - _Cutoff);

            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }

    FallBack "Transparent/Cutout/VertexLit"
}
