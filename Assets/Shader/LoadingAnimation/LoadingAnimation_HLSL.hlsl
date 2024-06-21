// https://www.shadertoy.com/view/3dtyz4
// loading animation 2 

float f(float t) {
    float f = frac(t/8.)*4.-2.;
    return abs(smoothstep(0.,.5,frac(f)-.25)+floor(f))-1.;
}
float time;
float dist(float2 p) {
    float d = 0.;
    float t = -time;
    for (float i=0.;i<7.;i+=1.) {
        float a = 3.1415926535/20.*i*2.+t*2.;
        d += 1./length(p+float2(f(a),0.));
    }
    return d;
}

float4 main(in float2 uv:TEXCOORD0):SV_Target
//void mainImage( out float4 fragColor, in float2 fragCoord )
{
    //float2 uv = (fragCoord-iResolution.xy/2.0)/iResolution.y*2.;
    // uv居中!
    uv = -1.0 +2.0 * uv;
    float d = dist(uv)/3.-10.;

    // free antialiasing by FabriceNeyret2
    //fragColor = float4(d/min(1.,fwidth(d)));
    float c = d/min(1.0,fwidth(d));
    return float4(c,c,c,c);
}