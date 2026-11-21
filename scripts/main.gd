## [VISUAL UPGRADE]
extends Node2D
## Primer piso. Adaptación de los tres documentos GDD, Lore v0.2 y Reglas v0.1.
## Knowledge Temple + GothicVania reales incorporados desde los ZIP aportados.
## Mecánicas no canonizadas se indican como provisionales en docs/DECISIONES.md.

const W: float = 960.0
const H: float = 640.0
const ARENA: Rect2 = Rect2(40.0, 122.0, 880.0, 458.0)
const SAVE_PATH: String = "user://templo_personaje_v03.json"
const BRAND_ICON: Texture2D = preload("res://assets/branding/icon.svg")
## PISOS (docs: «DISEÑO DE 10 PISOS»). Cada sala usa una escena
## rooms/sala_N.tscn y declara qué contiene: entidad, rasgos (altar, sello,
## archivo…) y objetos. El código pregunta por rasgos, nunca por números de sala.
##   enemy:  "" | "ghoul" | "testigo" | "hechicero" | "segador"
##   traits: "tutorial", "altar", "sello", "archivo", "almas" (la puerta exige
##           reunir las almas), "peregrino" (aparece el Peregrino), "cosecha",
##           "aliados" (se unen tres peregrinos), "caza" (la puerta no se abre
##           mientras viva la presa), "huida" (la presa escapa a media vida),
##           "recuento" (premio por los aliados que siguen vivos)
##   items:  [clave, marcador, posición por defecto]
##   mission (opcional): {goal: "desterrar" | "ahuyentar", required, reward, text}
##           Misión de la sala: si es obligatoria, la puerta no se abre sin ella.
##   traps (opcional): posiciones de trampas de pinchos (ciclo con aviso).
##   inscription (opcional): [posición, texto] que se lee al acercarse.
const FLOORS := [
    {
        "number": "I", "title": "EL DESPERTAR", "state": "TEMPLO CONSERVADO", "wear": 0.0,
        "eco": "respiracion",
        "rooms": [
            {"scene": 0, "name": "I · UMBRAL DEL DESPERTAR", "enemy": "", "traits": ["tutorial"],
             "whisper": "Una inscripción dice: 'La esperanza es parte del mecanismo'.",
             "items": [["madera", "Madera", Vector2(300, 470)], ["fosforos", "Fosforos", Vector2(660, 470)]]},
            {"scene": 1, "name": "II · CLAUSTRO DE LAS OFRENDAS", "enemy": "ghoul", "traits": ["altar"],
             "whisper": "Las piedras tienen marcas de quienes estuvieron antes que tú.", "items": [],
             "mission": {"goal": "desterrar", "required": true, "reward": 8, "text": "Destierra al Ghoul de brasas"}},
            {"scene": 2, "name": "III · SALA DEL TESTIGO", "enemy": "testigo", "traits": ["sello"],
             "whisper": "No todos los ojos necesitan luz para verte.",
             "items": [["fosforos", "Fosforos", Vector2(250, 470)]],
             "mission": {"goal": "desterrar", "required": false, "reward": 12, "text": "Destierra al Testigo"}},
            {"scene": 3, "name": "IV · ARCHIVO DE LOS AUSENTES", "enemy": "hechicero", "traits": ["archivo"],
             "whisper": "Algunas cartas parecen escritas por personas que regresaron.",
             "items": [["fosforos", "Fosforos", Vector2(230, 460)]],
             "mission": {"goal": "desterrar", "required": true, "reward": 10, "text": "Destierra al Hechicero del archivo"}},
            {"scene": 4, "name": "V · PÓRTICO DEL SIGUIENTE PISO", "enemy": "", "traits": [],
             "whisper": "Esto no es una salida. Es una transición.", "items": [],
             "traps": [Vector2(350, 350), Vector2(610, 350), Vector2(290, 500), Vector2(670, 500)],
             "inscription": [Vector2(480, 300), "Los que cruzaron antes dejaron sus nombres en la piedra. Ninguno dejó una salida."]},
        ],
    },
    {
        # Inspiración: la traición durante la recolección de almas.
        "number": "II", "title": "LOS PEREGRINOS", "state": "PRIMERAS GRIETAS", "wear": 1.0,
        "eco": "nuca",
        "rooms": [
            {"scene": 0, "name": "I · ATRIO DE LOS PEREGRINOS", "enemy": "", "traits": ["almas", "peregrino"],
             "whisper": "Alguien más respira en la oscuridad.", "items": []},
            {"scene": 2, "name": "II · NAVE DEL AGUA", "enemy": "", "traits": ["almas"],
             "whisper": "El agua corre hacia abajo. Las almas también.",
             "items": [["fosforos", "Fosforos", Vector2(250, 470)]],
             "traps": [Vector2(320, 380), Vector2(640, 380), Vector2(380, 470), Vector2(580, 470)],
             "inscription": [Vector2(330, 182), "El agua baja. Las almas también. Todo baja hacia algo que tiene hambre."]},
            {"scene": 4, "name": "III · CRIPTA DEL REPARTO", "enemy": "", "traits": ["almas", "cosecha"],
             "whisper": "Aquí se reparte lo reunido. Siempre sobra alguien.", "items": []},
            {"scene": 3, "name": "IV · UMBRAL DEL TERCER PISO", "enemy": "", "traits": [],
             "whisper": "Nadie llega a esta puerta acompañado.", "items": []},
        ],
    },
    {
        # Inspiración: la misión «matar al rápido», en grupo y con bajas.
        "number": "III", "title": "LA CACERÍA", "state": "EL TEMPLO TIENE HAMBRE", "wear": 1.5,
        "eco": "reflejos",
        "rooms": [
            {"scene": 1, "name": "I · CLAUSTRO DEL ENCARGO", "enemy": "", "traits": ["aliados"],
             "whisper": "Una voz sin boca: «Cazad al rápido. Solo entonces bajaréis».",
             "items": [["fosforos", "Fosforos", Vector2(250, 470)]],
             "inscription": [Vector2(330, 182), "La caza es una ofrenda. El cazador, también."]},
            {"scene": 2, "name": "II · NAVE DE LOS HILOS", "enemy": "segador", "traits": ["caza", "huida"],
             "whisper": "Algo cruza la nave más rápido que tu luz.", "items": [],
             "mission": {"goal": "ahuyentar", "required": true, "reward": 6, "text": "Hiere al Segador hasta que huya"}},
            {"scene": 3, "name": "III · CORO DESGARRADO", "enemy": "segador", "traits": ["caza"],
             "whisper": "Hilos rojos cuelgan de cada columna. Siguen tensos.",
             "items": [["fosforos", "Fosforos", Vector2(230, 460)]],
             "traps": [Vector2(330, 455), Vector2(630, 455), Vector2(250, 320), Vector2(710, 320)],
             "mission": {"goal": "desterrar", "required": true, "reward": 15, "text": "Mata al Segador de Hilos"}},
            {"scene": 4, "name": "IV · UMBRAL DEL CUARTO PISO", "enemy": "", "traits": ["recuento"],
             "whisper": "Los que siguen vivos cuentan los pasos de los que no.", "items": []},
        ],
    },
]

const RELICS := [
    Vector2(280, 245), Vector2(500, 465), Vector2(725, 230)
]
## Objetos interactivos. Las posiciones de dibujo y de interacción comparten
## constante para que lo que se ve coincida con donde se pulsa E.
const SEAL_POS := Vector2(704, 343)
const ALTAR_POS := Vector2(488, 318) # delante de la estatua central del claustro
const BOOK_POS := Vector2(497, 310) # sobre la mesa del archivo (base del libro)
const ARCHIVE_POS := Vector2(497, 362) # frente a la mesa, donde se lee
const EYE_POS := Vector2(690, 143) # ojo tallado en el muro del fondo
const DOOR_POS := Vector2(867, 355)
## Enemigos: hojas originales de 48x64 por celda, pies en y=61.
## Filas: 0 abajo, 1 arriba, 2 derecha, 3 izquierda.
const ENEMY_CELL := Vector2(48.0, 64.0)
const ENEMY_FEET_Y := 61.0
## Salas editables: TileMapLayer + objetos + marcadores + colisiones.
## Se generaron con herramientas/construir_salas.*; desde entonces se editan en Godot.
## Inventario y habilidades: iconos originales (herramientas/generar_iconos.py).
const ICONS := {
    "madera": preload("res://assets/visual/iconos/madera.png"),
    "fosforos": preload("res://assets/visual/iconos/fosforos.png"),
    "antorcha": preload("res://assets/visual/iconos/antorcha.png"),
    "antorcha_encendida": preload("res://assets/visual/iconos/antorcha_encendida.png"),
    "llama_interior": preload("res://assets/visual/iconos/llama_interior.png"),
    "resonancia": preload("res://assets/visual/iconos/resonancia.png"),
    "golpe": preload("res://assets/visual/iconos/golpe.png"),
    "alma": preload("res://assets/visual/iconos/alma.png"),
    "corazon": preload("res://assets/visual/iconos/corazon.png"),
    "vigor": preload("res://assets/visual/iconos/vigor.png"),
    "miedo": preload("res://assets/visual/iconos/miedo.png"),
    "eco_respiracion": preload("res://assets/visual/iconos/eco_respiracion.png"),
    "eco_nuca": preload("res://assets/visual/iconos/eco_nuca.png"),
    "eco_reflejos": preload("res://assets/visual/iconos/eco_reflejos.png"),
    "habilidades": preload("res://assets/visual/iconos/habilidades.png"),
    "pinchos": preload("res://assets/visual/iconos/pinchos.png"),
    "calavera": preload("res://assets/visual/iconos/calavera.png"),
    "pausa": preload("res://assets/visual/iconos/pausa.png"),
    "engranaje": preload("res://assets/visual/iconos/engranaje.png"),
}
## Retrato de Mark para el HUD y el perfil (herramientas/generar_retrato.py).
const DEFENSE_ICONS := {"descansar": preload("res://assets/visual/iconos/descansar.png")}
const PORTRAIT := preload("res://assets/visual/retratos/mark.png")
const PORTRAIT_HURT := preload("res://assets/visual/retratos/mark_herido.png")
## Variante femenina (creación de personaje): retratos y hoja de sprites.
const PORTRAIT_F := preload("res://assets/visual/retratos/femenina.png")
const PORTRAIT_F_HURT := preload("res://assets/visual/retratos/femenina_herida.png")
const HERO_SHEET_F := preload("res://assets/visual/protagonist_sheet_f.png")
## PROVISIONAL (petición del autor): mientras se prueban los pisos, morir no
## cuesta progreso. Reapareces en la entrada de la sala donde caíste con todo
## lo que llevabas: almas, objetos, habilidades, ecos y las almas ya recogidas
## de esa sala (no reaparecen, así que no se puede «cultivar» la muerte).
## En false vuelve la regla canónica: retorno o absorción al 50 %.
const MUERTE_SIN_PERDIDA := true
## Paleta del HUD (estilo roguelike de acción: paneles biselados y barras vivas).
const UI_PANEL := Color(0.055, 0.065, 0.085, 0.92)
const UI_EDGE := Color("#3c3f4c")
const UI_LIGHT := Color("#6b6f80")
const UI_GOLD := Color("#c6aa6e")
const BAR_HP := Color("#c8393f")
const BAR_VIGOR := Color("#4f9e78")
const BAR_FEAR := Color("#7a4aa3")
## Ecos: [nombre, descripción]. Se ganan al superar cada piso (clave "eco" del piso).
const ECOS := {
    "respiracion": ["RESPIRACIÓN CONTENIDA", "El miedo sube un 25 % más despacio."],
    "nuca": ["NUCA FRÍA", "Sientes cuando alguien con malas intenciones queda a tu espalda."],
    "reflejos": ["REFLEJOS", "Esquivar se recarga un 40 % antes."],
}
## Casillas del inventario: [clave, nombre, descripción].
const INVENTORY_SLOTS := [
    ["madera", "MADERA Y TELA", "El cuerpo de una antorcha. Con fósforos se construye sola."],
    ["fosforos", "FÓSFOROS", "Encender la antorcha gasta uno. Apagarla es gratis."],
    ["antorcha", "ANTORCHA", "F enciende o apaga. Encendida ilumina, atrae miradas y permite golpear."],
    ["llama_interior", "LLAMA INTERIOR", "Habilidad del altar: enciendes la antorcha sin gastar fósforos."],
    ["golpe", "GOLPE DE ANTORCHA", "Clic o E con la antorcha encendida: daño de fuego a corta distancia."],
    ["resonancia", "RESONANCIA", "Q: una onda que daña y aturde a las entidades cercanas."],
]
## Cuerpos de los antiguos dueños bajo cada alma (herramientas/generar_cuerpos.py).
const CORPSES := [
    preload("res://assets/visual/cuerpos/cuerpo_1.png"),
    preload("res://assets/visual/cuerpos/cuerpo_2.png"),
    preload("res://assets/visual/cuerpos/cuerpo_3.png"),
]
const DOOR_TOUCH := 36.0 # distancia a la que tocar la puerta abierta te hace cruzarla
const MATCHES_FIRST_BOX := 5
const MATCHES_REFILL := 3
## Vida de cada entidad por sala (PROVISIONAL, ajustar en pruebas de juego).
const ENEMY_MAX_HP := {"ghoul": 60.0, "testigo": 90.0, "hechicero": 70.0, "segador": 140.0}
const WIZARD_CHARGE := 1.0 # segundos de carga visibles (y vulnerables) del conjuro
const STRIKE_RANGE := 64.0
const STRIKE_DAMAGE := 18.0
const PULSE_RADIUS := 150.0
const BANISH_SOULS := 10
const ROOM_SCENES := [
    preload("res://rooms/sala_0.tscn"),
    preload("res://rooms/sala_1.tscn"),
    preload("res://rooms/sala_2.tscn"),
    preload("res://rooms/sala_3.tscn"),
    preload("res://rooms/sala_4.tscn"),
]
const WALL_COLOR := Color("#394052")
const BG := Color("#090c17")
const CREAM := Color("#d9d2ba")
const SOUL := Color("#8fc7d7")
const RED := Color("#d06470")

## Precarga estatica: Godot detecta estas rutas al importar el proyecto y al exportarlo.
## No cargar PNG mediante rutas construidas dinamicamente: pueden omitirse del import/export.
const ART_PRELOADED := {
    "visual_room_0": preload("res://assets/visual/rooms/room_0.png"),
    "visual_room_1": preload("res://assets/visual/rooms/room_1.png"),
    "visual_room_2": preload("res://assets/visual/rooms/room_2.png"),
    "visual_room_3": preload("res://assets/visual/rooms/room_3.png"),
    "visual_room_4": preload("res://assets/visual/rooms/room_4.png"),
    "visual_hero": preload("res://assets/visual/protagonist_sheet.png"),
    "knowledge_book_sheet": preload("res://assets/knowledge/magic_book_sheet.png"),
    ## Entidades originales cenitales (herramientas/generar_enemigos.py).
    "enemy_testigo": preload("res://assets/visual/enemies/testigo.png"),
    "enemy_ghoul": preload("res://assets/visual/enemies/ghoul.png"),
    "enemy_hechicero": preload("res://assets/visual/enemies/hechicero.png"),
    "enemy_peregrino": preload("res://assets/visual/enemies/peregrino.png"),
    "enemy_segador": preload("res://assets/visual/enemies/segador.png"),

    "room_0": preload("res://assets/knowledge/rooms/room_0.png"),
    "room_1": preload("res://assets/knowledge/rooms/room_1.png"),
    "room_2": preload("res://assets/knowledge/rooms/room_2.png"),
    "room_3": preload("res://assets/knowledge/rooms/room_3.png"),
    "room_4": preload("res://assets/knowledge/rooms/room_4.png"),
    "player": preload("res://assets/fallback/player.png"),
    "knowledge_door": preload("res://assets/knowledge/door_closed.png"),
    "knowledge_altar": preload("res://assets/knowledge/altar.png"),
    "knowledge_book": preload("res://assets/knowledge/magic_book.png"),
    "knowledge_torch": preload("res://assets/knowledge/torch_1.png"),
    "angel_1": preload("res://assets/gothic_enemies/angel_1.png"),
    "angel_2": preload("res://assets/gothic_enemies/angel_2.png"),
    "angel_3": preload("res://assets/gothic_enemies/angel_3.png"),
    "angel_4": preload("res://assets/gothic_enemies/angel_4.png"),
    "angel_5": preload("res://assets/gothic_enemies/angel_5.png"),
    "angel_6": preload("res://assets/gothic_enemies/angel_6.png"),
    "angel_7": preload("res://assets/gothic_enemies/angel_7.png"),
    "angel_8": preload("res://assets/gothic_enemies/angel_8.png"),
    "ghoul_1": preload("res://assets/gothic_enemies/ghoul_1.png"),
    "ghoul_2": preload("res://assets/gothic_enemies/ghoul_2.png"),
    "ghoul_3": preload("res://assets/gothic_enemies/ghoul_3.png"),
    "ghoul_4": preload("res://assets/gothic_enemies/ghoul_4.png"),
    "ghoul_5": preload("res://assets/gothic_enemies/ghoul_5.png"),
    "ghoul_6": preload("res://assets/gothic_enemies/ghoul_6.png"),
    "ghoul_7": preload("res://assets/gothic_enemies/ghoul_7.png"),
    "ghoul_8": preload("res://assets/gothic_enemies/ghoul_8.png"),
    "wizard_1": preload("res://assets/gothic_enemies/wizard_1.png"),
    "wizard_2": preload("res://assets/gothic_enemies/wizard_2.png"),
    "wizard_3": preload("res://assets/gothic_enemies/wizard_3.png"),
    "wizard_4": preload("res://assets/gothic_enemies/wizard_4.png"),
    "wizard_5": preload("res://assets/gothic_enemies/wizard_5.png"),
    "fireball_1": preload("res://assets/gothic_enemies/fireball_1.png"),
    "fireball_2": preload("res://assets/gothic_enemies/fireball_2.png"),
    "fireball_3": preload("res://assets/gothic_enemies/fireball_3.png"),
}

var font: Font
const PIXEL_FONT := preload("res://assets/fonts/PixelifySans.ttf")
## Personaje creado por el jugador (se guarda con el progreso).
var player_name: String = ""
var player_gender: String = "masculino" # masculino | femenino
var game_mode: String = "title" # title, create, play, altar, inventory, floor_intro, dead, victory
var current_floor: int = 0 # índice en FLOORS (0 = Piso I)
var current_room: int = 0
var elapsed: float = 0.0
var room_elapsed: float = 0.0
var player_pos: Vector2 = Vector2(120, 355)
var player_dir: Vector2 = Vector2.RIGHT
var player_moving: bool = false
var hp: float = 100.0
var max_hp: float = 100.0
var fear: float = 0.0
var stamina: float = 100.0
var souls: int = 0
var torch_on: bool = false
## Inventario de la partida (se pierde al empezar otra).
var has_wood: bool = false
var has_torch: bool = false
var matches: int = 0
var has_inner_flame: bool = false # habilidad del altar; se guarda como Resonancia
## Ecos: pasivas que se ganan al superar un piso y se acumulan (homenaje a
## las «pasivas ilimitadas»). Se conservan si el alma regresa; se pierden
## si es absorbida. Se guardan.
var ecos: Array = []
var floor_intro_eco: String = "" # Eco recién ganado, para la pantalla de piso
var items_taken: Dictionary = {} # "piso:sala:clave" -> true
var room_items: Array = [] # {kind, pos}
var inventory_sel: int = 0
## Combate.
var enemy_hp: float = 0.0
var enemy_max: float = 1.0
var banished: Dictionary = {} # "piso:sala" -> true (desterrada en esta partida)
var enemy_hit_t: float = 0.0
var strike_cd: float = 0.0
var strike_fx: float = 0.0
var strike_dir: Vector2 = Vector2.RIGHT
var pulse_fx: float = -1.0
var float_fx: Array = [] # {pos, text, color, t}
var dissolve_fx: Array = [] # {pos, kind, facing, frame, t}
var drops: Array = [] # {pos}
var door_msg_cd: float = 0.0
## Peregrino (Piso II): otro atrapado que te acompaña. En la mayoría de las
## vidas es un traidor; a veces es sincero. Nadie lo sabe hasta la Cosecha.
const PILGRIM_MAX_HP := 70.0
const PILGRIM_TRAITOR_CHANCE := 0.7
var pilgrim_state: String = "none" # none, waiting, follow, tell, hostile, friend, dead
var pilgrim_traitor: bool = true
var pilgrim_pos: Vector2 = Vector2.ZERO
var pilgrim_prev: Vector2 = Vector2.ZERO
var pilgrim_facing: int = 0
var pilgrim_moving: bool = false
var pilgrim_hp: float = PILGRIM_MAX_HP
var pilgrim_souls: int = 0
var pilgrim_timer: float = 0.0 # aviso antes de traicionar / carga del tajo
var pilgrim_cd: float = 0.0
var pilgrim_lunge: float = 0.0
var pilgrim_hit_t: float = 0.0
var pilgrim_stun: float = 0.0
var pilgrim_wronged: bool = false # lo atacaste siendo sincero
var pilgrim_line: String = ""
var pilgrim_line_t: float = 0.0
var pilgrim_corpse: Dictionary = {} # {key, pos}
var nuca_cd: float = 0.0
var step_t: float = 0.0
var step_i: int = 0
var dash_left: float = 0.0
var dash_cd: float = 0.0
var pulse_cd: float = 0.0
var ward_left: float = 0.0
var damage_cd: float = 0.0
var enemy_stun: float = 0.0
var enemy_pos: Vector2 = Vector2(788, 370)
var enemy_home: Vector2 = Vector2(788, 370)
var enemy_alert: bool = false
## Solo visual: orientación y movimiento del enemigo para elegir la animación.
var enemy_facing: int = 0 # 0 abajo, 1 arriba, 2 derecha, 3 izquierda
var enemy_moving: bool = false
var enemy_prev_pos: Vector2 = Vector2.ZERO
var wizard_cast_cd: float = 2.6
var fireballs: Array[Dictionary] = []
var collected: Array[bool] = [false, false, false]
var obstacles: Array[Rect2] = []
## Datos leídos de la escena de la sala actual (los const son valores por defecto).
var room_node: Node2D = null
var room_props: Array = [] # {tex, rect, base, shadow, light, flip}
var relics: Array = RELICS.duplicate()
var seal_pos: Vector2 = SEAL_POS
var altar_pos: Vector2 = ALTAR_POS
var book_pos: Vector2 = BOOK_POS
var archive_pos: Vector2 = ARCHIVE_POS
var eye_pos: Vector2 = EYE_POS
var door_pos: Vector2 = DOOR_POS
var still_timer: float = 0.0
var dark_timer: float = 0.0
var letter_found: bool = false
var has_pulse: bool = false
var ability_level: int = 0
var remembered_rule: bool = false
var seal_acquired: bool = false
var observed_rule: bool = false
var watcher_open: bool = false
var soul_fate: String = ""
var identity_number: int = 1
var new_humans: int = 0
var reincarnations: int = 0
var art: Dictionary = {}
var visual_interaction_left: float = 0.0
## Solo visual: polvo a los pies al chocar con un objeto sólido.
var bump_left: float = 0.0
var bump_at: Vector2 = Vector2.ZERO
var mobile_axis: Vector2 = Vector2.ZERO
var mobile_finger: int = -1
var touch_enabled: bool = false
var toast: String = ""
var toast_left: float = 0.0
var deaths: int = 0
var cleared: int = 0
## Audio original (herramientas/generar_audio.py): ambiente + capa de tensión
## adaptativa + grupo de reproductores para efectos.
const SFX_PATHS := {
    "alma": "res://audio/sfx_alma.ogg", "dano": "res://audio/sfx_dano.ogg",
    "ojo": "res://audio/sfx_ojo.ogg", "aviso": "res://audio/sfx_aviso.ogg",
    "sello": "res://audio/sfx_sello.ogg", "puerta": "res://audio/sfx_puerta.ogg",
    "conjuro": "res://audio/sfx_conjuro.ogg", "libro": "res://audio/sfx_libro.ogg",
    "linterna": "res://audio/sfx_linterna.ogg", "muerte": "res://audio/sfx_muerte.ogg",
    "fosforo": "res://audio/sfx_fosforo.ogg", "apagar": "res://audio/sfx_apagar.ogg",
    "objeto": "res://audio/sfx_objeto.ogg", "golpe": "res://audio/sfx_golpe.ogg",
    "impacto": "res://audio/sfx_impacto.ogg", "inmune": "res://audio/sfx_inmune.ogg",
    "resonancia": "res://audio/sfx_resonancia.ogg", "destierro": "res://audio/sfx_destierro.ogg",
    "interfaz": "res://audio/sfx_interfaz.ogg", "toque": "res://audio/sfx_toque.ogg",
    "paso_1": "res://audio/sfx_paso_1.ogg", "paso_2": "res://audio/sfx_paso_2.ogg",
    "paso_3": "res://audio/sfx_paso_3.ogg", "cuchillo": "res://audio/sfx_cuchillo.ogg",
    "hilo": "res://audio/sfx_hilo.ogg", "latigo": "res://audio/sfx_latigo.ogg",
    "pinchos": "res://audio/sfx_pinchos.ogg",
}
var music: AudioStreamPlayer
var tension: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var tension_level: float = 0.0
## Sensación de juego (solo visual / sonoro, sin efecto en las reglas).
var shake: float = 0.0
var souls_flash: float = 0.0
var pickup_fx: Array = [] # {pos, t}
var watcher_was_open: bool = false
var watcher_warned: bool = false


func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    # Tipografía pixel (Pixelify Sans, OFL), sin suavizado para que encaje con el pixel art.
    font = PIXEL_FONT
    if font is FontFile:
        var ff := font as FontFile
        ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
        ff.hinting = TextServer.HINTING_NONE
        ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
    randomize()
    Ajustes.cargar()
    _apply_touch_setting()
    # Al abrir el juego se ve la pantalla de inicio; al volver de la Vigilia, el menú.
    game_mode = "title" if Engine.has_meta("splash_visto") else "splash"
    _load_progress()
    _load_art()
    _load_room_scene() # sala 1 como fondo del menú
    # No iniciar AudioServer en tests sin pantalla: no hay salida de sonido.
    # En juego normal mantener audio ambiental y efectos completos.
    var audio_available: bool = DisplayServer.get_name() != "headless"
    music = AudioStreamPlayer.new()
    tension = AudioStreamPlayer.new()
    add_child(music)
    add_child(tension)
    for i in range(8):
        var player := AudioStreamPlayer.new()
        player.bus = "Efectos"
        add_child(player)
        sfx_pool.append(player)
    # Buses de Música y Efectos con los volúmenes de Configuración.
    Ajustes.preparar_buses()
    music.bus = "Musica"
    tension.bus = "Musica"
    if audio_available:
        var templo: AudioStreamOggVorbis = load("res://audio/musica_templo.ogg")
        var capa: AudioStreamOggVorbis = load("res://audio/musica_tension.ogg")
        templo.loop = true
        capa.loop = true
        music.stream = templo
        tension.stream = capa
        music.volume_db = -14.0
        tension.volume_db = -60.0
        music.play()
        tension.play() # empieza en silencio; sube con el peligro
        for key in SFX_PATHS:
            sfx_streams[key] = load(SFX_PATHS[key])
    queue_redraw()

func _load_art() -> void:
    # Preload hace que la ausencia de un asset sea un error comprobable y no invisible.
    art = ART_PRELOADED.duplicate()


func _exit_tree() -> void:
    # Evita que el servidor de audio retenga AudioStreamPlaybackWAV al
    # cambiar escenas, cerrar el juego o terminar una prueba automatizada.
    for player in [music, tension] + sfx_pool:
        if is_instance_valid(player):
            player.stop()
            player.stream = null
    sfx_streams.clear()


## Efecto con ligera variación de tono para que no suene repetitivo.
func _sfx(key: String, volume_db: float = -6.0, pitch: float = 1.0) -> void:
    if not sfx_streams.has(key):
        return
    var chosen: AudioStreamPlayer = sfx_pool[0]
    for player in sfx_pool:
        if not player.playing:
            chosen = player
            break
    chosen.stream = sfx_streams[key]
    chosen.volume_db = volume_db
    chosen.pitch_scale = pitch * randf_range(0.96, 1.04)
    chosen.play()


## La capa de tensión sube con el miedo, la persecución y el ojo abierto;
## el ambiente baja un poco para dejarle sitio.
func _update_audio(delta: float) -> void:
    if music == null or music.stream == null:
        return
    var target: float = 0.0
    if game_mode == "play":
        target = fear / 100.0 * 0.75
        if enemy_alert:
            target += 0.55
        if _enemy_active() and _enemy_kind() == "testigo" and watcher_open:
            target += 0.25
    tension_level = move_toward(tension_level, clampf(target, 0.0, 1.0), delta * 0.4)
    tension.volume_db = linear_to_db(maxf(tension_level, 0.001)) - 7.0
    var base_db: float = -14.0 - 5.0 * tension_level
    if game_mode == "dead":
        base_db = -26.0
    music.volume_db = move_toward(music.volume_db, base_db, delta * 12.0)


func _load_progress() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if data is Dictionary:
        identity_number = maxi(1, int(data.get("identity_number", 1)))
        new_humans = maxi(0, int(data.get("new_humans", 0)))
        reincarnations = maxi(0, int(data.get("reincarnations", 0)))
        has_pulse = bool(data.get("has_pulse", false))
        has_inner_flame = bool(data.get("has_inner_flame", false))
        var saved_ecos = data.get("ecos", [])
        ecos = (saved_ecos as Array).filter(func(e): return ECOS.has(str(e))) if saved_ecos is Array else []
        ability_level = maxi(0, int(data.get("ability_level", 0)))
        remembered_rule = bool(data.get("remembered_rule", false))
        deaths = maxi(0, int(data.get("deaths", 0)))
        cleared = maxi(0, int(data.get("cleared", 0)))
        player_name = _clean_name(str(data.get("player_name", "")))
        player_gender = "femenino" if str(data.get("player_gender", "")) == "femenino" else "masculino"

func _save_progress() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({
            "identity_number": identity_number,
            "new_humans": new_humans,
            "reincarnations": reincarnations,
            "has_pulse": has_pulse,
            "has_inner_flame": has_inner_flame,
            "ecos": ecos,
            "ability_level": ability_level,
            "remembered_rule": remembered_rule,
            "deaths": deaths,
            "cleared": cleared,
            "player_name": player_name,
            "player_gender": player_gender
        }))


## --- Datos del piso y de la sala actuales -------------------------------
func _floor() -> Dictionary:
    return TUTORIAL_FLOOR if in_tutorial else FLOORS[current_floor]


func _room() -> Dictionary:
    return _floor()["rooms"][current_room]


func _room_count() -> int:
    return (_floor()["rooms"] as Array).size()


func _room_key() -> String:
    return "%d:%d" % [current_floor, current_room]


func _has(trait_name: String) -> bool:
    return trait_name in _room()["traits"]


func _new_run() -> void:
    in_tutorial = false
    current_floor = 0
    current_room = 0
    pilgrim_state = "none"
    pilgrim_corpse = {}
    _allies_reset()
    missions_done.clear()
    talks_seen.clear()
    dialog_queue.clear()
    souls = 0
    max_hp = 100.0
    hp = max_hp
    fear = 0.0
    stamina = 100.0
    dash_cd = 0.0
    pulse_cd = 0.0
    damage_cd = 0.0
    elapsed = 0.0
    # Se empieza a oscuras: la antorcha se construye en la primera sala.
    torch_on = false
    has_wood = false
    has_torch = false
    matches = 0
    items_taken.clear()
    banished.clear()
    strike_cd = 0.0
    seal_acquired = false
    observed_rule = remembered_rule
    game_mode = "play"
    _enter_room()
    if remembered_rule:
        _say("Recuerdas la regla del Testigo de una vida anterior.", 4.0)
    else:
        _say("No recuerdas el origen del templo. Busca respuestas.", 4.0)


func _enter_room() -> void:
    _load_room_scene()
    player_pos = _marker("Jugador", Vector2(115.0, 359.0))
    player_dir = Vector2.RIGHT
    var default_enemy := Vector2(765.0, 358.0)
    if _enemy_kind() == "ghoul":
        default_enemy = Vector2(772.0, 472.0)
    elif _enemy_kind() == "hechicero":
        default_enemy = Vector2(773.0, 354.0)
    enemy_pos = _marker("Enemigo", default_enemy)
    wizard_cast_cd = 2.4
    fireballs.clear()
    enemy_home = enemy_pos
    enemy_prev_pos = enemy_pos
    enemy_facing = 3 # empiezan mirando hacia la entrada (izquierda)
    enemy_stun = 0.0
    enemy_alert = false
    room_elapsed = 0.0
    still_timer = 0.0
    dark_timer = 0.0
    letter_found = false
    collected = [false, false, false]
    ward_left = 0.0
    # La antorcha conserva su estado al cruzar la puerta.
    room_items.clear()
    for entry in _room()["items"]:
        if not items_taken.has("%s:%s" % [_room_key(), entry[0]]):
            room_items.append({"kind": entry[0], "pos": _marker(entry[1], entry[2])})
    enemy_max = maxf(1.0, float(ENEMY_MAX_HP.get(_enemy_kind(), 1.0)))
    enemy_hp = enemy_max
    if _enemy_kind() == "segador":
        _segador_enter_room()
    enemy_hit_t = 0.0
    pulse_fx = -1.0
    strike_fx = 0.0
    float_fx.clear()
    dissolve_fx.clear()
    drops.clear()
    _pilgrim_enter_room()
    _allies_enter_room()
    _load_traps()
    if game_mode == "floor_intro":
        toast_left = 0.0 # el susurro se oye al pulsar ENTRAR
    elif _has("tutorial") and not has_torch:
        _say("Oscuridad. Busca madera y fósforos para hacer una antorcha.", 4.5)
    else:
        _say(_room()["whisper"], 4.5)
    if game_mode == "play":
        _room_talk()


