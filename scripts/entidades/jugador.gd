extends Node2D
## El jugador: dónde está, hacia dónde mira y cómo se mueve.
##
## Su máquina de estados («Maquina», scripts/comun/maquina_estados.gd) tiene
## tres estados: Quieto, Camina y Esquiva. Cada uno decide la velocidad del
## cuadro (inercia corta al andar, impulso que se frena al esquivar); aquí se
## aplica el movimiento con las colisiones de la sala, se dejan las siluetas
## del esquive y se cuentan los pasos.
##
## Una segunda máquina, «Salud», lleva Vivo, Herido (invulnerable un
## momento tras un golpe) y Muerto. El jugador guarda su vida, vida máxima,
## vigor y miedo; herir() aplica un golpe y avisa con «herido», y morir()
## avisa con «muerto».
##
## La campaña (main.gd) llama a avanzar() cada cuadro de juego con el eje de
## los controles y la velocidad de paso (que cambia con Ecos y equipo), y
## escucha las señales para el sonido, las partículas y el desenlace. Las
## reglas que dependen de la partida (regeneración, Ecos, equipo) y el dibujo
## siguen en main.gd por ahora (docs/ARQUITECTURA.md, fase 3).
##
## position es la posición de los pies en coordenadas de la sala.

## Un paso: suena y levanta polvo.
signal paso(en: Vector2, esquivando: bool)
## Choca de frente contra un objeto sólido.
signal choque(en: Vector2)
## Recibe un golpe (ya aplicado a la vida).
signal herido(cantidad: float)
## Se queda sin vida y la campaña lo da por muerto.
signal muerto

const ESQUIVA_TIEMPO := 0.22
const ESQUIVA_PICO := 640.0 # el esquive arranca rápido…
const ESQUIVA_FIN := 170.0 # …y se frena hasta el paso normal
const ACELERACION := 1500.0 # px/s²: a toda velocidad en una décima
const FRENADA := 2100.0
const MOVIENDOSE := 12.0 # px/s: por debajo se considera quieto
const VIDA_SILUETA := 0.22
const CHOQUE_TIEMPO := 0.35

var direccion: Vector2 = Vector2.RIGHT
var velocidad: Vector2 = Vector2.ZERO
var moviendose: bool = false
var esquiva_t: float = 0.0 # tiempo de esquive que queda
var esquiva_dir: Vector2 = Vector2.RIGHT
var siluetas: Array = [] # {pos, dir, t}: lo que deja el esquive
var silueta_t: float = 0.0
var paso_t: float = 0.0
var paso_i: int = 0
var choque_t: float = 0.0 # polvo del choque que queda
var choque_en: Vector2 = Vector2.ZERO

var vida: float = 100.0 # puede pasar del máximo (vida extra)
var vida_max: float = 100.0
var vigor: float = 100.0
var miedo: float = 0.0 # 0..100
var invulnerable_t: float = 0.0 # tras un golpe no se recibe otro
var _golpe_t: float = 99.0 # tiempo desde el último golpe recibido (retroceso del dibujo)

## ¿Se puede estar en ese punto? / ¿Ese punto toca un objeto (no un muro)?
var _bloqueado: Callable = func(_en: Vector2) -> bool: return false
var _choca: Callable = func(_en: Vector2) -> bool: return false

@onready var maquina: Node = $Maquina
@onready var salud: Node = $Salud


func _ready() -> void:
    position = Vector2(120, 355)
    maquina.cambiar_a(&"Quieto")
    salud.cambiar_a(&"Vivo")


func estado_salud() -> StringName:
    return salud.nombre_actual()


## Un golpe: resta vida, suma miedo y, si «invulnerable» ≥ 0, deja al jugador
## a salvo de otro golpe ese tiempo. Avisa con «herido».
func herir(cantidad: float, miedo_extra: float = 0.0, invulnerable: float = -1.0) -> void:
    vida -= cantidad
    if miedo_extra != 0.0:
        miedo = minf(100.0, miedo + miedo_extra)
    if invulnerable >= 0.0:
        invulnerable_t = invulnerable
    _golpe_t = 0.0
    if estado_salud() != &"Muerto":
        salud.cambiar_a(&"Herido" if invulnerable_t > 0.0 else &"Vivo")
    herido.emit(cantidad)


## Sin vida: la campaña decide antes si algo lo salva (Huesos firmes).
func morir() -> void:
    salud.cambiar_a(&"Muerto")
    muerto.emit()


