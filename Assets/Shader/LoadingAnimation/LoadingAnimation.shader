Shader "ShaderToy/002(LoadingAnimation)"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Center("Center", Vector) = (-0.5,-0.5,0,0)
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

            float f(float t) {
                float f = frac(t/8.0)*4.0-2.0;
                return abs(smoothstep(0.0,0.5,frac(f)-0.25)+floor(f))-1.0;
            }

            float dist(float2 p) {
                float d = 0.0;
                float t = -_Time.y;
                for (float i=0;i<7.0;i+=1.) {
                    float a = 3.1415926535/20*i*2+t*2;
                    d += 1/length(p+float2(f(a),0));
                }
                return d;
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
                 float2 p = IN.uv + _Center;
                float d = dist(p)/5.0 - 8.0;

                // free antialiasing by FabriceNeyret2
                float c = d/min(5.0,fwidth(d));
                return float4(c,c,c,c);
            }
            ENDHLSL
        }
    }        
}