## Instancia rooms/sala_N.tscn bajo el dibujo del juego y lee sus datos.
func _load_room_scene() -> void:
    if room_node != null:
        remove_child(room_node)
        room_node.queue_free()
    room_node = ROOM_SCENES[int(_room()["scene"])].instantiate()
    room_node.z_index = -1 # el suelo (TileMapLayer) queda bajo todo lo demás
    # Cada piso más gastado y apagado que el anterior (GDD §5: cambio gradual).
    var wear: float = float(_floor().get("wear", 0.0))
    room_node.modulate = Color(1, 1, 1).lerp(Color(0.80, 0.82, 0.76), clampf(wear * 0.6, 0.0, 1.0))
    add_child(room_node)
    move_child(room_node, 0)
    obstacles.clear()
    for shape in room_node.find_children("*", "CollisionShape2D", true, false):
        var rect_shape := (shape as CollisionShape2D).shape as RectangleShape2D
        if rect_shape == null or (shape as CollisionShape2D).disabled:
            continue
        var center: Vector2 = (shape as Node2D).global_position - global_position
        obstacles.append(Rect2(center - rect_shape.size * 0.5, rect_shape.size))
    # Los objetos los dibuja este script, ordenados por profundidad con los
    # personajes; en el editor se ven y se mueven como Sprite2D normales.
    room_props.clear()
    var objetos: Node = room_node.get_node_or_null("Objetos")
    if objetos != null:
        (objetos as CanvasItem).visible = false
        for child in objetos.get_children():
            var sprite := child as Sprite2D
            if sprite == null or sprite.texture == null or not sprite.visible:
                continue
            var size: Vector2 = sprite.texture.get_size() * sprite.scale.abs()
            var anchor: Vector2 = sprite.global_position - global_position
            var top_left: Vector2 = anchor + sprite.offset * sprite.scale.abs()
            if sprite.centered:
                top_left -= size * 0.5
            room_props.append({
                "tex": sprite.texture, "rect": Rect2(top_left, size), "base": anchor.y,
                "shadow": bool(sprite.get_meta("sombra", true)), "light": bool(sprite.get_meta("luz", false)),
                "flip": sprite.flip_h,
            })
    relics = [_marker("Reliquia1", RELICS[0]), _marker("Reliquia2", RELICS[1]), _marker("Reliquia3", RELICS[2])]
    seal_pos = _marker("Sello", SEAL_POS)
    altar_pos = _marker("Altar", ALTAR_POS)
    book_pos = _marker("Libro", BOOK_POS)
    archive_pos = _marker("Lectura", ARCHIVE_POS)
    eye_pos = _marker("Ojo", EYE_POS)
    door_pos = _marker("Salida", DOOR_POS)


func _marker(marker_name: String, fallback: Vector2) -> Vector2:
    if room_node == null:
        return fallback
    var marker := room_node.get_node_or_null("Marcadores/" + marker_name) as Node2D
    return fallback if marker == null else marker.global_position - global_position


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var point: Vector2 = make_input_local(event).position
        _mobile_touch(event.index, point, event.pressed)
        return
    elif event is InputEventScreenDrag and event.index == mobile_finger:
        _mobile_update_axis(make_input_local(event).position)
        return
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        dragging_slider = ""
        return
    elif event is InputEventMouseMotion:
        ui_hover = make_input_local(event).position
        if game_mode == "settings" and dragging_slider != "" and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
            for w in _settings_widgets():
                if w["kind"] == "slider" and w["id"] == dragging_slider:
                    _set_slider(w, ui_hover.x)
        if game_mode in ["inventory", "altar"]:
            var slot_h: int = _inventory_slot_at(ui_hover) if game_mode == "inventory" else _altar_row_at(ui_hover)
            if slot_h >= 0:
                inventory_sel = slot_h
        if game_mode == "pause":
            for i in range(_pause_options().size()):
                if _pause_rect(i).has_point(ui_hover):
                    pause_sel = i
        queue_redraw()
        return
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var click_at: Vector2 = make_input_local(event).position
        if game_mode in ["title", "create", "inventory", "abilities", "dialog", "altar", "floor_intro", "splash", "eula", "intro", "pause", "settings"]:
            _mobile_tap(click_at)
            return
        if game_mode == "play" and click_at.y < 104.0:
            _mobile_tap(click_at) # botones del HUD (retrato, pausa, habilidades)
            return
        if game_mode == "play" and not touch_enabled:
            if not _torch_strike():
                _say("Enciende la antorcha (F) para golpear con fuego.", 1.8)
            return
    if not (event is InputEventKey):
        return
    if not event.pressed or event.echo:
        return
    var k: Key = event.keycode
    if game_mode == "dialog":
        if k == KEY_ESCAPE:
            _dialog_skip()
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E] or k == _key("interactuar"):
            _dialog_advance()
        queue_redraw()
        return
    if game_mode == "abilities":
        if k in [_key("habilidades"), KEY_ESCAPE, KEY_E, KEY_K]:
            _close_abilities()
        queue_redraw()
        return
    if game_mode == "create":
        _create_key(k, event.unicode)
        queue_redraw()
        return
    if game_mode == "settings":
        _settings_key(k)
        queue_redraw()
        return
    if game_mode == "splash":
        _splash_continue()
        return
    if game_mode == "eula":
        if k in [KEY_ENTER, KEY_KP_ENTER]:
            _accept_eula()
        return
    if game_mode == "intro":
        if k == KEY_ESCAPE:
            _end_intro()
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
            _intro_next()
        return
    if game_mode == "pause":
        _pause_key(k)
        queue_redraw()
        return
    if game_mode == "title":
        if k == KEY_ENTER or k == KEY_KP_ENTER:
            _start_explore()
        elif k == KEY_C:
            _start_creation("title")
        elif k == KEY_H:
            _open_defense()
        elif k == KEY_ESCAPE:
            game_mode = "splash"
    elif game_mode == "floor_intro":
        if k in [KEY_ENTER, KEY_KP_ENTER, KEY_E, KEY_SPACE]:
            _enter_floor()
    elif game_mode == "dead" or game_mode == "victory":
        if k == KEY_ENTER or k == KEY_KP_ENTER:
            _after_end()
        elif k == KEY_ESCAPE:
            game_mode = "title"
    elif game_mode == "altar":
        if k == KEY_1:
            _buy_upgrade(1)
        elif k == KEY_2:
            _buy_upgrade(2)
        elif k == KEY_ESCAPE or k == KEY_E:
            game_mode = "play"
            _sfx("interfaz", -12.0, 0.9)
    elif game_mode == "inventory":
        if k in [_key("perfil"), KEY_TAB, KEY_ESCAPE, KEY_E]:
            _close_inventory()
        elif k == _key("habilidades"):
            game_mode = "play"
            _open_abilities()
        elif k in [KEY_RIGHT, KEY_D]:
            inventory_sel = (inventory_sel % 100 + 1) % INVENTORY_SLOTS.size()
        elif k in [KEY_LEFT, KEY_A]:
            inventory_sel = (inventory_sel % 100 + INVENTORY_SLOTS.size() - 1) % INVENTORY_SLOTS.size()
        elif k in [KEY_DOWN, KEY_S, KEY_UP, KEY_W]:
            inventory_sel = (inventory_sel % 100 + 3) % INVENTORY_SLOTS.size()
    elif game_mode == "play":
        # Teclas reasignables desde Configuración > Controles.
        if k == _key("interactuar"):
            _interact()
        elif k == _key("antorcha"):
            _toggle_torch()
        elif k == _key("perfil") or k == KEY_TAB:
            _open_inventory()
        elif k == _key("esquivar"):
            _start_dash()
        elif k == _key("habilidades"):
            _open_abilities()
        elif k == _key("resonancia"):
            _use_pulse()
        elif k == _key("pausa") or k == KEY_ESCAPE:
            _open_pause()
    queue_redraw()


func _open_defense() -> void:
    get_tree().change_scene_to_file("res://scenes/defense.tscn")

func _mobile_touch(finger: int, at: Vector2, pressed: bool) -> void:
    if not pressed:
        if finger == mobile_finger:
            mobile_finger = -1
            mobile_axis = Vector2.ZERO
        queue_redraw()
        return
    if game_mode == "play" and at.x <= 325.0 and at.y >= 367.0:
        mobile_finger = finger
        _mobile_update_axis(at)
    else:
        _mobile_tap(at)
    queue_redraw()

func _mobile_update_axis(at: Vector2) -> void:
    mobile_axis = ((at - Vector2(135.0, 480.0)) / 68.0).limit_length(1.0)
    queue_redraw()

func _mobile_tap(at: Vector2) -> void:
    ui_hover = at
    if game_mode == "settings":
        _settings_click(at)
        return
    if game_mode == "splash":
        if GEAR_RECT.has_point(at):
            _open_settings("splash")
        else:
            _splash_continue()
        return
    if game_mode == "eula":
        for b in _eula_buttons():
            if (b["rect"] as Rect2).has_point(at):
                match b["id"]:
                    "aceptar":
                        _accept_eula()
                    "leer":
                        _open_settings("eula")
                        settings_tab = 3
                        legal_page = "acuerdo"
                    "salir":
                        get_tree().quit()
        return
    if game_mode == "intro":
        _intro_next()
        return
    if game_mode == "pause":
        for i in range(_pause_options().size()):
            if _pause_rect(i).has_point(at):
                _pause_choose(i)
                return
        return
    if game_mode == "create":
        _create_tap(at)
        return
    if game_mode == "title":
        if CHANGE_CHAR_RECT.has_point(at):
            _start_creation("title")
        elif GEAR_RECT.has_point(at):
            _open_settings("title")
        elif at.x >= 480.0 and at.y > 415.0:
            _open_defense()
        else:
            _start_explore()
        return
    if game_mode == "dead" or game_mode == "victory":
        _after_end()
        return
    if game_mode == "floor_intro":
        _enter_floor()
        return
    if game_mode == "altar":
        var row: int = _altar_row_at(at)
        if row >= 0:
            inventory_sel = row
            _buy_upgrade(row + 1)
        else:
            game_mode = "play"
            _sfx("interfaz", -12.0, 0.9)
        return
    if game_mode == "dialog":
        _dialog_advance()
        return
    if game_mode == "abilities":
        _close_abilities()
        return
    if game_mode == "inventory":
        if PROFILE_ABIL_BTN.has_point(at):
            game_mode = "play"
            _open_abilities()
            return
        var slot: int = _inventory_slot_at(at)
        if slot >= 0:
            inventory_sel = slot
        else:
            _close_inventory()
        return
    if game_mode != "play":
        return
    if ABIL_BTN.has_point(at):
        _open_abilities()
        return
    if at.x > 890.0 and at.y < 64.0:
        _open_pause() # botón de pausa del minimapa
        mobile_axis = Vector2.ZERO
        mobile_finger = -1
        return
    if at.y < 104.0 and at.x < 330.0:
        # Tocar el retrato abre el perfil.
        _open_inventory()
        return
    if at.y > 365.0 and at.x > 370.0:
        if at.x < 510.0:
            _interact()
        elif at.x < 660.0:
            _toggle_torch()
        elif at.x < 790.0:
            _start_dash()
        else:
            _use_pulse()
    queue_redraw()

func _draw_mobile_controls() -> void:
    if not touch_enabled:
        return
    if game_mode != "play":
        return
    # Joystick virtual: el dedo en la izquierda define un vector en vez de
    # modificar las teclas reales de escritorio o la IA original.
    draw_circle(Vector2(135, 480), 72.0, Color(0.10, 0.20, 0.28, 0.70))
    draw_arc(Vector2(135, 480), 72.0, 0.0, TAU, 48, SOUL, 3.0)
    draw_circle(Vector2(135, 480) + mobile_axis * 48.0, 26.0, Color(0.62, 0.81, 0.83, 0.68))
    var positions := [Vector2(440, 478), Vector2(585, 478), Vector2(725, 478), Vector2(865, 478)]
    var labels := ["E", "F", "DASH", "Q"]
    var icons := ["golpe" if has_torch and torch_on else "", "antorcha_encendida" if torch_on else "antorcha", "", "resonancia"]
    for i in range(4):
        var at: Vector2 = positions[i]
        draw_circle(at, 51.0, Color(0.09, 0.21, 0.27, 0.83))
        draw_arc(at, 51.0, 0.0, TAU, 36, SOUL, 2.0)
        if icons[i] != "" and (i != 1 or has_torch) and (i != 3 or has_pulse):
            draw_texture_rect(ICONS[icons[i]], Rect2(at - Vector2(24, 30), Vector2(48, 48)), false, Color(1, 1, 1, 0.9))
            draw_string(font, at + Vector2(-47, 38), labels[i], HORIZONTAL_ALIGNMENT_CENTER, 94, 14, CREAM)
        else:
            draw_string(font, at + Vector2(-47, 8), labels[i], HORIZONTAL_ALIGNMENT_CENTER, 94, 23, CREAM)


func _buy_upgrade(choice: int) -> void:
    if choice == 2:
        _buy_inner_flame()
        return
    if choice != 1:
        return
    if has_pulse:
        _say("Ya adquiriste Resonancia. Nivel actual: %d." % ability_level)
        return
    # Precio y balance de esta prueba vertical: PROVISIONALES, no canon definitivo.
    var price: int = 14
    if souls < price:
        _say("Necesitas 14 fragmentos de alma.")
        return
    souls -= price
    has_pulse = true
    ability_level = 0
    _save_progress()
    _sfx("sello", -6.0, 1.25)
    _say("Adquiriste Resonancia nivel 0. Pulsa Q para utilizarla.", 4.0)


const INNER_FLAME_PRICE := 10
func _buy_inner_flame() -> void:
    if has_inner_flame:
        _say("La llama interior ya arde en ti.")
        return
    if souls < INNER_FLAME_PRICE:
        _say("Necesitas %d fragmentos de alma." % INNER_FLAME_PRICE)
        _sfx("toque", -10.0)
        return
    souls -= INNER_FLAME_PRICE
    has_inner_flame = true
    _save_progress()
    _sfx("fosforo", -6.0, 0.8)
    _say("Adquiriste LLAMA INTERIOR: enciendes la antorcha sin fósforos.", 4.0)


func _use_pulse() -> void:
    if not has_pulse:
        _say("Todavía no adquiriste Resonancia en el altar.", 2.0)
        return
    if pulse_cd > 0.0 or stamina < 24.0:
        _say("Resonancia necesita energía o tiempo de recuperación.", 2.0)
        return
    pulse_cd = 8.0
    stamina -= 24.0
    pulse_fx = 0.0
    _sfx("resonancia", -5.0)
    if _pilgrim_present() and pilgrim_state != "dead" and player_pos.distance_to(pilgrim_pos) < PULSE_RADIUS + 12.0:
        pilgrim_stun = 1.4
        _damage_pilgrim(30.0 + 10.0 * float(ability_level))
    if _enemy_active() and player_pos.distance_to(enemy_pos) < 220.0:
        enemy_stun = 1.6 + 0.5 * float(ability_level)
        if player_pos.distance_to(enemy_pos) < PULSE_RADIUS + 12.0:
            _damage_enemy(30.0 + 10.0 * float(ability_level))
        else:
            _say("La onda la aturde, pero está lejos para dañarla.", 2.2)
    else:
        _say("Una vibración recorre la piedra.", 1.6)


## Antorcha: F la enciende (gasta un fósforo salvo con Llama interior) o la apaga.
func _toggle_torch() -> void:
    if not has_torch:
        if has_wood:
            _say("Te faltan fósforos para prender la madera.", 2.2)
        elif matches > 0:
            _say("Tienes fósforos, pero nada que arda. Busca madera.", 2.2)
        else:
            _say("No llevas luz. Busca madera y fósforos.", 2.2)
        _sfx("toque", -12.0)
        return
    if torch_on:
        torch_on = false
        _sfx("apagar", -9.0)
        _say("Antorcha apagada.", 1.2)
        return
    if has_inner_flame:
        torch_on = true
        _sfx("fosforo", -8.0, 1.3)
        _say("La llama interior prende la antorcha.", 1.6)
        return
    if matches <= 0:
        _say("No te quedan fósforos. Búscalos o compra la Llama interior.", 2.8)
        _sfx("toque", -10.0)
        return
    matches -= 1
    torch_on = true
    _sfx("fosforo", -7.0)
    _say("Antorcha encendida. Fósforos: %d." % matches, 1.8)


func _take_item(i: int) -> void:
    var item: Dictionary = room_items[i]
    var kind: String = item["kind"]
    items_taken["%s:%s" % [_room_key(), kind]] = true
    room_items.remove_at(i)
    var label: String = ""
    if kind == "madera":
        has_wood = true
        label = "+MADERA"
        _say("Madera seca y una tira de tela: el cuerpo de una antorcha.", 3.0)
    else:
        var amount: int = MATCHES_FIRST_BOX if matches == 0 and not has_torch else MATCHES_REFILL
        matches += amount
        label = "+%d FÓSFOROS" % amount
        _say("Caja de fósforos: +%d. Llevas %d." % [amount, matches], 3.0)
    pickup_fx.append({"pos": item["pos"], "t": 0.0, "text": label, "color": Color("#f0c98a")})
    _sfx("objeto", -6.0)
    _try_craft()


func _try_craft() -> void:
    if has_torch or not has_wood or matches <= 0:
        return
    has_wood = false
    has_torch = true
    _sfx("interfaz", -8.0, 0.8)
    _say("Construiste una ANTORCHA. Pulsa F para encenderla (gasta 1 fósforo).", 4.5)


func _enter_floor() -> void:
    game_mode = "play"
    _sfx("interfaz", -8.0, 0.7)
    _say(_room()["whisper"], 4.5)
    _room_talk()
    if not dialog_queue.is_empty() and game_mode == "play":
        _dialog([]) # frases que llegaron durante la pantalla del piso


func _open_inventory() -> void:
    if game_mode != "play":
        return
    game_mode = "inventory"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    # Selecciona el primer objeto que se tiene.
    for i in range(INVENTORY_SLOTS.size()):
        if _slot_owned(i):
            inventory_sel = i
            break
    _sfx("interfaz", -9.0)


func _close_inventory() -> void:
    game_mode = "play"
    if in_tutorial:
        tut_profile = true
    _sfx("interfaz", -12.0, 0.9)


func _slot_owned(i: int) -> bool:
    match INVENTORY_SLOTS[i][0]:
        "madera":
            return has_wood
        "fosforos":
            return matches > 0
        "antorcha":
            return has_torch
        "llama_interior":
            return has_inner_flame
        "golpe":
            return has_torch
        "resonancia":
            return has_pulse
    return false


func _inventory_slot_rect(i: int) -> Rect2:
    return Rect2(372.0 + float(i % 3) * 168.0, 100.0 + float(i / 3) * 128.0, 160.0, 120.0)


func _inventory_slot_at(at: Vector2) -> int:
    for i in range(INVENTORY_SLOTS.size()):
        if _inventory_slot_rect(i).has_point(at):
            return i
    for i in range(ECOS.size()):
        if _profile_eco_rect(i).has_point(at):
            return 100 + i
    return -1


func _profile_eco_rect(i: int) -> Rect2:
    return Rect2(372.0 + float(i) * 54.0, 380.0, 48.0, 48.0)


func _altar_row_rect(i: int) -> Rect2:
    return Rect2(190.0, 262.0 + float(i) * 96.0, 580.0, 86.0)


func _altar_row_at(at: Vector2) -> int:
    for i in range(2):
        if _altar_row_rect(i).has_point(at):
            return i
    return -1


# ---------------------------------------------------------------- COMBATE
func _enemy_active() -> bool:
    return _enemy_kind() != "" and not banished.has(_room_key())


func _enemy_kind() -> String:
    return str(_room()["enemy"])


## Debilidades: el Testigo solo con el ojo cerrado; el Hechicero solo
## mientras carga el conjuro; el Ghoul siempre.
func _enemy_vulnerable() -> bool:
    match _enemy_kind():
        "testigo":
            return not watcher_open
        "hechicero":
            return enemy_alert and wizard_cast_cd < WIZARD_CHARGE
        "segador":
            return seg_state == "engancha"
    return true


func _damage_enemy(amount: float) -> bool:
    var head := enemy_pos + Vector2(randf_range(-6.0, 6.0) + 30.0, -48.0)
    if not _enemy_vulnerable():
        float_fx.append({"pos": head, "text": "INMUNE", "color": Color("#b4bba8"), "t": 0.0})
        _sfx("inmune", -8.0)
        if _enemy_kind() == "testigo":
            _say("Con el ojo abierto es piedra. Golpéalo cuando lo cierre.", 2.6)
        elif _enemy_kind() == "segador":
            _say("Es demasiado rápido. Espera a que dispare y quede enganchado.", 2.6)
        else:
            _say("Su escudo solo cae mientras carga el conjuro.", 2.6)
        return false
    enemy_hp -= amount
    enemy_hit_t = 0.2
    float_fx.append({"pos": head, "text": "-%d" % int(amount), "color": Color("#ffd36b"), "t": 0.0})
    _sfx("impacto", -6.0)
    if enemy_hp <= 0.0:
        _banish_enemy()
    elif _enemy_kind() == "segador" and _has("huida") and enemy_hp <= enemy_max * 0.5:
        _segador_flee()
    return true


## A 0 de vida la entidad se disuelve y suelta almas. Vuelve si mueres.
func _banish_enemy() -> void:
    var kind: String = _enemy_kind()
    banished[_room_key()] = true
    if _mission().get("goal", "") == "desterrar":
        _complete_mission()
    if kind == "segador":
        seg_state = "acecho"
        seg_hp_floor = 0.0
    dissolve_fx.append({"pos": enemy_pos, "kind": kind, "facing": enemy_facing, "frame": _enemy_frame(kind), "t": 0.0})
    drops.append({"pos": enemy_pos})
    fireballs.clear()
    enemy_stun = 0.0
    enemy_alert = false
    shake = maxf(shake, 0.25)
    _sfx("destierro", -4.0)
    _say("Entidad DESTERRADA. Recoge sus almas. Volverá si mueres.", 3.8)


## Golpe de antorcha: arco de fuego delante del personaje.
func _torch_strike() -> bool:
    if not (has_torch and torch_on):
        return false
    if strike_cd > 0.0 or stamina < 10.0:
        return true
    strike_cd = 0.6
    stamina -= 10.0
    strike_fx = 0.25
    strike_dir = player_dir.normalized() if player_dir.length() > 0.1 else Vector2.RIGHT
    visual_interaction_left = 0.24
    _sfx("golpe", -7.0)
    if in_tutorial:
        var to_d := DUMMY_POS - player_pos
        if to_d.length() < STRIKE_RANGE + 14.0 and (to_d.length() < 26.0 or to_d.normalized().dot(strike_dir) > 0.2):
            dummy_hits += 1
            dummy_shake = 0.25
            float_fx.append({"pos": DUMMY_POS + Vector2(26, -60), "text": "-%d" % int(STRIKE_DAMAGE), "color": Color("#ffd36b"), "t": 0.0})
            _sfx("impacto", -8.0, 1.2)
    if _pilgrim_present() and pilgrim_state != "dead":
        var to_p := pilgrim_pos - player_pos
        if to_p.length() < STRIKE_RANGE + 10.0 and (to_p.length() < 24.0 or to_p.normalized().dot(strike_dir) > 0.25):
            _damage_pilgrim(STRIKE_DAMAGE)
            var shove := pilgrim_pos + to_p.normalized() * 16.0
            if not _is_blocked(shove):
                pilgrim_pos = shove
    if _enemy_active():
        var to := enemy_pos - player_pos
        if to.length() < STRIKE_RANGE + 10.0 and (to.length() < 24.0 or to.normalized().dot(strike_dir) > 0.25):
            if _damage_enemy(STRIKE_DAMAGE):
                enemy_stun = maxf(enemy_stun, 0.3)
                var pushed := enemy_pos + to.normalized() * 18.0
                if not _is_blocked(pushed):
                    enemy_pos = pushed
    return true


func _interact() -> void:
    visual_interaction_left = 0.24 # solo dibujo; no cambia la interacción
    if _has("sello") and not seal_acquired and player_pos.distance_to(seal_pos) < 60.0:
        seal_acquired = true
        remembered_rule = true
        observed_rule = true
        if has_pulse:
            ability_level = maxi(ability_level, 1)
        _save_progress()
        _say("SELLO RECUPERADO. El Testigo se inmoviliza cuando tú te detienes.", 5.0)
        _sfx("sello", -4.0)
        return
    if _has("altar") and player_pos.distance_to(altar_pos) < 64.0:
        game_mode = "altar"
        inventory_sel = 0
        _sfx("interfaz", -8.0)
        return
    if _has("archivo") and player_pos.distance_to(archive_pos) < 72.0:
        letter_found = true
        _say("Carta: 'He regresado. El cuerpo cambia, pero recuerdo sus ojos.'", 5.0)
        _sfx("libro", -5.0)
        return
    if player_pos.distance_to(door_pos) < 74.0:
        if _room_ready():
            _go_through_door()
        else:
            _say(_required_clue(), 3.2)
        return
    if _torch_strike():
        return
    _sfx("toque", -10.0)
    _say("La piedra no responde a tu tacto.", 1.3)

func _go_through_door() -> void:
    if current_room == _room_count() - 1:
        _finish_floor()
    else:
        current_room += 1
        _enter_room()
        _sfx("puerta", -6.0)


## La puerta se cruza al tocarla (sin pulsar E). Si sigue sellada, avisa.
func _check_door_touch(dt: float) -> void:
    door_msg_cd = maxf(0.0, door_msg_cd - dt)
    if player_pos.distance_to(door_pos) >= DOOR_TOUCH:
        return
    if _room_ready():
        _go_through_door()
    elif door_msg_cd <= 0.0:
        door_msg_cd = 3.0
        _say(_required_clue(), 3.0)
        _sfx("toque", -10.0)


func _room_ready() -> bool:
    if in_tutorial:
        return tutorial_step >= TUTORIAL_LAST
    # Una misión principal en el primer piso: recuperar el sello del Testigo.
    if _has("sello") and not seal_acquired:
        return false
    if _has("almas") and collected.has(false):
        return false
    if _has("caza") and _enemy_active():
        return false
    if _mission_pending(true):
        return false
    return _pilgrim_allows_exit()


func _pilgrim_allows_exit() -> bool:
    return not pilgrim_state in ["tell", "hostile"]

func _required_clue() -> String:
    if _has("sello") and not seal_acquired:
        return "El pórtico exige el sello de la estatua. Está al fondo."
    if _has("almas") and collected.has(false):
        return "El templo no deja pasar a nadie con las manos vacías: faltan almas."
    if pilgrim_state in ["tell", "hostile"]:
        return "No puedes darle la espalda a quien te quiere muerto."
    if _has("caza") and _enemy_active():
        return "La Cacería no ha terminado: la presa sigue viva."
    if _mission_pending(true):
        return "MISIÓN: %s. La puerta no se abre hasta cumplirla." % _mission()["text"]
    return "La puerta todavía no te reconoce."


func _relic_count() -> int:
    var count: int = 0
    for picked in collected:
        if picked:
            count += 1
    return count


## Última puerta del piso: Eco de recompensa y, si hay otro piso, su pantalla de entrada.
func _finish_floor() -> void:
    if in_tutorial:
        _end_tutorial()
        return
    var eco: String = str(_floor().get("eco", ""))
    floor_intro_eco = ""
    if eco != "" and not ecos.has(eco):
        ecos.append(eco)
        floor_intro_eco = eco
    _save_progress()
    if current_floor + 1 >= FLOORS.size():
        _win_run()
        return
    current_floor += 1
    current_room = 0
    _on_floor_start()
    game_mode = "floor_intro" # antes de entrar: nada habla hasta pulsar ENTRAR
    _enter_room()
    _sfx("puerta", -4.0, 0.7)


## Preparación propia de cada piso (p. ej., el Peregrino del Piso II).
func _on_floor_start() -> void:
    _pilgrim_reset()
    _allies_reset()


func _win_run() -> void:
    cleared += 1
    _save_progress()
    game_mode = "victory"
    _sfx("sello", -4.0, 0.8)

func _lose_run() -> void:
    deaths += 1
    if MUERTE_SIN_PERDIDA:
        soul_fate = "persistencia"
        _save_progress()
        game_mode = "dead"
        _sfx("muerte", -3.0)
        return
    souls = 0
    if randf() < 0.5:
        # Exactamente dos posibilidades equiprobables (regla canónica).
        soul_fate = "retorno"
        reincarnations += 1
        ability_level = 0
        # Conservar identidad, conocimientos y propiedad de la habilidad.
    else:
        soul_fate = "absorcion"
        new_humans += 1
        identity_number += 1
        has_pulse = false
        has_inner_flame = false
        ecos.clear()
        ability_level = 0
        remembered_rule = false
        # Una persona nueva, sin la memoria de la anterior.
    _save_progress()
    game_mode = "dead"
    _sfx("muerte", -3.0)


func _say(message: String, duration: float = 2.8) -> void:
    toast = message
    toast_left = duration


func _controls_axis() -> Vector2:
    var v := Vector2.ZERO
    # Movimiento reasignable; las flechas funcionan siempre.
    if Input.is_key_pressed(_key("arriba")) or Input.is_key_pressed(KEY_UP):
        v.y -= 1.0
    if Input.is_key_pressed(_key("abajo")) or Input.is_key_pressed(KEY_DOWN):
        v.y += 1.0
    if Input.is_key_pressed(_key("izquierda")) or Input.is_key_pressed(KEY_LEFT):
        v.x -= 1.0
    if Input.is_key_pressed(_key("derecha")) or Input.is_key_pressed(KEY_RIGHT):
        v.x += 1.0
    return (v + mobile_axis).limit_length(1.0)


## Choca con un objeto de la sala (no con los muros): para el polvo del impacto.
func _hits_obstacle(at: Vector2) -> bool:
    for rect in obstacles:
        if rect.grow(15.5).has_point(at):
            return true
    return false


func _is_blocked(at: Vector2) -> bool:
    if at.x < 63.0 or at.x > 895.0 or at.y < 155.0 or at.y > 552.0:
        return true
    for rect in obstacles:
        if rect.grow(15.5).has_point(at):
            return true
    return false


func _process(delta: float) -> void:
    elapsed += delta
    toast_left = maxf(0.0, toast_left - delta)
    visual_interaction_left = maxf(0.0, visual_interaction_left - delta)
    bump_left = maxf(0.0, bump_left - delta)
    souls_flash = maxf(0.0, souls_flash - delta)
    for fx in pickup_fx:
        fx["t"] = float(fx["t"]) + delta
    pickup_fx = pickup_fx.filter(func(fx): return float(fx["t"]) < 1.1)
    for fx in float_fx:
        fx["t"] = float(fx["t"]) + delta
    float_fx = float_fx.filter(func(fx): return float(fx["t"]) < 0.9)
    for fx in dissolve_fx:
        fx["t"] = float(fx["t"]) + delta
    dissolve_fx = dissolve_fx.filter(func(fx): return float(fx["t"]) < 1.4)
    enemy_hit_t = maxf(0.0, enemy_hit_t - delta)
    strike_fx = maxf(0.0, strike_fx - delta)
    if pulse_fx >= 0.0:
        pulse_fx += delta
        if pulse_fx > 0.6:
            pulse_fx = -1.0
    if game_mode == "play":
        _update_play(delta)
        _track_enemy_visual(delta)
    elif game_mode == "dialog":
        _update_dialog(delta)
    mission_banner_t = maxf(0.0, mission_banner_t - delta)
    # Sacudida de pantalla tras un golpe (todo el lienzo; decae rápido).
    shake = maxf(0.0, shake - delta * 2.4)
    position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 9.0 if shake > 0.0 else Vector2.ZERO
    _update_audio(delta)
    queue_redraw()


