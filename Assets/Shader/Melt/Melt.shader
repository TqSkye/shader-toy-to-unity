Shader "ShaderToy/003(Melt)"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Center("Center", Vector) = (-0.5,-0.5,0,0)
        _Zoom("Zoom", Float) = 40
        _Brightness("Brightness", Float) = 0.975
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
        half4 _Color;
        float4 _MainTex_ST;
        float3 _Center;
        float _Zoom;
        float _Brightness;
        CBUFFER_END

        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);        
        

        ENDHLSL
        
        pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct UnlitPassVertex
            {
                float4 positionOS   : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct UnlitPassFragment
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalW : TEXCOORD1;
            };
        
            // functions -----------------------------------

            float cosRange(float degrees, float range, float minimum) {
	            return (((1.0 + cos(degrees * 0.017453292519943295)) * 0.5) * range) + minimum;
            }

            // -----------------------------------

            UnlitPassFragment vert(UnlitPassVertex IN)
            {
                UnlitPassFragment OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalW = TransformObjectToWorldNormal(IN.normalOS, true);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(UnlitPassFragment IN) : SV_TARGET
            {
                // half4 texDiff = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                float2 p = IN.uv +_Center;

                float ct = cosRange(_Time.y * 5.0, 3.0, 1.1);
	            float xBoost = cosRange(_Time.y * 0.2, 5.0, 5.0);
	            float yBoost = cosRange(_Time.y * 0.1, 10.0, 5.0);
                float fScale = cosRange(_Time.y * 15.5, 1.25, 0.5);

                //int zoom = 40;
                //float brightness = 0.975;

                for(int i=1;i<_Zoom;i++) {
                    float _i = float(i);
                    float2 newp = p;
                    newp.x+=0.25/_i*sin(_i*p.y+_Time.y*cos(ct)*0.5/20.0+0.005*_i)*fScale+xBoost;
                    newp.y+=0.25/_i*sin(_i*p.x+_Time.y*ct*0.3/40.0+0.03*float(i+15))*fScale+yBoost;
                    p=newp;
                }

                float3 col=float3(0.5*sin(3.0*p.x)+0.5,0.5*sin(3.0*p.y)+0.5,sin(p.x+p.y));
                col *= _Brightness;

                // Add border
                float vigAmt = 5.0;
                float vignette = (1.0-vigAmt*(IN.uv.y-0.5)*(IN.uv.y-0.5))*(1.0-vigAmt*(IN.uv.x-0.5)*(IN.uv.x-0.5));
                float extrusion = (col.x + col.y + col.z) / 4.0;
                extrusion *= 1.5;
                extrusion *= vignette;
    
                // fragColor = float4(col, extrusion);
                return float4(col, extrusion);
            }
            ENDHLSL
        }
    }        
}
