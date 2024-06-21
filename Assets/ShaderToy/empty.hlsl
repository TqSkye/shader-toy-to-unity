// HLSL 片段着色器
float2 iResolution = float2(1280.0, 720.0); // 设置渲染目标的分辨率
 // 顶点着色器
//cbuffer ConstantBuffer : register(b0) {
//    float2 iResolution;
//};

float4 main(float2 fragCoord : SV_POSITION) : SV_Target
{
    // 将fragCoord转换为0到1的范围，其中iResolution为渲染目标的分辨率
    float2 uv = fragCoord / iResolution;
    
    // 简单的基于UV坐标的颜色混合
    float2 invResolution = 1.0 / iResolution;
    
    return float4(fragCoord * invResolution, 0.0, 1.0); // 返回渲染的颜色
}