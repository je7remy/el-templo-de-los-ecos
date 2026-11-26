@tool
extends RefCounted
## Estilo visual común de la interfaz: colores, tipografías y las piezas que
## se dibujan igual en todas partes (paneles, textos con borde, rótulos góticos,
## botones). Lo usan la campaña (main.gd) y las escenas de pantalla, así un
## botón se ve idéntico esté donde esté.
##
## Uso:  const Estilo := preload("res://scripts/ui/estilo.gd")
##       Estilo.panel(self, rect)            # desde el _draw() de un CanvasItem
##       Estilo.texto(self, "Hola", pos, 14, Estilo.CREMA)

## Las tipografías se cargan al primer uso, no con preload: la pantalla de
## carga (un autoload) usa este script y los autoloads se analizan al importar
## el proyecto, antes de que las fuentes estén importadas en una copia nueva.
const RUTA_FUENTE := "res://assets/fonts/Jersey15-Templo.ttf"
const RUTA_FUENTE_TITULO := "res://assets/fonts/Jacquard24-Regular.ttf"

const PANEL := Color(0.035, 0.03, 0.045, 0.84)
const BORDE := Color("#2f2a35")
const CLARO := Color("#5b5262")
const ORO := Color("#b8955a")
const VIOLETA := Color("#3b2550")
const CARMESI := Color("#8e1f2c")
const CREMA := Color("#d9d2ba")
const ALMA := Color("#8fc7d7")
const ROJO := Color("#d06470")
const GRIS := Color("#b9b29b")

## Tamaño base de la pantalla (las pantallas ocupan esto; lo que sobra en
## pantallas anchas lo rellena el fondo).
const ANCHO := 960.0
const ALTO := 640.0

static var _fuente: Font
static var _fuente_titulo: Font


## Letra pixel (Jersey 15).
const Idioma := preload("res://scripts/comun/idioma.gd")


## El texto en el idioma elegido (scripts/comun/idioma.gd). Las piezas de
## dibujo de aquí ya lo usan; úsalo antes de medir un texto propio.
static func t(msg: String) -> String:
    return Idioma.t(msg)


static func fuente() -> Font:
    if _fuente == null:
        preparar_fuentes()
    return _fuente


## Rótulos góticos (Jacquard 24).
static func fuente_titulo() -> Font:
    if _fuente_titulo == null:
        preparar_fuentes()
    return _fuente_titulo


## Pixel art: sin suavizado ni posiciones a medio píxel.
static func preparar_fuentes() -> void:
    if _fuente != null:
        return
    _fuente = load(RUTA_FUENTE)
    _fuente_titulo = load(RUTA_FUENTE_TITULO)
    for f in [_fuente, _fuente_titulo]:
        if f is FontFile:
            (f as FontFile).antialiasing = TextServer.FONT_ANTIALIASING_NONE
            (f as FontFile).hinting = TextServer.HINTING_NONE
            (f as FontFile).subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED


static func degradado_v(ci: CanvasItem, r: Rect2, arriba: Color, abajo: Color) -> void:
    ci.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
        PackedColorArray([arriba, arriba, abajo, abajo]))


static func degradado_h(ci: CanvasItem, r: Rect2, izq: Color, der: Color) -> void:
    ci.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
        PackedColorArray([izq, der, der, izq]))


## Panel: fondo oscuro translúcido, filete del color del borde y esquinas
## ornamentadas en los paneles grandes.
static func panel(ci: CanvasItem, r: Rect2, relleno: Color = PANEL, borde: Color = BORDE) -> void:
    ci.draw_rect(Rect2(r.position + Vector2(0, 3), r.size), Color(0, 0, 0, 0.35 * relleno.a)) # sombra
    ci.draw_rect(r, relleno)
    degradado_v(ci, Rect2(r.position, Vector2(r.size.x, minf(r.size.y * 0.5, 22.0))), Color(1, 1, 1, 0.035 * relleno.a), Color(1, 1, 1, 0.0))
    ci.draw_rect(r, Color(0, 0, 0, 0.7 * relleno.a), false, 1.0)
    var dentro := r.grow(-2.0)
    ci.draw_rect(dentro, Color(borde.r, borde.g, borde.b, borde.a * 0.9), false, 1.0)
    if r.size.x >= 70.0 and r.size.y >= 40.0:
        var orn: Color = borde.lightened(0.25)
        orn.a = borde.a
        for esquina in [dentro.position, Vector2(dentro.end.x, dentro.position.y), dentro.end, Vector2(dentro.position.x, dentro.end.y)]:
            var sx: float = 1.0 if esquina.x < r.get_center().x else -1.0
            var sy: float = 1.0 if esquina.y < r.get_center().y else -1.0
            ci.draw_rect(Rect2(esquina + Vector2(minf(0.0, sx * 7.0), minf(0.0, sy * 1.0)), Vector2(7, 1)), orn)
            ci.draw_rect(Rect2(esquina + Vector2(minf(0.0, sx * 1.0), minf(0.0, sy * 7.0)), Vector2(1, 7)), orn)
            var d: Vector2 = esquina + Vector2(sx * 4.0, sy * 4.0)
            ci.draw_colored_polygon(PackedVector2Array([d + Vector2(0, -2), d + Vector2(2, 0), d + Vector2(0, 2), d + Vector2(-2, 0)]), orn)


