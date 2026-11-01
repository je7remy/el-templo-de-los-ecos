extends SceneTree
## Comprobacion de grafica original de marca cargable por Godot.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var texture: Texture2D = load("res://assets/branding/icon.svg")
    if texture == null or texture.get_width() < 192 or texture.get_height() < 192:
        push_error("El icono grafico no se importa en Godot.")
        quit(1)
        return
    var logo: Texture2D = load("res://assets/branding/logo.svg")
    if logo == null or logo.get_width() < 700 or logo.get_height() < 300:
        push_error("El logotipo grafico no se importa en Godot.")
        quit(1)
        return
    print("OK: icono y logotipo originales disponibles como texturas.")
    texture = null
    logo = null
    call_deferred("quit", 0)
