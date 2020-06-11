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
			#include "UnityCustomRenderTexture.cginc"
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
			sampler2D _CameraMotionVectorsTexture;
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
				float depthValue = Linear01Depth(tex2Dproj(_CameraDepthTexture,i.scrPos).r);
				float2 mo = tex2Dproj(_CameraMotionVectorsTexture, UNITY_PROJ_COORD(i.scrPos));
				return fixed4(mo.r,mo.g, depthValue,1);
            }
            ENDCG
        }
    }
}
