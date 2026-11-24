extends "res://scripts/ui/hud/pieza_hud.gd"
## Arma en la mano (o la antorcha) con su «munición», el combustible de la
## antorcha y las habilidades con su recarga.
##
## Datos: «encendida», «icono», «tiene», «nombre», «municion»,
## «color_municion», «icono_municion», «combustible» (0..1, o -1 si no
## cuenta), «habilidades» ([icono, lista, espera 0..1, tecla]), «t».

const BORDE_HAB := Color("#2f2a35")


func _draw() -> void:
    Estilo.panel(self, Rect2(586, 578, 366, 58))
    var hueco := Rect2(594, 583, 48, 48)
    Estilo.panel(self, hueco, Color("#1a1f2a"), Estilo.ORO if bool(d.get("encendida", false)) else Estilo.CLARO)
    var tiene: bool = bool(d.get("tiene", false))
    if d.get("icono") != null:
        draw_texture_rect(d["icono"], Rect2(hueco.position + Vector2(8, 8), Vector2(32, 32)), false, Color.WHITE if tiene else Color(0.3, 0.3, 0.3, 0.5))
    Estilo.texto(self, str(d.get("nombre", "")), Vector2(650, 600), 14, Estilo.CREMA if tiene else Color("#6d6a60"))
    if d.get("icono_municion") != null:
        draw_texture_rect(d["icono_municion"], Rect2(648, 608, 20, 20), false)
    Estilo.texto(self, str(d.get("municion", "")), Vector2(672, 624), 12, d.get("color_municion", Estilo.CREMA))
    var combustible: float = float(d.get("combustible", -1.0))
    if combustible >= 0.0:
        var barra := Rect2(596, 628, 44, 4)
        draw_rect(barra, Color(0, 0, 0, 0.7))
        draw_rect(Rect2(barra.position, Vector2(barra.size.x * combustible, barra.size.y)), Color("#ff9a3c") if combustible > 0.25 else Color("#d1474f"))
    var habs: Array = d.get("habilidades", [])
    for i in range(habs.size()):
        var h: Array = habs[i]
        _habilidad(Rect2(780.0 + float(i) * 58.0, 583, 48, 48), h[0], bool(h[1]), float(h[2]), str(h[3]))


## Botón de habilidad redondo; la recuperación se ve como un reloj que se vacía.
func _habilidad(caja: Rect2, icono: Texture2D, lista: bool, espera: float, tecla: String) -> void:
    var c: Vector2 = caja.get_center()
    var r: float = caja.size.x * 0.5
    draw_circle(c + Vector2(1, 2), r, Color(0, 0, 0, 0.45))
    draw_circle(c, r, BORDE_HAB)
    draw_circle(c, r - 2.0, Color("#1a1f2a"))
    if icono != null:
        draw_texture_rect(icono, Rect2(c - Vector2(16, 16), Vector2(32, 32)), false, Color.WHITE if lista else Color(0.3, 0.3, 0.3, 0.55))
    if lista and espera > 0.0:
        var k: float = clampf(espera, 0.0, 1.0)
        var pts := PackedVector2Array([c])
        for i in range(25):
            pts.append(c + Vector2.from_angle(-PI * 0.5 + TAU * k * float(i) / 24.0) * (r - 2.0))
        draw_colored_polygon(pts, Color(0.02, 0.03, 0.05, 0.72))
    var ya: bool = lista and espera <= 0.0
    draw_arc(c, r - 1.0, 0.0, TAU, 32, Estilo.ORO if ya else Estilo.CLARO, 2.0)
    if ya:
        draw_arc(c, r + 1.5, 0.0, TAU, 32, Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, 0.25 + 0.2 * sin(tiempo() * 5.0)), 2.0)
    var placa := Rect2(caja.end.x - 15.0, caja.end.y - 15.0, 16, 16)
    Estilo.panel(self, placa, Color("#2a1d22"), Estilo.ORO)
    Estilo.texto(self, tecla, Vector2(placa.position.x, placa.end.y - 4.0), 11, Estilo.CREMA, placa.size.x)