func _update_play(dt: float) -> void:
    room_elapsed += dt
    dash_cd = maxf(0.0, dash_cd - dt)
    pulse_cd = maxf(0.0, pulse_cd - dt)
    strike_cd = maxf(0.0, strike_cd - dt)
    damage_cd = maxf(0.0, damage_cd - dt)
    dash_left = maxf(0.0, dash_left - dt)
    enemy_stun = maxf(0.0, enemy_stun - dt)
    stamina = minf(100.0, stamina + 16.0 * dt)
    var move: Vector2 = _controls_axis()
    if dash_left > 0.0:
        move = dash_dir # el impulso sigue su dirección aunque sueltes las teclas
    player_moving = move.length_squared() > 0.001
    if player_moving:
        player_dir = move
    var speed: float = 157.0 if dash_left <= 0.0 else 480.0
    if player_moving:
        var nx := Vector2(player_pos.x + move.x * speed * dt, player_pos.y)
        var blocked_x: bool = absf(move.x) > 0.3 and _hits_obstacle(nx)
        if not _is_blocked(nx):
            player_pos.x = nx.x
        var ny := Vector2(player_pos.x, player_pos.y + move.y * speed * dt)
        var blocked_y: bool = absf(move.y) > 0.3 and _hits_obstacle(ny)
        if not _is_blocked(ny):
            player_pos.y = ny.y
        if (blocked_x or blocked_y) and bump_left <= 0.0:
            bump_left = 0.35
            bump_at = player_pos + Vector2(signf(move.x) * 10.0 if blocked_x else 0.0, 2.0)
        # Pasos: tres pisadas que se alternan, más rápidas al esquivar.
        step_t -= dt
        if step_t <= 0.0:
            step_t = 0.33 if dash_left <= 0.0 else 0.12
            _sfx("paso_%d" % (step_i % 3 + 1), -17.0)
            step_i += 1
    else:
        step_t = 0.06

    # Las almas se recogen al tocarlas.
    for i in range(relics.size()):
        if not collected[i] and player_pos.distance_to(relics[i]) < 30.0:
            _collect_relic(i)
    for i in range(room_items.size() - 1, -1, -1):
        if player_pos.distance_to(room_items[i]["pos"]) < 30.0:
            _take_item(i)
    _update_tutorial(dt)
    _check_door_touch(dt)
    if game_mode != "play":
        return # se ganó la partida al cruzar la última puerta
    for i in range(drops.size() - 1, -1, -1):
        if player_pos.distance_to(drops[i]["pos"]) < 32.0:
            var value: int = int(drops[i].get("value", BANISH_SOULS))
            souls += value
            souls_flash = 0.8
            pickup_fx.append({"pos": drops[i]["pos"], "t": 0.0, "text": "+%d" % value})
            drops.remove_at(i)
            _sfx("alma", -5.0)

    watcher_open = fmod(room_elapsed, 6.0) < 3.25
    if _enemy_kind() == "testigo":
        # Aviso justo: el ojo tiembla y cruje 0,6 s antes de abrirse.
        var phase: float = fmod(room_elapsed, 6.0)
        if phase >= 5.4 and not watcher_warned:
            watcher_warned = true
            _sfx("aviso", -9.0)
        if watcher_open and not watcher_was_open:
            watcher_warned = false
            _sfx("ojo", -7.0)
        watcher_was_open = watcher_open
    _update_pilgrim(dt)
    _update_allies(dt)
    if _enemy_active():
        _update_enemy(dt)
        var near: float = player_pos.distance_to(enemy_pos)
        if near < 185.0:
            fear += dt * (8.0 if watcher_open else 2.0) * (0.75 if ecos.has("respiracion") else 1.0)
    else:
        # A oscuras el miedo se va más despacio.
        fear -= (4.0 if torch_on else 1.2) * dt
    fear = clampf(fear, 0.0, 100.0)
    if fear >= 100.0:
        hp -= dt * 5.0
    _update_traps(dt)
    _update_regen(dt)
    if hp <= 0.0:
        _lose_run()

func _collect_relic(i: int) -> void:
    collected[i] = true
    souls += 7
    fear = maxf(0.0, fear - 8.0)
    souls_flash = 0.8
    pickup_fx.append({"pos": relics[i], "t": 0.0})
    _say("Fragmento reunido: +7 almas. Es la moneda del templo.", 2.5)
    _sfx("alma", -5.0)


## Golpe recibido: sacudida, destello y sonido. No cambia el daño.
func _on_hurt() -> void:
    shake = 0.45
    _sfx("dano", -4.0)


func _update_enemy(dt: float) -> void:
    # PROVISIONAL: only the Witness rule is part of this vertical slice.
    # Other behaviors are simple encounter prototypes, not narrative canon.
    var d: float = enemy_pos.distance_to(player_pos)
    enemy_alert = false
    if _enemy_kind() == "ghoul":
        # Fire-lit hunter: darkness breaks its pursuit in this test encounter.
        enemy_alert = torch_on and d < 350.0
        if enemy_alert and enemy_stun <= 0.0:
            var wanted := enemy_pos.move_toward(player_pos, 132.0 * dt)
            if not _is_blocked(wanted):
                enemy_pos = wanted
        elif not enemy_alert and enemy_stun <= 0.0:
            enemy_pos = enemy_pos.move_toward(enemy_home, 48.0 * dt)
    elif _enemy_kind() == "testigo":
        # Witness: observes motion with its eyes open. Stop moving to survive.
        enemy_alert = watcher_open and player_moving and d < 490.0
        if enemy_alert and enemy_stun <= 0.0:
            var wanted := enemy_pos.move_toward(player_pos, 169.0 * dt)
            if not _is_blocked(wanted):
                enemy_pos = wanted
            if not observed_rule:
                observed_rule = true
                remembered_rule = true
                _save_progress()
                _say("Observación: al detenerte, el Testigo también se detiene.", 4.5)
    elif _enemy_kind() == "segador":
        _update_segador(dt)
    elif _enemy_kind() == "hechicero":
        # Wizard: warded while the player's torch is off. Provisional mechanic.
        enemy_alert = torch_on and d < 390.0
        wizard_cast_cd = maxf(0.0, wizard_cast_cd - dt)
        if enemy_alert and wizard_cast_cd <= 0.0 and enemy_stun <= 0.0:
            var direction := (player_pos - enemy_pos).normalized()
            fireballs.append({"pos": enemy_pos + Vector2(0.0, -20.0), "vel": direction * 215.0, "life": 2.2})
            wizard_cast_cd = 2.9
            _say("El hechicero responde a tu luz.", 1.6)
            _sfx("conjuro", -8.0)
        for i in range(fireballs.size() - 1, -1, -1):
            var ball: Dictionary = fireballs[i]
            var p: Vector2 = ball["pos"] + ball["vel"] * dt
            ball["pos"] = p
            ball["life"] = float(ball["life"]) - dt
            if p.distance_to(player_pos) < 23.0:
                if damage_cd <= 0.0:
                    hp -= 25.0
                    fear = minf(100.0, fear + 13.0)
                    damage_cd = 1.1
                    _say("El conjuro te alcanza. Busca cobertura.", 2.6)
                    _on_hurt()
                fireballs.remove_at(i)
            elif float(ball["life"]) <= 0.0 or _is_blocked(p):
                fireballs.remove_at(i)
            else:
                fireballs[i] = ball
    if (_enemy_kind() == "ghoul" or _enemy_kind() == "testigo") and enemy_alert and enemy_stun <= 0.0:
        if enemy_pos.distance_to(player_pos) < 31.0 and damage_cd <= 0.0:
            hp -= 33.0 if _enemy_kind() == "ghoul" else 42.0
            fear = minf(100.0, fear + 21.0)
            damage_cd = 1.5
            var away := (player_pos - enemy_pos).normalized()
            if away == Vector2.ZERO:
                away = Vector2.LEFT
            var escape := player_pos + away * 65.0
            if not _is_blocked(escape):
                player_pos = escape
            _say("La criatura te ha herido. Descubre su regla.", 3.0)
            _on_hurt()


func _draw() -> void:
    # El fondo lo pone la escena de la sala (está por debajo).
    if room_node == null:
        draw_rect(Rect2(0, 0, W, H), BG)
    elif game_mode in ["title", "create", "splash", "eula"] or (game_mode == "settings" and settings_return in ["title", "splash"]):
        # En el menú se ve la sala completa, con sus objetos, detrás del panel.
        var objetos: Node = room_node.get_node_or_null("Objetos")
        if objetos != null:
            (objetos as CanvasItem).visible = true
    _draw_background()
    var screen: String = settings_return if game_mode == "settings" else game_mode
    if screen == "intro":
        _draw_intro()
        return
    if screen in ["title", "create", "splash", "eula"]:
        if screen == "title":
            _draw_title()
        elif screen == "create":
            _draw_creation()
        elif screen == "splash":
            _draw_splash()
        else:
            _draw_eula()
        if game_mode == "settings":
            _draw_settings()
        return
    _draw_room()
    _draw_topbar()
    _draw_footer()
    if toast_left > 0.0:
        _draw_toast()
    _draw_mission_banner()
    if game_mode == "altar":
        _draw_altar_overlay()
    elif game_mode == "inventory":
        _draw_inventory_overlay()
    elif game_mode == "abilities":
        _draw_abilities()
    elif game_mode == "dialog":
        _draw_dialog()
    elif game_mode == "dead":
        _draw_end_overlay(false)
    elif game_mode == "victory":
        _draw_end_overlay(true)
    elif game_mode == "floor_intro":
        _draw_floor_intro()
    elif game_mode == "pause":
        _draw_pause()
    elif game_mode == "settings":
        _draw_settings()
    _draw_tutorial_overlay()
    _draw_mobile_controls()


func _draw_background() -> void:
    for i in range(0, 14):
        var px: float = float(i * 73 + 19)
        var py: float = 54.0 + sin(float(i) * 1.67) * 24.0
        draw_circle(Vector2(px, py), 1.0 + float(i % 3), Color(0.50, 0.64, 0.72, 0.20))


func _draw_room() -> void:
    # El suelo y los muros los dibuja la escena de la sala (TileMapLayer).
    _draw_room_depth()
    _draw_wear()
    _draw_decor()
    _draw_prop_shadows()
    # Nuevos efectos ambientales; no forman parte de colisiones ni IA.
    _draw_visual_atmosphere()
    # Objetos a ras de suelo: siempre por debajo de personajes y estatuas.
    _draw_door()
    _draw_inscription_plaque()
    _draw_traps()
    if _has("sello"):
        _draw_seal(seal_pos)
    if _enemy_kind() == "testigo" and _enemy_active():
        _draw_watcher_eye(eye_pos)
    for i in range(relics.size()):
        _draw_corpse(relics[i], (current_floor * 5 + current_room) * 3 + i)
    for ally in allies:
        if not bool(ally["alive"]) and str(ally["dead_key"]) == _room_key():
            _draw_corpse(ally["dead_pos"], int(ally["seed"]))
    if not pilgrim_corpse.is_empty() and pilgrim_corpse["key"] == _room_key():
        _draw_corpse(pilgrim_corpse["pos"], 1)
    for i in range(relics.size()):
        if not collected[i]:
            _draw_relic(relics[i], i)
    for item in room_items:
        _draw_item(item)
    for i in range(drops.size()):
        _draw_relic(drops[i]["pos"], 7 + i)
    _draw_depth_sorted()
    _draw_dissolve_fx()
    if not fireballs.is_empty():
        _draw_fireballs()
    _draw_lighting()
    _draw_segador_threads()
    _draw_strike_fx()
    _draw_pulse_fx()
    _draw_pickup_fx()
    _draw_float_fx()
    _draw_nuca()
    if damage_cd > 0.0:
        # Destello rojo que se apaga durante la invulnerabilidad.
        draw_rect(ARENA, Color(0.75, 0.08, 0.14, 0.16 * clampf(damage_cd / 1.5, 0.0, 1.0) ** 2))
    _draw_object_labels()


## Profundidad cenital: la luz cae desde arriba. El muro del fondo muestra
## su cara (más oscura abajo) y proyecta sombra sobre el suelo; los muros
## laterales y el frontal se ven por su remate, con un borde iluminado.
const WALL_BACK := Rect2(40, 122, 880, 36) # cara visible del muro del fondo
const WALL_LEFT_X := 67.0
const WALL_RIGHT_X := 893.0
const WALL_FRONT_Y := 552.0
func _draw_room_depth() -> void:
    var shade := Color(0.01, 0.015, 0.03)
    var floor_l: float = WALL_LEFT_X
    var floor_r: float = WALL_RIGHT_X
    # Cara del muro del fondo: luz arriba, sombra al pie.
    _vgradient(Rect2(floor_l - 19.0, WALL_BACK.position.y, floor_r - floor_l + 38.0, WALL_BACK.size.y), Color(1.0, 0.95, 0.82, 0.07), Color(shade, 0.34))
    draw_rect(Rect2(floor_l - 19.0, WALL_BACK.position.y, floor_r - floor_l + 38.0, 2.0), Color(0.85, 0.86, 0.74, 0.22))
    # Sombra que el muro del fondo proyecta sobre el suelo.
    _vgradient(Rect2(floor_l, WALL_BACK.end.y, floor_r - floor_l, 30.0), Color(shade, 0.42), Color(shade, 0.0))
    # Muros laterales: remate iluminado y oclusión en la base.
    for side in [-1.0, 1.0]:
        var edge: float = floor_l if side < 0.0 else floor_r
        var x0: float = edge if side < 0.0 else edge - 16.0
        _hgradient(Rect2(x0, WALL_BACK.end.y, 16.0, WALL_FRONT_Y - WALL_BACK.end.y), Color(shade, 0.26 if side < 0.0 else 0.0), Color(shade, 0.0 if side < 0.0 else 0.26))
        draw_rect(Rect2(edge - (2.0 if side < 0.0 else 0.0), WALL_BACK.position.y, 2.0, WALL_FRONT_Y - WALL_BACK.position.y + 23.0), Color(0.80, 0.82, 0.70, 0.16))
    # Muro frontal: se ve desde arriba, así que solo su remate recibe luz.
    _vgradient(Rect2(floor_l, WALL_FRONT_Y - 12.0, floor_r - floor_l, 12.0), Color(shade, 0.0), Color(shade, 0.18))
    draw_rect(Rect2(floor_l - 19.0, WALL_FRONT_Y, floor_r - floor_l + 38.0, 2.0), Color(0.82, 0.84, 0.72, 0.24))
    draw_rect(Rect2(floor_l - 19.0, WALL_FRONT_Y + 2.0, floor_r - floor_l + 38.0, 21.0), Color(shade, 0.22))


func _vgradient(rect: Rect2, top: Color, bottom: Color) -> void:
    draw_polygon(PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
        PackedColorArray([top, top, bottom, bottom]))


func _hgradient(rect: Rect2, left: Color, right: Color) -> void:
    draw_polygon(PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
        PackedColorArray([left, right, right, left]))


## [LUZ] Penumbra con luces dinámicas. Rejilla de vértices con oscuridad
## interpolada: el personaje lleva su luz (menor con la linterna apagada);
## braseros, almas, Ghoul, conjuros y la salida abierta iluminan su entorno.
## Nunca llega al negro: la sala siempre se lee (guía de estilo).
const LIGHT_CELL := 24.0
const LIGHT_CELL_MOBILE := 32.0 # rejilla más gruesa en móvil: menos coste por fotograma
func _lights() -> Array:
    var list: Array = [] # [pos, radio, intensidad]
    # Sin antorcha encendida solo se ve un círculo corto alrededor.
    list.append([player_pos + Vector2(0.0, -20.0), 205.0 if torch_on else 110.0, 1.0 if torch_on else 0.85])
    for item in room_items:
        list.append([item["pos"], 62.0, 0.5])
    for drop in drops:
        list.append([drop["pos"], 80.0, 0.6])
    for d in decor_cache:
        if d[0] == "velas" and decor_cache_key == _room_key():
            list.append([Vector2(d[1]) + Vector2(11, 8), 58.0, 0.45])
    if _pilgrim_present() and pilgrim_state != "dead":
        list.append([pilgrim_pos + Vector2(0.0, -20.0), 60.0, 0.5]) # se le distingue siempre
    if allies_here:
        for ally in allies:
            if bool(ally["alive"]):
                list.append([Vector2(ally["pos"]) + Vector2(0.0, -20.0), 55.0, 0.45])
    for prop in room_props:
        if prop["light"]:
            var rect: Rect2 = prop["rect"]
            var flicker: float = 0.92 + 0.08 * sin(elapsed * 9.0 + rect.position.x)
            list.append([rect.get_center(), 130.0 * flicker, 0.85])
    for i in range(relics.size()):
        if not collected[i]:
            list.append([relics[i], 70.0, 0.55])
    if _enemy_active():
        # Las amenazas siempre se distinguen (juego limpio); el Ghoul arde.
        list.append([enemy_pos + Vector2(0.0, -24.0), 120.0 if _enemy_kind() == "ghoul" else 70.0, 0.8 if _enemy_kind() == "ghoul" else 0.45])
    for ball in fireballs:
        list.append([ball["pos"], 85.0, 0.9])
    if _room_ready():
        list.append([door_pos + Vector2(20.0, 0.0), 95.0, 0.6])
    if _has("altar"):
        list.append([altar_pos, 85.0, 0.6])
    return list


func _draw_lighting() -> void:
    if torch_on:
        # Tono cálido de la linterna alrededor del personaje.
        for r in range(4, 0, -1):
            draw_circle(player_pos + Vector2(0, -20), float(r) * 34.0, Color(1.0, 0.78, 0.45, 0.018))
    var lights: Array = _lights()
    var base_dark: float = 0.50 if torch_on else 0.68
    var fear_edge: float = fear / 100.0 * 0.28
    var cell: float = LIGHT_CELL_MOBILE if touch_enabled else LIGHT_CELL
    var cols: int = int(ceil(ARENA.size.x / cell)) + 1
    var rows: int = int(ceil(ARENA.size.y / cell)) + 1
    var center: Vector2 = ARENA.get_center()
    var alpha: PackedFloat32Array = PackedFloat32Array()
    alpha.resize(cols * rows)
    for r in range(rows):
        for c in range(cols):
            var p := ARENA.position + Vector2(c, r) * cell
            var lit: float = 0.0
            for light in lights:
                var d: float = p.distance_to(light[0])
                if d < light[1]:
                    lit = maxf(lit, pow(1.0 - d / light[1], 1.4) * light[2])
            var edge: float = clampf((p - center).length() / (ARENA.size.x * 0.55) - 0.35, 0.0, 1.0)
            alpha[r * cols + c] = clampf(base_dark * (1.0 - lit) + fear_edge * edge, 0.0, 0.85)
    var tint := Color(0.01, 0.015, 0.035)
    for r in range(rows - 1):
        for c in range(cols - 1):
            var a0: float = alpha[r * cols + c]
            var a1: float = alpha[r * cols + c + 1]
            var a2: float = alpha[(r + 1) * cols + c + 1]
            var a3: float = alpha[(r + 1) * cols + c]
            if a0 + a1 + a2 + a3 < 0.01:
                continue
            var p := ARENA.position + Vector2(c, r) * cell
            draw_polygon(
                PackedVector2Array([p, p + Vector2(cell, 0), p + Vector2(cell, cell), p + Vector2(0, cell)]),
                PackedColorArray([Color(tint, a0), Color(tint, a1), Color(tint, a2), Color(tint, a3)]))


## Destello al recoger un alma: anillo que se expande y "+7" que asciende.
func _draw_pickup_fx() -> void:
    for fx in pickup_fx:
        var t: float = float(fx["t"])
        var p: Vector2 = fx["pos"]
        var a: float = clampf(1.0 - t / 1.1, 0.0, 1.0)
        draw_arc(p + Vector2(0, -8), 10.0 + t * 46.0, 0.0, TAU, 32, Color(0.75, 0.93, 1.0, a * 0.8), 2.0)
        for k in range(6):
            var ang: float = float(k) / 6.0 * TAU + t * 2.0
            draw_circle(p + Vector2(cos(ang), sin(ang) * 0.6) * (8.0 + t * 30.0) + Vector2(0, -10 - t * 14.0), 2.0 * a, Color(0.85, 0.97, 1.0, a))
        var label: String = fx.get("text", "+7")
        var tone: Color = fx.get("color", Color(0.75, 0.93, 1.0))
        draw_string(font, p + Vector2(-60, -30 - t * 26.0), label, HORIZONTAL_ALIGNMENT_CENTER, 120, 16, Color(tone.r, tone.g, tone.b, a))


## Sombras de contacto de los objetos de la sala (antes horneadas en el PNG)
## y halo vivo de los braseros.
func _draw_prop_shadows() -> void:
    for prop in room_props:
        var rect: Rect2 = prop["rect"]
        if prop["shadow"]:
            _draw_soft_shadow(Vector2(rect.get_center().x, float(prop["base"]) - 3.0), rect.size.x * 0.6, 1.1)
        if prop["light"]:
            var flicker: float = 0.5 + 0.5 * sin(elapsed * 7.0 + rect.position.x) * sin(elapsed * 2.3)
            var c := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.35)
            for r in range(4, 0, -1):
                draw_circle(c, 10.0 + float(r) * 7.0, Color(1.0, 0.78, 0.40, 0.03 + 0.012 * flicker))


## [VISUAL UPGRADE] Ordenación por profundidad: objetos de la sala, personajes,
## altar y libro se dibujan de arriba abajo según la y de su base.
func _draw_depth_sorted() -> void:
    var items: Array = [] # [y_base, tipo, dato]
    items.append([player_pos.y, "player", null])
    if _enemy_active():
        items.append([enemy_pos.y, "enemy", null])
    if _pilgrim_present() and pilgrim_state != "dead":
        items.append([pilgrim_pos.y, "pilgrim", null])
    for i in range(allies.size()):
        if bool(allies[i]["alive"]) and allies_here:
            items.append([Vector2(allies[i]["pos"]).y, "ally", i])
    if _has("altar"):
        items.append([altar_pos.y + 22.0, "altar", null])
    if in_tutorial:
        items.append([DUMMY_POS.y, "dummy", null])
    if _has("archivo"):
        items.append([book_pos.y + 37.0, "book", null]) # justo después de la mesa
    for i in range(room_props.size()):
        items.append([float(room_props[i]["base"]), "prop", i])
    items.sort_custom(func(x, y): return x[0] < y[0])
    for item in items:
        match item[1]:
            "player":
                _draw_player()
            "enemy":
                _draw_enemy()
            "pilgrim":
                _draw_pilgrim()
            "ally":
                _draw_ally(item[2])
            "dummy":
                _draw_dummy()
            "altar":
                _draw_altar(altar_pos)
            "book":
                _draw_letter(book_pos)
            "prop":
                var prop: Dictionary = room_props[item[2]]
                _draw_texture_flipped(prop["tex"], prop["rect"], prop["flip"])


func _draw_object_labels() -> void:
    # Etiquetas por encima de todo para que nunca queden tapadas.
    if _has("altar") and player_pos.distance_to(altar_pos) < 150.0:
        _label_center("INTERCAMBIO [E]", altar_pos + Vector2(0.0, 46.0), CREAM)
    if _has("archivo") and not letter_found and player_pos.distance_to(archive_pos) < 150.0:
        _label_center("LEER CARTA [E]", archive_pos + Vector2(0.0, 30.0), CREAM)
    if _has("sello") and not seal_acquired:
        _label_center("SELLO [E]", seal_pos + Vector2(0.0, 56.0), Color("#e2c48a"))
    if _enemy_active():
        _draw_enemy_health()
    _draw_ally_labels()
    _draw_inscription_text()
    if _pilgrim_present():
        _draw_pilgrim_overlay()


func _label_center(msg: String, at: Vector2, color: Color) -> void:
    var size: int = 12
    var width: float = font.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
    var box := Rect2(at.x - width * 0.5 - 6.0, at.y - 12.0, width + 12.0, 17.0)
    draw_rect(box, Color(0.03, 0.05, 0.06, 0.72))
    draw_string(font, Vector2(box.position.x + 6.0, at.y), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## [VISUAL UPGRADE] Puntos luminosos ligeros: no modifican colisiones ni reglas.
func _draw_visual_atmosphere() -> void:
    var amount: int = 13
    for i in range(amount):
        var seed_value: float = float(i * 71 + (current_floor * 5 + current_room) * 109)
        var x_pos: float = 92.0 + fmod(seed_value * 3.7, 775.0)
        var y_pos: float = 182.0 + fmod(seed_value * 1.9 + sin(elapsed * 0.4 + seed_value) * 8.0, 349.0)
        var intensity: float = 0.11 + 0.06 * sin(elapsed * 1.3 + seed_value)
        draw_circle(Vector2(x_pos, y_pos), 1.0, Color(0.85, 0.78, 0.60, intensity))


## Elipse rellena (sombras, halos de suelo): círculo aplastado en vertical.
func _draw_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
    draw_set_transform(center, 0.0, Vector2(1.0, radius_y / radius_x))
    draw_circle(Vector2.ZERO, radius_x, color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Sombra de contacto suave, con la misma luz que las sombras del fondo.
func _draw_soft_shadow(at: Vector2, radius_x: float, strength: float = 1.0) -> void:
    for i in range(3):
        var k: float = 1.0 - float(i) * 0.28
        _draw_ellipse(at, radius_x * k, radius_x * k * 0.32, Color(0.0, 0.0, 0.0, 0.13 * strength))

## [VISUAL UPGRADE] Sombra leve de contacto, anclada a los pies del protagonista.
func draw_ellipse_fake_shadow(at: Vector2) -> void:
    _draw_soft_shadow(at + Vector2(0.0, 1.0), 15.0)


## Ojo del Testigo tallado en el muro del fondo: abierto (rojo) o cerrado.
func _draw_watcher_eye(at: Vector2) -> void:
    var almond := PackedVector2Array()
    for i in range(16):
        var t: float = float(i) / 16.0 * TAU
        almond.append(at + Vector2(cos(t) * 24.0, sin(t) * 10.0 * (1.0 - 0.35 * absf(cos(t)))))
    draw_colored_polygon(almond, Color("#1a1c17"))
    almond.append(almond[0])
    draw_polyline(almond, Color("#5d6450"), 2.0)
    if watcher_open:
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 4.0)
        for r in range(3, 0, -1):
            draw_circle(at, 7.0 + float(r) * 4.0, Color(0.82, 0.25, 0.30, 0.07 + 0.03 * pulse))
        draw_circle(at, 7.5, Color("#c2414f"))
        draw_circle(at, 3.2, Color("#1a0d10"))
        draw_circle(at + Vector2(-2.5, -2.5), 1.4, Color(1.0, 0.85, 0.85, 0.9))
        # Mirada proyectada sobre la sala: indica que moverse ahora es peligroso.
        draw_polygon(PackedVector2Array([at + Vector2(-8, 10), at + Vector2(8, 10), at + Vector2(140, 260), at + Vector2(-140, 260)]),
            PackedColorArray([Color(0.82, 0.2, 0.25, 0.10 + 0.04 * pulse), Color(0.82, 0.2, 0.25, 0.10 + 0.04 * pulse), Color(0.82, 0.2, 0.25, 0.0), Color(0.82, 0.2, 0.25, 0.0)]))
    elif fmod(room_elapsed, 6.0) >= 5.4:
        # A punto de abrirse: el párpado tiembla y asoma una rendija roja.
        var jitter := Vector2(randf_range(-1.5, 1.5), randf_range(-1.0, 1.0))
        var open_k: float = (fmod(room_elapsed, 6.0) - 5.4) / 0.6
        draw_line(at + jitter + Vector2(-16, 0), at + jitter + Vector2(16, 0), Color(0.85, 0.25, 0.3, 0.5 + 0.5 * open_k), 2.0 + 3.0 * open_k)
        draw_circle(at + jitter, 2.0 + 3.0 * open_k, Color("#c2414f"))
    else:
        draw_arc(at + Vector2(0.0, -6.0), 22.0, 0.35, PI - 0.35, 18, Color("#72858d"), 2.0)
        for i in range(5):
            var x: float = -14.0 + float(i) * 7.0
            draw_line(at + Vector2(x, 9.0), at + Vector2(x * 1.15, 13.0), Color("#5d6450"), 1.0)


## Círculo rúnico en el suelo con el sello del Testigo.
func _draw_seal(at: Vector2) -> void:
    var ring: Color = SOUL if seal_acquired else Color("#be9b68")
    _draw_ellipse(at + Vector2(0.0, 6.0), 44.0, 20.0, Color(ring.r, ring.g, ring.b, 0.08))
    draw_set_transform(at + Vector2(0.0, 6.0), 0.0, Vector2(1.0, 0.46))
    draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 48, Color(ring.r, ring.g, ring.b, 0.75), 2.0)
    draw_arc(Vector2.ZERO, 33.0, 0.0, TAU, 40, Color(ring.r, ring.g, ring.b, 0.35), 1.0)
    for i in range(8):
        var t: float = float(i) / 8.0 * TAU + elapsed * 0.25
        draw_line(Vector2(cos(t), sin(t)) * 34.0, Vector2(cos(t), sin(t)) * 41.0, Color(ring.r, ring.g, ring.b, 0.8), 2.0)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if seal_acquired:
        return
    var lift: float = sin(elapsed * 2.0) * 3.0
    var c := at + Vector2(0.0, -14.0 + lift)
    for r in range(3, 0, -1):
        draw_circle(c, 8.0 + float(r) * 5.0, Color(0.95, 0.78, 0.45, 0.06))
    var hexagon := PackedVector2Array()
    for i in range(6):
        var t: float = float(i) / 6.0 * TAU + PI / 6.0
        hexagon.append(c + Vector2(cos(t), sin(t)) * 11.0)
    draw_colored_polygon(hexagon, Color("#c9a35f"))
    hexagon.append(hexagon[0])
    draw_polyline(hexagon, Color("#f2dc9f"), 1.5)
    draw_circle(c, 3.5, Color("#5a3f1d"))


## [VISUAL UPGRADE] Salida en el muro derecho vista desde arriba: losa con runas
## cuando está sellada; vano abierto con luz que entra cuando está lista.
func _draw_door() -> void:
    var ready: bool = _room_ready()
    var tone: Color = Color("#82bdaf") if ready else Color("#b04d5e")
    var gap := Rect2(door_pos.x + 28.0, door_pos.y - 36.0, 19.0, 72.0)
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.2)
    # Luz en el umbral.
    _draw_ellipse(Vector2(gap.position.x - 30.0, door_pos.y), 34.0, 40.0, Color(tone.r, tone.g, tone.b, 0.05 + 0.03 * pulse))
    if ready:
        draw_rect(gap, Color("#05080a"))
        draw_polygon(PackedVector2Array([gap.position, gap.position + Vector2(0, gap.size.y), Vector2(gap.position.x - 60.0, gap.end.y + 18.0), Vector2(gap.position.x - 60.0, gap.position.y - 18.0)]),
            PackedColorArray([Color(tone.r, tone.g, tone.b, 0.22), Color(tone.r, tone.g, tone.b, 0.22), Color(tone.r, tone.g, tone.b, 0.0), Color(tone.r, tone.g, tone.b, 0.0)]))
        draw_rect(Rect2(gap.position.x + 4.0, gap.position.y + 4.0, 3.0, gap.size.y - 8.0), Color(tone.r, tone.g, tone.b, 0.35 + 0.2 * pulse))
    else:
        draw_rect(gap, Color("#2b3027"))
        draw_rect(Rect2(gap.position, Vector2(3.0, gap.size.y)), Color("#3d4436"))
        for i in range(4):
            var y: float = gap.position.y + 11.0 + float(i) * 16.0
            draw_line(Vector2(gap.position.x + 5.0, y), Vector2(gap.position.x + 14.0, y + 5.0), Color(tone.r, tone.g, tone.b, 0.55 + 0.35 * pulse), 2.0)
    # Jambas de piedra.
    for y in [gap.position.y - 9.0, gap.end.y]:
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#454c3c"))
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 2.0), Color("#68715a"))
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#15170f"), false, 1.0)
    _label_center("SALIDA" if ready else "SELLADA", Vector2(door_pos.x - 4.0, gap.position.y - 16.0), tone)


## Altar a proporción real (78x112 escalado de forma uniforme).
func _draw_altar(at: Vector2) -> void:
    var scale: float = 0.75
    var tex: Texture2D = art["knowledge_altar"]
    var size := Vector2(tex.get_width(), tex.get_height()) * scale
    # La base visible del sprite está en y=99 de 112.
    var origin := Vector2(at.x - size.x * 0.5, at.y + 22.0 - 99.0 * scale)
    _draw_soft_shadow(Vector2(at.x, at.y + 20.0), 30.0)
    # Luz cálida de ofrenda: el sprite original es muy oscuro sobre este suelo.
    var flicker: float = 0.5 + 0.5 * sin(elapsed * 3.1) * sin(elapsed * 1.3)
    _draw_ellipse(Vector2(at.x, at.y + 18.0), 48.0, 20.0, Color(0.95, 0.72, 0.38, 0.07 + 0.03 * flicker))
    for r in range(3, 0, -1):
        draw_circle(at + Vector2(0.0, -14.0), 10.0 + float(r) * 7.0, Color(0.95, 0.74, 0.42, 0.035 + 0.015 * flicker))
    draw_texture_rect(tex, Rect2(origin, size), false, Color(1.55, 1.42, 1.22))
    # Velas a los lados del altar.
    for side in [-1.0, 1.0]:
        var c := Vector2(at.x + side * 30.0, at.y + 14.0)
        draw_rect(Rect2(c.x - 2.0, c.y - 9.0, 4.0, 9.0), Color("#d8cfb4"))
        draw_circle(c + Vector2(0.0, -12.0), 2.2 + flicker * 0.6, Color(1.0, 0.78, 0.35, 0.95))
        draw_circle(c + Vector2(0.0, -12.0), 6.0, Color(1.0, 0.7, 0.3, 0.12))


## Libro del archivo sobre la mesa: cerrado hasta leerlo; después hojea páginas.
func _draw_letter(at: Vector2) -> void:
    var sheet: Texture2D = art["knowledge_book_sheet"]
    var frame: int = 0
    if letter_found:
        frame = 15 + int(elapsed * 10.0) % 86
    else:
        var glow: float = 0.08 + 0.05 * sin(elapsed * 2.4)
        draw_circle(at + Vector2(0.0, -8.0), 22.0, Color(0.59, 0.79, 0.55, glow))
    var scale: float = 1.5
    # Celda de 64x64; la base del libro está en y=45.
    # Desde y=26 de la celda: libro y páginas, sin los glifos que flotaban
    # sobre la estatua de detrás.
    var region := Rect2(float(frame * 64) + 4.0, 26.0, 56.0, 22.0)
    var dest := Rect2(at.x - 28.0 * scale, at.y - 19.0 * scale, 56.0 * scale, 22.0 * scale)
    draw_texture_rect_region(sheet, dest, region)


