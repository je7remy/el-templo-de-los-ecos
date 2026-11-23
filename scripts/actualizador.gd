extends Node
## Actualizaciones del juego desde las versiones publicadas en GitHub.
##
## Al abrir una copia exportada (no el editor ni las pruebas), pregunta a
## GitHub cuál es la última versión. Si es más nueva que la propia, la pantalla
## de título lo avisa y, al aceptar, cada plataforma se actualiza a su manera:
##   · Windows instalado: descarga el instalador y lo ejecuta en silencio (/S);
##     el instalador reemplaza el juego y lo vuelve a abrir.
##   · Windows portable: descarga el .zip y cambia el .exe por el nuevo.
##   · Linux: descarga el .tar.gz y cambia el ejecutable por el nuevo.
##   · Android: abre la descarga del APK; Android pide confirmar la instalación
##     (ninguna app puede instalarse sola).
## Si algo falla, abre la página de la versión para descargarla a mano.
## La partida guardada vive aparte (user://) y no se toca en ningún caso.

signal cambiado

const REPO := "je7remy/el-templo-de-los-ecos"
const API := "https://api.github.com/repos/" + REPO + "/releases?per_page=10"
const PAGINA := "https://github.com/" + REPO + "/releases"
const CARPETA := "user://actualizacion"

## inactivo, buscando, al_dia, disponible, descargando, instalando, abierto, error
var estado: String = "inactivo"
var version_nueva: String = ""
var url_pagina: String = PAGINA
var recurso: Dictionary = {}
var progreso: float = 0.0
var detalle: String = ""
var descartada: bool = false

var _http: HTTPRequest


## Versión de esta copia del juego (project.godot → application/config/version).
static func version_local() -> String:
    return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


## "v0.5.10-alpha" → [[0, 5, 10], "alpha"].
static func _partes(v: String) -> Array:
    var limpio := v.strip_edges().trim_prefix("v").trim_prefix("V")
    var sufijo := ""
    var guion := limpio.find("-")
    if guion >= 0:
        sufijo = limpio.substr(guion + 1).to_lower()
        limpio = limpio.substr(0, guion)
    var nums: Array = []
    for trozo in limpio.split("."):
        nums.append(int(trozo) if trozo.is_valid_int() else 0)
    while nums.size() < 3:
        nums.append(0)
    return [nums, sufijo]


## Orden de las etiquetas: alpha < beta < rc < versión final (sin sufijo).
static func _rango_sufijo(s: String) -> int:
    if s == "":
        return 4
    if s.begins_with("rc"):
        return 3
    if s.begins_with("beta"):
        return 2
    if s.begins_with("alpha"):
        return 1
    return 0


## -1 si a es más vieja que b, 0 si son la misma, 1 si a es más nueva.
static func comparar(a: String, b: String) -> int:
    var pa := _partes(a)
    var pb := _partes(b)
    var na: Array = pa[0]
    var nb: Array = pb[0]
    for i in range(maxi(na.size(), nb.size())):
        var x: int = na[i] if i < na.size() else 0
        var y: int = nb[i] if i < nb.size() else 0
        if x != y:
            return 1 if x > y else -1
    var ra := _rango_sufijo(pa[1])
    var rb := _rango_sufijo(pb[1])
    if ra != rb:
        return 1 if ra > rb else -1
    return 0


## android, windows_instalado, windows_portable, linux o "" (sin actualizador).
static func plataforma() -> String:
    match OS.get_name():
        "Android":
            return "android"
        "Windows":
            var dir := OS.get_executable_path().get_base_dir()
            return "windows_instalado" if FileAccess.file_exists(dir.path_join("Desinstalar.exe")) else "windows_portable"
        "Linux", "FreeBSD":
            return "linux"
    return ""


## Elige, entre los archivos de una versión, el que sirve a esta plataforma.
static func elegir_recurso(assets: Array, plat: String) -> Dictionary:
    var fin := ""
    var contiene := ""
    match plat:
        "android":
            fin = ".apk"
        "windows_instalado":
            fin = ".exe"
            contiene = "setup"
        "windows_portable":
            fin = ".zip"
            contiene = "windows"
        "linux":
            fin = ".tar.gz"
            contiene = "linux"
        _:
            return {}
    for a in assets:
        if typeof(a) != TYPE_DICTIONARY:
            continue
        var nombre := str(a.get("name", "")).to_lower()
        if nombre.ends_with(fin) and (contiene == "" or nombre.contains(contiene)):
            return {"nombre": str(a.get("name", "")), "url": str(a.get("browser_download_url", "")), "tam": int(a.get("size", 0))}
    return {}


