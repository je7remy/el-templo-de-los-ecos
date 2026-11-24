extends "res://scripts/pantallas/pantalla.gd"
## Pantalla de inicio: el templo a oscuras detrás, niebla, el logo y
## «Haz clic para continuar». Cualquier tecla, botón del mando, clic o toque
## sigue adelante; el engranaje abre la configuración.
##
## Acciones: «continuar», «ajustes».

const ICONO_MARCA: Texture2D = preload("res://assets/branding/icon.svg")

@onready var _engranaje: Control = $Engranaje
@onready var _ayuda_engranaje: Control = $AyudaEngranaje

var _t: float = 0.0
## Polvo suspendido: {p, s, f, ph}.
var _motas: Array = []


func _ready() -> void:
    Estilo.preparar_fuentes()
    var rng := RandomNumberGenerator.new()
    rng.seed = 7
    for i in range(46):
        _motas.append({"p": Vector2(rng.randf_range(0, Estilo.ANCHO), rng.randf_range(0, Estilo.ALTO)),
            "s": float(rng.randi_range(1, 2)), "f": rng.randf_range(0.6, 2.2), "ph": rng.randf_range(0.0, TAU),
            "v": Vector2(rng.randf_range(-4, 4), rng.randf_range(-7, -2))})
    _engranaje.pressed.connect(elegir.bind(&"ajustes"))
    _engranaje.mouse_entered.connect(func(): _ayuda_engranaje.visible = true)
    _engranaje.mouse_exited.connect(func(): _ayuda_engranaje.visible = false)
    _ayuda_engranaje.visible = false


func _al_entrar() -> void:
    $Subtitulo.texto = str(datos.get("subtitulo", ""))
    $Continuar.texto = str(datos.get("continuar", ""))
    _ayuda_engranaje.texto = str(datos.get("ajustes", ""))
    $Version.texto = "v" + str(datos.get("version", ""))


func actualizar(delta: float) -> void:
    _t += delta
    for m in _motas:
        var p: Vector2 = m["p"] + Vector2(m["v"]) * delta
        if p.y < -4.0:
            p.y = Estilo.ALTO + 4.0
        p.x = fposmod(p.x, Estilo.ANCHO)
        m["p"] = p
    var pulso: float = 0.35 + 0.65 * (0.5 + 0.5 * sin(_t * 3.2))
    $Continuar.color = Color(Estilo.ORO.r, Estilo.ORO.g, Estilo.ORO.b, pulso)
    queue_redraw()


func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0.01, 0.012, 0.02, 0.82))
    # Niebla que respira: discos concéntricos muy tenues.
    for i in range(9):
        var x: float = fmod(float(i) * 137.0 + _t * (6.0 + float(i % 3) * 3.0), Estilo.ANCHO + 300.0) - 150.0
        var y: float = 470.0 + float(i % 4) * 34.0 + sin(_t * 0.5 + float(i)) * 10.0
        var rad: float = 90.0 + float(i % 3) * 30.0
        for k in range(4):
            draw_circle(Vector2(x, y), rad * (1.0 - float(k) * 0.22), Color(0.55, 0.65, 0.68, 0.007))
    var brillo: float = 0.5 + 0.5 * sin(_t * 1.4)
    for k in range(10):
        draw_circle(Vector2(480, 175), (40.0 + float(k) * 14.0) * (1.0 + brillo * 0.05), Color(0.45, 0.75, 0.85, 0.012))
    for m in _motas:
        var tw: float = 0.5 + 0.5 * sin(_t * float(m["f"]) + float(m["ph"]))
        draw_rect(Rect2(Vector2(m["p"]).round(), Vector2(float(m["s"]), float(m["s"]))), Color(0.86, 0.8, 0.66, 0.06 + 0.12 * tw))
    draw_texture_rect(ICONO_MARCA, Rect2(424, 118, 112, 112), false)
    Estilo.adorno(self, Vector2(480, 384), 200.0)


## Clic o toque en cualquier sitio (menos el engranaje): seguir.
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        accept_event()
        elegir(&"continuar")


## Cualquier tecla o botón del mando: seguir.
func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    if (event is InputEventKey and event.pressed and not event.echo) or (event is InputEventJoypadButton and event.pressed):
        get_viewport().set_input_as_handled()
        elegir(&"continuar")