## Fragmento de alma: cristal flotante con halo y sombra fija en el suelo.
func _draw_relic(at: Vector2, index: int) -> void:
    var wave: float = sin(elapsed * 2.3 + float(index) * 2.5) * 4.0
    var p := at + Vector2(0, -8.0 + wave)
    _draw_soft_shadow(at + Vector2(0.0, 10.0), 9.0 - wave * 0.5, 0.8)
    for r in range(3, 0, -1):
        draw_circle(p, 6.0 + float(r) * 5.0, Color(0.43, 0.76, 0.87, 0.05))
    var top := p + Vector2(0, -14)
    var bottom := p + Vector2(0, 12)
    var left := p + Vector2(-7, -1)
    var right := p + Vector2(7, -1)
    draw_colored_polygon(PackedVector2Array([top, p + Vector2(0, -1), bottom, left]), Color("#bfe9f2"))
    draw_colored_polygon(PackedVector2Array([top, right, bottom, p + Vector2(0, -1)]), Color("#5ea7bb"))
    draw_polyline(PackedVector2Array([top, right, bottom, left, top]), Color("#e8fbff"), 1.0)
    var sparkle: float = 0.5 + 0.5 * sin(elapsed * 5.0 + float(index))
    var s := top + Vector2(3, 2)
    draw_line(s + Vector2(-3, 0), s + Vector2(3, 0), Color(1, 1, 1, sparkle), 1.0)
    draw_line(s + Vector2(0, -3), s + Vector2(0, 3), Color(1, 1, 1, sparkle), 1.0)


func _enemy_rect() -> Rect2:
    return Rect2(enemy_pos.x - 15.0, enemy_pos.y + 4.0 - 56.0, 30.0, 56.0)


func _track_enemy_visual(dt: float) -> void:
    var delta_pos: Vector2 = enemy_pos - enemy_prev_pos
    enemy_moving = dt > 0.0 and delta_pos.length() > 8.0 * dt
    # Mientras se mueve mira hacia donde va; quieto, mira al jugador.
    var look: Vector2 = delta_pos if enemy_moving else (player_pos - enemy_pos)
    if look.length() > 0.5:
        if absf(look.x) > absf(look.y):
            enemy_facing = 2 if look.x > 0.0 else 3
        else:
            enemy_facing = 0 if look.y > 0.0 else 1
    enemy_prev_pos = enemy_pos


func _enemy_frame(kind: String) -> int:
    match kind:
        "testigo":
            # La regla se lee en el sprite: columnas 0-3 ojo abierto, 4-7 cerrado.
            return (0 if watcher_open else 4) + int(elapsed * 6.0) % 4
        "ghoul":
            return 2 + int(elapsed * 9.0) % 4 if enemy_moving else int(elapsed * 2.5) % 2
        "segador":
            if seg_state == "tensa":
                return 6
            if seg_state == "engancha":
                return 7
            return 2 + int(elapsed * 12.0) % 4 if enemy_moving else int(elapsed * 2.0) % 2
        _:
            if enemy_alert and (wizard_cast_cd > 2.45 or wizard_cast_cd < WIZARD_CHARGE): # carga o acaba de lanzar
                return 6 + int(elapsed * 8.0) % 2
            return 2 + int(elapsed * 7.0) % 4 if enemy_moving else int(elapsed * 2.0) % 2


func _draw_enemy() -> void:
    var kind: String = _enemy_kind()
    var sheet: Texture2D = art["enemy_" + kind]
    var frame: int = _enemy_frame(kind)
    var region := Rect2(float(frame) * ENEMY_CELL.x, float(enemy_facing) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
    var lift: float = 0.0
    if kind == "testigo":
        lift = 8.0 + sin(elapsed * 2.6) * 2.0 # flota: la sombra se queda en el suelo
    var feet := Vector2(roundf(enemy_pos.x), roundf(enemy_pos.y + 4.0 - lift))
    var footprint: float = 17.0 if kind == "testigo" else 14.0
    _draw_soft_shadow(enemy_pos + Vector2(0.0, 3.0), footprint, 1.0 if lift == 0.0 else 0.7)
    if enemy_alert:
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 8.0)
        _draw_ellipse(enemy_pos + Vector2(0.0, 3.0), footprint + 9.0, (footprint + 9.0) * 0.34, Color(0.85, 0.22, 0.28, 0.18 + 0.12 * pulse))
    if enemy_stun > 0.0:
        _draw_ellipse(enemy_pos + Vector2(0.0, 3.0), footprint + 9.0, (footprint + 9.0) * 0.34, Color(0.56, 0.78, 0.84, 0.30))
    if kind == "ghoul":
        # Las brasas iluminan el suelo a su alrededor.
        draw_circle(enemy_pos + Vector2(0.0, -30.0), 30.0, Color(1.0, 0.55, 0.2, 0.05 + 0.02 * sin(elapsed * 9.0)))
    var tint := Color(0.75, 0.85, 1.0, 1.0) if enemy_stun > 0.0 else Color.WHITE
    if enemy_hit_t > 0.0 and int(enemy_hit_t * 30.0) % 2 == 0:
        tint = Color(1.0, 0.42, 0.38, 1.0) # destello del golpe
    var dest := Rect2(feet.x - ENEMY_CELL.x * 0.5, feet.y - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y)
    draw_texture_rect_region(sheet, dest, region, tint)
    if kind == "hechicero" and enemy_alert and wizard_cast_cd < WIZARD_CHARGE:
        # Aviso justo: el orbe crece antes de lanzar el conjuro (y es vulnerable).
        var k: float = 1.0 - wizard_cast_cd / WIZARD_CHARGE
        # Donde el sprite sostiene el orbe: sobre la cabeza de frente, en la mano de lado.
        var hand: Vector2 = [Vector2(0, -57), Vector2(0, -57), Vector2(19, -49), Vector2(-19, -49)][enemy_facing]
        var orb := feet + hand
        draw_circle(orb, 5.0 + 9.0 * k, Color(1.0, 0.6, 0.25, 0.15 + 0.2 * k))
        draw_circle(orb, 1.5 + 3.0 * k, Color(1.0, 0.88, 0.6, 0.9))


## Barra de vida y estado de la entidad: siempre sobre la escena.
func _draw_enemy_health() -> void:
    var top: float = _enemy_rect().position.y - (8.0 if _enemy_kind() == "testigo" else 0.0)
    var near: bool = player_pos.distance_to(enemy_pos) < 300.0
    if enemy_hp >= enemy_max and not near:
        return
    var vulnerable: bool = _enemy_vulnerable()
    var bar := Rect2(enemy_pos.x - 24.0, top - 12.0, 48.0, 6.0)
    draw_rect(bar.grow(1.0), Color(0, 0, 0, 0.7))
    draw_rect(bar, Color("#3a2328"))
    var fill: Color = Color("#d1474f") if vulnerable else Color("#7d6f73")
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(enemy_hp / enemy_max, 0.0, 1.0), bar.size.y)), fill)
    var edge: Color = Color("#e3bd7b") if vulnerable else Color("#5b6266")
    if vulnerable and not _enemy_kind() == "ghoul":
        edge.a = 0.6 + 0.4 * sin(elapsed * 10.0)
    draw_rect(bar.grow(1.0), edge, false, 1.0)
    var state: String = ""
    var tone: Color = CREAM
    if enemy_stun > 0.0:
        state = "ATURDIDO"
        tone = SOUL
    elif not _enemy_kind() == "ghoul":
        state = "VULNERABLE" if vulnerable else "INMUNE"
        tone = Color("#e3bd7b") if vulnerable else Color("#9aa19a")
    if state != "":
        _label_center(state, Vector2(enemy_pos.x, bar.position.y - 4.0), tone)


## Entidad desterrada: el sprite se deshace hacia arriba en ceniza luminosa.
func _draw_dissolve_fx() -> void:
    for fx in dissolve_fx:
        var t: float = float(fx["t"])
        var k: float = clampf(t / 1.4, 0.0, 1.0)
        var p: Vector2 = fx["pos"]
        var sheet: Texture2D = art["enemy_" + str(fx["kind"])]
        var region := Rect2(float(fx["frame"]) * ENEMY_CELL.x, float(fx["facing"]) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
        var dest := Rect2(p.x - ENEMY_CELL.x * 0.5, p.y + 4.0 - ENEMY_FEET_Y - k * 18.0, ENEMY_CELL.x, ENEMY_CELL.y)
        draw_texture_rect_region(sheet, dest, region, Color(0.75 + k, 0.9, 1.0, (1.0 - k) * 0.9))
        for i in range(14):
            var ang: float = float(i) * 2.4
            var r: float = 6.0 + k * (22.0 + float(i % 4) * 6.0)
            var q := p + Vector2(cos(ang) * r, -28.0 - k * (30.0 + float(i % 5) * 8.0) + sin(ang) * r * 0.4)
            draw_circle(q, 2.2 * (1.0 - k) + 0.6, Color(0.75, 0.93, 1.0, (1.0 - k) * 0.9))


## Estela de fuego del golpe de antorcha.
func _draw_strike_fx() -> void:
    if strike_fx <= 0.0:
        return
    var k: float = 1.0 - strike_fx / 0.25
    var c := player_pos + Vector2(0.0, -20.0)
    var mid: float = strike_dir.angle()
    var a0: float = mid - 1.1
    var a1: float = mid - 1.1 + 2.2 * minf(1.0, k * 1.6)
    for i in range(3):
        var r: float = 34.0 + float(i) * 9.0
        var col: Color = [Color(1.0, 0.85, 0.42), Color(0.94, 0.54, 0.23), Color(0.76, 0.25, 0.18)][i]
        col.a = (1.0 - k) * 0.85
        draw_arc(c, r, a0, a1, 16, col, 5.0 - float(i))
    var tip := c + Vector2.from_angle(a1) * 44.0
    draw_circle(tip, 7.0 * (1.0 - k), Color(1.0, 0.82, 0.45, 0.7 * (1.0 - k)))


## Onda de Resonancia: anillo que se expande hasta su alcance de daño.
func _draw_pulse_fx() -> void:
    if pulse_fx < 0.0:
        return
    var k: float = clampf(pulse_fx / 0.45, 0.0, 1.0)
    var r: float = PULSE_RADIUS * (1.0 - pow(1.0 - k, 3.0))
    var a: float = 1.0 - clampf(pulse_fx / 0.6, 0.0, 1.0)
    draw_set_transform(player_pos + Vector2(0.0, -6.0), 0.0, Vector2(1.0, 0.6))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, Color(0.75, 0.93, 1.0, a), 4.0)
    draw_arc(Vector2.ZERO, r * 0.8, 0.0, TAU, 64, Color(0.56, 0.78, 0.84, a * 0.6), 2.0)
    draw_circle(Vector2.ZERO, r, Color(0.56, 0.78, 0.84, a * 0.08))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_float_fx() -> void:
    for fx in float_fx:
        var t: float = float(fx["t"])
        var a: float = clampf(1.0 - t / 0.9, 0.0, 1.0)
        var col: Color = fx["color"]
        var p: Vector2 = fx["pos"] + Vector2(0.0, -t * 24.0)
        draw_string(font, p + Vector2(-110, 1), str(fx["text"]), HORIZONTAL_ALIGNMENT_CENTER, 220, 16, Color(0, 0, 0, a * 0.8))
        draw_string(font, p + Vector2(-111, 0), str(fx["text"]), HORIZONTAL_ALIGNMENT_CENTER, 220, 16, Color(col.r, col.g, col.b, a))


## Cadáver del antiguo dueño del alma: tendido en el suelo, bajo la luz de la sala.
func _draw_corpse(at: Vector2, seed_index: int) -> void:
    var tex: Texture2D = CORPSES[seed_index % CORPSES.size()]
    var size := Vector2(tex.get_width(), tex.get_height())
    var dest := Rect2(roundf(at.x - size.x * 0.5), roundf(at.y + 4.0 - size.y * 0.5), size.x, size.y)
    _draw_texture_flipped(tex, dest, seed_index % 2 == 1) # variedad: espejo


## Dibuja una textura en su rectángulo, volteada en horizontal si se pide.
## (Un Rect2 de ancho negativo no sirve: Godot lo desplaza un ancho.)
func _draw_texture_flipped(tex: Texture2D, dest: Rect2, flip: bool) -> void:
    if not flip:
        draw_texture_rect(tex, dest, false)
        return
    draw_set_transform(Vector2(dest.position.x + dest.size.x, dest.position.y), 0.0, Vector2(-1.0, 1.0))
    draw_texture_rect(tex, Rect2(Vector2.ZERO, dest.size), false)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Objeto recogible en el suelo: icono que flota sobre su sombra.
func _draw_item(item: Dictionary) -> void:
    var p: Vector2 = item["pos"]
    var wave: float = sin(elapsed * 2.6 + p.x) * 2.5
    _draw_soft_shadow(p + Vector2(0.0, 8.0), 11.0, 0.8)
    draw_circle(p + Vector2(0.0, -8.0), 18.0, Color(0.95, 0.78, 0.45, 0.06 + 0.03 * sin(elapsed * 3.0)))
    draw_texture_rect(ICONS[item["kind"]], Rect2(p + Vector2(-16.0, -26.0 + wave), Vector2(32.0, 32.0)), false)


func _draw_fireballs() -> void:
    var frame: int = 1 + (int(elapsed * 11.0) % 3)
    for ball in fireballs:
        var p: Vector2 = ball["pos"]
        draw_circle(p, 16.0, Color(1.0, 0.55, 0.2, 0.12))
        draw_texture_rect(art["fireball_%d" % frame], Rect2(p.x - 20, p.y - 20, 40, 40), false)


func _draw_player() -> void:
    ## [VISUAL UPGRADE] Spritesheet top-down, arte original y cuatro orientaciones.
    if art.has("visual_hero"):
        var direction_index: int = 0 # frente/abajo
        if absf(player_dir.x) > absf(player_dir.y):
            direction_index = 2 if player_dir.x > 0.0 else 3
        elif player_dir.y < 0.0:
            direction_index = 1 # espalda/arriba
        var frame_index: int = int(elapsed * 2.0) % 2 # Idle A/B
        if game_mode == "dead":
            frame_index = 8
        elif damage_cd > 0.0:
            frame_index = 7
        elif visual_interaction_left > 0.0:
            frame_index = 6
        elif player_moving:
            frame_index = 2 + (int(elapsed * 8.0) % 4)
        var atlas := Rect2(float(frame_index * 40), float(direction_index * 56), 40.0, 56.0)
        var location := Vector2(roundf(player_pos.x) - 20.0, roundf(player_pos.y) - 50.0)
        draw_ellipse_fake_shadow(player_pos)
        var blink: bool = damage_cd > 0.0 and int(elapsed * 14.0) % 2 == 0
        # La antorcha va en la mano; de espaldas queda detrás del cuerpo.
        var hand: Vector2 = player_pos + [Vector2(12, -18), Vector2(-12, -20), Vector2(9, -19), Vector2(-9, -19)][direction_index]
        if has_torch and direction_index == 1 and game_mode != "dead":
            _draw_hand_torch(hand)
        draw_texture_rect_region(_hero_sheet(), Rect2(location, Vector2(40.0, 56.0)), atlas, Color(1, 1, 1, 0.35 if blink else 1.0))
        if has_torch and direction_index != 1 and game_mode != "dead":
            _draw_hand_torch(hand)
        if bump_left > 0.0:
            # Polvo del choque a ambos lados de los pies: el objeto es sólido.
            var t: float = 1.0 - bump_left / 0.35
            for side in [-1.0, 1.0]:
                for i in range(3):
                    var p: Vector2 = bump_at + Vector2(side * (12.0 + t * 10.0 + float(i) * 4.0), -float(i) * 3.0 - t * 4.0)
                    draw_circle(p, 3.0 - t * 1.6 - float(i) * 0.4, Color(0.84, 0.80, 0.66, 0.65 * (1.0 - t)))
        if ward_left > 0.0:
            draw_arc(player_pos, 27.0, 0.0, TAU, 40, SOUL, 2.0)
        if damage_cd > 0.0:
            draw_arc(player_pos, 29.0, 0.0, TAU, 40, RED, 2.0)
        return
    if art.has("mark"):
        var t: Texture2D = art["mark"]
        var frame: int = 0
        if player_moving:
            var tick: int = int(elapsed * 9.0)
            if absf(player_dir.x) > absf(player_dir.y):
                frame = (10 + tick % 5) if player_dir.x > 0.0 else (19 + tick % 5)
            else:
                frame = (6 + tick % 4) if player_dir.y > 0.0 else (16 + tick % 4)
        draw_texture_rect_region(t, Rect2(player_pos.x - 15, player_pos.y - 54, 30, 57), Rect2(frame * 24, 0, 24, 70))
        return
    if art.has("player"):
        draw_texture_rect(art["player"], Rect2(player_pos.x - 20, player_pos.y - 42, 40, 48), false)
        return
    var p := player_pos
    draw_circle(p + Vector2(0, 18), 14.0, Color(0, 0, 0, 0.4))
    draw_colored_polygon(PackedVector2Array([
        p + Vector2(0, -19), p + Vector2(17, -4),
        p + Vector2(17, 20), p + Vector2(-16, 20), p + Vector2(-17, -3)
    ]), Color("#b9b8b3"))
    draw_circle(p + Vector2(0, -11), 11.5, Color("#d0cac0"))
    draw_line(p + Vector2(-3, -12), p + Vector2(3, -12), Color("#26272d"), 2)
    draw_line(p + Vector2(2, -1), p + Vector2(16, 8), Color("#a53e56"), 4.0)
    draw_line(p + Vector2(9, 5), p + Vector2(24, 15), Color("#a53e56"), 3.0)
    draw_line(p + Vector2(0, 0), p + player_dir * 20.0, Color("#e9ddab"), 2.0)
    if ward_left > 0:
        draw_arc(p, 27.0, 0.0, TAU, 48, SOUL, 2.0)
    if damage_cd > 0:
        draw_arc(p, 29.0, 0.0, TAU, 28, RED, 2.0)


func _draw_hand_torch(hand: Vector2) -> void:
    var tip := hand + Vector2(0.0, -14.0)
    draw_line(hand + Vector2(0.0, 4.0), tip, Color("#5c3a22"), 3.0)
    draw_line(hand + Vector2(-1.0, 3.0), tip + Vector2(-1.0, 1.0), Color("#8a5a35"), 1.0)
    draw_rect(Rect2(tip.x - 3.0, tip.y - 1.0, 6.0, 4.0), Color("#d9cfb0"))
    if not torch_on:
        draw_rect(Rect2(tip.x - 2.0, tip.y - 3.0, 4.0, 2.0), Color("#3a2f2a"))
        return
    var f: float = sin(elapsed * 17.0) * 1.2
    draw_circle(tip + Vector2(0.0, -10.0), 16.0, Color(1.0, 0.7, 0.3, 0.10))
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-5, -1), tip + Vector2(5, -1), tip + Vector2(2, -9), tip + Vector2(f, -15), tip + Vector2(-3, -8)]), Color("#c2412f"))
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-3, -1), tip + Vector2(3, -1), tip + Vector2(f * 0.6, -11)]), Color("#f08a3a"))
    draw_colored_polygon(PackedVector2Array([tip + Vector2(-1.5, -1), tip + Vector2(1.5, -1), tip + Vector2(0, -6)]), Color("#ffd36b"))


func _draw_topbar() -> void:
    ## HUD estilo roguelike de acción: paneles flotantes sobre una franja oscura.
    _vgradient(Rect2(0, 0, W, 112), Color(0.02, 0.025, 0.035, 0.96), Color(0.02, 0.025, 0.035, 0.55))
    _draw_player_panel()
    _draw_floor_banner()
    _draw_minimap()


## Panel del jugador: retrato, nombre y barras con icono y números.
func _draw_player_panel() -> void:
    var panel := Rect2(8, 6, 318, 96)
    _panel(panel)
    var frame := Rect2(16, 12, 72, 72)
    _panel(frame, Color("#1a1f2a"), UI_GOLD)
    var hurt: bool = hp / max_hp < 0.35
    var shake_x: float = roundf(sin(elapsed * 40.0)) if damage_cd > 0.9 else 0.0
    draw_texture_rect(_portrait(hurt), Rect2(frame.position + Vector2(4.0 + shake_x, 4.0), Vector2(64, 64)), false)
    if damage_cd > 0.0:
        draw_rect(frame.grow(-2.0), Color(0.8, 0.05, 0.08, 0.35 * clampf(damage_cd / 1.2, 0.0, 1.0)))
    # Placa con el nombre bajo el retrato.
    _panel(Rect2(16, 82, 72, 17), Color("#2a1d22"), UI_GOLD)
    _text_outline(_hero_name(), Vector2(16, 95), 12, CREAM, 72.0)
    var bars := [
        ["corazon", hp, max_hp, BAR_HP, "%d/%d" % [int(ceil(hp)), int(max_hp)]],
        ["vigor", stamina, 100.0, BAR_VIGOR, "%d/100" % int(stamina)],
        ["miedo", fear, 100.0, BAR_FEAR, "MIEDO %d%%" % int(fear)],
    ]
    for i in range(bars.size()):
        var y: float = 15.0 + float(i) * 27.0
        var b: Array = bars[i]
        draw_texture_rect(ICONS[b[0]], Rect2(96, y - 1.0, 22, 22), false)
        _px_bar(Rect2(122, y, 196, 20), float(b[1]) / float(b[2]), b[3], b[4])
    if fear > 70.0:
        # Al borde del pánico la barra de miedo late.
        var k: float = 0.5 + 0.5 * sin(elapsed * 9.0)
        draw_rect(Rect2(121, 68, 198, 22), Color(0.7, 0.3, 1.0, 0.35 * k), false, 2.0)


## Cartel del piso y la sala, con el contador de almas.
func _draw_floor_banner() -> void:
    var banner := Rect2(336, 6, 288, 58)
    _panel(banner)
    var floor_label: String = _floor()["title"] if in_tutorial else "PISO %s · %s" % [_floor()["number"], _floor()["title"]]
    _text_outline(floor_label, Vector2(banner.position.x, 25), 13, UI_GOLD, banner.size.x)
    _text_outline(_room()["name"], Vector2(banner.position.x, 44), 14, CREAM, banner.size.x)
    _text_outline(_floor()["state"], Vector2(banner.position.x, 58), 10, Color("#8a8574"), banner.size.x)
    # Almas: icono y número que destella al recoger.
    var souls_box := Rect2(420, 68, 120, 34)
    _panel(souls_box)
    var bounce: float = souls_flash * 6.0
    draw_texture_rect(ICONS["alma"], Rect2(428, 72.0 - roundf(bounce * 0.5), 26, 26), false)
    var soul_color: Color = SOUL.lerp(Color.WHITE, clampf(souls_flash / 0.8, 0.0, 1.0))
    _text_outline("%d" % souls, Vector2(460, 93), 18 + int(round(bounce)), soul_color)


## Minimapa del piso: salas en cadena, la actual resaltada.
func _draw_minimap() -> void:
    var panel := Rect2(634, 6, 318, 96)
    _panel(panel)
    _text_outline("MAPA DEL PISO", Vector2(644, 24), 11, Color("#8a8574"))
    var count: int = _room_count()
    var cell := Vector2(28, 22)
    var gap: float = 12.0
    var total: float = float(count) * cell.x + float(count - 1) * gap
    var x0: float = roundf(634.0 + (258.0 - total) * 0.5)
    var y0: float = 40.0
    for i in range(count):
        var r := Rect2(x0 + float(i) * (cell.x + gap), y0, cell.x, cell.y)
        if i < count - 1:
            draw_rect(Rect2(r.end.x, r.position.y + 9.0, gap, 4.0), UI_GOLD if i < current_room else Color("#2a2e38"))
        var room: Dictionary = _floor()["rooms"][i]
        if i < current_room:
            _panel(r, Color("#3a3f4c"), UI_LIGHT)
        elif i == current_room:
            var pulse: float = 0.6 + 0.4 * sin(elapsed * 4.0)
            _panel(r, Color(0.78, 0.67, 0.43, 0.35 + 0.2 * pulse), UI_GOLD)
            draw_rect(Rect2(r.get_center() - Vector2(3, 3), Vector2(6, 6)), CREAM)
        else:
            _panel(r, Color("#12151c"), Color("#2a2e38"))
            if i < count - 1:
                _text_outline("?", Vector2(r.position.x, r.position.y + 16.0), 12, Color("#4a4e5a"), r.size.x)
        # Marcas: amenaza viva en la sala actual; el final del piso, una calavera.
        if i == current_room and (_enemy_active() or pilgrim_state in ["tell", "hostile"]):
            draw_rect(Rect2(r.end.x - 7.0, r.position.y + 3.0, 4, 4), RED)
        if i == count - 1 and i > current_room:
            draw_texture_rect(ICONS["calavera"], Rect2(r.position + Vector2(5, 2), Vector2(18, 18)), false, Color(1, 1, 1, 0.8))
        if "cosecha" in room["traits"] and i <= current_room:
            draw_texture_rect(ICONS["calavera"], Rect2(r.position + Vector2(-5, -10), Vector2(14, 14)), false)
    _text_outline("SALA %d/%d" % [current_room + 1, count], Vector2(644, 92), 12, CREAM)
    _text_outline("ID %03d" % identity_number, Vector2(800, 92), 11, Color("#8a8574"))
    # Botón de pausa (en móvil vuelve al menú).
    var pause := Rect2(898, 12, 46, 46)
    _panel(pause, Color("#1a1f2a"), UI_LIGHT)
    draw_texture_rect(ICONS["pausa"], Rect2(pause.position + Vector2(7, 7), Vector2(32, 32)), false, Color(1, 1, 1, 0.85))
    var abil_hot: bool = ABIL_BTN.has_point(ui_hover)
    _panel(ABIL_BTN, Color("#241a30") if abil_hot else Color("#1a1f2a"), UI_GOLD if abil_hot else UI_LIGHT)
    draw_texture_rect(ICONS["habilidades"], Rect2(ABIL_BTN.position + Vector2(11, 4), Vector2(24, 24)), false)
    _text_outline("K", Vector2(ABIL_BTN.end.x - 9.0, ABIL_BTN.end.y - 3.0), 9, UI_GOLD)


func _bar(rect: Rect2, fraction: float, color: Color) -> void:
    _px_bar(rect, fraction, color, "")


## Panel biselado de pixel art: sombra, borde, luz superior y esquinas recortadas.
func _panel(rect: Rect2, fill: Color = UI_PANEL, edge: Color = UI_EDGE) -> void:
    var r := rect
    draw_rect(Rect2(r.position + Vector2(2, 3), r.size), Color(0, 0, 0, 0.45 * fill.a)) # sombra
    draw_rect(Rect2(r.position.x + 2.0, r.position.y, r.size.x - 4.0, r.size.y), edge)
    draw_rect(Rect2(r.position.x, r.position.y + 2.0, r.size.x, r.size.y - 4.0), edge)
    var inner := r.grow(-2.0)
    draw_rect(inner, fill)
    draw_rect(Rect2(inner.position, Vector2(inner.size.x, 2.0)), Color(1, 1, 1, 0.07 * fill.a)) # luz
    draw_rect(Rect2(inner.position.x, inner.end.y - 2.0, inner.size.x, 2.0), Color(0, 0, 0, 0.25 * fill.a))


## Barra viva: fondo hundido, relleno con brillo arriba y sombra abajo,
## marcas cada 10 % y el valor escrito encima con contorno.
func _px_bar(rect: Rect2, fraction: float, color: Color, label: String) -> void:
    draw_rect(rect, Color("#0b0d12"))
    var inner := rect.grow(-2.0)
    draw_rect(inner, color.darkened(0.75))
    var w: float = roundf(inner.size.x * clampf(fraction, 0.0, 1.0))
    if w > 0.0:
        draw_rect(Rect2(inner.position, Vector2(w, inner.size.y)), color)
        draw_rect(Rect2(inner.position, Vector2(w, 3.0)), color.lightened(0.35))
        draw_rect(Rect2(inner.position.x, inner.end.y - 3.0, w, 3.0), color.darkened(0.3))
    for k in range(1, 10):
        var x: float = roundf(inner.position.x + inner.size.x * float(k) / 10.0)
        draw_rect(Rect2(x, inner.position.y, 1.0, inner.size.y), Color(0, 0, 0, 0.25))
    draw_rect(rect, Color("#2c303b"), false, 1.0)
    if label != "":
        _text_outline(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.5 + 5.0), 13, Color.WHITE, rect.size.x)


## Texto con contorno negro de 1 px (legible sobre cualquier fondo).
func _text_outline(msg: String, at: Vector2, size: int, color: Color, width: float = -1.0) -> void:
    var align: int = HORIZONTAL_ALIGNMENT_CENTER if width > 0.0 else HORIZONTAL_ALIGNMENT_LEFT
    var dark := Color(0, 0, 0, color.a * 0.9)
    for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 1)]:
        draw_string(font, at + o, msg, align, width, size, dark)
    draw_string(font, at, msg, align, width, size, color)


func _draw_footer() -> void:
    ## Abajo: misión a la izquierda; arma y habilidades a la derecha.
    _vgradient(Rect2(0, 572, W, 68), Color(0.02, 0.025, 0.035, 0.55), Color(0.02, 0.025, 0.035, 0.96))
    var task: String = _mission_text()
    var task_color: Color = SOUL if _room_ready() else CREAM
    if _has("sello") and _enemy_active() and watcher_open and not seal_acquired:
        task_color = RED
    if pilgrim_state in ["tell", "hostile"]:
        task_color = RED
    var mission := Rect2(8, 580, 568, 34)
    _panel(mission)
    draw_colored_polygon(PackedVector2Array([Vector2(22, 597), Vector2(28, 591), Vector2(34, 597), Vector2(28, 603)]), UI_GOLD)
    _text_outline(task, Vector2(42, 603), 15, task_color)
    if not touch_enabled:
        var n := func(a: String) -> String: return Ajustes.nombre_tecla(a)
        var hint: String = "%s%s%s%s mover · %s/CLIC golpear · %s antorcha · %s esquivar · %s resonancia · %s perfil · %s habilidades · %s pausa" % [
            n.call("arriba"), n.call("izquierda"), n.call("abajo"), n.call("derecha"), n.call("interactuar"), n.call("antorcha"),
            n.call("esquivar"), n.call("resonancia"), n.call("perfil"), n.call("habilidades"), n.call("pausa")]
        _text_outline(hint, Vector2(12, 632), 10, Color("#8d8877"))
    _draw_weapon_panel()


## Arma equipada (la antorcha) con su «munición» y las habilidades.
func _draw_weapon_panel() -> void:
    var panel := Rect2(586, 578, 366, 58)
    _panel(panel)
    var slot := Rect2(594, 583, 48, 48)
    _panel(slot, Color("#1a1f2a"), UI_GOLD if has_torch and torch_on else UI_LIGHT)
    var icon: String = ("antorcha_encendida" if torch_on else "antorcha") if has_torch else "madera"
    var owned: bool = has_torch or has_wood
    draw_texture_rect(ICONS[icon], Rect2(slot.position + Vector2(8, 8), Vector2(32, 32)), false, Color.WHITE if owned else Color(0.3, 0.3, 0.3, 0.5))
    var name_txt: String = "ANTORCHA" if has_torch else ("MADERA" if has_wood else "SIN ARMA")
    _text_outline(name_txt, Vector2(650, 600), 14, CREAM if owned else Color("#6d6a60"))
    var ammo: String = "LLAMA INTERIOR" if has_inner_flame else "FÓSFOROS x%d" % matches
    var ammo_col: Color = SOUL if has_inner_flame else (Color("#f0c98a") if matches > 0 else RED)
    draw_texture_rect(ICONS["llama_interior" if has_inner_flame else "fosforos"], Rect2(648, 608, 20, 20), false)
    _text_outline(ammo, Vector2(672, 624), 12, ammo_col)
    _draw_ability_icon(Rect2(838, 583, 48, 48), "golpe", has_torch and torch_on, strike_cd / 0.6, "E")
    _draw_ability_icon(Rect2(896, 583, 48, 48), "resonancia", has_pulse, pulse_cd / 8.0, "Q")


## Objetivo de la sala para el pie de pantalla.
func _mission_text() -> String:
    if in_tutorial:
        return _tutorial_text(tutorial_step)
    if _has("tutorial") and not has_torch:
        return "OSCURIDAD: busca madera y fósforos"
    if _has("tutorial") and not torch_on:
        return "PULSA F PARA ENCENDER LA ANTORCHA"
    if _has("sello"):
        if seal_acquired:
            return "SELLO RECUPERADO · VE A LA PUERTA"
        if _enemy_active():
            return "OJO ABIERTO: INMÓVIL" if watcher_open else "OJO CERRADO: AVANZA"
        return "MISIÓN: Recuperar el sello del Testigo"
    var pilgrim_task: String = _pilgrim_mission_text()
    if pilgrim_task != "":
        return pilgrim_task
    var hunt_task: String = _hunt_mission_text()
    if hunt_task != "" and seg_state != "acecho":
        return hunt_task
    if _mission_pending(false):
        var m: Dictionary = _mission()
        return "MISIÓN%s: %s · +%d almas" % ["" if bool(m["required"]) else " (OPCIONAL)", m["text"], int(m["reward"])]
    if hunt_task != "":
        return hunt_task
    if _has("almas") and collected.has(false):
        return "MISIÓN: reúne las almas de la sala (%d/3)" % (3 - collected.count(false))
    match _enemy_kind():
        "ghoul":
            if _enemy_active():
                return "BRASAS: tu luz puede atraer algo"
        "hechicero":
            if _enemy_active():
                return "ARCHIVO: lee la carta, evita los conjuros"
    if current_floor == 0:
        return "MISIÓN: Recuperar el sello del Testigo"
    return "LA PUERTA ESTÁ ABIERTA" if _room_ready() else "BUSCA LA SALIDA"


