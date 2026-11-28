extends Control
## Lo que va encima de todo en un susto: el apagón, la distorsión de la
## pantalla y la cara que salta. Los decide scripts/mundo/sustos.gd.

const SHADER := preload("res://shaders/sustos.gdshader")

var sustos: Node

var _apagon_t: float = -1.0
var _distorsion_t: float = 0.0
var _distorsion_dura: float = 0.0
var _distorsion_max: float = 0.0
var _salto_t: float = -1.0
var _salto_dura: float = 0.0
var _salto_tex: Texture2D
var _velo: ColorRect
var _mat: ShaderMaterial
## Encima del velo: el apagón y la cara (la distorsión no debe taparlos).
var _encima: Control


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_preset(Control.PRESET_FULL_RECT)
    _velo = ColorRect.new()
    _velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _velo.set_anchors_preset(Control.PRESET_FULL_RECT)
    _mat = ShaderMaterial.new()
    _mat.shader = SHADER
    _velo.material = _mat
    _velo.visible = false
    add_child(_velo)
    _encima = Control.new()
    _encima.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _encima.set_anchors_preset(Control.PRESET_FULL_RECT)
    _encima.draw.connect(_dibujar_encima)
    add_child(_encima)


## Dos cortes de luz seguidos (unos 0,6 s en total).
func apagon() -> void:
    _apagon_t = 0.0


func distorsion(fuerza: float, segundos: float) -> void:
    _distorsion_max = fuerza
    _distorsion_dura = segundos
    _distorsion_t = segundos


func salto(cara: Texture2D, segundos: float) -> void:
    _salto_tex = cara
    _salto_dura = segundos
    _salto_t = 0.0
    distorsion(1.0, segundos * 0.9)


func activo() -> bool:
    return _apagon_t >= 0.0 or _distorsion_t > 0.0 or _salto_t >= 0.0


func _process(delta: float) -> void:
    if _apagon_t >= 0.0:
        _apagon_t += delta
        if _apagon_t > 0.62:
            _apagon_t = -1.0
    if _salto_t >= 0.0:
        _salto_t += delta
        if _salto_t > _salto_dura + 0.3:
            _salto_t = -1.0
    var fuerza := 0.0
    if _distorsion_t > 0.0:
        _distorsion_t = maxf(0.0, _distorsion_t - delta)
        fuerza = _distorsion_max * (_distorsion_t / maxf(0.01, _distorsion_dura))
    _velo.visible = fuerza > 0.001
    _mat.set_shader_parameter("intensidad", fuerza)
    _mat.set_shader_parameter("tiempo", float(Time.get_ticks_msec()) / 1000.0)
    _encima.queue_redraw()


func _dibujar_encima() -> void:
    var c := _encima
    var r := Rect2(Vector2.ZERO, size)
    if _apagon_t >= 0.0:
        # Oscuro 0,00–0,10 s y 0,22–0,48 s.
        var t := _apagon_t
        if t < 0.10 or (t > 0.22 and t < 0.48):
            c.draw_rect(r, Color(0, 0, 0, 0.97))
    if _salto_t >= 0.0 and _salto_tex != null:
        var t2: float = _salto_t
        var a: float = 1.0 if t2 < _salto_dura else clampf(1.0 - (t2 - _salto_dura) / 0.3, 0.0, 1.0)
        c.draw_rect(r, Color(0.0, 0.0, 0.0, 0.85 * a))
        # La cara se abalanza: crece deprisa y tiembla.
        var k: float = clampf(t2 / 0.18, 0.0, 1.0)
        var alto: float = size.y * lerpf(0.75, 1.35, k)
        var ancho: float = alto * 64.0 / 96.0
        var tiembla := Vector2(randf_range(-6, 6), randf_range(-6, 6)) * (1.0 - k * 0.5)
        var dest := Rect2(size * 0.5 - Vector2(ancho * 0.5, alto * 0.36) + tiembla, Vector2(ancho, alto))
        c.draw_texture_rect_region(_salto_tex, dest, Rect2(128, 0, 64, 96), Color(1.0, 0.82, 0.82, a))
        c.draw_rect(r, Color(0.7, 0.0, 0.05, 0.28 * a * (1.0 - k * 0.6)))
