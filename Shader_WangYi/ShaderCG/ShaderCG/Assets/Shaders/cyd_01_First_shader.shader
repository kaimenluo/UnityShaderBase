Shader "cyd/001_myShader"{

	Properties{
		//属性
		_Color("Color",Color)=(1,1,1,1)      //float4
		_Vector("Vector",Vector)=(5,2,3,4)   //float4
		_Int("Int", Int)=12341               //float
		_Float("Float",Float)=1.2            //float
		_Range("Range",Range(5,20))=10       //float
		_2D("Texture",2D)="red"{}            //sampler2D
		_Cube("Cube",Cube)="white"{}         //samplerCube
		_3D("Texture",3D)="blue"{}           //sampler3D
	}

	/*SubShader可以有很多个
	显卡运行效果时，将会从第一个subshader开始，如果第一个SubShader里面的效果
	都可以实现，则使用第一个SubShader,如果无法实现SubShader的某些效果，那么会自动寻找下一个SubShader
	*/
	SubShader{
		//至少有一个Pass
		Pass{
			//在这里编写Shader代码
			CGPROGRAM
			//使用CG语言编写shader代码
			//float4 _Color;        //half4 fixed4
			fixed4 _Color;
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
			//half 16位 -6万~+6万
			//fixed 11位 -2~+2

			ENDCG
		}
	}

	FallBack "VertexLit"	

}