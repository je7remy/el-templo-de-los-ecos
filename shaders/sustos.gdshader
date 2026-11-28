shader_type canvas_item;
// Distorsión de los sustos: la imagen se rompe en franjas que se desplazan,
// los canales de color se separan y aparece ruido. «intensidad» 0 = nada.
// Compatible con el renderizador Compatibility (OpenGL 3 / WebGL 2).

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform float tiempo = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	if (intensidad <= 0.001) {
		COLOR = texture(screen_tex, uv);
	} else {
		float paso = floor(tiempo * 24.0);
		// Franjas horizontales de alto variable que saltan a los lados.
		float franja = floor(uv.y * mix(18.0, 60.0, hash(vec2(paso, 1.0))));
		float salta = step(1.0 - intensidad * 0.55, hash(vec2(franja, paso)));
		uv.x += (hash(vec2(franja, paso + 3.0)) - 0.5) * 0.12 * intensidad * salta;
		// Separación de canales.
		float sep = 0.012 * intensidad;
		float r = texture(screen_tex, uv + vec2(sep, 0.0)).r;
		float g = texture(screen_tex, uv).g;
		float b = texture(screen_tex, uv - vec2(sep, 0.0)).b;
		vec3 c = vec3(r, g, b);
		// Ruido y un velo rojo.
		float n = hash(uv * vec2(640.0, 360.0) + paso);
		c = mix(c, vec3(n), 0.18 * intensidad);
		c = mix(c, c * vec3(1.25, 0.55, 0.55), 0.5 * intensidad);
		COLOR = vec4(c, 1.0);
	}
}
