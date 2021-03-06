﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LiuSu/07 Specular Vertex"{
	Properties{
		_Diffuse("Diffuse Color",Color) = (1,1,1,1)
		_Specular("Specular Color",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,100))=10
	}
		SubShader{
			Pass{

				Tags{ "LightMode" = "ForwardBase" }

				CGPROGRAM

		#include "Lighting.cginc"//取得第一个直射光的颜色 _LightColor0, 第一个直射光的位置 _WorldSpaceLightPos0

		#pragma vertex vert
		#pragma fragment frag
				fixed4 _Diffuse;
				fixed4 _Specular;
				half _Gloss;


			struct a2v {
				float4 vertex : POSITION;//告诉unity把模型空间下的顶点坐标填充给vertex
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 position:SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v) {
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 normalDir = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);//对于每个顶点来说，光的位置就是光的方向，因为光是平行光
				fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir, lightDir), 0) * _Diffuse.rgb;//取得漫反射的颜色

				fixed3 refleDir = normalize(reflect(-lightDir, normalDir));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(v.vertex, unity_WorldToObject).xyz);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(refleDir, viewDir), 0), _Gloss);

				f.color = diffuse + ambient + specular;
				return f;
			}

			fixed4 frag(v2f f) : SV_Target {
				return fixed4(f.color,1);
			}

			ENDCG
		}
	}
		Fallback "VertexLit"
}