## Texto pixel con borde oscuro. Con ancho > 0 se centra en ese ancho.
static func texto(ci: CanvasItem, msg: String, en: Vector2, tam: int, color: Color, ancho: float = -1.0) -> void:
    msg = Idioma.t(msg)
    var alin: int = HORIZONTAL_ALIGNMENT_CENTER if ancho > 0.0 else HORIZONTAL_ALIGNMENT_LEFT
    var oscuro := Color(0, 0, 0, color.a * 0.9)
    for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 1)]:
        ci.draw_string(fuente(), en + o, msg, alin, ancho, tam, oscuro)
    ci.draw_string(fuente(), en, msg, alin, ancho, tam, color)


## Rótulo gótico (Jacquard 24) con sombra rojiza.
static func titulo(ci: CanvasItem, msg: String, en: Vector2, tam: int, color: Color, ancho: float = -1.0) -> void:
    msg = Idioma.t(msg)
    var alin: int = HORIZONTAL_ALIGNMENT_CENTER if ancho > 0.0 else HORIZONTAL_ALIGNMENT_LEFT
    var sombra := Color(0.0, 0.0, 0.0, color.a * 0.85)
    ci.draw_string(fuente_titulo(), en + Vector2(0, maxf(2.0, float(tam) / 16.0)), msg, alin, ancho, tam, Color(0.12, 0.02, 0.05, color.a * 0.8))
    for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
        ci.draw_string(fuente_titulo(), en + o, msg, alin, ancho, tam, sombra)
    ci.draw_string(fuente_titulo(), en, msg, alin, ancho, tam, color)


## Filete ornamental dorado con rombo central.
static func adorno(ci: CanvasItem, centro: Vector2, mitad: float) -> void:
    var oro := Color(ORO.r, ORO.g, ORO.b, 0.8)
    degradado_h(ci, Rect2(centro.x - mitad, centro.y, mitad - 8.0, 1), Color(oro.r, oro.g, oro.b, 0.0), oro)
    degradado_h(ci, Rect2(centro.x + 8.0, centro.y, mitad - 8.0, 1), oro, Color(oro.r, oro.g, oro.b, 0.0))
    ci.draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -4), centro + Vector2(4, 0), centro + Vector2(0, 4), centro + Vector2(-4, 0)]), oro)
    ci.draw_circle(centro, 1.5, Color("#2a1d22"))


## Botón de menú (pausa, ajustes…).
static func boton(ci: CanvasItem, r: Rect2, etiqueta: String, principal: bool, activo: bool) -> void:
    var relleno: Color = Color("#1d4a4f") if principal else Color("#1a1f2a")
    if activo:
        relleno = relleno.lightened(0.15)
    panel(ci, r, relleno, ORO if activo else (ALMA if principal else CLARO))
    texto(ci, etiqueta, Vector2(r.position.x, r.position.y + r.size.y * 0.5 + 6.0), 16, CREMA, r.size.x)


