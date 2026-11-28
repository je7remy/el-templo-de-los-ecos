extends Node
## Sustos: lo que pasa cuando no pasa nada.
##
## Cuatro tipos, repartidos al azar con calma (nunca dos seguidos, nunca en
## una pelea contra un jefe, nunca en el tutorial ni en la primera sala):
##
## - Aparición: una silueta o dos ojos en la parte oscura de la sala. Se
##   desvanece si la luz de la antorcha llega hasta ella o si tardas en mirarla.
## - A tu espalda: pasos, un golpe o un crujido que suenan detrás de ti
##   (por el lado contrario al que miras).
## - Interfaz: la luz se va dos veces, la pantalla se descompone un instante
##   o aparece tu nombre escrito en el muro del fondo.
## - Repentino: una entidad salta a la pantalla con un golpe de sonido.
##   Solo a partir del Piso II, como mucho uno por piso y nunca seguidos.
##   Se puede apagar en Ajustes («Sustos repentinos»).
##
## La campaña (main.gd) llama a actualizar() cada fotograma de juego,
## a sala_nueva() al entrar en una sala y a dibujar_mundo() después de la
## penumbra. Lo que va encima de todo (apagón, distorsión, el salto) lo dibuja
## la capa CapaSustos. Cada susto sube el miedo.

const Ajustes := preload("res://scripts/ajustes.gd")
const SILUETAS := [
    ["res://assets/visual/enemies/peregrino.png", 48, 64],
    ["res://assets/visual/enemies/vigia.png", 64, 96],
    ["res://assets/visual/enemies/ghoul.png", 48, 64],
]
const CARA := "res://assets/visual/enemies/vigia.png" # el salto: la Vigía de frente

## Segundos de calma: primero, entre sustos y entre saltos.
const CALMA_INICIAL := Vector2(25.0, 40.0)
const CALMA := Vector2(40.0, 85.0)
const CALMA_SALTO := 300.0
const DURA_SALTO := 0.75

var juego: Node2D
var capa: Control

var _espera: float = 0.0
var _desde_salto: float = 999.0
var _saltos_piso: int = 0
var _piso: int = -1
var _rng := RandomNumberGenerator.new()
var _bus: int = -1
var _panner: AudioEffectPanner
var _voz: AudioStreamPlayer
var _pendientes: Array = [] # sonidos programados: [t, clave, volumen, tono]

## Aparición en curso: {pos, t, dura, tipo («silueta»|«ojos»), tex, w, h, fuera}
var aparicion: Dictionary = {}
## Escrito en el muro: {texto, pos, t}
var escrito: Dictionary = {}


func _ready() -> void:
    _rng.randomize()
    _espera = _rng.randf_range(CALMA_INICIAL.x, CALMA_INICIAL.y)
    # Un bus propio con panorámica: así los sonidos suenan de un lado.
    _bus = AudioServer.get_bus_index("Sustos")
    if _bus == -1:
        AudioServer.add_bus()
        _bus = AudioServer.bus_count - 1
        AudioServer.set_bus_name(_bus, "Sustos")
        AudioServer.set_bus_send(_bus, "Efectos" if AudioServer.get_bus_index("Efectos") != -1 else "Master")
        AudioServer.add_bus_effect(_bus, AudioEffectPanner.new())
    _panner = AudioServer.get_bus_effect(_bus, 0) as AudioEffectPanner
    _voz = AudioStreamPlayer.new()
    _voz.bus = "Sustos"
    add_child(_voz)


func iniciar(j: Node2D, c: Control) -> void:
    juego = j
    capa = c
    capa.sustos = self


## ¿Puede haber un susto ahora?
func _tranquilo() -> bool:
    if juego.game_mode != "play" or juego.in_tutorial:
        return false
    if juego.gaze_active or juego.colossus_active or juego.elder_active:
        return false
    if juego.current_floor == 0 and juego.current_room == 0:
        return false # la primera sala del juego, en paz
    return true


func sala_nueva() -> void:

    aparicion = {}
    escrito = {}
    if juego != null and juego.current_floor != _piso:
        _piso = juego.current_floor
        _saltos_piso = 0


func actualizar(delta: float) -> void:
    _desde_salto += delta
    _sonidos_pendientes(delta)
    if not aparicion.is_empty():
        _actualizar_aparicion(delta)
    if not escrito.is_empty():
        escrito["t"] = float(escrito["t"]) + delta
        if float(escrito["t"]) > 5.5:
            escrito = {}
    if not _tranquilo():
        return
    _espera -= delta
    if _espera > 0.0:
        return
    _espera = _rng.randf_range(CALMA.x, CALMA.y)
    lanzar(_elegir())


func _elegir() -> String:
    var opciones := {"aparicion": 35, "espalda": 30, "interfaz": 25}
    if _salto_permitido():
        opciones["salto"] = 12
    var total := 0
    for k in opciones:
        total += int(opciones[k])
    var r := _rng.randi_range(1, total)
    for k in opciones:
        r -= int(opciones[k])
        if r <= 0:
            return k
    return "espalda"


