﻿Shader "Unlit/Depth"
{

	SubShader{
		Tags { "RenderType" = "Opaque" }

		Pass{
			CGPROGRAM
			#pragma vertex vert  
			#pragma fragment frag  
			#include "UnityCG.cginc"  

			sampler2D _CameraDepthTexture;

			struct v2f {
			   float4 pos : SV_POSITION;
			   float4 scrPos:TEXCOORD1;
			};

			//Vertex Shader  
			v2f vert(appdata_base v) {
			   v2f o;
			   o.pos = UnityObjectToClipPos(v.vertex);
			   o.scrPos = ComputeScreenPos(o.pos);
			   return o;
			}

			//Fragment Shader  
			float4 frag(v2f i) : color{
				//float depthValue = tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(i.scrPos)).r;
			   float depthValue = Linear01Depth(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(i.scrPos)).r);
			   return float4(depthValue,0,0,1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
