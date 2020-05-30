// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "cyd/cyd_14_Rock_Alpha"{
	Properties{


		_Color("Color",color)=(1,1,1,1)
		_MainTex("Main Tex",2D)="white"{}
		_NormalMap("Normal Map",2D)="bump"{}
		_BumpScale("Bump Scale",Float)=1
		_AlphaScale("Alpha Scale",Range(0,1))=1
	}
	SubShader{
			/*
			先渲染不透明的 再渲染透明的物体
			"IngnorProjector"="True" 忽略投影
			
			*/
			Tags{"Queue"="Transparent" "IngnorProjector"="True" "RebderType"="Transparent"}
		Pass{

			Tags{"LightMode"="ForwardBase"} //标签（灯光）

			ZWrite Off     //关闭深度写入
			Blend SrcAlpha OneMinusSrcAlpha

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
			fixed4 _Color;

			sampler2D _MainTex;
			float4 _MainTex_ST; 

		    sampler2D _NormalMap;
			float4 _NormalMap_ST;
			float _BumpScale;
			float _AlphaScale;
			
			/*
			切线空间的确定是通过(存储到模型里面的)法线 和 (存储到模型里面) 的切线来确定的
			tangent.w 是用来确定切线空间中坐标轴的方向
			*/
			struct a2v{
				float4 vertex:POSITION;  //位置
				float3 normal:NORMAL;    //法线
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			/*
			xy用来存储_MainTex的纹理坐标
			zw用来存储_NomalMap的纹理坐标
			*/
			struct v2f{
				float4 svPos:SV_POSITION;
				float3 lightDir:TEXCOORD0; //切线空间下平行光的方向
				float4 worldVertex:TEXCOORD1;
				float4 uv:TEXCOORD2; 
			};

			/*
			_MainTex_ST.zw: 获取偏移值
			f.uv.zw 用来采样法线贴图的颜色 ->fixed4 normalColor = tex2D(_NormalMap,f.uv.zw);
			采取到法线贴图的颜色之后 ->  fixed3 tangentNormal = normalColor.xyz * 2 - 1;获得切线空间下的法线
			公式:normal = pixel*2 - 1


			*/
			v2f vert(a2v v){
				v2f f;
				f.svPos = UnityObjectToClipPos(v.vertex);
				f.worldVertex = mul(v.vertex, unity_WorldToObject);//模型空间下的坐标-》世界空间下的坐标
				f.uv.xy = v.texcoord.xy * _MainTex_ST.xy  + _MainTex_ST.zw;
				f.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

				/*
				调用这个宏之后，可以得到一个矩阵rotation, 把切线空间下的方向转换成模型空间下
				ObjSpaceLightDir(v.vertex); //得到模型空间下平行光的方向
				f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)); 模型空间下 -> 切线空间下
				*/
				TANGENT_SPACE_ROTATION;

				//ObjSpaceLightDir(v.vertex); //得到模型空间下平行光的方向

				f.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				//f.lightDir = mul(rotation, _WorldSpaceLightPos0.xyz);

				return f;
			}

			/*
			不要忘了SV_Target的语义
			tex2D(_MainTex, f.uv.xy); //图片 纹理坐标
			把所有跟法线向量有关的运算都放在线性空间下
			从法线贴图里面取得的法线方向是在切线空间下
			控制	tangentNormal.xy = tangentNormal.xy * _BumpScale;的凹凸程度
			*/
			fixed4 frag(v2f f):SV_Target {
				fixed4 normalColor = tex2D(_NormalMap,f.uv.zw);

				/*
				切线空间下的法线
				利用系统自带的UnpackNormal获得切线空间下的法线
				*/
				//fixed3 tangentNormal = normalColor.xyz * 2 - 1;
				fixed3 tangentNormal = UnpackNormal(normalColor);
				tangentNormal.xy = tangentNormal.xy * _BumpScale;
				tangentNormal = normalize(tangentNormal);

				fixed3 lightDir = normalize(f.lightDir);

				fixed4 texColor = tex2D(_MainTex, f.uv.xy) * _Color;

				fixed3 diffuse = _LightColor0.rgb * texColor.rgb * max(dot(tangentNormal,lightDir),0);

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertex));
				fixed3 halfDir = normalize(viewDir + lightDir);
					
				fixed3 tmpColor = diffuse  + UNITY_LIGHTMODEL_AMBIENT.rgb * texColor;

				return fixed4(tmpColor, _AlphaScale * texColor.a);
			}


			ENDCG
		
		}
	
	}
	FallBack "Specular"
} 
