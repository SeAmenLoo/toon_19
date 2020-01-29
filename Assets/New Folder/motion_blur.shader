Shader "mgo/motion_blur" {	
	Properties{ 
		_MainTex("Texture", 2D) = "white" {}		
	_BlurSize("_BlurSize", range(0.001, 0.999)) = 0.9 } 	
	SubShader{ 
		Tags{ "RenderType" = "Opaque" }				
		ZTest Off		
		cull Off		
		ZWrite Off		
		Blend SrcAlpha OneMinusSrcAlpha 		
		Pass{			
			Name "Main"			
			CGPROGRAM			
			#pragma vertex vert			
			#pragma fragment frag 			
			#include "UnityCG.cginc" 			
			struct appdata 
			{ 
				float4 vertex:POSITION;				
				float2 uv:TEXCOORD0; 
			}; 			
			struct v2f 
			{
				float4 pos:SV_POSITION;				
				float2 uv:TEXCOORD0; 
			}; 			
			uniform sampler2D _MainTex;			
			uniform half _BlurSize; 			
			v2f vert(appdata v) 
			{ 
				v2f o;				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o; 
			} 			
			fixed4 frag(v2f i) : SV_Target			
			{				
				fixed4 color = tex2D(_MainTex,i.uv);				//降低中心人物的运动模糊start	
				float r = sqrt(pow(i.uv.x-0.5,2) + pow(i.uv.y-0.6,2));				
				float a = _BlurSize * pow((1 - r + 0.01), 5);		
				if (a < 1 - _BlurSize)			
				{					
					a = 1 - _BlurSize;		
				}			
				color.a = 0.5;				//降低中心人物的运动模糊end 	
											//color.a = 1 - _BlurSize;		
				return color;			
			}		
			ENDCG		
		}		
	}
}