func _draw_ability_icon(box: Rect2, key: String, ready_to_use: bool, cooldown: float, hotkey: String) -> void:
    ## Botón de habilidad redondo; la recuperación se ve como un reloj que se vacía.
    var c: Vector2 = box.get_center()
    var r: float = box.size.x * 0.5
    draw_circle(c + Vector2(1, 2), r, Color(0, 0, 0, 0.45))
    draw_circle(c, r, UI_EDGE)
    draw_circle(c, r - 2.0, Color("#1a1f2a"))
    draw_texture_rect(ICONS[key], Rect2(c - Vector2(16, 16), Vector2(32, 32)), false, Color.WHITE if ready_to_use else Color(0.3, 0.3, 0.3, 0.55))
    if ready_to_use and cooldown > 0.0:
        var k: float = clampf(cooldown, 0.0, 1.0)
        var pts := PackedVector2Array([c])
        for i in range(25):
            pts.append(c + Vector2.from_angle(-PI * 0.5 + TAU * k * float(i) / 24.0) * (r - 2.0))
        draw_colored_polygon(pts, Color(0.02, 0.03, 0.05, 0.72))
    var ready_now: bool = ready_to_use and cooldown <= 0.0
    draw_arc(c, r - 1.0, 0.0, TAU, 32, UI_GOLD if ready_now else UI_LIGHT, 2.0)
    if ready_now:
        draw_arc(c, r + 1.5, 0.0, TAU, 32, Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.25 + 0.2 * sin(elapsed * 5.0)), 2.0)
    var badge := Rect2(box.end.x - 15.0, box.end.y - 15.0, 16, 16)
    _panel(badge, Color("#2a1d22"), UI_GOLD)
    _text_outline(hotkey, Vector2(badge.position.x, badge.end.y - 4.0), 11, CREAM, badge.size.x)


func _draw_toast() -> void:
    ## Mensaje flotante bajo el HUD, centrado y con desvanecimiento.
    var alpha: float = clampf(toast_left * 3.0, 0.0, 1.0)
    var size: int = 14
    var width: float = minf(font.get_string_size(toast, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 40.0, W - 40.0)
    var box := Rect2(roundf((W - width) * 0.5), 110.0, width, 28.0)
    _panel(box, Color(0.035, 0.045, 0.06, 0.94 * alpha), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.8 * alpha))
    _text_outline(toast, Vector2(box.position.x, box.position.y + 19.0), size, Color(CREAM.r, CREAM.g, CREAM.b, alpha), box.size.x)


func _draw_title() -> void:
    ## Menú principal estilo roguelike: panel biselado, botones gruesos con icono.
    # La sala actual (escena) queda detrás; solo se oscurece.
    draw_rect(Rect2(0, 0, W, H), Color(0.018, 0.027, 0.032, 0.62))
    var main := Rect2(149, 150, 662, 410)
    _panel(main, Color(0.045, 0.055, 0.07, 0.95), UI_GOLD)
    draw_rect(main.grow(-8.0), Color("#3a3f4c"), false, 1.0)
    draw_texture_rect(BRAND_ICON, Rect2(443, 164, 74, 74), false)
    _text_outline("EL TEMPLO", Vector2(149, 284), 44, CREAM, main.size.x)
    _text_outline("DE LOS ECOS", Vector2(149, 330), 46, SOUL, main.size.x)
    _text_outline("UN LUGAR SAGRADO. UN CICLO QUE SE ALIMENTA DE TI.", Vector2(149, 362), 14, CREAM, main.size.x)
    draw_rect(Rect2(318, 376, 324, 2), UI_GOLD.darkened(0.3))
    _text_outline("ROGUELIKE DE TERROR · PISOS I–%s · REGLAS POR DESCUBRIR" % FLOORS[FLOORS.size() - 1]["number"], Vector2(149, 398), 12, SOUL, main.size.x)
    _text_outline("No conoces las reglas. Aún.", Vector2(149, 422), 15, Color("#b9b29b"), main.size.x)
    ## Botones: misma zona táctil que antes (izquierda explorar, derecha vigilia).
    var explore := Rect2(203, 440, 257, 64)
    var vigil := Rect2(500, 440, 257, 64)
    _big_button(explore, "EXPLORAR", "antorcha_encendida", Color("#1d4a4f"), SOUL)
    _big_button(vigil, "VIGILIA", "descansar", Color("#4a3417"), UI_GOLD)
    _text_outline("ENTER  explorar      ·      H  vigilia", Vector2(149, 526), 12, Color("#9fb3b3"), main.size.x)
    # Ficha rápida del personaje.
    if player_name != "":
        draw_texture_rect(_portrait(false), Rect2(171, 510, 40, 40), false)
        _text_outline("%s · ID %03d   |   MUERTES %d" % [player_name, identity_number, deaths], Vector2(149, 548), 12, CREAM, main.size.x)
        var hot_c: bool = CHANGE_CHAR_RECT.has_point(ui_hover)
        _panel(CHANGE_CHAR_RECT, Color("#222c39") if hot_c else Color("#141922"), UI_GOLD if hot_c else UI_LIGHT)
        _text_outline(_t("cambiar_pj"), CHANGE_CHAR_RECT.position + Vector2(0, 19), 12, CREAM if hot_c else Color("#b9b29b"), CHANGE_CHAR_RECT.size.x)
    else:
        _text_outline(_t("sin_pj"), Vector2(149, 548), 12, Color("#b9b29b"), main.size.x)
    var hot: bool = GEAR_RECT.has_point(ui_hover)
    _panel(GEAR_RECT, Color("#222c39") if hot else Color("#141922"), UI_GOLD if hot else UI_LIGHT)
    draw_texture_rect(ICONS["engranaje"], Rect2(GEAR_RECT.position + Vector2(10, 10), Vector2(32, 32)), false)
    if toast_left > 0:
        _draw_toast()


## Botón grueso de pixel art: bisel claro arriba, oscuro abajo, icono y texto.
func _big_button(rect: Rect2, label: String, icon: String, fill: Color, edge: Color) -> void:
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 3.0)
    _panel(rect, fill, edge)
    draw_rect(Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8.0, 4)), fill.lightened(0.25))
    draw_rect(Rect2(rect.position.x + 4.0, rect.end.y - 8.0, rect.size.x - 8.0, 4), fill.darkened(0.35))
    draw_rect(rect.grow(2.0), Color(edge.r, edge.g, edge.b, 0.15 + 0.15 * pulse), false, 2.0)
    var icon_tex: Texture2D = DEFENSE_ICONS.get(icon, ICONS.get(icon, null))
    if icon_tex != null:
        draw_texture_rect(icon_tex, Rect2(rect.position + Vector2(18, 16), Vector2(32, 32)), false)
    _text_outline(label, Vector2(rect.position.x + 30.0, rect.position.y + 42.0), 24, CREAM, rect.size.x - 30.0)


func _draw_altar_overlay() -> void:
    _overlay()
    _panel(Rect2(164, 155, 632, 357), Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _center("EL MERCADER SILENCIOSO", 200, 26, CREAM)
    _center("'Todo préstamo tiene un dueño que no conoces.'", 232, 15, SOUL)
    var offers := [
        ["resonancia", "[1] RESONANCIA", "Onda (Q) que daña y aturde a las entidades cercanas.", 14, has_pulse, "NIVEL %d" % ability_level],
        ["llama_interior", "[2] LLAMA INTERIOR", "Enciendes la antorcha sin gastar fósforos.", INNER_FLAME_PRICE, has_inner_flame, "ADQUIRIDA"],
    ]
    for i in range(offers.size()):
        var row: Rect2 = _altar_row_rect(i)
        var o: Array = offers[i]
        var hover: bool = inventory_sel == i
        _panel(row, Color("#202a36") if hover else Color("#141922"), UI_GOLD if hover else UI_EDGE)
        draw_texture_rect(ICONS[o[0]], Rect2(row.position + Vector2(12, 11), Vector2(64, 64)), false)
        _text(o[1], row.position + Vector2(92, 32), 18, CREAM)
        _text(o[2], row.position + Vector2(92, 60), 13, Color("#b9b29b"))
        var right: String = o[5] if o[4] else "%d ALMAS" % o[3]
        var tone: Color = SOUL if o[4] else (CREAM if souls >= o[3] else RED)
        draw_string(font, row.position + Vector2(0, 32), right, HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 14.0, 15, tone)
    draw_texture_rect(ICONS["alma"], Rect2(196, 464, 26, 26), false)
    _text("ALMAS: %d" % souls, Vector2(228, 484), 16, SOUL)
    _text("E / ESC: salir", Vector2(640, 484), 14, CREAM)


func _draw_inventory_overlay() -> void:
    ## PERFIL del jugador (I / Tab, o tocar el retrato): ficha de personaje al
    ## estilo de los roguelike de acción. Izquierda: retrato y estadísticas.
    ## Derecha: equipo y habilidades, Ecos y la descripción de lo señalado.
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.78))
    var sheet := Rect2(70, 46, 820, 548)
    _panel(sheet, Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _panel(Rect2(380, 34, 200, 30), Color("#2a1d22"), UI_GOLD)
    _text_outline("PERFIL", Vector2(380, 55), 18, CREAM, 200.0)
    # --- Columna izquierda: retrato y datos.
    var frame := Rect2(102, 84, 140, 140)
    _panel(frame, Color("#1a1f2a"), UI_GOLD)
    draw_texture_rect(_portrait(hp / max_hp < 0.35), Rect2(frame.position + Vector2(6, 6), Vector2(128, 128)), false)
    _text_outline(_hero_name(), Vector2(252, 112), 26, CREAM)
    _text_outline("IDENTIDAD %03d" % identity_number, Vector2(252, 136), 13, Color("#a0b6b2"))
    _text_outline("PISO %s · SALA %d" % [_floor()["number"], current_room + 1], Vector2(252, 158), 13, UI_GOLD)
    var fate: String = "Recuerda sus vidas" if reincarnations > 0 else "Primera vida"
    _text_outline(fate, Vector2(252, 180), 12, Color("#8a8574"))
    _px_bar(Rect2(102, 236, 238, 18), hp / max_hp, BAR_HP, "VIDA %d/%d" % [int(ceil(hp)), int(max_hp)])
    _px_bar(Rect2(102, 258, 238, 18), stamina / 100.0, BAR_VIGOR, "VIGOR %d" % int(stamina))
    _px_bar(Rect2(102, 280, 238, 18), fear / 100.0, BAR_FEAR, "MIEDO %d%%" % int(fear))
    var stats := [
        ["Daño del golpe", "%d" % int(STRIKE_DAMAGE)],
        ["Daño de Resonancia", ("%d" % int(30.0 + 10.0 * float(ability_level))) if has_pulse else "—"],
        ["Almas", "%d" % souls],
        ["Muertes", "%d" % deaths],
        ["Retornos", "%d" % reincarnations],
        ["Absorciones", "%d" % new_humans],
        ["Pisos superados", "%d" % cleared],
    ]
    _panel(Rect2(96, 310, 250, 268), Color("#0f1218"))
    for i in range(stats.size()):
        var y: float = 340.0 + float(i) * 33.0
        _text_outline(stats[i][0], Vector2(112, y), 13, Color("#b9b29b"))
        draw_string(font, Vector2(112, y), stats[i][1], HORIZONTAL_ALIGNMENT_RIGHT, 220.0, 15, CREAM)
        if i < stats.size() - 1:
            draw_rect(Rect2(112, y + 11.0, 220, 1), Color(1, 1, 1, 0.06))
    # --- Columna derecha: equipo/mochila (casillas seleccionables).
    _text_outline("EQUIPO Y MOCHILA", Vector2(372, 92), 13, UI_GOLD)
    for i in range(INVENTORY_SLOTS.size()):
        var box: Rect2 = _inventory_slot_rect(i)
        var owned: bool = _slot_owned(i)
        var sel: bool = inventory_sel == i
        _panel(box, Color("#222c39") if sel else Color("#141922"), UI_GOLD if sel else UI_EDGE)
        var key: String = INVENTORY_SLOTS[i][0]
        if key == "antorcha" and torch_on:
            key = "antorcha_encendida"
        draw_texture_rect(ICONS[key], Rect2(box.position + Vector2(roundf(box.size.x * 0.5) - 24.0, 8), Vector2(48, 48)), false, Color.WHITE if owned else Color(0.1, 0.1, 0.12, 0.9))
        var title: String = INVENTORY_SLOTS[i][1] if owned else "???"
        if INVENTORY_SLOTS[i][0] == "fosforos" and owned:
            title = "FÓSFOROS x%d" % matches
        _text_outline(title, Vector2(box.position.x, box.end.y - 10.0), 11, CREAM if owned else Color("#5d5a52"), box.size.x)
    # --- Ecos: iconos compactos (caben los diez pisos); el detalle está en HABILIDADES.
    _text_outline("ECOS", Vector2(372, 368), 13, UI_GOLD)
    var keys: Array = ECOS.keys()
    for i in range(keys.size()):
        var r: Rect2 = _profile_eco_rect(i)
        var has_it: bool = ecos.has(keys[i])
        var sel_e: bool = inventory_sel == 100 + i
        _panel(r, Color("#222c39") if sel_e else Color("#141922"), UI_GOLD if sel_e else (Color("#3b6f7d") if has_it else UI_EDGE))
        draw_texture_rect(ICONS["eco_" + str(keys[i])], Rect2(r.position + Vector2(8, 8), Vector2(32, 32)), false, Color.WHITE if has_it else Color(0.15, 0.15, 0.18, 0.9))
    var hot_ab: bool = PROFILE_ABIL_BTN.has_point(ui_hover)
    _panel(PROFILE_ABIL_BTN, Color("#241a30") if hot_ab else Color("#141922"), UI_GOLD)
    draw_texture_rect(ICONS["habilidades"], Rect2(PROFILE_ABIL_BTN.position + Vector2(8, 10), Vector2(24, 24)), false)
    _text_outline("HABILIDADES (%s)" % Ajustes.nombre_tecla("habilidades"), Vector2(PROFILE_ABIL_BTN.position.x + 36.0, PROFILE_ABIL_BTN.position.y + 27.0), 12, CREAM)
    # --- Descripción de la casilla señalada (cursor, flechas o toque).
    var desc_box := Rect2(372, 454, 496, 76)
    _panel(desc_box, Color("#0f1218"))
    if inventory_sel >= 100:
        var ek: String = str(ECOS.keys()[clampi(inventory_sel - 100, 0, ECOS.size() - 1)])
        var has_e: bool = ecos.has(ek)
        _text_outline(("ECO · " + ECOS[ek][0]) if has_e else "ECO SIN DESPERTAR", Vector2(388, 478), 15, SOUL if has_e else Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), ECOS[ek][1] if has_e else "Supera un piso para despertarlo.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, CREAM if has_e else Color("#8a8778"))
    else:
        var owned_sel: bool = _slot_owned(inventory_sel)
        _text_outline(INVENTORY_SLOTS[inventory_sel][1] if owned_sel else "???", Vector2(388, 478), 15, CREAM if owned_sel else Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), INVENTORY_SLOTS[inventory_sel][2] if owned_sel else "Aún no lo tienes. Explora el templo.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, SOUL if owned_sel else Color("#8a8778"))
    _text_outline("I / ESC: cerrar", Vector2(372, 566), 12, Color("#8a8574"), 496.0)


## Pantalla de entrada al piso (GDD §7): solo una vista parcial del interior,
## sin desvelar lo que hay tras las puertas.
func _draw_floor_intro() -> void:
    # Ventana circular: un fragmento de la sala, nada más. Fuera, oscuridad.
    var c := Vector2(480, 330)
    var r_in: float = 128.0
    var dark := Color(0.01, 0.015, 0.02, 0.96)
    var seg: int = 64
    for i in range(seg):
        var a0: float = TAU * float(i) / float(seg)
        var a1: float = TAU * float(i + 1) / float(seg)
        draw_colored_polygon(PackedVector2Array([
            c + Vector2.from_angle(a0) * r_in, c + Vector2.from_angle(a0) * 1200.0,
            c + Vector2.from_angle(a1) * 1200.0, c + Vector2.from_angle(a1) * r_in]), dark)
    # Borde difuminado hacia dentro.
    for k in range(6):
        draw_arc(c, r_in - float(k) * 4.0, 0.0, TAU, seg, Color(0.01, 0.015, 0.02, 0.5 - float(k) * 0.08), 4.0)
    draw_arc(c, r_in + 2.0, 0.0, TAU, seg, Color("#8d7957"), 2.0)
    _center("PISO %s" % _floor()["number"], 120, 22, Color("#c6aa6e"))
    _center(_floor()["title"], 160, 34, CREAM)
    if floor_intro_eco != "":
        var eco: Array = ECOS[floor_intro_eco]
        _center("ECO ADQUIRIDO: %s" % eco[0], 486, 16, SOUL)
        _center(eco[1], 510, 14, Color("#b9b29b"))
    var pulse: float = 0.6 + 0.4 * sin(elapsed * 3.0)
    _center("ENTRAR  ·  ENTER / TOCA", 560, 18, Color(0.89, 0.74, 0.48, pulse))


func _draw_end_overlay(win: bool) -> void:
    _overlay()
    if win:
        _center("PISO %s SUPERADO" % _floor()["number"], 230, 33, SOUL)
        _center("No has escapado. El siguiente nivel sigue oculto.", 280, 18, CREAM)
        _center("El templo conserva su apariencia. Nada es lo que parece.", 318, 16, CREAM)
        _center("ENTER: repetir prueba  ·  ESC: menú", 418, 18, CREAM)
    elif soul_fate == "persistencia":
        _center("%s HA CAÍDO" % _hero_name(), 230, 32, RED)
        _center("El templo todavía no te reclama.", 278, 18, CREAM)
        _center("Conservas almas, objetos, habilidades y ecos.", 318, 17, CREAM)
        _center("(Modo de pruebas: la muerte no cuesta progreso.)", 352, 15, Color("#9fb3b3"))
        _center("ENTER: levantarte en la entrada de la sala  ·  ESC: menú", 418, 18, CREAM)
    elif soul_fate == "retorno":
        _center("TU ALMA HA REGRESADO", 230, 30, SOUL)
        _center("Resultado aleatorio de la muerte: reencarnación (50 %).", 278, 18, CREAM)
        _center("Eres la misma persona. Conservas memoria y habilidades.", 318, 17, CREAM)
        _center("Los niveles de habilidad regresaron a cero.", 352, 17, CREAM)
        _center("ENTER: reaparecer al inicio  ·  ESC: menú", 418, 18, CREAM)
    else:
        _center("ALMA ABSORBIDA", 230, 32, RED)
        _center("Resultado aleatorio: absorción definitiva (50 %).", 278, 18, CREAM)
        _center("La persona anterior ha dejado de existir.", 318, 17, CREAM)
        _center("Un nuevo humano ocupará el lugar, sin sus recuerdos.", 352, 17, CREAM)
        _center("ENTER: iniciar nueva identidad  ·  ESC: menú", 418, 18, CREAM)


func _overlay() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.75))