func _actualizar_salud(dt: float) -> void:
    invulnerable_t = maxf(0.0, invulnerable_t - dt)
    _golpe_t += dt
    var quiere: StringName = &"Vivo"
    if estado_salud() == &"Muerto" and vida <= 0.0:
        quiere = &"Muerto"
    elif invulnerable_t > 0.0:
        quiere = &"Herido"
    if quiere != estado_salud():
        salud.cambiar_a(quiere)


## La sala dice dónde no se puede pisar.
func preparar(bloqueado: Callable, choca: Callable) -> void:
    _bloqueado = bloqueado
    _choca = choca


func estado() -> StringName:
    return maquina.nombre_actual()


## Para en seco (al entrar en una sala).
func detener() -> void:
    velocidad = Vector2.ZERO
    siluetas.clear()


func esquivar(hacia: Vector2) -> void:
    esquiva_dir = hacia
    esquiva_t = ESQUIVA_TIEMPO


## Un cuadro de juego. «eje»: controles (longitud ≤ 1); «paso»: velocidad al
## andar en px/s.
func avanzar(dt: float, eje: Vector2, paso_vel: float) -> void:
    _actualizar_salud(dt)
    esquiva_t = maxf(0.0, esquiva_t - dt)
    for s in siluetas:
        s["t"] = float(s["t"]) + dt
    siluetas = siluetas.filter(func(s): return float(s["t"]) < VIDA_SILUETA)
    var quiere: StringName = &"Esquiva" if esquiva_t > 0.0 else (&"Camina" if eje.length_squared() > 0.001 else &"Quieto")
    if quiere != estado():
        maquina.cambiar_a(quiere)
    maquina.estado.call("mover", self, dt, eje, paso_vel)
    moviendose = velocidad.length() > MOVIENDOSE
    if moviendose:
        _desplazar(dt, eje, paso_vel)
    else:
        paso_t = 0.06


func _desplazar(dt: float, eje: Vector2, paso_vel: float) -> void:
    var nx := Vector2(position.x + velocidad.x * dt, position.y)
    var choca_x: bool = absf(velocidad.x) > paso_vel * 0.3 and bool(_choca.call(nx))
    if not bool(_bloqueado.call(nx)):
        position.x = nx.x
    else:
        velocidad.x = 0.0
    var ny := Vector2(position.x, position.y + velocidad.y * dt)
    var choca_y: bool = absf(velocidad.y) > paso_vel * 0.3 and bool(_choca.call(ny))
    if not bool(_bloqueado.call(ny)):
        position.y = ny.y
    else:
        velocidad.y = 0.0
    if esquiva_t > 0.0:
        silueta_t -= dt
        if silueta_t <= 0.0:
            silueta_t = 0.035
            siluetas.append({"pos": position, "dir": direccion, "t": 0.0})
    if (choca_x or choca_y) and choque_t <= 0.0:
        choque_t = CHOQUE_TIEMPO
        choque_en = position + Vector2(signf(eje.x) * 10.0 if choca_x else 0.0, 2.0)
        choque.emit(choque_en)
    # Pasos: más rápidos al esquivar.
    paso_t -= dt
    if paso_t <= 0.0:
        paso_t = 0.33 if esquiva_t <= 0.0 else 0.12
        paso_i += 1
        paso.emit(position, esquiva_t > 0.0)


# ------------------------------------------------------------ DIBUJO
## El jugador se dibuja sobre el lienzo del mundo en su turno del orden por
## profundidad. «ap» (apariencia) la prepara la campaña: hoja del héroe, t
## (tiempo de juego), muerto, interactua, arma, icono_arma, golpe (tiempo del
## tajo), antorcha (en la mano), antorcha_encendida, proteccion y puesto
## (casco, peto, botas, amuleto, brazalete, mascara) y hoja_botas (la capa
## de botas que sigue a cada cuadro de la hoja).
const Lienzo := preload("res://scripts/comun/lienzo.gd")
const ALMA := Color("#8fc7d7")
const ROJO := Color("#d06470")
const GEAR_STEEL := Color("#8d949a")
const GEAR_STEEL_DARK := Color("#4f565c")
const GEAR_STEEL_LIGHT := Color("#c9d0d4")
const GEAR_LEATHER := Color("#6e4630")
const GEAR_LEATHER_DARK := Color("#45291b")
const GEAR_GOLD := Color("#e3bd7b")
const MASK_WHITE := Color("#fbfaf6")
const MASK_SHADE := Color("#d9d6e0")
const MASK_RED := Color("#b0242f")
const GEAR_OUTLINE := Color("#140f12")


