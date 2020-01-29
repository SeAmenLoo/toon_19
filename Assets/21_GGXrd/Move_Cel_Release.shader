Shader "Move/Cel_Release"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SSSTex("SSS (RGB)", 2D) = "white" {}
		_ILMTex("ILM (RGB)", 2D) = "white" {}

		_Shininess ("Shininess", Range (0.001, 2)) = 0.078125
		_SpecStep ("_SpecStep",Range(0.1,0.3)) = 0.5
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline Width", Range(.0,0.01)) = 0.01
		_ShadowContrast("Shadow Contrast", Range(-2,1)) = 1
		_DarkenInnerLine("Darken Inner Line", Range(0, 1)) = 0.2

		_WorldLightDir ("_WorldLightDir",Vector) = (1,1,1,1)
	}
	/*
        •R：判断阴影的阈值对应的Offfset。1是标准，越倾向变成影子的部分也会越暗(接近0)，0的话一定是影子。
        •G：对应到Camera的距离，轮廓线的在哪个范围膨胀的系数    
        •B：轮廓线的Z Offset 值
        •A：轮廓线的粗细系数。0.5是标准，1是最粗，0的话就没有轮廓线。
	*/
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			Name "OUTLINE"
			Tags {"LightMode" = "Always"}
			Cull Front
			ZWrite On
			ColorMask RGB
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			fixed _Outline;
			fixed4 _OutlineColor;

			v2f vert (appdata v)
			{
				v2f o;
				
				float4 vPos = float4(UnityObjectToViewPos(v.vertex),1.0f);
				float cameraDis = length(vPos.xyz);
				vPos.xyz += normalize(normalize(vPos.xyz)) * v.color.b;
				float3 vNormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
				o.pos = mul(UNITY_MATRIX_P,vPos);
				float2 offset = TransformViewToProjection(vNormal).xy;
				offset += offset * cameraDis  * v.color.g;
				o.pos.xy += offset * _Outline* v.color.a;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _OutlineColor;
				return col;
			}
			ENDCG
		}
		

		Pass
		{
			
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texCoord : TEXCOORD0;
				fixed4 color : COLOR;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float3 normal : NORMAL;
				float4 vertex : TEXCOORD1;
			};

			sampler2D _MainTex,_SSSTex,_ILMTex;
			float4 _MainTex_ST;
			fixed _ShadowContrast,_DarkenInnerLine,_Shininess,_SpecStep;
			fixed4 _LightColor0;
			// fixed4 _WorldLightDir;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texCoord,_MainTex);
				o.color = v.color;
				o.vertex = v.vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 finCol;
				fixed4 mainTex = tex2D(_MainTex,i.uv);
				fixed4 sssTex = tex2D(_SSSTex,i.uv);
				fixed4 ilmTex = tex2D(_ILMTex,i.uv);

				finCol = mainTex;

				fixed3 brightCol = mainTex.rgb;
				fixed3 shadowCol = mainTex.rgb * sssTex.rgb;
				fixed lineCol = ilmTex.a;
				lineCol = lerp(lineCol,_DarkenInnerLine,step(lineCol,_DarkenInnerLine)); 

				fixed shadowThreshold = ilmTex.g;
				shadowThreshold *= i.color.r;
				shadowThreshold = 1- shadowThreshold + _ShadowContrast;
				
				float3 normalDir = normalize(i.normal);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);//normalize(_WorldLightDir.xyz);
				
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex));
				float3 halfDir = normalize(viewDir + lightDir);

				float NdotL = dot(normalDir,lightDir);
				float NdotH = max(0,dot(normalDir,halfDir));
				
				fixed ilmTexR = ilmTex.r;
				fixed ilmTexB = ilmTex.b;

				float shadowContrast = step(shadowThreshold,NdotL);
				finCol.rgb = lerp(shadowCol,brightCol,shadowContrast);
				
				finCol.rgb += shadowCol*0.5f*step(_SpecStep,ilmTexB*pow(NdotH,_Shininess*ilmTexR*128)) *shadowContrast ;
				finCol.rgb *= lineCol;
			 	
			 	finCol *= _LightColor0;
			 	finCol *= 1 + UNITY_LIGHTMODEL_AMBIENT;
				
				finCol.a = mainTex.a;
				
				return finCol;
			}
			ENDCG
		}
	}
}
