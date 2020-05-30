// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LiuSu/02 secondshader can run"{
	SubShader{
		Pass{
			CGPROGRAM
//顶点函数 这里只是声明了，顶点函数的函数名
//基本作用为：完成顶点坐标从模型空间到剪裁空间的转换（从游戏环境转换到视野相机屏幕上）
#pragma vertex vert
//片元函数 这里只是声明了，片元函数的函数名
//基本作用为：返回模型对应的屏幕上的每一个像素的颜色值
#pragma fragment frag
//通过语义告诉系统，这个参数的作用是什么，比如POSITION的作用是，告诉系统我需要顶点坐标
//SV_POSITION这个语义是用来解释说明返回值，意思就是返回值是剪裁空间下的顶点坐标
			float4 vert(float4 v : POSITION) : SV_POSITION {
			/*float4 pos = mul(UNITY_MATRIX_MVP,v);
			return pos;*/
			return UnityObjectToClipPos(v);
			}

			fixed4 frag() : SV_Target {
				return fixed4(0.2,0.8,0.6,1);
			}

			ENDCG
		}
	}
	Fallback "VertexLit"
}