## Pequeños desplazamientos del dibujo (no de la posición real) que dan
## peso a las acciones: al golpear se adelanta y vuelve; al recibir un golpe
## retrocede y tiembla; al esquivar se agacha y se inclina hacia donde va.
const GOLPE_DURA := 0.25 # lo que dura strike_fx en main.gd


func _desvio(ap: Dictionary) -> Vector2:
    var d := Vector2.ZERO
    var golpe: float = float(ap.get("golpe", 0.0))
    if golpe > 0.0:
        var k: float = 1.0 - golpe / GOLPE_DURA # 0 → 1
        d += direccion.normalized() * 3.0 * sin(k * PI) - direccion.normalized() * 1.0 * clampf(1.0 - k * 4.0, 0.0, 1.0)
    if invulnerable_t > 0.0 and _golpe_t < 0.18:
        var k2: float = 1.0 - _golpe_t / 0.18
        d += -direccion.normalized() * 2.0 * k2 + Vector2(randf_range(-1.0, 1.0), 0.0) * k2
    if esquiva_t > 0.0:
        d += Vector2(0.0, 1.0) + esquiva_dir.normalized() * 1.5
    return d


func dibujar(c: CanvasItem, ap: Dictionary) -> void:
    var t: float = float(ap["t"])
    var muerto: bool = bool(ap["muerto"])
    var hoja: Texture2D = ap.get("hoja")
    ## [VISUAL UPGRADE] Spritesheet top-down, arte original y cuatro orientaciones.
    if ap.get("hoja") != null:
        var direction_index: int = 0 # frente/abajo
        if absf(direccion.x) > absf(direccion.y):
            direction_index = 2 if direccion.x > 0.0 else 3
        elif direccion.y < 0.0:
            direction_index = 1 # espalda/arriba
        var frame_index: int = int(t * 2.0) % 2 # Idle A/B
        if muerto:
            frame_index = 8
        elif invulnerable_t > 0.0:
            frame_index = 7
        elif bool(ap["interactua"]):
            frame_index = 6
        elif moviendose:
            # De frente y de espaldas, los cuadros 9–12 levantan cada pie
            # (herramientas/generar_pasos.py); de lado, los originales 2–5.
            var base_paso: int = 9 if direction_index <= 1 else 2
            frame_index = base_paso + (int(t * 8.0) % 4)
        var atlas := Rect2(float(frame_index * 40), float(direction_index * 56), 40.0, 56.0)
        var desvio: Vector2 = _desvio(ap)
        var location := Vector2(roundf(position.x + desvio.x) - 20.0, roundf(position.y + desvio.y) - 50.0)
        Lienzo.sombra(c, position + Vector2(0.0, 1.0), 15.0)
        for gh in siluetas:
            var gk: float = 1.0 - float(gh["t"]) / 0.22
            var gloc := Vector2(roundf(Vector2(gh["pos"]).x) - 20.0, roundf(Vector2(gh["pos"]).y) - 50.0)
            c.draw_texture_rect_region(hoja, Rect2(gloc, Vector2(40.0, 56.0)), Rect2(float(2 * 40), float(direction_index * 56), 40.0, 56.0), Color(0.55, 0.85, 1.0, 0.35 * gk))
        var blink: bool = invulnerable_t > 0.0 and int(t * 14.0) % 2 == 0
        # La antorcha va en la mano; de espaldas queda detrás del cuerpo.
        var hand: Vector2 = position + desvio.round() + [Vector2(12, -18), Vector2(-12, -20), Vector2(9, -19), Vector2(-9, -19)][direction_index]
        var in_hand_torch: bool = bool(ap["antorcha"]) and str(ap["arma"]) == ""
        if direction_index == 1 and not muerto:
            if str(ap["arma"]) != "":
                _dibujar_arma(c, hand, direction_index, ap)
            elif in_hand_torch:
                _dibujar_antorcha(c, hand, ap)
        Lienzo.contorno(c, hoja, Rect2(location, Vector2(40.0, 56.0)), atlas, Color(1, 1, 1, 0.35 if blink else 1.0))
        if not muerto:
            # Botas: una hoja con la misma rejilla que la del héroe, así siguen
            # cada cuadro de la animación (herramientas/generar_botas.py).
            if bool(ap["puesto"].get("botas", false)) and ap.get("hoja_botas") != null:
                c.draw_texture_rect_region(ap["hoja_botas"], Rect2(location, Vector2(40.0, 56.0)), atlas, Color(1, 1, 1, 0.35 if blink else 1.0))
            _dibujar_equipo(c, location, direction_index, 0.35 if blink else 1.0, ap["puesto"])
        if direction_index != 1 and not muerto:
            if str(ap["arma"]) != "":
                _dibujar_arma(c, hand, direction_index, ap)
            elif in_hand_torch:
                _dibujar_antorcha(c, hand, ap)
        if choque_t > 0.0:
            # Polvo del choque a ambos lados de los pies: el objeto es sólido.
            var k_choque: float = 1.0 - choque_t / 0.35
            for side in [-1.0, 1.0]:
                for i in range(3):
                    var p: Vector2 = choque_en + Vector2(side * (12.0 + k_choque * 10.0 + float(i) * 4.0), -float(i) * 3.0 - k_choque * 4.0)
                    c.draw_circle(p, 3.0 - k_choque * 1.6 - float(i) * 0.4, Color(0.84, 0.80, 0.66, 0.65 * (1.0 - k_choque)))
        if float(ap["proteccion"]) > 0.0:
            c.draw_arc(position, 27.0, 0.0, TAU, 40, ALMA, 2.0)
        if invulnerable_t > 0.0:
            c.draw_arc(position, 29.0, 0.0, TAU, 40, ROJO, 2.0)
        return
    if ap.get("marca") != null:
        var marca: Texture2D = ap["marca"]
        var frame: int = 0
        if moviendose:
            var tick: int = int(t * 9.0)
            if absf(direccion.x) > absf(direccion.y):
                frame = (10 + tick % 5) if direccion.x > 0.0 else (19 + tick % 5)
            else:
                frame = (6 + tick % 4) if direccion.y > 0.0 else (16 + tick % 4)
        c.draw_texture_rect_region(marca, Rect2(position.x - 15, position.y - 54, 30, 57), Rect2(frame * 24, 0, 24, 70))
        return
    if ap.get("figura") != null:
        c.draw_texture_rect(ap["figura"], Rect2(position.x - 20, position.y - 42, 40, 48), false)
        return
    var p := position
    c.draw_circle(p + Vector2(0, 18), 14.0, Color(0, 0, 0, 0.4))
    c.draw_colored_polygon(PackedVector2Array([
        p + Vector2(0, -19), p + Vector2(17, -4),
        p + Vector2(17, 20), p + Vector2(-16, 20), p + Vector2(-17, -3)
    ]), Color("#b9b8b3"))
    c.draw_circle(p + Vector2(0, -11), 11.5, Color("#d0cac0"))
    c.draw_line(p + Vector2(-3, -12), p + Vector2(3, -12), Color("#26272d"), 2)
    c.draw_line(p + Vector2(2, -1), p + Vector2(16, 8), Color("#a53e56"), 4.0)
    c.draw_line(p + Vector2(9, 5), p + Vector2(24, 15), Color("#a53e56"), 3.0)
    c.draw_line(p + Vector2(0, 0), p + direccion * 20.0, Color("#e9ddab"), 2.0)
    if float(ap["proteccion"]) > 0:
        c.draw_arc(p, 27.0, 0.0, TAU, 48, ALMA, 2.0)
    if invulnerable_t > 0:
        c.draw_arc(p, 29.0, 0.0, TAU, 28, ROJO, 2.0)