func _salto_permitido() -> bool:
    return bool(Ajustes.obtener("sustos_repentinos", true)) and juego.current_floor >= 1 \
        and _saltos_piso == 0 and _desde_salto > CALMA_SALTO


## Lanza un susto concreto (también lo usan las pruebas).
func lanzar(tipo: String) -> void:
    match tipo:
        "aparicion":
            _aparicion()
        "espalda":
            _espalda()
        "interfaz":
            match _rng.randi_range(0, 2):
                0:
                    apagon()
                1:
                    distorsion()
                _:
                    _escribir_en_muro()
        "salto":
            salto()
        "apagon":
            apagon()
        "distorsion":
            distorsion()
        "muro":
            _escribir_en_muro()


func _miedo(cuanto: float) -> void:
    juego.fear = minf(100.0, juego.fear + cuanto)


# ---------------------------------------------------------------- aparición

func _aparicion() -> void:
    var arena: Rect2 = juego.ARENA
    var lejos: float = 240.0 if juego.torch_on else 150.0
    var punto := Vector2.ZERO
    for intento in range(24):
        var p := Vector2(_rng.randf_range(arena.position.x + 40.0, arena.end.x - 40.0), _rng.randf_range(arena.position.y + 70.0, arena.end.y - 30.0))
        if p.distance_to(juego.player_pos) > lejos and p.distance_to(juego.player_pos) < 520.0:
            punto = p
            break
    if punto == Vector2.ZERO:
        _espalda() # sala demasiado pequeña o iluminada: mejor un sonido
        return
    var s: Array = SILUETAS[_rng.randi_range(0, SILUETAS.size() - 1)]
    aparicion = {"pos": punto, "t": 0.0, "dura": _rng.randf_range(2.2, 3.4), "tipo": "ojos" if _rng.randf() < 0.4 else "silueta",
        "tex": load(s[0]), "w": s[1], "h": s[2], "fuera": -1.0}
    _miedo(6.0)


func _actualizar_aparicion(delta: float) -> void:
    aparicion["t"] = float(aparicion["t"]) + delta
    var fuera: float = float(aparicion["fuera"])
    if fuera >= 0.0:
        aparicion["fuera"] = fuera + delta
        if fuera > 0.25:
            aparicion = {}
        return
    var cerca: float = 205.0 if juego.torch_on else 110.0
    var pos: Vector2 = aparicion["pos"]
    # La luz la alcanza, o ya se le acabó el tiempo: se va (rápido si la iluminas).
    if juego.player_pos.distance_to(pos) < cerca * 0.9:
        aparicion["fuera"] = 0.0
        _sonar("ojo", -16.0, 0.55, _lado_de(pos))
        _miedo(4.0)
    elif float(aparicion["t"]) > float(aparicion["dura"]):
        aparicion["fuera"] = 0.0


## Llamado por la campaña tras la penumbra, con la transformación del mundo.
func dibujar_mundo(c: CanvasItem) -> void:
    if not aparicion.is_empty():
        _dibujar_aparicion(c)
    if not escrito.is_empty():
        _dibujar_escrito(c)


func _dibujar_aparicion(c: CanvasItem) -> void:
    var t: float = float(aparicion["t"])
    var a: float = clampf(t / 0.8, 0.0, 1.0)
    var fuera: float = float(aparicion["fuera"])
    if fuera >= 0.0:
        a *= clampf(1.0 - fuera / 0.25, 0.0, 1.0)
    var pos: Vector2 = aparicion["pos"]
    var w: float = float(aparicion["w"])
    var h: float = float(aparicion["h"])
    if aparicion["tipo"] == "silueta":
        # La silueta: el sprite de frente, en negro, con un temblor leve.
        var tiembla := Vector2(sin(t * 31.0) * 0.6, 0.0)
        var r := Rect2(pos - Vector2(w * 0.5, h) + tiembla, Vector2(w, h))
        c.draw_texture_rect_region(aparicion["tex"], r, Rect2(0, 0, w, h), Color(0.0, 0.0, 0.0, 0.82 * a))
        var ojos: Vector2 = pos + Vector2(0.0, -h * 0.78)
        _ojos(c, ojos, 4.0, a)
    else:
        # Solo ojos que parpadean despacio.
        var parpado: float = 1.0 if fmod(t, 1.7) > 0.12 else 0.0
        _ojos(c, pos + Vector2(0.0, -30.0), 6.0, a * parpado)


func _ojos(c: CanvasItem, centro: Vector2, sep: float, a: float) -> void:
    for lado in [-1.0, 1.0]:
        var p: Vector2 = centro + Vector2(sep * lado, 0.0)
        c.draw_circle(p, 3.2, Color(0.9, 0.1, 0.12, 0.25 * a))
        c.draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), Color(1.0, 0.85, 0.8, 0.95 * a))


# ------------------------------------------------------------- a tu espalda

## Lado contrario al que mira el personaje: -1 izquierda, 1 derecha.
func _lado_espalda() -> float:
    var d: Vector2 = juego.player_dir
    if absf(d.x) > 0.3:
        return -signf(d.x)
    return -1.0 if _rng.randf() < 0.5 else 1.0


