Shader "Hidden/test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
		Cull Off ZWrite Off ZTest Always

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
				float4 scrPos:TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.scrPos = ComputeScreenPos(o.vertex);
				return o;
			}
			sampler2D _OldFrame;
			sampler2D _CameraDepthTexture;
			sampler2D _CurFrame;
			float _BlurAmount;


            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
				 float curD = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
                fixed4 col = tex2D(_OldFrame, i.uv).r;
                // just invert the colors
				fixed4 oldcol = tex2D(_OldFrame, i.uv);
				
				fixed4 s = oldcol* _BlurAmount +col*(1 - _BlurAmount);
				//oldcol.a = 0.9;
				//oldcol.r += 0.7;
				return fixed4(curD, curD, curD,1);
            }
            ENDCG
        }
    }
}
