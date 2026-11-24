extends SceneTree
## Actualizador: comparación de versiones, elección del archivo de cada
## plataforma, reemplazo del ejecutable (Linux y Windows portable) y el aviso
## de la pantalla de título. No se conecta a internet.

const A := preload("res://scripts/actualizador.gd")

func _initialize() -> void:
    Engine.set_meta("modo_prueba", true)
    Engine.set_meta("splash_visto", true)
    for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg", "user://prueba_vigilia.json"]:
        if FileAccess.file_exists(f):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
    call_deferred("_run")


func _run() -> void:
    # --- Versiones -----------------------------------------------------------
    var casos := [
        ["0.5.9-alpha", "0.5.8-alpha", 1], ["0.5.8-alpha", "0.5.9-alpha", -1],
        ["v0.5.10-alpha", "0.5.9-alpha", 1], ["0.6.0-alpha", "0.5.12-alpha", 1],
        ["0.5.9-alpha", "v0.5.9-alpha", 0], ["0.5.9", "0.5.9-alpha", 1],
        ["0.5.9-beta", "0.5.9-alpha", 1], ["1.0.0-rc1", "1.0.0-beta", 1], ["1.0", "1.0.0", 0],
    ]
    for c in casos:
        if A.comparar(c[0], c[1]) != c[2]:
            _fail("comparar(%s, %s) debía dar %d." % c)
            return
    # La versión del juego (project.godot) es la misma que la del APK y los instaladores.
    var presets := ConfigFile.new()
    presets.load("res://export_presets.cfg")
    var exportada := str(presets.get_value("preset.0.options", "version/name", ""))
    if exportada == "" or A.version_local() != exportada:
        _fail("project.godot (%s) y export_presets.cfg (%s) deben tener la misma versión." % [A.version_local(), exportada])
        return
    if A.permitido():
        _fail("Las pruebas no deben buscar actualizaciones.")
        return
    # --- Elegir versión y archivo -------------------------------------------
    var assets := func(tag: String) -> Array:
        return [
            {"name": "ElTemploDeLosEcos-%s-Android.apk" % tag, "browser_download_url": "https://x/%s.apk" % tag, "size": 10},
            {"name": "ElTemploDeLosEcos-%s-Windows-Setup.exe" % tag, "browser_download_url": "https://x/%s-setup.exe" % tag, "size": 20},
            {"name": "ElTemploDeLosEcos-%s-Windows-Portable.zip" % tag, "browser_download_url": "https://x/%s.zip" % tag, "size": 30},
            {"name": "ElTemploDeLosEcos-%s-Linux-x86_64.tar.gz" % tag, "browser_download_url": "https://x/%s.tar.gz" % tag, "size": 40},
            # Copias de nombre fijo para los enlaces «latest/download»: no deben confundir al actualizador.
            {"name": "ElTemploDeLosEcos-Android.apk", "browser_download_url": "https://x/%s.apk" % tag, "size": 10},
            {"name": "ElTemploDeLosEcos-Windows-Setup.exe", "browser_download_url": "https://x/%s-setup.exe" % tag, "size": 20},
        ]
    var releases := [
        {"tag_name": "v0.5.8-alpha", "html_url": "p58", "assets": assets.call("v0.5.8-alpha")},
        {"tag_name": "v0.6.1-alpha", "html_url": "p61", "draft": true, "assets": assets.call("v0.6.1-alpha")},
        {"tag_name": "v0.6.0-alpha", "html_url": "p60", "assets": assets.call("v0.6.0-alpha")},
        {"tag_name": "v0.5.10-alpha", "html_url": "p510", "assets": assets.call("v0.5.10-alpha")},
    ]
    var esperado := {"android": ".apk", "windows_instalado": "-setup.exe", "windows_portable": ".zip", "linux": ".tar.gz"}
    for plat in esperado:
        var v: Dictionary = A.elegir_version(releases, "0.5.9-alpha", plat)
        if v.is_empty() or v["tag"] != "v0.6.0-alpha" or v["pagina"] != "p60" or not str(v["recurso"]["url"]).ends_with("v0.6.0-alpha" + esperado[plat]):
            _fail("Para %s debía elegirse v0.6.0-alpha (no el borrador ni versiones viejas): %s" % [plat, str(v)])
            return
    if not A.elegir_version(releases, "0.6.0-alpha", "linux").is_empty():
        _fail("Con la última versión instalada no debe ofrecerse nada.")
        return
    var sin_linux := [{"tag_name": "v0.7.0-alpha", "assets": [{"name": "x-Android.apk", "browser_download_url": "u"}]}]
    if not A.elegir_version(sin_linux, "0.5.9-alpha", "linux").is_empty():
        _fail("Una versión sin archivo para la plataforma no debe ofrecerse.")
        return
    # --- Reemplazo del ejecutable en Linux ------------------------------------
    var tmp := ProjectSettings.globalize_path("user://prueba_actualizador")
    OS.execute("rm", ["-rf", tmp])
    DirAccess.make_dir_recursive_absolute(tmp + "/paquete/ElTemploDeLosEcos-v0.6.0-alpha-Linux-x86_64")
    _escribir(tmp + "/paquete/ElTemploDeLosEcos-v0.6.0-alpha-Linux-x86_64/ElTemploDeLosEcos.x86_64", "NUEVO")
    _escribir(tmp + "/paquete/ElTemploDeLosEcos-v0.6.0-alpha-Linux-x86_64/LEEME.txt", "leeme")
    OS.execute("tar", ["-C", tmp + "/paquete", "-czf", tmp + "/linux.tar.gz", "ElTemploDeLosEcos-v0.6.0-alpha-Linux-x86_64"])
    _escribir(tmp + "/juego/ElTemploDeLosEcos.x86_64", "VIEJO")
    if not A.cambiar_ejecutable_linux(tmp + "/linux.tar.gz", tmp + "/juego/ElTemploDeLosEcos.x86_64"):
        _fail("No se pudo reemplazar el ejecutable de Linux.")
        return
    if _leer(tmp + "/juego/ElTemploDeLosEcos.x86_64") != "NUEVO" or FileAccess.file_exists(tmp + "/juego/ElTemploDeLosEcos.x86_64.nuevo"):
        _fail("El ejecutable de Linux no quedó actualizado.")
        return
    var permisos: Array = []
    OS.execute("stat", ["-c", "%a", tmp + "/juego/ElTemploDeLosEcos.x86_64"], permisos)
    if str(permisos[0]).strip_edges() != "755":
        _fail("El ejecutable nuevo de Linux no quedó ejecutable.")
        return
    if A.cambiar_ejecutable_linux(tmp + "/no_existe.tar.gz", tmp + "/juego/ElTemploDeLosEcos.x86_64") or _leer(tmp + "/juego/ElTemploDeLosEcos.x86_64") != "NUEVO":
        _fail("Un paquete roto no debe tocar el juego instalado.")
        return
    # --- Reemplazo del .exe portable ------------------------------------------
    var zp := ZIPPacker.new()
    zp.open(tmp + "/portable.zip")
    zp.start_file("ElTemploDeLosEcos.exe")
    zp.write_file("EXE-NUEVO".to_utf8_buffer())
    zp.close_file()
    zp.start_file("LEEME.txt")
    zp.write_file("leeme".to_utf8_buffer())
    zp.close_file()
    zp.close()
    _escribir(tmp + "/win/ElTemploDeLosEcos.exe", "EXE-VIEJO")
    if not A.cambiar_exe_portable(tmp + "/portable.zip", tmp + "/win/ElTemploDeLosEcos.exe"):
        _fail("No se pudo reemplazar el .exe portable.")
        return
    if _leer(tmp + "/win/ElTemploDeLosEcos.exe") != "EXE-NUEVO" or _leer(tmp + "/win/ElTemploDeLosEcos.old.exe") != "EXE-VIEJO":
        _fail("El .exe portable no quedó cambiado (el viejo pasa a .old.exe).")
        return
    OS.execute("rm", ["-rf", tmp])
    # --- Aviso en la pantalla de título ----------------------------------------
    var Ajustes = load("res://scripts/ajustes.gd")
    if not bool(Ajustes.obtener("buscar_actualizaciones")):
        _fail("Buscar actualizaciones debe venir activado.")
        return
    var game: Node = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    if game.get("actualizador") != null:
        _fail("En pruebas el juego no debe crear el actualizador.")
        return
    game.set("game_mode", "title")
    var ids: Array = []
    game.set("settings_tab", 0)
    for w in game.call("_settings_widgets"):
        ids.append(w["id"])
    if not ids.has("buscar_actualizaciones"):
        _fail("Falta el interruptor de actualizaciones en Ajustes.")
        return
    var u: Node = A.new()
    game.add_child(u)
    game.set("actualizador", u)
    u.version_nueva = "0.6.0-alpha"
    u.estado = "disponible"
    if not bool(game.call("_update_banner_on")):
        _fail("El aviso de versión nueva no se muestra.")
        return
    game.queue_redraw()
    await process_frame
    var no_btn: Rect2 = game.get("UPDATE_NO")
    game.call("_mobile_touch", 1, no_btn.get_center(), true)
    game.call("_mobile_touch", 1, no_btn.get_center(), false)
    if bool(game.call("_update_banner_on")) or game.get("game_mode") != "title":
        _fail("AHORA NO debe cerrar el aviso y quedarse en el menú.")
        return
    u.descartada = false
    u.estado = "error"
    if game.call("_update_buttons")[0] == "":
        _fail("Si falla, el aviso debe ofrecer la descarga a mano.")
        return
    print("OK: actualizador con versiones, archivo por plataforma, reemplazo del juego y aviso en el menú.")
    game.queue_free()
    await process_frame
    call_deferred("quit", 0)


func _escribir(ruta: String, texto: String) -> void:
    DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
    var f := FileAccess.open(ruta, FileAccess.WRITE)
    f.store_string(texto)
    f.close()


func _leer(ruta: String) -> String:
    if not FileAccess.file_exists(ruta):
        return ""
    return FileAccess.get_file_as_string(ruta)


func _fail(reason: String) -> void:
    push_error(reason)
    quit(1)
