extends Node
## Vitrinas (autoload «Vitrinas»): objetos en 3D pixelado para los momentos
## clave (el rótulo del cofre, el perfil y el menú principal).
##
## Cada objeto se arma con piezas sencillas (cajas, cilindros, esferas…) dentro
## de un SubViewport pequeño con su propio mundo 3D y fondo transparente. Se
## renderiza a pocos píxeles y se dibuja ampliado con filtro NEAREST, así que
## se ve como pixel art que gira con luz de verdad.
##
##   var tex := Vitrinas.textura("espada")        # null si no hay modelo
##   draw_texture_rect(tex, Rect2(pos, Vector2(64, 64)), false)
##
## Las vitrinas se crean la primera vez que se piden y se paran solas cuando
## nadie las pide durante un rato (no gastan nada mientras no se ven).

## Píxeles del lado de la textura (se dibuja ampliada).
const LADO := 48
## Segundos sin pedirla antes de dejar de renderizarla.
const REPOSO := 0.6
## Vueltas por segundo (radianes).
const GIRO := 1.1

## Objetos planos: se mecen de cara a la cámara en vez de dar la vuelta entera
## (de canto casi no se ven).
const PLANOS := ["espada", "daga", "lanza", "hacha", "maza", "escudo", "amuleto", "mascara", "fosforos"]

## Nombres que llegan desde otras partes del juego → modelo.
const ALIAS := {
    "fosforos_caja": "fosforos", "amuleto_up": "amuleto", "brazalete_up": "brazalete",
    "resonancia_up": "resonancia", "antorcha_encendida": "antorcha",
}

const ORO := Color("#d9a94e")
const HIERRO := Color("#9aa3ad")
const ACERO := Color("#c9d1d8")
const CUERO := Color("#6b4428")
const MADERA := Color("#7a4f2c")
const HUESO := Color("#e6dcc3")
const OSCURO := Color("#141018")
const ALMA := Color("#7fe3ff")
const VIOLETA := Color("#b48cff")
const SANGRE := Color("#c4243a")

## id → {"vp": SubViewport, "raiz": Node3D, "t": último pedido, "fase": float}
var _vitrinas: Dictionary = {}
var _reloj: float = 0.0
## Sin pantalla (pruebas en --headless) las piezas se arman sin malla: el
## renderizador vacío no sabe medir las mallas primitivas y llena el registro.
var _sin_pantalla: bool = DisplayServer.get_name() == "headless"


func _process(delta: float) -> void:
    _reloj += delta
    for id in _vitrinas:
        var v: Dictionary = _vitrinas[id]
        var vp: SubViewport = v["vp"]
        var activa: bool = _reloj - float(v["t"]) < REPOSO
        vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if activa else SubViewport.UPDATE_DISABLED
        if not activa:
            continue
        v["fase"] = float(v["fase"]) + delta
        var f: float = v["fase"]
        var raiz: Node3D = v["raiz"]
        raiz.rotation.y = sin(f * GIRO * 0.7) * 0.9 if bool(v["plano"]) else f * GIRO
        raiz.position.y = sin(f * 1.7) * 0.05
        for n in raiz.find_children("*", "Node3D", true, false):
            if n.has_meta("late"):
                var s: float = 1.0 + sin(f * float(n.get_meta("late"))) * 0.08
                n.scale = (n.get_meta("escala_base") as Vector3) * s


## ¿Hay modelo 3D para este nombre?
func tiene(id: String) -> bool:
    return _modelo(_normal(id)) != ""


## Textura viva del objeto (null si no hay modelo). Pedirla cada fotografía la
## mantiene girando; si se deja de pedir, se para.
func textura(id: String) -> Texture2D:
    var k: String = _normal(id)
    if _modelo(k) == "":
        return null
    if not _vitrinas.has(k):
        _crear(k)
    _vitrinas[k]["t"] = _reloj
    return (_vitrinas[k]["vp"] as SubViewport).get_texture()