## Botón grande con icono: crece y brilla según k (0 = reposo, 1 = activo).
static func boton_grande(ci: CanvasItem, r0: Rect2, etiqueta: String, icono: Texture2D, relleno: Color, borde: Color, k: float, pulso: float) -> void:
    var r := r0.grow(roundf(3.0 * k))
    ci.draw_rect(r.grow(4.0), Color(borde.r, borde.g, borde.b, 0.05 + 0.12 * k + 0.04 * pulso), false, 3.0)
    panel(ci, r, Color(relleno.r, relleno.g, relleno.b, 0.55 + 0.35 * k), borde)
    degradado_v(ci, Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6.0, r.size.y * 0.45)), Color(1, 1, 1, 0.05 + 0.06 * k), Color(1, 1, 1, 0.0))
    if icono != null:
        ci.draw_texture_rect(icono, Rect2(r.position + Vector2(14, roundf(r.size.y * 0.5) - 16.0), Vector2(32, 32)), false)
    texto(ci, etiqueta, Vector2(r.position.x + 30.0, r.position.y + r.size.y * 0.5 + 8.0), 22, CREMA.lerp(Color.WHITE, k * 0.5), r.size.x - 30.0)


## Barra estilizada: canal hundido, relleno en degradado con brillo superior,
## un destello en el extremo y marcas cada 25 %.
static func barra(ci: CanvasItem, r: Rect2, fraccion: float, color: Color, etiqueta: String = "") -> void:
    ci.draw_rect(r, Color(0.015, 0.012, 0.02, 0.9))
    var dentro := r.grow(-2.0)
    ci.draw_rect(dentro, color.darkened(0.82))
    var w: float = roundf(dentro.size.x * clampf(fraccion, 0.0, 1.0))
    if w > 0.0:
        degradado_v(ci, Rect2(dentro.position, Vector2(w, dentro.size.y)), color.lightened(0.22), color.darkened(0.4))
        ci.draw_rect(Rect2(dentro.position, Vector2(w, 1.0)), Color(1, 1, 1, 0.35))
        ci.draw_rect(Rect2(dentro.position.x + w - 2.0, dentro.position.y, 2.0, dentro.size.y), color.lightened(0.55))
    for k in range(1, 4):
        var x: float = roundf(dentro.position.x + dentro.size.x * float(k) / 4.0)
        ci.draw_rect(Rect2(x, dentro.position.y, 1.0, dentro.size.y), Color(0, 0, 0, 0.35))
    ci.draw_rect(r, Color(ORO.r, ORO.g, ORO.b, 0.35), false, 1.0)
    if etiqueta != "":
        texto(ci, etiqueta, Vector2(r.position.x, r.position.y + r.size.y * 0.5 + 5.0), 13, Color.WHITE, r.size.x)


## Párrafo con saltos de línea automáticos dentro de «caja». Devuelve la
## línea base de la última línea escrita.
static func parrafo(ci: CanvasItem, msg: String, caja: Rect2, tam: int, color: Color) -> float:
    msg = Idioma.t(msg)
    var palabras: PackedStringArray = msg.split(" ")
    var linea: String = ""
    var y: float = caja.position.y + float(tam)
    for p in palabras:
        var prueba: String = p if linea == "" else linea + " " + p
        if fuente().get_string_size(prueba, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > caja.size.x and linea != "":
            ci.draw_string(fuente(), Vector2(caja.position.x, y), linea, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)
            y += float(tam) + 7.0
            linea = p
        else:
            linea = prueba
    if linea != "":
        ci.draw_string(fuente(), Vector2(caja.position.x, y), linea, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, color)
    return y


## Texto sin borde (como _text de la campaña).
static func plano(ci: CanvasItem, msg: String, en: Vector2, tam: int = 16, color: Color = CREMA) -> void:
    ci.draw_string(fuente(), en, Idioma.t(msg), HORIZONTAL_ALIGNMENT_LEFT, -1.0, tam, color)


## Texto sin borde centrado en la pantalla base (x 40 → 920).
static func centrado(ci: CanvasItem, msg: String, y: float, tam: int = 16, color: Color = CREMA) -> void:
    ci.draw_string(fuente(), Vector2(40, y), Idioma.t(msg), HORIZONTAL_ALIGNMENT_CENTER, 880.0, tam, color)


## Corta un texto en líneas que caben en «ancho».
static func lineas(msg: String, ancho: float, tam: int) -> PackedStringArray:
    msg = Idioma.t(msg)
    var out := PackedStringArray()
    var linea: String = ""
    for p in msg.split(" ", false):
        var prueba: String = p if linea == "" else linea + " " + p
        if fuente().get_string_size(prueba, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x > ancho and linea != "":
            out.append(linea)
            linea = p
        else:
            linea = prueba
    if linea != "":
        out.append(linea)
    return out
