extends "res://scripts/pantallas/pantalla.gd"
## Logros: los veinte en dos columnas, con los conseguidos en dorado y los
## ocultos como «???» hasta conseguirlos. Lee la lista del autoload Logros.
##
## Acciones: «cerrar» (ESC, B, clic fuera o cualquier tecla de volver).

const HOJA := Rect2(70, 46, 820, 548)
const ICONOS_DIR := "res://assets/visual/iconos/%s.png"
const COLUMNAS := 2
const ALTO_FILA := 46.0
const ARRIBA := 108.0

var _iconos: Dictionary = {}


static func rect_logro(i: int) -> Rect2:
    var filas: int = int(ceil(float(Logros.total()) / float(COLUMNAS)))
    return Rect2(96.0 + float(i / filas) * 392.0, ARRIBA + float(i % filas) * ALTO_FILA, 380.0, 40.0)


func _icono(nombre: String) -> Texture2D:
    if not _iconos.has(nombre):
        var ruta := ICONOS_DIR % nombre
        _iconos[nombre] = load(ruta) if ResourceLoader.exists(ruta) else null
    return _iconos[nombre]


func _draw() -> void:
    oscurecer(Color(0, 0, 0, 0.8))
    Estilo.panel(self, HOJA, Color(0.05, 0.05, 0.075, 0.97), Estilo.ORO)
    Estilo.panel(self, Rect2(380, 34, 200, 30), Color("#2a1d22"), Estilo.ORO)
    Estilo.titulo(self, "Logros", Vector2(380, 58), 24, Estilo.CREMA, 200.0)
    var hechos: int = Logros.cuantos()
    var total: int = Logros.total()
    Estilo.texto(self, "%d / %d CONSEGUIDOS" % [hechos, total], Vector2(96, 92), 13, Estilo.ORO)
    var barra := Rect2(300, 83, 560, 8)
    draw_rect(barra, Color("#141922"))
    draw_rect(Rect2(barra.position, Vector2(barra.size.x * float(hechos) / float(maxi(1, total)), barra.size.y)), Color("#e3bd7b"))
    var apagado := Color("#5d5a52")
    var lista: Array = Logros.todos()
    for i in range(lista.size()):
        var l: Dictionary = lista[i]
        var r: Rect2 = rect_logro(i)
        var tiene: bool = bool(l["tiene"])
        var secreto: bool = bool(l["oculto"]) and not tiene
        Estilo.panel(self, r, Color("#1d1710") if tiene else Color("#0e1015"), Color("#e3bd7b") if tiene else Color("#24262c"))
        var icono: Texture2D = _icono(str(l["icono"]))
        if icono != null and not secreto:
            draw_texture_rect(icono, Rect2(r.position + Vector2(6, 4), Vector2(32, 32)), false, Color.WHITE if tiene else Color(0.12, 0.12, 0.14, 0.9))
        Estilo.texto(self, "???" if secreto else str(l["nombre"]), Vector2(r.position.x + 46.0, r.position.y + 17.0), 13, Estilo.CREMA if tiene else apagado)
        Estilo.texto(self, "Logro oculto: sigue jugando." if secreto else str(l["descripcion"]), Vector2(r.position.x + 46.0, r.position.y + 33.0), 10, Color("#c9b98f") if tiene else Color("#6d6a62"))
    Estilo.texto(self, "ESC / B · volver", Vector2(96, 580), 12, Color("#8a8574"))


func _gui_input(event: InputEvent) -> void:
    if clic_de(event) != null:
        accept_event()
        elegir(&"cerrar")


func _unhandled_input(event: InputEvent) -> void:
    if not is_visible_in_tree():
        return
    var k := tecla_de(event)
    var b := boton_de(event)
    if k in [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E] or b in [JOY_BUTTON_B, JOY_BUTTON_A, JOY_BUTTON_START, JOY_BUTTON_BACK]:
        elegir(&"cerrar")
        get_viewport().set_input_as_handled()
