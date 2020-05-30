// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LiuSu/06 Diffuse Fragment HalfLambert"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
	}
		SubShader{
			Pass{

				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM

		#include "Lighting.cginc"//取得第一个直射光的颜色 _LightColor0, 第一个直射光的位置 _WorldSpaceLightPos0

		#pragma vertex vert
		#pragma fragment frag
				fixed4 _Diffuse;
			struct a2v {
				float4 vertex : POSITION;//告诉unity把模型空间下的顶点坐标填充给vertex
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 position:SV_POSITION;
				fixed3 worldNormalDir : COLOR0;
			};

			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.worldNormalDir = mul(v.normal, (float3x3)unity_WorldToObject);
				
				return f;
			}

			fixed4 frag(v2f f) : SV_Target {

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 normalDir = normalize(f.worldNormalDir);

				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);//对于每个顶点来说，光的位置就是光的方向，因为光是平行光
				float halfLambert = dot(normalDir, lightDir) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb * halfLambert * _Diffuse.rgb;//取得漫反射的颜色
				fixed3 tempColor = diffuse + ambient;

				return fixed4(tempColor,1);
			}

			ENDCG
		}
	}
		Fallback "VertexLit"
}
