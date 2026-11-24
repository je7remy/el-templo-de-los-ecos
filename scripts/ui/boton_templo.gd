@tool
extends TextureButton
## Botón de la interfaz con el estilo del templo.
##
## Es un botón de verdad (TextureButton, sin texturas): Godot le da el ratón, el toque, el foco del
## teclado y del mando (ui_up/ui_down/ui_accept) y la señal «pressed». Solo
## el dibujo es propio (scripts/ui/estilo.gd), para que encaje con el pixel art.
##
## Variantes:
##   menu    botón de lista (pausa, ajustes): «principal» lo pinta verde azulado
##   grande  botón grueso con icono (menú principal)
##   chico   botón pequeño de texto (SALIR, CAMBIAR)
##   icono   solo icono (engranaje); «girar» lo hace rotar

const Estilo := preload("res://scripts/ui/estilo.gd")

@export_enum("menu", "grande", "chico", "icono") var variante: String = "menu":
    set(v):
        variante = v
        queue_redraw()
@export var texto: String = "":
    set(v):
        texto = v
        queue_redraw()
@export var icono: Texture2D:
    set(v):
        icono = v
        queue_redraw()
@export var principal: bool = false
@export var relleno: Color = Color("#3b2550")
@export var borde: Color = Color("#a988d0")
## Borde al pasar el cursor en la variante «chico» (dorado o carmesí).
@export var borde_activo: Color = Color("#b8955a")
## Relleno al pasar el cursor en la variante «chico» (transparente = el de
## reposo un poco más claro).
@export var relleno_activo: Color = Color(0, 0, 0, 0)
@export var girar: bool = false
@export var tam_texto: int = 12

var _k: float = 0.0 # 0 reposo → 1 activo (anima el crecimiento)
var _t: float = 0.0


func _ready() -> void:
    Estilo.preparar_fuentes()
    focus_mode = Control.FOCUS_ALL
    ignore_texture_size = true
    mouse_entered.connect(queue_redraw)
    mouse_exited.connect(queue_redraw)
    focus_entered.connect(queue_redraw)
    focus_exited.connect(queue_redraw)


## Activo: con el cursor encima o con el foco (teclado o mando).
func activo() -> bool:
    return is_hovered() or has_focus() or button_pressed


func _process(delta: float) -> void:
    _t += delta
    var meta: float = 1.0 if activo() else 0.0
    if not is_equal_approx(_k, meta) or variante in ["grande", "icono"]:
        _k = move_toward(_k, meta, delta * 7.0)
        queue_redraw()


func _draw() -> void:
    var r := Rect2(Vector2.ZERO, size)
    var hot := activo()
    match variante:
        "menu":
            Estilo.boton(self, r, texto, principal, hot)
        "grande":
            Estilo.boton_grande(self, r, texto, icono, relleno, borde, _k, 0.5 + 0.5 * sin(_t * 3.0))
        "chico":
            var fondo: Color = (relleno_activo if relleno_activo.a > 0.0 else relleno.lightened(0.12)) if hot else relleno
            Estilo.panel(self, r, fondo, borde_activo if hot else borde)
            Estilo.texto(self, texto, Vector2(0, r.size.y * 0.5 + 6.0), tam_texto, Estilo.CREMA if hot else Estilo.GRIS, r.size.x)
        "icono":
            Estilo.panel(self, r, Color("#222c39") if hot else Color("#141922"), Estilo.ORO if hot else Estilo.CLARO)
            if icono != null:
                var giro: float = _t * (1.5 if hot else 0.3) if girar else 0.0
                draw_set_transform(r.get_center(), giro, Vector2.ONE)
                draw_texture_rect(icono, Rect2(Vector2(-16, -16), Vector2(32, 32)), false)
                draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
