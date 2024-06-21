float pi = 3.1415926;

float2x2 rotateZ(float angle)
{
    return float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

// 创建棋盘格(下列参数均以像素为单位)
// pos:当前坐标,size:棋盘格大小,threshold:aa大小
// return:0为奇行奇列或偶行偶列,1为奇行偶列或偶行奇列,0~1为aa值
float checkerboard(float2 pos, float2 size, float threshold)
{
    float2 gc = floor(pos/size);// 网格坐标
    float flag = abs(fmod(gc.x,2.0) - fmod(gc.y,2.0));// abs=1表示奇行偶列或者偶行奇列
    
    // aa
    float2 t1 = smoothstep(size,size-threshold,pos - floor(pos/size)*size);// 当前坐标在右、上 t像素的时候得到0~1的值,其余地方是1
    float2 t2 = smoothstep(0.0,threshold,pos - floor(pos/size)*size);// 左、下得到0~1的值，其余是1,乘积得到四边的渐变值
    float aa = t1.x*t1.y*t2.x*t2.y;
    
    return flag*aa;
}

float time;
float4 main(in float2 uv:TEXCOORD0):SV_Target
//void mainImage( out float2 fragColor, in float2 fragCoord )
{
   // uv居中!
    uv = -1.0 +2.0 * uv;

    float2 size = float2(30.0,30.0);// 棋盘格的大小(单位:像素)
    float2 col1 = float2(0.15,0.15);// 两个格子的颜色
    float2 col2 = float2(0.85,0.85);
    float threshold = 2.0;// aa(单位:像素)
    
    float2 coord = uv;
    //coord -= iResolution.xy / 2.0;
    float p = fmod(time, 10.0) / 10.0;// 20s周期,得到0~1的值
    float v = abs(sin(p * pi)) * 45.0;// 每个周期内得到0->45度->0变化的角度
    //coord *= rotateZ(radians(v));
    coord = mul(coord, rotateZ(radians(v)));
    //coord += iResolution.xy / 2.0;
    
    float flag = checkerboard(coord, size, threshold);
    float2 col = lerp(col1, col2, flag);
    //fragColor = float2(col, 1.0);
    return (col, 1.0, 0.0);
}