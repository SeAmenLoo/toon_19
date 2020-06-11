Shader "Hidden/ColorBuffer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Tags { "RenderType" = "Opaque" }
		//Blend SrcAlpha OneMinusSrcAlpha
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.scrPos = ComputeScreenPos(o.vertex);
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CurFrame;
			sampler2D _OldFrame;
            sampler2D _CameraDepthTexture;
			sampler2D _LastCameraDepthTexture;
            sampler2D _DepthBuffer;
            float _AccumOrig;


			float4 frag (v2f i) : SV_Target
            {
				float4 old = tex2D(_DepthBuffer,i.uv);
                float oldD=tex2D(_DepthBuffer,i.uv).r;
				
				//float oldD = Linear01Depth(tex2Dproj(_DepthBuffer, UNITY_PROJ_COORD(i.scrPos)).r);
                //fixed curD=tex2D(_CameraDepthTexture,i.uv).r;
				float curD = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);

				float d = old.g;//1 - step(curD - oldD, 0.00001);//step(0.1,curD- oldD);
                fixed4 curC=tex2D(_CurFrame,i.uv);
                fixed4 oldC=tex2D(_OldFrame,i.uv);
                fixed4 col= (1 - d)*curC+d*(_AccumOrig*oldC +(1-_AccumOrig)*curC);
                //return fixed4(d, d, d,1);
				return col;

				//return fixed4(old.r, old.r, old.r, 1);
            }
            ENDCG
        }
    }

}
