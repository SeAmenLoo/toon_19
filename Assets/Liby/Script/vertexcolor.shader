Shader "Custom/VertexColor" 
{

Properties
	{
		

		_Shininess ("Shininess", Range (0.001, 2)) = 0.078125
		_SpecStep ("_SpecStep",Range(0.1,0.3)) = 0.5
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline Width", Float) = 0.01

	}
	SubShader 
	{		
		CGPROGRAM

		#pragma surface surf Lambert vertex:vert
		#pragma target 3.0
 
 		#include "UnityCG.cginc"
            
		struct Input {
			float4 vertColor;
		};

		void vert(inout appdata_full v, out Input o){
			o.vertColor = v.color;
		}

		half3 surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = half3(IN.vertColor.r,IN.vertColor.g,IN.vertColor.b);
			//o.Albedo = IN.vertColor.rgb;
            o.Alpha=IN.vertColor.a;
			half3 col = o.Albedo;
			return col;
		}

		ENDCG
		Pass
		{
			/*
			顶点色
				•R：判断阴影的阈值对应的Offset。1是标准，越倾向变成影子的部分也会越暗(接近0)，0的话一定是影子。
				•G：对应到Camera的距离，轮廓线的在哪个范围膨胀的系数    
				•B：轮廓线的Z Offset 值
				•A：轮廓线的粗细系数。0.5是标准，1是最粗，0的话就没有轮廓线。
			*/
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
		
	}
}
