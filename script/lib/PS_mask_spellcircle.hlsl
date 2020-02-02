
//Simple masking shader:
//Takes pixels from the destination layer and uses the red and alpha channels to determine to show the shader's source image


sampler sampler0_ : register(s0);

const float SCREEN_WIDTH = 1024;
const float SCREEN_HEIGHT = 512;

float red = 1;
float blue = 1;
float green = 1;
float alpha = 1;

float amount = 10;
float speed = 5;
float distance = 50;
float time = 0;

float frame_ = 0;
float2 weight_ = float2(3, 3);
float frec_ = 2;
float weightX = 1;
float weightY = 1;



struct PS_INPUT{
	float4 diffuse : COLOR0;
	float2 texCoord : TEXCOORD0;
	float2 vPos : VPOS;
};


struct PS_OUTPUT{
	float4 color : COLOR0;
};

PS_OUTPUT PsSpellCircle( PS_INPUT In ) : COLOR0{
	PS_OUTPUT Out;
	
	float orgY = In.vPos.y;
	float orgX = In.vPos.x;
	float displacementX = (cos( time * speed + orgY * amount ) * distance) / 1024;
	float displacementY = (sin( time * speed + orgX * amount ) * distance) / 1024;
	float2 texUV = In.texCoord;
    texUV.x += displacementX;
    texUV.y += displacementY;
    Out.color = tex2D(sampler0_, texUV) * In.diffuse;
	
	return Out;
}

PS_OUTPUT PsWave (PS_INPUT In) : COLOR0 {
    PS_OUTPUT Out;

	//Thanks Naudiz
    float2 rad = float2(weightX, weightY) / 256;
    float2 texUV = In.texCoord;
    texUV.x += sin(In.vPos.y / pow(2, frec_) + time) * rad.x;
    texUV.y += cos(In.vPos.x / pow(2, frec_) - time) * rad.y;
    Out.color = tex2D(sampler0_, texUV) * In.diffuse;
    return Out;
}


PS_OUTPUT PsPassthrough( PS_INPUT In ) : COLOR0{
	PS_OUTPUT Out;
	
	float2 texUV = In.texCoord;
	Out.color = tex2D(sampler0_, texUV) * In.diffuse;
	
	return Out;
}


technique TecSpell{
	pass P0{
		PixelShader = compile ps_3_0 PsWave();
	}
}

technique TecPass{
	pass P0{
		PixelShader = compile ps_3_0 PsPassthrough();
	}
}