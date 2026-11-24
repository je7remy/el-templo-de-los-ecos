extends SceneTree
## Arquitectura por escenas (fase 1): autoloads Eventos, Progreso y Escenas,
## máquina de estados, pantallas de inicio, menú y pausa como escenas con
## botones de verdad, y la capa de avisos encima de todo.

const MaquinaEstados := preload("res://scripts/comun/maquina_estados.gd")
const Botin := preload("res://scripts/botin.gd")

var _cambios: Array = []


func _initialize() -> void:
    Engine.set_meta("modo_prueba", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
    call_deferred("_run")


func _run() -> void:
    root.size = Vector2i(960, 640) # sin pantalla la ventana mide 64 × 64
    # --- Autoloads -----------------------------------------------------------
    for nombre in ["Eventos", "Progreso", "Escenas", "ConfirmarSalida"]:
        if root.get_node_or_null(nombre) == null:
            _fail("Falta el autoload %s." % nombre)
            return
    var progreso: Node = root.get_node("Progreso")
    var guardados := [0]
    root.get_node("Eventos").progreso_guardado.connect(func(): guardados[0] += 1)
    if not progreso.cargar().is_empty():
        _fail("Sin partida, Progreso debe cargar un diccionario vacío.")
        return
    progreso.guardar({"souls": 12, "bag": {"pan": 1}})
    if int(progreso.cargar().get("souls", 0)) != 12 or guardados[0] != 1:
        _fail("Progreso no guarda o no avisa al guardar.")
        return
    # El botín de la Vigilia escribe a través de Progreso y respeta lo demás.
    Botin.aplicar("pan")
    var tras_botin: Dictionary = progreso.cargar()
    if int((tras_botin.get("bag", {}) as Dictionary).get("pan", 0)) != 2 or int(tras_botin.get("souls", 0)) != 12:
        _fail("El botín de la Vigilia no pasa por Progreso o pisa el resto del progreso.")
        return
    progreso.borrar()
    if progreso.existe():
        _fail("Progreso no borra el archivo.")
        return
    var escenas: Node = root.get_node("Escenas")
    if escenas.call("ocupado") or escenas.get_node_or_null("PantallaCarga") == null:
        _fail("El gestor de escenas no tiene pantalla de carga o arranca ocupado.")
        return
    # --- Máquina de estados ---------------------------------------------------
    var m: Node = MaquinaEstados.new()
    for n in ["A", "B"]:
        var hijo := Control.new()
        hijo.name = n
        m.add_child(hijo)
    root.add_child(m)
    m.estado_cambiado.connect(func(a, b): _cambios.append([a, b]))
    m.cambiar_a(&"A")
    m.cambiar_a(&"B")
    if m.nombre_actual() != &"B" or (m.get_node("A") as Control).visible or not (m.get_node("B") as Control).visible or _cambios.size() != 2:
        _fail("La máquina de estados no deja un solo estado activo.")
        return
    m.queue_free()
    # --- La escena principal está hecha de escenas -----------------------------
    var game: Node = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    for ruta in ["Pantallas/Maquina/Splash", "Pantallas/Maquina/Titulo", "Pantallas/Maquina/Pausa", "CapaAvisos/Avisos"]:
        if game.get_node_or_null(ruta) == null:
            _fail("main.tscn no incluye %s." % ruta)
            return
    var pantallas: Node = game.get_node("Pantallas")
    if game.get("game_mode") != "splash" or pantallas.call("activa") != &"Splash":
        _fail("No arranca mostrando la escena de inicio.")
        return
    var Ajustes = load("res://scripts/ajustes.gd")
    # Primera vez: el acuerdo (escena) antes del menú; «LEER COMPLETO» abre
    # el texto en la configuración y al volver sigue el acuerdo.
    _tecla(KEY_SPACE)
    if game.get("game_mode") != "eula" or pantallas.call("activa") != &"Acuerdo":
        _fail("La primera vez no aparece la escena del acuerdo.")
        return
    var acuerdo: Node = pantallas.call("pantalla", &"Acuerdo")
    _clic((acuerdo.get_node("Leer") as Control).get_global_rect().get_center())
    var ajustes: Node = pantallas.call("pantalla", &"Ajustes")
    if game.get("game_mode") != "settings" or str(ajustes.get("legal")) != "acuerdo" or int(ajustes.get("pestana")) != 3:
        _fail("LEER COMPLETO no abre el acuerdo en la configuración.")
        return
    # Con un texto legal abierto, las pestañas no responden; ESC lo cierra.
    _clic(Vector2(118 + 87, 132)) # pestaña SONIDO
    if int(ajustes.get("pestana")) != 3 or str(ajustes.get("legal")) != "acuerdo":
        _fail("Las pestañas cambian mientras se leen los términos.")
        return
    _tecla(KEY_ESCAPE)
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "eula":
        _fail("Cerrar la configuración no vuelve al acuerdo.")
        return
    _clic((acuerdo.get_node("Aceptar") as Control).get_global_rect().get_center())
    if game.get("game_mode") != "title" or pantallas.call("activa") != &"Titulo" or not bool(Ajustes.obtener("acuerdo_aceptado")):
        _fail("ACEPTAR no guarda el acuerdo ni lleva al menú.")
        return
    # Engranaje → configuración (dibujada aún por main.gd) → vuelve al menú.
    var titulo: Node = pantallas.call("pantalla", &"Titulo")
    _clic((titulo.get_node("Engranaje") as Control).get_global_rect().get_center())
    if game.get("game_mode") != "settings" or pantallas.call("activa") != &"Ajustes" or (titulo as Control).visible:
        _fail("El engranaje del menú no abre la configuración (o el menú no se oculta).")
        return
    # Deslizador arrastrado con el ratón y un interruptor con un clic.
    var antes: float = float(Ajustes.obtener("volumen_musica"))
    _clic(Vector2(440 + 10, 168 + 58 + 25)) # al principio de la barra de Música
    if float(Ajustes.obtener("volumen_musica")) >= antes or float(Ajustes.obtener("volumen_musica")) > 0.1:
        _fail("El deslizador de la música no responde al clic.")
        return
    var silencio: bool = bool(Ajustes.obtener("silencio"))
    _clic(Vector2(480, 168 + 3 * 58 + 25))
    if bool(Ajustes.obtener("silencio")) == silencio:
        _fail("El interruptor de silencio no responde al clic.")
        return
    _clic(Vector2(480, 168 + 3 * 58 + 25))
    Ajustes.poner("volumen_musica", antes)
    # Teclado: ↓ recorre, TAB cambia de pestaña, una tecla se reasigna.
    _tecla(KEY_TAB)
    if int(ajustes.get("pestana")) != 1:
        _fail("TAB no cambia de pestaña en la configuración.")
        return
    _tecla(KEY_ENTER) # primera acción: reasignar
    _tecla(KEY_I)
    if int(Ajustes.tecla(str(Ajustes.ORDEN[0]))) != KEY_I:
        _fail("No se puede reasignar una tecla.")
        return
    Ajustes.restablecer_teclas()
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "title" or not (titulo as Control).visible:
        _fail("Cerrar la configuración no devuelve el menú.")
        return
    # JUGAR con un clic de verdad abre los pisos (escena con diez tarjetas).
    _clic((titulo.get_node("Jugar") as Control).get_global_rect().get_center())
    var pisos: Node = pantallas.call("pantalla", &"Pisos")
    if game.get("game_mode") != "floors" or (titulo as Control).visible or not (pisos as Control).visible:
        _fail("JUGAR no abre el menú de pisos.")
        return
    _tecla(KEY_RIGHT)
    if int(pisos.get("seleccion")) != 1:
        _fail("Las flechas no mueven la selección de pisos.")
        return
    _clic((pisos.call("tarjeta", 3) as Control).get_global_rect().get_center())
    if int(pisos.get("seleccion")) != 3 or game.get("game_mode") != "floors":
        _fail("Tocar una tarjeta debe elegirla sin descender.")
        return
    _clic((pisos.call("tarjeta", 3) as Control).get_global_rect().get_center()) # bloqueado: avisa y no entra
    if game.get("game_mode") != "floors":
        _fail("Se puede descender a un piso bloqueado.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "title":
        _fail("ESC en los pisos no vuelve al menú.")
        return
    _clic((titulo.get_node("Jugar") as Control).get_global_rect().get_center())
    print("OK: autoloads Eventos, Progreso y Escenas, máquina de estados, inicio y menú como escenas.")
    print("OK: acuerdo, configuración (deslizadores, interruptores, teclas, textos legales) y pisos como escenas.")

    # --- Pausa ----------------------------------------------------------------
    Ajustes.poner("intro_vista", true)
    Ajustes.poner("tutorial_hecho", true)
    game.set("game_mode", "title")
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    _tecla(KEY_ESCAPE)
    var pausa: Node = pantallas.call("pantalla", &"Pausa")
    if game.get("game_mode") != "pause" or not (pausa as Control).visible or int(pausa.call("seleccion")) != 0:
        _fail("ESC no abre la pausa con CONTINUAR seleccionado.")
        return
    _tecla(KEY_S)
    _tecla(KEY_DOWN)
    if int(pausa.call("seleccion")) != 2:
        _fail("Las teclas no mueven la selección de la pausa.")
        return
    _tecla(KEY_ENTER) # PERFIL
    if game.get("game_mode") != "inventory" or (pausa as Control).visible:
        _fail("ENTER no elige la opción de la pausa.")
        return
    game.call("_close_inventory")
    if game.get("game_mode") != "pause":
        _fail("Cerrar el perfil abierto desde la pausa no vuelve a ella.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "play" or (pausa as Control).visible:
        _fail("ESC en la pausa no vuelve al juego.")
        return
    # --- Avisos encima de todo ---------------------------------------------------
    var avisos: Node = game.get_node("CapaAvisos/Avisos")
    if int((avisos.get_parent() as CanvasLayer).layer) <= int((pantallas as CanvasLayer).layer):
        _fail("La capa de avisos debe quedar por encima de las pantallas.")
        return
    root.get_node("Eventos").aviso_pedido.emit("Hola", 2.0)
    if str(avisos.get("texto")) != "Hola" or float(avisos.get("texto_t")) <= 0.0:
        _fail("Eventos.aviso_pedido no llega a la capa de avisos.")
        return
    game.set("xp", 0)
    game.call("_level_up", 1)
    if float(avisos.get("nivel_t")) <= 0.0:
        _fail("Subir de nivel no muestra el rótulo.")
        return
    game.set("loot_banner", {"key": "pan", "t": 2.0})
    if (avisos.get("botin") as Dictionary).get("key", "") != "pan" or (game.get("loot_banner") as Dictionary).is_empty():
        _fail("El rótulo de botín no pasa a la capa de avisos.")
        return
    print("OK: pausa con teclado y avisos de nivel y botín encima de las pantallas.")
    game.queue_free()
    await process_frame
    call_deferred("quit", 0)


func _tecla(k: Key) -> void:
    var e := InputEventKey.new()
    e.keycode = k
    e.physical_keycode = k
    e.pressed = true
    root.push_input(e)
    var suelta := e.duplicate()
    suelta.pressed = false
    root.push_input(suelta)


func _clic(at: Vector2) -> void:
    for pressed in [true, false]:
        var m := InputEventMouseButton.new()
        m.button_index = MOUSE_BUTTON_LEFT
        m.position = at
        m.global_position = at
        m.pressed = pressed
        m.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
        root.push_input(m)


func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