## Dibuja el objeto en «dest» con un contorno oscuro de un píxel (del tamaño
## del píxel ampliado). Devuelve false si no hay modelo, para que quien llama
## dibuje su icono plano.
func dibujar(c: CanvasItem, id: String, dest: Rect2, alfa: float = 1.0) -> bool:
    var tex: Texture2D = textura(id)
    if tex == null:
        return false
    var px: float = maxf(1.0, roundf(dest.size.x / float(LADO)))
    var sombra := Color(0.03, 0.02, 0.05, 0.85 * alfa)
    for o in [Vector2(px, 0), Vector2(-px, 0), Vector2(0, px), Vector2(0, -px)]:
        c.draw_texture_rect(tex, Rect2(dest.position + o, dest.size), false, sombra)
    c.draw_texture_rect(tex, dest, false, Color(1, 1, 1, alfa))
    return true


## Cuántas vitrinas están renderizando ahora mismo (para las pruebas).
func activas() -> int:
    var n: int = 0
    for id in _vitrinas:
        if (_vitrinas[id]["vp"] as SubViewport).render_target_update_mode == SubViewport.UPDATE_ALWAYS:
            n += 1
    return n


## Todos los modelos que hay.
func modelos() -> PackedStringArray:
    return PackedStringArray(["reliquia", "alma", "resonancia", "calavera", "corazon", "mascara",
        "espada", "daga", "lanza", "hacha", "maza", "antorcha", "escudo",
        "yelmo", "peto", "botas", "amuleto", "brazalete",
        "vial", "pan", "fosforos", "incienso", "bolsa_almas", "campana"])


## Piezas del modelo (para las pruebas).
func piezas(id: String) -> int:
    var k: String = _normal(id)
    if _modelo(k) == "":
        return 0
    if not _vitrinas.has(k):
        _crear(k)
    return (_vitrinas[k]["raiz"] as Node3D).find_children("*", "MeshInstance3D", true, false).size()


func _normal(id: String) -> String:
    return str(ALIAS.get(id, id))


func _modelo(k: String) -> String:
    return k if modelos().has(k) else ""


# ------------------------------------------------------------ ESCENARIO
func _crear(k: String) -> void:
    var vp := SubViewport.new()
    vp.name = "Vitrina_" + k
    vp.size = Vector2i(LADO, LADO)
    vp.transparent_bg = true
    vp.own_world_3d = true
    vp.msaa_3d = Viewport.MSAA_DISABLED
    vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
    vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    add_child(vp)

    var cam := Camera3D.new()
    cam.projection = Camera3D.PROJECTION_ORTHOGONAL
    cam.size = 1.8
    cam.position = Vector3(0, 0.25, 3.0)
    cam.rotation_degrees = Vector3(-7, 0, 0)
    var entorno := Environment.new()
    entorno.background_mode = Environment.BG_CLEAR_COLOR
    entorno.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    entorno.ambient_light_color = Color("#3a3050")
    entorno.ambient_light_energy = 1.4
    cam.environment = entorno
    vp.add_child(cam)

    var sol := DirectionalLight3D.new() # luz cálida de antorcha, arriba a la izquierda
    sol.light_color = Color("#ffd6a0")
    sol.light_energy = 1.6
    sol.rotation_degrees = Vector3(-40, -35, 0)
    vp.add_child(sol)
    var contra := DirectionalLight3D.new() # contraluz fría: recorta la silueta
    contra.light_color = Color("#7fb8ff")
    contra.light_energy = 0.7
    contra.rotation_degrees = Vector3(-15, 150, 0)
    vp.add_child(contra)

    var raiz := Node3D.new()
    raiz.name = "Modelo"
    vp.add_child(raiz)
    var cuerpo := Node3D.new() # inclinación propia del objeto; la raíz solo gira
    raiz.add_child(cuerpo)
    call("_m_" + k, cuerpo)
    _vitrinas[k] = {"vp": vp, "raiz": raiz, "t": _reloj, "fase": randf() * TAU, "plano": PLANOS.has(k)}


