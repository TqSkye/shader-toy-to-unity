Shader "ShaderToy/004(Heartfelt(Rain))"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Center("Center", Vector) = (-0.5,-0.5,0,0)
        _RainAmount("RainAmount", Float) = 10
        
        [Toggle] _HAS_HEART("HAS_HEART", Float) = 0
        [Toggle] _USE_POST_PROCESSING("USE_POST_PROCESSING", Float) = 0
        [Toggle] _CHEAP_NORMALS("CHEAP_NORMALS", Float) = 0
        
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
        float _RainAmount;
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
            #pragma shader_feature_local_fragment _HAS_HEART_ON
            #pragma shader_feature_local_fragment _USE_POST_PROCESSING_ON
            #pragma shader_feature_local_fragment _CHEAP_NORMALS
            
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
            // #define S(a, b, t) smoothstep(a, b, t)
            // #define HAS_HEART
            // #define USE_POST_PROCESSING

            float S(float a, float b, float t) {
	            return smoothstep(a, b, t);
            }

            float3 N13(float p) {
	           float3 p3 = frac(float3(p,p,p) * float3(0.1031,0.11369,0.13787));
               p3 += dot(p3, p3.yzx + 19.19);
               return frac(float3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
            }

            float4 N14(float t) {
	            return frac(sin(t*float4(123, 1024, 1456, 264))*float4(6547, 345, 8799, 1564));
            }

            float N(float t) {
                return frac(sin(t*12345.564)*7658.76);
            }

            float Saw(float b, float t) {
	            return S(0, b, t)*S(1, b, t);
            }

            float2 DropLayer2(float2 uv, float t) {
                float2 UV = uv;
    
                uv.y += t*0.75;
                float2 a = float2(6, 1);
                float2 grid = a*2;
                float2 id = floor(uv*grid);
    
                float colShift = N(id.x); 
                uv.y += colShift;
    
                id = floor(uv*grid);
                float3 n = N13(id.x*35.2+id.y*2376.1);
                float2 st = frac(uv*grid)-float2(0.5, 0);
    
                float x = n.x-0.5;
    
                float y = UV.y*20;
                float wiggle = sin(y+sin(y));
                x += wiggle*(0.5-abs(x))*(n.z-0.5);
                x *= 0.7;
                float ti = frac(t+n.z);
                y = (Saw(0.85, ti)-0.5)*0.9+0.5;
                float2 p = float2(x, y);
    
                float d = length((st-p)*a.yx);
    
                float mainDrop = S(0.4, 0, d);
    
                float r = sqrt(S(1.0, y, st.y));
                float cd = abs(st.x-x);
                float trail = S(0.23*r, 0.15*r*r, cd);
                float trailFront = S(-0.02, 0.02, st.y-y);
                trail *= trailFront*r*r;
    
                y = UV.y;
                float trail2 = S(0.2*r, 0, cd);
                float droplets = max(0, (sin(y*(1-y)*120)-st.y))*trail2*trailFront*n.z;
                y = frac(y*10)+(st.y-0.5);
                float dd = length(st-float2(x, y));
                droplets = S(0.3, 0, dd);
                float m = mainDrop+droplets*r*trailFront;
    
                //m += st.x>a.y*0.45 || st.y>a.x*0.165 ? 1.2 : 0;
                return float2(m, trail);
            }

            float StaticDrops(float2 uv, float t) {
	            uv *= 40;
    
                float2 id = floor(uv);
                uv = frac(uv)-0.5;
                float3 n = N13(id.x*107.45+id.y*3543.654);
                float2 p = (n.xy-0.5)*0.7;
                float d = length(uv-p);
    
                float fade = Saw(0.025, frac(t+n.z));
                float c = S(0.3, 0, d)*frac(n.z*10)*fade;
                return c;
            }

            float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
                float s = StaticDrops(uv, t)*l0; 
                float2 m1 = DropLayer2(uv, t)*l1;
                float2 m2 = DropLayer2(uv*1.85, t)*l2;
    
                float c = s+m1.x+m2.x;
                c = S(0.3, 1, c);
    
                return float2(c, max(m1.y*l0, m2.y*l1));
            }

            float Mix(float x, float y, float a) {
                return x*(1 - a) + y*a;
            }

            float3 Mix3(float3 x, float3 y, float3 a) {
                return x*(1 - a) + y*a;
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
                // fragCoord.xy / iResolution.xy 会将坐标转换到 [0, 1] 之间。

      	        //float2 uv = (fragCoord.xy-0.5*iResolution.xy) / iResolution.y;
                //float2 UV = fragCoord.xy/iResolution.xy;
                float2 uv = IN.uv;//(IN.uv.xy-0.5*IN.uv.xy) / IN.uv.y; 
                float2 UV = IN.uv.xy/IN.uv.xy;
                //float3 M = iMouse.xyz/iResolution.xyz;
                float T = _Time.y * _RainAmount;//+M.x*2;
    
                #ifdef _HAS_HEART_ON
                    //T = fmord(_Time.y, 102);//mod(iTime, 102);
                    //T = Mix(T, M.x*102, M.z>0?1:0);
                #endif
                float t = T*0.2;
    
                float rainAmount = sin(T*0.05)*0.3+0.7;//iMouse.z>0 ? M.y : sin(T*0.05)*0.3+0.7;
    
                float maxBlur = Mix(3, 6, rainAmount);
                float minBlur = 2;
    
                float story = 0;
                float heart = 0;
    
                #ifdef _HAS_HEART_ON
                    story = S(0, 70, T);
    
                    t = min(1, T/70);						// remap drop time so it goes slower when it freezes
                    t = 1-t;
                    t = (1-t*t)*70;
    
                    float zoom= Mix(0.3, 1.2, story);		// slowly zoom out
                    uv *=zoom;
                    minBlur = 4+S(0.5, 1, story)*3;		// more opaque glass towards the end
                    maxBlur = 6+S(0.5, 1, story)*1.5;
    
                    float2 hv = uv-float2(0, -0.1);				// build heart
                    hv.x *= 0.5;
                    float s = S(110, 70, T);				// heart gets smaller and fades towards the end
                    hv.y-=sqrt(abs(hv.x))*0.5*s;
                    heart = length(hv);
                    heart = S(0.4*s, 0.2*s, heart)*s;
                    rainAmount = heart;						// the rain is where the heart is
    
                    maxBlur-=heart;							// inside the heart slighly less foggy
                    uv *= 1.5;								// zoom out a bit more
                    t *= 0.25;
                #else
                    float zoom = -cos(T*0.2);
                    uv *= 0.7+zoom*0.3;
                #endif

                UV = (UV-0.5)*(0.9+zoom*0.1)+0.5;
    
                float staticDrops = S(-0.5, 1, rainAmount)*2;
                float layer1 = S(0.25, 0.75, rainAmount);
                float layer2 = S(0, 0.5, rainAmount);
    
                float2 c = Drops(uv, t, staticDrops, layer1, layer2);

                #ifdef _CHEAP_NORMALS_ON
    	            float2 n = float2(dFdx(c.x), dFdy(c.x));// cheap normals (3x cheaper, but 2 times shittier ;))
                #else
    	            float2 e = float2(0.001, 0);
    	            float cx = Drops(uv+e, t, staticDrops, layer1, layer2).x;
    	            float cy = Drops(uv+e.yx, t, staticDrops, layer1, layer2).x;
    	            float2 n = float2(cx-c.x, cy-c.x);		// expensive normals
                #endif
    
    
                #ifdef _HAS_HEART_ON
                    n *= 1-S(60, 85, T);
                    c.y *= 1-S(80, 100, T)*0.8;
                #endif
    
                float focus = Mix(maxBlur-c.y, minBlur, S(0.1, 0.2, c.x));

                float3 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                //float3 col = textureLod(iChannel0, UV+n, focus).rgb;
    
                #ifdef _USE_POST_PROCESSING_ON
                    t = (T+3)*0.5;										// make time sync with first lightnoing
                    float colFade = sin(t*0.2)*0.5+0.5+story;
                    col *= Mix3(float3(1,1,1), float3(0.8, 0.9, 1.3), colFade);	// subtle color shift
                    float fade = S(0, 10, T);							// fade in at the start
                    float lightning = sin(t*sin(t*10));				// lighting flicker
                    lightning *= pow(max(0, sin(t+sin(t))), 10);		// lightning flash
                    col *= 1+lightning*fade*Mix(1, 0.1, story*story);	// composite lightning
                    col *= 1-dot(UV-=0.5, UV);							// vignette
    											
                    #ifdef _HAS_HEART_ON
    	                col = Mix3(pow(col, float3(1.2,1.2,1.2)), col, heart);
    	                fade *= S(102, 97, T);
                    #endif
    
                    col *= fade;										// composite start and end fade
                #endif
    
                //col = float3(heart);
                // fragColor = float4(col, 1);
                return float4(col, 1);
            }
            ENDHLSL
        }
    }        
}
