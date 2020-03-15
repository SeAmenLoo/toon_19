Shader "Hidden/DepthBuffer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
				
		Tags { "RenderType" = "Opaque" }
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
		//Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            sampler2D _DepthBuffer;
            float _Num;

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
			fixed4 frag (v2f i) : SV_Target
            {
                float curD= Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
				float subD = tex2D(_DepthBuffer, i.uv).r;
				float4 sub=tex2D(_DepthBuffer,i.uv);
				//float4 sub = tex2Dproj(_DepthBuffer, UNITY_PROJ_COORD(i.scrPos));
				float vol = min(step(sub.g,1), step(subD, curD));
                float col=vol* sub.r +(1.0-vol)*curD;
                float n=1.0/_Num;
                
				return fixed4(col, vol*sub.g +n, 0, 1.0);
            }
            ENDCG
        }
    }
}
