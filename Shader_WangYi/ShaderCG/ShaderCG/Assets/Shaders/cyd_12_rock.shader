// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "cyd/cyd_12_Rock"{
	Properties{
		//_Diffuse("Diffuse Color", Color) = (1,1,1,1)
		_Color("Color",color)=(1,1,1,1)
		_MainTex("Main Tex",2D)="white"{}
	}
	SubShader{
		Pass{

			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
#include "Lighting.cginc"
#pragma vertex vert
#pragma fragment frag
			//fixed4 _Diffuse;

			/*
			//S:缩放 T:偏移
			xy:缩放
			zw:偏移
			*/
			sampler2D _MainTex;
			float4 _MainTex_ST; 

			fixed4 _Color;
			
			struct a2v{
				float4 vertex:POSITION;  //位置
				float3 normal:NORMAL;    //法线
				float4 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 svPos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float4 worldVertex:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			/*
			_MainTex_ST.zw: 获取偏移值
			*/
			v2f vert(a2v v){
				v2f f;
				f.svPos = UnityObjectToClipPos(v.vertex);
				f.worldNormal = UnityObjectToWorldNormal(v.normal);
				f.worldVertex = mul(v.vertex, unity_WorldToObject);//模型空间下的坐标-》世界空间下的坐标
				//f.uv = v.texcoord.xy ;
				f.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				return f;
			}

			/*
			不要忘了SV_Target的语义
			tex2D(_MainTex, f.uv.xy); //图片 纹理坐标
			*/
			fixed4 frag(v2f f):SV_Target {
				fixed3 normalDir = normalize(f.worldNormal); //世界空间下的法线方向
				fixed3 lightDir = normalize(WorldSpaceLightDir(f.worldVertex));

				fixed3 texColor = tex2D(_MainTex, f.uv.xy) * _Color;

				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(normalDir,lightDir) *0.5 + 0.5); //半lambert
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(dot(normalDir,lightDir),0);
				fixed3 diffuse = _LightColor0.rgb * texColor * max(dot(normalDir,lightDir),0);

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertex));
				fixed3 halfDir = normalize(viewDir + lightDir);
					
				fixed3 tmpColor = diffuse  + UNITY_LIGHTMODEL_AMBIENT.rgb * texColor;

				return fixed4(tmpColor,1);
			}


			ENDCG
		
		}
	
	}
	FallBack "Specular"
} 
