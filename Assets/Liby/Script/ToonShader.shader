Shader "Liby/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowTex("Shadow",2D)="white"{}
        _DetTex("Detial",2D)="white"{}

		_OutLineColor("OutLineColor",color) = (0,0,0,1)
        _OutLineWidth("OutLineWidth",float)=0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "OutLine"
            Tags{"LightMode"="Always"}
            cull front
            zwrite on
    
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:normal;

            };

            struct v2f
            {

                float4 vertex : SV_POSITION;
            };

            fixed4 _OutLineColor;
			float _OutLineWidth;
            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				

                
               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _OutLineColor;

                return col;
            }
            ENDCG
        }
		Pass
		{
			Name "ToonPass"
			Tags{"LightMode" = "Always"}
			
			zwrite on

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:normal;

			};

			struct v2f
			{

				float4 vertex : SV_POSITION;
			};

			fixed4 _OutLineColor;

			v2f vert(appdata v)
			{
				v2f o;
				float4 vNormal = float4 (normalize(v.normal),1);
				o.vertex = UnityObjectToClipPos(v.vertex + vNormal);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = _OutLineColor;

				return col;
			}
			ENDCG
		}
    }
}
