﻿Shader "Hidden/test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend zero one
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
			sampler2D _OldFrame;
			sampler2D _CurFrame;
			float _BlurAmount;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_CurFrame, i.uv);
                // just invert the colors
				fixed4 oldcol = tex2D(_OldFrame, i.uv);
				//col.a = _BlurAmount;
				//oldcol.a = 1- _BlurAmount;
				fixed4 s = oldcol+col;
				//oldcol.a = 0.9;
				//oldcol.r += 0.7;
				return oldcol;
            }
            ENDCG
        }
    }
}
