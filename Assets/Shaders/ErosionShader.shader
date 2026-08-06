Shader "MyShaders/ErosionShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "black" {}
        _AnimateXY("Animate X Y", Vector) = (0, 0, 0, 0)

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor ("SRC Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("DST Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0


        _Reveal("Reveal MainTex", Float) = 0
        _Feather("Feathering", Float) = 0
        _ErodeColor("Erosion Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _MaskTex_ST;
            
            float _Reveal;
            float _Feather;
            float4 _ErodeColor;

             // Used for Animation
            float4 _AnimateXY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex); // First Texture
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex); // Second Texture

                o.uv.zw += frac(_AnimateXY.xy * _MaskTex_ST * float2(_Time.yy));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 mainTex = tex2D(_MainTex, i.uv.xy);
                fixed4 maskTex = tex2D(_MaskTex, i.uv.zw);

                //float revealAmount = smoothstep(maskTex.r - _Feather, maskTex.r + _Feather, _Reveal);

                float revealAmountTop = step(maskTex.r, _Reveal + _Feather);
                float revealAmountBottom = step(maskTex.r, _Reveal - _Feather);
                float revealDifference = revealAmountTop - revealAmountBottom;

                float4 finalCol = lerp(mainTex.rgba, _ErodeColor, revealDifference); 

                //return maskTex;
                return fixed4(finalCol.rgb, (mainTex.a * finalCol.a) * revealAmountTop);
            }
            ENDCG
        }
    }
}
