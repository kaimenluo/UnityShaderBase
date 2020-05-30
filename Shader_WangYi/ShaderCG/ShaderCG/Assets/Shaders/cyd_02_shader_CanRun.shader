Shader "cyd/002_secondshader_can_run"{
	SubShader{
		Pass{
			CGPROGRAM
//顶点函数,这里只是申明了顶点函数的函数名
//基本作用为:完成顶点坐标到剪裁空间的转换(从游戏环境转换到视野相机屏幕上)
#pragma vertex vert

//片元函数 这里只是声明了，片元函数的函数名
//基本作用为:返回模型对应的屏幕上的每一个像素的颜色值
#pragma fragment frag
			//M(模型坐标-局部坐标)-V(世界坐标-视口坐标系)-P(视口坐标系-二维屏幕坐标系)
			//SV_POSITION是剪裁空间的坐标(二维平面)
			float4 vert(float4 v:POSITION) : SV_POSITION {
				//return UnityObjectToClipPos(v);
				return UnityObjectToClipPos(v);
			}

			fixed4 frag():SV_Target{
				return fixed4(0.2,0.8,0.6,1);
			}

			ENDCG
		
		}
	}
	FallBack "VertexLit"
}