func _dibujar_antorcha(c: CanvasItem, hand: Vector2, ap: Dictionary) -> void:
    var torch_on: bool = bool(ap["antorcha_encendida"])
    var elapsed: float = float(ap["t"])
    var tip := hand + Vector2(0.0, -14.0)
    c.draw_line(hand + Vector2(0.0, 4.0), tip, Color("#5c3a22"), 3.0)
    c.draw_line(hand + Vector2(-1.0, 3.0), tip + Vector2(-1.0, 1.0), Color("#8a5a35"), 1.0)
    c.draw_rect(Rect2(tip.x - 3.0, tip.y - 1.0, 6.0, 4.0), Color("#d9cfb0"))
    if not torch_on:
        c.draw_rect(Rect2(tip.x - 2.0, tip.y - 3.0, 4.0, 2.0), Color("#3a2f2a"))
        return
    var f: float = sin(elapsed * 17.0) * 1.2
    c.draw_circle(tip + Vector2(0.0, -10.0), 16.0, Color(1.0, 0.7, 0.3, 0.10))
    c.draw_colored_polygon(PackedVector2Array([tip + Vector2(-5, -1), tip + Vector2(5, -1), tip + Vector2(2, -9), tip + Vector2(f, -15), tip + Vector2(-3, -8)]), Color("#c2412f"))
    c.draw_colored_polygon(PackedVector2Array([tip + Vector2(-3, -1), tip + Vector2(3, -1), tip + Vector2(f * 0.6, -11)]), Color("#f08a3a"))
    c.draw_colored_polygon(PackedVector2Array([tip + Vector2(-1.5, -1), tip + Vector2(1.5, -1), tip + Vector2(0, -6)]), Color("#ffd36b"))


