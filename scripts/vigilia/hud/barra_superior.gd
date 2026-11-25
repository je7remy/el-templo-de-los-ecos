extends "res://scripts/vigilia/hud/pieza_vigilia.gd"
## Barra de arriba: fase y nivel de botín, tiempo de la fase, ecos, energía y
## los botones de pausa y salir.
##
## Datos: margen, fase, jefe, nivel_botin, segundos, duracion, ecos, ritmo,
## durmiendo, energia, en_partida, pausada, raton.

const PAUSA := Rect2(826, 8, 56, 48)
const SALIR := Rect2(888, 8, 56, 48)
## Ficha de los ecos (el tutorial la señala).
const FICHA_ECOS := Rect2(506, 12, 150, 40)


func _draw() -> void:
    var m := margen()
    draw_rect(Rect2(-m.x, -m.y, Estilo.ANCHO + m.x * 2.0, 64 + m.y), Color(0.02, 0.018, 0.03, 0.95))
    draw_rect(Rect2(-m.x, 62, Estilo.ANCHO + m.x * 2.0, 2), EV.ORO)
    EV.rotulo(self, "Vigilia", Vector2(16, 44), 36, EV.CREMA, -1.0)
    var jefe: bool = bool(datos.get("jefe", false))
    var insignia := Rect2(150, 12, 110, 40)
    EV.caja(self, insignia, Color("#4a1a24") if jefe else EV.VIOLETA, EV.ORO_CLARO)
    EV.en_caja(self, "FASE %d" % int(datos.get("fase", 1)), Rect2(insignia.position.x, insignia.position.y + 4.0, insignia.size.x, 20), 18, EV.CREMA)
    EV.en_caja(self, "JEFE" if jefe else "BOTÍN NIVEL %d" % int(datos.get("nivel_botin", 1)), Rect2(insignia.position.x, insignia.position.y + 23.0, insignia.size.x, 12), 9, EV.ORO_CLARO)
    var segundos: float = float(datos.get("segundos", 0.0))
    var duracion: float = float(datos.get("duracion", 90.0))
    var barra := Rect2(272, 32, 220, 10)
    draw_rect(barra.grow(2.0), Color(0, 0, 0, 0.8))
    draw_rect(Rect2(barra.position, Vector2(barra.size.x * clampf(segundos / duracion, 0.0, 1.0), barra.size.y)), EV.ALMA)
    EV.etiqueta(self, "%d / %d s" % [int(segundos), int(duracion)], Vector2(272, 24), 12, EV.CREMA)
    EV.ficha(self, FICHA_ECOS, EV.icono("alma"), "%d" % int(datos.get("ecos", 0)), "+%d/s" % int(datos.get("ritmo", 0)) if bool(datos.get("durmiendo", false)) else "¡duerme!", EV.ALMA)
    EV.ficha(self, Rect2(664, 12, 150, 40), EV.icono("generador"), "%d" % int(datos.get("energia", 0)), "energía", EV.ORO_CLARO)
    var raton: Vector2 = datos.get("raton", Vector2(-100, -100))
    if bool(datos.get("en_partida", false)):
        EV.boton_redondo(self, PAUSA, EV.icono("reanudar" if bool(datos.get("pausada", false)) else "pausa"), PAUSA.has_point(raton))
    EV.boton_redondo(self, SALIR, EV.icono("salir"), SALIR.has_point(raton))
