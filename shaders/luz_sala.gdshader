shader_type canvas_item;
// Luz y tinte de cada sala sobre la arquitectura (TileMapLayer).
// Las cinco salas comparten tiles; cada una tiene su color:
//   color = tile * ganancia + desplazamiento   (por canal)
// Valores ajustados por herramientas/construir_salas.py contra assets/visual/rooms.
uniform vec3 ganancia = vec3(1.0);
uniform vec3 desplazamiento = vec3(0.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(c.rgb * ganancia + desplazamiento, c.a) * COLOR.a;
}
