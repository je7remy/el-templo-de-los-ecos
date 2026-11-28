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
    _clic(Vector2(440 + 10, 164 + 44 + 20)) # al principio de la barra de Música
    if float(Ajustes.obtener("volumen_musica")) >= antes or float(Ajustes.obtener("volumen_musica")) > 0.1:
        _fail("El deslizador de la música no responde al clic.")
        return
    var silencio: bool = bool(Ajustes.obtener("silencio"))
    _clic(Vector2(480, 164 + 3 * 44 + 20))
    if bool(Ajustes.obtener("silencio")) == silencio:
        _fail("El interruptor de silencio no responde al clic.")
        return
    # Cámara en el móvil: tres opciones (CERCA, MEDIA, SALA) a la derecha de la fila.
    _clic(Vector2(820 - 360 + 2 * 120 + 56, 164 + 7 * 44 + 5 + 15))
    if str(Ajustes.obtener("zoom_movil")) != "lejos":
        _fail("La opción SALA de «Cámara en el móvil» no responde al clic.")
        return
    _clic(Vector2(820 - 360 + 56, 164 + 7 * 44 + 5 + 15))
    if str(Ajustes.obtener("zoom_movil")) != "cerca":
        _fail("La opción CERCA de «Cámara en el móvil» no responde al clic.")
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

    # --- Pantallas de la partida (fase 2b) ---------------------------------------
    var maquina: Node = game.get_node("Pantallas/Maquina")
    # Diálogo: el primer clic completa la frase, el segundo pasa; SALTAR corta.
    game.set("game_mode", "play")
    game.call("_dialog", [["PEREGRINO", "Una frase."], ["PEREGRINO", "Otra."], ["PEREGRINO", "La última."]])
    if game.get("game_mode") != "dialog" or not (maquina.get_node("Dialogo") as Control).visible:
        _fail("El diálogo no se muestra como escena.")
        return
    _clic(Vector2(480, 500))
    _clic(Vector2(480, 500))
    if (game.get("dialog_queue") as Array).size() != 2:
        _fail("Un clic no completa la frase y el siguiente no pasa a la otra.")
        return
    _clic((maquina.get_node("Dialogo/Saltar") as Control).get_global_rect().get_center())
    if game.get("game_mode") != "play" or not (game.get("dialog_queue") as Array).is_empty():
        _fail("SALTAR no corta la conversación.")
        return
    # Elección: ESC la deja para luego.
    game.call("_open_choice", "GRUPO", "¿Nos guías?", [["guiar", "GUIARLOS", "a"], ["rechazar", "NEGARTE", "b"]])
    if not (maquina.get_node("Eleccion") as Control).visible:
        _fail("La elección no se muestra como escena.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "play" or not (game.get("choice") as Dictionary).is_empty():
        _fail("ESC no cierra la elección.")
        return
    # Muerte: los primeros segundos no se cierra; luego ENTER sigue.
    game.set("soul_fate", "persistencia")
    game.set("game_mode", "dead")
    game.set("end_t", 0.0)
    _tecla(KEY_ENTER)
    if game.get("game_mode") != "dead" or not (maquina.get_node("Final") as Control).visible:
        _fail("La pantalla de muerte se cierra antes de leerla.")
        return
    game.set("end_t", 5.0)
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "title":
        _fail("ESC en la pantalla de muerte no vuelve al menú.")
        return
    # Altar: la tecla 2 compra Llama Interior.
    game.set("game_mode", "title")
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("souls", 50)
    game.set("has_inner_flame", false)
    game.set("game_mode", "altar")
    _tecla(KEY_2)
    if not bool(game.get("has_inner_flame")) or int(game.get("souls")) >= 50:
        _fail("La tecla 2 del altar no compra la Llama Interior.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "play":
        _fail("ESC no cierra el altar.")
        return
    # Tienda: la llave de la Vigilia explica antes de cobrar; AHORA NO no paga.
    game.set("souls", 900)
    game.set("vigil_unlocked", false)
    game.call("_open_shop")
    var tienda: Node = maquina.get_node("Tienda")
    var llave: int = (game.get("SHOP") as Array).size() - 1
    _clic((tienda.call("rect_fila", llave) as Rect2).get_center())
    if not bool(game.get("shop_info")) or bool(game.get("vigil_unlocked")):
        _fail("La llave de la Vigilia se cobra sin explicar antes el modo.")
        return
    _clic((tienda.call("rect_boton_ficha", 1) as Rect2).get_center())
    if bool(game.get("shop_info")) or bool(game.get("vigil_unlocked")) or int(game.get("souls")) != 900:
        _fail("AHORA NO cobra la llave o no cierra la ficha.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "play":
        _fail("ESC no cierra la tienda.")
        return
    print("OK: diálogo, elección, muerte, altar y tienda como escenas.")

    # --- Fase 2c: intro, creación, habilidades y mapa ------------------------------
    # Intro: el texto se escribe solo; un clic lo completa y el siguiente pasa.
    game.call("_start_intro", "title")
    if not (maquina.get_node("Intro") as Control).visible:
        _fail("La intro no se muestra como escena.")
        return
    for i in range(30):
        await process_frame
    if int(game.get("intro_slide")) != 0 or float(game.get("intro_t")) <= 0.0:
        _fail("El texto de la intro no se escribe solo.")
        return
    _clic(Vector2(480, 300))
    _clic(Vector2(480, 300))
    if int(game.get("intro_slide")) != 1:
        _fail("Dos clics no pasan a la siguiente diapositiva de la intro.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "title":
        _fail("ESC no salta la intro.")
        return
    # Creación con el teclado físico: letras, borrar, ENTER, flechas y ENTER.
    game.call("_start_creation", "title")
    game.set("create_buf", "")
    for k in [KEY_L, KEY_U, KEY_Z, KEY_X]:
        var e := InputEventKey.new()
        e.keycode = k
        e.unicode = k
        e.pressed = true
        root.push_input(e)
    _tecla(KEY_BACKSPACE)
    if str(game.get("create_buf")) != "LUZ":
        _fail("El teclado físico no escribe el nombre (%s)." % game.get("create_buf"))
        return
    _tecla(KEY_ENTER)
    var genero: int = int(game.get("create_gender"))
    _tecla(KEY_RIGHT)
    if int(game.get("create_step")) != 1 or int(game.get("create_gender")) == genero:
        _fail("ENTER no pasa al género o las flechas no lo cambian.")
        return
    _tecla(KEY_ENTER)
    if str(game.get("player_name")) != "LUZ" or game.get("game_mode") != "title":
        _fail("ENTER no guarda el personaje.")
        return
    # Habilidades: las flechas pasan de página; ESC cierra.
    game.call("_new_run")
    game.call("_dialog_skip")
    game.set("game_mode", "play")
    game.set("ecos", (game.get("ECOS") as Dictionary).keys())
    game.call("_open_abilities")
    _tecla(KEY_RIGHT)
    if int(game.get("abil_page")) != 1 or not (maquina.get_node("Habilidades") as Control).visible:
        _fail("Las flechas no pasan de página en Habilidades.")
        return
    _tecla(KEY_ESCAPE)
    if game.get("game_mode") != "play":
        _fail("ESC no cierra Habilidades.")
        return
    game.set("ecos", [])
    # Mapa: un clic en la pestaña DESCENSO y fuera lo cierra.
    game.call("_open_map")
    _clic(Vector2(560, 109))
    if int(game.get("map_tab")) != 1:
        _fail("La pestaña DESCENSO del mapa no responde al clic.")
        return
    _clic(Vector2(20, 20))
    if game.get("game_mode") != "play":
        _fail("Tocar fuera no cierra el mapa.")
        return
    print("OK: intro, creación del personaje, habilidades y mapa como escenas.")

    # --- Fase 2d: perfil ------------------------------------------------------------
    # Se abre con su tecla desde el juego; las flechas mueven la selección.
    var perfil: Control = maquina.get_node("Perfil")
    game.set("game_mode", "play")
    game.set("has_wood", true)
    game.set("matches", 3)
    _tecla(int(game.call("_key", "perfil")))
    if game.get("game_mode") != "inventory" or not perfil.visible:
        _fail("La tecla del perfil no abre el perfil como escena.")
        return
    var sel_antes: int = int(game.get("inventory_sel"))
    _tecla(KEY_RIGHT)
    if int(game.get("inventory_sel")) != sel_antes + 1 or int(perfil.call("seleccion")) != sel_antes + 1:
        _fail("Las flechas no mueven la selección del perfil.")
        return
    # OBJETOS con un clic en su pestaña; tocar el pan ya señalado lo usa.
    game.set("bag", {"pan": 2})
    _clic(perfil.call("rect_pestana", 1).get_center())
    if int(game.get("profile_tab")) != 1 or int(game.get("inventory_sel")) != 0:
        _fail("La pestaña OBJETOS no responde al clic.")
        return
    _clic(perfil.call("rect_objeto", 0).get_center())
    if int((game.get("bag") as Dictionary).get("pan", 0)) != 1:
        _fail("Tocar el pan señalado no lo usa.")
        return
    # EQUIPO con la O; tocar el peto puesto lo quita.
    game.call("_equip_gear", "peto")
    _tecla(KEY_O)
    if int(game.get("profile_tab")) != 2:
        _fail("La O no cambia a la pestaña EQUIPO.")
        return
    _clic(perfil.call("rect_hueco", 2).get_center())
    if str((game.get("gear") as Dictionary).get("peto", "")) != "":
        _fail("Tocar el peto en EQUIPO no lo quita.")
        return
    # El botón HABILIDADES abre las habilidades; al cerrarlas se vuelve al juego.
    _clic((perfil.get("BOTON_HABILIDADES") as Rect2).get_center())
    if game.get("game_mode") != "abilities":
        _fail("El botón HABILIDADES del perfil no las abre.")
        return
    _tecla(KEY_ESCAPE)
    # Con el mando: LB abre el perfil y B lo cierra; tocar fuera también cierra.
    var lb := InputEventJoypadButton.new()
    lb.button_index = JOY_BUTTON_LEFT_SHOULDER
    lb.pressed = true
    root.push_input(lb)
    if game.get("game_mode") != "inventory":
        _fail("LB no abre el perfil.")
        return
    var bb := InputEventJoypadButton.new()
    bb.button_index = JOY_BUTTON_B
    bb.pressed = true
    root.push_input(bb)
    if game.get("game_mode") != "play" or perfil.visible:
        _fail("B no cierra el perfil.")
        return
    game.call("_open_inventory")
    _clic(Vector2(20, 20))
    if game.get("game_mode") != "play":
        _fail("Tocar fuera no cierra el perfil.")
        return
    print("OK: perfil (mochila, objetos, equipo y Ecos) como escena.")

    # --- Fase 2e: HUD como escena ---------------------------------------------------
    var hud: CanvasLayer = game.get_node("Hud")
    if not (int(hud.layer) > 0 and int(hud.layer) < int((pantallas as CanvasLayer).layer)):
        _fail("El HUD debe ir encima de la sala y debajo de las pantallas.")
        return
    game.set("touch_enabled", false)
    game.set("souls", 23)
    await process_frame
    var piezas := ["FranjaSuperior", "PanelJugador", "CartelPiso", "Minimapa", "FranjaInferior", "Mision", "PanelArma"]
    for nombre in piezas:
        if not (hud.call("pieza", StringName(nombre)) as Control).visible:
            _fail("La pieza %s del HUD no se ve al jugar." % nombre)
            return
    if int((hud.call("pieza", &"CartelPiso") as Control).get("d").get("almas", -1)) != 23:
        _fail("El cartel del HUD no muestra las almas.")
        return
    if ((hud.call("pieza", &"Minimapa") as Control).get("d").get("salas", []) as Array).size() != int(game.call("_room_count")):
        _fail("El minimapa del HUD no tiene todas las salas.")
        return
    if (hud.call("pieza", &"ControlesTactiles") as Control).visible:
        _fail("Los controles táctiles se ven sin pantalla táctil.")
        return
    game.set("touch_enabled", true)
    await process_frame
    if not (hud.call("pieza", &"ControlesTactiles") as Control).visible or (hud.call("pieza", &"PanelArma") as Control).visible:
        _fail("En móvil, el HUD debe mostrar los botones táctiles en lugar del panel del arma.")
        return
    game.set("touch_enabled", false)
    game.set("mission_banner", "PRUEBA")
    game.set("mission_banner_t", 1.0)
    game.set("fade_t", 0.2)
    await process_frame
    if not (hud.call("pieza", &"AvisoMision") as Control).visible or not (hud.call("pieza", &"Fundido") as Control).visible:
        _fail("El rótulo de misión o el fundido de la sala no aparecen en el HUD.")
        return
    game.set("mission_banner_t", 0.0)
    game.set("fade_t", 0.0)
    game.set("shake", 0.5)
    await process_frame
    if (hud as CanvasLayer).offset != (game as Node2D).position:
        _fail("El HUD no se sacude con la sala.")
        return
    game.set("shake", 0.0)
    game.set("game_mode", "title")
    await process_frame
    if (hud.call("pieza", &"PanelJugador") as Control).visible:
        _fail("El HUD se ve en el menú principal.")
        return
    print("OK: HUD (barras, minimapa, misión, arma y controles táctiles) como escena.")
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