func _text(msg: String, at: Vector2, size: int = 16, color: Color = CREAM) -> void:
    draw_string(font, at, msg, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _center(msg: String, y: float, size: int = 16, color: Color = CREAM) -> void:
    draw_string(font, Vector2(40, y), msg, HORIZONTAL_ALIGNMENT_CENTER, 880.0, size, color)


# ============================================================ PISO II: PEREGRINO
func _pilgrim_reset() -> void:
    pilgrim_state = "none"
    for room in _floor()["rooms"]:
        if "peregrino" in room["traits"]:
            pilgrim_state = "waiting"
    pilgrim_traitor = randf() < PILGRIM_TRAITOR_CHANCE
    pilgrim_hp = PILGRIM_MAX_HP
    pilgrim_souls = 0
    pilgrim_wronged = false
    pilgrim_corpse = {}
    pilgrim_line_t = 0.0


func _pilgrim_present() -> bool:
    return pilgrim_state in ["follow", "tell", "hostile", "friend"]


func _pilgrim_say(line: String, duration: float = 3.2, bark: bool = false) -> void:
    # Lo que importa se lee en el cuadro de diálogo (clic para seguir); en pleno
    # combate o en comentarios de paso, un bocadillo que dura según su largo.
    if not bark and not _in_combat():
        _dialog([["PEREGRINO", line]])
        return
    pilgrim_line = line
    pilgrim_line_t = maxf(duration, _read_time(line))


## Al entrar en una sala: aparece (sala con "peregrino") o entra detrás de ti.
func _pilgrim_enter_room() -> void:
    if pilgrim_state == "waiting" and _has("peregrino"):
        pilgrim_state = "follow"
        pilgrim_pos = Vector2(220, 400)
    elif pilgrim_state in ["follow", "friend"]:
        pilgrim_pos = player_pos + Vector2(-6.0, 40.0)
        if _is_blocked(pilgrim_pos):
            pilgrim_pos = player_pos + Vector2(20.0, 0.0)
        if _has("cosecha"):
            _pilgrim_say("Esta cripta... Aquí se termina de reunir. Luego, a repartir.", 4.0)
        elif pilgrim_state == "follow" and pilgrim_souls > 0:
            # El traidor miente sobre lo que lleva: ese es el indicio.
            var claimed: int = pilgrim_souls if not pilgrim_traitor else maxi(0, pilgrim_souls - 14)
            _pilgrim_say("Yo apenas llevo %d almas. Sigamos." % claimed, 3.5)
    pilgrim_prev = pilgrim_pos


func _update_pilgrim(dt: float) -> void:
    pilgrim_line_t = maxf(0.0, pilgrim_line_t - dt)
    nuca_cd = maxf(0.0, nuca_cd - dt)
    if not _pilgrim_present():
        return
    pilgrim_hit_t = maxf(0.0, pilgrim_hit_t - dt)
    pilgrim_cd = maxf(0.0, pilgrim_cd - dt)
    pilgrim_lunge = maxf(0.0, pilgrim_lunge - dt)
    pilgrim_stun = maxf(0.0, pilgrim_stun - dt)
    var dirn: Vector2 = player_dir.normalized() if player_dir.length() > 0.1 else Vector2.RIGHT
    match pilgrim_state:
        "follow", "friend":
            # El traidor se queda a tu espalda; el sincero camina a tu lado.
            var target: Vector2 = player_pos - dirn * 46.0
            if not pilgrim_traitor or pilgrim_state == "friend":
                target = player_pos + dirn * 18.0 + Vector2(-dirn.y, dirn.x) * 40.0
            # Compite por las almas. El sincero solo toma las que le quedan más
            # cerca a él; el traidor, codicioso, va a por la que más le ventaja
            # te saca (la que tú no estás a punto de coger).
            if pilgrim_state == "follow":
                var best: int = -1
                var best_gain: float = -INF
                for i in range(relics.size()):
                    if collected[i]:
                        continue
                    var mine: float = pilgrim_pos.distance_to(relics[i])
                    var yours: float = player_pos.distance_to(relics[i])
                    var wants: bool = mine < 150.0 and mine < yours
                    if pilgrim_traitor:
                        wants = mine < 340.0 and yours > 110.0
                    if wants and yours - mine > best_gain:
                        best_gain = yours - mine
                        best = i
                if best >= 0:
                    target = relics[best]
                    if pilgrim_pos.distance_to(relics[best]) < 22.0:
                        _pilgrim_take_relic(best)
            _pilgrim_move_to(target, 140.0, dt)
            if _has("cosecha") and pilgrim_state == "follow" and not collected.has(false):
                _pilgrim_harvest()
        "tell":
            pilgrim_timer -= dt
            _pilgrim_face(player_pos - pilgrim_pos)
            pilgrim_moving = false
            if pilgrim_timer <= 0.0:
                pilgrim_state = "hostile"
        "hostile":
            if pilgrim_stun > 0.0:
                pilgrim_moving = false
            elif pilgrim_timer > 0.0:
                # Carga del tajo: se detiene y alza el cuchillo (aviso justo).
                pilgrim_timer -= dt
                pilgrim_moving = false
                _pilgrim_face(player_pos - pilgrim_pos)
                if pilgrim_timer <= 0.0:
                    pilgrim_lunge = 0.22
                    pilgrim_cd = 1.2
                    if pilgrim_pos.distance_to(player_pos) < 46.0 and damage_cd <= 0.0:
                        hp -= 26.0
                        fear = minf(100.0, fear + 14.0)
                        damage_cd = 1.2
                        _on_hurt()
                        _say("El cuchillo del Peregrino te alcanza.", 2.2)
            else:
                _pilgrim_move_to(player_pos, 172.0, dt)
                if pilgrim_pos.distance_to(player_pos) < 38.0 and pilgrim_cd <= 0.0:
                    pilgrim_timer = 0.42
                    _sfx("cuchillo", -12.0, 1.3)
    # Nuca fría: sientes a quien te quiere mal cuando está a tu espalda.
    if ecos.has("nuca") and _pilgrim_behind() and nuca_cd <= 0.0:
        nuca_cd = 4.0
        _sfx("aviso", -14.0, 0.8)


func _pilgrim_move_to(target: Vector2, speed: float, dt: float) -> void:
    var delta_v := target - pilgrim_pos
    if delta_v.length() < 12.0:
        pilgrim_moving = false
        return
    var step := delta_v.normalized() * speed * dt
    var moved := false
    var nx := Vector2(pilgrim_pos.x + step.x, pilgrim_pos.y)
    if not _is_blocked(nx):
        pilgrim_pos.x = nx.x
        moved = true
    var ny := Vector2(pilgrim_pos.x, pilgrim_pos.y + step.y)
    if not _is_blocked(ny):
        pilgrim_pos.y = ny.y
        moved = true
    # Atascado lejos de ti: retoma el camino detrás de tus pasos.
    if not moved and pilgrim_pos.distance_to(player_pos) > 160.0:
        var behind := player_pos - player_dir.normalized() * 40.0
        if not _is_blocked(behind):
            pilgrim_pos = behind
    pilgrim_moving = moved
    _pilgrim_face(step)


func _pilgrim_face(v: Vector2) -> void:
    if v.length() < 0.1:
        return
    if absf(v.x) > absf(v.y):
        pilgrim_facing = 2 if v.x > 0.0 else 3
    else:
        pilgrim_facing = 0 if v.y > 0.0 else 1


func _pilgrim_take_relic(i: int) -> void:
    collected[i] = true
    pilgrim_souls += 7
    pickup_fx.append({"pos": relics[i], "t": 0.0, "text": "+7 (él)", "color": Color("#c9a27a")})
    _sfx("alma", -12.0, 0.8)
    if randf() < 0.5:
        _pilgrim_say(["Esta la vi yo primero.", "Una menos para ti, ¿eh? Es broma.", "Hay que darse prisa."][randi() % 3], 2.4, true)


## Última alma de la cripta: el traidor desenvaina; el sincero comparte.
func _pilgrim_harvest() -> void:
    if pilgrim_traitor:
        pilgrim_state = "tell"
        pilgrim_timer = 0.9
        _pilgrim_say("Lo siento. Las almas no alcanzan para dos.", 3.0)
        _sfx("cuchillo", -6.0)
        shake = maxf(shake, 0.2)
    else:
        pilgrim_state = "friend"
        var gift: int = pilgrim_souls / 2
        souls += gift
        pilgrim_souls -= gift
        hp = minf(max_hp, hp + 30.0)
        souls_flash = 0.8
        _pilgrim_say("Toma, bebe. Y la mitad de lo mío. Nadie debería cruzar esto solo.", 4.5)
        _say("El Peregrino era sincero: +%d almas y agua (+30 de vida)." % gift, 4.0)
        _sfx("alma", -6.0, 0.9)


func _damage_pilgrim(amount: float) -> void:
    if pilgrim_state in ["follow", "friend"]:
        # Atacarlo primero: el traidor lo admite; el sincero no lo entiende.
        pilgrim_wronged = not pilgrim_traitor
        _pilgrim_say("Así que lo sabías." if pilgrim_traitor else "¿Por qué...? Yo solo quería salir.", 3.0)
        pilgrim_state = "hostile"
        pilgrim_timer = 0.0
        _sfx("cuchillo", -8.0)
    pilgrim_hp -= amount
    pilgrim_hit_t = 0.2
    float_fx.append({"pos": pilgrim_pos + Vector2(28.0, -44.0), "text": "-%d" % int(amount), "color": Color("#ffd36b"), "t": 0.0})
    _sfx("impacto", -6.0, 1.1)
    if pilgrim_hp <= 0.0:
        _pilgrim_die()


func _pilgrim_die() -> void:
    pilgrim_state = "dead"
    pilgrim_corpse = {"key": _room_key(), "pos": pilgrim_pos}
    drops.append({"pos": pilgrim_pos + Vector2(0.0, -4.0), "value": maxi(7, pilgrim_souls)})
    pilgrim_line_t = 0.0
    _sfx("muerte", -12.0, 1.4)
    if pilgrim_wronged:
        fear = minf(100.0, fear + 30.0)
        _say("Era sincero. En su morral había agua para dos.", 4.5)
    else:
        _say("El Peregrino ha caído. Sus almas son tuyas.", 3.0)


## ¿Está el Peregrino (con malas intenciones) a tu espalda y cerca?
func _pilgrim_behind() -> bool:
    if not _pilgrim_present() or not (pilgrim_traitor or pilgrim_state == "hostile"):
        return false
    if pilgrim_state == "friend":
        return false
    var to := pilgrim_pos - player_pos
    if to.length() > 140.0 or to.length() < 1.0:
        return false
    return to.normalized().dot(player_dir.normalized()) < -0.3


func _pilgrim_mission_text() -> String:
    match pilgrim_state:
        "tell", "hostile":
            return "¡TRAICIÓN! Sobrevive al Peregrino"
        "follow":
            if _has("almas") and collected.has(false):
                var claimed: int = pilgrim_souls if not pilgrim_traitor else maxi(0, pilgrim_souls - 14)
                return "REÚNE LAS ALMAS (%d/3) · él dice llevar %d" % [3 - collected.count(false), claimed]
        "friend":
            return "EL PEREGRINO ERA SINCERO · SIGAN JUNTOS"
    return ""


func _draw_pilgrim() -> void:
    var sheet: Texture2D = art["enemy_peregrino"]
    var frame: int = int(elapsed * 2.0) % 2
    if pilgrim_state == "tell" or (pilgrim_state == "hostile" and pilgrim_timer > 0.0):
        frame = 6
    elif pilgrim_lunge > 0.0:
        frame = 7
    elif pilgrim_moving:
        frame = 2 + int(elapsed * 8.0) % 4
    var region := Rect2(float(frame) * ENEMY_CELL.x, float(pilgrim_facing) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
    var feet := Vector2(roundf(pilgrim_pos.x), roundf(pilgrim_pos.y + 4.0))
    _draw_soft_shadow(pilgrim_pos + Vector2(0.0, 3.0), 13.0)
    if pilgrim_state in ["tell", "hostile"]:
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 8.0)
        _draw_ellipse(pilgrim_pos + Vector2(0.0, 3.0), 22.0, 7.5, Color(0.85, 0.22, 0.28, 0.18 + 0.12 * pulse))
    var tint := Color.WHITE
    if pilgrim_hit_t > 0.0 and int(pilgrim_hit_t * 30.0) % 2 == 0:
        tint = Color(1.0, 0.42, 0.38)
    elif pilgrim_stun > 0.0:
        tint = Color(0.75, 0.85, 1.0)
    draw_texture_rect_region(sheet, Rect2(feet.x - ENEMY_CELL.x * 0.5, feet.y - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y), region, tint)
    if pilgrim_state == "hostile" and pilgrim_timer > 0.0:
        # Destello del filo justo antes del tajo.
        draw_circle(feet + Vector2(0.0, -58.0), 3.0 + 5.0 * (1.0 - pilgrim_timer / 0.42), Color(1.0, 1.0, 1.0, 0.8))


## Bocadillo de diálogo y vida del Peregrino, por encima de todo.
func _draw_pilgrim_overlay() -> void:
    if pilgrim_state == "dead":
        return
    var head := pilgrim_pos + Vector2(0.0, -60.0)
    if pilgrim_state in ["tell", "hostile"] or pilgrim_hp < PILGRIM_MAX_HP:
        var bar := Rect2(pilgrim_pos.x - 22.0, head.y - 6.0, 44.0, 5.0)
        draw_rect(bar.grow(1.0), Color(0, 0, 0, 0.7))
        draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(pilgrim_hp / PILGRIM_MAX_HP, 0.0, 1.0), bar.size.y)), Color("#d1474f"))
        head.y -= 10.0
    if pilgrim_state == "tell":
        _label_center("!", head + Vector2(0.0, -2.0), RED)
    if pilgrim_line_t <= 0.0:
        return
    var a: float = clampf(pilgrim_line_t * 2.0, 0.0, 1.0)
    var size: int = 12
    var width: float = minf(font.get_string_size(pilgrim_line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + 18.0, 420.0)
    var box := Rect2(clampf(pilgrim_pos.x - width * 0.5, 46.0, W - width - 46.0), head.y - 34.0, width, 22.0)
    draw_rect(box, Color(0.93, 0.89, 0.80, 0.92 * a))
    draw_colored_polygon(PackedVector2Array([Vector2(pilgrim_pos.x - 5, box.end.y), Vector2(pilgrim_pos.x + 5, box.end.y), Vector2(pilgrim_pos.x, box.end.y + 7)]), Color(0.93, 0.89, 0.80, 0.92 * a))
    draw_string(font, box.position + Vector2(9, 16), pilgrim_line, HORIZONTAL_ALIGNMENT_LEFT, width - 12.0, size, Color(0.10, 0.09, 0.08, a))


## Eco «Nuca fría»: escarcha en el borde de la pantalla del lado de la amenaza.
func _draw_nuca() -> void:
    if not ecos.has("nuca") or not _pilgrim_behind():
        return
    var side: Vector2 = (pilgrim_pos - player_pos).normalized()
    var k: float = 0.5 + 0.5 * sin(elapsed * 4.0)
    var col := Color(0.62, 0.84, 0.95, 0.10 + 0.08 * k)
    var clear := Color(0.62, 0.84, 0.95, 0.0)
    if absf(side.x) > absf(side.y):
        var x0: float = ARENA.position.x if side.x < 0.0 else ARENA.end.x - 90.0
        _hgradient(Rect2(x0, ARENA.position.y, 90.0, ARENA.size.y), col if side.x < 0.0 else clear, clear if side.x < 0.0 else col)
    else:
        var y0: float = ARENA.position.y if side.y < 0.0 else ARENA.end.y - 70.0
        _vgradient(Rect2(ARENA.position.x, y0, ARENA.size.x, 70.0), col if side.y < 0.0 else clear, clear if side.y < 0.0 else col)


## Desgaste progresivo del templo (GDD §5): grietas y cascotes según el piso.
func _draw_wear() -> void:
    var wear: float = float(_floor().get("wear", 0.0))
    if wear <= 0.0:
        return
    var rng := RandomNumberGenerator.new()
    rng.seed = hash(_room_key())
    var dark := Color(0.03, 0.04, 0.04, 0.55)
    var lit := Color(0.55, 0.60, 0.50, 0.18)
    for n in range(int(7.0 * wear)):
        var p := Vector2(rng.randf_range(90.0, 870.0), rng.randf_range(180.0, 540.0))
        var ang: float = rng.randf_range(0.0, TAU)
        var pts := PackedVector2Array([p])
        for k in range(rng.randi_range(3, 6)):
            ang += rng.randf_range(-0.7, 0.7)
            p += Vector2.from_angle(ang) * rng.randf_range(8.0, 18.0)
            pts.append(p)
            if rng.randf() < 0.35: # ramificación
                draw_line(p, p + Vector2.from_angle(ang + 1.2) * 9.0, dark, 1.0)
        draw_polyline(pts, dark, 1.5)
        var edge := PackedVector2Array()
        for q in pts:
            edge.append(q + Vector2(1.0, -1.0)) # filo iluminado desde arriba
        draw_polyline(edge, lit, 1.0)
    # Grietas en la cara del muro del fondo.
    for n in range(int(4.0 * wear)):
        var x: float = rng.randf_range(100.0, 860.0)
        draw_polyline(PackedVector2Array([Vector2(x, 124.0), Vector2(x + rng.randf_range(-6, 6), 136.0), Vector2(x + rng.randf_range(-8, 8), 150.0)]), dark, 1.5)
    # Cascotes caídos.
    for n in range(int(10.0 * wear)):
        var q := Vector2(rng.randf_range(80.0, 880.0), rng.randf_range(165.0, 545.0))
        draw_rect(Rect2(q, Vector2(rng.randi_range(2, 4), rng.randi_range(2, 3))), Color(0.42, 0.45, 0.38, 0.6))


# ============================================================ DECORADOS
## Detalle de mazmorra (herramientas/generar_decorados.py): sin colisión,
## en espejo respecto al eje x = 480 y siempre igual en la misma sala.
const DECOR := {
    "craneo": preload("res://assets/visual/decorados/craneo.png"),
    "huesos": preload("res://assets/visual/decorados/huesos.png"),
    "costillar": preload("res://assets/visual/decorados/costillar.png"),
    "vasija_rota": preload("res://assets/visual/decorados/vasija_rota.png"),
    "velas": preload("res://assets/visual/decorados/velas.png"),
    "charco_grande": preload("res://assets/visual/decorados/charco_grande.png"),
    "charco_pequeno": preload("res://assets/visual/decorados/charco_pequeno.png"),
    "reguero": preload("res://assets/visual/decorados/reguero.png"),
    "estandarte": preload("res://assets/visual/decorados/estandarte.png"),
    "cadena": preload("res://assets/visual/decorados/cadena.png"),
    "telarana": preload("res://assets/visual/decorados/telarana.png"),
    "manos": preload("res://assets/visual/decorados/manos.png"),
    "goteo": preload("res://assets/visual/decorados/goteo.png"),
}
const DECOR_FLOOR := ["craneo", "huesos", "costillar", "vasija_rota", "velas", "charco_pequeno", "charco_grande", "reguero"]
var decor_cache_key: String = ""
var decor_cache: Array = [] # [clave, posición (arriba-izquierda), espejo]


func _decor_layout() -> Array:
    if decor_cache_key == _room_key():
        return decor_cache
    decor_cache_key = _room_key()
    decor_cache = []
    var rng := RandomNumberGenerator.new()
    rng.seed = hash("decor:" + _room_key())
    var wear: float = float(_floor().get("wear", 0.0))
    # Puntos que no se deben tapar: almas, objetos, puerta, entrada y objetos de juego.
    var keep_clear: Array = relics.duplicate()
    keep_clear.append_array([door_pos, Vector2(115, 359), seal_pos, altar_pos, archive_pos, book_pos])
    for item in room_items:
        keep_clear.append(item["pos"])
    # Muro del fondo: estandartes y cadenas en parejas; sangre según el piso.
    var wall_slots := [150.0, 262.0, 372.0]
    for x in wall_slots:
        var roll: float = rng.randf()
        var key: String = "estandarte" if roll < 0.4 else ("cadena" if roll < 0.7 else ("manos" if roll < 0.7 + 0.15 * (1.0 + wear) else "goteo"))
        var tex: Texture2D = DECOR[key]
        var y: float = 121.0 if key in ["estandarte", "cadena"] else 126.0
        decor_cache.append([key, Vector2(x - tex.get_width() * 0.5, y), false])
        decor_cache.append([key, Vector2(960.0 - x - tex.get_width() * 0.5, y), true])
    # Telarañas en las esquinas del fondo.
    decor_cache.append(["telarana", Vector2(68, 158), false])
    decor_cache.append(["telarana", Vector2(893 - 26, 158), true])
    # Suelo: restos en la mitad izquierda y su reflejo.
    var count: int = 6 + int(3.0 * wear)
    var tries: int = 0
    var placed: int = 0
    while placed < count and tries < 80:
        tries += 1
        var key2: String = DECOR_FLOOR[rng.randi() % DECOR_FLOOR.size()]
        if key2 in ["charco_grande", "reguero"] and rng.randf() > 0.5 + 0.4 * wear:
            continue
        var tex2: Texture2D = DECOR[key2]
        var size := Vector2(tex2.get_width(), tex2.get_height())
        var center := Vector2(rng.randf_range(90.0, 450.0), rng.randf_range(185.0, 535.0))
        var ok: bool = true
        for q in keep_clear:
            if Vector2(q).distance_to(center) < 48.0 or Vector2(960.0 - q.x, q.y).distance_to(center) < 48.0:
                ok = false
                break
        if ok and (_is_blocked(center) or _is_blocked(Vector2(960.0 - center.x, center.y))):
            ok = false
        for d in decor_cache:
            if Vector2(d[1]).distance_to(center - size * 0.5) < 40.0:
                ok = false
        if not ok:
            continue
        var top_left := (center - size * 0.5).round()
        decor_cache.append([key2, top_left, false])
        decor_cache.append([key2, Vector2(960.0 - top_left.x - size.x, top_left.y), true])
        placed += 1
    return decor_cache


func _draw_decor() -> void:
    for d in _decor_layout():
        var tex: Texture2D = DECOR[d[0]]
        _draw_texture_flipped(tex, Rect2(d[1], Vector2(tex.get_width(), tex.get_height())), d[2])
    # Las velas encendidas titilan un poco por encima del suelo.
    for d in decor_cache:
        if d[0] == "velas":
            var c: Vector2 = Vector2(d[1]) + Vector2(11, 6)
            draw_circle(c, 14.0, Color(1.0, 0.7, 0.3, 0.05 + 0.03 * sin(elapsed * 9.0 + c.x)))


# ============================================================ INICIO, AJUSTES, INTRO, TUTORIAL Y PAUSA
## Textos de las pantallas nuevas en español e inglés ([es, en]).
## (El resto del juego sigue en español: la traducción completa está pendiente.)
const T := {
    "continuar": ["HAZ CLIC PARA CONTINUAR", "CLICK TO CONTINUE"],
    "cambiar_pj": ["CAMBIAR (C)", "CHANGE (C)"],
    "sin_pj": ["Al explorar crearás a tu personaje.", "Exploring will create your character."],
    "pj_nombre": ["¿CÓMO TE LLAMAS?", "WHAT IS YOUR NAME?"],
    "pj_nombre_ayuda": ["Escribe o toca las letras  ·  ENTER seguir  ·  ESC volver", "Type or tap the letters  ·  ENTER next  ·  ESC back"],
    "pj_genero": ["ELIGE TU GÉNERO", "CHOOSE YOUR GENDER"],
    "pj_genero_ayuda": ["A / D elegir  ·  ENTER comenzar  ·  ESC atrás", "A / D choose  ·  ENTER start  ·  ESC back"],
    "pj_te_llamas": ["Te llamas %s.", "Your name is %s."],
    "pj_masculino": ["MASCULINO", "MALE"],
    "pj_femenino": ["FEMENINO", "FEMALE"],
    "pj_borrar": ["BORRAR", "DELETE"],
    "pj_espacio": ["ESPACIO", "SPACE"],
    "pj_azar": ["AL AZAR", "RANDOM"],
    "pj_siguiente": ["SIGUIENTE", "NEXT"],
    "pj_atras": ["ATRÁS", "BACK"],
    "pj_comenzar": ["COMENZAR", "START"],
    "pj_vacio": ["Escribe un nombre primero.", "Type a name first."],
    "continuar_tactil": ["TOCA PARA CONTINUAR", "TAP TO CONTINUE"],
    "subtitulo": ["Un roguelike de terror en un templo que se alimenta de ti.", "A horror roguelike in a temple that feeds on you."],
    "ajustes": ["CONFIGURACIÓN", "SETTINGS"],
    "sonido": ["SONIDO", "SOUND"],
    "controles": ["CONTROLES", "CONTROLS"],
    "idioma": ["IDIOMA", "LANGUAGE"],
    "privacidad": ["PRIVACIDAD", "PRIVACY"],
    "vol_general": ["Volumen general", "Master volume"],
    "vol_musica": ["Música", "Music"],
    "vol_efectos": ["Efectos", "Effects"],
    "silencio": ["Silenciar todo", "Mute all"],
    "si": ["SÍ", "ON"],
    "no": ["NO", "OFF"],
    "tactil": ["Controles táctiles", "Touch controls"],
    "auto": ["AUTO", "AUTO"],
    "siempre": ["SIEMPRE", "ALWAYS"],
    "nunca": ["NUNCA", "NEVER"],
    "restablecer": ["Restablecer teclas", "Reset keys"],
    "repetir_tutorial": ["Repetir el tutorial", "Replay tutorial"],
    "ver_intro": ["Ver la intro", "Watch the intro"],
    "pulsa_tecla": ["Pulsa una tecla… (ESC cancela)", "Press a key… (ESC cancels)"],
    "clic_cambiar": ["Haz clic en una acción para cambiar su tecla. Las flechas siempre mueven.", "Click an action to change its key. Arrow keys always move."],
    "nota_idioma": ["La traducción al inglés cubre los menús nuevos; el resto llegará más adelante.", "English covers the new menus; the rest of the game is still in Spanish."],
    "volver": ["VOLVER", "BACK"],
    "acuerdo": ["Acuerdo de usuario", "User agreement"],
    "politica": ["Política de privacidad", "Privacy policy"],
    "borrar": ["Borrar mis datos", "Delete my data"],
    "borrar_seguro": ["¿Seguro? Haz clic otra vez", "Sure? Click again"],
    "borrado": ["Datos borrados.", "Data deleted."],
    "privacidad_resumen": ["Este juego no recoge ni envía datos personales. Solo guarda tu progreso y tus ajustes en este equipo.", "This game does not collect or send personal data. It only stores your progress and settings on this device."],
    "privacidad_ruta": ["Archivos: progreso (%s) y ajustes (%s).", "Files: progress (%s) and settings (%s)."],
    "acuerdo_titulo": ["ANTES DE ENTRAR", "BEFORE YOU ENTER"],
    "acuerdo_texto": [
        "El Templo de los Ecos es una demo en desarrollo con terror, sangre y violencia. Juegas bajo tu responsabilidad. El juego no recoge datos personales: solo guarda tu progreso y tus ajustes en este equipo. Puedes leer el acuerdo completo y borrar tus datos en Configuración > Privacidad.",
        "The Temple of Echoes is a demo in development with horror, blood and violence. You play at your own risk. The game does not collect personal data: it only stores your progress and settings on this device. You can read the full agreement and delete your data in Settings > Privacy.",
    ],
    "aceptar": ["ACEPTAR Y ENTRAR", "ACCEPT AND ENTER"],
    "leer": ["LEER COMPLETO", "READ IN FULL"],
    "salir_juego": ["SALIR", "QUIT"],
    "pausa": ["PAUSA", "PAUSED"],
    "reanudar": ["CONTINUAR", "RESUME"],
    "perfil": ["PERFIL", "PROFILE"],
    "habilidades": ["HABILIDADES", "ABILITIES"],
    "saltar_tutorial": ["SALTAR TUTORIAL", "SKIP TUTORIAL"],
    "volver_inicio": ["VOLVER AL INICIO", "BACK TO START SCREEN"],
    "aviso_abandono": ["La partida se abandonará. No ganarás almas.", "The run will be abandoned. No souls are kept."],
    "saltar": ["ESC: saltar", "ESC: skip"],
    "siguiente": ["CLIC / ENTER: seguir", "CLICK / ENTER: next"],
    "tutorial": ["TUTORIAL", "TUTORIAL"],
}
## Acuerdo de usuario y privacidad (resumen en el juego; texto completo en docs/legal/).
## BORRADOR: no es asesoramiento legal; revisar antes de vender el juego.
const LEGAL := {
    "acuerdo": [
        ["1. Licencia. Puedes jugar esta copia para uso personal. No puedes revender, redistribuir ni descompilar el juego salvo lo que permita la ley.", "1. License. You may play this copy for personal use. You may not resell, redistribute or decompile the game except as the law allows."],
        ["2. Contenido. Incluye terror, sangre, violencia y temas perturbadores. No recomendado para menores.", "2. Content. It includes horror, blood, violence and disturbing themes. Not recommended for minors."],
        ["3. Demo en desarrollo. Puede contener errores; el progreso puede perderse entre versiones.", "3. Demo in development. It may contain bugs; progress may be lost between versions."],
        ["4. Sin garantía. Se ofrece «tal cual», sin garantías, en la medida que permita la ley.", "4. No warranty. It is provided \"as is\", without warranties, to the extent the law allows."],
        ["5. Terceros. La tipografía Pixelify Sans se usa bajo la licencia SIL OFL 1.1.", "5. Third parties. The Pixelify Sans font is used under the SIL OFL 1.1 license."],
    ],
    "politica": [
        ["Qué guarda: tu progreso (almas, identidad, habilidades, Ecos) y tus ajustes (volumen, teclas, idioma, si aceptaste este acuerdo).", "What is stored: your progress (souls, identity, abilities, Echoes) and your settings (volume, keys, language, whether you accepted this agreement)."],
        ["Dónde: solo en este equipo, en la carpeta de datos del juego. Nada se envía por internet.", "Where: only on this device, in the game's data folder. Nothing is sent over the internet."],
        ["Qué no hace: no hay cuentas, ni publicidad, ni estadísticas, ni seguimiento.", "What it does not do: no accounts, no ads, no analytics, no tracking."],
        ["Tus derechos: puedes borrar todos tus datos desde Configuración > Privacidad > Borrar mis datos.", "Your rights: you can delete all your data from Settings > Privacy > Delete my data."],
    ],
}
const Ajustes := preload("res://scripts/ajustes.gd")
const GEAR_RECT := Rect2(16, 572, 52, 52)
const SETTINGS_PANEL := Rect2(100, 60, 760, 520)
var settings_tab: int = 0
var settings_sel: int = 0
var settings_return: String = "splash"
var rebinding: String = ""
var dragging_slider: String = ""
var confirm_delete: bool = false
var legal_page: String = ""
var pause_sel: int = 0
var ui_hover: Vector2 = Vector2(-100, -100)
var intro_slide: int = 0
var intro_t: float = 0.0
var intro_then: String = "tutorial"
## Tutorial: una sala de práctica antes del Piso I.
const TUTORIAL_FLOOR := {
    "number": "0", "title": "PRÓLOGO", "state": "SALA DE PRÁCTICA", "wear": 0.0, "eco": "",
    "rooms": [
        {"scene": 0, "name": "PRÓLOGO · SALA DE PRÁCTICA", "enemy": "", "traits": ["practica"],
         "whisper": "Aprende a moverte antes de que el templo te enseñe a su manera.", "items": []},
    ],
}
const DUMMY_POS := Vector2(480, 300)
var in_tutorial: bool = false
var tutorial_step: int = 0
var tut_moved: float = 0.0
var tut_prev: Vector2 = Vector2.ZERO
var tut_dashed: bool = false
var tut_profile: bool = false
var tut_paused: bool = false
var dummy_hits: int = 0
var dummy_shake: float = 0.0


func _t(key: String) -> String:
    var pair: Array = T.get(key, [key, key])
    return pair[1] if Ajustes.obtener("idioma") == "en" else pair[0]


func _lang_pick(pair: Array) -> String:
    return pair[1] if Ajustes.obtener("idioma") == "en" else pair[0]


func _key(action: String) -> int:
    return Ajustes.tecla(action)


func _apply_touch_setting() -> void:
    match str(Ajustes.obtener("tactil")):
        "siempre":
            touch_enabled = true
        "nunca":
            touch_enabled = false
        _:
            touch_enabled = DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")


# ------------------------------------------------------------ PANTALLA DE INICIO
func _splash_continue() -> void:
    Engine.set_meta("splash_visto", true)
    _sfx("interfaz", -8.0, 0.8)
    game_mode = "title" if bool(Ajustes.obtener("acuerdo_aceptado")) else "eula"


func _accept_eula() -> void:
    Ajustes.poner("acuerdo_aceptado", true)
    Ajustes.poner("acuerdo_version", 1)
    game_mode = "title"
    _sfx("sello", -10.0, 1.2)


func _back_to_splash() -> void:
    in_tutorial = false
    game_mode = "splash"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    current_floor = 0
    current_room = 0
    _enter_room() # la sala del Umbral vuelve como fondo


func _draw_splash() -> void:
    # El templo detrás, casi a oscuras, con niebla que respira.
    draw_rect(Rect2(0, 0, W, H), Color(0.01, 0.012, 0.02, 0.82))
    for i in range(9):
        var x: float = fmod(float(i) * 137.0 + elapsed * (6.0 + float(i % 3) * 3.0), W + 300.0) - 150.0
        var y: float = 470.0 + float(i % 4) * 34.0 + sin(elapsed * 0.5 + float(i)) * 10.0
        var rad: float = 90.0 + float(i % 3) * 30.0
        for k in range(4): # bordes suaves: discos concéntricos muy tenues
            draw_circle(Vector2(x, y), rad * (1.0 - float(k) * 0.22), Color(0.55, 0.65, 0.68, 0.007))
    var glow: float = 0.5 + 0.5 * sin(elapsed * 1.4)
    draw_circle(Vector2(480, 205), 120.0 + glow * 8.0, Color(0.45, 0.75, 0.85, 0.05))
    draw_texture_rect(BRAND_ICON, Rect2(424, 118, 112, 112), false)
    _text_outline("EL TEMPLO", Vector2(0, 300), 56, CREAM, W)
    _text_outline("DE LOS ECOS", Vector2(0, 358), 60, SOUL, W)
    _text_outline(_t("subtitulo"), Vector2(0, 392), 15, Color("#b9b29b"), W)
    var pulse: float = 0.35 + 0.65 * (0.5 + 0.5 * sin(elapsed * 3.2))
    _text_outline(_t("continuar_tactil") if touch_enabled else _t("continuar"), Vector2(0, 478), 24, Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, pulse), W)
    # Engranaje de configuración, abajo a la izquierda.
    var hot: bool = GEAR_RECT.has_point(ui_hover)
    _panel(GEAR_RECT, Color("#222c39") if hot else Color("#141922"), UI_GOLD if hot else UI_LIGHT)
    var spin: float = elapsed * (1.5 if hot else 0.3)
    draw_set_transform(GEAR_RECT.get_center(), spin, Vector2.ONE)
    draw_texture_rect(ICONS["engranaje"], Rect2(Vector2(-16, -16), Vector2(32, 32)), false)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if hot:
        _text_outline(_t("ajustes"), Vector2(78, 604), 14, CREAM)
    _text_outline("v0.9 · demo", Vector2(820, 630), 11, Color("#6d6a60"))


func _draw_eula() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0.01, 0.012, 0.02, 0.88))
    var panel := Rect2(150, 150, 660, 300)
    _panel(panel, Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _text_outline(_t("acuerdo_titulo"), Vector2(panel.position.x, 196), 26, CREAM, panel.size.x)
    _draw_text_block(_t("acuerdo_texto"), Rect2(186, 222, 588, 120), 15, Color("#d0c8b0"))
    for b in _eula_buttons():
        _ui_button(b["rect"], _t(b["label"]), b["id"] == "aceptar")


func _eula_buttons() -> Array:
    return [
        {"id": "aceptar", "label": "aceptar", "rect": Rect2(180, 374, 250, 50)},
        {"id": "leer", "label": "leer", "rect": Rect2(446, 374, 180, 50)},
        {"id": "salir", "label": "salir_juego", "rect": Rect2(642, 374, 136, 50)},
    ]


## Texto con saltos de línea automáticos dentro de un rectángulo.
func _draw_text_block(text: String, box: Rect2, size: int, color: Color) -> float:
    var words: PackedStringArray = text.split(" ")
    var line: String = ""
    var y: float = box.position.y + float(size)
    for w in words:
        var test: String = w if line == "" else line + " " + w
        if font.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > box.size.x and line != "":
            draw_string(font, Vector2(box.position.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
            y += float(size) + 7.0
            line = w
        else:
            line = test
    if line != "":
        draw_string(font, Vector2(box.position.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
    return y


## Botón de interfaz con bisel; resaltado al pasar el cursor.
func _ui_button(rect: Rect2, label: String, primary: bool = false, selected: bool = false) -> void:
    var hot: bool = rect.has_point(ui_hover) or selected
    var fill: Color = Color("#1d4a4f") if primary else Color("#1a1f2a")
    if hot:
        fill = fill.lightened(0.15)
    _panel(rect, fill, UI_GOLD if hot else (SOUL if primary else UI_LIGHT))
    _text_outline(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.5 + 6.0), 16, CREAM, rect.size.x)


# ------------------------------------------------------------ CONFIGURACIÓN
func _open_settings(from_mode: String) -> void:
    settings_return = from_mode
    game_mode = "settings"
    settings_tab = 0
    settings_sel = 0
    rebinding = ""
    confirm_delete = false
    legal_page = ""
    _sfx("interfaz", -8.0)


func _close_settings() -> void:
    rebinding = ""
    legal_page = ""
    game_mode = settings_return
    _sfx("interfaz", -12.0, 0.9)


## Lista de controles de la pestaña actual: se usa para dibujar y para la entrada.
func _settings_widgets() -> Array:
    var list: Array = []
    var tabs := ["sonido", "controles", "idioma", "privacidad"]
    for i in range(tabs.size()):
        list.append({"kind": "tab", "id": i, "label": _t(tabs[i]), "rect": Rect2(118.0 + float(i) * 182.0, 112.0, 174.0, 40.0)})
    if legal_page != "":
        list.append({"kind": "button", "id": "cerrar_legal", "label": _t("volver"), "rect": Rect2(660, 520, 180, 44)})
        return list
    match settings_tab:
        0:
            var rows := [["slider", "volumen_general", "vol_general"], ["slider", "volumen_musica", "vol_musica"], ["slider", "volumen_efectos", "vol_efectos"], ["toggle", "silencio", "silencio"]]
            for i in range(rows.size()):
                list.append({"kind": rows[i][0], "id": rows[i][1], "label": _t(rows[i][2]), "rect": Rect2(140, 182.0 + float(i) * 70.0, 680, 54)})
        1:
            for i in range(Ajustes.ORDEN.size()):
                var action: String = Ajustes.ORDEN[i]
                var col: int = i / 6
                list.append({"kind": "key", "id": action, "label": _lang_pick(Ajustes.ACCIONES[action]),
                    "rect": Rect2(130.0 + float(col) * 356.0, 182.0 + float(i % 6) * 38.0, 344, 33)})
            list.append({"kind": "choice", "id": "tactil", "label": _t("tactil"), "rect": Rect2(130, 418, 700, 40)})
            list.append({"kind": "button", "id": "restablecer", "label": _t("restablecer"), "rect": Rect2(130, 470, 224, 42)})
            list.append({"kind": "button", "id": "repetir_tutorial", "label": _t("repetir_tutorial"), "rect": Rect2(368, 470, 224, 42)})
            list.append({"kind": "button", "id": "ver_intro", "label": _t("ver_intro"), "rect": Rect2(606, 470, 224, 42)})
        2:
            list.append({"kind": "lang", "id": "es", "label": "ESPAÑOL", "rect": Rect2(250, 200, 460, 56)})
            list.append({"kind": "lang", "id": "en", "label": "ENGLISH", "rect": Rect2(250, 268, 460, 56)})
        3:
            list.append({"kind": "button", "id": "acuerdo", "label": _t("acuerdo"), "rect": Rect2(140, 330, 330, 46)})
            list.append({"kind": "button", "id": "politica", "label": _t("politica"), "rect": Rect2(490, 330, 330, 46)})
            list.append({"kind": "button", "id": "borrar", "label": _t("borrar_seguro") if confirm_delete else _t("borrar"), "rect": Rect2(140, 392, 330, 46)})
    list.append({"kind": "button", "id": "volver", "label": _t("volver"), "rect": Rect2(660, 520, 180, 44)})
    return list


func _settings_focusable() -> Array:
    return _settings_widgets().filter(func(w): return w["kind"] != "tab")


func _draw_settings() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.82))
    _panel(SETTINGS_PANEL, Color(0.05, 0.06, 0.08, 0.98), UI_GOLD)
    _panel(Rect2(380, 48, 200, 30), Color("#2a1d22"), UI_GOLD)
    _text_outline(_t("ajustes"), Vector2(380, 69), 16, CREAM, 200.0)
    var focus: Array = _settings_focusable()
    var focused: Dictionary = focus[clampi(settings_sel, 0, focus.size() - 1)] if not focus.is_empty() else {}
    for w in _settings_widgets():
        var r: Rect2 = w["rect"]
        var hot: bool = r.has_point(ui_hover) or (not focused.is_empty() and str(w["id"]) == str(focused["id"]) and w["kind"] == focused["kind"])
        match w["kind"]:
            "tab":
                var on: bool = int(w["id"]) == settings_tab
                _panel(r, Color("#2a1d22") if on else Color("#141922"), UI_GOLD if on or hot else UI_EDGE)
                _text_outline(w["label"], Vector2(r.position.x, r.position.y + 26.0), 15, CREAM if on else Color("#9a957f"), r.size.x)
            "slider":
                _panel(r, Color("#1a1f2a") if hot else Color("#11151c"), UI_GOLD if hot else UI_EDGE)
                _text_outline(w["label"], Vector2(r.position.x + 18.0, r.position.y + 33.0), 15, CREAM)
                var v: float = float(Ajustes.obtener(w["id"]))
                _px_bar(_slider_track(r), v, SOUL, "%d%%" % int(round(v * 100.0)))
            "toggle":
                _panel(r, Color("#1a1f2a") if hot else Color("#11151c"), UI_GOLD if hot else UI_EDGE)
                _text_outline(w["label"], Vector2(r.position.x + 18.0, r.position.y + 33.0), 15, CREAM)
                var on2: bool = bool(Ajustes.obtener(w["id"]))
                var pill := Rect2(r.end.x - 110.0, r.position.y + 10.0, 92, 34)
                _panel(pill, Color("#5a1f26") if on2 else Color("#1d3a2c"), UI_LIGHT)
                _text_outline(_t("si") if on2 else _t("no"), Vector2(pill.position.x, pill.position.y + 23.0), 14, CREAM, pill.size.x)
            "key":
                var waiting: bool = rebinding == str(w["id"])
                _panel(r, Color("#2a1d22") if waiting else (Color("#1a1f2a") if hot else Color("#11151c")), UI_GOLD if hot or waiting else UI_EDGE)
                _text_outline(w["label"], Vector2(r.position.x + 12.0, r.position.y + 25.0), 13, CREAM)
                var cap := Rect2(r.end.x - 118.0, r.position.y + 5.0, 110, 28)
                _panel(cap, Color("#232836"), UI_GOLD if waiting else UI_LIGHT)
                _text_outline("…" if waiting else Ajustes.nombre_tecla(w["id"]), Vector2(cap.position.x, cap.position.y + 20.0), 13, UI_GOLD if waiting else CREAM, cap.size.x)
            "choice":
                _panel(r, Color("#1a1f2a") if hot else Color("#11151c"), UI_GOLD if hot else UI_EDGE)
                _text_outline(w["label"], Vector2(r.position.x + 12.0, r.position.y + 26.0), 14, CREAM)
                var opts := ["auto", "siempre", "nunca"]
                for i in range(3):
                    var o := _choice_rect(r, i)
                    var sel: bool = str(Ajustes.obtener("tactil")) == opts[i]
                    _panel(o, Color("#1d4a4f") if sel else Color("#141922"), SOUL if sel else UI_EDGE)
                    _text_outline(_t(opts[i]), Vector2(o.position.x, o.position.y + 21.0), 13, CREAM, o.size.x)
            "lang":
                var sel2: bool = str(Ajustes.obtener("idioma")) == str(w["id"])
                _panel(r, Color("#1d4a4f") if sel2 else (Color("#1a1f2a") if hot else Color("#11151c")), SOUL if sel2 else (UI_GOLD if hot else UI_EDGE))
                _text_outline(("● " if sel2 else "○ ") + w["label"], Vector2(r.position.x, r.position.y + 36.0), 20, CREAM, r.size.x)
            "button":
                _ui_button(r, w["label"], str(w["id"]) == "volver", hot)
    # Textos propios de cada pestaña.
    if legal_page != "":
        _text_outline(_t(legal_page), Vector2(140, 192), 18, UI_GOLD)
        var y: float = 210.0
        for para in LEGAL[legal_page]:
            y = _draw_text_block(_lang_pick(para), Rect2(140, y, 680, 60), 13, Color("#d0c8b0")) + 14.0
        _text_outline("BORRADOR · no es asesoramiento legal" if Ajustes.obtener("idioma") == "es" else "DRAFT · not legal advice", Vector2(140, 548), 11, Color("#8a8574"))
        return
    match settings_tab:
        1:
            _text_outline(_t("pulsa_tecla") if rebinding != "" else _t("clic_cambiar"), Vector2(130, 176 - 4), 12, UI_GOLD if rebinding != "" else Color("#9a957f"))
        2:
            _draw_text_block(_t("nota_idioma"), Rect2(250, 350, 460, 60), 13, Color("#9a957f"))
        3:
            _draw_text_block(_t("privacidad_resumen"), Rect2(140, 178, 680, 60), 15, Color("#d0c8b0"))
            _draw_text_block(_t("privacidad_ruta") % [SAVE_PATH, Ajustes.RUTA], Rect2(140, 262, 680, 40), 12, Color("#9a957f"))
            if confirm_delete:
                _text_outline("Se borrará el progreso y los ajustes." if Ajustes.obtener("idioma") == "es" else "Progress and settings will be deleted.", Vector2(490, 420), 12, RED)


func _slider_track(r: Rect2) -> Rect2:
    return Rect2(r.position.x + 300.0, r.position.y + 15.0, r.size.x - 320.0, 24.0)


func _choice_rect(r: Rect2, i: int) -> Rect2:
    return Rect2(r.end.x - 360.0 + float(i) * 120.0, r.position.y + 5.0, 112, 30)


func _settings_click(at: Vector2) -> void:
    for w in _settings_widgets():
        if not (w["rect"] as Rect2).has_point(at):
            continue
        _settings_activate(w, at)
        return


func _settings_activate(w: Dictionary, at: Vector2 = Vector2(-1, -1)) -> void:
    match w["kind"]:
        "tab":
            settings_tab = int(w["id"])
            settings_sel = 0
            confirm_delete = false
            rebinding = ""
            _sfx("interfaz", -12.0, 1.1)
        "slider":
            dragging_slider = w["id"]
            if at.x >= 0.0:
                _set_slider(w, at.x)
        "toggle":
            Ajustes.poner(w["id"], not bool(Ajustes.obtener(w["id"])))
            Ajustes.aplicar_audio()
            _sfx("toque", -8.0)
        "key":
            rebinding = w["id"]
        "choice":
            var opts := ["auto", "siempre", "nunca"]
            var idx: int = opts.find(str(Ajustes.obtener("tactil")))
            if at.x >= 0.0:
                for i in range(3):
                    if _choice_rect(w["rect"], i).has_point(at):
                        idx = i
            else:
                idx = (idx + 1) % 3
            Ajustes.poner("tactil", opts[idx])
            _apply_touch_setting()
        "lang":
            Ajustes.poner("idioma", w["id"])
            _sfx("interfaz", -10.0)
        "button":
            match w["id"]:
                "volver":
                    _close_settings()
                "cerrar_legal":
                    legal_page = ""
                "acuerdo", "politica":
                    legal_page = w["id"]
                "restablecer":
                    Ajustes.restablecer_teclas()
                    _sfx("interfaz", -8.0)
                "repetir_tutorial":
                    Ajustes.poner("tutorial_hecho", false)
                    _start_tutorial()
                "ver_intro":
                    _start_intro("title" if settings_return in ["splash", "title"] else "title")
                "borrar":
                    if confirm_delete:
                        Ajustes.borrar_todo(SAVE_PATH)
                        Ajustes.aplicar_audio()
                        _reset_progress_vars()
                        confirm_delete = false
                        _say(_t("borrado"), 2.5)
                        _back_to_splash()
                    else:
                        confirm_delete = true


func _set_slider(w: Dictionary, x: float) -> void:
    var track: Rect2 = _slider_track(w["rect"])
    var v: float = clampf((x - track.position.x) / track.size.x, 0.0, 1.0)
    Ajustes.datos[w["id"]] = snappedf(v, 0.05)
    Ajustes.aplicar_audio()


func _settings_key(k: int) -> void:
    if rebinding != "":
        if k != KEY_ESCAPE:
            Ajustes.asignar_tecla(rebinding, k)
            _sfx("interfaz", -8.0, 1.2)
        rebinding = ""
        return
    var focus: Array = _settings_focusable()
    if k == KEY_ESCAPE:
        if legal_page != "":
            legal_page = ""
        else:
            _close_settings()
        return
    if focus.is_empty():
        return
    settings_sel = clampi(settings_sel, 0, focus.size() - 1)
    var w: Dictionary = focus[settings_sel]
    if k in [KEY_DOWN, KEY_S]:
        settings_sel = (settings_sel + 1) % focus.size()
    elif k in [KEY_UP, KEY_W]:
        settings_sel = (settings_sel + focus.size() - 1) % focus.size()
    elif k in [KEY_LEFT, KEY_RIGHT, KEY_A, KEY_D]:
        var dir: float = -1.0 if k in [KEY_LEFT, KEY_A] else 1.0
        if w["kind"] == "slider":
            Ajustes.datos[w["id"]] = clampf(float(Ajustes.obtener(w["id"])) + 0.05 * dir, 0.0, 1.0)
            Ajustes.aplicar_audio()
        elif w["kind"] == "choice":
            _settings_activate(w)
        else:
            settings_tab = (settings_tab + (1 if dir > 0.0 else 3)) % 4
            settings_sel = 0
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
        _settings_activate(w)
    elif k == KEY_TAB:
        settings_tab = (settings_tab + 1) % 4
        settings_sel = 0


func _reset_progress_vars() -> void:
    identity_number = 1
    new_humans = 0
    reincarnations = 0
    deaths = 0
    cleared = 0
    has_pulse = false
    has_inner_flame = false
    ability_level = 0
    ecos.clear()
    remembered_rule = false


# ------------------------------------------------------------ PAUSA
func _open_pause() -> void:
    if game_mode != "play":
        return
    game_mode = "pause"
    pause_sel = 0
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -8.0, 0.8)


func _pause_options() -> Array:
    var opts := ["reanudar", "ajustes", "perfil", "habilidades"]
    if in_tutorial:
        opts.append("saltar_tutorial")
    opts.append("volver_inicio")
    return opts


func _pause_rect(i: int) -> Rect2:
    return Rect2(330, 210.0 + float(i) * 62.0, 300, 50)


func _pause_choose(i: int) -> void:
    match _pause_options()[i]:
        "reanudar":
            game_mode = "play"
            if in_tutorial:
                tut_paused = true
            _sfx("interfaz", -12.0, 0.9)
        "ajustes":
            _open_settings("pause")
        "perfil":
            game_mode = "play"
            _open_inventory()
        "habilidades":
            game_mode = "play"
            _open_abilities()
        "saltar_tutorial":
            _end_tutorial()
        "volver_inicio":
            _back_to_splash()


func _draw_pause() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.7))
    var opts: Array = _pause_options()
    var panel := Rect2(300, 130, 360, 90.0 + float(opts.size()) * 62.0)
    _panel(panel, Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _text_outline(_t("pausa"), Vector2(panel.position.x, 180), 30, CREAM, panel.size.x)
    for i in range(opts.size()):
        _ui_button(_pause_rect(i), _t(opts[i]), i == 0, i == pause_sel)
    if opts[pause_sel] == "volver_inicio":
        _text_outline(_t("aviso_abandono"), Vector2(0, panel.end.y + 24.0), 13, RED, W)


func _pause_key(k: int) -> void:
    var n: int = _pause_options().size()
    if k == KEY_ESCAPE or k == _key("pausa"):
        _pause_choose(0)
    elif k in [KEY_DOWN, KEY_S]:
        pause_sel = (pause_sel + 1) % n
    elif k in [KEY_UP, KEY_W]:
        pause_sel = (pause_sel + n - 1) % n
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
        _pause_choose(pause_sel)


# ------------------------------------------------------------ INTRO
## Diapositivas: [texto ES, texto EN, escena]. Escenas: despertar, templo, ojo, almas, descenso.
const INTRO := [
    ["Despiertas sobre piedra fría. No recuerdas cómo llegaste.", "You wake on cold stone. You don't remember how you got here.", "despertar"],
    ["Un templo. Columnas que no reconoces. Ecos de pasos que no son tuyos.", "A temple. Columns you don't recognize. Echoes of footsteps that aren't yours.", "templo"],
    ["Algo aquí te observa. Y se alimenta de tu miedo.", "Something here is watching you. And it feeds on your fear.", "ojo"],
    ["Otros llegaron antes. Lo que dejaron atrás todavía brilla.", "Others came before. What they left behind still glows.", "almas"],
    ["Encuentra la luz. Desciende. No confíes en nadie.", "Find the light. Descend. Trust no one.", "descenso"],
]


func _start_explore() -> void:
    if player_name == "":
        _start_creation("explore")
        return
    if not bool(Ajustes.obtener("intro_vista")):
        _start_intro("tutorial")
    elif not bool(Ajustes.obtener("tutorial_hecho")):
        _start_tutorial()
    else:
        _new_run()


func _start_intro(then: String) -> void:
    intro_then = then
    intro_slide = 0
    intro_t = 0.0
    game_mode = "intro"
    _sfx("ojo", -14.0, 0.7)


func _intro_next() -> void:
    var full_len: int = _lang_pick(INTRO[intro_slide]).length()
    if int(intro_t * 38.0) < full_len:
        intro_t = float(full_len) / 38.0 + 0.01 # muestra el texto completo
        return
    intro_slide += 1
    intro_t = 0.0
    if intro_slide >= INTRO.size():
        _end_intro()
    else:
        _sfx("toque", -16.0, 0.7)


func _end_intro() -> void:
    Ajustes.poner("intro_vista", true)
    if intro_then == "tutorial" and not bool(Ajustes.obtener("tutorial_hecho")):
        _start_tutorial()
    elif intro_then == "tutorial":
        _new_run()
    else:
        game_mode = "title"


func _draw_intro() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 1.0))
    var slide: Array = INTRO[clampi(intro_slide, 0, INTRO.size() - 1)]
    var fade: float = clampf(intro_t * 1.5, 0.0, 1.0)
    var c := Vector2(480, 270)
    match slide[2]:
        "despertar":
            # Mark tendido en un círculo de luz mortecina.
            draw_circle(c + Vector2(0, 30), 120.0, Color(0.35, 0.45, 0.5, 0.10 * fade))
            var region := Rect2(8.0 * 40.0, 0.0, 40.0, 56.0)
            draw_texture_rect_region(_hero_sheet(), Rect2(c + Vector2(-60, -50), Vector2(120, 168)), region, Color(1, 1, 1, fade))
        "templo":
            draw_set_transform(Vector2(-240, -160) * fade * 0.05, 0.0, Vector2.ONE)
            for k in range(4):
                var x: float = 230.0 + float(k) * 170.0
                draw_rect(Rect2(x, 150, 28, 260), Color(0.25, 0.3, 0.28, 0.6 * fade))
                draw_rect(Rect2(x - 8, 140, 44, 14), Color(0.35, 0.4, 0.36, 0.6 * fade))
            draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        "ojo":
            var open_k: float = clampf(intro_t * 0.8, 0.0, 1.0)
            draw_set_transform(c, 0.0, Vector2(1.0, 0.15 + 0.85 * open_k))
            draw_circle(Vector2.ZERO, 110.0, Color(0.85, 0.82, 0.74, fade))
            draw_circle(Vector2.ZERO, 58.0, Color(0.42, 0.24, 0.57, fade))
            draw_circle(Vector2.ZERO, 26.0, Color(0.05, 0.03, 0.07, fade))
            draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
            for k in range(6):
                var a: float = float(k) * 1.05
                draw_line(c + Vector2.from_angle(a) * 80.0, c + Vector2.from_angle(a + 0.2) * 108.0, Color(0.76, 0.23, 0.25, 0.7 * fade), 2.0)
        "almas":
            for k in range(3):
                var p := c + Vector2(-160.0 + float(k) * 160.0, 40.0)
                _draw_corpse(p, k)
                draw_circle(p + Vector2(0, -26), 30.0, Color(0.56, 0.78, 0.84, 0.15 * fade))
                draw_texture_rect(ICONS["alma"], Rect2(p + Vector2(-16, -46 + sin(elapsed * 2.0 + float(k)) * 4.0), Vector2(32, 32)), false, Color(1, 1, 1, fade))
        "descenso":
            for k in range(6):
                var w: float = 300.0 - float(k) * 44.0
                draw_rect(Rect2(480.0 - w * 0.5, 140.0 + float(k) * 34.0, w, 26), Color(0.20, 0.24, 0.24, (0.7 - float(k) * 0.1) * fade))
            draw_circle(Vector2(480, 380), 14.0, Color(1.0, 0.7, 0.3, 0.5 + 0.3 * sin(elapsed * 9.0)))
    # Texto que se escribe letra a letra.
    var text: String = _lang_pick(slide)
    var shown: String = text.substr(0, int(intro_t * 38.0))
    _text_outline(shown, Vector2(0, 500), 20, CREAM, W)
    for k in range(INTRO.size()):
        draw_rect(Rect2(430.0 + float(k) * 22.0, 540, 14, 4), UI_GOLD if k <= intro_slide else Color("#2a2e38"))
    _text_outline(_t("siguiente"), Vector2(24, 622), 12, Color("#8a8574"))
    _text_outline(_t("saltar"), Vector2(820, 622), 12, Color("#8a8574"))


