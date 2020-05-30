// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "cyd/003_use_struct"{
	SubShader{
		Pass{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

			/*
			结构体a2v封装
			vertex:POSITION(语义) -> 告诉unity把模型空间下的顶点坐标填充给vertex
			normal:NORMAL(语义) -> 告诉unity把模型空间下的法线填充给normal
			float4 texcoord:TEXCOORD0; -> 告诉unity把第一套纹理坐标填充给texcoord

			片元函数传递给系统
			SV_Target 颜色值，显示到屏幕上的颜色

			*/
			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			/*
			定义一个结构体用来存储坐标转换后的顶点坐标传送到片元着色器
			*/
			struct v2f{
				float4 position:SV_POSITION;
				float3 temp:COLOR0;
			};

			/*
			f.position = UnityObjectToClipPos(v.vertex); 
			f.position = mul(UNITY_MATRIX_MVP, v.vertex)
			vert:顶点着色器
			frag:片元着色器
			*/
			v2f vert(a2v v){
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				f.temp = v.normal;
				return f;
			}

			fixed4 frag(v2f f):SV_Target{
				//return fixed4(0.2,0.8,0.6,1);
				return fixed4(f.temp,1);
			}

			ENDCG
		
		}
	}
	FallBack "VertexLit"
}