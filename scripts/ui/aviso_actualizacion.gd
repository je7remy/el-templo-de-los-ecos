extends Control
## Aviso de versión nueva (menú principal). Se conecta a un nodo
## Actualizador (scripts/actualizador.gd) y se redibuja cuando este cambia.
## Botones: ACTUALIZAR / DESCARGAR y AHORA NO / CERRAR. Tecla U: aceptar.

const Estilo := preload("res://scripts/ui/estilo.gd")
const Actualizador := preload("res://scripts/actualizador.gd")
const Ajustes := preload("res://scripts/ajustes.gd")

const TEXTOS := {
    "nueva": ["NUEVA VERSIÓN %s DISPONIBLE", "NEW VERSION %s AVAILABLE"],
    "actual": ["Tienes la %s. Tu partida se conserva.", "You have %s. Your save is kept."],
    "actualizar": ["ACTUALIZAR", "UPDATE"],
    "ahora_no": ["AHORA NO", "NOT NOW"],
    "descargando": ["DESCARGANDO %s · %d%%", "DOWNLOADING %s · %d%%"],
    "instalando": ["INSTALANDO… EL JUEGO SE REABRIRÁ SOLO", "INSTALLING… THE GAME WILL REOPEN"],
    "android": ["ABRE LA DESCARGA Y TOCA «INSTALAR»", "OPEN THE DOWNLOAD AND TAP «INSTALL»"],
    "android2": ["Android pide confirmarlo. Tu partida se conserva.", "Android asks you to confirm. Your save is kept."],
    "error": ["NO SE PUDO ACTUALIZAR SOLO (%s)", "COULD NOT UPDATE BY ITSELF (%s)"],
    "a_mano": ["DESCARGAR", "DOWNLOAD"],
    "cerrar": ["CERRAR", "CLOSE"],
}

@onready var aceptar: Control = $Aceptar
@onready var descartar: Control = $Descartar

var actualizador: Node = null


func _ready() -> void:
    Estilo.preparar_fuentes()
    mouse_filter = Control.MOUSE_FILTER_STOP
    aceptar.pressed.connect(_aceptar)
    descartar.pressed.connect(_descartar)
    _refrescar()


func _t(clave: String) -> String:
    var par: Array = TEXTOS.get(clave, [clave, clave])
    return par[1] if Ajustes.obtener("idioma") == "en" else par[0]


## Une el aviso a un actualizador (o lo suelta con null).
func vincular(nuevo: Node) -> void:
    if actualizador == nuevo:
        _refrescar()
        return
    if actualizador != null and actualizador.cambiado.is_connected(_refrescar):
        actualizador.cambiado.disconnect(_refrescar)
    actualizador = nuevo
    if actualizador != null:
        actualizador.cambiado.connect(_refrescar)
    _refrescar()


func _exit_tree() -> void:
    vincular(null)


func visible_aviso() -> bool:
    return actualizador != null and actualizador.aviso_visible()


## [aceptar, descartar]: textos de los botones ("" = no se muestra).
func botones() -> Array:
    if actualizador == null:
        return ["", ""]
    match str(actualizador.estado):
        "disponible":
            return [_t("actualizar"), _t("ahora_no")]
        "error":
            return [_t("a_mano"), _t("ahora_no")]
        "abierto":
            return [_t("a_mano"), _t("cerrar")]
    return ["", ""]


func _refrescar() -> void:
    visible = visible_aviso()
    if not is_node_ready():
        return
    var b: Array = botones()
    aceptar.texto = b[0]
    aceptar.visible = b[0] != ""
    descartar.texto = b[1]
    descartar.visible = b[1] != ""
    queue_redraw()


func _process(_delta: float) -> void:
    if visible and actualizador != null and str(actualizador.estado) == "descargando":
        queue_redraw() # barra de progreso


func _aceptar() -> void:
    if actualizador == null:
        return
    match str(actualizador.estado):
        "disponible":
            actualizador.actualizar()
        "error", "abierto":
            actualizador.abrir_pagina()


func _descartar() -> void:
    if actualizador != null:
        actualizador.ahora_no()


func _unhandled_key_input(event: InputEvent) -> void:
    if is_visible_in_tree() and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_U and aceptar.visible:
        get_viewport().set_input_as_handled()
        _aceptar()


func _draw() -> void:
    if actualizador == null:
        return
    var r := Rect2(Vector2.ZERO, size)
    var st := str(actualizador.estado)
    var mal := st == "error"
    Estilo.panel(self, r, Color("#2a1418") if mal else Color("#141f1c"), Estilo.CARMESI if mal else Estilo.ALMA)
    var nueva := "v" + str(actualizador.version_nueva)
    var l1 := ""
    var l2 := ""
    match st:
        "disponible":
            l1 = _t("nueva") % nueva
            l2 = _t("actual") % ("v" + Actualizador.version_local())
        "descargando":
            l1 = _t("descargando") % [nueva, int(round(float(actualizador.progreso) * 100.0))]
        "instalando":
            l1 = _t("instalando")
        "abierto":
            l1 = _t("android")
            l2 = _t("android2")
        "error":
            l1 = _t("error") % str(actualizador.detalle)
    var y: float = 24.0 if l2 != "" else 33.0
    Estilo.texto(self, l1, Vector2(14, y), 14, Estilo.CREMA)
    if l2 != "":
        Estilo.texto(self, l2, Vector2(14, y + 18.0), 11, Estilo.GRIS)
    if st == "descargando":
        var barra := Rect2(330, 20, 316, 14)
        draw_rect(barra, Color("#0b0f12"))
        draw_rect(Rect2(barra.position, Vector2(barra.size.x * clampf(float(actualizador.progreso), 0.0, 1.0), barra.size.y)), Estilo.ALMA)
        draw_rect(barra, Estilo.CLARO, false, 1.0)