func _lado_de(p: Vector2) -> float:
    return clampf((p.x - juego.player_pos.x) / 300.0, -1.0, 1.0)


func _espalda() -> void:
    var lado := _lado_espalda() * 0.85
    match _rng.randi_range(0, 2):
        0: # pasos que se acercan y paran
            for i in range(4):
                _programar(0.42 * float(i) - 0.04 * float(i * i), "k_paso", -20.0 + float(i) * 3.0, 0.8, lado)
        1: # un golpe seco contra la piedra
            _programar(0.0, "k_piedra", -10.0, 0.6, lado)
            _programar(0.05, "impacto", -16.0, 0.5, lado)
        _: # algo que se arrastra
            _programar(0.0, "raices", -14.0, 0.55, lado)
            _programar(0.6, "hilo", -18.0, 0.45, lado)
    _miedo(5.0)


func _programar(t: float, clave: String, vol: float, tono: float, lado: float) -> void:
    _pendientes.append([t, clave, vol, tono, lado])


func _sonidos_pendientes(delta: float) -> void:
    for i in range(_pendientes.size() - 1, -1, -1):
        _pendientes[i][0] = float(_pendientes[i][0]) - delta
        if float(_pendientes[i][0]) <= 0.0:
            var p: Array = _pendientes[i]
            _pendientes.remove_at(i)
            _sonar(str(p[1]), float(p[2]), float(p[3]), float(p[4]))


## Suena por el bus de los sustos, hacia un lado (-1 izquierda … 1 derecha).
## Una voz nueva cada vez: así no se cortan entre sí.
func _sonar(clave: String, vol: float, tono: float, lado: float) -> void:
    var flujos: Dictionary = juego.sfx_streams
    var k: String = "paso" if clave == "k_paso" else clave
    var flujo = flujos.get(k, null)
    if flujo == null:
        return
    if flujo is Array:
        flujo = flujo[_rng.randi_range(0, flujo.size() - 1)]
    if _panner != null:
        _panner.pan = lado
    var v := AudioStreamPlayer.new()
    v.bus = "Sustos"
    v.stream = flujo
    v.volume_db = vol
    v.pitch_scale = tono * _rng.randf_range(0.95, 1.05)
    add_child(v)
    v.finished.connect(v.queue_free)
    v.play()


# ---------------------------------------------------------------- interfaz

func apagon() -> void:
    capa.apagon()
    juego._sfx("apagar", -8.0, 0.7)
    _miedo(5.0)


func distorsion() -> void:
    capa.distorsion(0.55, 0.7)
    _sonar("resonancia", -14.0, 0.5, 0.0)
    _miedo(5.0)


const ESCRITOS := ["{yo}", "TE VEO, {yo}", "NO {ERES EL PRIMERO|ERES LA PRIMERA}", "VUELVE", "SIGUES AQUÍ", "DETRÁS"]


func _escribir_en_muro() -> void:
    var arena: Rect2 = juego.ARENA
    # _personal traduce y pone el nombre ({yo}) y el género ({masculino|femenino}).
    var t: String = juego._personal(ESCRITOS[_rng.randi_range(0, ESCRITOS.size() - 1)])
    escrito = {"texto": t, "pos": Vector2(_rng.randf_range(arena.position.x + 120.0, arena.end.x - 120.0), arena.position.y + 34.0), "t": 0.0}
    _sonar("latigo", -20.0, 0.5, _lado_de(escrito["pos"]))
    _miedo(5.0)


func _dibujar_escrito(c: CanvasItem) -> void:
    var t: float = float(escrito["t"])
    var a: float = clampf(t / 1.2, 0.0, 1.0) * clampf((5.5 - t) / 1.2, 0.0, 1.0)
    var texto: String = escrito["texto"]
    var pos: Vector2 = escrito["pos"]
    var fuente: Font = juego.font
    var ancho: float = fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
    var base := pos - Vector2(ancho * 0.5, 0.0)
    # Letras de sangre que gotean.
    c.draw_string(fuente, base + Vector2(1, 1), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0, 0, 0, 0.6 * a))
    c.draw_string(fuente, base, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.55, 0.04, 0.07, 0.9 * a))
    var gotas: int = mini(texto.length(), 6)
    for i in range(gotas):
        var x: float = base.x + ancho * (float(i) + 0.5) / float(gotas)
        var largo: float = clampf(t * 6.0 - float(i), 0.0, 10.0 + float(i % 3) * 4.0)
        c.draw_line(Vector2(x, pos.y + 4.0), Vector2(x, pos.y + 4.0 + largo), Color(0.5, 0.03, 0.06, 0.8 * a), 1.5)


# ---------------------------------------------------------------- repentino

func salto() -> void:
    _saltos_piso += 1
    _desde_salto = 0.0
    capa.salto(load(CARA), DURA_SALTO)
    juego._sfx("grunido", -2.0, 0.6)
    juego._sfx("impacto", -2.0, 0.7)
    _sonar("ojo", -6.0, 0.45, 0.0)
    juego.shake = maxf(float(juego.shake), 0.9)
    _miedo(18.0)
