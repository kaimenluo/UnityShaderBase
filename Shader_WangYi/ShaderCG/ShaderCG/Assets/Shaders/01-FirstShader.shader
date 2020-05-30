//这里指定shader的名字，不要求与文件名保持一致
Shader "LiuSu/01 myShader"{

	Properties{
		//属性
		_Color("Color",Color)=(1,1,1,1)		//float4
		_Vector("Vector",Vector)=(1,2,3,4)	//float4
		_Int("Int",Int)=12341				//float
		_Float("Float",Float)=1.2			//float
		_Range("Range",Range(5,20))=10		//float
		_2D("Texture",2D) = "red"{}			//sampler2D
		_Cube("Cube",Cube) = "white"{}		//samplerCube
		_3D("Texure",3D) = "blue"{}			//sampler3D
	}
	//SubShader可以有很多个 当显卡运行效果的时候，将会从第一个SubShader开始，如果第一个SubShader里面的效果都可以实现
	//那么就使用第一个SubShader，如果显卡无法实现当前SubShader里面的某些效果，那么他会自动寻找下一个SubShader
	SubShader{
		//至少有一个Pass
		Pass{
		//在这里编写shader代码 HLSLPROGRAM
		CGPROGRAM
		//使用CG语言编写shader代码
		float4 _Color;		//half3 fixed3
		//fixed4 _Color;
		float3 a3;
		float2 a2;
		float a;
		float4 _Vector;
		float _Int;
		float _Float;
		float _Range;
		sampler2D _2D;
		samplerCube _Cube;
		sampler3D _3D;
		//float 32位存储
		//half 16 -6万 ~ +6万
		//fixed 11 -2 ~ +2

		ENDCG
		}

	}
	Fallback "VertexLit"
}