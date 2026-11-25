extends RefCounted
## Piezas de interfaz propias de la Vigilia del Claustro: cajas con sombra y
## filete, ventanas modales, fichas, botones redondos, pastillas y textos sin
## borde. Usa las tipografías y los colores comunes de estilo.gd; así la
## Vigilia (scripts/defense.gd) y sus pantallas (scripts/vigilia/) se ven
## igual dibujen donde dibujen.
##
## Uso:  const EstiloVigilia := preload("res://scripts/ui/estilo_vigilia.gd")
##       EstiloVigilia.modal(self, rect)      # desde el _draw() de un CanvasItem

const Estilo := preload("res://scripts/ui/estilo.gd")

const CREMA := Estilo.CREMA
const ALMA := Estilo.ALMA
const ORO := Estilo.ORO
const ORO_CLARO := Color("#e3bd7b")
const CARMIN := Color("#d1474f")
const VIOLETA := Estilo.VIOLETA
const BORDE := Estilo.BORDE
const APAGADO := Color("#9a957f")
## Colores del botín por nivel (común, poco común, raro, épico).
const COLOR_NIVEL := [Color("#9a957f"), Estilo.ALMA, Color("#a988d0"), Color("#e3bd7b")]
const NOMBRE_NIVEL := ["COMÚN", "POCO COMÚN", "RARO", "ÉPICO"]

static var _iconos: Dictionary = {}


## Icono de assets/visual/iconos/ (se carga una vez).
static func icono(nombre: String) -> Texture2D:
    if not _iconos.has(nombre):
        _iconos[nombre] = load("res://assets/visual/iconos/%s.png" % nombre)
    return _iconos[nombre]


## Caja: sombra, relleno, brillo arriba y filete.
static func caja(ci: CanvasItem, r: Rect2, relleno: Color, borde: Color) -> void:
    ci.draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0, 0, 0, 0.4))
    ci.draw_rect(r, relleno)
    ci.draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color(1, 1, 1, 0.05))
    ci.draw_rect(r, borde, false, 2.0)


## Ventana modal: caja casi opaca con doble filete.
static func modal(ci: CanvasItem, r: Rect2) -> void:
    caja(ci, r, Color(0.04, 0.035, 0.05, 0.97), ORO)
    ci.draw_rect(r.grow(-6.0), Color("#3a3440"), false, 1.0)


## Ficha de la barra de arriba: icono, valor y una línea pequeña.
static func ficha(ci: CanvasItem, r: Rect2, icono_t: Texture2D, valor: String, sub: String, color: Color) -> void:
    caja(ci, r, Color("#141018"), BORDE)
    ci.draw_texture_rect(icono_t, Rect2(r.position + Vector2(6, 6), Vector2(28, 28)), false)
    ci.draw_string(Estilo.fuente(), r.position + Vector2(40, 22), valor, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color)
    ci.draw_string(Estilo.fuente(), r.position + Vector2(40, 35), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, APAGADO)


static func boton_redondo(ci: CanvasItem, r: Rect2, icono_t: Texture2D, activo: bool) -> void:
    caja(ci, r, Color("#241c2c") if activo else Color("#141018"), ORO_CLARO if activo else ORO)
    ci.draw_texture_rect(icono_t, Rect2(r.get_center() - Vector2(16, 16), Vector2(32, 32)), false)


## Pastilla de aviso centrada en «centro» (la línea base va 2 px más abajo).
static func pastilla(ci: CanvasItem, msg: String, centro: Vector2, tam: int, color: Color) -> void:
    var ancho: float = Estilo.fuente().get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
    var r := Rect2(centro.x - ancho * 0.5 - 8, centro.y - tam + 1, ancho + 16, tam + 7)
    ci.draw_rect(r, Color(0.03, 0.025, 0.04, 0.85))
    ci.draw_rect(r, Color(color.r, color.g, color.b, 0.4), false, 1.0)
    ci.draw_string(Estilo.fuente(), Vector2(centro.x - ancho * 0.5, centro.y + 2), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)


## Rótulo gótico sin borde (centrado en «ancho» si es > 0).
static func rotulo(ci: CanvasItem, msg: String, en: Vector2, tam: int, color: Color, ancho: float) -> void:
    ci.draw_string(Estilo.fuente_titulo(), en, msg, HORIZONTAL_ALIGNMENT_CENTER if ancho > 0.0 else HORIZONTAL_ALIGNMENT_LEFT, ancho, tam, color)


static func etiqueta(ci: CanvasItem, msg: String, en: Vector2, tam: int = 16, color: Color = CREMA) -> void:
    ci.draw_string(Estilo.fuente(), en, msg, HORIZONTAL_ALIGNMENT_LEFT, -1.0, tam, color)


## Línea centrada en la celda (x de 40 a 920).
static func centrado(ci: CanvasItem, msg: String, y: float, tam: int = 16, color: Color = CREMA) -> void:
    ci.draw_string(Estilo.fuente(), Vector2(40, y), msg, HORIZONTAL_ALIGNMENT_CENTER, 880.0, tam, color)


## Texto centrado en un rectángulo (la línea base, a «tam» del borde de arriba).
static func en_caja(ci: CanvasItem, msg: String, r: Rect2, tam: int, color: Color) -> void:
    ci.draw_string(Estilo.fuente(), Vector2(r.position.x, r.position.y + tam), msg, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, tam, color)