## Píxel del equipo (sobre la celda de 40 × 56 del héroe).
func _px(c: CanvasItem, loc: Vector2, x: float, y: float, w: float, h: float, col: Color) -> void:
    c.draw_rect(Rect2(loc + Vector2(x, y), Vector2(w, h)), col)


func _dibujar_equipo(c: CanvasItem, loc: Vector2, dir: int, a: float, puesto: Dictionary) -> void:
    var side: bool = dir >= 2
    var left: bool = dir == 3
    var steel := Color(GEAR_STEEL, a)
    var dark := Color(GEAR_STEEL_DARK, a)
    var light := Color(GEAR_STEEL_LIGHT, a)
    var ol := Color(GEAR_OUTLINE, a)
    # Las botas no van aquí: se dibujan con su hoja en dibujar().
    # Peto: placa sobre el torso, con hombreras.
    if bool(puesto.get("peto", false)):
        if side:
            _px(c, loc, 14, 25, 13, 15, ol)
            _px(c, loc, 15, 26, 11, 13, steel)
            _px(c, loc, 15, 26, 11, 2, light)
            _px(c, loc, 15, 32, 11, 1, dark)
        else:
            _px(c, loc, 10, 24, 21, 16, ol)
            _px(c, loc, 11, 25, 19, 14, steel)
            _px(c, loc, 11, 25, 19, 2, light)
            _px(c, loc, 20, 27, 1, 12, dark)
            _px(c, loc, 11, 32, 19, 1, dark)
            _px(c, loc, 7, 24, 5, 5, Color(GEAR_LEATHER, a))
            _px(c, loc, 29, 24, 5, 5, Color(GEAR_LEATHER, a))
    # Amuleto de hueso: cadena y colgante sobre el pecho.
    if bool(puesto.get("amuleto", false)) and dir != 1:
        var chain := Color(GEAR_GOLD, a)
        if side:
            var cx: float = 23.0 if not left else 17.0
            _px(c, loc, cx, 25, 1, 4, chain)
            _px(c, loc, cx - 1.0, 29, 3, 3, Color("#d8f0dc", a))
        else:
            _px(c, loc, 15, 24, 2, 1, chain)
            _px(c, loc, 16, 25, 2, 1, chain)
            _px(c, loc, 17, 26, 2, 1, chain)
            _px(c, loc, 23, 24, 2, 1, chain)
            _px(c, loc, 22, 25, 2, 1, chain)
            _px(c, loc, 21, 26, 2, 1, chain)
            _px(c, loc, 19, 27, 3, 4, Color("#d8f0dc", a))
            _px(c, loc, 20, 28, 1, 2, Color("#5f8f6a", a))
    # Brazalete: aro dorado en la muñeca.
    if bool(puesto.get("brazalete", false)):
        var band := Color(GEAR_GOLD, a)
        match dir:
            0: _px(c, loc, 30, 35, 4, 2, band)
            1: _px(c, loc, 6, 35, 4, 2, band)
            2: _px(c, loc, 24, 36, 4, 2, band)
            3: _px(c, loc, 12, 36, 4, 2, band)
    # Máscara de porcelana: tapa el rostro (de espaldas, solo la cinta).
    if bool(puesto.get("mascara", false)):
        var w := Color(MASK_WHITE, a)
        var sh := Color(MASK_SHADE, a)
        var eye := Color(0.05, 0.04, 0.06, a)
        match dir:
            0:
                _px(c, loc, 12, 7, 17, 17, ol)
                _px(c, loc, 13, 8, 15, 15, w)
                _px(c, loc, 13, 19, 15, 4, sh)
                _px(c, loc, 14, 12, 5, 3, eye) # cuencas vacías
                _px(c, loc, 22, 12, 5, 3, eye)
                _px(c, loc, 15, 15, 1, 3, Color(MASK_RED, a)) # lágrimas pintadas
                _px(c, loc, 25, 15, 1, 3, Color(MASK_RED, a))
                _px(c, loc, 18, 19, 5, 1, Color(MASK_RED, a)) # boca
                _px(c, loc, 21, 8, 1, 4, ol) # grieta
            1:
                _px(c, loc, 10, 14, 21, 1, Color(0.3, 0.12, 0.1, a))
            2:
                _px(c, loc, 20, 7, 12, 17, ol)
                _px(c, loc, 21, 8, 10, 15, w)
                _px(c, loc, 21, 19, 10, 4, sh)
                _px(c, loc, 25, 12, 4, 3, eye)
                _px(c, loc, 27, 15, 1, 3, Color(MASK_RED, a))
                _px(c, loc, 26, 19, 4, 1, Color(MASK_RED, a))
            3:
                _px(c, loc, 8, 7, 12, 17, ol)
                _px(c, loc, 9, 8, 10, 15, w)
                _px(c, loc, 9, 19, 10, 4, sh)
                _px(c, loc, 11, 12, 4, 3, eye)
                _px(c, loc, 12, 15, 1, 3, Color(MASK_RED, a))
                _px(c, loc, 10, 19, 4, 1, Color(MASK_RED, a))
    # Yelmo: casco de hierro sobre el pelo, con cresta roja.
    if bool(puesto.get("casco", false)):
        var hx: float = 10.0 if not side else (11.0 if not left else 9.0)
        var hw: float = 21.0 if not side else 20.0
        # Cúpula redondeada: las filas de arriba son más estrechas.
        _px(c, loc, hx + 2.0, -1, hw - 4.0, 2, ol)
        _px(c, loc, hx - 1.0, 1, hw + 2.0, 11, ol)
        _px(c, loc, hx + 3.0, 0, hw - 6.0, 1, steel)
        _px(c, loc, hx + 1.0, 1, hw - 2.0, 1, steel)
        _px(c, loc, hx, 2, hw, 9, steel)
        _px(c, loc, hx + 3.0, 1, hw - 8.0, 2, light)
        _px(c, loc, hx + 1.0, 3, 2, 5, light)
        _px(c, loc, hx, 9, hw, 2, dark)
        for rv in range(3):
            _px(c, loc, hx + 3.0 + float(rv) * (hw - 6.0) * 0.5, 10, 1, 1, light) # remaches
        _px(c, loc, hx + hw * 0.5 - 1.0, -4, 3, 4, Color(0.75, 0.2, 0.18, a))
        if dir == 0:
            _px(c, loc, 19, 11, 3, 5, dark) # nasal
        elif side:
            _px(c, loc, (27.0 if not left else 12.0), 11, 2, 4, dark)


func _dibujar_arma(c: CanvasItem, hand: Vector2, dir: int, ap: Dictionary) -> void:
    var weapon: String = str(ap["arma"])
    var tex: Texture2D = ap.get("icono_arma")
    var strike_fx: float = float(ap["golpe"])
    if tex == null:
        return
    var base_angle: float = [0.35, -0.35, 0.15, -0.15][dir]
    var flip: bool = dir == 3 or dir == 1
    var swing: float = 0.0
    if strike_fx > 0.0:
        var k: float = 1.0 - strike_fx / 0.25
        swing = lerpf(-1.3, 1.1, k) * (-1.0 if flip else 1.0)
    var sz: float = 26.0 if weapon in ["daga"] else (34.0 if weapon in ["lanza", "hacha"] else 30.0)
    # El icono tiene la empuñadura abajo a la izquierda: se gira desde ahí.
    Lienzo.xf(c, hand, base_angle + swing, Vector2(-1.0 if flip else 1.0, 1.0))
    c.draw_texture_rect(tex, Rect2(Vector2(-sz * 0.2, -sz * 0.8), Vector2(sz, sz)), false)
    Lienzo.xf(c, Vector2.ZERO, 0.0, Vector2.ONE)
