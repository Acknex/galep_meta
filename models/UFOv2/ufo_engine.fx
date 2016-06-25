// Lambert bump mapping
// (c) oP group 2008  Version 2.1

float4x4 matWorld;
float4x4 matWorldViewProj;
float4 vecTime;

texture entSkin1;
texture entSkin2;
sampler texColor = sampler_state { Texture = <entSkin1>; MipFilter = Linear; };
sampler texNoise = sampler_state { Texture = <entSkin2>; MipFilter = Linear; };

struct VSIN
{
	float3 position : POSITION;
	float2 texcoord : TEXCOORD0;
};

struct VSOUT
{
	float4 projectedPosition : POSITION;
	float2 texcoord : TEXCOORD0;
};

VSOUT baseVS(VSIN input)
{
	VSOUT output;
	output.projectedPosition = mul(float4(input.position, 1.0f), matWorldViewProj);
	output.texcoord = input.texcoord;
	return output;
}

float4 basePS(VSOUT input) : COLOR0
{
	float4 color = tex2D(texColor, input.texcoord.xy);
	float alpha = tex2D(texNoise, (input.texcoord.xy-float2(0.0, vecTime.a*.08))*float2(4,0.2)).r;
	alpha *= tex2D(texNoise, input.texcoord.xy-float2(vecTime.a*.001, 0)*float2(4,1)).g;
	alpha *= tex2D(texNoise, input.texcoord.xy+float2(vecTime.a*.001, 0)*float2(4,1)).b;
	color.a *= saturate(alpha*(color.a+0.8));
	return color;
}

technique base
{
	pass one
	{
		ZEnable = true;
		ZWriteEnable = true;
		VertexShader = compile vs_3_0 baseVS();
		PixelShader = compile ps_3_0 basePS();
	}
}
