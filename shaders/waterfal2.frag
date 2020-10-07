// #version 330 core // Uncomment this if you're using glslViewer!
// gzcompat.frag is a "compatibility layer" that lets you write texture shaders
// for GZDoom using glslViewer.
// glslViewer: https://github.com/patriciogonzalezvivo/glslViewer
// gzcompat.frag: https://gist.github.com/Talon1024/f704e883851f447ca1985a1d8a45bf95
#ifdef GLSLVIEWER
#define USER_SHADER
#include "gzcompat.frag"
#endif

uniform float timer;

// From https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
// Unknown license

float zrand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noize(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);

	float res = mix(
		mix(zrand(ip),zrand(ip+vec2(1.0,0.0)),u.x),
		mix(zrand(ip+vec2(0.0,1.0)),zrand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

// 	<https://www.shadertoy.com/view/MdX3Rr>
//	by inigo quilez
const mat2 m2 = mat2(0.8,-0.6,0.6,0.8);
float fbm( in vec2 p ){
    float f = 0.0;
    f += 0.5000*noize( p ); p = m2*p*2.02;
    f += 0.2500*noize( p ); p = m2*p*2.03;
    f += 0.1250*noize( p ); p = m2*p*2.01;
    f += 0.0625*noize( p );

    return f/0.9375;
}

// By Talon1024
#define NOISE_SCALE 32.

vec4 Process(vec4 color) // color is white for some reason.. A GZDoom bug?
{
	vec4 finalColor = texture(tex, vTexCoord.xy);
	vec2 fbmUv = vTexCoord.xy; fbmUv.y -= timer;
	vec4 fbmColor = vec4(fbm(fbmUv * NOISE_SCALE));
	// return fbmColor;
	fbmColor *= texture(tex, vTexCoord.xy); // Colorize fbm
	finalColor = mix(finalColor, texture(tex, vec2(vTexCoord.x, vTexCoord.y - timer * .5)), .5);
	finalColor += fbmColor;
	return finalColor;
}
