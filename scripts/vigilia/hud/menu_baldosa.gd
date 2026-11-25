extends "res://scripts/vigilia/hud/pieza_vigilia.gd"
## Menú de lo que se toca en la celda (baldosa libre, estructura, lecho o
## puerta): título y una opción por acción, con su icono, nombre y precio.
## Apunta con un pico a lo que se tocó.
##
## Datos: titulo, ancla (punto señalado), opciones ([{id, label, sub, icon,
## enabled}]), raton, seleccion, cursor (si se elige con teclado o mando).

const ANCHO_CELDA := 960.0


## Recuadro del menú con «n» opciones que señala «ancla»: encima si cabe; si
## no, debajo; siempre dentro de la pantalla.
static func caja(n: int, ancla: Vector2) -> Rect2:
    var tam := Vector2(float(n) * 96.0 + 12.0, 128.0)
    var pos := Vector2(ancla.x - tam.x * 0.5, ancla.y - tam.y - 34.0)
    if pos.y < 70.0:
        pos.y = ancla.y + 34.0
    pos.x = clampf(pos.x, 8.0, ANCHO_CELDA - tam.x - 8.0)
    return Rect2(pos, tam)


static func opcion(r: Rect2, i: int) -> Rect2:
    return Rect2(r.position.x + 6.0 + float(i) * 96.0, r.position.y + 28.0, 90.0, 94.0)


func _draw() -> void:
    var opciones: Array = datos.get("opciones", [])
    var a: Vector2 = datos.get("ancla", Vector2.ZERO)
    var r := caja(opciones.size(), a)
    var encima: bool = r.position.y < a.y
    var pico_y: float = r.end.y if encima else r.position.y
    draw_colored_polygon(PackedVector2Array([Vector2(a.x - 8, pico_y), Vector2(a.x + 8, pico_y), Vector2(a.x, a.y - 26.0 if encima else a.y + 26.0)]), EV.ORO)
    EV.caja(self, r, Color(0.04, 0.035, 0.05, 0.98), EV.ORO)
    EV.en_caja(self, str(datos.get("titulo", "")), Rect2(r.position.x, r.position.y + 6.0, r.size.x, 14), 12, EV.ORO_CLARO)
    var raton: Vector2 = datos.get("raton", Vector2(-100, -100))
    var sel: int = int(datos.get("seleccion", 0))
    var cursor: bool = bool(datos.get("cursor", false))
    for i in range(opciones.size()):
        var o: Dictionary = opciones[i]
        var orr := opcion(r, i)
        var activo: bool = orr.has_point(raton) or (cursor and sel == i)
        var ok: bool = bool(o["enabled"])
        EV.caja(self, orr, Color("#241c2c") if activo else Color("#141018"), EV.ORO_CLARO if activo else (EV.ALMA if ok else EV.BORDE))
        draw_texture_rect(EV.icono(o["icon"]), Rect2(orr.position + Vector2(orr.size.x * 0.5 - 20.0, 6), Vector2(40, 40)), false, Color.WHITE if ok else Color(0.45, 0.45, 0.5, 0.8))
        EV.en_caja(self, str(o["label"]), Rect2(orr.position.x, orr.position.y + 50.0, orr.size.x, 12), 11, EV.CREMA)
        EV.en_caja(self, str(o["sub"]), Rect2(orr.position.x, orr.position.y + 70.0, orr.size.x, 12), 11, EV.ALMA if ok else EV.CARMIN)
