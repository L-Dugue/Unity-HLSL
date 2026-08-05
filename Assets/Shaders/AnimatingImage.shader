Shader "MyShaders/AnimatingImage"
{
    Properties
    {
       _MainTexture("Main Texture", 2D) = "white" {}
       _AnimateXY("Animate X Y", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Sampler
            sampler2D _MainTexture;
            
            // Texture Offset Coord from UnitCG
            float4 _MainTexture_ST;

            // Used for Animation
            float4 _AnimateXY;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                o.uv += frac(_AnimateXY.xy * _MainTexture_ST * float2(_Time.yy));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                fixed4 textureColor = tex2D(_MainTexture, uv);
                fixed4 col = fixed4(i.uv, 0, 1);
                return textureColor * 0.5;
            }
            ENDCG
        }
    }
}
