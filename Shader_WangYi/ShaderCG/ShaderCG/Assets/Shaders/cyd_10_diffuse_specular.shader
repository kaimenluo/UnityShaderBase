// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "cyd/cyd_10_Fragment_BinnPhone"{
	Properties{
		_Diffuse("Diffuse Color", Color) = (1,1,1,1)
		_Specular("Specular Color", Color) = (1,1,1,1)
		_Gloss("Gloss",Range(10,100)) = 15 
	}
	SubShader{
		Pass{

			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
#include "Lighting.cginc"
#pragma vertex vert
#pragma fragment frag
			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss; //高光系数
			
			struct a2v{
				float4 vertex:POSITION;  //位置
				float3 normal:NORMAL;    //法线
			};

			struct v2f{
				float4 svPos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float4 worldVertex:TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f f;
				f.svPos = UnityObjectToClipPos(v.vertex);
				f.worldNormal = UnityObjectToWorldNormal(v.normal);
				f.worldVertex = mul(v.vertex, unity_WorldToObject);//模型空间下的坐标-》世界空间下的坐标
				return f;
			}

			/*
			不要忘了SV_Target的语义
			*/
			fixed4 frag(v2f f):SV_Target {
				fixed3 normalDir = normalize(f.worldNormal); //世界空间下的法线方向
				fixed3 lightDir = normalize(WorldSpaceLightDir(f.worldVertex));

				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(normalDir,lightDir) *0.5 + 0.5); //半lambert
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(dot(normalDir,lightDir),0);
	

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertex));
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(normalDir, halfDir),0), _Gloss);
					
				fixed3 tmpColor = diffuse + specular + UNITY_LIGHTMODEL_AMBIENT.rgb;

				return fixed4(tmpColor,1);
			}


			ENDCG
		
		}
	
	}
	FallBack "Specular"
} 
