shader_type canvas_item;
// Postproceso cinematográfico de la sala (etapa 2 de arte):
//  - bloom moderado: solo lo muy brillante (almas, fuego, velas) se expande;
//  - gradación: sombras hacia violeta oscuro, luces hacia dorado envejecido;
//  - viñeta suave centrada en la sala;
//  - grano de película muy leve.
// Solo se aplica dentro de la sala (uniform «arena»): el HUD queda nítido.
// Compatible con el renderizador Compatibility (OpenGL 3 / WebGL 2).

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform vec4 arena = vec4(40.0, 122.0, 920.0, 580.0); // x0, y0, x1, y1 en píxeles del lienzo
uniform vec2 canvas_size = vec2(960.0, 640.0);
uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform float bloom : hint_range(0.0, 2.0) = 0.6;
uniform float vignette : hint_range(0.0, 1.0) = 0.55;
uniform float grain : hint_range(0.0, 0.2) = 0.035;
uniform float time = 0.0;
uniform vec3 shadow_tint = vec3(0.07, 0.03, 0.10);
uniform vec3 light_tint = vec3(1.05, 0.98, 0.88);
// Color vivo y legible (inspirado en Soul Knight): más saturación, algo de
// contraste y una exposición un poco más alta.
uniform float saturation : hint_range(0.0, 2.0) = 1.22;
uniform float contrast : hint_range(0.5, 1.5) = 1.07;
uniform float exposure : hint_range(0.5, 2.0) = 1.10;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 base = texture(screen_tex, uv).rgb;
	vec2 px = uv * canvas_size;
	float inside = step(arena.x, px.x) * step(px.x, arena.z) * step(arena.y, px.y) * step(px.y, arena.w);
	vec3 c = base;
	if (inside > 0.5 && strength > 0.0) {
		// Bloom: dos anillos de 8 muestras; solo cuenta lo que supera el umbral.
		if (bloom > 0.0) {
			vec3 glow = vec3(0.0);
			vec2 texel = 1.0 / canvas_size;
			for (int i = 0; i < 8; i++) {
				float a = float(i) * 0.785398 + 0.39;
				vec2 dir = vec2(cos(a), sin(a));
				vec3 s1 = texture(screen_tex, uv + dir * texel * 4.0).rgb;
				vec3 s2 = texture(screen_tex, uv + dir * texel * 10.0).rgb;
				glow += max(s1 - vec3(0.55), vec3(0.0)) * 0.6 + max(s2 - vec3(0.55), vec3(0.0)) * 0.4;
			}
			c += glow / 8.0 * bloom * 1.6;
		}
		// Gradación de color.
		float l = dot(c, vec3(0.299, 0.587, 0.114));
		c = mix(c + shadow_tint * (1.0 - l) * 0.45, c * light_tint, smoothstep(0.15, 0.8, l));
		// Color vivo: exposición, saturación y contraste.
		c *= exposure;
		float g = dot(c, vec3(0.299, 0.587, 0.114));
		c = mix(vec3(g), c, saturation);
		c = (c - 0.5) * contrast + 0.5;
		// Viñeta centrada en la sala.
		vec2 center = (arena.xy + arena.zw) * 0.5;
		vec2 half_size = (arena.zw - arena.xy) * 0.5;
		vec2 q = (px - center) / half_size;
		float v = smoothstep(0.45, 1.35, length(q * vec2(0.92, 1.05)));
		c *= 1.0 - v * vignette;
		// Grano.
		c += (hash(px + vec2(time * 37.0, time * 11.0)) - 0.5) * grain;
		c = mix(base, c, strength);
	}
	COLOR = vec4(c, 1.0);
}
