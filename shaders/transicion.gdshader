shader_type canvas_item;
// Transición con máscara (idea del primer juego del autor, máscaras propias).
// «cover» va de 1 (todo tapado) a 0 (todo visible): se destapan primero los
// píxeles más claros de la máscara. En el borde que avanza brilla un filo
// del color de las almas.

uniform sampler2D mask : filter_linear;
uniform float cover : hint_range(-0.2, 1.2) = 0.0;
uniform float edge = 0.07;
uniform bool invert = false;
uniform vec4 tint : source_color = vec4(0.012, 0.008, 0.02, 1.0);
uniform vec4 rim : source_color = vec4(0.56, 0.86, 0.95, 1.0);

void fragment() {
	float m = texture(mask, UV).r;
	if (invert) {
		m = 1.0 - m;
	}
	float c = cover * (1.0 + 2.0 * edge) - edge;
	float a = 1.0 - smoothstep(c - edge, c + edge, m);
	float glow = (1.0 - clamp(abs(m - c) / edge, 0.0, 1.0)) * step(0.001, cover) * step(cover, 0.999);
	COLOR = vec4(mix(tint.rgb, rim.rgb, glow * 0.8), max(a, glow * 0.6) * tint.a);
}
