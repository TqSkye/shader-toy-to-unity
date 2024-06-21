Shader "ShaderToy/001(MarbleColourTest2)"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Ro("Ro", Vector) = (10,10,10,0)
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
        float3 _Ro;
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

            float2 csqr( float2 a )  { return float2( a.x*a.x - a.y*a.y, 2.*a.x*a.y  ); }

            float2 iSphere( in float3 ro, in float3 rd, in float4 sph )//from iq
            {
	            float3 oc = ro;// - sph.xyz;
	            float b = dot( oc, rd );
	            float c = dot( oc, oc ) - sph.w*sph.w;
	            float h = 1.0; //b*b - c;
	            return float2(-b-h, -b+h );
            }

            float map(in float3 p, float2 sctime) {
	
	            float res = 0.;
	
                float3 c = p;
                c.xy = c.xy * sctime.x + (c.y, c.x) * sctime.y;
	            for (int i = 0; i < 10; ++i) 
                {
                    p =.7*abs(p)/dot(p,p) -.7;
                    p.yz= csqr(p.yz);
                    p=p.zxy;
                    res += exp(-19. * abs(dot(p,c)));        
	            }
	            return res/2.;
            }

            float3 raymarch( in float3 ro, float3 rd, float2 tminmax , float2 sctime)
            {
                //tminmax += float2(1.,1.) * sin( iTime * 1.3)*3.0;
   	            float3 one3 = float3(1.0,1.0,1.0);
                float3 t = one3 * tminmax.x;
    
                float3 dt = float3(0.07, 0.02, 0.05);
                float3 col= float3(0.0, 0.0, 0.0);
                float3 c = one3 * 0.0;
                for( int i=0; i<64; i++ )
	            {
     	            float3 s = float3(2.0, 3.0, 4.0);   
                    t+=dt*exp(-s*c);
                    float3 a = step(t,one3*tminmax.y);
                    float3 pos = ro+t*rd;
        
                    c.x = map(ro+t.x*rd, sctime);
                    c.y = map(ro+t.y*rd, sctime);
                    c.z = map(ro+t.z*rd, sctime);               
        
                    col = lerp(col, 0.99*col+ 0.08*c*c*c, a);
                }
    
                float3 c0 = float3(0.4,0.3,0.99);
                float3 c1 = float3(0.9,0.7,0.0);
                float3 c2 = float3(0.9,0.1,0.2);
                return c0 * col.x + c1 * col.y + c2 * col.z;
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
                
                // return texDiff;

                 // float time = iTime;
                // float2 q = fragCoord.xy / iResolution.xy;
                float2 p = IN.uv + _Center;
                // p.x *= iResolution.x/iResolution.y;
                float m = float2(0.0, 0.0);

                // float3 ro = float3(6.);
                float3 ta = float3(0.0 , 0.0, 0.0);
                float3 ww = normalize(ta - _Ro);
                float3 uu = normalize(cross(ww,float3(0.0,1.0,0.0)));
                float3 vv = normalize(cross(uu,ww));
                float3 rd = normalize((p.x*uu + p.y*vv + 4.0*ww));

                float2 tmm = iSphere( _Ro, rd, float4(0.0,0.0,0.0,2.0) );
	            // raymarch
                float3 col = raymarch(_Ro,rd,tmm, float2(sin(_Time.y), cos(_Time.y)));

	            // shade    
                col =  0.5 *(log(1.0+col));
                col = clamp(col,0.0,1.0);
                // fragColor = float4( col, 1.0 );
                return float4(col, 1.0);

            }
            
            ENDHLSL
        }
    }        
}
