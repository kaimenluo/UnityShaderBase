

Shader "cyd/cyd_09_Fragment_BinnPhone"{
	Properties{
		_Diffuse("Diffuse Color",Color)=(1,1,1,1)
		_Specular("Specular Color",Color)=(1,1,1,1)
		_Gloss("Gloss", Range(8,100)) = 10
	}
	SubShader{
		Pass{

			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

	#include "Lighting.cginc"
	//包含unity的内置的文件，才可以使用unity内置的一些变量


	#pragma vertex vert
	#pragma fragment frag

			fixed4 _Diffuse;
			fixed4 _Specular;
			half _Gloss;

			/*
			_Gloss:高光系数
			结构体a2v封装
			vertex:POSITION(语义) -> 告诉unity把模型空间下的顶点坐标填充给vertex
			normal:NORMAL(语义) -> 告诉unity把模型空间下的法线填充给normal
			float4 texcoord:TEXCOORD0; -> 告诉unity把第一套纹理坐标填充给texcoord

			片元函数传递给系统
			SV_Target 颜色值，显示到屏幕上的颜色

			*/
			struct a2v{
				float4 vertex : POSITION;
				float3 normal : Normal;
			};

			/*
			定义一个结构体用来存储坐标转换后的顶点坐标传送到片元着色器
			*/
			struct v2f{
				float4 position:SV_POSITION;
				float3 worldNormal:Texcoord0;
				float4 worldVertex:Texcoord1;
			};

			/*
			f.position = UnityObjectToClipPos(v.vertex); 
			f.position = mul(UNITY_MATRIX_MVP, v.vertex)
			vert:顶点着色器
			frag:片元着色器
			normalize()用来把一个向量单位化(原来的向量保持不变，长度为1)

			(float3x3)unity_WorldToObject: 截取前三行前三列

			_WorldSpaceLightPos0: 取得平行光的位置
			_LightColor0:取得平行光的颜色
			unity_WorldToObject:模型空间到世界空间的变换矩阵的逆矩阵
			ambient: 环境光
			diffuse + ambient: +表示叠加

			reflect(-lightDir,normalDir);
			lightDir是物体到光源的向量, 与入射光的反向相反
			reflect(-lightDir,normalDir) 取得反射光的方向

			取得视野向量 = _WorldSpaceCameraPos.xyz(摄像机的坐标) - 物体的世界坐标
			mul(向量的行形式，正交矩阵) = mul(正交矩阵的逆(转置)，向量的列形式)
			unity_WorldToObject的逆为unity_ObjectToWorld

			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(v.vertex, unity_WorldToObject).xyz); 
			mul(unity_ObjectToWorld, v.vertex): 从局部坐标系转换到世界坐标系
			fixed3 specular = 直射光的颜色 * pow(max(cosx,0), 高光参数);

			UnityObjectToWorldNormal:将法线从模型空间转换到世界空间

			WorldSpaceLightDir(float4 v) 	模型空间中的顶点坐标==》世界空间中从这个点到光源的方向
			*/
			v2f vert(a2v v){
				v2f f;
				f.position = UnityObjectToClipPos(v.vertex);
				//f.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				f.worldNormal = UnityObjectToWorldNormal(v.normal);
				f.worldVertex = mul(v.vertex, unity_WorldToObject);
				return f;
			}

			fixed4 frag(v2f f):SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				//用于将法线向量从世界空间转换到模型空间
				fixed3 normalDir = normalize(f.worldNormal); 

				//fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 lightDir = normalize(WorldSpaceLightDir(f.worldVertex));

				fixed3 diffuse= _LightColor0.rgb * max(dot(normalDir, lightDir),0) * _Diffuse.rgb; //取得漫反射的颜色

				fixed3 reflectDir = normalize(reflect(-lightDir,normalDir));


				/*
				法线 和 光和视野方向的平分线的夹角
				f.worldVertex = _WorldSpaceCameraPos.xyz - mul(x.vertex,unity_WorldToObject).xyz
				viewDir: 视野方向
				float3 UnityWorldSpaceViewDir(float4 v) 世界空间中的顶点坐标==》世界空间从这个点到摄像机的观察方向

				*/
		
				//fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - f.worldVertex);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(f.worldVertex));

				fixed3 halfDir = normalize((lightDir + viewDir) / 2);
				fixed3 specular =_LightColor0.rgb * pow(max(dot(normalDir,halfDir),0),_Gloss) * _Specular.rgb;

				fixed3 tempColor = diffuse + ambient + specular;

				return fixed4(tempColor,1);
			}

			ENDCG
		
		}
	}
	FallBack "VertexLit"
}