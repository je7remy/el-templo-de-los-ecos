extends "res://scripts/pantallas/pantalla.gd"
## Acuerdo de usuario (la primera vez que se abre el juego).
## Acciones: «aceptar», «leer» (abre el texto completo en Configuración),
## «salir». ENTER acepta.

const Textos := preload("res://scripts/datos/textos.gd")


func _ready() -> void:
    $Aceptar.pressed.connect(elegir.bind(&"aceptar"))
    $Leer.pressed.connect(elegir.bind(&"leer"))
    $Salir.pressed.connect(elegir.bind(&"salir"))


func _al_entrar() -> void:
    $Titulo.texto = Textos.t("acuerdo_titulo")
    $Texto.texto = Textos.t("acuerdo_texto")
    $Aceptar.texto = Textos.t("aceptar")
    $Leer.texto = Textos.t("leer")
    $Salir.texto = Textos.t("salir_juego")
    $Aceptar.grab_focus()


func _al_salir() -> void:
    var foco: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
    if foco != null and is_ancestor_of(foco):
        foco.release_focus()


func _draw() -> void:
    var margen: Vector2 = datos.get("margen", Vector2.ZERO)
    draw_rect(Rect2(-margen, size + margen * 2.0), Color(0.01, 0.012, 0.02, 0.88))


func _unhandled_input(event: InputEvent) -> void:
    if is_visible_in_tree() and event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode in [KEY_ENTER, KEY_KP_ENTER]:
        get_viewport().set_input_as_handled()
        elegir(&"aceptar")