# ------------------------------------------------------------ TUTORIAL
## Pasos: [texto ES, texto EN]. Las teclas se escriben según la configuración.
func _tutorial_text(step: int) -> String:
    var es := [
        "Muévete con %s %s %s %s o las flechas" % [Ajustes.nombre_tecla("arriba"), Ajustes.nombre_tecla("izquierda"), Ajustes.nombre_tecla("abajo"), Ajustes.nombre_tecla("derecha")],
        "Esquiva con %s: te hace invulnerable un instante" % Ajustes.nombre_tecla("esquivar"),
        "Recoge un alma: basta con tocarla",
        "Pulsa %s para encender la antorcha (gasta un fósforo)" % Ajustes.nombre_tecla("antorcha"),
        "Golpea al muñeco 3 veces con CLIC o %s" % Ajustes.nombre_tecla("interactuar"),
        "Abre tu perfil con %s y vuelve a cerrarlo" % Ajustes.nombre_tecla("perfil"),
        "Pausa el juego con %s y continúa" % Ajustes.nombre_tecla("pausa"),
        "¡Listo! Cruza la puerta para entrar en el templo",
    ]
    var en := [
        "Move with %s %s %s %s or the arrow keys" % [Ajustes.nombre_tecla("arriba"), Ajustes.nombre_tecla("izquierda"), Ajustes.nombre_tecla("abajo"), Ajustes.nombre_tecla("derecha")],
        "Dodge with %s: you are invulnerable for an instant" % Ajustes.nombre_tecla("esquivar"),
        "Collect a soul: just touch it",
        "Press %s to light the torch (uses a match)" % Ajustes.nombre_tecla("antorcha"),
        "Hit the dummy 3 times with CLICK or %s" % Ajustes.nombre_tecla("interactuar"),
        "Open your profile with %s and close it again" % Ajustes.nombre_tecla("perfil"),
        "Pause the game with %s and resume" % Ajustes.nombre_tecla("pausa"),
        "Done! Cross the door to enter the temple",
    ]
    if touch_enabled:
        es[0] = "Muévete con el joystick de la izquierda"
        en[0] = "Move with the joystick on the left"
        es[1] = "Esquiva con el botón DASH"
        en[1] = "Dodge with the DASH button"
        es[3] = "Toca el botón de la antorcha para encenderla"
        en[3] = "Tap the torch button to light it"
        es[4] = "Golpea al muñeco 3 veces con el botón E"
        en[4] = "Hit the dummy 3 times with the E button"
        es[5] = "Toca tu retrato para abrir el perfil y ciérralo"
        en[5] = "Tap your portrait to open the profile, then close it"
        es[6] = "Toca el botón de pausa y continúa"
        en[6] = "Tap the pause button and resume"
    return (en if Ajustes.obtener("idioma") == "en" else es)[clampi(step, 0, es.size() - 1)]


const TUTORIAL_LAST := 7


func _start_tutorial() -> void:
    _new_run()
    in_tutorial = true
    tutorial_step = 0
    tut_moved = 0.0
    tut_dashed = false
    tut_profile = false
    tut_paused = false
    dummy_hits = 0
    current_floor = 0
    current_room = 0
    _enter_room()
    tut_prev = player_pos
    game_mode = "play"


func _end_tutorial() -> void:
    Ajustes.poner("tutorial_hecho", true)
    in_tutorial = false
    _new_run()
    _say("PISO I · EL DESPERTAR. A partir de aquí, nadie te guía.", 4.0)


func _update_tutorial(dt: float) -> void:
    if not in_tutorial:
        return
    dummy_shake = maxf(0.0, dummy_shake - dt)
    tut_moved += player_pos.distance_to(tut_prev)
    tut_prev = player_pos
    if dash_left > 0.0:
        tut_dashed = true
    var done: bool = false
    match tutorial_step:
        0:
            done = tut_moved > 120.0
        1:
            done = tut_dashed
        2:
            done = collected.has(true)
        3:
            done = torch_on
        4:
            done = dummy_hits >= 3
        5:
            done = tut_profile
        6:
            done = tut_paused
    if done and tutorial_step < TUTORIAL_LAST:
        tutorial_step += 1
        _sfx("alma", -8.0, 1.3)
        if tutorial_step == 3:
            has_torch = true
            matches = maxi(matches, 3)
            _say("Toma una antorcha de práctica." if Ajustes.obtener("idioma") == "es" else "Take a practice torch.", 2.5)


func _draw_tutorial_overlay() -> void:
    if not in_tutorial or game_mode != "play":
        return
    var box := Rect2(230, 146, 500, 52)
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 4.0)
    _panel(box, Color(0.05, 0.06, 0.08, 0.93), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.7 + 0.3 * pulse))
    _text_outline("%s %d/%d" % [_t("tutorial"), mini(tutorial_step + 1, TUTORIAL_LAST + 1), TUTORIAL_LAST + 1], Vector2(box.position.x, box.position.y + 18.0), 11, UI_GOLD, box.size.x)
    _text_outline(_tutorial_text(tutorial_step), Vector2(box.position.x, box.position.y + 40.0), 15, CREAM, box.size.x)


## Muñeco de entrenamiento: poste y saco relleno de paja, con diana pintada.
func _draw_dummy() -> void:
    var p := DUMMY_POS + Vector2(sin(elapsed * 50.0) * 3.0 * dummy_shake * 4.0, 0.0)
    _draw_soft_shadow(DUMMY_POS + Vector2(0, 3), 14.0)
    draw_rect(Rect2(p.x - 2.0, p.y - 40.0, 4, 42), Color("#5c3a22"))
    draw_rect(Rect2(p.x - 16.0, p.y - 34.0, 32, 6), Color("#5c3a22"))
    draw_rect(Rect2(p.x - 11.0, p.y - 50.0, 22, 26), Color("#b89a5e"))
    draw_rect(Rect2(p.x - 11.0, p.y - 50.0, 22, 4), Color("#d8bd80"))
    draw_circle(p + Vector2(0, -60), 9.0, Color("#b89a5e"))
    draw_circle(p + Vector2(0, -37), 6.0, Color("#8a1620"))
    draw_circle(p + Vector2(0, -37), 3.0, Color("#e2dccb"))
    for k in range(dummy_hits):
        draw_rect(Rect2(p.x - 8.0 + float(k) * 6.0, p.y - 46.0, 3, 3), Color("#3a2f2a"))


# ------------------------------------------------------------ PERSONAJE
## Creación del personaje: primero el nombre y después el género. Se guarda
## con el progreso y se usa en el HUD, el perfil, el menú y la muerte.
const NAME_MAX := 12
const NAME_ROWS := ["ABCDEFGHIJ", "KLMNÑOPQRS", "TUVWXYZ"]
const NAME_KEY := Vector2(52, 44)
const NAME_GRID := Vector2(193, 252)
const CHANGE_CHAR_RECT := Rect2(676, 528, 120, 26)
const CREATE_PANEL := Rect2(150, 104, 660, 452)
const RANDOM_NAMES := ["ELÍAS", "TOMÁS", "DARÍO", "ADRIÁN", "JONÁS", "MATEO", "LUCÍA", "ELENA", "IRENE", "NORA", "ALBA", "MARA"]
var create_step: int = 0 # 0 nombre, 1 género
var create_buf: String = ""
var create_gender: int = 0 # 0 masculino, 1 femenino
var create_then: String = "explore" # explore | title


func _hero_name() -> String:
    return player_name if player_name != "" else "MARK"


func _portrait(hurt: bool) -> Texture2D:
    if player_gender == "femenino":
        return PORTRAIT_F_HURT if hurt else PORTRAIT_F
    return PORTRAIT_HURT if hurt else PORTRAIT


func _hero_sheet() -> Texture2D:
    return HERO_SHEET_F if player_gender == "femenino" else art["visual_hero"]


func _clean_name(raw: String) -> String:
    var out := ""
    for ch in raw.strip_edges().to_upper():
        if out.length() >= NAME_MAX:
            break
        if ch == " " and (out == "" or out.ends_with(" ")):
            continue
        if ch.unicode_at(0) >= 65 and ch.unicode_at(0) <= 90 or ch in "ÁÉÍÓÚÜÑ -'":
            out += ch
    return out.strip_edges()


func _start_creation(then: String) -> void:
    create_then = then
    create_step = 0
    create_buf = player_name
    create_gender = 1 if player_gender == "femenino" else 0
    game_mode = "create"
    _sfx("interfaz", -8.0, 0.9)


func _create_type(ch: String) -> void:
    if create_buf.length() >= NAME_MAX or ch.length() != 1:
        return
    ch = ch.to_upper()
    var code: int = ch.unicode_at(0)
    if not ((code >= 65 and code <= 90) or ch in "ÁÉÍÓÚÜÑ -'"):
        return
    if ch == " " and (create_buf == "" or create_buf.ends_with(" ")):
        return
    create_buf += ch
    _sfx("toque", -14.0, 1.1)


func _create_next() -> void:
    create_buf = _clean_name(create_buf)
    if create_buf == "":
        _say(_t("pj_vacio"), 2.0)
        return
    create_step = 1
    _sfx("interfaz", -8.0, 1.0)


func _create_finish() -> void:
    player_name = _clean_name(create_buf)
    player_gender = "femenino" if create_gender == 1 else "masculino"
    _save_progress()
    _sfx("sello", -10.0, 1.1)
    if create_then == "explore":
        _start_explore()
    else:
        game_mode = "title"
        _say(_t("pj_te_llamas") % player_name, 2.5)


func _create_back() -> void:
    if create_step == 1:
        create_step = 0
    else:
        game_mode = "title"
    _sfx("interfaz", -10.0, 0.8)


func _create_key(k: Key, unicode: int) -> void:
    if k == KEY_ESCAPE:
        _create_back()
        return
    if create_step == 0:
        if k in [KEY_ENTER, KEY_KP_ENTER]:
            _create_next()
        elif k == KEY_BACKSPACE:
            create_buf = create_buf.substr(0, maxi(0, create_buf.length() - 1))
        elif unicode > 0:
            _create_type(char(unicode))
    else:
        if k in [KEY_LEFT, KEY_A, KEY_RIGHT, KEY_D, KEY_TAB]:
            create_gender = 1 - create_gender
            _sfx("toque", -14.0, 1.0)
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E]:
            _create_finish()


## Teclas en pantalla: [rect, acción]. Acción: una letra o «borrar»,
## «espacio», «azar», «siguiente».
func _create_name_keys() -> Array:
    var keys: Array = []
    for row in range(NAME_ROWS.size()):
        var letters: String = NAME_ROWS[row]
        for col in range(letters.length()):
            keys.append([Rect2(NAME_GRID + Vector2(col * (NAME_KEY.x + 6.0), row * (NAME_KEY.y + 6.0)), NAME_KEY), letters[col]])
    var y3: float = NAME_GRID.y + 2.0 * (NAME_KEY.y + 6.0)
    keys.append([Rect2(NAME_GRID.x + 7.0 * (NAME_KEY.x + 6.0), y3, 3.0 * NAME_KEY.x + 12.0, NAME_KEY.y), "borrar"])
    var y4: float = NAME_GRID.y + 3.0 * (NAME_KEY.y + 6.0) + 8.0
    keys.append([Rect2(193, y4, 170, 44), "espacio"])
    keys.append([Rect2(373, y4, 170, 44), "azar"])
    keys.append([Rect2(553, y4, 214, 44), "siguiente"])
    return keys


func _create_card(i: int) -> Rect2:
    return Rect2(215.0 + i * 280.0, 196.0, 250.0, 236.0)


func _create_step2_buttons() -> Array:
    return [[Rect2(215, 452, 200, 48), "atras"], [Rect2(545, 452, 200, 48), "comenzar"]]


func _create_tap(at: Vector2) -> void:
    if create_step == 0:
        for key in _create_name_keys():
            if not (key[0] as Rect2).has_point(at):
                continue
            match str(key[1]):
                "borrar":
                    create_buf = create_buf.substr(0, maxi(0, create_buf.length() - 1))
                    _sfx("toque", -14.0, 0.8)
                "espacio":
                    _create_type(" ")
                "azar":
                    create_buf = RANDOM_NAMES[randi() % RANDOM_NAMES.size()]
                    _sfx("toque", -12.0, 1.2)
                "siguiente":
                    _create_next()
                _:
                    _create_type(str(key[1]))
            return
        return
    for i in range(2):
        if _create_card(i).has_point(at):
            if create_gender == i:
                _create_finish() # segundo toque sobre la misma tarjeta confirma
            else:
                create_gender = i
                _sfx("toque", -14.0, 1.0)
            return
    for b in _create_step2_buttons():
        if (b[0] as Rect2).has_point(at):
            if b[1] == "atras":
                _create_back()
            else:
                _create_finish()
            return


func _create_key_button(rect: Rect2, label: String, size: int, accent: bool = false) -> void:
    var hot: bool = rect.has_point(ui_hover)
    var fill := Color("#1d4a4f") if accent else Color("#141922")
    _panel(rect, fill.lightened(0.12) if hot else fill, UI_GOLD if hot or accent else UI_EDGE)
    _text_outline(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.5 + size * 0.36), size, CREAM, rect.size.x)


func _draw_creation() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0.018, 0.027, 0.032, 0.72))
    _panel(CREATE_PANEL, Color(0.045, 0.055, 0.07, 0.96), UI_GOLD)
    draw_rect(CREATE_PANEL.grow(-8.0), Color("#3a3f4c"), false, 1.0)
    # Indicador de paso (1 nombre · 2 género).
    for i in range(2):
        var dot := Rect2(462.0 + i * 24.0, 120.0, 12.0, 12.0)
        draw_rect(dot, UI_GOLD if create_step >= i else UI_EDGE)
    if create_step == 0:
        _text_outline(_t("pj_nombre"), Vector2(150, 168), 30, CREAM, CREATE_PANEL.size.x)
        var box := Rect2(300, 182, 360, 54)
        _panel(box, Color("#0b0e13"), SOUL)
        var shown: String = create_buf + ("_" if int(elapsed * 2.0) % 2 == 0 and create_buf.length() < NAME_MAX else " ")
        _text_outline(shown, Vector2(box.position.x, box.position.y + 38.0), 30, SOUL, box.size.x)
        _text_outline("%d/%d" % [create_buf.length(), NAME_MAX], Vector2(box.end.x - 46.0, box.end.y - 6.0), 10, Color("#6b6f80"))
        for key in _create_name_keys():
            var action: String = str(key[1])
            match action:
                "borrar":
                    _create_key_button(key[0], "< " + _t("pj_borrar"), 15)
                "espacio":
                    _create_key_button(key[0], _t("pj_espacio"), 15)
                "azar":
                    _create_key_button(key[0], _t("pj_azar"), 15)
                "siguiente":
                    _create_key_button(key[0], _t("pj_siguiente") + " »", 17, true)
                _:
                    _create_key_button(key[0], action, 20)
        _text_outline(_t("pj_nombre_ayuda"), Vector2(150, 520), 12, Color("#9fb3b3"), CREATE_PANEL.size.x)
    else:
        _text_outline(_t("pj_genero"), Vector2(150, 162), 30, CREAM, CREATE_PANEL.size.x)
        _text_outline(_t("pj_te_llamas") % _clean_name(create_buf), Vector2(150, 186), 14, SOUL, CREATE_PANEL.size.x)
        var labels := [_t("pj_masculino"), _t("pj_femenino")]
        var sheets: Array = [art["visual_hero"], HERO_SHEET_F]
        var portraits: Array = [PORTRAIT, PORTRAIT_F]
        for i in range(2):
            var card := _create_card(i)
            var sel: bool = create_gender == i
            _panel(card, Color("#1a2430") if sel else Color("#10141b"), UI_GOLD if sel else UI_EDGE)
            if sel:
                draw_rect(card.grow(3.0), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.25 + 0.2 * sin(elapsed * 4.0)), false, 2.0)
            # Círculo de luz y el personaje caminando de frente (o quieto si no está elegido).
            var feet := Vector2(card.position.x + 142.0, card.position.y + 186.0)
            draw_circle(feet + Vector2(0, -4), 46.0, Color(0.95, 0.85, 0.55, 0.07 if sel else 0.03))
            draw_set_transform(feet + Vector2(0, -2), 0.0, Vector2(1.0, 0.35))
            draw_circle(Vector2.ZERO, 30.0, Color(0, 0, 0, 0.45))
            draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
            var frame_i: int = (2 + int(elapsed * 7.0) % 4) if sel else int(elapsed * 1.6) % 2
            var region := Rect2(frame_i * 40.0, 0.0, 40.0, 56.0)
            draw_texture_rect_region(sheets[i], Rect2(feet - Vector2(60, 150), Vector2(120, 168)), region, Color(1, 1, 1, 1.0 if sel else 0.6))
            draw_texture_rect(portraits[i], Rect2(card.position + Vector2(12, 12), Vector2(64, 64)), false, Color(1, 1, 1, 1.0 if sel else 0.55))
            _text_outline(labels[i], Vector2(card.position.x, card.end.y - 14.0), 22, CREAM if sel else Color("#8f8a7a"), card.size.x)
        for b in _create_step2_buttons():
            var is_go: bool = b[1] == "comenzar"
            _create_key_button(b[0], (_t("pj_comenzar") + " »") if is_go else ("« " + _t("pj_atras")), 18, is_go)
        _text_outline(_t("pj_genero_ayuda"), Vector2(150, 530), 12, Color("#9fb3b3"), CREATE_PANEL.size.x)
    if toast_left > 0.0:
        _draw_toast()


## Tras la pantalla de muerte o de victoria.
func _after_end() -> void:
    if game_mode == "dead" and soul_fate == "persistencia":
        _respawn()
    else:
        _new_run()


## Muerte sin pérdida: se reaparece en la entrada de la misma sala con todo
## lo que se tenía. Las almas ya recogidas de la sala siguen recogidas.
func _respawn() -> void:
    var keep_collected: Array[bool] = collected.duplicate()
    var keep_letter: bool = letter_found
    hp = max_hp
    fear = 0.0
    stamina = 100.0
    dash_left = 0.0
    dash_cd = 0.0
    game_mode = "play"
    _enter_room()
    collected = keep_collected
    letter_found = keep_letter
    damage_cd = 1.5 # unos instantes de gracia al levantarse
    _say("Te levantas en la entrada. Nada se ha perdido... por ahora.", 3.5)


# ------------------------------------------------------------ PISO III · LA CACERÍA
## El Segador de Hilos: rápido e intocable mientras acecha. Antes de cada
## ataque TENSA sus hilos (línea roja visible, SEG_TENSE s); al disparar,
## todo lo que esté sobre la línea recibe el golpe y él atraviesa el sitio
## donde estabas. Después queda ENGANCHADO a la pared o la columna donde se
## clavaron los hilos: solo entonces es vulnerable. Valores PROVISIONALES.
const SEG_SPEED := 205.0
const SEG_RANGE := 190.0 # distancia a la que le gusta acechar
const SEG_TENSE := 0.9
const SEG_HOOK := 1.6
const SEG_BAND := 15.0 # medio ancho de la línea (lo que roza, recibe)
const SEG_DAMAGE := 45.0
const SEG_OVERSHOOT := 46.0 # cuánto atraviesa más allá de donde apuntó
const ALLY_NAMES := ["ODÓN", "BRUNA", "CIRO"]
const ALLY_TINTS := [Color(0.86, 1.0, 0.9), Color(1.0, 0.88, 0.84), Color(0.86, 0.92, 1.08)]
const ALLY_SOULS := 6 # premio por cada aliado vivo al terminar el piso
var seg_state: String = "acecho" # acecho, tensa, engancha
var seg_t: float = 0.0
var seg_cd: float = 2.0
var seg_circle: float = 1.0
var seg_from: Vector2 = Vector2.ZERO
var seg_to: Vector2 = Vector2.ZERO # donde se clavan los hilos
var seg_dash_to: Vector2 = Vector2.ZERO
var seg_flash: float = 0.0
var seg_hp_floor: float = -1.0 # vida que conserva al huir a la sala siguiente
## Aliados del Piso III: tres peregrinos que te acompañan en la Cacería.
var allies: Array = [] # {name, pos, prev, facing, moving, alive, react, seed, dead_key, dead_pos}
var allies_here: bool = false
var allies_rewarded: bool = false


func _dash_cooldown() -> float:
    return 2.65 * (0.6 if ecos.has("reflejos") else 1.0)


func _segador_enter_room() -> void:
    if seg_hp_floor > 0.0:
        enemy_hp = minf(enemy_max, seg_hp_floor)
    seg_state = "acecho"
    seg_t = 0.0
    seg_cd = 2.4
    seg_flash = 0.0


## Primer encuentro: a media vida huye a la sala siguiente (la puerta se abre).
func _segador_flee() -> void:
    seg_hp_floor = enemy_hp
    banished[_room_key()] = true
    if _mission().get("goal", "") == "ahuyentar":
        _complete_mission()
    seg_state = "acecho"
    dissolve_fx.append({"pos": enemy_pos, "kind": "segador", "facing": enemy_facing, "frame": 2, "t": 0.0})
    shake = maxf(shake, 0.2)
    _sfx("latigo", -6.0, 0.7)
    _say("El Segador recoge sus hilos y huye hacia el coro. La caza sigue.", 4.0)
    _ally_say_random(["¡Se escapa! ¡Tras él!", "Está herido. Ahora o nunca.", "Lo he visto sangrar. Puede morir."])


## Final del rayo desde «from» en «dir»: la primera pared o columna.
func _thread_end(from: Vector2, dir: Vector2) -> Vector2:
    var p := from
    for i in range(220):
        var nxt := p + dir * 5.0
        if nxt.x < 63.0 or nxt.x > 895.0 or nxt.y < 155.0 or nxt.y > 552.0:
            return p
        for rect in obstacles:
            if (rect as Rect2).has_point(nxt):
                return p
        p = nxt
    return p


func _on_thread(at: Vector2, extra: float = 0.0) -> bool:
    var closest: Vector2 = Geometry2D.get_closest_point_to_segment(at, seg_from, seg_to)
    return at.distance_to(closest) < SEG_BAND + extra


