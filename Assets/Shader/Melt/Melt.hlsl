// https://www.shadertoy.com/view/XsX3zl
// 70s Melt

//#ifdef GL_ES
//precision mediump float;
//#endif
//#define RADIANS 0.017453292519943295

//const int zoom = 40;
//const float brightness = 0.975;
//float fScale = 1.25;

float cosRange(float degrees, float range, float minimum) {
	return (((1.0 + cos(degrees * 0.017453292519943295)) * 0.5) * range) + minimum;
}

float time1;
float iResolutionX;
float iResolutionY;
float4 main(in float2 fragCoord :TEXCOORD0):SV_Target
//void mainImage( out float4 fragColor, in float2 fragCoord )
{
    float2 iResolution = float2(iResolutionX, iResolutionY);
    // 将fragCoord转换为0到1的范围，其中iResolution为渲染目标的分辨率
    float2 uv = fragCoord / iResolution;
	float time = time1 * 1.25;

	//float2 uv = fragCoord.xy / iResolution.xy;
    // uv居中!
    //uv = -1.0 +2.0 * uv;
	float2 p  = (2.0*uv.xy-iResolution.xy)/max(iResolution.x,iResolution.y);

    float ct = cosRange(time*5.0, 3.0, 1.1);
	float xBoost = cosRange(time*0.2, 5.0, 5.0);
	float yBoost = cosRange(time*0.1, 10.0, 5.0);
	
	float fScale = cosRange(time * 15.5, 1.25, 0.5);

	int zoom = 40;
    float brightness = 0.975;

	for(int i=1;i<zoom;i++) {
		float _i = float(i);
		float2 newp=p;
		newp.x+=0.25/_i*sin(_i*p.y+time*cos(ct)*0.5/20.0+0.005*_i)*fScale+xBoost;		
		newp.y+=0.25/_i*sin(_i*p.x+time*ct*0.3/40.0+0.03*float(i+15))*fScale+yBoost;
		p=newp;
	}
	
	float3 col=float3(0.5*sin(3.0*p.x)+0.5,0.5*sin(3.0*p.y)+0.5,sin(p.x+p.y));
	col *= brightness;
    
    // Add border
    float vigAmt = 5.0;
    float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
	float extrusion = (col.x + col.y + col.z) / 4.0;
    extrusion *= 1.5;
    extrusion *= vignette;
    
	//fragColor = float4(col, extrusion);
    return float4(col, extrusion);
}

/** SHADERDATA
{
	"title": "70s Melt",
	"description": "Variation of Sine Puke",
	"model": "car"
}
*/