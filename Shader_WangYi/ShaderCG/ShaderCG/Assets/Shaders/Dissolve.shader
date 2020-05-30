Shader "LiuSu/Dissolve"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BurnMap("Fire Map", 2D) = "white" {}
		_BurnSpeed("Burn Speed", float) = 1.0
		_Specular("Specular", range(0, 1)) = 0.5
		_Gloss("Gloss", range(8, 256)) = 20
			//_BurnAmount ("BurnAmount", range(0,1)) = 0

			_BurnFirstColor("Burn First Color", Color) = (1,0,0,1)
			_BurnSecondColor("Burn Second Color", Color) = (0,0,0,1)
			_BurnRange("Burn Range", float) = 0.1
	}
		SubShader
		{
			Tags { "LightMode" = "ForwardBase" }


			Pass
			{
				Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"


				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BurnMap;
				fixed _BurnSpeed;
				fixed _Gloss;
				float _Specular;

				fixed _BurnAmount;
				fixed4 _BurnFirstColor;
				fixed4 _BurnSecondColor;
				float _BurnRange;

				struct a2v {
					float4 vertex : POSITION;
					float4 normal : NORMAL;
					float4 uv : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 worldPos : TEXCOORD1;
					float3 worldNormal : TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);

					o.worldPos = mul(unity_ObjectToWorld, v.vertex);
					o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					//burn map
					fixed3 burn = tex2D(_BurnMap, i.uv).rgb;
					_BurnAmount += _Time.y * _BurnSpeed;
					clip(burn.r - _BurnAmount);


					// sample the texture
					fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

					//diffuse
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed3 diffuse = _LightColor0.rgb * saturate(dot(lightDir, i.worldNormal)) * albedo;

					//specular
					fixed3 reflectDir = normalize(reflect(-lightDir, i.worldNormal));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

					fixed3 finalColor = specular + diffuse + ambient;

					//在消融的边缘位置，添加红色和黑色，模拟烧焦的效果。当前正在烧的边缘就是那些r - _BurnAmount刚好为0的位置。
					//float burnRate = 1 - saturate((burn.r - _BurnAmount) / _BurnRange);
					float burnRate = 1 - smoothstep(0, _BurnRange, burn.r - _BurnAmount);
					fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, burnRate);
					//burnColor = pow(burnColor, 5);
					finalColor = lerp(finalColor, burnColor, burnRate);

					return fixed4(finalColor, 1);
				}
				ENDCG
			}
		}
}