func _update_segador(dt: float) -> void:
    enemy_alert = true
    seg_flash = maxf(0.0, seg_flash - dt)
    var d: float = enemy_pos.distance_to(player_pos)
    if enemy_stun > 0.0:
        if seg_state == "tensa":
            # Aturdirlo mientras tensa rompe el ataque.
            seg_state = "acecho"
            seg_cd = 1.4
            _say("La onda corta sus hilos antes de que dispare.", 2.0)
        return
    match seg_state:
        "acecho":
            # Ronda a distancia, rápido; cambia de sentido si choca.
            var to_p: Vector2 = (player_pos - enemy_pos).normalized()
            if to_p == Vector2.ZERO:
                to_p = Vector2.LEFT
            var radial: float = clampf((d - SEG_RANGE) / 60.0, -1.0, 1.0)
            var tangent := Vector2(-to_p.y, to_p.x) * seg_circle
            var orbit: float = 0.9 if d < SEG_RANGE + 120.0 else 0.25 # lejos, primero se acerca
            # Prueba la ruta ideal y, si choca, solo acercarse/alejarse o solo rodear.
            var moved: bool = false
            for v in [to_p * radial + tangent * orbit, to_p * signf(radial + 0.01), tangent, -tangent]:
                var wanted: Vector2 = enemy_pos + (v as Vector2).normalized() * SEG_SPEED * dt
                if (v as Vector2).length() > 0.01 and not _is_blocked(wanted):
                    enemy_pos = wanted
                    moved = true
                    break
            if not moved:
                seg_circle = -seg_circle
            seg_cd -= dt
            if seg_cd <= 0.0 and d < 430.0:
                var dir: Vector2 = (player_pos - enemy_pos).normalized()
                if dir == Vector2.ZERO:
                    dir = Vector2.LEFT
                var end: Vector2 = _thread_end(enemy_pos, dir)
                if end.distance_to(enemy_pos) < d + 10.0:
                    # Una columna te cubre: sigue rondando hasta tener línea limpia.
                    seg_cd = 0.25
                    return
                seg_state = "tensa"
                seg_t = SEG_TENSE
                seg_from = enemy_pos
                seg_to = end
                var reach: float = minf(seg_from.distance_to(player_pos) + SEG_OVERSHOOT, seg_from.distance_to(seg_to) - 26.0)
                seg_dash_to = seg_from + dir * maxf(0.0, reach)
                _sfx("hilo", -6.0)
                for ally in allies:
                    ally["react"] = randf_range(0.25, 1.15)
        "tensa":
            seg_t -= dt
            if seg_t <= 0.0:
                _segador_fire()
        "engancha":
            # Atraviesa la línea en un instante y queda clavado a sus hilos.
            enemy_pos = enemy_pos.move_toward(seg_dash_to, 1600.0 * dt)
            seg_t -= dt
            if seg_t <= 0.0:
                seg_state = "acecho"
                seg_cd = randf_range(1.3, 2.2)
                seg_circle = -1.0 if randf() < 0.5 else 1.0


func _segador_fire() -> void:
    seg_state = "engancha"
    seg_t = SEG_HOOK
    seg_flash = 0.18
    shake = maxf(shake, 0.3)
    _sfx("latigo", -3.0)
    if _on_thread(player_pos):
        if dash_left > 0.0:
            float_fx.append({"pos": player_pos + Vector2(0, -60), "text": "ESQUIVA", "color": SOUL, "t": 0.0})
        elif damage_cd <= 0.0:
            hp -= SEG_DAMAGE
            fear = minf(100.0, fear + 24.0)
            damage_cd = 1.2
            _say("El hilo te atraviesa. Sal de la línea antes de que dispare.", 3.0)
            _on_hurt()
    if allies_here:
        for ally in allies:
            if bool(ally["alive"]) and _on_thread(ally["pos"]):
                _ally_die(ally)


# --- Aliados ---------------------------------------------------------------
func _allies_reset() -> void:
    allies.clear()
    allies_here = false
    allies_rewarded = false
    seg_hp_floor = -1.0


func _allies_alive() -> int:
    var n: int = 0
    for ally in allies:
        if bool(ally["alive"]):
            n += 1
    return n


func _allies_enter_room() -> void:
    if _has("aliados") and allies.is_empty():
        for i in range(3):
            allies.append({"name": ALLY_NAMES[i], "pos": Vector2.ZERO, "prev": Vector2.ZERO, "facing": 0,
                "moving": false, "alive": true, "react": 0.0, "seed": 20 + i, "dead_key": "", "dead_pos": Vector2.ZERO,
                "line": "", "line_t": 0.0})
        if game_mode != "floor_intro":
            _say("Tres peregrinos te esperaban. «Nadie sobrevive a esta caza solo».", 4.0)
    # Te acompañan mientras sigas en el piso donde se unieron.
    allies_here = not allies.is_empty() and not in_tutorial and _floor_has_trait("aliados")
    if not allies_here:
        return
    for i in range(allies.size()):
        var ally: Dictionary = allies[i]
        var spot: Vector2 = player_pos + Vector2(-10.0 + float(i) * 6.0, -44.0 + float(i) * 44.0)
        if _is_blocked(spot):
            spot = player_pos + Vector2(24.0, float(i - 1) * 30.0)
        ally["pos"] = spot
        ally["prev"] = spot
    if _has("recuento") and not allies_rewarded:
        allies_rewarded = true
        var alive: int = _allies_alive()
        if alive > 0:
            souls += alive * ALLY_SOULS
            matches += 3
            souls_flash = 0.8
            _sfx("alma", -5.0)
            _say("Sobrevivieron %d de 3. Te dan +%d almas y 3 fósforos: «Sin ti no lo contábamos»." % [alive, alive * ALLY_SOULS], 5.0)
            _ally_say_random(["Seguiremos bajando. Quizá volvamos a vernos.", "Hasta el próximo piso. Si es que hay suelo."])
        else:
            _say("Nadie más llegó hasta aquí. El templo cobró su parte.", 4.5)
            fear = minf(100.0, fear + 15.0)


func _ally_say_random(lines: Array) -> void:
    var alive: Array = allies.filter(func(a): return bool(a["alive"]))
    if alive.is_empty() or not allies_here:
        return
    var who: Dictionary = alive[randi() % alive.size()]
    var line: String = lines[randi() % lines.size()]
    if not _in_combat():
        _dialog([[str(who["name"]), line]])
        return
    who["line"] = line
    who["line_t"] = _read_time(line)


func _ally_die(ally: Dictionary) -> void:
    ally["alive"] = false
    ally["dead_key"] = _room_key()
    ally["dead_pos"] = ally["pos"]
    fear = minf(100.0, fear + 12.0)
    shake = maxf(shake, 0.35)
    float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -60), "text": "%s HA MUERTO" % ally["name"], "color": RED, "t": 0.0})
    _sfx("dano", -6.0, 0.8)
    _ally_say_random(["¡%s! ¡No...!" % ally["name"], "Estaba justo detrás de ti...", "¡Apártate de la línea, maldita sea!"])


func _update_allies(dt: float) -> void:
    if not allies_here:
        return
    var tense: bool = _enemy_active() and _enemy_kind() == "segador" and seg_state == "tensa"
    var back: Vector2 = -player_dir.normalized() if player_dir.length() > 0.1 else Vector2.LEFT
    var side := Vector2(-back.y, back.x)
    var idx: int = 0
    for ally in allies:
        ally["line_t"] = maxf(0.0, float(ally["line_t"]) - dt)
        if not bool(ally["alive"]):
            continue
        var pos: Vector2 = ally["pos"]
        var target: Vector2 = pos
        var speed: float = 150.0
        if tense:
            ally["react"] = float(ally["react"]) - dt
            if float(ally["react"]) <= 0.0 and _on_thread(pos, 14.0):
                # Se aparta en perpendicular a la línea, hacia su lado.
                var line_dir: Vector2 = (seg_to - seg_from).normalized()
                var normal := Vector2(-line_dir.y, line_dir.x)
                var closest: Vector2 = Geometry2D.get_closest_point_to_segment(pos, seg_from, seg_to)
                if (pos - closest).dot(normal) < 0.0:
                    normal = -normal
                target = pos + normal * 60.0
                speed = 215.0
        else:
            # Te siguen en abanico, un poco por detrás.
            target = player_pos + back * 52.0 + side * float(idx - 1) * 38.0
            if _is_blocked(target):
                # Pegado a una pared: se reparten a tus lados.
                target = player_pos + side * (float(idx) - 1.0) * 46.0 + Vector2(0.0, 34.0 if idx == 1 else 0.0)
            if pos.distance_to(target) < 26.0:
                target = pos
            # No se amontonan unos sobre otros.
            for other in allies:
                if other != ally and bool(other["alive"]) and pos.distance_to(other["pos"]) < 24.0:
                    var away: Vector2 = pos - Vector2(other["pos"])
                    target += (away.normalized() if away.length() > 0.1 else Vector2(0, 1)) * 30.0
        idx += 1
        var step: Vector2 = pos.move_toward(target, speed * dt) - pos
        var nx := Vector2(pos.x + step.x, pos.y)
        if not _is_blocked(nx):
            pos.x = nx.x
        var ny := Vector2(pos.x, pos.y + step.y)
        if not _is_blocked(ny):
            pos.y = ny.y
        var moved: Vector2 = pos - Vector2(ally["prev"])
        ally["moving"] = moved.length() > 6.0 * dt
        var look: Vector2 = moved if bool(ally["moving"]) else (player_pos - pos)
        if look.length() > 0.5:
            if absf(look.x) > absf(look.y):
                ally["facing"] = 2 if look.x > 0.0 else 3
            else:
                ally["facing"] = 0 if look.y > 0.0 else 1
        ally["prev"] = pos
        ally["pos"] = pos


func _draw_ally(i: int) -> void:
    var ally: Dictionary = allies[i]
    var sheet: Texture2D = art["enemy_peregrino"]
    var frame: int = 2 + int(elapsed * 8.0 + float(i)) % 4 if bool(ally["moving"]) else int(elapsed * 2.0 + float(i)) % 2
    var region := Rect2(float(frame) * ENEMY_CELL.x, float(ally["facing"]) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
    var pos: Vector2 = ally["pos"]
    var feet := Vector2(roundf(pos.x), roundf(pos.y + 4.0))
    _draw_soft_shadow(pos + Vector2(0.0, 3.0), 12.0)
    _draw_ellipse(pos + Vector2(0.0, 3.0), 17.0, 6.0, Color(0.45, 0.85, 0.6, 0.16))
    draw_texture_rect_region(sheet, Rect2(feet.x - ENEMY_CELL.x * 0.5, feet.y - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y), region, ALLY_TINTS[i % ALLY_TINTS.size()])


func _draw_ally_labels() -> void:
    if not allies_here:
        return
    for ally in allies:
        if not bool(ally["alive"]):
            continue
        var pos: Vector2 = ally["pos"]
        _label_center(str(ally["name"]), pos + Vector2(0.0, -66.0), Color("#9fd8b0"))
        if float(ally["line_t"]) > 0.0:
            _label_center("«%s»" % ally["line"], pos + Vector2(0.0, -84.0), CREAM)


## Hilos: línea de aviso mientras tensa, destello al disparar y el hilo
## clavado mientras está enganchado. Se dibujan sobre la penumbra: el aviso
## siempre se ve (juego limpio).
func _draw_segador_threads() -> void:
    if not (_enemy_active() and _enemy_kind() == "segador"):
        return
    if seg_state == "tensa":
        var k: float = 1.0 - clampf(seg_t / SEG_TENSE, 0.0, 1.0)
        var flicker: float = 0.75 + 0.25 * sin(elapsed * (20.0 + 30.0 * k))
        var dir: Vector2 = (seg_to - seg_from).normalized()
        var n := Vector2(-dir.y, dir.x) * SEG_BAND
        draw_colored_polygon(PackedVector2Array([seg_from + n, seg_to + n, seg_to - n, seg_from - n]), Color(0.85, 0.1, 0.15, (0.06 + 0.12 * k) * flicker))
        draw_line(seg_from + Vector2(0, -26), seg_to, Color(1.0, 0.25, 0.3, (0.35 + 0.6 * k) * flicker), 1.0 + 2.0 * k)
        draw_line(seg_from, seg_to, Color(1.0, 0.3, 0.32, 0.25 + 0.4 * k), 1.0)
        draw_circle(seg_to, 3.0 + 3.0 * k, Color(1.0, 0.3, 0.32, 0.7))
    elif seg_state == "engancha":
        var hand := enemy_pos + Vector2(0, -26)
        var sway: float = sin(elapsed * 30.0) * 1.2
        draw_line(hand, seg_to + Vector2(0, sway), Color(0.9, 0.15, 0.2, 0.95), 2.0)
        draw_line(enemy_pos + Vector2(0, -20), seg_to + Vector2(0, -sway), Color(0.7, 0.1, 0.14, 0.8), 1.0)
        draw_circle(seg_to, 4.0, Color(0.55, 0.05, 0.1, 0.9)) # clavado en la piedra
        if seg_flash > 0.0:
            var a: float = seg_flash / 0.18
            draw_line(seg_from, seg_to, Color(1.0, 0.85, 0.85, a), 6.0 * a + 1.0)


func _floor_has_trait(trait_name: String) -> bool:
    for room in _floor()["rooms"]:
        if trait_name in room["traits"]:
            return true
    return false


func _hunt_mission_text() -> String:
    var alive: int = _allies_alive()
    if _has("caza") and _enemy_active():
        match seg_state:
            "tensa":
                return "¡HILOS TENSOS! SAL DE LA LÍNEA (Y APARTA A LOS TUYOS)"
            "engancha":
                return "¡ENGANCHADO! GOLPÉALO AHORA"
        return "CAZA: espera su disparo, luego golpea · aliados %d/3" % alive
    if allies.is_empty() or not allies_here:
        return ""
    if _has("aliados"):
        return "LA CACERÍA: aliados %d/3 · busca la puerta" % alive
    if _has("recuento"):
        return "SOBREVIVIERON %d DE 3" % alive
    return ""



# ------------------------------------------------------------ JUGABILIDAD (etapa 1)
const ABIL_BTN := Rect2(898, 62, 46, 36) # botón del HUD: pantalla de habilidades
const PROFILE_ABIL_BTN := Rect2(706, 380, 162, 48)
## Regeneración: tras REGEN_WAIT s sin recibir daño, la vida vuelve poco a poco.
const REGEN_WAIT := 4.0
const REGEN_RATE := 2.0 # vida por segundo
## Esquivar: impulso hacia donde te mueves o, quieto, hacia donde miras.
const DASH_TIME := 0.19
const DASH_COST := 28.0
## Trampas de pinchos (homenaje a los pinchos del primer juego del autor):
## ciclo con aviso visible y sonoro; esquivar te hace inmune a ellas.
const TRAP_SIZE := 30.0
const TRAP_CYCLE := 3.2
const TRAP_WARN := 1.7 # desde aquí asoman y suenan
const TRAP_UP := 2.3 # desde aquí hieren
const TRAP_DAMAGE := 18.0
var dash_dir: Vector2 = Vector2.RIGHT
var regen_wait: float = 0.0
var hp_prev: float = 100.0
var traps: Array = [] # {pos, phase, warned, bloody}
## Misiones de sala.
var missions_done: Dictionary = {} # "piso:sala" -> true
var mission_banner_t: float = 0.0
var mission_banner: String = ""
## Diálogos: cuadro inferior; el texto se escribe solo y avanza con clic/E.
var dialog_queue: Array = [] # [quién, texto]
var dialog_chars: float = 0.0
var dialog_return: String = "play"
var dialog_tick: float = 0.0
var talks_seen: Dictionary = {}


func _start_dash() -> void:
    if dash_cd > 0.0 or stamina < DASH_COST or game_mode != "play":
        return
    var move: Vector2 = _controls_axis()
    dash_dir = move.normalized() if move.length() > 0.1 else (player_dir.normalized() if player_dir.length() > 0.1 else Vector2.RIGHT)
    dash_left = DASH_TIME
    dash_cd = _dash_cooldown()
    stamina -= DASH_COST
    _sfx("toque", -14.0, 1.6)
    if in_tutorial:
        tut_dashed = true


func _update_regen(dt: float) -> void:
    if hp < hp_prev - 0.01:
        regen_wait = REGEN_WAIT # recibir daño reinicia la espera
    regen_wait = maxf(0.0, regen_wait - dt)
    if regen_wait <= 0.0 and fear < 100.0 and hp > 0.0 and hp < max_hp:
        hp = minf(max_hp, hp + REGEN_RATE * dt)
    hp_prev = hp


# --- Trampas -----------------------------------------------------------------
func _load_traps() -> void:
    traps.clear()
    var list: Array = _room().get("traps", [])
    for i in range(list.size()):
        traps.append({"pos": list[i], "phase": float(i % 2) * TRAP_CYCLE * 0.5, "warned": false, "bloody": false})


func _trap_t(trap: Dictionary) -> float:
    return fmod(room_elapsed + float(trap["phase"]), TRAP_CYCLE)


func _trap_rect(trap: Dictionary) -> Rect2:
    return Rect2(Vector2(trap["pos"]) - Vector2(TRAP_SIZE, TRAP_SIZE) * 0.5, Vector2(TRAP_SIZE, TRAP_SIZE))


func _update_traps(_dt: float) -> void:
    for trap in traps:
        var t: float = _trap_t(trap)
        var near: bool = player_pos.distance_to(trap["pos"]) < 260.0
        if t >= TRAP_WARN and not bool(trap["warned"]):
            trap["warned"] = true
            if near:
                _sfx("pinchos", -13.0 if t < TRAP_UP else -8.0, 1.0)
        elif t < TRAP_WARN:
            trap["warned"] = false
        if t >= TRAP_UP and _trap_rect(trap).grow(4.0).has_point(player_pos):
            if dash_left > 0.0:
                continue # esquivando se pasa por encima
            if damage_cd <= 0.0:
                hp -= TRAP_DAMAGE
                fear = minf(100.0, fear + 10.0)
                damage_cd = 1.0
                trap["bloody"] = true
                _say("Pinchos. Míralos asomar y pasa cuando bajen, o esquiva por encima.", 3.0)
                _on_hurt()


func _draw_traps() -> void:
    for trap in traps:
        var r: Rect2 = _trap_rect(trap)
        var t: float = _trap_t(trap)
        # Placa de hierro con agujeros.
        draw_rect(r.grow(2.0), Color(0.04, 0.04, 0.05, 0.55))
        draw_rect(r, Color("#2c2f33"))
        draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#4a4e54"))
        for gx in range(3):
            for gy in range(3):
                var hole := r.position + Vector2(6.0 + gx * 9.0, 6.0 + gy * 9.0)
                draw_rect(Rect2(hole, Vector2(4, 3)), Color("#0c0d0f"))
        var rise: float = 0.0
        if t >= TRAP_UP:
            rise = 1.0 if t < TRAP_CYCLE - 0.25 else (TRAP_CYCLE - t) / 0.25
        elif t >= TRAP_WARN:
            rise = 0.25 + 0.08 * sin(elapsed * 40.0) # asoman y tiemblan: aviso
        if rise <= 0.0:
            continue
        var steel := Color("#c3c9c4")
        for gx in range(3):
            for gy in range(3):
                var base := r.position + Vector2(8.0 + gx * 9.0, 9.0 + gy * 9.0)
                var tip := base + Vector2(0, -11.0 * rise)
                draw_colored_polygon(PackedVector2Array([base + Vector2(-3, 0), base + Vector2(3, 0), tip]), steel)
                draw_line(base + Vector2(0, -1), tip, Color("#f0f2ee"), 1.0)
                if bool(trap["bloody"]) and rise > 0.6 and (gx + gy) % 2 == 0:
                    draw_circle(tip + Vector2(0, 2), 1.5, Color("#9c1c25"))
        if t >= TRAP_WARN and t < TRAP_UP:
            draw_rect(r.grow(3.0), Color(1.0, 0.35, 0.3, 0.25 + 0.2 * sin(elapsed * 20.0)), false, 1.0)


# --- Inscripciones -------------------------------------------------------------
func _inscription() -> Array:
    return _room().get("inscription", [])


func _draw_inscription_plaque() -> void:
    var ins: Array = _inscription()
    if ins.is_empty():
        return
    var at: Vector2 = ins[0]
    var plaque := Rect2(at - Vector2(26, 10), Vector2(52, 20))
    draw_rect(plaque.grow(2.0), Color(0, 0, 0, 0.5))
    draw_rect(plaque, Color("#5a5446"))
    draw_rect(Rect2(plaque.position, Vector2(plaque.size.x, 2)), Color("#8a8370"))
    for i in range(5):
        draw_rect(Rect2(plaque.position + Vector2(6.0 + i * 9.0, 8.0 + float(i % 2) * 3.0), Vector2(6, 2)), Color("#2a261f"))
    if player_pos.distance_to(at) < 90.0:
        draw_rect(plaque.grow(3.0), Color(0.78, 0.67, 0.43, 0.35 + 0.2 * sin(elapsed * 4.0)), false, 1.0)


func _draw_inscription_text() -> void:
    var ins: Array = _inscription()
    if ins.is_empty():
        return
    var d: float = player_pos.distance_to(ins[0])
    if d > 150.0:
        return
    if d > 90.0:
        _label_center("INSCRIPCIÓN", Vector2(ins[0]) + Vector2(0, 26), Color("#c6aa6e"))
        return
    var box := Rect2(200, 112, 560, 64)
    _panel(box, Color(0.07, 0.065, 0.055, 0.94), UI_GOLD)
    _text_outline("INSCRIPCIÓN", Vector2(box.position.x + 16.0, box.position.y + 20.0), 11, UI_GOLD)
    draw_multiline_string(font, box.position + Vector2(16, 40), str(ins[1]), HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 32.0, 14, 2, CREAM)


# --- Misiones de sala --------------------------------------------------------------
func _mission() -> Dictionary:
    return _room().get("mission", {}) if not in_tutorial else {}


func _mission_pending(only_required: bool) -> bool:
    var m: Dictionary = _mission()
    if m.is_empty() or missions_done.has(_room_key()):
        return false
    return bool(m["required"]) or not only_required


func _complete_mission() -> void:
    var m: Dictionary = _mission()
    if m.is_empty() or missions_done.has(_room_key()):
        return
    missions_done[_room_key()] = true
    var reward: int = int(m.get("reward", 0))
    souls += reward
    souls_flash = 0.8
    mission_banner = "MISIÓN CUMPLIDA · %s · +%d almas" % [m["text"], reward]
    mission_banner_t = 3.2
    _sfx("sello", -6.0, 1.2)


func _draw_mission_banner() -> void:
    if mission_banner_t <= 0.0:
        return
    var a: float = clampf(mission_banner_t * 2.0, 0.0, 1.0) * clampf((3.2 - mission_banner_t) * 4.0, 0.0, 1.0)
    var box := Rect2(220, 186, 520, 44)
    _panel(box, Color(0.08, 0.07, 0.04, 0.92 * a), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, a))
    _text_outline(mission_banner, Vector2(box.position.x, box.position.y + 28.0), 15, Color(CREAM.r, CREAM.g, CREAM.b, a), box.size.x)


# --- Diálogos ----------------------------------------------------------------------
## Conversaciones al entrar en salas con más personajes. «{yo}» es tu nombre.
## Las líneas de quien ya no está (aliado muerto, sin Peregrino) se omiten.
const ROOM_TALKS := {
    "1:0": [
        ["PEREGRINO", "¿Tú también despertaste aquí? Tranquilo, no muerdo."],
        ["{yo}", "¿Quién eres? ¿Cuánto llevas en este sitio?"],
        ["PEREGRINO", "Lo bastante para saber que las puertas de este piso solo se abren con almas."],
        ["PEREGRINO", "Busquemos juntos. Hay para los dos."],
    ],
    "1:1": [
        ["PEREGRINO", "Escucha el agua. Siempre baja... como nosotros."],
        ["{yo}", "Quédate donde pueda verte."],
        ["PEREGRINO", "Claro, claro. A tu lado."],
    ],
    "2:0": [
        ["ODÓN", "Otro más. Bien. La voz ya habló: hay que cazar al rápido."],
        ["BRUNA", "Lo llaman el Segador. Tensa hilos rojos antes de atacar. Vi cómo partía a un hombre en dos."],
        ["CIRO", "Yo... yo solo quiero bajar. Iré detrás de ti, si no te importa."],
        ["{yo}", "Detrás de mí es justo donde no quieres estar."],
        ["ODÓN", "Entonces marca tú el paso. Nosotros te seguimos."],
    ],
    "2:1": [
        ["BRUNA", "Ahí está. ¿Lo oyes? Cuerdas que se tensan."],
        ["ODÓN", "Cuando dispara se queda clavado a sus hilos. Ese es el momento de golpear."],
        ["CIRO", "Y que la línea no nos pille a nosotros, por favor."],
    ],
    "2:2": [
        ["CIRO", "Está herido... Esta vez no tiene adónde huir."],
        ["BRUNA", "Las columnas cortan sus hilos. Úsalas."],
    ],
}


func _room_talk() -> void:
    var key: String = _room_key()
    if in_tutorial or talks_seen.has(key) or not ROOM_TALKS.has(key):
        return
    talks_seen[key] = true
    var lines: Array = []
    for line in ROOM_TALKS[key]:
        var who: String = line[0]
        if who == "PEREGRINO" and not _pilgrim_present():
            continue
        if who in ALLY_NAMES and not _ally_alive_named(who):
            continue
        lines.append([who, line[1]])
    _dialog(lines)


func _ally_alive_named(who: String) -> bool:
    for ally in allies:
        if str(ally["name"]) == who and bool(ally["alive"]) and allies_here:
            return true
    return false


func _in_combat() -> bool:
    if pilgrim_state == "hostile":
        return true
    return _enemy_active() and enemy_alert and player_pos.distance_to(enemy_pos) < 360.0


func _read_time(text: String) -> float:
    return clampf(1.8 + 0.065 * float(text.length()), 2.5, 7.0)


func _dialog(lines: Array) -> void:
    for line in lines:
        dialog_queue.append([str(line[0]).replace("{yo}", _hero_name()), str(line[1]).replace("{yo}", _hero_name())])
    if game_mode == "play" and not dialog_queue.is_empty():
        dialog_return = "play"
        game_mode = "dialog"
        dialog_chars = 0.0
        mobile_axis = Vector2.ZERO
        mobile_finger = -1


func _update_dialog(delta: float) -> void:
    if dialog_queue.is_empty():
        game_mode = dialog_return
        return
    var total: int = str(dialog_queue[0][1]).length()
    if dialog_chars < float(total):
        dialog_chars = minf(float(total), dialog_chars + 46.0 * delta)
        dialog_tick -= delta
        if dialog_tick <= 0.0:
            dialog_tick = 0.07
            _sfx("toque", -24.0, 1.7)


func _dialog_advance() -> void:
    if dialog_queue.is_empty():
        game_mode = dialog_return
        return
    var total: int = str(dialog_queue[0][1]).length()
    if dialog_chars < float(total):
        dialog_chars = float(total) # primer clic: muestra la frase entera
        return
    dialog_queue.pop_front()
    dialog_chars = 0.0
    if dialog_queue.is_empty():
        game_mode = dialog_return
        _sfx("interfaz", -14.0, 1.1)


func _dialog_skip() -> void:
    dialog_queue.clear()
    game_mode = dialog_return


func _speaker_color(who: String) -> Color:
    if who == "PEREGRINO":
        return Color("#d9b56e")
    if who in ALLY_NAMES:
        return Color("#9fd8b0")
    return SOUL


func _draw_dialog() -> void:
    if dialog_queue.is_empty():
        return
    var who: String = dialog_queue[0][0]
    var text: String = dialog_queue[0][1]
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.25))
    var box := Rect2(110, 432, 740, 128)
    _panel(box, Color(0.04, 0.045, 0.06, 0.95), UI_GOLD)
    draw_rect(box.grow(-6.0), Color(1, 1, 1, 0.04), false, 1.0)
    var tag := Rect2(box.position + Vector2(18, -16), Vector2(maxf(120.0, font.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 30.0), 28))
    _panel(tag, Color("#2a1d22"), _speaker_color(who))
    _text_outline(who, Vector2(tag.position.x, tag.position.y + 20.0), 15, _speaker_color(who), tag.size.x)
    var shown: String = text.substr(0, int(dialog_chars))
    draw_multiline_string(font, box.position + Vector2(24, 44), shown, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 48.0, 18, 3, CREAM)
    if int(dialog_chars) >= text.length():
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 5.0)
        var more: String = "»  clic / E" if dialog_queue.size() > 1 else "»  clic / E para cerrar"
        _text_outline(more, Vector2(box.end.x - 230.0, box.end.y - 12.0), 12, Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.5 + 0.5 * pulse), 210.0)
    _text_outline("ESC: saltar", Vector2(box.position.x + 24.0, box.end.y - 12.0), 10, Color("#6b6f80"))


# --- Pantalla de habilidades ---------------------------------------------------------
var abilities_return: String = "play"


func _open_abilities() -> void:
    if game_mode != "play":
        return
    game_mode = "abilities"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -9.0, 1.1)


func _close_abilities() -> void:
    game_mode = "play"
    _sfx("interfaz", -12.0, 0.9)


## [icono, nombre, tecla, descripción, la tienes, coste]
func _ability_rows() -> Array:
    return [
        ["golpe", "GOLPE DE ANTORCHA", Ajustes.nombre_tecla("interactuar") + " / CLIC",
            "Arco de fuego a corta distancia. Daño %d. Necesita la antorcha encendida." % int(STRIKE_DAMAGE), has_torch, "10 vigor"],
        ["resonancia", "RESONANCIA · NIVEL %d" % ability_level, Ajustes.nombre_tecla("resonancia"),
            "Onda que aturde a las entidades cercanas y les hace %d de daño." % int(30.0 + 10.0 * float(ability_level)), has_pulse, "24 vigor · 8 s"],
        ["vigor", "ESQUIVAR", Ajustes.nombre_tecla("esquivar"),
            "Impulso hacia donde te mueves o, quieto, hacia donde miras. Pasas por encima de las trampas.", true, "%d vigor · %.1f s" % [int(DASH_COST), _dash_cooldown()]],
        ["llama_interior", "LLAMA INTERIOR", "PASIVA",
            "Enciendes la antorcha sin gastar fósforos.", has_inner_flame, "altar"],
        ["corazon", "RESPIRO", "PASIVA",
            "Tras %d s sin recibir daño recuperas %d de vida por segundo (no con el miedo al máximo)." % [int(REGEN_WAIT), int(REGEN_RATE)], true, "siempre"],
    ]


func _draw_abilities() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.8))
    var sheet := Rect2(70, 46, 820, 548)
    _panel(sheet, Color(0.05, 0.05, 0.075, 0.97), UI_GOLD)
    _panel(Rect2(360, 34, 240, 30), Color("#241a30"), UI_GOLD)
    _text_outline("HABILIDADES", Vector2(360, 55), 18, CREAM, 240.0)
    _text_outline("ACTIVAS Y PROPIAS", Vector2(96, 92), 13, UI_GOLD)
    var rows: Array = _ability_rows()
    for i in range(rows.size()):
        var row: Array = rows[i]
        var r := Rect2(96, 102.0 + float(i) * 84.0, 420, 76)
        var owned: bool = row[4]
        _panel(r, Color("#141922") if owned else Color("#0e1015"), UI_EDGE if owned else Color("#24262c"))
        draw_texture_rect(ICONS[row[0]], Rect2(r.position + Vector2(10, 14), Vector2(48, 48)), false, Color.WHITE if owned else Color(0.12, 0.12, 0.14, 0.9))
        _text_outline(row[1] if owned else "???", Vector2(r.position.x + 70.0, r.position.y + 22.0), 14, CREAM if owned else Color("#5d5a52"))
        var keytag: String = str(row[2])
        var kw: float = font.get_string_size(keytag, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 14.0
        _panel(Rect2(r.end.x - kw - 10.0, r.position.y + 8.0, kw, 18), Color("#1d2230"), UI_GOLD if owned else UI_EDGE)
        _text_outline(keytag, Vector2(r.end.x - kw - 10.0, r.position.y + 22.0), 11, UI_GOLD if owned else Color("#5d5a52"), kw)
        var desc: String = row[3] if owned else "Aún no la tienes. Búscala en el templo o en el altar."
        draw_multiline_string(font, r.position + Vector2(70, 42), desc, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 84.0, 11, 2, Color("#b9b29b") if owned else Color("#5d5a52"))
        if owned:
            _text_outline(str(row[5]), Vector2(r.position.x + 70.0, r.end.y - 6.0), 10, SOUL)
    _text_outline("ECOS · PASIVAS DE CADA PISO", Vector2(540, 92), 13, UI_GOLD)
    var keys: Array = ECOS.keys()
    for i in range(keys.size()):
        var e := Rect2(540, 102.0 + float(i) * 70.0, 324, 62)
        var has_it: bool = ecos.has(keys[i])
        _panel(e, Color("#141922"), Color("#3b6f7d") if has_it else UI_EDGE)
        draw_texture_rect(ICONS["eco_" + str(keys[i])], Rect2(e.position + Vector2(10, 15), Vector2(32, 32)), false, Color.WHITE if has_it else Color(0.15, 0.15, 0.18, 0.9))
        _text_outline(ECOS[keys[i]][0] if has_it else "ECO SIN DESPERTAR", Vector2(e.position.x + 52.0, e.position.y + 22.0), 12, SOUL if has_it else Color("#5d5a52"))
        draw_multiline_string(font, e.position + Vector2(52, 40), ECOS[keys[i]][1] if has_it else "Supera el piso %s para despertarlo." % _eco_floor(str(keys[i])), HORIZONTAL_ALIGNMENT_LEFT, e.size.x - 60.0, 10, 2, Color("#9a957f"))
    _text_outline("Se acumulan sin límite: una por cada piso superado.", Vector2(540, 102.0 + float(keys.size()) * 70.0 + 14.0), 11, Color("#8a8574"))
    _text_outline("%s / ESC: cerrar" % Ajustes.nombre_tecla("habilidades"), Vector2(96, 574), 12, Color("#8a8574"), 768.0)


func _eco_floor(key: String) -> String:
    for f in FLOORS:
        if str(f.get("eco", "")) == key:
            return str(f["number"])
    return "?"