## De la lista de versiones de GitHub, la más nueva que sea más nueva que la
## propia y traiga archivo para esta plataforma. {} si no hay ninguna.
static func elegir_version(releases: Array, actual: String, plat: String) -> Dictionary:
    var mejor: Dictionary = {}
    for r in releases:
        if typeof(r) != TYPE_DICTIONARY or bool(r.get("draft", false)):
            continue
        var tag := str(r.get("tag_name", ""))
        if tag == "" or comparar(tag, actual) <= 0:
            continue
        if not mejor.is_empty() and comparar(tag, str(mejor["tag"])) <= 0:
            continue
        var rec := elegir_recurso(r.get("assets", []), plat)
        if rec.is_empty():
            continue
        mejor = {"tag": tag, "pagina": str(r.get("html_url", PAGINA)), "recurso": rec}
    return mejor


## Dirección de la lista de versiones. Para probar el actualizador con un
## servidor propio: ElTemploDeLosEcos -- --api-actualizaciones=http://…
static func api() -> String:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--api-actualizaciones="):
            return arg.trim_prefix("--api-actualizaciones=")
    return API


## Solo las copias exportadas buscan actualizaciones: ni el editor, ni las
## pruebas automáticas, ni una ejecución sin pantalla.
static func permitido() -> bool:
    if Engine.has_meta("modo_prueba") or DisplayServer.get_name() == "headless":
        return false
    return OS.has_feature("template") and plataforma() != ""


func _ready() -> void:
    _limpiar_restos()


func buscar() -> void:
    if estado in ["buscando", "descargando", "instalando"]:
        return
    estado = "buscando"
    cambiado.emit()
    _nuevo_http()
    _http.request_completed.connect(_respuesta_busqueda)
    var cabeceras := PackedStringArray(["User-Agent: ElTemploDeLosEcos/" + version_local(), "Accept: application/vnd.github+json"])
    if _http.request(api(), cabeceras) != OK:
        estado = "inactivo" # sin red no se avisa nada: se juega con lo que hay
        cambiado.emit()


func _nuevo_http() -> void:
    if _http != null:
        _http.queue_free()
    _http = HTTPRequest.new()
    _http.timeout = 20.0
    _http.use_threads = true
    add_child(_http)


func _respuesta_busqueda(resultado: int, codigo: int, _cab: PackedStringArray, cuerpo: PackedByteArray) -> void:
    if resultado != HTTPRequest.RESULT_SUCCESS or codigo != 200:
        # Sin internet no pasa nada: se juega con la versión que hay.
        estado = "inactivo"
        cambiado.emit()
        return
    var datos = JSON.parse_string(cuerpo.get_string_from_utf8())
    if typeof(datos) != TYPE_ARRAY:
        estado = "inactivo"
        cambiado.emit()
        return
    var v := elegir_version(datos, version_local(), plataforma())
    if v.is_empty():
        estado = "al_dia"
    else:
        version_nueva = str(v["tag"]).trim_prefix("v")
        url_pagina = str(v["pagina"])
        recurso = v["recurso"]
        estado = "disponible"
    cambiado.emit()


func _process(_dt: float) -> void:
    if _http == null:
        return
    if estado == "descargando":
        var total: int = _http.get_body_size()
        if total <= 0:
            total = int(recurso.get("tam", 0))
        if total > 0:
            progreso = clampf(float(_http.get_downloaded_bytes()) / float(total), 0.0, 1.0)


func ahora_no() -> void:
    descartada = true
    cambiado.emit()


## Visible en el título: hay versión nueva y no se ha dicho «ahora no».
func aviso_visible() -> bool:
    return not descartada and estado in ["disponible", "descargando", "instalando", "abierto", "error"]


func actualizar() -> void:
    if estado != "disponible" and estado != "error":
        return
    var plat := plataforma()
    if plat == "android":
        # Android exige que la persona confirme la instalación del APK.
        OS.shell_open(str(recurso.get("url", url_pagina)))
        estado = "abierto"
        cambiado.emit()
        return
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CARPETA))
    estado = "descargando"
    progreso = 0.0
    detalle = ""
    cambiado.emit()
    _nuevo_http()
    _http.download_file = CARPETA.path_join(str(recurso.get("nombre", "descarga")))
    _http.request_completed.connect(_descarga_lista)
    if _http.request(str(recurso.get("url", ""))) != OK:
        _fallo("no se pudo descargar")