# ------------------------------------------------------------ PIEZAS
func _mat(color: Color, metal: float = 0.0, brillo: float = 0.0, alfa: float = 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(color.r, color.g, color.b, alfa)
    m.metallic = metal * 0.45 # sin reflejos de entorno, el metal puro sale negro
    m.roughness = 0.45 if metal > 0.0 else 0.85
    m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
    m.specular_mode = BaseMaterial3D.SPECULAR_TOON
    if alfa < 1.0:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    if brillo > 0.0:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = brillo
    return m


func _pieza(padre: Node3D, malla: Mesh, mat: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO, escala: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var mi := MeshInstance3D.new()
    if not _sin_pantalla:
        mi.mesh = malla
    mi.material_override = mat
    mi.position = pos
    mi.rotation_degrees = rot
    mi.scale = escala
    mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    padre.add_child(mi)
    return mi


func _caja(x: float, y: float, z: float) -> BoxMesh:
    var m := BoxMesh.new()
    m.size = Vector3(x, y, z)
    return m


func _cil(r_arriba: float, r_abajo: float, alto: float, lados: int = 10) -> CylinderMesh:
    var m := CylinderMesh.new()
    m.top_radius = r_arriba
    m.bottom_radius = r_abajo
    m.height = alto
    m.radial_segments = lados
    m.rings = 1
    return m


func _esfera(r: float, media: bool = false) -> SphereMesh:
    var m := SphereMesh.new()
    m.radius = r
    m.height = r * (1.0 if media else 2.0)
    m.is_hemisphere = media
    m.radial_segments = 12
    m.rings = 6
    return m


func _aro(r: float, grosor: float) -> TorusMesh:
    var m := TorusMesh.new()
    m.inner_radius = r - grosor
    m.outer_radius = r + grosor
    m.rings = 14
    m.ring_segments = 6
    return m


func _prisma(x: float, y: float, z: float) -> PrismMesh:
    var m := PrismMesh.new()
    m.size = Vector3(x, y, z)
    return m


func _late(n: Node3D, velocidad: float) -> void:
    n.set_meta("late", velocidad)
    n.set_meta("escala_base", n.scale)


## Mango de madera con empuñadura de cuero (para armas de asta).
func _mango(c: Node3D, alto: float, y: float) -> void:
    _pieza(c, _cil(0.045, 0.05, alto, 6), _mat(MADERA), Vector3(0, y, 0))
    _pieza(c, _cil(0.06, 0.06, 0.22, 6), _mat(CUERO), Vector3(0, y - alto * 0.5 + 0.18, 0))


# ------------------------------------------------------------ MODELOS
func _m_reliquia(c: Node3D) -> void:
    var cristal := _mat(ALMA, 0.0, 1.6, 0.92)
    var arriba := _pieza(c, _cil(0.0, 0.32, 0.6, 6), cristal, Vector3(0, 0.3, 0))
    _pieza(c, _cil(0.32, 0.0, 0.5, 6), cristal, Vector3(0, -0.25, 0))
    _pieza(c, _aro(0.42, 0.035), _mat(ORO, 0.9), Vector3(0, 0.02, 0), Vector3(90, 0, 18))
    _pieza(c, _aro(0.42, 0.035), _mat(ORO, 0.9), Vector3(0, 0.02, 0), Vector3(90, 0, -18))
    _pieza(c, _esfera(0.12), _mat(Color.WHITE, 0.0, 2.2), Vector3(0, 0.05, 0))
    _late(arriba, 3.0)


func _m_alma(c: Node3D) -> void:
    var nucleo := _pieza(c, _esfera(0.32), _mat(ALMA, 0.0, 1.8, 0.9), Vector3(0, 0.05, 0))
    _pieza(c, _esfera(0.16), _mat(Color.WHITE, 0.0, 2.5), Vector3(0, 0.05, 0))
    _pieza(c, _aro(0.55, 0.025), _mat(VIOLETA, 0.0, 1.4), Vector3(0, 0.05, 0), Vector3(70, 0, 0))
    _pieza(c, _prisma(0.14, 0.45, 0.14), _mat(ALMA, 0.0, 1.2, 0.8), Vector3(0, 0.5, 0))
    _late(nucleo, 4.0)


func _m_resonancia(c: Node3D) -> void:
    for i in range(3):
        var a := _pieza(c, _aro(0.22 + i * 0.18, 0.03), _mat(ALMA.lerp(VIOLETA, i * 0.4), 0.0, 1.6 - i * 0.3), Vector3(0, 0.05, 0), Vector3(90 - i * 25, 0, i * 30))
        _late(a, 2.0 + i)
    _pieza(c, _esfera(0.1), _mat(Color.WHITE, 0.0, 2.4), Vector3(0, 0.05, 0))


func _m_calavera(c: Node3D) -> void:
    var hueso := _mat(HUESO)
    var hueco := _mat(OSCURO)
    _pieza(c, _esfera(0.42), hueso, Vector3(0, 0.2, 0), Vector3.ZERO, Vector3(1, 0.95, 1.05))
    _pieza(c, _caja(0.5, 0.26, 0.42), hueso, Vector3(0, -0.12, 0.04))
    _pieza(c, _caja(0.42, 0.12, 0.36), hueso, Vector3(0, -0.36, 0.06))
    for x in [-0.15, 0.15]:
        _pieza(c, _esfera(0.11), hueco, Vector3(x, 0.08, 0.33))
    _pieza(c, _prisma(0.1, 0.12, 0.08), hueco, Vector3(0, -0.07, 0.4), Vector3(0, 0, 180))
    for i in range(4):
        _pieza(c, _caja(0.06, 0.06, 0.04), hueco, Vector3(-0.12 + i * 0.08, -0.27, 0.25))


func _m_corazon(c: Node3D) -> void:
    var carne := _mat(SANGRE, 0.0, 0.5)
    var latido := Node3D.new()
    c.add_child(latido)
    for x in [-0.17, 0.17]:
        _pieza(latido, _esfera(0.27), carne, Vector3(x, 0.2, 0))
    _pieza(latido, _cil(0.36, 0.0, 0.62, 10), carne, Vector3(0, -0.15, 0))
    _pieza(latido, _cil(0.07, 0.07, 0.25, 6), _mat(Color("#8a1a2a")), Vector3(0.05, 0.5, 0), Vector3(0, 0, -15))
    _late(latido, 6.0)


func _m_mascara(c: Node3D) -> void:
    var porcelana := _mat(Color("#efe8e0"), 0.2)
    _pieza(c, _esfera(0.45, true), porcelana, Vector3(0, 0.05, 0), Vector3(90, 0, 0), Vector3(0.85, 1, 1.15))
    for x in [-0.15, 0.15]:
        _pieza(c, _esfera(0.08), _mat(OSCURO), Vector3(x, 0.15, 0.36), Vector3.ZERO, Vector3(1.3, 0.7, 0.5))
        _pieza(c, _caja(0.025, 0.2, 0.02), _mat(Color("#6a6a78")), Vector3(x, -0.02, 0.4))
    _pieza(c, _caja(0.16, 0.035, 0.05), _mat(SANGRE), Vector3(0, -0.22, 0.38))


func _arma(c: Node3D) -> Node3D:
    var a := Node3D.new()
    a.rotation_degrees = Vector3(0, 0, -38)
    c.add_child(a)
    return a


func _m_espada(c: Node3D) -> void:
    var a := _arma(c)
    _pieza(a, _caja(0.14, 1.1, 0.04), _mat(ACERO, 0.9), Vector3(0, 0.25, 0))
    _pieza(a, _prisma(0.14, 0.2, 0.04), _mat(ACERO, 0.9), Vector3(0, 0.9, 0))
    _pieza(a, _caja(0.03, 0.9, 0.05), _mat(HIERRO, 0.9), Vector3(0, 0.22, 0))
    _pieza(a, _caja(0.5, 0.08, 0.1), _mat(ORO, 0.9), Vector3(0, -0.34, 0))
    _pieza(a, _cil(0.045, 0.045, 0.3, 6), _mat(CUERO), Vector3(0, -0.53, 0))
    _pieza(a, _esfera(0.08), _mat(ORO, 0.9), Vector3(0, -0.72, 0))


func _m_daga(c: Node3D) -> void:
    var a := _arma(c)
    _pieza(a, _caja(0.13, 0.6, 0.035), _mat(ACERO, 0.9), Vector3(0, 0.15, 0))
    _pieza(a, _prisma(0.13, 0.22, 0.035), _mat(ACERO, 0.9), Vector3(0, 0.56, 0))
    _pieza(a, _caja(0.32, 0.06, 0.08), _mat(HIERRO, 0.8), Vector3(0, -0.17, 0))
    _pieza(a, _cil(0.04, 0.04, 0.24, 6), _mat(CUERO), Vector3(0, -0.32, 0))
    _pieza(a, _esfera(0.06), _mat(SANGRE, 0.3, 0.4), Vector3(0, -0.47, 0))


func _m_lanza(c: Node3D) -> void:
    var a := _arma(c)
    _mango(a, 1.5, -0.1)
    _pieza(a, _prisma(0.2, 0.42, 0.05), _mat(ACERO, 0.9), Vector3(0, 0.86, 0))
    _pieza(a, _cil(0.06, 0.06, 0.08, 6), _mat(HIERRO, 0.9), Vector3(0, 0.63, 0))
    _pieza(a, _caja(0.03, 0.18, 0.02), _mat(SANGRE), Vector3(0.07, 0.52, 0))


func _m_hacha(c: Node3D) -> void:
    var a := _arma(c)
    _mango(a, 1.3, -0.15)
    _pieza(a, _caja(0.38, 0.34, 0.05), _mat(HIERRO, 0.85), Vector3(0.2, 0.38, 0))
    _pieza(a, _caja(0.05, 0.46, 0.04), _mat(ACERO, 0.95), Vector3(0.4, 0.38, 0))
    _pieza(a, _caja(0.14, 0.16, 0.09), _mat(HIERRO, 0.85), Vector3(-0.04, 0.38, 0))


func _m_maza(c: Node3D) -> void:
    var a := _arma(c)
    _mango(a, 1.1, -0.25)
    _pieza(a, _esfera(0.24), _mat(HIERRO, 0.8), Vector3(0, 0.45, 0))
    # [dirección, giro que lleva el eje Y del pincho hacia ella]
    for d in [[Vector3(1, 0, 0), Vector3(0, 0, -90)], [Vector3(-1, 0, 0), Vector3(0, 0, 90)],
            [Vector3(0, 0, 1), Vector3(90, 0, 0)], [Vector3(0, 0, -1), Vector3(-90, 0, 0)], [Vector3(0, 1, 0), Vector3.ZERO]]:
        _pieza(a, _cil(0.0, 0.07, 0.16, 4), _mat(ACERO, 0.9), Vector3(0, 0.45, 0) + d[0] * 0.27, d[1])


func _m_antorcha(c: Node3D) -> void:
    var a := Node3D.new()
    a.rotation_degrees = Vector3(0, 0, -14)
    c.add_child(a)
    _pieza(a, _cil(0.08, 0.05, 1.0, 6), _mat(MADERA), Vector3(0, -0.25, 0))
    _pieza(a, _cil(0.1, 0.1, 0.16, 6), _mat(CUERO), Vector3(0, 0.22, 0))
    var llama := _pieza(a, _esfera(0.17), _mat(Color("#ff7a1a"), 0.0, 2.0, 0.92), Vector3(0, 0.46, 0), Vector3.ZERO, Vector3(1, 1.7, 1))
    _pieza(a, _esfera(0.09), _mat(Color("#ffe27a"), 0.0, 2.6), Vector3(0, 0.42, 0), Vector3.ZERO, Vector3(1, 1.6, 1))
    _late(llama, 9.0)


func _m_escudo(c: Node3D) -> void:
    _pieza(c, _cil(0.5, 0.5, 0.07, 14), _mat(MADERA), Vector3(0, 0.05, 0), Vector3(90, 0, 0))
    _pieza(c, _aro(0.5, 0.04), _mat(HIERRO, 0.85), Vector3(0, 0.05, 0), Vector3(90, 0, 0))
    _pieza(c, _esfera(0.13), _mat(ORO, 0.9), Vector3(0, 0.05, 0.05))
    _pieza(c, _caja(0.9, 0.06, 0.08), _mat(HIERRO, 0.85), Vector3(0, 0.05, 0.02))


func _m_yelmo(c: Node3D) -> void:
    var metal := _mat(HIERRO, 0.85)
    _pieza(c, _esfera(0.42, true), metal, Vector3(0, 0.05, 0))
    _pieza(c, _cil(0.42, 0.44, 0.38, 12), metal, Vector3(0, -0.14, 0))
    _pieza(c, _caja(0.5, 0.06, 0.1), _mat(OSCURO), Vector3(0, -0.04, 0.39))
    _pieza(c, _caja(0.06, 0.3, 0.1), _mat(OSCURO), Vector3(0, -0.2, 0.4))
    _pieza(c, _aro(0.43, 0.03), _mat(ORO, 0.9), Vector3(0, -0.33, 0))
    _pieza(c, _caja(0.06, 0.2, 0.6), _mat(SANGRE), Vector3(0, 0.52, -0.05))


func _m_peto(c: Node3D) -> void:
    var metal := _mat(HIERRO, 0.85)
    _pieza(c, _caja(0.72, 0.8, 0.34), metal, Vector3(0, -0.05, 0))
    _pieza(c, _cil(0.36, 0.3, 0.2, 10), metal, Vector3(0, -0.52, 0))
    for x in [-0.42, 0.42]:
        _pieza(c, _esfera(0.18, true), metal, Vector3(x, 0.32, 0), Vector3(0, 0, -x * 50))
    _pieza(c, _caja(0.08, 0.4, 0.04), _mat(ORO, 0.9), Vector3(0, 0.0, 0.18))
    _pieza(c, _caja(0.28, 0.08, 0.04), _mat(ORO, 0.9), Vector3(0, 0.08, 0.18))
    _pieza(c, _caja(0.3, 0.12, 0.36), _mat(OSCURO), Vector3(0, 0.38, 0))


func _m_botas(c: Node3D) -> void:
    var cuero := _mat(CUERO)
    for x in [-0.2, 0.2]:
        _pieza(c, _caja(0.22, 0.5, 0.24), cuero, Vector3(x, 0.05, -0.05))
        _pieza(c, _caja(0.24, 0.16, 0.44), cuero, Vector3(x, -0.25, 0.05))
        _pieza(c, _caja(0.26, 0.06, 0.46), _mat(OSCURO), Vector3(x, -0.35, 0.05))
        _pieza(c, _aro(0.15, 0.035), _mat(HIERRO, 0.8), Vector3(x, 0.29, -0.05))


func _m_amuleto(c: Node3D) -> void:
    _pieza(c, _aro(0.36, 0.02), _mat(ORO, 0.9), Vector3(0, 0.3, 0), Vector3(90, 0, 0))
    _pieza(c, _cil(0.26, 0.26, 0.06, 12), _mat(ORO, 0.9), Vector3(0, -0.12, 0), Vector3(90, 0, 0))
    var gema := _pieza(c, _esfera(0.13), _mat(Color("#3fd2b0"), 0.2, 1.2), Vector3(0, -0.12, 0.05))
    _late(gema, 3.0)


func _m_brazalete(c: Node3D) -> void:
    _pieza(c, _cil(0.36, 0.36, 0.3, 14), _mat(ORO, 0.9), Vector3(0, 0, 0), Vector3(70, 0, 0))
    _pieza(c, _cil(0.3, 0.3, 0.32, 14), _mat(OSCURO), Vector3(0, 0, 0), Vector3(70, 0, 0))
    _pieza(c, _esfera(0.09), _mat(SANGRE, 0.3, 1.0), Vector3(0, 0.12, 0.33))


func _m_vial(c: Node3D) -> void:
    _pieza(c, _esfera(0.3), _mat(Color("#bfe6ff"), 0.0, 0.0, 0.45), Vector3(0, -0.18, 0))
    var liquido := _pieza(c, _esfera(0.24), _mat(SANGRE, 0.0, 1.2), Vector3(0, -0.2, 0))
    _pieza(c, _cil(0.1, 0.1, 0.36, 8), _mat(Color("#bfe6ff"), 0.0, 0.0, 0.45), Vector3(0, 0.25, 0))
    _pieza(c, _cil(0.11, 0.09, 0.14, 8), _mat(MADERA), Vector3(0, 0.48, 0))
    _late(liquido, 2.5)


func _m_pan(c: Node3D) -> void:
    var cap := CapsuleMesh.new()
    cap.radius = 0.25
    cap.height = 0.95
    _pieza(c, cap, _mat(Color("#c98a43")), Vector3(0, 0, 0), Vector3(0, 0, 90), Vector3(1, 1, 0.85))
    for i in range(3):
        _pieza(c, _caja(0.05, 0.04, 0.3), _mat(Color("#f0c27a")), Vector3(-0.2 + i * 0.2, 0.22, 0), Vector3(0, 30, 0))


func _m_fosforos(c: Node3D) -> void:
    _pieza(c, _caja(0.7, 0.2, 0.42), _mat(Color("#8a2a24")), Vector3(0, -0.15, 0))
    _pieza(c, _caja(0.5, 0.21, 0.3), _mat(Color("#d9c08a")), Vector3(0.05, -0.15, 0.065))
    for i in range(3):
        var x: float = -0.18 + i * 0.16
        _pieza(c, _cil(0.025, 0.025, 0.55, 4), _mat(Color("#e6c98f")), Vector3(x, 0.15, 0), Vector3(0, 0, -10 + i * 10))
        _pieza(c, _esfera(0.05), _mat(SANGRE), Vector3(x + (0.04 - i * 0.04), 0.43, 0))


func _m_incienso(c: Node3D) -> void:
    _pieza(c, _cil(0.32, 0.22, 0.2, 10), _mat(Color("#6a5a7a"), 0.4), Vector3(0, -0.4, 0))
    for i in range(3):
        var ang: float = i * 2.1
        var p := Vector3(cos(ang) * 0.1, 0.0, sin(ang) * 0.1)
        _pieza(c, _cil(0.018, 0.018, 0.7, 4), _mat(Color("#5a3a2a")), p + Vector3(0, -0.05, 0), Vector3(sin(ang) * 8, 0, cos(ang) * 8))
        _pieza(c, _esfera(0.04), _mat(Color("#ff8a3a"), 0.0, 2.2), p + Vector3(0, 0.3, 0))
    var humo := _pieza(c, _esfera(0.12), _mat(Color("#c8c0d8"), 0.0, 0.9, 0.45), Vector3(0, 0.5, 0), Vector3.ZERO, Vector3(1, 1.8, 1))
    _late(humo, 2.0)


func _m_bolsa_almas(c: Node3D) -> void:
    _pieza(c, _esfera(0.38), _mat(CUERO), Vector3(0, -0.15, 0), Vector3.ZERO, Vector3(1, 0.85, 1))
    _pieza(c, _cil(0.1, 0.16, 0.2, 8), _mat(CUERO), Vector3(0, 0.25, 0))
    _pieza(c, _aro(0.13, 0.03), _mat(ORO, 0.8), Vector3(0, 0.2, 0))
    var brillo := _pieza(c, _esfera(0.11), _mat(ALMA, 0.0, 2.0), Vector3(0, 0.4, 0))
    _late(brillo, 5.0)


func _m_campana(c: Node3D) -> void:
    var bronce := _mat(Color("#b8863a"), 0.9)
    _pieza(c, _cil(0.18, 0.42, 0.62, 12), bronce, Vector3(0, 0.0, 0))
    _pieza(c, _esfera(0.18, true), bronce, Vector3(0, 0.31, 0))
    _pieza(c, _aro(0.42, 0.04), bronce, Vector3(0, -0.31, 0))
    _pieza(c, _esfera(0.08), _mat(OSCURO), Vector3(0, -0.36, 0))
    _pieza(c, _aro(0.08, 0.025), _mat(HIERRO, 0.8), Vector3(0, 0.55, 0), Vector3(90, 0, 0))
