// Lambert bump mapping
// (c) oP group 2008  Version 2.1

float4x4 matWorld;
float4x4 matWorldViewProj;

float4 vecLightPos[8];
float4 vecTime;

texture entSkin1;
texture entSkin2;
sampler skin1Sampler = sampler_state { Texture = <entSkin1>; MipFilter = Linear; };
sampler skin2Sampler = sampler_state { Texture = <entSkin2>; MipFilter = Linear; };

struct VSIN
{
	float3 position : POSITION;
	float2 texcoord : TEXCOORD0;
	float3 normal : NORMAL;
};

struct VSOUT
{
	float4 projectedPosition : POSITION;
	float2 texcoord : TEXCOORD0;
	float3 worldPosition : TEXCOORD1;
	float3 worldNormal : NORMAL;
	float z : TEXCOORD2;
};

VSOUT baseVS(VSIN input)
{
	VSOUT output;
	output.z = 1.0-saturate((input.position.z+.8)*4);
	output.projectedPosition = mul(float4(input.position, 1.0f), matWorldViewProj);
	output.texcoord = input.texcoord;
	output.worldPosition = mul(float4(input.position, 1.0f), matWorld);
	output.worldNormal = mul(float4(input.normal, 0.0f), matWorld);
	return output;
}

float4 basePS(VSOUT input) : COLOR0
{
	float4 color = tex2D(skin1Sampler, input.texcoord.xy+float2(vecTime.a*.004, 0.0));
	float4 color2 = tex2D(skin1Sampler, -input.texcoord.xy+float2(0.0, vecTime.a*.004));
	float4 final = pow(max(color, color2), 2.0);
	float4 frame = tex2D(skin2Sampler, input.texcoord.xy);
	final.gb *= .5+frame.a*.5;
	final.r *= .8+frame.a*.2;
	//final.rgb = lerp(frame.rgb, final.rgb, 1.0-frame.a);
	final.rgb *= input.z;
	return final;
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