func _descarga_lista(resultado: int, codigo: int, _cab: PackedStringArray, _cuerpo: PackedByteArray) -> void:
    if resultado != HTTPRequest.RESULT_SUCCESS or codigo != 200:
        _fallo("descarga interrumpida")
        return
    progreso = 1.0
    estado = "instalando"
    cambiado.emit()
    var archivo := ProjectSettings.globalize_path(CARPETA.path_join(str(recurso.get("nombre", ""))))
    var exe := OS.get_executable_path()
    var ok := false
    match plataforma():
        "windows_instalado":
            # El instalador espera a que el juego se cierre, lo reemplaza y lo reabre.
            ok = OS.create_process(archivo, ["/S"]) > 0
        "windows_portable":
            ok = cambiar_exe_portable(archivo, exe) and OS.create_process(exe, []) > 0
        "linux":
            ok = cambiar_ejecutable_linux(archivo, exe) and OS.create_process(exe, []) > 0
    if not ok:
        _fallo("no se pudo instalar")
        return
    # Se cierra al terminar este cuadro (no dentro de la señal de la descarga).
    _http.queue_free()
    _http = null
    get_tree().quit.call_deferred()


## En Windows no se puede sobrescribir un .exe abierto, pero sí renombrarlo:
## el viejo pasa a .old.exe (se borra al abrir el nuevo) y el nuevo ocupa su sitio.
static func cambiar_exe_portable(zip: String, exe: String) -> bool:
    var lector := ZIPReader.new()
    if lector.open(zip) != OK:
        return false
    var dentro := ""
    for f in lector.get_files():
        if f.to_lower().ends_with(".exe"):
            dentro = f
            break
    if dentro == "":
        lector.close()
        return false
    var bytes := lector.read_file(dentro)
    lector.close()
    if bytes.is_empty():
        return false
    var viejo := exe.get_basename() + ".old.exe"
    if FileAccess.file_exists(viejo):
        DirAccess.remove_absolute(viejo)
    if DirAccess.rename_absolute(exe, viejo) != OK:
        return false
    var f := FileAccess.open(exe, FileAccess.WRITE)
    if f == null:
        DirAccess.rename_absolute(viejo, exe)
        return false
    f.store_buffer(bytes)
    f.close()
    return true


## En Linux se puede reemplazar el archivo del juego abierto: se copia el nuevo
## al lado y se renombra encima (el viejo sigue en memoria hasta cerrarse).
static func cambiar_ejecutable_linux(tar: String, exe: String) -> bool:
    var destino_tmp := ProjectSettings.globalize_path(CARPETA.path_join("extraido"))
    OS.execute("rm", ["-rf", destino_tmp])
    DirAccess.make_dir_recursive_absolute(destino_tmp)
    if OS.execute("tar", ["-xzf", tar, "-C", destino_tmp]) != 0:
        return false
    var salida: Array = []
    OS.execute("find", [destino_tmp, "-name", "*.x86_64", "-type", "f"], salida)
    var nuevo := str(salida[0]).strip_edges().split("\n")[0] if not salida.is_empty() else ""
    if nuevo == "" or not FileAccess.file_exists(nuevo):
        return false
    var junto := exe + ".nuevo"
    if OS.execute("cp", ["-f", nuevo, junto]) != 0:
        return false
    OS.execute("chmod", ["755", junto])
    if OS.execute("mv", ["-f", junto, exe]) != 0:
        OS.execute("rm", ["-f", junto])
        return false
    OS.execute("rm", ["-rf", destino_tmp])
    return true


## Si no se pudo actualizar solo, se abre la página de la versión.
func abrir_pagina() -> void:
    OS.shell_open(url_pagina)


func _fallo(motivo: String) -> void:
    detalle = motivo
    estado = "error"
    cambiado.emit()


## Borra descargas viejas y el .exe anterior de una actualización portable.
func _limpiar_restos() -> void:
    if not permitido():
        return
    var viejo := OS.get_executable_path().get_basename() + ".old.exe"
    if OS.get_name() == "Windows" and FileAccess.file_exists(viejo):
        DirAccess.remove_absolute(viejo)
    var dir := DirAccess.open(CARPETA)
    if dir == null:
        return
    for f in dir.get_files():
        dir.remove(f)
    if OS.get_name() != "Windows" and dir.dir_exists("extraido"):
        OS.execute("rm", ["-rf", ProjectSettings.globalize_path(CARPETA.path_join("extraido"))])
