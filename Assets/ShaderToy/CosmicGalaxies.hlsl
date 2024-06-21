float random(float2 par){
   return frac (sin(dot(par.xy,float2(12.9898,78.233))) * 43758.5453);
}

float2 random2(float2 par){
	float rand = random(par);
	return float2(rand, random(par+rand));
}

float time;
float iResolutionX;
float iResolutionY;
float4 main(in float2 fragColor:TEXCOORD0):SV_Target
//void mainImage( out float4 fragColor, in float2 fragCoord )
{   
    // 将fragCoord转换为0到1的范围，其中iResolution为渲染目标的分辨率
    //float2 uv = fragCoord / iResolution;
    float2 iResolution = float2(iResolutionX, iResolutionY);
    //float2 uv = fragCoord/iResolution.xy;
    float ratio = iResolution.x/iResolution.y;
      // uv居中!
    float2 uv = fragColor / iResolution;

    float t = time * 0.01;
    float an = time * -0.01;
    float3 col;
    float _Layers = 16.0;
    float _MaxScale = 32.0;

    
    float2x2 rotation = float2x2(cos(an), -sin(an), 
                         sin(an),  cos(an));
 	
    //float2 uv_1;
    for(float i = 0.0; i < _Layers; i++){
        float depth = frac (i/_Layers + t);
        
        float2 center = float2(0.5, 0.5);
        
        //center.x = 0.5 + 0.1 * cos(t) * depth;
        //center.y = 0.5 + 0.1 * sin(t) * depth;
        
    	uv = center-uv/iResolution.xy;;//fragCoord/iResolution.xy;
    	//uv.x *= ratio; hlsl用mul
        uv = mul(uv, ratio);

        //uv *= float2(rotation._11, rotation._11);//rotation;
    	uv *= lerp(_MaxScale, 0.0, depth);
        
        float2 id = floor(uv);
        
        float2 seed = 20.0 * i + id;
        
        float2 guv = frac (i + uv) - 0.5;
        
        float2 pos = 0.8 * (random2(seed) - 0.5);
        
        float phase = 128.0 * random(seed);

        float v = pow(abs(1.0-length(guv-pos)), 50.0) * min(1.0, depth*2.0);
    	col += float3(v,v,v);
        
    }
    //fragColor = float4(col,1.0);
    return float4(col,1.0);
}