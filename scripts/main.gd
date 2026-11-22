## [VISUAL UPGRADE]
extends Node2D
## Primer piso. Adaptación de los tres documentos GDD, Lore v0.2 y Reglas v0.1.
## Knowledge Temple + GothicVania reales incorporados desde los ZIP aportados.
## Mecánicas no canonizadas se indican como provisionales en docs/DECISIONES.md.

const W: float = 960.0
const H: float = 640.0
const ARENA: Rect2 = Rect2(40.0, 122.0, 880.0, 458.0)
const SAVE_PATH: String = "user://templo_personaje_v03.json"
## Las pruebas automáticas guardan aparte: nunca pisan tu partida real.
const SAVE_PATH_TEST: String = "user://prueba_progreso.json"
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
##   inscription (opcional): [posición, texto] que se lee al acercarse ({yo} = tu nombre).
##   walls (opcional): muros bajos (Rect2) que forman el laberinto; bloquean el paso.
##   hounds (opcional): dónde aparecen los Mastines de Relicario.
##   rescue / mask / channels (opcionales): peregrino atrapado, Máscara de
##           Porcelana y canales de almas del Piso V.
##   Piso con "fuel": la antorcha se consume en esos segundos por fósforo.
##   vines (opcional): tramos de enredadera seca que arden y propagan el fuego.
##           Rasgo "raices_puerta": raíces vivas tapan la puerta; solo arden
##           si les llega el fuego de las secas.
const Pisos := preload("res://scripts/datos/pisos.gd")
const FLOORS = Pisos.FLOORS

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
    "eco_piel": preload("res://assets/visual/iconos/eco_piel.png"),
    "eco_paso": preload("res://assets/visual/iconos/eco_paso.png"),
    "mascara": preload("res://assets/visual/iconos/mascara.png"),
    "eco_huesos": preload("res://assets/visual/iconos/eco_huesos.png"),
    "eco_serena": preload("res://assets/visual/iconos/eco_serena.png"),
    "eco_memoria": preload("res://assets/visual/iconos/eco_memoria.png"),
    "eco_fuerza": preload("res://assets/visual/iconos/eco_fuerza.png"),
    "pan": preload("res://assets/visual/iconos/pan.png"),
    "brazalete": preload("res://assets/visual/iconos/brazalete.png"),
    "amuleto": preload("res://assets/visual/iconos/amuleto.png"),
    "vial": preload("res://assets/visual/iconos/vial.png"),
    "incienso": preload("res://assets/visual/iconos/incienso.png"),
    "bolsa_almas": preload("res://assets/visual/iconos/bolsa_almas.png"),
    "reliquia": preload("res://assets/visual/iconos/reliquia.png"),
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
## Paleta de la dirección de arte (etapa 2): negros profundos, carbón, dorado
## envejecido, violeta oscuro y carmesí.
const UI_PANEL := Color(0.035, 0.03, 0.045, 0.84)
const UI_EDGE := Color("#2f2a35")
const UI_LIGHT := Color("#5b5262")
const UI_GOLD := Color("#b8955a")
const UI_VIOLET := Color("#3b2550")
const UI_CRIMSON := Color("#8e1f2c")
const BAR_HP := Color("#b3263a")
const BAR_VIGOR := Color("#5c9474")
const BAR_FEAR := Color("#6b3fa0")
const TITLE_FONT := preload("res://assets/fonts/Jacquard24-Regular.ttf")
const FOG_TEX := preload("res://assets/visual/fx/niebla.png")
## Ecos: [nombre, descripción]. Se ganan al superar cada piso (clave "eco" del piso).
const ECOS := {
    "respiracion": ["RESPIRACIÓN CONTENIDA", "El miedo sube un 25 % más despacio."],
    "nuca": ["NUCA FRÍA", "Sientes cuando alguien con malas intenciones queda a tu espalda."],
    "reflejos": ["REFLEJOS", "Esquivar cuesta un 40 % menos de vigor."],
    "piel": ["PIEL CURTIDA", "Recibes un 25 % menos de daño."],
    "paso": ["PASO LIGERO", "Te mueves un 5 % más rápido."],
    "huesos": ["HUESOS FIRMES", "Una vez por piso, un golpe mortal te deja con 1 de vida."],
    "serena": ["MENTE SERENA", "El miedo al máximo ya no te hace daño."],
    "memoria": ["MEMORIA DE ECO", "Ves tu silueta donde moriste en otras vidas."],
    "fuerza": ["FUERZA ACUMULADA", "Tu golpe hace un 4 % más de daño por cada Eco que tienes."],
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
const ENEMY_MAX_HP := {"ghoul": 60.0, "testigo": 90.0, "hechicero": 70.0, "segador": 140.0, "tejedora": 110.0}
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
    "enemy_tejedora": preload("res://assets/visual/enemies/tejedora.png"),

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
    "fuego": "res://audio/sfx_fuego.ogg", "raices": "res://audio/sfx_raices.ogg",
    "grunido": "res://audio/sfx_grunido.ogg",
}
## Sonidos de Kenney (CC0) traídos del primer juego del autor: cada grupo
## tiene varias tomas y se elige una al azar con un tono algo distinto.
const SFX_GROUPS := {
    "k_paso": ["footstep_concrete_000", "footstep_concrete_001", "footstep_concrete_002", "footstep_concrete_003", "footstep_concrete_004"],
    "k_campana": ["impactBell_heavy_000", "impactBell_heavy_001", "impactBell_heavy_002", "impactBell_heavy_003", "impactBell_heavy_004"],
    "k_metal": ["impactMetal_heavy_000", "impactMetal_heavy_001", "impactMetal_heavy_002", "impactMetal_light_000", "impactMetal_light_001", "impactMetal_light_002"],
    "k_vidrio": ["impactGlass_light_000", "impactGlass_light_001", "impactGlass_light_002", "impactGlass_light_003", "impactGlass_light_004"],
    "k_vidrio_fuerte": ["impactGlass_heavy_000", "impactGlass_heavy_001", "impactGlass_heavy_002"],
    "k_golpe": ["impactPunch_medium_000", "impactPunch_medium_001", "impactPunch_medium_002", "impactPunch_medium_003", "impactPunch_medium_004"],
    "k_cuerpo": ["impactSoft_heavy_000", "impactSoft_heavy_001", "impactSoft_heavy_002"],
    "k_piedra": ["impactMining_000", "impactMining_001", "impactMining_002"],
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
    # Rótulos: Jacquard 24 (OFL), gótica de píxel; también sin suavizado.
    title_font = TITLE_FONT
    if title_font is FontFile:
        var tf := title_font as FontFile
        tf.antialiasing = TextServer.FONT_ANTIALIASING_NONE
        tf.hinting = TextServer.HINTING_NONE
        tf.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
    randomize()
    Ajustes.cargar()
    _apply_touch_setting()
    # Al abrir el juego se ve la pantalla de inicio; al volver de la Vigilia, el menú.
    game_mode = "title" if Engine.has_meta("splash_visto") else "splash"
    _load_progress()
    _load_art()
    _load_room_scene() # sala 1 como fondo del menú
    _setup_post()
    _setup_transition()
    _setup_cursor()
    _apply_window_mode()
    Input.joy_connection_changed.connect(_on_joy_connection)
    pad_active = not Input.get_connected_joypads().is_empty()
    _init_motes()
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
        for group in SFX_GROUPS:
            var takes: Array = []
            for file in SFX_GROUPS[group]:
                takes.append(load("res://audio/kenney/%s.ogg" % file))
            sfx_streams[group] = takes
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
    var entry = sfx_streams[key]
    if entry is Array:
        chosen.stream = entry[randi() % entry.size()]
        chosen.pitch_scale = pitch * randf_range(0.9, 1.1)
    else:
        chosen.stream = entry
        chosen.pitch_scale = pitch * randf_range(0.96, 1.04)
    chosen.volume_db = volume_db
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
    if not FileAccess.file_exists(_save_path()):
        return
    var data = JSON.parse_string(FileAccess.get_file_as_string(_save_path()))
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
        max_floor = maxi(0, int(data.get("max_floor", 0)))
        has_mask = bool(data.get("has_mask", false))
        var saved_rescued = data.get("rescued", [])
        rescued = (saved_rescued as Array).map(func(e): return str(e)) if saved_rescued is Array else []
        player_level = clampi(int(data.get("player_level", 1)), 1, LEVEL_MAX)
        var saved_marks = data.get("death_marks", {})
        death_marks = saved_marks if saved_marks is Dictionary else {}
        xp = maxi(0, int(data.get("xp", 0)))
        var saved_guided = data.get("guided", [])
        guided = (saved_guided as Array).map(func(e): return str(e)) if saved_guided is Array else []
        var saved_bag = data.get("bag", {})
        bag = saved_bag if saved_bag is Dictionary else {}
        var saved_levels = data.get("trinket_levels", {})
        trinket_levels = saved_levels if saved_levels is Dictionary else {}
        karma = int(data.get("karma", 0))
        var saved_chests = data.get("chests_opened", {})
        chests_opened = saved_chests if saved_chests is Dictionary else {}
        var saved_trinkets = data.get("trinkets", [])
        trinkets = (saved_trinkets as Array).filter(func(e): return str(e) in ["brazalete", "amuleto"]) if saved_trinkets is Array else []

func _save_progress() -> void:
    var file := FileAccess.open(_save_path(), FileAccess.WRITE)
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
            "player_gender": player_gender,
            "max_floor": max_floor,
            "has_mask": has_mask,
            "rescued": rescued,
            "guided": guided,
            "player_level": player_level,
            "death_marks": death_marks,
            "xp": xp,
            "trinkets": trinkets,
            "trinket_levels": trinket_levels,
            "bag": bag,
            "karma": karma,
            "chests_opened": chests_opened
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
    life_corpse = {}
    rescue_state = ""
    hand_lost = false
    guiding = false
    fountains_used.clear()
    floor_t0 = Time.get_ticks_msec()
    floor_souls0 = 0
    floor_deaths = 0
    floor_critters = 0
    dialog_queue.clear()
    souls = 0
    max_hp = _base_max_hp()
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
        _say("No recuerdas nada de este lugar.", 4.0)


func _enter_room() -> void:
    fade_t = FADE_TIME # fundido cinematográfico al cruzar
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
    enemy_max = maxf(1.0, float(ENEMY_MAX_HP.get(_enemy_kind(), 1.0)) * _depth_mult()) # más fuertes cuanto más abajo
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
    _load_critters()
    _load_vines()
    _load_labyrinth()
    _load_merchant()
    _load_gaze()
    _load_colossus_room()
    _load_harvest_room()
    _chest_obstacle()
    if _fountain_here():
        obstacles.append(Rect2(FOUNTAIN_POS.x - 12.0, FOUNTAIN_POS.y - 10.0, 24.0, 10.0))
    door_state = "unknown"
    if game_mode == "floor_intro":
        toast_left = 0.0 # el susurro se oye al pulsar ENTRAR
    elif _has("tutorial") and not has_torch:
        _say("Oscuridad. Busca madera y fósforos para hacer una antorcha.", 4.5)
    else:
        _say(_room()["whisper"], 4.5)
    if game_mode == "play":
        _room_talk()
        _offering_after_talk()
        _memory_whisper()


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
                "flip": sprite.flip_h != bool(_floor().get("mirror", false)), # Piso VIII: todo mira al otro lado
            })
    relics = [_marker("Reliquia1", RELICS[0]), _marker("Reliquia2", RELICS[1]), _marker("Reliquia3", RELICS[2])]
    seal_pos = _marker("Sello", SEAL_POS)
    altar_pos = _marker("Altar", ALTAR_POS)
    book_pos = _marker("Libro", BOOK_POS)
    archive_pos = _marker("Lectura", ARCHIVE_POS)
    eye_pos = _marker("Ojo", EYE_POS)
    door_pos = _marker("Salida", DOOR_POS)
    if _room().has("seal"):
        seal_pos = _room()["seal"] # Piso VIII: el sello cambió de sala


func _marker(marker_name: String, fallback: Vector2) -> Vector2:
    if room_node == null:
        return fallback
    var marker := room_node.get_node_or_null("Marcadores/" + marker_name) as Node2D
    return fallback if marker == null else marker.global_position - global_position


func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton:
        if event.pressed:
            _pad_button(event.button_index)
        return
    elif event is InputEventJoypadMotion:
        _pad_motion(event.axis, event.axis_value)
        return
    if event is InputEventKey or event is InputEventMouseButton:
        pad_active = false
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
        if game_mode == "shop":
            for i in range(SHOP.size()):
                if _shop_row(i).has_point(ui_hover):
                    shop_sel = i
        if game_mode == "pause":
            for i in range(_pause_options().size()):
                if _pause_rect(i).has_point(ui_hover):
                    pause_sel = i
        queue_redraw()
        return
    elif event is InputEventMouseButton and event.pressed and game_mode == "abilities" and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
        _abil_turn(1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1)
        queue_redraw()
        return
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var click_at: Vector2 = make_input_local(event).position
        _click_spark(click_at)
        if game_mode in ["title", "create", "floors", "floor_summary", "shop", "inventory", "abilities", "map", "dialog", "altar", "floor_intro", "splash", "eula", "intro", "pause", "settings"]:
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
    if game_mode == "map":
        _map_key(k)
        queue_redraw()
        return
    if game_mode == "abilities":
        if k in [_key("habilidades"), KEY_ESCAPE, KEY_E, KEY_K]:
            _close_abilities()
        elif k in [KEY_RIGHT, KEY_D, KEY_DOWN, KEY_S, KEY_PAGEDOWN, KEY_TAB]:
            _abil_turn(1)
        elif k in [KEY_LEFT, KEY_A, KEY_UP, KEY_W, KEY_PAGEUP]:
            _abil_turn(-1)
        queue_redraw()
        return
    if game_mode == "floors":
        _floors_key(k)
        queue_redraw()
        return
    if game_mode == "shop":
        _shop_key(k)
        queue_redraw()
        return
    if game_mode == "floor_summary":
        if k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E, KEY_ESCAPE]:
            _after_floor_summary()
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
            _open_floors() # los pisos son la entrada al juego
        elif k == KEY_C:
            _start_creation("title")
        elif k == KEY_P:
            _open_floors()
        elif k == KEY_H:
            _open_defense()
        elif k == KEY_ESCAPE:
            _ask_quit()
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
            _open_abilities()
        elif k == KEY_O:
            _profile_switch_tab()
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
            _profile_use_selected()
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
        elif k == KEY_M:
            _open_map()
        elif k == _key("pausa") or k == KEY_ESCAPE:
            _open_pause()
    queue_redraw()


# ------------------------------------------------------------ MANDO
## Mando de Xbox 360 / Xbox One / PlayStation / Switch (Godot usa la base de
## SDL, así que los botones se nombran por posición: A abajo, B derecha, X
## izquierda, Y arriba). Cada botón se traduce a la tecla que ya entiende el
## menú o la acción; así todo el juego funciona igual con teclado o mando.
const PAD_DEADZONE := 0.24
const PAD_MENU_ON := 0.6
const PAD_MENU_OFF := 0.35
const PAD_REPEAT_FIRST := 0.38
const PAD_REPEAT := 0.14
var pad_active: bool = false
var pad_trigger: Dictionary = {}
var pad_menu_dir: Vector2i = Vector2i.ZERO
var pad_repeat_left: float = 0.0
var pad_stick: Vector2 = Vector2.ZERO
var pad_name_sel: int = 0


func _pad_key(k: Key) -> void:
    var ev := InputEventKey.new()
    ev.keycode = k
    ev.physical_keycode = k
    ev.pressed = true
    _input(ev)
    pad_active = true


func _pad_dir_key(dir: Vector2i) -> Key:
    if dir.y < 0:
        return KEY_UP
    if dir.y > 0:
        return KEY_DOWN
    return KEY_LEFT if dir.x < 0 else KEY_RIGHT


func _pad_button(b: int) -> void:
    pad_active = true
    var dpad := {JOY_BUTTON_DPAD_UP: Vector2i(0, -1), JOY_BUTTON_DPAD_DOWN: Vector2i(0, 1),
        JOY_BUTTON_DPAD_LEFT: Vector2i(-1, 0), JOY_BUTTON_DPAD_RIGHT: Vector2i(1, 0)}
    if game_mode == "settings" and rebinding != "":
        # Las teclas se reasignan con teclado; el mando tiene su esquema fijo.
        rebinding = ""
        _say(_t("mando_reasignar"), 2.4)
        queue_redraw()
        return
    if game_mode == "create" and create_step == 0:
        _pad_create_name(b, dpad)
        return
    if game_mode == "play":
        match b:
            JOY_BUTTON_A:
                _pad_key(_key("interactuar"))
            JOY_BUTTON_B:
                _pad_key(_key("esquivar"))
            JOY_BUTTON_X:
                _pad_key(_key("antorcha"))
            JOY_BUTTON_Y:
                _pad_key(_key("resonancia"))
            JOY_BUTTON_LEFT_SHOULDER:
                _pad_key(_key("perfil"))
            JOY_BUTTON_BACK:
                _open_map()
            JOY_BUTTON_RIGHT_SHOULDER:
                _pad_key(_key("habilidades"))
            JOY_BUTTON_START:
                _pad_key(KEY_ESCAPE)
        return
    if dpad.has(b) and game_mode == "abilities":
        _abil_turn(1 if (dpad[b] as Vector2i).x + (dpad[b] as Vector2i).y > 0 else -1)
        queue_redraw()
        return
    if dpad.has(b):
        _pad_menu_step(dpad[b])
        return
    match game_mode:
        "dialog":
            if b in [JOY_BUTTON_A, JOY_BUTTON_B]:
                _pad_key(KEY_ENTER)
            elif b in [JOY_BUTTON_Y, JOY_BUTTON_START]:
                _pad_key(KEY_ESCAPE)
            return
        "title":
            match b:
                JOY_BUTTON_A, JOY_BUTTON_START:
                    _pad_key(KEY_ENTER)
                JOY_BUTTON_X:
                    _pad_key(KEY_C)
                JOY_BUTTON_Y:
                    _pad_key(KEY_P)
                JOY_BUTTON_RIGHT_SHOULDER:
                    _pad_key(KEY_H)
                JOY_BUTTON_BACK:
                    _open_settings("title")
                    queue_redraw()
                JOY_BUTTON_B:
                    _pad_key(KEY_ESCAPE)
            return
        "altar":
            match b:
                JOY_BUTTON_A:
                    _buy_upgrade(inventory_sel + 1)
                    queue_redraw()
                JOY_BUTTON_X:
                    _pad_key(KEY_1)
                JOY_BUTTON_Y:
                    _pad_key(KEY_2)
                JOY_BUTTON_B, JOY_BUTTON_START:
                    _pad_key(KEY_ESCAPE)
            return
        "inventory":
            match b:
                JOY_BUTTON_RIGHT_SHOULDER:
                    _pad_key(_key("habilidades"))
                JOY_BUTTON_A:
                    _pad_key(KEY_ENTER)
                JOY_BUTTON_Y:
                    _pad_key(KEY_O)
                JOY_BUTTON_B, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_BACK, JOY_BUTTON_START:
                    _pad_key(KEY_ESCAPE)
            return
        "map":
            if b in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_BACK, JOY_BUTTON_START]:
                _close_map()
            elif b in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER]:
                _map_key(KEY_TAB)
            queue_redraw()
            return
        "abilities":
            if b in [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_START]:
                _pad_key(KEY_ESCAPE)
            elif b == JOY_BUTTON_LEFT_SHOULDER:
                _abil_turn(1)
            return
        "settings":
            if b in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER] and legal_page == "":
                settings_tab = (settings_tab + (1 if b == JOY_BUTTON_RIGHT_SHOULDER else 3)) % 4
                settings_sel = 0
                _sfx("toque", -14.0, 1.0)
                queue_redraw()
                return
    match b:
        JOY_BUTTON_A, JOY_BUTTON_START:
            _pad_key(KEY_ENTER)
        JOY_BUTTON_B, JOY_BUTTON_BACK:
            _pad_key(KEY_ESCAPE)


func _pad_menu_step(dir: Vector2i) -> void:
    if game_mode == "create" and create_step == 0:
        _pad_name_move(dir)
    elif game_mode == "altar":
        inventory_sel = clampi(inventory_sel + dir.y + dir.x, 0, 1)
        queue_redraw()
    else:
        _pad_key(_pad_dir_key(dir))


## Teclado en pantalla para el nombre: la cruceta mueve un recuadro sobre las
## teclas (se reutiliza el resaltado de «cursor encima»).
func _pad_create_name(b: int, dpad: Dictionary) -> void:
    var keys: Array = _create_name_keys()
    pad_name_sel = clampi(pad_name_sel, 0, keys.size() - 1)
    if dpad.has(b):
        _pad_name_move(dpad[b])
        return
    match b:
        JOY_BUTTON_A:
            _create_tap((keys[pad_name_sel][0] as Rect2).get_center())
        JOY_BUTTON_X:
            _create_tap(_pad_name_key_rect("borrar").get_center())
        JOY_BUTTON_Y:
            _create_tap(_pad_name_key_rect("azar").get_center())
        JOY_BUTTON_START:
            _create_next()
        JOY_BUTTON_B, JOY_BUTTON_BACK:
            if create_buf != "" and b == JOY_BUTTON_B:
                _create_tap(_pad_name_key_rect("borrar").get_center())
            else:
                _create_back()
    _pad_name_hover()
    queue_redraw()


func _pad_name_key_rect(action: String) -> Rect2:
    for key in _create_name_keys():
        if str(key[1]) == action:
            return key[0]
    return Rect2()


## Mueve la selección a la tecla más cercana en esa dirección.
func _pad_name_move(dir: Vector2i) -> void:
    var keys: Array = _create_name_keys()
    pad_name_sel = clampi(pad_name_sel, 0, keys.size() - 1)
    var from: Vector2 = (keys[pad_name_sel][0] as Rect2).get_center()
    var best: int = -1
    var best_score: float = INF
    for i in range(keys.size()):
        var d: Vector2 = (keys[i][0] as Rect2).get_center() - from
        var along: float = d.x * dir.x + d.y * dir.y
        if i == pad_name_sel or along < 8.0:
            continue
        var across: float = absf(d.x * dir.y) + absf(d.y * dir.x)
        var score: float = along + across * 2.0
        if score < best_score:
            best_score = score
            best = i
    if best >= 0:
        pad_name_sel = best
        _sfx("toque", -18.0, 1.3)
    _pad_name_hover()
    queue_redraw()


func _pad_name_hover() -> void:
    if game_mode == "create" and create_step == 0:
        ui_hover = (_create_name_keys()[clampi(pad_name_sel, 0, _create_name_keys().size() - 1)][0] as Rect2).get_center()


func _pad_motion(axis: int, value: float) -> void:
    if axis == JOY_AXIS_TRIGGER_LEFT or axis == JOY_AXIS_TRIGGER_RIGHT:
        var was: bool = bool(pad_trigger.get(axis, false))
        var now: bool = value > (0.3 if was else 0.55)
        pad_trigger[axis] = now
        if now and not was:
            pad_active = true
            if game_mode == "play":
                if axis == JOY_AXIS_TRIGGER_RIGHT:
                    if not _torch_strike():
                        _say(_t("mando_golpe"), 1.8)
                else:
                    _start_dash()
                queue_redraw()
        return
    if axis == JOY_AXIS_LEFT_X:
        pad_stick.x = value
    elif axis == JOY_AXIS_LEFT_Y:
        pad_stick.y = value
    else:
        return
    if pad_stick.length() > PAD_DEADZONE:
        pad_active = true
    if game_mode == "play":
        pad_menu_dir = Vector2i.ZERO
        return
    # En los menús el stick funciona como la cruceta, con repetición al mantener.
    var dir := Vector2i.ZERO
    var limit: float = PAD_MENU_OFF if pad_menu_dir != Vector2i.ZERO else PAD_MENU_ON
    if maxf(absf(pad_stick.x), absf(pad_stick.y)) > limit:
        dir = Vector2i(signi(roundi(pad_stick.x)) if absf(pad_stick.x) > absf(pad_stick.y) else 0,
            signi(roundi(pad_stick.y)) if absf(pad_stick.y) >= absf(pad_stick.x) else 0)
    if dir != pad_menu_dir:
        pad_menu_dir = dir
        if dir != Vector2i.ZERO:
            pad_repeat_left = PAD_REPEAT_FIRST
            _pad_menu_step(dir)


func _update_pad_repeat(delta: float) -> void:
    if pad_menu_dir == Vector2i.ZERO or game_mode == "play":
        return
    pad_repeat_left -= delta
    if pad_repeat_left <= 0.0:
        pad_repeat_left = PAD_REPEAT
        _pad_menu_step(pad_menu_dir)


## Stick izquierdo y cruceta de todos los mandos conectados, con zona muerta.
func _pad_axis() -> Vector2:
    var total := Vector2.ZERO
    for device in Input.get_connected_joypads():
        var v := Vector2(Input.get_joy_axis(device, JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
        if v.length() < PAD_DEADZONE:
            v = Vector2.ZERO
        else:
            v = v.normalized() * inverse_lerp(PAD_DEADZONE, 1.0, minf(v.length(), 1.0))
        if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP):
            v.y -= 1.0
        if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN):
            v.y += 1.0
        if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT):
            v.x -= 1.0
        if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT):
            v.x += 1.0
        total += v
    return total


func _on_joy_connection(device: int, connected: bool) -> void:
    if connected:
        pad_active = true
        _say(_t("mando_conectado") % Input.get_joy_name(device), 2.6)
    else:
        _say(_t("mando_desconectado"), 2.6)
        if game_mode == "play":
            _open_pause() # como en consola: si se desconecta, el juego se detiene
    queue_redraw()


func _open_defense() -> void:
    get_tree().change_scene_to_file("res://scenes/defense.tscn")

func _mobile_touch(finger: int, at: Vector2, pressed: bool) -> void:
    if not pressed:
        if finger == mobile_finger:
            mobile_finger = -1
            mobile_axis = Vector2.ZERO
            joy_center = JOY_HOME
        queue_redraw()
        return
    if game_mode == "play" and at.x <= JOY_ZONE_X and at.y >= JOY_ZONE_Y:
        mobile_finger = finger
        # Joystick flotante: si el dedo cae lejos de la base, la base va al dedo.
        if at.distance_to(joy_center) > JOY_RADIUS + 10.0:
            joy_center = Vector2(clampf(at.x, 90.0, JOY_ZONE_X - 40.0), clampf(at.y, JOY_ZONE_Y + 50.0, 560.0))
        _mobile_update_axis(at)
    else:
        _mobile_tap(at)
    queue_redraw()

func _mobile_update_axis(at: Vector2) -> void:
    mobile_axis = ((at - joy_center) / 68.0).limit_length(1.0)
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
                        _ask_quit()
        return
    if game_mode == "intro":
        if INTRO_SKIP_BTN.has_point(at):
            _end_intro()
        else:
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
    if game_mode == "floors":
        _floors_tap(at)
        return
    if game_mode == "floor_summary":
        _after_floor_summary()
        return
    if game_mode == "shop":
        _shop_tap(at)
        return
    if game_mode == "title":
        if CHANGE_CHAR_RECT.has_point(at):
            _start_creation("title")
        elif GEAR_RECT.has_point(at):
            _open_settings("title")
        elif FLOORS_BTN.has_point(at):
            _open_floors()
        elif VIGIL_BTN.has_point(at):
            _open_defense()
        elif QUIT_BTN.has_point(at):
            _ask_quit()
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
        if SKIP_BTN.has_point(at):
            _dialog_skip()
        else:
            _dialog_advance()
        return
    if game_mode == "map":
        _map_tap(at)
        return
    if game_mode == "abilities":
        if _abil_pages() > 1 and ABIL_PREV_BTN.grow(8.0).has_point(at):
            _abil_turn(-1)
        elif _abil_pages() > 1 and ABIL_NEXT_BTN.grow(8.0).has_point(at):
            _abil_turn(1)
        else:
            _close_abilities()
        return
    if game_mode == "inventory":
        if PROFILE_ABIL_BTN.has_point(at):
            _open_abilities()
            return
        for t in range(2):
            if _profile_tab_rect(t).has_point(at):
                if profile_tab != t:
                    _profile_switch_tab()
                return
        var slot: int = _inventory_slot_at(at)
        if slot >= 0:
            if slot == inventory_sel and profile_tab == 1:
                _profile_use_selected() # segundo toque: usar
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
    if MINIMAP_RECT.has_point(at):
        _open_map() # tocar el minimapa: mapa grande
        return
    if at.y < 104.0 and at.x < 330.0:
        # Tocar el retrato abre el perfil.
        _open_inventory()
        return
    match _touch_button_at(at):
        "accion":
            _interact()
        "antorcha":
            _toggle_torch()
        "esquivar":
            _start_dash()
        "resonancia":
            _use_pulse()
    queue_redraw()

func _draw_mobile_controls() -> void:
    if not touch_enabled:
        return
    if game_mode != "play":
        return
    # Joystick flotante a la izquierda y botones agrupados a la derecha, al
    # alcance del pulgar (controles de Kenney, CC0, teñidos con la paleta).
    var idle: bool = mobile_finger < 0
    draw_texture_rect(JOY_BASE_TEX, Rect2(joy_center - Vector2(76, 76), Vector2(152, 152)), false, Color(0.75, 0.68, 0.8, 0.35 if idle else 0.7))
    draw_texture_rect(BUTTON_TEX, Rect2(joy_center + mobile_axis * 48.0 - Vector2(30, 30), Vector2(60, 60)), false, Color(0.62, 0.81, 0.83, 0.5 if idle else 0.85))
    var ctx: Array = _touch_context()
    for id in TOUCH_BUTTONS:
        var at: Vector2 = TOUCH_BUTTONS[id][0]
        var r: float = TOUCH_BUTTONS[id][1]
        if id == "resonancia" and not has_pulse:
            continue
        var wait: float = 0.0
        var icon: String = ""
        var label: String = ""
        match id:
            "accion":
                label = ctx[0]
                icon = ctx[1]
                if ctx[2]:
                    wait = _vigor_wait(10.0)
            "antorcha":
                label = "APAGAR" if torch_on else "LUZ"
                icon = "antorcha_encendida" if torch_on else "antorcha"
            "esquivar":
                label = "ESQUIVA"
                icon = "vigor"
                wait = _dash_wait()
            "resonancia":
                label = "RUGIDO" if has_mask else "ONDA"
                icon = "resonancia"
                wait = _vigor_wait(RESONANCE_COST)
        var ready_b: bool = wait <= 0.0 and (id != "antorcha" or has_torch)
        var tint := Color(0.85, 0.75, 0.6, 0.72) if ready_b else Color(0.45, 0.42, 0.48, 0.55)
        if id == "accion" and ctx[3]:
            tint = Color(1.0, 0.85, 0.5, 0.85 + 0.15 * sin(elapsed * 5.0)) # hay algo con qué interactuar
        draw_texture_rect(BUTTON_TEX, Rect2(at - Vector2(r, r), Vector2(r * 2.0, r * 2.0)), false, tint)
        if not ready_b and wait > 0.0:
            draw_arc(at, r - 6.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - wait), 32, SOUL, 3.0)
        var isz: float = r * 0.8
        if icon != "" and ICONS.has(icon):
            draw_texture_rect(ICONS[icon], Rect2(at - Vector2(isz * 0.5, isz * 0.62), Vector2(isz, isz)), false, Color(1, 1, 1, 0.95 if ready_b else 0.5))
        _text_outline(label, Vector2(at.x - r, at.y + r * 0.62), 13 if id == "accion" else 11, CREAM, r * 2.0)
        if id == "antorcha" and has_torch and not has_inner_flame:
            var tag := Rect2(at + Vector2(r * 0.35, -r - 4.0), Vector2(30, 18))
            _panel(tag, Color("#2a1d22"), UI_GOLD)
            _text_outline("×%d" % matches, Vector2(tag.position.x, tag.position.y + 14.0), 11, CREAM, tag.size.x)


func _buy_upgrade(choice: int) -> void:
    if choice == 2:
        _buy_inner_flame()
        return
    if choice != 1:
        return
    if has_pulse:
        # Ya la tienes: el altar la mejora de nivel con almas.
        if ability_level >= ABILITY_LEVEL_MAX:
            _say("Tu Resonancia ya está al nivel máximo (%d)." % ability_level)
            return
        var up_price: int = RESONANCE_UPGRADE_BASE + RESONANCE_UPGRADE_STEP * ability_level
        if souls < up_price:
            _say("Mejorar la Resonancia cuesta %d almas." % up_price)
            return
        souls -= up_price
        ability_level += 1
        _save_progress()
        _sfx("sello", -6.0, 1.35)
        _say("Resonancia mejorada a nivel %d: más daño." % ability_level, 3.0)
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
    if pulse_cd > 0.0 or stamina < RESONANCE_COST:
        _say("Resonancia necesita vigor: espera a que la barra se llene.", 2.0)
        return
    pulse_cd = ABILITY_LOCK # se recarga con la barra de vigor, no con un reloj aparte
    stamina -= RESONANCE_COST
    pulse_fx = 0.0
    _sfx("resonancia", -5.0)
    if has_mask:
        _sfx("grunido", -4.0, 1.4) # Rugido: la máscara amplifica la onda
    for h in hounds:
        if player_pos.distance_to(h["pos"]) < _pulse_radius() + 12.0:
            h["flee"] = 5.0 if has_mask else 3.0
            float_fx.append({"pos": Vector2(h["pos"]) + Vector2(0, -50), "text": "HUYE", "color": SOUL, "t": 0.0})
    if _pilgrim_present() and _pilgrim_can_be_hit() and player_pos.distance_to(pilgrim_pos) < PULSE_RADIUS + 12.0:
        pilgrim_stun = 1.4
        _damage_pilgrim(_pulse_damage())
    for cr in critters:
        if bool(cr["alive"]) and player_pos.distance_to(cr["pos"]) < _pulse_radius() + 12.0:
            _critter_die(cr)
    _harvest_pulse()
    if _enemy_active() and player_pos.distance_to(enemy_pos) < 220.0:
        enemy_stun = 1.6 + 0.5 * float(ability_level)
        if player_pos.distance_to(enemy_pos) < PULSE_RADIUS + 12.0:
            _damage_enemy(_pulse_damage())
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
    torch_fuel = float(_floor().get("fuel", 0.0))
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
    elif kind == "pan":
        _heal(40.0)
        stamina = 100.0
        label = "+40 VIDA"
        _say("Un mendrugo olvidado. Duro, pero es comida.", 3.0)
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
    _offering_after_talk()
    _memory_whisper()
    if not dialog_queue.is_empty() and game_mode == "play":
        _dialog([]) # frases que llegaron durante la pantalla del piso


func _open_inventory() -> void:
    if not game_mode in ["play", "pause", "abilities"]:
        return
    if game_mode != "abilities":
        overlay_return = game_mode # desde la pausa, ESC vuelve a la pausa
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
    game_mode = overlay_return
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
    return Rect2(372.0 + float(i) * 49.0, 382.0, 44.0, 44.0) # caben los diez Ecos


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
            _say("El golpe rebota. Ahora mismo es piedra.", 2.6)
        elif _enemy_kind() == "segador":
            _say("Demasiado rápido: el golpe no lo alcanza.", 2.6)
        else:
            _say("Algo invisible desvía el golpe.", 2.6)
        return false
    if _enemy_kind() == "tejedora" and not fire_hit:
        # La corteza apenas se marca: el fuego es lo que la mata.
        amount = maxf(2.0, roundf(amount * 0.18))
        if teje_hint_t <= 0.0:
            teje_hint_t = 6.0
            _say("La corteza apenas se marca.", 3.2)
    enemy_hp -= amount
    enemy_hit_t = 0.2
    _sfx("k_golpe", -11.0)
    _emit(enemy_pos + Vector2(0, -30), 14, Color(1.0, 0.72, 0.35), 60.0, 190.0, 0.5, 2.0, 260.0, (enemy_pos - player_pos).normalized(), 1.2, true)
    _emit(enemy_pos + Vector2(0, -28), 6, Color(0.55, 0.08, 0.12), 30.0, 110.0, 0.7, 3.0, 300.0, Vector2.UP, 1.4)
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
    _emit(enemy_pos + Vector2(0, -30), 36, Color(0.62, 0.5, 0.95), 20.0, 90.0, 1.4, 2.0, -50.0, Vector2.UP, 1.4, true)
    if _mission().get("goal", "") == "desterrar":
        _complete_mission()
    if kind == "segador":
        seg_state = "acecho"
        seg_hp_floor = 0.0
    dissolve_fx.append({"pos": enemy_pos, "kind": kind, "facing": enemy_facing, "frame": _enemy_frame(kind), "t": 0.0})
    drops.append({"pos": enemy_pos})
    _gain_xp(XP_BANISH)
    fireballs.clear()
    enemy_stun = 0.0
    enemy_alert = false
    shake = maxf(shake, 0.25)
    _sfx("destierro", -4.0)
    _sfx("k_vidrio_fuerte", -12.0, 0.8)
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
            float_fx.append({"pos": DUMMY_POS + Vector2(26, -60), "text": "-%d" % int(_strike_damage()), "color": Color("#ffd36b"), "t": 0.0})
            _sfx("impacto", -8.0, 1.2)
    if _pilgrim_present() and _pilgrim_can_be_hit():
        var to_p := pilgrim_pos - player_pos
        if to_p.length() < STRIKE_RANGE + 10.0 and (to_p.length() < 24.0 or to_p.normalized().dot(strike_dir) > 0.25):
            _damage_pilgrim(_strike_damage())
            var shove := pilgrim_pos + to_p.normalized() * 16.0
            if not _is_blocked(shove):
                pilgrim_pos = shove
    _try_ignite(player_pos + strike_dir * 28.0)
    _strike_hounds_and_rescue()
    _strike_rams_and_pillars()
    _harvest_strike()
    for cr in critters:
        if bool(cr["alive"]):
            var to_c: Vector2 = Vector2(cr["pos"]) - player_pos
            if to_c.length() < STRIKE_RANGE + 12.0 and (to_c.length() < 24.0 or to_c.normalized().dot(strike_dir) > 0.2):
                _critter_die(cr)
    if _enemy_active():
        var to := enemy_pos - player_pos
        if to.length() < STRIKE_RANGE + 10.0 and (to.length() < 24.0 or to.normalized().dot(strike_dir) > 0.25):
            if _damage_enemy(_strike_damage()):
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
        _say("SELLO RECUPERADO. El ojo grabado en la cera mira hacia otro lado." if _floor().get("inverted", false) else "SELLO RECUPERADO. En la cera, un ojo abierto y una figura inmóvil.", 5.0)
        _sfx("sello", -4.0)
        return
    if _open_chest():
        return
    if _calm_ally():
        return
    if _use_fountain():
        return
    if _light_brazier():
        return
    if _offering_interact():
        return
    if _has("altar") and player_pos.distance_to(altar_pos) < 64.0:
        game_mode = "altar"
        inventory_sel = 0
        _sfx("interfaz", -8.0)
        return
    if _has("archivo") and player_pos.distance_to(archive_pos) < 72.0:
        letter_found = true
        _say(str(_room().get("letter", "Carta: 'He regresado. El cuerpo cambia, pero recuerdo sus ojos.'")), 5.0)
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
    _karma_on_leave()
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
    if _door_roots_left() > 0:
        return false
    return _pilgrim_allows_exit()


func _pilgrim_allows_exit() -> bool:
    return not pilgrim_state in ["tell", "hostile"]

func _required_clue() -> String:
    if _has("sello") and not seal_acquired:
        return "El pórtico exige el sello de la estatua. Está al fondo."
    if _has("almas") and collected.has(false):
        return "La puerta no se abre para manos vacías: faltan almas."
    if pilgrim_state in ["tell", "hostile"]:
        return "No puedes darle la espalda a quien te quiere muerto."
    if _has("caza") and _enemy_active():
        return "La Cacería no ha terminado: la presa sigue viva."
    if _mission_pending(true):
        return "MISIÓN: %s. La puerta no se abre hasta cumplirla." % _mission()["text"]
    if _door_roots_left() > 0:
        return "Raíces vivas tapan la puerta."
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
    _gain_xp(XP_FLOOR)
    _save_progress()
    # Resumen del piso (idea de la pantalla «nivel completado» del primer juego).
    _open_floor_summary(eco)


func _after_floor_summary() -> void:
    if current_floor + 1 >= FLOORS.size():
        _win_run()
        return
    current_floor += 1
    current_room = 0
    max_floor = maxi(max_floor, current_floor)
    _save_progress()
    _on_floor_start()
    game_mode = "floor_intro" # antes de entrar: nada habla hasta pulsar ENTRAR
    _enter_room()
    _sfx("puerta", -4.0, 0.7)
    _sfx("k_campana", -9.0, 0.8)
    _transition("espiral", false, 1.0)


## Preparación propia de cada piso (p. ej., el Peregrino del Piso II).
func _on_floor_start() -> void:
    _pilgrim_reset()
    _allies_reset()
    bones_used = false
    inverted_seen = false
    guiding = false
    guides_rewarded = false
    rescue_state = "atrapado" if _floor_has_trait_key("rescue") else ""
    floor_t0 = Time.get_ticks_msec()
    floor_souls0 = souls
    floor_deaths = 0
    floor_critters = 0


func _win_run() -> void:
    cleared += 1
    _save_progress()
    game_mode = "victory"
    _sfx("sello", -4.0, 0.8)

func _lose_run() -> void:
    deaths += 1
    # El alma se desprende: motas que suben y un estallido carmesí.
    _emit(player_pos + Vector2(0, -24), 50, Color(0.62, 0.86, 0.98), 10.0, 70.0, 2.0, 2.0, -45.0, Vector2.UP, 0.8, true)
    _emit(player_pos + Vector2(0, -20), 24, Color(0.6, 0.05, 0.1), 50.0, 160.0, 0.9, 3.0, 300.0, Vector2.UP, 1.6)
    death_fx = 0.0
    _sfx("k_campana", -7.0, 0.55) # tañido fúnebre
    floor_deaths += 1
    # Tu cuerpo se queda en la sala: el «cadáver de la vida anterior».
    _mark_death()
    life_corpse = {"key": _room_key(), "pos": player_pos, "life": deaths,
        "souls": 0 if MUERTE_SIN_PERDIDA else souls / 2, "claimed": false}
    _transition("nubes", false, 0.9)
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
        player_level = 1 # otra persona: empieza de cero
        xp = 0
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
    return (v + mobile_axis + _pad_axis()).limit_length(1.0)


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
    _update_pad_repeat(delta)
    _update_level_fx(delta)
    for i in shop_flash.keys():
        shop_flash[i] = maxf(0.0, float(shop_flash[i]) - delta * 1.8)
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
    # Temblor suave (ondas superpuestas, como el ruido de la cámara del primer juego).
    position = Vector2(sin(elapsed * 47.0) + 0.6 * sin(elapsed * 83.0), cos(elapsed * 41.0) + 0.6 * sin(elapsed * 67.0)) * 0.6 * shake * shake * 14.0 if shake > 0.0 else Vector2.ZERO
    _update_fx(delta)
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
    stamina = minf(100.0, stamina + _stamina_regen() * dt)
    var move: Vector2 = _controls_axis()
    if dash_left > 0.0:
        move = dash_dir # el impulso sigue su dirección aunque sueltes las teclas
    player_moving = move.length_squared() > 0.001
    if player_moving:
        player_dir = move
    var speed: float = (157.0 * (1.05 if ecos.has("paso") else 1.0)) if dash_left <= 0.0 else 480.0
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
            _sfx("k_paso", -19.0, 0.85) # pasos sobre piedra
            _emit(player_pos + Vector2(0, 2), 3, Color(0.55, 0.5, 0.45, 0.5), 8.0, 26.0, 0.5, 2.0, -10.0, Vector2.UP, 1.2)
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
    if fear >= 100.0 and not ecos.has("serena"):
        hp -= dt * 5.0
    _update_traps(dt)
    _update_fire(dt)
    _update_hounds(dt)
    _update_labyrinth(dt)
    _update_critters(dt)
    _update_life_corpse()
    _update_door_celebration()
    _update_regen(dt)
    _update_offering(dt)
    _update_gaze(dt)
    _update_rams(dt)
    _update_colossus(dt)
    _update_harvest(dt)
    if hp <= 0.0 and ecos.has("huesos") and not bones_used:
        _bones_hold()
    if hp <= 0.0:
        _lose_run()

func _collect_relic(i: int) -> void:
    collected[i] = true
    souls += 7
    fear = maxf(0.0, fear - 8.0)
    souls_flash = 0.8
    pickup_fx.append({"pos": relics[i], "t": 0.0})
    _gain_xp(XP_RELIC)
    _sfx("k_vidrio", -15.0, 1.35)
    _emit(relics[i] + Vector2(0, -16), 18, Color(0.56, 0.86, 0.95), 15.0, 60.0, 1.1, 2.0, -40.0, Vector2.UP, 1.0, true)
    _say("Fragmento reunido: +7 almas.", 2.5)
    _sfx("alma", -5.0)


## Golpe recibido: sacudida, destello y sonido. No cambia el daño.
func _on_hurt() -> void:
    shake = 0.45
    _sfx("dano", -4.0)
    _sfx("k_cuerpo", -9.0)
    _emit(player_pos + Vector2(0, -26), 16, Color(0.62, 0.06, 0.1), 40.0, 150.0, 0.8, 3.0, 320.0, Vector2.UP, 1.5)


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
        # En el Piso VIII la regla se invierte: persigue al que se queda quieto.
        var inverted: bool = bool(_floor().get("inverted", false))
        enemy_alert = watcher_open and (player_moving != inverted) and d < 490.0
        if enemy_alert and enemy_stun <= 0.0:
            var wanted := enemy_pos.move_toward(player_pos, 169.0 * dt)
            if not _is_blocked(wanted):
                enemy_pos = wanted
            if inverted:
                if not inverted_seen:
                    inverted_seen = true
                    _say("¡Viene cuando te detienes!", 3.5)
            elif not observed_rule:
                observed_rule = true
                remembered_rule = true
                _save_progress()
                _say("Te detuviste... y el Testigo también.", 4.0)
    elif _enemy_kind() == "segador":
        _update_segador(dt)
    elif _enemy_kind() == "tejedora":
        _update_tejedora(dt)
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
                    hp -= 25.0 * _depth_mult()
                    fear = minf(100.0, fear + 13.0)
                    damage_cd = 1.1
                    _say("El conjuro te alcanza.", 2.6)
                    _on_hurt()
                fireballs.remove_at(i)
            elif float(ball["life"]) <= 0.0 or _is_blocked(p):
                fireballs.remove_at(i)
            else:
                fireballs[i] = ball
    if (_enemy_kind() == "ghoul" or _enemy_kind() == "testigo") and enemy_alert and enemy_stun <= 0.0:
        if enemy_pos.distance_to(player_pos) < 31.0 and damage_cd <= 0.0:
            hp -= (33.0 if _enemy_kind() == "ghoul" else 42.0) * _depth_mult()
            fear = minf(100.0, fear + 21.0)
            damage_cd = 1.5
            var away := (player_pos - enemy_pos).normalized()
            if away == Vector2.ZERO:
                away = Vector2.LEFT
            var escape := player_pos + away * 65.0
            if not _is_blocked(escape):
                player_pos = escape
            _say("La criatura te ha herido.", 3.0)
            _on_hurt()


func _draw() -> void:
    # El fondo lo pone la escena de la sala (está por debajo).
    if room_node == null:
        draw_rect(Rect2(0, 0, W, H), BG)
    elif game_mode in ["title", "create", "floors", "splash", "eula"] or (game_mode == "settings" and settings_return in ["title", "splash"]):
        # En el menú se ve la sala completa, con sus objetos, detrás del panel.
        var objetos: Node = room_node.get_node_or_null("Objetos")
        if objetos != null:
            (objetos as CanvasItem).visible = true
    _draw_background()
    var screen: String = settings_return if game_mode == "settings" else game_mode
    if screen == "intro":
        _draw_intro()
        return
    if screen in ["title", "create", "floors", "splash", "eula"]:
        if screen == "title":
            _draw_title()
        elif screen == "floors":
            _draw_floors()
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
    _draw_level_banner()
    _draw_room_souls_counter()
    _draw_room_fade()
    if game_mode == "altar":
        _draw_altar_overlay()
    elif game_mode == "shop":
        _draw_shop()
    elif game_mode == "inventory":
        _draw_inventory_overlay()
    elif game_mode == "abilities":
        _draw_abilities()
    elif game_mode == "map":
        _draw_map()
    elif game_mode == "floor_summary":
        _draw_floor_summary()
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
    _draw_vines()
    _draw_channels_ground()
    _draw_mask_item()
    if _has("sello"):
        _draw_seal(seal_pos)
    if _enemy_kind() == "testigo" and _enemy_active():
        _draw_watcher_eye(eye_pos)
    for i in range(relics.size()):
        _draw_corpse(relics[i], (current_floor * 5 + current_room) * 3 + i)
    for ally in allies:
        if not bool(ally["alive"]) and str(ally["dead_key"]) == _room_key():
            _draw_corpse(ally["dead_pos"], int(ally["seed"]))
    _draw_life_corpse()
    _draw_death_marks()
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
    _draw_flames()
    _draw_tejedora_fire()
    _draw_labyrinth_glow()
    _draw_merchant_glow()
    _draw_mark_aura()
    _draw_ram_warnings()
    _draw_elder_threads()
    _draw_critter_eyes()
    _draw_light_rays()
    _draw_fog()
    _draw_fx()
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
    var lit: int = 0
    for cell in vines:
        if str(vines[cell]["state"]) == "fuego":
            lit += 1
            if lit % 3 == 1: # una luz por cada tres celdas: barato y suficiente
                list.append([_cell_center(cell) + Vector2(0, -8), 90.0, 0.9])
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
    for i in range(critters.size()):
        items.append([Vector2(critters[i]["pos"]).y - (8.0 if not bool(critters[i]["alive"]) else 0.0), "critter", i])
    for i in range(hounds.size()):
        items.append([Vector2(hounds[i]["pos"]).y, "hound", i])
    for i in range(maze_walls.size()):
        items.append([(maze_walls[i] as Rect2).end.y, "wall", i])
    if _room().has("rescue") and rescue_state != "":
        items.append([Vector2(_room()["rescue"]).y, "rescue", null])
    if _room().has("merchant"):
        items.append([Vector2(_room()["merchant"]).y, "merchant", null])
    if gaze_active:
        items.append([gaze_pos.y, "vigia", null])
    for i in range(rams.size()):
        items.append([Vector2(rams[i]["pos"]).y, "ram", i])
    for i in range(pillars.size()):
        items.append([Vector2(pillars[i]["pos"]).y + 6.0, "pillar", i])
    if colossus_active:
        items.append([colossus_pos.y, "colossus", null])
    for i in range(braziers.size()):
        items.append([Vector2(braziers[i]["pos"]).y, "brazier", i])
    if _chest_here():
        items.append([_chest_pos().y, "chest", null])
    if elder_active or elder_npc:
        items.append([elder_pos.y, "elder", null])
    for i in range(elder_traitors.size()):
        items.append([Vector2(elder_traitors[i]["pos"]).y, "traitor", i])
    if _fountain_here():
        items.append([FOUNTAIN_POS.y, "fountain", null])
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
            "critter":
                _draw_critter(item[2])
            "hound":
                _draw_hound(item[2])
            "wall":
                _draw_maze_wall(item[2])
            "rescue":
                _draw_rescue()
            "merchant":
                _draw_merchant()
            "vigia":
                _draw_vigia()
            "ram":
                _draw_ram(item[2])
            "pillar":
                _draw_pillar(item[2])
            "colossus":
                _draw_colossus()
            "brazier":
                _draw_brazier(item[2])
            "chest":
                _draw_chest()
            "elder":
                _draw_elder()
            "traitor":
                _draw_traitor(item[2])
            "fountain":
                _draw_fountain()
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
        _label_center(_prompt("INTERCAMBIO"), altar_pos + Vector2(0.0, 46.0), CREAM)
    if _has("archivo") and not letter_found and player_pos.distance_to(archive_pos) < 150.0:
        _label_center(_prompt("LEER CARTA"), archive_pos + Vector2(0.0, 30.0), CREAM)
    if _has("sello") and not seal_acquired:
        _label_center(_prompt("SELLO"), seal_pos + Vector2(0.0, 56.0), Color("#e2c48a"))
    if _enemy_active():
        _draw_enemy_health()
    _draw_ally_labels()
    _draw_inscription_text()
    _draw_rescue_label()
    _draw_offering_labels()
    _draw_gaze_hud()
    _draw_colossus_hud()
    _draw_harvest_hud()
    _draw_chest_label()
    _draw_fountain_label()
    if _pilgrim_present():
        _draw_pilgrim_overlay()


func _label_center(msg: String, at: Vector2, color: Color) -> void:
    var size: int = 14 if touch_enabled else 12
    var width: float = font.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
    var box := Rect2(at.x - width * 0.5 - 6.0, at.y - 12.0, width + 12.0, 17.0)
    draw_rect(box, Color(0.03, 0.05, 0.06, 0.72))
    draw_string(font, Vector2(box.position.x + 6.0, at.y), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


## [VISUAL UPGRADE] Puntos luminosos ligeros: no modifican colisiones ni reglas.
func _draw_visual_atmosphere() -> void:
    # Polvo y ceniza suspendidos (más brasas carmesí cuanto más gastado el piso).
    var wear: float = float(_floor().get("wear", 0.0))
    for m in motes:
        var p: Vector2 = m["p"]
        var tw: float = 0.5 + 0.5 * sin(elapsed * float(m["f"]) + float(m["ph"]))
        var ember: bool = float(m["ph"]) < wear * 0.9
        var col: Color = Color(0.95, 0.35, 0.22, 0.10 + 0.22 * tw) if ember else Color(0.86, 0.8, 0.66, 0.06 + 0.12 * tw)
        draw_rect(Rect2(p.round(), Vector2(float(m["s"]), float(m["s"]))), col)



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
        "tejedora":
            if teje_state == "alza":
                return 6
            if teje_state == "zarpa":
                return 7
            return 2 + int(elapsed * 6.0) % 4 if enemy_moving else int(elapsed * 1.5) % 2
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
    elif _enemy_kind() == "tejedora":
        state = "ARDIENDO" if teje_burn > 0.0 else "CORTEZA · TEME AL FUEGO"
        tone = Color("#ff9a3c") if teje_burn > 0.0 else Color("#b49a72")
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
    var r: float = _pulse_radius() * (1.0 - pow(1.0 - k, 3.0))
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
    # Nivel: placa en la esquina del retrato y barra de experiencia.
    if _mark() != "":
        var mk := Rect2(54, 6, 34, 18)
        var bless: bool = _mark() == "bendicion"
        _panel(mk, Color("#4a3a12") if bless else Color("#4a121a"), Color("#ffd36b") if bless else UI_CRIMSON)
        _text_outline("BEN" if bless else "MAL", Vector2(mk.position.x, mk.position.y + 14.0), 11, CREAM, mk.size.x)
    var badge := Rect2(10, 6, 34, 18)
    _panel(badge, Color("#3b2550"), UI_GOLD)
    _text_outline("NV%d" % player_level, Vector2(badge.position.x, badge.position.y + 14.0), 11, CREAM, badge.size.x)
    var xpbar := Rect2(122, 94, 196, 4)
    draw_rect(xpbar, Color(0, 0, 0, 0.7))
    draw_rect(Rect2(xpbar.position, Vector2(xpbar.size.x * _xp_fraction(), xpbar.size.y)), Color("#c9a25e").lerp(Color.WHITE, 0.4 * level_flash))
    var bars := [
        ["corazon", minf(hp, max_hp), max_hp, BAR_HP, ("%d/%d" % [int(ceil(hp)), int(max_hp)]) if hp <= max_hp else ("%d/%d +%d" % [int(max_hp), int(max_hp), int(ceil(hp - max_hp))])],
        ["vigor", stamina, 100.0, BAR_VIGOR, "%d/100" % int(stamina)],
        ["miedo", fear, 100.0, BAR_FEAR, "MIEDO %d%%" % int(fear)],
    ]
    for i in range(bars.size()):
        var y: float = 15.0 + float(i) * 27.0
        var b: Array = bars[i]
        draw_texture_rect(ICONS[b[0]], Rect2(96, y - 1.0, 22, 22), false)
        _px_bar(Rect2(122, y, 196, 20), float(b[1]) / float(b[2]), b[3], b[4])
    if hp > max_hp:
        # Vida extra por encima del máximo: franja dorada sobre la barra.
        var k_over: float = clampf((hp - max_hp) / OVERHEAL_MAX, 0.0, 1.0)
        draw_rect(Rect2(124, 15, 192.0 * k_over, 4), Color("#ffd36b"))
        draw_rect(Rect2(122, 15, 196, 20), Color(1.0, 0.85, 0.4, 0.35 + 0.2 * sin(elapsed * 4.0)), false, 2.0)
    if fear > 70.0:
        # Al borde del pánico la barra de miedo late.
        var k: float = 0.5 + 0.5 * sin(elapsed * 9.0)
        draw_rect(Rect2(121, 68, 198, 22), Color(0.7, 0.3, 1.0, 0.35 * k), false, 2.0)


## Cartel del piso y la sala, con el contador de almas.
func _draw_floor_banner() -> void:
    var banner := Rect2(336, 6, 288, 58)
    _panel(banner)
    var floor_label: String = _floor()["title"] if in_tutorial else "PISO %s · %s" % [_floor()["number"], _floor()["title"]]
    var banner_title: String = _tc(floor_label)
    var state_line: String = _floor()["state"]
    if title_font != null and title_font.get_string_size(banner_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x > banner.size.x - 12.0:
        # Título largo: el número en gótica y el nombre del piso abajo, en pequeño.
        banner_title = _tc(floor_label.get_slice(" · ", 0))
        state_line = floor_label.get_slice(" · ", 1)
    _title_text(banner_title, Vector2(banner.position.x, 27), 24, UI_GOLD, banner.size.x)
    _text_outline(_room()["name"], Vector2(banner.position.x, 44), 14, CREAM, banner.size.x)
    _text_outline(state_line, Vector2(banner.position.x, 58), 10, Color("#8a8574"), banner.size.x)
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
    var map_hot: bool = MINIMAP_RECT.has_point(ui_hover)
    _text_outline("MAPA DEL PISO", Vector2(644, 24), 11, UI_GOLD if map_hot else Color("#8a8574"))
    _text_outline("M · ampliar" if not DisplayServer.is_touchscreen_available() else "toca: ampliar", Vector2(760, 24), 9, Color("#6d6772"), 128.0)
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
    ## Panel de la etapa 2: fondo oscuro translúcido, filete fino del color del
    ## borde y esquinas ornamentadas en los paneles grandes.
    var r := rect
    draw_rect(Rect2(r.position + Vector2(0, 3), r.size), Color(0, 0, 0, 0.35 * fill.a)) # sombra
    draw_rect(r, fill)
    _vgradient(Rect2(r.position, Vector2(r.size.x, minf(r.size.y * 0.5, 22.0))), Color(1, 1, 1, 0.035 * fill.a), Color(1, 1, 1, 0.0))
    draw_rect(r, Color(0, 0, 0, 0.7 * fill.a), false, 1.0)
    var inner := r.grow(-2.0)
    draw_rect(inner, Color(edge.r, edge.g, edge.b, edge.a * 0.9), false, 1.0)
    if r.size.x >= 70.0 and r.size.y >= 40.0:
        var orn: Color = edge.lightened(0.25)
        orn.a = edge.a
        for corner in [inner.position, Vector2(inner.end.x, inner.position.y), inner.end, Vector2(inner.position.x, inner.end.y)]:
            var sx: float = 1.0 if corner.x < r.get_center().x else -1.0
            var sy: float = 1.0 if corner.y < r.get_center().y else -1.0
            draw_rect(Rect2(corner + Vector2(minf(0.0, sx * 7.0), minf(0.0, sy * 1.0)), Vector2(7, 1)), orn)
            draw_rect(Rect2(corner + Vector2(minf(0.0, sx * 1.0), minf(0.0, sy * 7.0)), Vector2(1, 7)), orn)
            var d: Vector2 = corner + Vector2(sx * 4.0, sy * 4.0)
            draw_colored_polygon(PackedVector2Array([d + Vector2(0, -2), d + Vector2(2, 0), d + Vector2(0, 2), d + Vector2(-2, 0)]), orn)



func _px_bar(rect: Rect2, fraction: float, color: Color, label: String) -> void:
    ## Barra estilizada: canal hundido, relleno en degradado con brillo
    ## superior, un destello en el extremo y marcas cada 25 %.
    draw_rect(rect, Color(0.015, 0.012, 0.02, 0.9))
    var inner := rect.grow(-2.0)
    draw_rect(inner, color.darkened(0.82))
    var w: float = roundf(inner.size.x * clampf(fraction, 0.0, 1.0))
    if w > 0.0:
        _vgradient(Rect2(inner.position, Vector2(w, inner.size.y)), color.lightened(0.22), color.darkened(0.4))
        draw_rect(Rect2(inner.position, Vector2(w, 1.0)), Color(1, 1, 1, 0.35))
        draw_rect(Rect2(inner.position.x + w - 2.0, inner.position.y, 2.0, inner.size.y), color.lightened(0.55))
    for k in range(1, 4):
        var x: float = roundf(inner.position.x + inner.size.x * float(k) / 4.0)
        draw_rect(Rect2(x, inner.position.y, 1.0, inner.size.y), Color(0, 0, 0, 0.35))
    draw_rect(rect, Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.35), false, 1.0)
    if label != "":
        _text_outline(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.5 + 5.0), 13, Color.WHITE, rect.size.x)



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
    if _has("sello") and _enemy_active() and _enemy_kind() == "testigo" and watcher_open and not seal_acquired:
        task_color = RED
    if pilgrim_state in ["tell", "hostile"]:
        task_color = RED
    var mission := Rect2(8, 580, 568, 34)
    _panel(mission)
    draw_colored_polygon(PackedVector2Array([Vector2(22, 597), Vector2(28, 591), Vector2(34, 597), Vector2(28, 603)]), UI_GOLD)
    _text_outline(task, Vector2(42, 603), 15, task_color)
    if not touch_enabled:
        var n := func(a: String) -> String: return _key_label(a)
        var hint: String = _t("mando_hud") if pad_active else "%s%s%s%s mover · %s/CLIC golpear · %s antorcha · %s esquivar · %s resonancia · %s perfil · %s habilidades · %s pausa" % [
            n.call("arriba"), n.call("izquierda"), n.call("abajo"), n.call("derecha"), n.call("interactuar"), n.call("antorcha"),
            n.call("esquivar"), n.call("resonancia"), n.call("perfil"), n.call("habilidades"), n.call("pausa")]
        _text_outline(hint, Vector2(12, 632), 10, Color("#8d8877"))
    _draw_weapon_panel()


## Arma equipada (la antorcha) con su «munición» y las habilidades.
func _draw_weapon_panel() -> void:
    if touch_enabled and game_mode == "play":
        return # en móvil esa información está en los botones
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
    _draw_torch_fuel()
    _draw_ability_icon(Rect2(780, 583, 48, 48), "vigor", true, _dash_wait(), _short_key("esquivar"))
    _draw_ability_icon(Rect2(838, 583, 48, 48), "golpe", has_torch and torch_on, maxf(strike_cd / 0.6, _vigor_wait(10.0)), _short_key("interactuar"))
    _draw_ability_icon(Rect2(896, 583, 48, 48), "resonancia", has_pulse, _vigor_wait(RESONANCE_COST), _short_key("resonancia"))


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
        if _enemy_active() and _enemy_kind() == "testigo":
            return "OJO ABIERTO: INMÓVIL" if watcher_open else "OJO CERRADO: AVANZA" # Piso I
        return "MISIÓN: Recuperar el sello del Testigo"
    if _enemy_kind() == "testigo" and _enemy_active() and bool(_floor().get("inverted", false)):
        return "OJO ABIERTO: ¡NO TE DETENGAS!" if watcher_open else "OJO CERRADO: GOLPÉALO · almas %d/3" % (3 - collected.count(false))
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
    var size: int = 16 if touch_enabled else 14
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
    _title_text("El Templo de los Ecos", Vector2(149, 300), 48, CREAM, main.size.x)
    _ornament_line(Vector2(480, 318), 150.0)
    _text_outline("UN LUGAR SAGRADO. UN CICLO QUE SE ALIMENTA DE TI.", Vector2(149, 362), 14, CREAM, main.size.x)
    draw_rect(Rect2(318, 376, 324, 2), UI_GOLD.darkened(0.3))
    _text_outline("ROGUELIKE DE TERROR · PISOS I–%s · REGLAS POR DESCUBRIR" % FLOORS[FLOORS.size() - 1]["number"], Vector2(149, 398), 12, SOUL, main.size.x)
    _text_outline("No conoces las reglas. Aún.", Vector2(149, 422), 15, Color("#b9b29b"), main.size.x)
    ## Botones: los PISOS son la entrada al juego (el Piso I empieza desde el
    ## principio); la VIGILIA es el modo aparte.
    _big_button(FLOORS_BTN, "JUGAR", "antorcha_encendida", Color("#3b2550"), Color("#a988d0"))
    _big_button(VIGIL_BTN, "VIGILIA", "descansar", Color("#43301a"), UI_GOLD)
    var hot_q: bool = QUIT_BTN.has_point(ui_hover)
    _panel(QUIT_BTN, Color("#3a1a20") if hot_q else Color("#141922"), UI_CRIMSON if hot_q else UI_LIGHT)
    _text_outline("SALIR", QUIT_BTN.position + Vector2(0, 19), 12, CREAM if hot_q else Color("#b9b29b"), QUIT_BTN.size.x)
    _text_outline(_hint("ENTER  jugar (elegir piso)   ·   H  vigilia   ·   ESC  salir", "Toca JUGAR para elegir piso", _t("mando_titulo")), Vector2(149, 526), 12, Color("#9fb3b3"), main.size.x)
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
    ## Botón principal: crece un poco y brilla al pasar el cursor (como los
    ## botones animados del primer juego del autor).
    var hot: bool = rect.has_point(ui_hover)
    var k: float = move_toward(float(btn_anim.get(label, 0.0)), 1.0 if hot else 0.0, 0.12)
    btn_anim[label] = k
    var r := rect.grow(roundf(3.0 * k))
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 3.0)
    draw_rect(r.grow(4.0), Color(edge.r, edge.g, edge.b, 0.05 + 0.12 * k + 0.04 * pulse), false, 3.0)
    _panel(r, Color(fill.r, fill.g, fill.b, 0.55 + 0.35 * k), edge)
    _vgradient(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6.0, r.size.y * 0.45)), Color(1, 1, 1, 0.05 + 0.06 * k), Color(1, 1, 1, 0.0))
    var icon_tex: Texture2D = DEFENSE_ICONS.get(icon, ICONS.get(icon, null))
    if icon_tex != null:
        draw_texture_rect(icon_tex, Rect2(r.position + Vector2(14, roundf(r.size.y * 0.5) - 16.0), Vector2(32, 32)), false)
    _text_outline(label, Vector2(r.position.x + 30.0, r.position.y + r.size.y * 0.5 + 8.0), 22, CREAM.lerp(Color.WHITE, k * 0.5), r.size.x - 30.0)


func _draw_altar_overlay() -> void:
    _overlay()
    _panel(Rect2(164, 155, 632, 357), Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _center("EL MERCADER SILENCIOSO", 200, 26, CREAM)
    _center("'Todo préstamo tiene un dueño que no conoces.'", 232, 15, SOUL)
    var offers := [
        ["resonancia", "[1] RESONANCIA" if not has_pulse else "[1] MEJORAR RESONANCIA", "Onda (Q) que daña y aturde a las entidades cercanas." if not has_pulse else "Nivel %d → %d: la onda hace más daño." % [ability_level, ability_level + 1], 14 if not has_pulse else RESONANCE_UPGRADE_BASE + RESONANCE_UPGRADE_STEP * ability_level, has_pulse and ability_level >= ABILITY_LEVEL_MAX, "NIVEL MÁXIMO"],
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
    _text(_hint("E / ESC: salir", "Toca fuera para salir", "B: salir"), Vector2(600, 484), 14, CREAM)


func _draw_inventory_overlay() -> void:
    ## PERFIL del jugador (I / Tab, o tocar el retrato): ficha de personaje al
    ## estilo de los roguelike de acción. Izquierda: retrato y estadísticas.
    ## Derecha: equipo y habilidades, Ecos y la descripción de lo señalado.
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.78))
    var sheet := Rect2(70, 46, 820, 548)
    _panel(sheet, Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _panel(Rect2(380, 34, 200, 30), Color("#2a1d22"), UI_GOLD)
    _title_text("Perfil", Vector2(380, 58), 24, CREAM, 200.0)
    # --- Columna izquierda: retrato y datos.
    var frame := Rect2(102, 84, 140, 140)
    _panel(frame, Color("#1a1f2a"), UI_GOLD)
    draw_texture_rect(_portrait(hp / max_hp < 0.35), Rect2(frame.position + Vector2(6, 6), Vector2(128, 128)), false)
    _text_outline(_hero_name(), Vector2(252, 112), 26, CREAM)
    _text_outline("IDENTIDAD %03d" % identity_number, Vector2(252, 136), 13, Color("#a0b6b2"))
    _text_outline("PISO %s · SALA %d" % [_floor()["number"], current_room + 1], Vector2(252, 158), 13, UI_GOLD)
    var fate: String = "Recuerda sus vidas" if reincarnations > 0 else "Primera vida"
    _text_outline(fate, Vector2(252, 180), 12, Color("#8a8574"))
    _text_outline("NIVEL %d" % player_level, Vector2(252, 204), 14, UI_GOLD)
    var xp_label: String = "MÁXIMO" if player_level >= LEVEL_MAX else "%d/%d XP" % [xp, _xp_needed(player_level)]
    _px_bar(Rect2(252, 210, 108, 14), _xp_fraction(), Color("#c9a25e"), xp_label)
    _px_bar(Rect2(102, 236, 238, 18), minf(1.0, hp / max_hp), BAR_HP, ("VIDA %d/%d" % [int(ceil(hp)), int(max_hp)]) + ((" +%d" % int(ceil(hp - max_hp))) if hp > max_hp else ""))
    _px_bar(Rect2(102, 258, 238, 18), stamina / 100.0, BAR_VIGOR, "VIGOR %d" % int(stamina))
    _px_bar(Rect2(102, 280, 238, 18), fear / 100.0, BAR_FEAR, "MIEDO %d%%" % int(fear))
    var stats := [
        ["Daño del golpe", "%d" % int(_strike_damage())],
        ["Daño de Resonancia", ("%d" % int(_pulse_damage())) if has_pulse else "—"],
        ["Almas", "%d" % souls],
        ["Muertes", "%d" % deaths],
        ["Retornos", "%d" % reincarnations],
        ["Pisos superados", "%d" % cleared],
        ["Vida máxima", "%d" % int(max_hp)],
        ["Marca", {"bendicion": "Bendición", "maldicion": "Maldición"}.get(_mark(), "Ninguna") + " (%+d)" % karma],
    ]
    _panel(Rect2(96, 310, 250, 268), Color("#0f1218"))
    for i in range(stats.size()):
        var y: float = 338.0 + float(i) * 29.0
        _text_outline(stats[i][0], Vector2(112, y), 13, Color("#b9b29b"))
        draw_string(font, Vector2(112, y), stats[i][1], HORIZONTAL_ALIGNMENT_RIGHT, 220.0, 15, CREAM)
        if i < stats.size() - 1:
            draw_rect(Rect2(112, y + 11.0, 220, 1), Color(1, 1, 1, 0.06))
    # --- Columna derecha: pestañas EQUIPO / OBJETOS (casillas seleccionables).
    for t in range(2):
        var tr: Rect2 = _profile_tab_rect(t)
        var on: bool = profile_tab == t
        _panel(tr, Color("#2a1d22") if on else Color("#141922"), UI_GOLD if on else UI_EDGE)
        _text_outline(["EQUIPO Y MOCHILA", "OBJETOS (%d)" % _object_slots().size()][t], Vector2(tr.position.x, tr.position.y + 17.0), 12, CREAM if on else Color("#9a957f"), tr.size.x)
    for i in range(INVENTORY_SLOTS.size() if profile_tab == 0 else 0):
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
    if profile_tab == 1:
        _draw_object_slots()
    # --- Ecos: iconos compactos (caben los diez pisos); el detalle está en HABILIDADES.
    _text_outline("ECOS", Vector2(372, 368), 13, UI_GOLD)
    var keys: Array = ECOS.keys()
    for i in range(keys.size()):
        var r: Rect2 = _profile_eco_rect(i)
        var has_it: bool = ecos.has(keys[i])
        var sel_e: bool = inventory_sel == 100 + i
        _panel(r, Color("#222c39") if sel_e else Color("#141922"), UI_GOLD if sel_e else (Color("#3b6f7d") if has_it else UI_EDGE))
        draw_texture_rect(ICONS["eco_" + str(keys[i])], Rect2(r.position + Vector2(6, 6), Vector2(32, 32)), false, Color.WHITE if has_it else Color(0.15, 0.15, 0.18, 0.9))
    var hot_ab: bool = PROFILE_ABIL_BTN.has_point(ui_hover)
    _panel(PROFILE_ABIL_BTN, Color("#241a30") if hot_ab else Color("#141922"), UI_GOLD)
    draw_texture_rect(ICONS["habilidades"], Rect2(PROFILE_ABIL_BTN.position + Vector2(8, 10), Vector2(24, 24)), false)
    _text_outline("HABILIDADES" if touch_enabled and not pad_active else "HABILIDADES (%s)" % _key_label("habilidades"), Vector2(PROFILE_ABIL_BTN.position.x + 36.0, PROFILE_ABIL_BTN.position.y + 26.0), 12, CREAM)
    # --- Descripción de la casilla señalada (cursor, flechas o toque).
    var desc_box := Rect2(372, 454, 496, 76)
    _panel(desc_box, Color("#0f1218"))
    if inventory_sel >= 100:
        var ek: String = str(ECOS.keys()[clampi(inventory_sel - 100, 0, ECOS.size() - 1)])
        var has_e: bool = ecos.has(ek)
        _text_outline(("ECO · " + ECOS[ek][0]) if has_e else "ECO SIN DESPERTAR", Vector2(388, 478), 15, SOUL if has_e else Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), ECOS[ek][1] if has_e else "Supera un piso para despertarlo.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, CREAM if has_e else Color("#8a8778"))
    elif profile_tab == 1:
        _draw_object_desc()
    else:
        var owned_sel: bool = _slot_owned(inventory_sel)
        _text_outline(INVENTORY_SLOTS[inventory_sel][1] if owned_sel else "???", Vector2(388, 478), 15, CREAM if owned_sel else Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), INVENTORY_SLOTS[inventory_sel][2] if owned_sel else "Aún no lo tienes.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, SOUL if owned_sel else Color("#8a8778"))
    _text_outline(_hint("I / ESC: cerrar", "Toca fuera para cerrar", "B: cerrar"), Vector2(372, 564), 12, Color("#8a8574"), 320.0)


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
    _title_text("Piso %s" % _floor()["number"], Vector2(0, 124), 24, UI_GOLD, W)
    _title_text(_tc(_floor()["title"]), Vector2(0, 176), 48, CREAM, W)
    if floor_intro_eco != "":
        var eco: Array = ECOS[floor_intro_eco]
        _center("ECO ADQUIRIDO: %s" % eco[0], 486, 16, SOUL)
        _center(eco[1], 510, 14, Color("#b9b29b"))
    var pulse: float = 0.6 + 0.4 * sin(elapsed * 3.0)
    _center(_hint("ENTRAR  ·  ENTER", "TOCA PARA ENTRAR", "ENTRAR  ·  A"), 560, 18, Color(0.89, 0.74, 0.48, pulse))


func _draw_end_overlay(win: bool) -> void:
    _overlay()
    if win and bool(_floor().get("final", false)):
        _title_text("Fin del primer arco", Vector2(0, 214), 48, SOUL, W)
        _center("La Puerta de la Cosecha no lleva a la salida, sino a otros escalones.", 262, 17, CREAM)
        _center("«Esto no es una salida. Es una transición.»", 300, 20, Color("#e3bd7b"))
        _center("En el marco, doscientas marcas de alas: este lugar es solo uno de muchos.", 338, 15, Color("#9fb3b3"))
        _center("Continuará.", 376, 16, CREAM)
        _center(_hint("ENTER: volver a empezar  ·  ESC: menú", "Toca para volver a empezar", "A: volver a empezar  ·  B: menú"), 430, 18, CREAM)
    elif win:
        _center("PISO %s SUPERADO" % _floor()["number"], 230, 33, SOUL)
        _center("No has escapado. El siguiente nivel sigue oculto.", 280, 18, CREAM)
        _center("Nada es lo que parece.", 318, 16, CREAM)
        _center(_hint("ENTER: repetir prueba  ·  ESC: menú", "Toca para repetir la prueba", "A: repetir prueba  ·  B: menú"), 418, 18, CREAM)
    elif soul_fate == "persistencia":
        _death_vignette()
        _title_text("%s ha caído" % _tc(_hero_name()), Vector2(0, 240), 48, Color("#d0475a"), W)
        _center("Este lugar todavía no te reclama.", 278, 18, CREAM)
        _center("Conservas almas, objetos, habilidades y ecos.", 318, 17, CREAM)
        _center("(Modo de pruebas: la muerte no cuesta progreso.)", 352, 15, Color("#9fb3b3"))
        _center(_hint("ENTER: levantarte en la entrada de la sala  ·  ESC: menú", "Toca para levantarte en la entrada de la sala", "A: levantarte  ·  B: menú"), 418, 18, CREAM)
    elif soul_fate == "retorno":
        _center("TU ALMA HA REGRESADO", 230, 30, SOUL)
        _center("Resultado aleatorio de la muerte: reencarnación (50 %).", 278, 18, CREAM)
        _center("Eres la misma persona. Conservas memoria y habilidades.", 318, 17, CREAM)
        _center("Los niveles de habilidad regresaron a cero.", 352, 17, CREAM)
        _center(_hint("ENTER: reaparecer al inicio  ·  ESC: menú", "Toca para reaparecer al inicio", "A: reaparecer  ·  B: menú"), 418, 18, CREAM)
    else:
        _center("ALMA ABSORBIDA", 230, 32, RED)
        _center("Resultado aleatorio: absorción definitiva (50 %).", 278, 18, CREAM)
        _center("La persona anterior ha dejado de existir.", 318, 17, CREAM)
        _center("Un nuevo humano ocupará el lugar, sin sus recuerdos.", 352, 17, CREAM)
        _center(_hint("ENTER: iniciar nueva identidad  ·  ESC: menú", "Toca para iniciar una nueva identidad", "A: nueva identidad  ·  B: menú"), 418, 18, CREAM)


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
    # La marca cambia cómo te ven: con bendición confía más; con maldición, nunca.
    var chance: float = {"bendicion": 0.35, "maldicion": 1.0}.get(_mark(), PILGRIM_TRAITOR_CHANCE)
    pilgrim_traitor = randf() < chance
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
        _heal(30.0)
        souls_flash = 0.8
        _pilgrim_say("Toma, bebe. Y la mitad de lo mío. Nadie debería cruzar esto solo.", 4.5)
        _say("El Peregrino era sincero: +%d almas y agua (+30 de vida)." % gift, 4.0)
        _sfx("alma", -6.0, 0.9)


## Mientras te acompaña no se le puede tocar: los golpes a las alimañas (o
## la Resonancia) no deben destapar la traición antes de tiempo. Solo se le
## puede herir cuando desenvaina.
func _pilgrim_can_be_hit() -> bool:
    return pilgrim_state in ["tell", "hostile"]


func _damage_pilgrim(amount: float) -> void:
    if not _pilgrim_can_be_hit():
        return
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
    "pj_nombre_mando": ["Cruceta elegir  ·  A letra  ·  X borrar  ·  Y al azar  ·  START seguir  ·  B volver", "D-pad choose  ·  A letter  ·  X delete  ·  Y random  ·  START next  ·  B back"],
    "pj_genero_mando": ["Cruceta elegir  ·  A comenzar  ·  B atrás", "D-pad choose  ·  A start  ·  B back"],
    "pj_nombre_tactil": ["Toca las letras (o AL AZAR) y luego SIGUIENTE", "Tap the letters (or RANDOM) and then NEXT"],
    "pj_genero_tactil": ["Toca tu personaje y luego COMENZAR", "Tap your character and then START"],
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
    "subtitulo": ["Un roguelike de terror. Despiertas a oscuras y nadie te dice por qué.", "A horror roguelike. You wake in the dark and no one tells you why."],
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
    "mando_reasignar": ["El mando tiene un esquema fijo; reasigna con el teclado.", "The gamepad layout is fixed; rebind with the keyboard."],
    "mando_golpe": ["Enciende la antorcha (X) para golpear con fuego.", "Light the torch (X) to strike with fire."],
    "mando_conectado": ["Mando conectado: %s", "Gamepad connected: %s"],
    "mando_desconectado": ["Mando desconectado.", "Gamepad disconnected."],
    "mando_hud": ["STICK mover · A/RT golpear · X antorcha · B/LT esquivar · Y resonancia · LB perfil · RB habilidades · START pausa",
        "STICK move · A/RT strike · X torch · B/LT dodge · Y resonance · LB profile · RB abilities · START pause"],
    "mando_esquema": ["MANDO: stick/cruceta mover · A usar/golpear · RT golpear · B/LT esquivar · X antorcha · Y resonancia",
        "GAMEPAD: stick/D-pad move · A use/strike · RT strike · B/LT dodge · X torch · Y resonance"],
    "mando_esquema2": ["LB perfil · RB habilidades · START pausa · en menús: A aceptar, B volver, LB/RB pestañas",
        "LB profile · RB abilities · START pause · in menus: A accept, B back, LB/RB tabs"],
    "mando_titulo": ["A  jugar   ·   X  personaje   ·   RB  vigilia   ·   SELECT  ajustes   ·   B  salir",
        "A  play   ·   X  character   ·   RB  vigil   ·   SELECT  settings   ·   B  quit"],
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
    "pantalla_completa": ["Pantalla completa", "Fullscreen"],
    "creditos": ["CRÉDITOS", "CREDITS"],
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
    "creditos": [
        ["EL TEMPLO DE LOS ECOS · creado por je7remy. Diseño, historia y desarrollo.", "THE TEMPLE OF ECHOES · created by je7remy. Design, story and development."],
        ["Escenario: Knowledge Temple, por pingupollas (pingupollas.itch.io/knowledge-temple). Criaturas: GothicVania Church Pack, por Luis Zuno (Ansimuz).", "Environment: Knowledge Temple by pingupollas (pingupollas.itch.io/knowledge-temple). Creatures: GothicVania Church Pack by Luis Zuno (Ansimuz)."],
        ["Protagonistas, entidades, iconos, efectos, música y la mayoría de sonidos: originales del proyecto. Sonidos de impacto y pasos, y controles táctiles: Kenney (kenney.nl), CC0.", "Protagonists, entities, icons, effects, music and most sounds: original to the project. Impact and footstep sounds and touch controls: Kenney (kenney.nl), CC0."],
        ["Tipografías: Pixelify Sans y Jacquard 24 (SIL Open Font License 1.1).", "Fonts: Pixelify Sans and Jacquard 24 (SIL Open Font License 1.1)."],
        ["Nacido de un primer juego: Craving Candy. En memoria de Leudy Antonio Mendez.", "Born from a first game: Craving Candy. In memory of Leudy Antonio Mendez."],
    ],
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
         "whisper": "Aprende a moverte antes de que este lugar te enseñe a su manera.", "items": []},
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
    for k in range(10): # halo suave: muchos discos muy tenues
        draw_circle(Vector2(480, 175), (40.0 + float(k) * 14.0) * (1.0 + glow * 0.05), Color(0.45, 0.75, 0.85, 0.012))
    _draw_visual_atmosphere()
    draw_texture_rect(BRAND_ICON, Rect2(424, 118, 112, 112), false)
    _ornament_line(Vector2(480, 384), 200.0)
    _title_text("El Templo", Vector2(0, 306), 72, CREAM, W)
    _title_text("de los Ecos", Vector2(0, 366), 72, SOUL, W)
    _text_outline(_t("subtitulo"), Vector2(0, 410), 15, Color("#b9b29b"), W)
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
            var rows := [["slider", "volumen_general", "vol_general"], ["slider", "volumen_musica", "vol_musica"], ["slider", "volumen_efectos", "vol_efectos"], ["toggle", "silencio", "silencio"], ["toggle", "pantalla_completa", "pantalla_completa"]]
            for i in range(rows.size()):
                list.append({"kind": rows[i][0], "id": rows[i][1], "label": _t(rows[i][2]), "rect": Rect2(140, 172.0 + float(i) * 66.0, 680, 54)})
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
            list.append({"kind": "button", "id": "creditos", "label": _t("creditos"), "rect": Rect2(490, 392, 330, 46)})
    list.append({"kind": "button", "id": "volver", "label": _t("volver"), "rect": Rect2(660, 520, 180, 44)})
    return list


func _settings_focusable() -> Array:
    return _settings_widgets().filter(func(w): return w["kind"] != "tab")


func _draw_settings() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.82))
    _panel(SETTINGS_PANEL, Color(0.05, 0.06, 0.08, 0.98), UI_GOLD)
    _panel(Rect2(380, 48, 200, 30), Color("#2a1d22"), UI_GOLD)
    _title_text(_tc(_t("ajustes")), Vector2(380, 72), 24, CREAM, 200.0)
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
        if legal_page != "creditos":
            _text_outline("BORRADOR · no es asesoramiento legal" if Ajustes.obtener("idioma") == "es" else "DRAFT · not legal advice", Vector2(140, 548), 11, Color("#8a8574"))
        return
    match settings_tab:
        1:
            _text_outline(_t("pulsa_tecla") if rebinding != "" else _t("clic_cambiar"), Vector2(130, 176 - 4), 12, UI_GOLD if rebinding != "" else Color("#9a957f"))
            _text_outline(_t("mando_esquema"), Vector2(118, 538), 11, SOUL)
            _text_outline(_t("mando_esquema2"), Vector2(118, 556), 11, SOUL)
        2:
            _draw_text_block(_t("nota_idioma"), Rect2(250, 350, 460, 60), 13, Color("#9a957f"))
        3:
            _draw_text_block(_t("privacidad_resumen"), Rect2(140, 178, 680, 60), 15, Color("#d0c8b0"))
            _draw_text_block(_t("privacidad_ruta") % [_save_path(), Ajustes.ruta()], Rect2(140, 262, 680, 40), 12, Color("#9a957f"))
            if confirm_delete:
                _text_outline("Se borrará todo (campaña, Vigilia y ajustes) y empezarás de cero." if Ajustes.obtener("idioma") == "es" else "Everything (campaign, Vigil and settings) will be deleted; you will start over.", Vector2(490, 420), 12, RED)


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
            if w["id"] == "pantalla_completa":
                _apply_window_mode()
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
                "acuerdo", "politica", "creditos":
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
                        _wipe_everything()
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


## Borrar perfil: se borran el progreso de la campaña, los récords de la
## Vigilia y los ajustes, y el juego se reinicia desde cero (intro, tutorial
## y creación del personaje, con todos los pisos bloqueados salvo el I).
const VIGILIA_SAVES := ["user://vigilia_claustro_records.json", "user://prueba_vigilia.json"]


func _wipe_everything() -> void:
    Ajustes.borrar_todo(_save_path())
    for path in VIGILIA_SAVES:
        if (path.contains("prueba") == Engine.has_meta("modo_prueba")) and FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    Ajustes.aplicar_audio()
    confirm_delete = false
    if Engine.has_meta("splash_visto"):
        Engine.remove_meta("splash_visto")
    if Engine.has_meta("modo_prueba"):
        # En las pruebas no se recarga la escena: se vacía el estado aquí mismo.
        _reset_progress_vars()
        _say(_t("borrado"), 2.5)
        _back_to_splash()
        return
    get_tree().call_deferred("reload_current_scene")


func _reset_progress_vars() -> void:
    player_level = 1
    xp = 0
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
    player_name = ""
    player_gender = "masculino"
    max_floor = 0
    has_mask = false
    rescued = []
    guided = []
    death_marks = {}
    trinkets = []
    trinket_levels = {}
    bag = {}
    karma = 0
    souls = 0
    chests_opened = {}


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
            _open_inventory() # al cerrarlo se vuelve a la pausa
        "habilidades":
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
    _title_text(_tc(_t("pausa")), Vector2(panel.position.x, 186), 48, CREAM, panel.size.x)
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
    ["Columnas que no reconoces. Bóvedas sin cielo. Ecos de pasos que no son tuyos.", "Columns you don't recognize. Vaults with no sky. Echoes of footsteps that aren't yours.", "templo"],
    ["Algo aquí te observa. No sabes desde dónde.", "Something here is watching you. You don't know from where.", "ojo"],
    ["Otros llegaron antes. Lo que dejaron atrás todavía brilla.", "Others came before. What they left behind still glows.", "almas"],
    ["Encuentra la luz. Siempre hay otra puerta.", "Find the light. There is always another door.", "descenso"],
]


## Primera partida: intro, tutorial y, al terminarlo, crear el personaje.
func _start_explore() -> void:
    if not bool(Ajustes.obtener("intro_vista")):
        _start_intro("tutorial")
    elif not bool(Ajustes.obtener("tutorial_hecho")):
        _start_tutorial()
    elif player_name == "":
        _start_creation("explore")
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
        _start_explore()
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
    _skip_button(INTRO_SKIP_BTN)


# ------------------------------------------------------------ TUTORIAL
## Pasos: [texto ES, texto EN]. Las teclas se escriben según la configuración.
func _tutorial_text(step: int) -> String:
    var es := [
        "Muévete con %s %s %s %s o las flechas" % [_key_label("arriba"), _key_label("izquierda"), _key_label("abajo"), _key_label("derecha")],
        "Esquiva con %s: te hace invulnerable un instante" % _key_label("esquivar"),
        "Recoge un alma: basta con tocarla",
        "Pulsa %s para encender la antorcha (gasta un fósforo)" % _key_label("antorcha"),
        "Golpea al muñeco 3 veces con CLIC o %s" % _key_label("interactuar"),
        "Abre tu perfil con %s y vuelve a cerrarlo" % _key_label("perfil"),
        "Pausa el juego con %s y continúa" % _key_label("pausa"),
        "¡Listo! Cruza la puerta para empezar",
    ]
    var en := [
        "Move with %s %s %s %s or the arrow keys" % [_key_label("arriba"), _key_label("izquierda"), _key_label("abajo"), _key_label("derecha")],
        "Dodge with %s: you are invulnerable for an instant" % _key_label("esquivar"),
        "Collect a soul: just touch it",
        "Press %s to light the torch (uses a match)" % _key_label("antorcha"),
        "Hit the dummy 3 times with CLICK or %s" % _key_label("interactuar"),
        "Open your profile with %s and close it again" % _key_label("perfil"),
        "Pause the game with %s and resume" % _key_label("pausa"),
        "Done! Cross the door to enter the temple",
    ]
    if pad_active:
        es[0] = "Muévete con el stick izquierdo o la cruceta"
        en[0] = "Move with the left stick or the D-pad"
        es[4] = "Golpea al muñeco 3 veces con A o RT"
        en[4] = "Hit the dummy 3 times with A or RT"
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
    if player_name == "":
        _start_creation("explore") # tras el tutorial, tu nombre y tu género
        return
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
    pad_name_sel = 0
    if pad_active:
        _pad_name_hover()
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
    elif create_then.begins_with("piso:"):
        _start_floor(int(create_then.substr(5)))
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
        _text_outline(_t(_hint("pj_nombre_ayuda", "pj_nombre_tactil", "pj_nombre_mando")), Vector2(150, 520), 12, Color("#9fb3b3"), CREATE_PANEL.size.x)
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
        _text_outline(_t(_hint("pj_genero_ayuda", "pj_genero_tactil", "pj_genero_mando")), Vector2(150, 530), 12, Color("#9fb3b3"), CREATE_PANEL.size.x)
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
    respawn_fx = 1.4
    _transition("radial", true, 0.8)
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


## Esquivar y Resonancia se recargan al ritmo de la barra de vigor: están
## listas en cuanto la barra vuelve a cubrir su coste.
const STAMINA_REGEN := 16.0 # vigor por segundo
const RESONANCE_COST := 40.0
const ABILITY_LOCK := 0.25 # evita dobles pulsaciones accidentales


func _dash_cost() -> float:
    return DASH_COST * (0.6 if ecos.has("reflejos") else 1.0) # Reflejos: esquivar cuesta menos


## Segundos que tarda la barra en recuperar un coste desde vacío (para textos).
## Recarga propia de esquivar: un 50 % más larga que lo que tarda la barra
## en recuperar su coste. Reflejos (menos coste), el amuleto y los niveles
## (más recarga del vigor) la acortan.
const DASH_COOLDOWN_MULT := 1.5
var dash_cd_max: float = 1.0


func _dash_cooldown() -> float:
    return DASH_COOLDOWN_MULT * _dash_cost() / _stamina_regen()


## Fracción que falta para poder esquivar (vigor o recarga, lo que tarde más).
func _dash_wait() -> float:
    return maxf(_vigor_wait(_dash_cost()), clampf(dash_cd / maxf(0.01, dash_cd_max), 0.0, 1.0))


## Fracción que falta para poder usar algo que cuesta «cost» de vigor (0 = listo).
func _vigor_wait(cost: float) -> float:
    return clampf((cost - stamina) / cost, 0.0, 1.0)


## Nombre del botón o tecla de una acción, según lo último que se usó.
const PAD_LABELS := {"arriba": "STICK", "abajo": "STICK", "izquierda": "STICK", "derecha": "STICK",
    "interactuar": "A", "antorcha": "X", "esquivar": "B", "resonancia": "Y", "perfil": "LB",
    "habilidades": "RB", "pausa": "START"}


func _key_label(action: String) -> String:
    if pad_active and PAD_LABELS.has(action):
        return PAD_LABELS[action]
    return Ajustes.nombre_tecla(action)


func _short_key(action: String) -> String:
    var k: String = _key_label(action)
    if k in ["ESPACIO", "SPACE"]:
        return "SP"
    return k.substr(0, 2) if k.length() > 2 else k


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
            hp -= SEG_DAMAGE * _depth_mult()
            fear = minf(100.0, fear + 24.0)
            damage_cd = 1.2
            _say("El hilo te atraviesa.", 3.0)
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
    _guides_enter_room()
    allies_here = not allies.is_empty() and not in_tutorial and (_floor_has_trait("aliados") or guiding or _has("guias"))
    if not allies_here:
        return
    for i in range(allies.size()):
        var ally: Dictionary = allies[i]
        if bool(ally.get("waiting", false)):
            continue # el grupo del Piso VI espera en su sitio
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
            _say("Nadie más llegó hasta aquí. Este lugar cobró su parte.", 4.5)
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
        if bool(ally.get("waiting", false)):
            target = pos # esperan junto a la estatua a que aceptes guiarlos
        elif bool(ally.get("flee", false)):
            target = door_pos # rompe la regla: echa a correr
            speed = 210.0
        elif float(ally.get("panic", 0.0)) > 0.0:
            target = pos + Vector2(randf_range(-2, 2), 0) # tiembla sin moverse
        elif tense:
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
            target = player_pos + back * (120.0 if _mark() == "maldicion" else 52.0) + side * float(idx - 1) * 38.0
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
        _label_center(str(ally["name"]) + (" · SIN MANO" if bool(ally.get("maimed", false)) else ""), pos + Vector2(0.0, -66.0), Color("#d1747b") if bool(ally.get("maimed", false)) else Color("#9fd8b0"))
        if float(ally["line_t"]) > 0.0:
            _label_center("«%s»" % ally["line"], pos + Vector2(0.0, -84.0), CREAM)
        if float(ally.get("panic", 0.0)) > 0.0:
            var blink: bool = int(elapsed * 5.0) % 2 == 0
            _label_center(_prompt("¡CÁLMALO!"), pos + Vector2(0.0, -102.0), Color("#ff6b6b") if blink else Color("#ffd36b"))


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
const PROFILE_ABIL_BTN := Rect2(706, 538, 162, 42)
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
    if dash_cd > 0.0 or stamina < _dash_cost() or game_mode != "play":
        return
    var move: Vector2 = _controls_axis()
    dash_dir = move.normalized() if move.length() > 0.1 else (player_dir.normalized() if player_dir.length() > 0.1 else Vector2.RIGHT)
    dash_left = DASH_TIME
    dash_cd = _dash_cooldown()
    dash_cd_max = dash_cd
    stamina -= _dash_cost()
    _emit(player_pos, 12, Color(0.62, 0.57, 0.5, 0.6), 30.0, 90.0, 0.55, 3.0, -20.0, -dash_dir, 1.1)
    _emit(player_pos + Vector2(0, -24), 8, Color(0.56, 0.78, 0.84, 0.7), 20.0, 60.0, 0.4, 2.0, 0.0, -dash_dir, 0.6, true)
    _sfx("toque", -14.0, 1.6)
    if in_tutorial:
        tut_dashed = true


func _update_regen(dt: float) -> void:
    if hp < hp_prev - 0.01:
        regen_wait = REGEN_WAIT # recibir daño reinicia la espera
        if ecos.has("piel"):
            hp += (hp_prev - hp) * 0.25 # Piel curtida: un cuarto del daño no entra
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
                if t >= TRAP_UP:
                    _sfx("k_metal", -16.0, 1.2)
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
                _say("Pinchos en el suelo.", 3.0)
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
    draw_multiline_string(font, box.position + Vector2(16, 40), str(ins[1]).replace("{yo}", _hero_name()), HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 32.0, 14, 2, CREAM)


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
    _sfx("k_campana", -13.0, 1.2)
    var reward: int = int(m.get("reward", 0))
    souls += reward
    souls_flash = 0.8
    mission_banner = "MISIÓN CUMPLIDA · %s · +%d almas" % [m["text"], reward]
    mission_banner_t = 3.2
    _gain_xp(XP_MISSION + reward)
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
const ROOM_TALKS = Pisos.ROOM_TALKS


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
        if (who in ALLY_NAMES or who in GUIDE_NAMES or who == "SAÚL") and not _ally_alive_named(who):
            continue
        if line.size() > 2 and str(line[2]) == "solo" and guiding:
            continue
        if line.size() > 2 and str(line[2]) == "grupo" and not guiding:
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
        var more: String = ("»  " + _hint("clic / E", "toca", "A")) if dialog_queue.size() > 1 else ("»  " + _hint("clic / E", "toca", "A") + " para cerrar")
        _text_outline(more, Vector2(box.end.x - 230.0, box.end.y - 12.0), 12, Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.5 + 0.5 * pulse), 210.0)
    _skip_button(SKIP_BTN)


# --- Pantalla de habilidades ---------------------------------------------------------
var abilities_return: String = "play"
## Páginas de la pantalla de habilidades: cada columna muestra las filas que
## caben y el resto pasa a la página siguiente, así nunca se sale del cuadro
## por muchas habilidades o Ecos que haya.
var abil_page: int = 0
const ABIL_TOP := 102.0
const ABIL_BOTTOM := 540.0
const ABIL_ROW_H := 84.0
const ECO_ROW_H := 70.0
const ABIL_PREV_BTN := Rect2(372, 546, 48, 34)
const ABIL_NEXT_BTN := Rect2(540, 546, 48, 34)


func _abil_per_page() -> int:
    return maxi(1, int((ABIL_BOTTOM - ABIL_TOP) / ABIL_ROW_H))


func _eco_per_page() -> int:
    return maxi(1, int((ABIL_BOTTOM - ABIL_TOP - 20.0) / ECO_ROW_H))


func _abil_pages() -> int:
    var a: int = int(ceil(float(_ability_rows().size()) / float(_abil_per_page())))
    var e: int = int(ceil(float(ECOS.size()) / float(_eco_per_page())))
    return maxi(1, maxi(a, e))


func _abil_turn(d: int) -> void:
    var n: int = _abil_pages()
    if n <= 1:
        return
    abil_page = (abil_page + d + n) % n
    _sfx("toque", -14.0, 1.0)


func _open_abilities() -> void:
    if not game_mode in ["play", "pause", "inventory"]:
        return
    if game_mode != "inventory":
        overlay_return = game_mode # desde la pausa, ESC vuelve a la pausa
    game_mode = "abilities"
    abil_page = 0
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -9.0, 1.1)


func _close_abilities() -> void:
    game_mode = overlay_return
    _sfx("interfaz", -12.0, 0.9)


## [icono, nombre, tecla, descripción, la tienes, coste]
func _ability_rows() -> Array:
    return [
        ["golpe", "GOLPE DE ANTORCHA", _key_label("interactuar") + (" / RT" if pad_active else " / CLIC"),
            "Arco de fuego a corta distancia. Daño %d. Necesita la antorcha encendida." % int(_strike_damage()), has_torch, "10 vigor"],
        ["resonancia", ("RUGIDO" if has_mask else "RESONANCIA") + " · NIVEL %d" % ability_level, _key_label("resonancia"),
            ("Con la Máscara de Porcelana la onda llega más lejos y espanta a los mastines 5 s. " if has_mask else "") + "Aturde a las entidades cercanas y les hace %d de daño." % int(_pulse_damage()), has_pulse, "%d vigor · se recarga con la barra" % int(RESONANCE_COST)],
        ["vigor", "ESQUIVAR", _key_label("esquivar"),
            "Impulso hacia donde te mueves o, quieto, hacia donde miras. Pasas por encima de las trampas.", true, "%d vigor · %.1f s de recarga" % [int(_dash_cost()), _dash_cooldown()]],
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
    _title_text("Habilidades", Vector2(360, 58), 24, CREAM, 240.0)
    _text_outline("ACTIVAS Y PROPIAS", Vector2(96, 92), 13, UI_GOLD)
    abil_page = clampi(abil_page, 0, _abil_pages() - 1)
    var rows: Array = _ability_rows()
    var per_a: int = _abil_per_page()
    for i in range(abil_page * per_a, mini(rows.size(), (abil_page + 1) * per_a)):
        var row: Array = rows[i]
        var r := Rect2(96, ABIL_TOP + float(i - abil_page * per_a) * ABIL_ROW_H, 420, 76)
        var owned: bool = row[4]
        _panel(r, Color("#141922") if owned else Color("#0e1015"), UI_EDGE if owned else Color("#24262c"))
        draw_texture_rect(ICONS[row[0]], Rect2(r.position + Vector2(10, 14), Vector2(48, 48)), false, Color.WHITE if owned else Color(0.12, 0.12, 0.14, 0.9))
        _text_outline(row[1] if owned else "???", Vector2(r.position.x + 70.0, r.position.y + 22.0), 14, CREAM if owned else Color("#5d5a52"))
        var keytag: String = str(row[2])
        var kw: float = font.get_string_size(keytag, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 14.0
        _panel(Rect2(r.end.x - kw - 10.0, r.position.y + 8.0, kw, 18), Color("#1d2230"), UI_GOLD if owned else UI_EDGE)
        _text_outline(keytag, Vector2(r.end.x - kw - 10.0, r.position.y + 22.0), 11, UI_GOLD if owned else Color("#5d5a52"), kw)
        var desc: String = row[3] if owned else "Aún no la tienes."
        draw_multiline_string(font, r.position + Vector2(70, 42), desc, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 84.0, 11, 2, Color("#b9b29b") if owned else Color("#5d5a52"))
        if owned:
            _text_outline(str(row[5]), Vector2(r.position.x + 70.0, r.end.y - 6.0), 10, SOUL)
    _text_outline("ECOS · PASIVAS DE CADA PISO", Vector2(540, 92), 13, UI_GOLD)
    var keys: Array = ECOS.keys()
    var per_e: int = _eco_per_page()
    var shown: int = 0
    for i in range(abil_page * per_e, mini(keys.size(), (abil_page + 1) * per_e)):
        var e := Rect2(540, ABIL_TOP + float(i - abil_page * per_e) * ECO_ROW_H, 324, 62)
        shown += 1
        var has_it: bool = ecos.has(keys[i])
        _panel(e, Color("#141922"), Color("#3b6f7d") if has_it else UI_EDGE)
        draw_texture_rect(ICONS["eco_" + str(keys[i])], Rect2(e.position + Vector2(10, 15), Vector2(32, 32)), false, Color.WHITE if has_it else Color(0.15, 0.15, 0.18, 0.9))
        _text_outline(ECOS[keys[i]][0] if has_it else "ECO SIN DESPERTAR", Vector2(e.position.x + 52.0, e.position.y + 22.0), 12, SOUL if has_it else Color("#5d5a52"))
        draw_multiline_string(font, e.position + Vector2(52, 40), ECOS[keys[i]][1] if has_it else "???", HORIZONTAL_ALIGNMENT_LEFT, e.size.x - 60.0, 10, 2, Color("#9a957f"))
    if abil_page * per_a >= rows.size():
        _text_outline("Tus habilidades están en la página 1.", Vector2(96, ABIL_TOP + 20.0), 12, Color("#8a8574"))
    _text_outline("%d de %d Ecos despiertos: uno por cada piso superado." % [ecos.size(), keys.size()], Vector2(540, ABIL_TOP + float(shown) * ECO_ROW_H + 14.0), 11, Color("#8a8574"))
    var pages: int = _abil_pages()
    if pages > 1:
        for b in [[ABIL_PREV_BTN, "<"], [ABIL_NEXT_BTN, ">"]]:
            var hot: bool = (b[0] as Rect2).has_point(ui_hover)
            _panel(b[0], Color("#241a30") if hot else Color("#141922"), UI_GOLD)
            _text_outline(b[1], Vector2((b[0] as Rect2).position.x, (b[0] as Rect2).position.y + 23.0), 18, CREAM, (b[0] as Rect2).size.x)
        _text_outline("PÁGINA %d / %d" % [abil_page + 1, pages], Vector2(420, 568), 13, UI_GOLD, 120.0)
    var paging: String = " · ◀ ▶ páginas" if pages > 1 else ""
    _text_outline(_hint("%s / ESC: cerrar%s" % [_key_label("habilidades"), paging], "Flechas: páginas · toca fuera para cerrar" if pages > 1 else "Toca para cerrar", "B: cerrar%s" % (" · cruceta/LB: páginas" if pages > 1 else "")), Vector2(96, 590), 11, Color("#8a8574"), 768.0)


func _eco_floor(key: String) -> String:
    for f in FLOORS:
        if str(f.get("eco", "")) == key:
            return str(f["number"])
    return "?"


# ------------------------------------------------------------ ARTE (etapa 2)
## Capas visuales nuevas: tipografía gótica de rótulos, partículas, niebla,
## rayos de luz, fundidos y un postproceso con bloom, gradación y viñeta.
const FADE_TIME := 0.5
const FLOORS_BTN := Rect2(190, 440, 330, 64)
const VIGIL_BTN := Rect2(540, 440, 230, 64)
const QUIT_BTN := Rect2(700, 162, 96, 26)
var title_font: Font
var motes: Array = [] # {p, v, s, f, ph}
var fx_parts: Array = [] # {p, v, life, max, size, col, grav, glow}
var fade_t: float = 0.0
var death_fx: float = -1.0
var respawn_fx: float = 0.0
var btn_anim: Dictionary = {}
var post_rect: ColorRect = null
var max_floor: int = 0 # piso más profundo alcanzado (menú de pisos)
var floors_sel: int = 0


## Pasa un rótulo en mayúsculas a «Título» (la gótica en mayúsculas no se lee).
func _tc(msg: String) -> String:
    var small := ["de", "del", "la", "las", "los", "el", "y", "a", "en"]
    var words: PackedStringArray = msg.to_lower().split(" ")
    var out: PackedStringArray = []
    for i in range(words.size()):
        var w: String = words[i]
        var up: String = w.to_upper()
        var roman: bool = up != "" and up.replace("I", "").replace("V", "").replace("X", "") == ""
        if roman:
            out.append(up)
        elif i > 0 and w in small and words[i - 1] != "·":
            out.append(w)
        else:
            out.append(w.substr(0, 1).to_upper() + w.substr(1))
    return " ".join(out)


func _title_text(msg: String, at: Vector2, size: int, color: Color, width: float = -1.0) -> void:
    var align: int = HORIZONTAL_ALIGNMENT_CENTER if width > 0.0 else HORIZONTAL_ALIGNMENT_LEFT
    var f: Font = title_font if title_font != null else font
    var shade := Color(0.0, 0.0, 0.0, color.a * 0.85)
    draw_string(f, at + Vector2(0, maxf(2.0, float(size) / 16.0)), msg, align, width, size, Color(0.12, 0.02, 0.05, color.a * 0.8))
    for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
        draw_string(f, at + o, msg, align, width, size, shade)
    draw_string(f, at, msg, align, width, size, color)


## Filete ornamental dorado con rombo central.
func _ornament_line(center: Vector2, half: float) -> void:
    var gold := Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.8)
    _hgradient(Rect2(center.x - half, center.y, half - 8.0, 1), Color(gold.r, gold.g, gold.b, 0.0), gold)
    _hgradient(Rect2(center.x + 8.0, center.y, half - 8.0, 1), gold, Color(gold.r, gold.g, gold.b, 0.0))
    draw_colored_polygon(PackedVector2Array([center + Vector2(0, -4), center + Vector2(4, 0), center + Vector2(0, 4), center + Vector2(-4, 0)]), gold)
    draw_circle(center, 1.5, Color("#2a1d22"))


func _death_vignette() -> void:
    var k: float = clampf(death_fx / 1.2, 0.0, 1.0) if death_fx >= 0.0 else 1.0
    for i in range(6):
        var g: float = float(i) * 18.0
        draw_rect(Rect2(g, g, W - g * 2.0, H - g * 2.0), Color(0.45, 0.02, 0.06, 0.07 * k), false, 18.0)


func _setup_post() -> void:
    var shader: Shader = load("res://shaders/postproceso.gdshader")
    if shader == null:
        return
    var layer := CanvasLayer.new()
    layer.layer = 4
    add_child(layer)
    post_rect = ColorRect.new()
    post_rect.size = Vector2(W, H)
    post_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var mat := ShaderMaterial.new()
    mat.shader = shader
    post_rect.material = mat
    layer.add_child(post_rect)


func _init_motes() -> void:
    motes.clear()
    for i in range(46):
        motes.append({"p": Vector2(randf_range(70, 890), randf_range(160, 550)), "v": Vector2(randf_range(-6, 6), randf_range(-9, -2)),
            "s": 1.0 if randf() < 0.7 else 2.0, "f": randf_range(0.8, 2.6), "ph": randf_range(0.0, 2.0)})


func _emit(at: Vector2, count: int, col: Color, speed_min: float, speed_max: float, life: float, size: float,
        gravity: float = 0.0, dir: Vector2 = Vector2.ZERO, spread: float = PI, glow: bool = false) -> void:
    if fx_parts.size() > 420:
        return
    var base_angle: float = dir.angle() if dir.length() > 0.01 else 0.0
    var cone: float = spread if dir.length() > 0.01 else PI
    for i in range(count):
        var a: float = base_angle + randf_range(-cone, cone)
        var l: float = life * randf_range(0.6, 1.0)
        fx_parts.append({"p": at + Vector2(randf_range(-3, 3), randf_range(-3, 3)), "v": Vector2.from_angle(a) * randf_range(speed_min, speed_max),
            "life": l, "max": l, "size": size * randf_range(0.6, 1.0), "col": col, "grav": gravity, "glow": glow})


func _update_fx(delta: float) -> void:
    fade_t = maxf(0.0, fade_t - delta)
    respawn_fx = maxf(0.0, respawn_fx - delta)
    _update_transition(delta)
    if death_fx >= 0.0:
        death_fx += delta
        if game_mode != "dead":
            death_fx = -1.0
    for m in motes:
        var p: Vector2 = m["p"] + (m["v"] as Vector2) * delta + Vector2(sin(elapsed * 0.7 + float(m["ph"]) * 3.0) * 4.0 * delta, 0)
        if p.y < 150.0:
            p = Vector2(randf_range(70, 890), 555.0)
        if p.x < 60.0:
            p.x = 895.0
        elif p.x > 900.0:
            p.x = 65.0
        m["p"] = p
    if dash_left > 0.0 and game_mode == "play":
        _emit(player_pos + Vector2(0, -20), 1, Color(0.56, 0.78, 0.84, 0.5), 5.0, 20.0, 0.35, 2.0, 0.0, Vector2.ZERO, PI, true)
    for i in range(fx_parts.size() - 1, -1, -1):
        var q: Dictionary = fx_parts[i]
        q["life"] = float(q["life"]) - delta
        if float(q["life"]) <= 0.0:
            fx_parts.remove_at(i)
            continue
        var v: Vector2 = q["v"]
        v.y += float(q["grav"]) * delta
        v *= 1.0 - 1.8 * delta
        q["v"] = v
        q["p"] = Vector2(q["p"]) + v * delta
    if post_rect != null:
        var mat := post_rect.material as ShaderMaterial
        var in_room: bool = game_mode in ["play", "dialog", "dead", "floor_intro", "victory", "floor_summary"]
        mat.set_shader_parameter("strength", 1.0 if in_room else 0.0)
        mat.set_shader_parameter("bloom", 0.0 if touch_enabled else 0.65)
        mat.set_shader_parameter("time", fmod(elapsed, 100.0))
        mat.set_shader_parameter("vignette", 0.5 + fear / 100.0 * 0.3)


func _draw_fx() -> void:
    for q in fx_parts:
        var k: float = float(q["life"]) / float(q["max"])
        var col: Color = q["col"]
        var a: float = col.a * clampf(k * 1.6, 0.0, 1.0)
        var sz: float = maxf(1.0, roundf(float(q["size"])))
        var p: Vector2 = Vector2(q["p"]).round()
        if bool(q["glow"]):
            draw_circle(p, sz * 2.6, Color(col.r, col.g, col.b, a * 0.18))
        draw_rect(Rect2(p - Vector2(sz, sz) * 0.5, Vector2(sz, sz)), Color(col.r, col.g, col.b, a))
    if respawn_fx > 0.0:
        # Reencarnación: columna de luz espiritual donde vuelves a levantarte.
        var k2: float = respawn_fx / 1.4
        var c: Vector2 = player_pos
        _vgradient(Rect2(c.x - 18.0 * k2, ARENA.position.y, 36.0 * k2, c.y - ARENA.position.y), Color(0.56, 0.86, 0.95, 0.0), Color(0.56, 0.86, 0.95, 0.35 * k2))
        _draw_ellipse(c + Vector2(0, 2), 30.0 * (1.2 - k2 * 0.4), 9.0, Color(0.7, 0.92, 1.0, 0.3 * k2))


## Haces de luz desde los ventanales altos (más tenues en pisos gastados).
func _draw_light_rays() -> void:
    var wear: float = float(_floor().get("wear", 0.0))
    var base: float = 0.09 * (1.0 - wear * 0.3)
    for i in range(3):
        var x: float = 250.0 + float(i) * 230.0
        var breath: float = 0.75 + 0.25 * sin(elapsed * 0.35 + float(i) * 1.7)
        var a: float = base * breath
        var top_l := Vector2(x, ARENA.position.y + 4.0)
        var top_r := Vector2(x + 34.0, ARENA.position.y + 4.0)
        var bot_r := Vector2(x + 210.0, ARENA.end.y - 30.0)
        var bot_l := Vector2(x + 70.0, ARENA.end.y - 30.0)
        draw_polygon(PackedVector2Array([top_l, top_r, bot_r, bot_l]),
            PackedColorArray([Color(1.0, 0.9, 0.7, a), Color(1.0, 0.9, 0.7, a), Color(1.0, 0.9, 0.7, 0.0), Color(1.0, 0.9, 0.7, 0.0)]))
        # Polvo que brilla al cruzar el haz.
        for d in range(7):
            var t: float = fmod(elapsed * 0.05 + float(d) * 0.143 + float(i) * 0.31, 1.0)
            var across: float = 0.5 + 0.4 * sin(elapsed * 0.6 + float(d) * 2.1)
            var pos: Vector2 = top_l.lerp(bot_l, t).lerp(top_r.lerp(bot_r, t), across)
            draw_rect(Rect2(pos.round(), Vector2(1, 1)), Color(1.0, 0.92, 0.75, 0.55 * (1.0 - t) * breath))


## Niebla baja que se desliza (dos capas a distinta velocidad), recortada a la sala.
func _draw_fog() -> void:
    var tint := Color(0.62, 0.55, 0.75)
    for layer in range(2):
        var speed: float = 9.0 if layer == 0 else -5.5
        var y: float = ARENA.end.y - 150.0 - float(layer) * 70.0
        var alpha: float = 0.2 if layer == 0 else 0.13
        var off: float = fmod(elapsed * speed, 256.0)
        if off > 0.0:
            off -= 256.0
        var x: float = ARENA.position.x + off
        while x < ARENA.end.x:
            var x0: float = maxf(x, ARENA.position.x)
            var x1: float = minf(x + 256.0, ARENA.end.x)
            if x1 > x0:
                var src := Rect2(x0 - x, 0, x1 - x0, 128)
                draw_texture_rect_region(FOG_TEX, Rect2(x0, y, x1 - x0, 150), src, Color(tint.r, tint.g, tint.b, alpha))
            x += 256.0


func _draw_room_fade() -> void:
    if fade_t <= 0.0:
        return
    var k: float = fade_t / FADE_TIME
    draw_rect(ARENA, Color(0.01, 0.005, 0.015, k * k))


# --- Menú de pisos -------------------------------------------------------------
## Los diez pisos del diseño: los jugables vienen de FLOORS; el resto, en camino.
const FLOOR_PLAN := [
    ["I", "EL DESPERTAR"], ["II", "LOS PEREGRINOS"], ["III", "LA CACERÍA"], ["IV", "EL CLAUSTRO ENRAIZADO"],
    ["V", "EL LABERINTO DE LOS MASTINES"], ["VI", "LA OFRENDA"], ["VII", "LA QUE NO APARTA LA VISTA"],
    ["VIII", "LAS SALAS QUE CAMBIAN"], ["IX", "EL COLOSO DEL PÓRTICO"], ["X", "LA COSECHA"],
]


func _floors_unlocked() -> int:
    var top: int = max_floor
    for i in range(FLOORS.size()):
        var eco: String = str(FLOORS[i].get("eco", ""))
        if eco != "" and ecos.has(eco):
            top = maxi(top, i + 1)
    return mini(top, FLOORS.size() - 1)


func _floor_card(i: int) -> Rect2:
    return Rect2(104.0 + float(i % 5) * 152.0, 150.0 + float(i / 5) * 178.0, 144.0, 168.0)


func _open_floors() -> void:
    game_mode = "floors"
    floors_sel = mini(current_floor, _floors_unlocked())
    _sfx("interfaz", -8.0, 0.9)


func _floors_key(k: int) -> void:
    if k == KEY_ESCAPE:
        game_mode = "title"
        _sfx("interfaz", -10.0, 0.8)
    elif k in [KEY_RIGHT, KEY_D]:
        floors_sel = (floors_sel + 1) % FLOOR_PLAN.size()
    elif k in [KEY_LEFT, KEY_A]:
        floors_sel = (floors_sel + FLOOR_PLAN.size() - 1) % FLOOR_PLAN.size()
    elif k in [KEY_DOWN, KEY_S, KEY_UP, KEY_W]:
        floors_sel = (floors_sel + 5) % FLOOR_PLAN.size()
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_E, KEY_SPACE]:
        _choose_floor(floors_sel)


func _floors_tap(at: Vector2) -> void:
    for i in range(FLOOR_PLAN.size()):
        if _floor_card(i).has_point(at):
            if floors_sel == i:
                _choose_floor(i)
            else:
                floors_sel = i
                _sfx("toque", -14.0, 1.0)
            return
    if Rect2(104, 516, 180, 40).has_point(at):
        game_mode = "title"
    elif Rect2(676, 516, 180, 40).has_point(at):
        _choose_floor(floors_sel)


func _choose_floor(i: int) -> void:
    if i >= FLOORS.size():
        _say("Este piso todavía se está construyendo en las profundidades.", 2.6)
        _sfx("toque", -10.0)
        return
    if i > _floors_unlocked():
        _say("Aún no has llegado tan abajo. Supera el piso anterior.", 2.6)
        _sfx("toque", -10.0)
        return
    if player_name == "" or i == 0:
        if i == 0:
            _start_explore()
        else:
            _start_creation("piso:%d" % i)
        return
    _start_floor(i)


## Empieza una partida directamente en un piso ya alcanzado, con el equipo
## básico que se habría conseguido antes (antorcha y fósforos).
func _start_floor(i: int) -> void:
    if i <= 0:
        _start_explore()
        return
    _new_run()
    current_floor = i
    current_room = 0
    has_wood = true
    has_torch = true
    matches = MATCHES_FIRST_BOX
    floor_intro_eco = ""
    _on_floor_start()
    game_mode = "floor_intro"
    _enter_room()
    _sfx("puerta", -4.0, 0.7)
    _transition("espiral", false, 1.0)


func _draw_floors() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0.012, 0.01, 0.02, 0.8))
    var panel := Rect2(80, 64, 800, 508)
    _panel(panel, Color(0.035, 0.03, 0.045, 0.95), UI_GOLD)
    _title_text("Los Pisos", Vector2(80, 112), 48, CREAM, panel.size.x)
    _ornament_line(Vector2(480, 130), 220.0)
    var unlocked: int = _floors_unlocked()
    for i in range(FLOOR_PLAN.size()):
        var card: Rect2 = _floor_card(i)
        var playable: bool = i < FLOORS.size()
        var open: bool = playable and i <= unlocked
        var sel: bool = floors_sel == i
        var fill := Color("#1c1428") if sel else Color("#0f0c15")
        var edge: Color = UI_GOLD if sel else (Color("#6a4a8a") if open else UI_EDGE)
        _panel(card, Color(fill.r, fill.g, fill.b, 0.95), edge)
        if sel:
            draw_rect(card.grow(3.0), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.25 + 0.15 * sin(elapsed * 4.0)), false, 2.0)
        var tone: Color = CREAM if open else Color("#5d5865")
        _title_text(FLOOR_PLAN[i][0], Vector2(card.position.x, card.position.y + 52.0), 48, UI_GOLD if open else Color("#4a4452"), card.size.x)
        # Sin pistas: lo que no has alcanzado no tiene nombre todavía.
        draw_multiline_string(font, Vector2(card.position.x + 10.0, card.position.y + 82.0), _tc(FLOOR_PLAN[i][1]) if open else "???", HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 20.0, 13, 3, tone)
        var status: String
        var status_col: Color
        if not playable:
            status = "EN LAS PROFUNDIDADES"
            status_col = Color("#5d5865")
        elif not open:
            status = "SIN ALCANZAR"
            status_col = Color("#8a5a64")
        else:
            var eco: String = str(FLOORS[i].get("eco", ""))
            status = "SUPERADO" if eco != "" and ecos.has(eco) else "DISPONIBLE"
            status_col = SOUL if status == "SUPERADO" else Color("#9fd8b0")
        _text_outline(status, Vector2(card.position.x, card.end.y - 14.0), 10, status_col, card.size.x)
        if open and str(FLOORS[i].get("eco", "")) != "" and ecos.has(str(FLOORS[i]["eco"])):
            var ek: String = "eco_" + str(FLOORS[i]["eco"])
            if ICONS.has(ek):
                draw_texture_rect(ICONS[ek], Rect2(card.get_center() + Vector2(-16, 26), Vector2(32, 32)), false, Color.WHITE if open else Color(0.2, 0.2, 0.24, 0.8))
        elif open and bool(FLOORS[i].get("final", false)) and ICONS.has("calavera"):
            draw_texture_rect(ICONS["calavera"], Rect2(card.get_center() + Vector2(-16, 26), Vector2(32, 32)), false, Color(1.0, 0.75, 0.6) if open else Color(0.2, 0.2, 0.24, 0.8))
        if not open:
            draw_texture_rect(ICONS["calavera"], Rect2(card.position + Vector2(card.size.x - 26.0, 8.0), Vector2(18, 18)), false, Color(1, 1, 1, 0.35))
    var playable_sel: bool = floors_sel < FLOORS.size() and floors_sel <= unlocked
    _ui_button(Rect2(104, 516, 180, 40), "« VOLVER")
    _ui_button(Rect2(676, 516, 180, 40), "DESCENDER »" if playable_sel else "BLOQUEADO", playable_sel)
    _text_outline(_hint("Flechas elegir · ENTER descender · ESC volver", "Toca un piso y luego DESCENDER", "Cruceta elegir · A descender · B volver"), Vector2(80, 541), 12, Color("#8a8574"), panel.size.x)
    if toast_left > 0.0:
        _draw_toast()


# ------------------------------------------------------------ DEL PRIMER JUEGO (etapa 3)
## Lo que se aprovecha de «Craving Candy», el primer juego del autor:
## alimañas que patrullan y mueren de un esquive, nidos que las reponen,
## el cuerpo que queda al morir, transiciones con máscara, resumen al
## terminar el piso, cursor propio y controles táctiles de Kenney.
const ALIMANA_TEX := preload("res://assets/visual/enemies/alimana.png")
const CURSOR_TEX := preload("res://assets/visual/cursor.png")
const JOY_BASE_TEX := preload("res://assets/visual/controles/joystick_base.png")
const BUTTON_TEX := preload("res://assets/visual/controles/boton.png")
const TRANSITION_MASKS := {
    "nubes": preload("res://assets/visual/fx/transicion_nubes.png"),
    "radial": preload("res://assets/visual/fx/transicion_radial.png"),
    "espiral": preload("res://assets/visual/fx/transicion_espiral.png"),
    "barrido": preload("res://assets/visual/fx/transicion_barrido.png"),
}
## Alimañas por sala ("piso:sala"): trayectos de patrulla y si hay nido.
const CRITTER_SPOTS := {
    "0:4": {"paths": [[Vector2(150, 530), Vector2(810, 530)], [Vector2(560, 190), Vector2(840, 190)]], "nest": false},
    "1:1": {"paths": [[Vector2(110, 440), Vector2(390, 440)], [Vector2(560, 440), Vector2(850, 440)]], "nest": true},
    "1:3": {"paths": [[Vector2(120, 455), Vector2(840, 455)], [Vector2(270, 190), Vector2(690, 190)]], "nest": true},
    "2:0": {"paths": [[Vector2(120, 425), Vector2(840, 425)], [Vector2(120, 530), Vector2(840, 530)]], "nest": false},
}
const CRITTER_SPEED := 62.0
const CRITTER_CHASE := 92.0
const CRITTER_BITE := 6.0
const CRITTER_RESPAWN := 9.0
## Verdad que revela cada piso (del diseño de los diez pisos).
const FLOOR_TRUTHS = Pisos.FLOOR_TRUTHS
var critters: Array = [] # {pos, a, b, to_b, alive, dead_t, respawn, flip, bite_cd}
var life_corpse: Dictionary = {}
var door_state: String = "unknown" # unknown | locked | open
var floor_t0: int = 0
var floor_souls0: int = 0
var floor_deaths: int = 0
var floor_critters: int = 0
var summary: Dictionary = {}
var trans_rect: ColorRect = null
var trans_t: float = 0.0
var trans_len: float = 0.0


# --- Alimañas ---------------------------------------------------------------
func _load_critters() -> void:
    critters.clear()
    if in_tutorial or not CRITTER_SPOTS.has(_room_key()):
        return
    var spot: Dictionary = CRITTER_SPOTS[_room_key()]
    for path in spot["paths"]:
        critters.append({"pos": path[0] + (path[1] - path[0]) * randf_range(0.1, 0.9), "a": path[0], "b": path[1], "to_b": randf() < 0.5,
            "alive": true, "dead_t": 0.0, "respawn": bool(spot["nest"]), "flip": false, "bite_cd": 0.0})


func _update_critters(dt: float) -> void:
    for cr in critters:
        if not bool(cr["alive"]):
            cr["dead_t"] = float(cr["dead_t"]) + dt
            if bool(cr["respawn"]) and float(cr["dead_t"]) > CRITTER_RESPAWN and player_pos.distance_to(cr["a"]) > 160.0:
                cr["alive"] = true # el nido repone la alimaña
                cr["dead_t"] = 0.0
                cr["pos"] = cr["a"]
                cr["to_b"] = true
            continue
        cr["bite_cd"] = maxf(0.0, float(cr["bite_cd"]) - dt)
        var pos: Vector2 = cr["pos"]
        var d: float = pos.distance_to(player_pos)
        var target: Vector2
        var speed: float = CRITTER_SPEED
        if d < 95.0:
            target = player_pos # huele la sangre y se lanza
            speed = CRITTER_CHASE
        else:
            target = cr["b"] if bool(cr["to_b"]) else cr["a"]
            if pos.distance_to(target) < 6.0:
                cr["to_b"] = not bool(cr["to_b"]) # al llegar, da media vuelta
        var nxt: Vector2 = pos.move_toward(target, speed * dt)
        if not _is_blocked(nxt) or d >= 95.0:
            if absf(nxt.x - pos.x) > 0.01:
                cr["flip"] = nxt.x < pos.x
            cr["pos"] = nxt
        # Contacto: esquivando la aplastas; si no, muerde.
        if d < 20.0:
            if dash_left > 0.0:
                _critter_die(cr)
            elif float(cr["bite_cd"]) <= 0.0 and damage_cd <= 0.0:
                cr["bite_cd"] = 1.0
                hp -= CRITTER_BITE
                damage_cd = 0.6
                fear = minf(100.0, fear + 4.0)
                _on_hurt()


func _critter_die(cr: Dictionary) -> void:
    if not bool(cr["alive"]):
        return
    cr["alive"] = false
    cr["dead_t"] = 0.0
    souls += 1
    souls_flash = 0.4
    floor_critters += 1
    _gain_xp(XP_CRITTER)
    var at: Vector2 = cr["pos"]
    _emit(at + Vector2(0, -6), 10, Color(0.55, 0.06, 0.1), 30.0, 110.0, 0.6, 2.0, 260.0, Vector2.UP, 1.4)
    _emit(at + Vector2(0, -10), 6, Color(0.56, 0.86, 0.95), 10.0, 40.0, 0.9, 2.0, -40.0, Vector2.UP, 0.8, true)
    float_fx.append({"pos": at + Vector2(0, -30), "text": "+1", "color": SOUL, "t": 0.0})
    _sfx("k_cuerpo", -12.0, 1.5)
    _sfx("toque", -10.0, 2.2)


func _draw_critter(i: int) -> void:
    var cr: Dictionary = critters[i]
    var at: Vector2 = Vector2(cr["pos"]).round()
    var region: Rect2
    if bool(cr["alive"]):
        var frame: int = int(elapsed * 10.0 + float(i) * 1.3) % 4
        region = Rect2(float(frame) * 24.0, 0, 24, 16)
    else:
        var df: int = mini(3, int(float(cr["dead_t"]) * 8.0))
        region = Rect2(float(df) * 24.0, 16, 24, 16)
    _draw_soft_shadow(at + Vector2(0, 2), 10.0)
    if bool(cr["flip"]):
        draw_set_transform(Vector2(at.x, 0), 0.0, Vector2(-1, 1))
        draw_texture_rect_region(ALIMANA_TEX, Rect2(-24.0, at.y - 28.0, 48, 32), region)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    else:
        draw_texture_rect_region(ALIMANA_TEX, Rect2(at.x - 24.0, at.y - 28.0, 48, 32), region)


# --- El cuerpo de tu vida anterior -------------------------------------------
func _draw_life_corpse() -> void:
    if life_corpse.is_empty() or str(life_corpse["key"]) != _room_key():
        return
    var at: Vector2 = life_corpse["pos"]
    # Charco de sangre y tu propio cuerpo tendido (tu hoja de sprites, girada).
    _draw_ellipse(at + Vector2(4, 2), 30.0, 10.0, Color(0.32, 0.02, 0.05, 0.85))
    _draw_ellipse(at + Vector2(-6, 4), 18.0, 6.0, Color(0.45, 0.03, 0.07, 0.8))
    draw_set_transform(at + Vector2(-4, -2), PI * 0.5, Vector2.ONE)
    draw_texture_rect_region(_hero_sheet(), Rect2(-28, -20, 40, 56), Rect2(0, 0, 40, 56), Color(0.55, 0.5, 0.55, 1.0))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
    if not bool(life_corpse["claimed"]):
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 3.0)
        draw_circle(at + Vector2(0, -6), 5.0 + pulse * 2.0, Color(0.56, 0.86, 0.95, 0.25 + 0.25 * pulse))


func _update_life_corpse() -> void:
    if life_corpse.is_empty() or bool(life_corpse["claimed"]) or str(life_corpse["key"]) != _room_key():
        return
    if player_pos.distance_to(life_corpse["pos"]) > 28.0 or damage_cd > 0.9:
        return
    life_corpse["claimed"] = true
    var back: int = maxi(2, int(life_corpse["souls"]))
    souls += back
    souls_flash = 0.8
    _emit(Vector2(life_corpse["pos"]) + Vector2(0, -10), 20, Color(0.56, 0.86, 0.95), 10.0, 50.0, 1.2, 2.0, -40.0, Vector2.UP, 1.0, true)
    _sfx("k_vidrio", -10.0, 0.8)
    _dialog([[_hero_name(), "Este cuerpo era yo, hace una vida. Aún guarda algo: +%d almas." % back]])


# --- Puerta que se abre: estallido y campana ----------------------------------
func _update_door_celebration() -> void:
    var ready_now: bool = _room_ready()
    if door_state == "unknown":
        door_state = "open" if ready_now else "locked"
    elif door_state == "locked" and ready_now:
        door_state = "open"
        _emit(door_pos + Vector2(0, -30), 34, Color(0.95, 0.82, 0.5), 30.0, 140.0, 1.2, 2.0, -30.0, Vector2.UP, 1.3, true)
        _emit(door_pos + Vector2(0, -30), 18, Color(0.56, 0.86, 0.95), 20.0, 80.0, 1.4, 2.0, -50.0, Vector2.UP, 1.0, true)
        _sfx("k_campana", -9.0, 1.0)
        _say("La puerta se abre.", 2.0)


# --- Contador de almas de la sala --------------------------------------------
func _draw_room_souls_counter() -> void:
    if game_mode != "play" or relics.is_empty():
        return
    var got: int = 0
    for c in collected:
        if c:
            got += 1
    var box := Rect2(ARENA.end.x - 150.0, ARENA.position.y + 6.0, 142.0, 24.0)
    _panel(box, Color(0.035, 0.03, 0.045, 0.7), UI_EDGE)
    draw_texture_rect(ICONS["alma"], Rect2(box.position + Vector2(6, 2), Vector2(20, 20)), false)
    _text_outline("SALA %d/%d" % [got, relics.size()], Vector2(box.position.x + 30.0, box.position.y + 17.0), 12, SOUL if got == relics.size() else CREAM)


# --- Resumen del piso -------------------------------------------------------------
func _open_floor_summary(eco: String) -> void:
    var done: int = 0
    var total: int = 0
    var rooms: Array = _floor()["rooms"]
    for r in range(rooms.size()):
        if (rooms[r] as Dictionary).has("mission"):
            total += 1
            if missions_done.has("%d:%d" % [current_floor, r]):
                done += 1
    var secs: int = int((Time.get_ticks_msec() - floor_t0) / 1000)
    summary = {"floor": _floor()["number"], "title": _floor()["title"], "time": "%d:%02d" % [secs / 60, secs % 60],
        "souls": souls - floor_souls0, "deaths": floor_deaths, "missions": "%d / %d" % [done, total] if total > 0 else "—",
        "critters": floor_critters, "allies": ("%d / 3" % _allies_alive()) if _floor_has_trait("aliados") else (("%d / %d" % [_allies_alive(), allies.size()]) if guiding and not allies.is_empty() else "—"),
        "eco": eco, "truth": FLOOR_TRUTHS[current_floor] if current_floor < FLOOR_TRUTHS.size() else ""}
    game_mode = "floor_summary"
    _sfx("k_campana", -8.0, 0.9)
    _transition("barrido", false, 0.7)


func _draw_floor_summary() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0.012, 0.01, 0.02, 0.82))
    var panel := Rect2(170, 70, 620, 500)
    _panel(panel, Color(0.035, 0.03, 0.045, 0.96), UI_GOLD)
    _title_text("Piso %s superado" % summary.get("floor", ""), Vector2(170, 124), 48, CREAM, panel.size.x)
    _text_outline(_tc(str(summary.get("title", ""))), Vector2(170, 150), 15, UI_GOLD, panel.size.x)
    _ornament_line(Vector2(480, 166), 200.0)
    var rows := [["Tiempo", summary.get("time", "")], ["Almas ganadas", "%+d" % int(summary.get("souls", 0))],
        ["Muertes", str(summary.get("deaths", 0))], ["Misiones", str(summary.get("missions", ""))],
        ["Alimañas aplastadas", str(summary.get("critters", 0))], ["Aliados con vida", str(summary.get("allies", ""))]]
    for i in range(rows.size()):
        var y: float = 200.0 + float(i) * 34.0
        _text_outline(rows[i][0], Vector2(230, y), 15, Color("#b9b29b"))
        _text_outline(str(rows[i][1]), Vector2(520, y), 15, CREAM, 210.0)
        draw_rect(Rect2(230, y + 9.0, 500, 1), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.15))
    var eco: String = str(summary.get("eco", ""))
    if eco != "" and ECOS.has(eco):
        draw_texture_rect(ICONS["eco_" + eco], Rect2(230, 408, 32, 32), false)
        _text_outline("ECO DESPERTADO · " + ECOS[eco][0], Vector2(272, 422), 14, SOUL)
        _text_outline(ECOS[eco][1], Vector2(272, 440), 11, Color("#9a957f"))
    if str(summary.get("truth", "")) != "":
        _text_outline("VERDAD REVELADA", Vector2(230, 476), 11, UI_GOLD)
        draw_multiline_string(font, Vector2(230, 496), "«%s»" % summary["truth"], HORIZONTAL_ALIGNMENT_LEFT, 500.0, 15, 2, CREAM)
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 4.0)
    _text_outline(_hint("ENTER / clic: seguir descendiendo", "Toca para seguir descendiendo", "A: seguir descendiendo"), Vector2(170, 552), 13, Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.5 + 0.5 * pulse), panel.size.x)


# --- Transiciones con máscara -----------------------------------------------------
func _setup_transition() -> void:
    var shader: Shader = load("res://shaders/transicion.gdshader")
    if shader == null:
        return
    var layer := CanvasLayer.new()
    layer.layer = 6
    add_child(layer)
    trans_rect = ColorRect.new()
    trans_rect.size = Vector2(W, H)
    trans_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    trans_rect.visible = false
    var mat := ShaderMaterial.new()
    mat.shader = shader
    trans_rect.material = mat
    layer.add_child(trans_rect)


## Revela la pantalla nueva a través de una máscara: el cambio de estado ya
## ocurrió; esto solo lo destapa (así la lógica y las pruebas no esperan).
func _transition(mask: String, invert: bool, duration: float) -> void:
    if trans_rect == null or not TRANSITION_MASKS.has(mask):
        return
    var mat := trans_rect.material as ShaderMaterial
    mat.set_shader_parameter("mask", TRANSITION_MASKS[mask])
    mat.set_shader_parameter("invert", invert)
    mat.set_shader_parameter("cover", 1.0)
    trans_t = duration
    trans_len = duration
    trans_rect.visible = true


func _update_transition(delta: float) -> void:
    if trans_rect == null or not trans_rect.visible:
        return
    trans_t = maxf(0.0, trans_t - delta)
    var k: float = trans_t / maxf(0.01, trans_len)
    (trans_rect.material as ShaderMaterial).set_shader_parameter("cover", k * k * (3.0 - 2.0 * k))
    if trans_t <= 0.0:
        trans_rect.visible = false


# --- Cursor, chispa al hacer clic y pantalla completa ------------------------------
func _setup_cursor() -> void:
    if DisplayServer.get_name() == "headless":
        return
    Input.set_custom_mouse_cursor(CURSOR_TEX, Input.CURSOR_ARROW, Vector2(1, 1))


func _click_spark(at: Vector2) -> void:
    if touch_enabled:
        return
    _emit(at, 6, Color(0.95, 0.82, 0.5), 20.0, 70.0, 0.35, 2.0, 0.0, Vector2.ZERO, PI, true)


func _apply_window_mode() -> void:
    if DisplayServer.get_name() == "headless" or OS.has_feature("mobile") or OS.has_feature("web"):
        return
    var want: bool = bool(Ajustes.obtener("pantalla_completa"))
    var mode: int = DisplayServer.WINDOW_MODE_FULLSCREEN if want else DisplayServer.WINDOW_MODE_WINDOWED
    if DisplayServer.window_get_mode() != mode:
        DisplayServer.window_set_mode(mode)


## Ojos rojos que brillan en la penumbra: se ve venir a las alimañas.
func _draw_critter_eyes() -> void:
    for i in range(critters.size()):
        var cr: Dictionary = critters[i]
        if not bool(cr["alive"]):
            continue
        var at: Vector2 = Vector2(cr["pos"]).round()
        var eye: Vector2 = at + Vector2(-12.0 if bool(cr["flip"]) else 12.0, -12.0)
        var blink: float = 0.0 if int(elapsed * 1.3 + float(i) * 0.7) % 5 == 0 and fmod(elapsed * 1.3, 1.0) < 0.12 else 1.0
        draw_circle(eye, 5.0, Color(1.0, 0.15, 0.15, 0.12 * blink))
        draw_rect(Rect2(eye - Vector2(1, 1), Vector2(2, 2)), Color(1.0, 0.3, 0.3, 0.9 * blink))


func _save_path() -> String:
    return SAVE_PATH_TEST if Engine.has_meta("modo_prueba") else SAVE_PATH


# ------------------------------------------------------------ SALTAR Y VOLVER A LA PAUSA
## Botón para saltar diálogos y la intro (además de ESC); se puede tocar.
const SKIP_BTN := Rect2(690, 390, 160, 34) # sobre el cuadro de diálogo
const INTRO_SKIP_BTN := Rect2(780, 596, 160, 34)
## Adónde vuelven el perfil y las habilidades al cerrarse: al juego si se
## abrieron jugando, a la pausa si se abrieron desde la pausa.
var overlay_return: String = "play"


func _skip_button(rect: Rect2) -> void:
    var hot: bool = rect.has_point(ui_hover)
    _panel(rect, Color("#2a1d22") if hot else Color(0.04, 0.035, 0.05, 0.9), UI_GOLD if hot else UI_LIGHT)
    _text_outline("SALTAR (ESC)  »»", Vector2(rect.position.x, rect.position.y + 22.0), 13, CREAM if hot else Color("#b9b29b"), rect.size.x)



# ------------------------------------------------------------ PISO IV · EL CLAUSTRO ENRAIZADO
## Enredaderas que arden: un golpe de antorcha prende las secas (gasta un
## fósforo, salvo con Llama Interior) y el fuego salta a las vecinas. Lo que
## pisa una celda en llamas se quema, tú incluido (esquivando no). Las raíces
## vivas de la puerta solo arden si les llega el fuego. La Tejedora de Raíz
## apenas nota los golpes: hay que atraerla al fuego. Valores PROVISIONALES.
const VINE_CELL := 32.0
const FIRE_SPREAD := 0.3 # segundos hasta prender a las vecinas
const FIRE_BURN := 3.6 # segundos que arde una celda
const FIRE_DAMAGE := 9.0 # por toque al jugador (cada 0,45 s)
const VINE_REGROW := 14.0 # las secas vuelven a crecer (las raíces de la puerta, no)
const TEJE_SPEED := 66.0
const TEJE_REACH := 58.0
const TEJE_WINDUP := 0.65
const TEJE_DAMAGE := 22.0
var vines: Dictionary = {} # Vector2i -> {state: intacta|fuego|ceniza, t, verde, seed}
var fire_hit: bool = false
var fire_hint_t: float = 0.0
var teje_state: String = "anda" # anda | alza | zarpa
var teje_t: float = 0.0
var teje_burn: float = 0.0
var teje_fire_acc: float = 0.0
var teje_hint_t: float = 0.0
var teje_detour: Vector2 = Vector2.ZERO
var teje_detour_t: float = 0.0


func _cell_of(at: Vector2) -> Vector2i:
    return Vector2i(int(floor(at.x / VINE_CELL)), int(floor(at.y / VINE_CELL)))


func _cell_center(cell: Vector2i) -> Vector2:
    return Vector2((float(cell.x) + 0.5) * VINE_CELL, (float(cell.y) + 0.5) * VINE_CELL)


func _load_vines() -> void:
    vines.clear()
    teje_state = "anda"
    teje_burn = 0.0
    var n: int = 0
    for seg in _room().get("vines", []):
        var a: Vector2 = seg[0]
        var b: Vector2 = seg[1]
        var steps: int = maxi(1, int(a.distance_to(b) / 8.0))
        for i in range(steps + 1):
            var cell: Vector2i = _cell_of(a.lerp(b, float(i) / float(steps)))
            if not vines.has(cell):
                n += 1
                vines[cell] = {"state": "intacta", "t": 0.0, "verde": false, "seed": n * 7919}
    if _has("raices_puerta"):
        # Raíces vivas delante de la puerta.
        for dx in range(-2, 0):
            for dy in range(-3, 3):
                var cell: Vector2i = _cell_of(door_pos) + Vector2i(dx, dy)
                n += 1
                vines[cell] = {"state": "intacta", "t": 0.0, "verde": true, "seed": n * 7919}


func _door_roots_left() -> int:
    var left: int = 0
    for cell in vines:
        if bool(vines[cell]["verde"]) and str(vines[cell]["state"]) != "ceniza":
            left += 1
    return left


func _cell_burning(at: Vector2) -> bool:
    var cell: Vector2i = _cell_of(at)
    return vines.has(cell) and str(vines[cell]["state"]) == "fuego"


## Golpe de antorcha sobre una enredadera seca: la prende.
func _try_ignite(at: Vector2) -> void:
    var target: Variant = null
    for cell in [_cell_of(at), _cell_of(player_pos)]:
        if vines.has(cell) and str(vines[cell]["state"]) == "intacta":
            target = cell
            break
    if target == null:
        return
    if bool(vines[target]["verde"]):
        _say("Raíz viva: la antorcha no la prende.", 2.6)
        return
    if not has_inner_flame:
        if matches <= 0:
            _say("Sin fósforos no hay chispa para prender las raíces.", 2.4)
            return
        matches -= 1
    _ignite(target)
    _sfx("fuego", -5.0)
    if fire_hint_t <= 0.0:
        fire_hint_t = 30.0
        _say("Las raíces prenden. Cuidado: el fuego también te quema.", 3.0)


func _ignite(cell: Vector2i) -> void:
    vines[cell]["state"] = "fuego"
    vines[cell]["t"] = 0.0


func _update_fire(dt: float) -> void:
    fire_hint_t = maxf(0.0, fire_hint_t - dt)
    if vines.is_empty():
        return
    var to_light: Array = []
    for cell in vines:
        var v: Dictionary = vines[cell]
        if str(v["state"]) == "fuego":
            var before: float = float(v["t"])
            v["t"] = before + dt
            if before < FIRE_SPREAD and float(v["t"]) >= FIRE_SPREAD:
                for dx in range(-1, 2):
                    for dy in range(-1, 2):
                        var nb: Vector2i = cell + Vector2i(dx, dy)
                        if vines.has(nb) and str(vines[nb]["state"]) == "intacta":
                            to_light.append(nb)
            if float(v["t"]) >= FIRE_BURN:
                v["state"] = "ceniza"
                v["t"] = 0.0
            elif randf() < dt * 3.0:
                _emit(_cell_center(cell) + Vector2(randf_range(-10, 10), -10), 1, Color(1.0, 0.6, 0.2), 10.0, 40.0, 0.9, 2.0, -60.0, Vector2.UP, 0.5, true)
        elif str(v["state"]) == "ceniza":
            v["t"] = float(v["t"]) + dt
            if float(v["t"]) > VINE_REGROW and not bool(v["verde"]):
                v["state"] = "intacta" # las raíces secas vuelven a crecer
                v["t"] = 0.0
    var roots_before: int = _door_roots_left()
    for cell in to_light:
        _ignite(cell)
    if roots_before > 0 and not to_light.is_empty() and randf() < 0.3:
        _sfx("fuego", -12.0, 1.2)
    # Quemaduras: el jugador (no esquivando) y las alimañas.
    if _cell_burning(player_pos) and dash_left <= 0.0 and damage_cd <= 0.0:
        hp -= FIRE_DAMAGE
        fear = minf(100.0, fear + 5.0)
        damage_cd = 0.45
        _on_hurt()
    for cr in critters:
        if bool(cr["alive"]) and _cell_burning(cr["pos"]):
            _critter_die(cr)


func _draw_vines() -> void:
    for cell in vines:
        var v: Dictionary = vines[cell]
        var c: Vector2 = _cell_center(cell)
        var seed_v: int = int(v["seed"])
        match str(v["state"]):
            "intacta":
                # Tallos que se enlazan con las celdas vecinas, con espinas y hojas secas.
                var base: Color = Color("#3d5a2a") if bool(v["verde"]) else Color("#6b5236")
                var light: Color = Color("#5f8040") if bool(v["verde"]) else Color("#a88452")
                var thick: float = 4.0 if bool(v["verde"]) else 3.0
                var linked: bool = false
                for off in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(-1, 1)]:
                    var nb: Vector2i = cell + off
                    if vines.has(nb) and str(vines[nb]["state"]) == "intacta":
                        linked = true
                        var nc: Vector2 = _cell_center(nb)
                        var n: Vector2 = (nc - c).orthogonal().normalized()
                        for k in range(2):
                            var bend: float = (float((seed_v >> (k * 3)) % 9) - 4.0) * 1.4 + float(k) * 3.0 - 1.5
                            var m1: Vector2 = c.lerp(nc, 0.33) + n * bend
                            var m2: Vector2 = c.lerp(nc, 0.66) - n * bend
                            draw_polyline(PackedVector2Array([c + n * float(k * 3 - 1), m1, m2, nc + n * float(k * 3 - 1)]), base if k == 0 else light, thick if k == 0 else 1.0)
                if not linked:
                    draw_circle(c, 5.0, base)
                for k in range(3):
                    var t_pos: Vector2 = c + Vector2(float((seed_v >> k) % 24) - 12.0, float((seed_v >> (k + 3)) % 14) - 7.0)
                    if k == 0:
                        draw_line(t_pos, t_pos + Vector2(2, -3), light, 1.0) # espina
                    else:
                        draw_rect(Rect2(t_pos.round(), Vector2(3, 2)), Color("#7da04f") if bool(v["verde"]) else Color("#9a7434"))
            "fuego":
                draw_rect(Rect2(c - Vector2(15, 15), Vector2(30, 30)), Color(0.35, 0.08, 0.02, 0.6))
            "ceniza":
                var glow: float = clampf(1.0 - float(v["t"]) / 4.0, 0.0, 1.0)
                draw_rect(Rect2(c - Vector2(14, 12), Vector2(28, 24)), Color(0.08, 0.07, 0.07, 0.75))
                for k in range(3):
                    var e: Vector2 = c + Vector2(float((seed_v >> k) % 22) - 11.0, float((seed_v >> (k + 2)) % 18) - 9.0)
                    draw_rect(Rect2(e.round(), Vector2(2, 1)), Color(1.0, 0.45, 0.15, 0.2 + 0.7 * glow * (0.5 + 0.5 * sin(elapsed * 5.0 + float(k)))))


## Llamas: sobre la penumbra, con parpadeo; menguan al final de la quema.
func _draw_flames() -> void:
    for cell in vines:
        var v: Dictionary = vines[cell]
        if str(v["state"]) != "fuego":
            continue
        var c: Vector2 = _cell_center(cell) + Vector2(0, 8)
        var life: float = float(v["t"]) / FIRE_BURN
        var size: float = clampf(life * 6.0, 0.0, 1.0) * clampf((1.0 - life) * 3.0, 0.25, 1.0)
        for k in range(3):
            var x: float = c.x - 9.0 + float(k) * 9.0
            var flick: float = 0.75 + 0.25 * sin(elapsed * 17.0 + float(k) * 2.1 + float(v["seed"]))
            var h: float = (16.0 + 8.0 * float((int(v["seed"]) >> k) % 3)) * flick * size
            draw_colored_polygon(PackedVector2Array([Vector2(x - 6, c.y), Vector2(x + 6, c.y), Vector2(x, c.y - h)]), Color(1.0, 0.42, 0.12, 0.85))
            draw_colored_polygon(PackedVector2Array([Vector2(x - 3, c.y), Vector2(x + 3, c.y), Vector2(x, c.y - h * 0.6)]), Color(1.0, 0.85, 0.4, 0.9))
        draw_circle(c + Vector2(0, -8), 18.0 * size, Color(1.0, 0.5, 0.15, 0.10))


# --- Tejedora de Raíz -----------------------------------------------------------
func _update_tejedora(dt: float) -> void:
    enemy_alert = true
    teje_hint_t = maxf(0.0, teje_hint_t - dt)
    # Fuego: si pisa una celda en llamas, prende y sigue ardiendo un poco.
    if _cell_burning(enemy_pos):
        if teje_burn <= 0.0:
            _sfx("raices", -6.0, 1.3)
        teje_burn = 1.3
    if teje_burn > 0.0:
        teje_burn -= dt
        teje_fire_acc += dt
        if randf() < dt * 12.0:
            _emit(enemy_pos + Vector2(randf_range(-12, 12), randf_range(-60, -10)), 1, Color(1.0, 0.55, 0.15), 15.0, 50.0, 0.7, 3.0, -70.0, Vector2.UP, 0.6, true)
        if teje_fire_acc >= 0.25:
            teje_fire_acc = 0.0
            fire_hit = true
            _damage_enemy(11.0)
            fire_hit = false
            if not _enemy_active():
                return
    if enemy_stun > 0.0:
        teje_state = "anda"
        return
    var d: float = enemy_pos.distance_to(player_pos)
    match teje_state:
        "anda":
            var to_p: Vector2 = (player_pos - enemy_pos).normalized()
            var dir: Vector2 = to_p
            if teje_detour_t > 0.0:
                teje_detour_t -= dt
                dir = teje_detour # rodea la columna un momento
            var nxt: Vector2 = enemy_pos + dir * TEJE_SPEED * dt
            if not _is_blocked(nxt):
                enemy_pos = nxt
            else:
                # Choca: prueba a rodear por el lado que más la acerca a ti.
                var perp := Vector2(-to_p.y, to_p.x)
                var options: Array = [perp, -perp, -to_p] if perp.dot(player_pos - enemy_pos) >= 0.0 else [-perp, perp, -to_p]
                for cand in options:
                    var try_pos: Vector2 = enemy_pos + (cand as Vector2) * TEJE_SPEED * dt
                    if not _is_blocked(try_pos):
                        enemy_pos = try_pos
                        teje_detour = cand
                        teje_detour_t = 0.7
                        break
            if d < TEJE_REACH:
                teje_state = "alza"
                teje_t = TEJE_WINDUP
                _sfx("raices", -7.0)
        "alza":
            teje_t -= dt
            if teje_t <= 0.0:
                teje_state = "zarpa"
                teje_t = 0.35
                shake = maxf(shake, 0.25)
                if d < TEJE_REACH + 16.0 and dash_left <= 0.0 and damage_cd <= 0.0:
                    hp -= TEJE_DAMAGE * _depth_mult()
                    fear = minf(100.0, fear + 12.0)
                    damage_cd = 0.8
                    _on_hurt()
        "zarpa":
            teje_t -= dt
            if teje_t <= 0.0:
                teje_state = "anda"


func _draw_tejedora_fire() -> void:
    if _enemy_active() and _enemy_kind() == "tejedora" and teje_burn > 0.0:
        for k in range(4):
            var x: float = enemy_pos.x - 12.0 + float(k) * 8.0
            var h: float = 22.0 + 10.0 * sin(elapsed * 15.0 + float(k) * 1.7)
            var base: float = enemy_pos.y - 14.0 - float(k % 2) * 16.0
            draw_colored_polygon(PackedVector2Array([Vector2(x - 5, base), Vector2(x + 5, base), Vector2(x, base - h)]), Color(1.0, 0.45, 0.1, 0.8))


# ------------------------------------------------------------ PISO V · EL LABERINTO DE LOS MASTINES
## Mastines de Relicario: perros de bronce con máscara de porcelana. Son
## inmunes y no sienten dolor, pero temen al fuego: con la antorcha
## encendida no se acercan a menos de dos casillas; a oscuras, cargan y
## muerden. En este piso la antorcha se consume (25 s por fósforo). Un golpe
## de antorcha o la Resonancia los espanta. Valores PROVISIONALES.
const HOUND_SPEED := 70.0
const HOUND_CHARGE := 165.0
const HOUND_KEEP := 100.0 # distancia que guardan ante el fuego (≈ dos casillas)
const HOUND_SIGHT := 290.0
const HOUND_BITE := 20.0
const HOUND_TEX := preload("res://assets/visual/enemies/mastin.png")
var hounds: Array = [] # {pos, prev, home, wander, wander_t, flee, bite_cd, bite_t, facing, moving, growl_t, detour, detour_t}
var maze_walls: Array = []
var torch_fuel: float = 0.0
var has_mask: bool = false
var rescued: Array = [] # aliados salvados (para el Piso X)
var rescue_state: String = "" # "" | atrapado | libre


func _pulse_radius() -> float:
    return PULSE_RADIUS * (1.5 if has_mask else 1.0)


func _floor_has_trait_key(key: String) -> bool:
    for room in _floor()["rooms"]:
        if (room as Dictionary).has(key):
            return true
    return false


func _load_labyrinth() -> void:
    maze_walls.clear()
    for w in _room().get("walls", []):
        maze_walls.append(w)
        obstacles.append(w) # el laberinto bloquea el paso como cualquier columna
    hounds.clear()
    if in_tutorial:
        return
    for at in _room().get("hounds", []):
        hounds.append({"pos": at, "prev": at, "home": at, "wander": at, "wander_t": 0.0, "flee": 0.0, "bite_cd": 0.0,
            "bite_t": 0.0, "facing": 0, "moving": false, "growl_t": randf_range(1.0, 3.0), "detour": Vector2.ZERO, "detour_t": 0.0})
    if torch_on and float(_floor().get("fuel", 0.0)) > 0.0 and torch_fuel <= 0.0:
        torch_fuel = float(_floor()["fuel"])


## La antorcha se consume en los pisos con «fuel».
func _update_labyrinth(dt: float) -> void:
    _check_mask_pickup()
    var fuel_max: float = float(_floor().get("fuel", 0.0))
    if fuel_max <= 0.0 or not torch_on:
        return
    torch_fuel -= dt
    if torch_fuel <= 0.0:
        torch_on = false
        _sfx("apagar", -6.0)
        _say("La antorcha se ha consumido. Vuelve a encenderla (gasta un fósforo).", 3.0)


func _hound_move(h: Dictionary, dir: Vector2, speed: float, dt: float) -> void:
    if dir.length() < 0.01:
        return
    if float(h["detour_t"]) > 0.0:
        h["detour_t"] = float(h["detour_t"]) - dt
        dir = h["detour"]
    var pos: Vector2 = h["pos"]
    var nxt: Vector2 = pos + dir.normalized() * speed * dt
    if not _is_blocked(nxt):
        h["pos"] = nxt
        return
    var perp := Vector2(-dir.y, dir.x).normalized()
    for cand in [perp, -perp, -dir.normalized()]:
        var try_pos: Vector2 = pos + (cand as Vector2) * speed * dt
        if not _is_blocked(try_pos):
            h["pos"] = try_pos
            h["detour"] = cand
            h["detour_t"] = 0.6
            return


func _update_hounds(dt: float) -> void:
    for h in hounds:
        var pos: Vector2 = h["pos"]
        var d: float = pos.distance_to(player_pos)
        var away: Vector2 = (pos - player_pos).normalized() if d > 0.1 else Vector2.RIGHT
        h["bite_cd"] = maxf(0.0, float(h["bite_cd"]) - dt)
        h["bite_t"] = maxf(0.0, float(h["bite_t"]) - dt)
        if float(h["flee"]) > 0.0:
            h["flee"] = float(h["flee"]) - dt
            _hound_move(h, away, 150.0, dt)
        elif d < HOUND_SIGHT:
            if torch_on:
                # Temen al fuego: guardan distancia y rondan gruñendo.
                if d < HOUND_KEEP:
                    _hound_move(h, away, 120.0, dt)
                else:
                    _hound_move(h, Vector2(-away.y, away.x), 45.0, dt)
                h["growl_t"] = float(h["growl_t"]) - dt
                if float(h["growl_t"]) <= 0.0 and d < 180.0:
                    h["growl_t"] = randf_range(2.5, 4.5)
                    _sfx("grunido", -10.0, randf_range(0.9, 1.1))
            else:
                _hound_move(h, -away, HOUND_CHARGE, dt)
                if d < 26.0 and float(h["bite_cd"]) <= 0.0:
                    h["bite_cd"] = 1.2
                    h["bite_t"] = 0.25
                    h["flee"] = 0.5 # muerde y se aparta un instante
                    if dash_left <= 0.0 and damage_cd <= 0.0:
                        hp -= HOUND_BITE * _depth_mult()
                        fear = minf(100.0, fear + 14.0)
                        damage_cd = 0.8
                        _on_hurt()
                        _sfx("grunido", -4.0, 1.3)
        else:
            h["wander_t"] = float(h["wander_t"]) - dt
            if float(h["wander_t"]) <= 0.0:
                h["wander_t"] = randf_range(1.5, 3.0)
                h["wander"] = Vector2(h["home"]) + Vector2(randf_range(-70, 70), randf_range(-50, 50))
            if pos.distance_to(h["wander"]) > 6.0:
                _hound_move(h, Vector2(h["wander"]) - pos, HOUND_SPEED, dt)
        var moved: Vector2 = Vector2(h["pos"]) - Vector2(h["prev"])
        h["moving"] = moved.length() > 5.0 * dt
        var look: Vector2 = moved if bool(h["moving"]) else (player_pos - Vector2(h["pos"]))
        if look.length() > 0.5:
            if absf(look.x) > absf(look.y):
                h["facing"] = 2 if look.x > 0.0 else 3
            else:
                h["facing"] = 0 if look.y > 0.0 else 1
        h["prev"] = h["pos"]


func _strike_hounds_and_rescue() -> void:
    for h in hounds:
        var to_h: Vector2 = Vector2(h["pos"]) - player_pos
        if to_h.length() < STRIKE_RANGE + 14.0 and (to_h.length() < 26.0 or to_h.normalized().dot(strike_dir) > 0.2):
            h["flee"] = 1.4
            h["pos"] = Vector2(h["pos"]) + to_h.normalized() * 18.0 if not _is_blocked(Vector2(h["pos"]) + to_h.normalized() * 18.0) else h["pos"]
            float_fx.append({"pos": Vector2(h["pos"]) + Vector2(0, -50), "text": "INMUNE", "color": Color("#b4bba8"), "t": 0.0})
            _sfx("k_metal", -10.0, 0.8)
    if _room().has("rescue") and rescue_state == "atrapado" and player_pos.distance_to(_room()["rescue"]) < STRIKE_RANGE + 20.0:
        _free_rescue()


func _free_rescue() -> void:
    rescue_state = "libre"
    _karma(1, "Liberaste a quien pedía ayuda")
    if not rescued.has("SAÚL"):
        rescued.append("SAÚL")
    matches += 2
    _complete_mission()
    _save_progress()
    _emit(Vector2(_room()["rescue"]) + Vector2(0, -20), 16, Color(0.56, 0.86, 0.95), 15.0, 60.0, 1.0, 2.0, -40.0, Vector2.UP, 1.0, true)
    _dialog([["SAÚL", "¡Gracias! El manto se me enganchó en la reja y los perros me olían..."],
        ["SAÚL", "Toma, dos fósforos. Y escucha: con la luz encendida no se acercan. A oscuras no tienen piedad."],
        ["SAÚL", "Me llamo Saúl. Si sigo vivo más abajo, no lo olvidaré."]])


## La máscara está en su pedestal en cada visita hasta que la recoges en esa
## partida: la puerta de los Canales depende de recogerla, y si ya la llevabas
## de antes no puede quedar cerrada para siempre.
func _mask_on_pedestal() -> bool:
    return _room().has("mask") and not missions_done.has(_room_key())


func _check_mask_pickup() -> void:
    if not _mask_on_pedestal():
        return
    if player_pos.distance_to(_room()["mask"]) < 28.0:
        var had_it: bool = has_mask
        has_mask = true
        _complete_mission()
        _save_progress()
        _sfx("k_campana", -8.0, 0.7)
        _emit(Vector2(_room()["mask"]) + Vector2(0, -14), 24, Color(0.95, 0.92, 0.85), 15.0, 70.0, 1.2, 2.0, -40.0, Vector2.UP, 1.1, true)
        if had_it:
            _dialog([[_hero_name(), "Otra máscara igual a la mía, en el mismo pedestal. Alguien la repone para cada visitante."],
                [_hero_name(), "Al tocarla, la puerta de los canales cede."]])
        else:
            _dialog([[_hero_name(), "Una máscara de porcelana, como las de los perros. Al ponérmela, mi Resonancia ruge."],
                [_hero_name(), "Ahora la onda llega más lejos, y los mastines huyen de ella."]])


func _draw_hound(i: int) -> void:
    var h: Dictionary = hounds[i]
    var frame: int
    if float(h["bite_t"]) > 0.0:
        frame = 7
    elif torch_on and player_pos.distance_to(h["pos"]) < 180.0 and not bool(h["moving"]):
        frame = 6 # gruñe ante el fuego
    elif bool(h["moving"]):
        frame = 2 + int(elapsed * 11.0 + float(i)) % 4
    else:
        frame = int(elapsed * 2.0 + float(i)) % 2
    var pos: Vector2 = Vector2(h["pos"]).round()
    _draw_soft_shadow(pos + Vector2(0, 3), 15.0)
    var region := Rect2(float(frame) * ENEMY_CELL.x, float(h["facing"]) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
    draw_texture_rect_region(HOUND_TEX, Rect2(pos.x - ENEMY_CELL.x * 0.5, pos.y + 4.0 - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y), region)


## Muro bajo del laberinto: cara superior clara, frente de sillares y musgo.
func _draw_maze_wall(i: int) -> void:
    var r: Rect2 = maze_walls[i]
    var lift: float = 22.0
    var top := Rect2(r.position.x, r.position.y - lift, r.size.x, r.size.y)
    var front := Rect2(r.position.x, r.position.y - lift + r.size.y, r.size.x, lift)
    draw_rect(Rect2(r.position + Vector2(3, 4), r.size), Color(0, 0, 0, 0.35)) # sombra
    draw_rect(front, Color("#2c2a2e"))
    var row: int = 0
    var y: float = front.position.y
    while y < front.end.y - 1.0:
        var off: float = 0.0 if row % 2 == 0 else 7.0
        var x: float = front.position.x - off
        while x < front.end.x:
            var bx: float = maxf(x, front.position.x)
            var bw: float = minf(x + 14.0, front.end.x) - bx
            if bw > 1.0:
                draw_rect(Rect2(bx + 0.5, y + 0.5, bw - 1.0, 6.0), Color("#3a373c") if (row + int(x)) % 3 else Color("#343136"))
            x += 14.0
        y += 7.0
        row += 1
    draw_rect(top, Color("#55505a"))
    draw_rect(Rect2(top.position, Vector2(top.size.x, 2)), Color("#6d6772"))
    draw_rect(Rect2(front.position.x, front.end.y - 3.0, front.size.x, 3), Color("#3f5236", 0.8)) # musgo
    draw_rect(Rect2(top.position.x, top.position.y, top.size.x, top.size.y + lift), Color(0, 0, 0, 0.55), false, 1.0)


func _draw_rescue() -> void:
    var at: Vector2 = _room()["rescue"]
    var sheet: Texture2D = art["enemy_peregrino"]
    var free: bool = rescue_state == "libre"
    var frame: int = int(elapsed * 2.0) % 2 if free else (6 if int(elapsed * 3.0) % 3 == 0 else 0)
    _draw_soft_shadow(at + Vector2(0, 3), 12.0)
    draw_texture_rect_region(sheet, Rect2(at.x - ENEMY_CELL.x * 0.5, at.y + 4.0 - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y),
        Rect2(float(frame) * ENEMY_CELL.x, 0, ENEMY_CELL.x, ENEMY_CELL.y), Color(0.95, 0.9, 1.0))
    if not free:
        # Reja caída que le atrapa el manto.
        var g := Rect2(at.x - 22.0, at.y - 18.0, 44.0, 20.0)
        for k in range(6):
            draw_line(Vector2(g.position.x + float(k) * 8.0 + 2.0, g.position.y), Vector2(g.position.x + float(k) * 8.0 - 4.0, g.end.y), Color("#5b5f63"), 2.0)
        draw_line(g.position, Vector2(g.end.x, g.position.y + 4.0), Color("#7a7f84"), 2.0)


func _draw_rescue_label() -> void:
    if not _room().has("rescue") or rescue_state == "":
        return
    var at: Vector2 = _room()["rescue"]
    if rescue_state == "atrapado":
        _label_center("ATRAPADO", at + Vector2(0, -70), Color("#e3bd7b"))
        if player_pos.distance_to(at) < 200.0 and int(elapsed) % 4 == 0:
            _label_center("«¡Ayuda! ¡Mi manto!»", at + Vector2(0, -88), CREAM)
    else:
        _label_center("SAÚL", at + Vector2(0, -70), Color("#9fd8b0"))


func _draw_mask_item() -> void:
    if not _mask_on_pedestal():
        return
    var at: Vector2 = _room()["mask"]
    draw_rect(Rect2(at.x - 16.0, at.y - 4.0, 32, 10), Color("#4a4540"))
    draw_rect(Rect2(at.x - 16.0, at.y - 4.0, 32, 2), Color("#6d6772"))
    var bob: float = sin(elapsed * 2.0) * 2.0
    draw_texture_rect(ICONS["mascara"], Rect2(at + Vector2(-14, -32 + bob), Vector2(28, 28)), false)


## Canales del suelo: surcos oscuros por donde corren motas de alma.
func _draw_channels_ground() -> void:
    for ch in _room().get("channels", []):
        draw_line(ch[0], ch[1], Color(0.04, 0.05, 0.07, 0.85), 6.0)
        draw_line(ch[0], ch[1], Color(0.25, 0.5, 0.6, 0.25), 2.0)


func _draw_labyrinth_glow() -> void:
    for ch in _room().get("channels", []):
        var a: Vector2 = ch[0]
        var b: Vector2 = ch[1]
        var n: int = int(a.distance_to(b) / 40.0)
        for k in range(n):
            var t: float = fmod(elapsed * 0.25 + float(k) / float(maxi(1, n)), 1.0)
            var p: Vector2 = a.lerp(b, t)
            draw_circle(p, 4.0, Color(0.56, 0.86, 0.95, 0.12))
            draw_rect(Rect2(p.round() - Vector2(1, 1), Vector2(2, 2)), Color(0.75, 0.95, 1.0, 0.8))
    # Las máscaras de porcelana reflejan la luz: se ven en la penumbra.
    for h in hounds:
        var head: Vector2 = Vector2(h["pos"]) + Vector2(10.0 if int(h["facing"]) == 2 else (-10.0 if int(h["facing"]) == 3 else 0.0), -20.0)
        draw_circle(head, 4.0, Color(0.95, 0.92, 0.85, 0.12))
        draw_rect(Rect2(head.round() - Vector2(1, 1), Vector2(2, 2)), Color(0.95, 0.92, 0.85, 0.55))


func _draw_torch_fuel() -> void:
    var fuel_max: float = float(_floor().get("fuel", 0.0))
    if fuel_max <= 0.0 or not has_torch:
        return
    var bar := Rect2(596, 628, 44, 4)
    draw_rect(bar, Color(0, 0, 0, 0.7))
    var k: float = clampf(torch_fuel / fuel_max, 0.0, 1.0) if torch_on else 0.0
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * k, bar.size.y)), Color("#ff9a3c") if k > 0.25 else Color("#d1474f"))


# ------------------------------------------------------------ PISO VI · LA OFRENDA
## Piso de respiro: no hay entidades. Un grupo de peregrinos pide que lo
## guíes (Saúl va con ellos si lo salvaste en el Piso V) y el Mercader
## Silencioso abre su puesto completo. Su regla: se paga primero y nunca se
## mete la mano bajo su manto; quien lo hace pierde vida máxima en esta vida.
## Precios y efectos PROVISIONALES.
const GUIDE_NAMES := ["IRENE", "TEO", "BAS"]
const MERCHANT_TEX := preload("res://assets/visual/enemies/mercader.png")
const MERCHANT_CELL := Vector2(64, 96)
const MERCHANT_BASE := 92.0
const HAND_LOSS := 25.0 # vida máxima que cuesta meter la mano bajo el manto
const GUIDE_SOULS := 3 # almas que da cada peregrino que llega contigo a la escalera
## Puesto del Mercader: [clave, nombre, precio base, descripción]. El pan se
## guarda en la bolsa (se usa desde el perfil); el brazalete y el amuleto se
## equipan y, si ya los llevas, comprarlos otra vez los mejora de nivel. La
## Resonancia también se mejora aquí si ya la tienes.
const SHOP := [
    ["pan", "PAN DE CENIZA", 6, "A la bolsa. Úsalo desde el perfil: +50 de vida, aunque pase del máximo."],
    ["fosforos", "FÓSFOROS ×3", 5, "Tres fósforos más para la antorcha."],
    ["brazalete", "BRAZALETE DE BRONCE", 12, "+10 % al daño del golpe por nivel. Se queda contigo."],
    ["amuleto", "AMULETO DE HUESO", 12, "+10 % a la recarga del vigor por nivel. Se queda contigo."],
    ["resonancia", "MEJORAR RESONANCIA", 10, "+1 nivel: la onda hace más daño."],
]
var guiding: bool = false
var guided: Array = [] # peregrinos que bajaron contigo (para el Piso VII)
var trinkets: Array = [] # objetos del Mercader que se quedan contigo
var hand_lost: bool = false
var bones_used: bool = false
var shop_sel: int = 0
var merchant_open_t: float = 0.0
var guides_rewarded: bool = false


func _strike_damage() -> float:
    var fuerza: float = 1.0 + (0.04 * float(ecos.size()) if ecos.has("fuerza") else 0.0)
    return STRIKE_DAMAGE * (1.0 + 0.1 * float(_trinket_level("brazalete"))) * _level_power() * fuerza


func _stamina_regen() -> float:
    return STAMINA_REGEN * (1.0 + 0.1 * float(_trinket_level("amuleto"))) * (1.0 + LEVEL_VIGOR * float(player_level - 1))


## Daño de la Resonancia: un 90 % menos que antes (era demasiado fuerte).
## Las mejoras del altar o el puesto y los niveles lo van subiendo.
const PULSE_DAMAGE_MULT := 0.1


func _pulse_damage() -> float:
    return (30.0 + 10.0 * float(ability_level)) * _level_power() * PULSE_DAMAGE_MULT


## Huesos firmes: una vez por piso, el golpe mortal te deja con 1 de vida.
func _bones_hold() -> void:
    bones_used = true
    hp = 1.0
    damage_cd = maxf(damage_cd, 1.2)
    shake = maxf(shake, 0.5)
    _sfx("k_cuerpo", -4.0, 0.7)
    _emit(player_pos + Vector2(0, -24), 22, Color(0.92, 0.9, 0.84), 30.0, 110.0, 0.8, 2.0, 120.0, Vector2.UP, 1.4)
    float_fx.append({"pos": player_pos + Vector2(0, -64), "text": "HUESOS FIRMES", "color": Color("#e8e2d4"), "t": 0.0})
    _say("HUESOS FIRMES: aguantas el golpe con 1 de vida. No volverá a pasar en este piso.", 4.0)


func _guides_enter_room() -> void:
    if in_tutorial:
        return
    if bool(_floor().get("followers", false)) and allies.is_empty() and not guided.is_empty() and current_room == 0:
        guiding = true
        for i in range(guided.size()):
            allies.append({"name": guided[i], "pos": player_pos, "prev": player_pos, "facing": 0,
                "moving": false, "alive": true, "react": 0.0, "seed": 60 + i, "dead_key": "", "dead_pos": Vector2.ZERO,
                "line": "", "line_t": 0.0, "waiting": false, "maimed": str(guided[i]) == "TEO", "panic": 0.0, "flee": false})
    if _has("recuento_guias") and guiding and not guides_rewarded:
        guides_rewarded = true
        var alive_n: int = _allies_alive()
        guided = allies.filter(func(a): return bool(a["alive"])).map(func(a): return str(a["name"]))
        souls += alive_n * GUIDE_SOULS
        souls_flash = 0.8
        _save_progress()
        if alive_n > 0:
            _say("Sobrevivieron %d. «No miramos atrás, como dijiste.» +%d almas." % [alive_n, alive_n * GUIDE_SOULS], 4.5)
        else:
            _say("Nadie más llegó. Ella se quedó con todos.", 4.5)
            fear = minf(100.0, fear + 15.0)
    if _has("guias") and allies.is_empty():
        guiding = false
        guides_rewarded = false
        var spots: Array = _room().get("guides", [])
        var names: Array = GUIDE_NAMES.duplicate()
        if rescued.has("SAÚL"):
            names.append("SAÚL")
        for i in range(mini(names.size(), spots.size())):
            allies.append({"name": names[i], "pos": spots[i], "prev": spots[i], "facing": 0,
                "moving": false, "alive": true, "react": 0.0, "seed": 40 + i, "dead_key": "", "dead_pos": Vector2.ZERO,
                "line": "", "line_t": 0.0, "waiting": true, "maimed": false})
    if _has("despedida") and guiding and not guides_rewarded:
        guides_rewarded = true
        var alive: int = _allies_alive()
        guided = allies.filter(func(a): return bool(a["alive"])).map(func(a): return str(a["name"]))
        souls += alive * GUIDE_SOULS
        souls_flash = 0.8
        _save_progress()
        _say("Llegan %d contigo a la escalera. Te dan +%d almas: «Lo poco que tenemos»." % [alive, alive * GUIDE_SOULS], 4.5)


## E / A junto al grupo, al cuenco del Mercader o al borde de su manto.
func _offering_interact() -> bool:
    if _has("guias") and not guiding:
        for ally in allies:
            if player_pos.distance_to(ally["pos"]) < 72.0:
                _accept_guides()
                return true
    if not _room().has("merchant"):
        return false
    var m: Vector2 = _room()["merchant"]
    if player_pos.distance_to(_merchant_hem()) < 30.0:
        _reach_under_cloak()
        return true
    if player_pos.distance_to(m + Vector2(0, 40)) < 56.0:
        _open_shop()
        return true
    return false


func _accept_guides() -> void:
    if _mark() == "maldicion":
        _dialog([["IRENE", "No. Hemos oído lo que dejaste atrás. No vamos a seguirte."],
            ["BAS", "Tienes la marca. Aléjate de nosotros."]])
        _sfx("toque", -8.0, 0.7)
        return
    guiding = true
    _karma(1, "Aceptaste guiar al grupo")
    if _mark() == "bendicion":
        bag["pan"] = int(bag.get("pan", 0)) + 1
        float_fx.append({"pos": player_pos + Vector2(0, -64), "text": "+1 PAN (REGALO)", "color": Color("#ffd36b"), "t": 0.0})
    for ally in allies:
        ally["waiting"] = false
    _complete_mission()
    _sfx("k_campana", -10.0, 1.1)
    var lines: Array = [["IRENE", "Gracias. Iremos detrás de ti, a tu paso."]]
    if _ally_alive_named("SAÚL"):
        lines.append(["SAÚL", "Ya te lo dije: no lo olvido."])
    lines.append(["{yo}", "Detrás de mí, y sin tocar nada que no sea vuestro."])
    _dialog(lines.map(func(l): return [_hero_name() if l[0] == "{yo}" else l[0], l[1]]))


func _merchant_hem() -> Vector2:
    return Vector2(_room()["merchant"]) + Vector2(36, -6)


func _load_merchant() -> void:
    if _room().has("merchant"):
        var m: Vector2 = _room()["merchant"]
        obstacles.append(Rect2(m.x - 14.0, m.y - 12.0, 28.0, 12.0))


func _reach_under_cloak() -> void:
    merchant_open_t = 1.2
    shake = maxf(shake, 0.6)
    _sfx("dano", -4.0, 0.7)
    _sfx("k_cuerpo", -6.0, 0.6)
    _emit(_merchant_hem(), 30, Color(0.6, 0.05, 0.1), 40.0, 150.0, 0.9, 3.0, 300.0, Vector2.UP, 1.6)
    if hand_lost:
        _say("El manto no se abre dos veces para la misma mano.", 3.0)
        return
    hand_lost = true
    max_hp = maxf(40.0, max_hp - HAND_LOSS)
    hp = minf(hp, max_hp)
    fear = minf(100.0, fear + 30.0)
    _on_hurt()
    float_fx.append({"pos": player_pos + Vector2(0, -64), "text": "-%d VIDA MÁXIMA" % int(HAND_LOSS), "color": RED, "t": 0.0})
    _dialog([[_hero_name(), "¡Algo me ha agarrado la mano desde dentro! ¡Está helada... y ya no la siento!"],
        [_hero_name(), "La regla estaba escrita en la pared. En esta vida no la recuperaré."]])


func _update_offering(dt: float) -> void:
    merchant_open_t = maxf(0.0, merchant_open_t - dt)


## El resto de la sala del Mercader: lo que pasa al entrar (Teo y su mano).
func _offering_after_talk() -> void:
    if not _has("mercader") or not guiding:
        return
    for ally in allies:
        if str(ally["name"]) == "TEO" and bool(ally["alive"]) and not bool(ally.get("maimed", false)):
            ally["maimed"] = true
            merchant_open_t = 1.2
            shake = maxf(shake, 0.4)
            _emit(_merchant_hem(), 26, Color(0.6, 0.05, 0.1), 40.0, 150.0, 0.9, 3.0, 300.0, Vector2.UP, 1.6)
            _sfx("dano", -6.0, 0.8)


# --- Puesto del Mercader ----------------------------------------------------------
func _open_shop() -> void:
    game_mode = "shop"
    shop_sel = 0
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -8.0, 0.8)


func _close_shop() -> void:
    game_mode = "play"
    _sfx("interfaz", -12.0, 0.9)


func _shop_row(i: int) -> Rect2:
    return Rect2(180, 190 + float(i) * 64.0, 600, 58)


## Precio real: crece con el nivel de lo que mejoras y cambia con tu marca.
func _shop_price(i: int) -> int:
    var key: String = SHOP[i][0]
    var base: float = float(SHOP[i][2])
    match key:
        "brazalete", "amuleto":
            base *= float(_trinket_level(key) + 1) # comprar: 12; mejorar a NV 2: 24; a NV 3: 36...
        "resonancia":
            base = float(RESONANCE_UPGRADE_BASE + RESONANCE_UPGRADE_STEP * ability_level)
    return maxi(1, int(roundf(base * _karma_price_factor())))


func _shop_maxed(i: int) -> bool:
    var key: String = SHOP[i][0]
    if key in ["brazalete", "amuleto"]:
        return _trinket_level(key) >= ITEM_LEVEL_MAX
    if key == "resonancia":
        return not has_pulse or ability_level >= ABILITY_LEVEL_MAX
    return false


## Lo que llevas de cada cosa, para verlo crecer al comprar.
func _shop_owned_text(i: int) -> String:
    match str(SHOP[i][0]):
        "pan":
            return "LLEVAS ×%d" % int(bag.get("pan", 0))
        "fosforos":
            return "LLEVAS ×%d" % matches
        "brazalete", "amuleto":
            var lv: int = _trinket_level(SHOP[i][0])
            return "NV %d" % lv if lv > 0 else "NO LO TIENES"
        "resonancia":
            return ("NV %d" % ability_level) if has_pulse else "SIN RESONANCIA"
    return ""


func _shop_key(k: int) -> void:
    if k in [KEY_ESCAPE, KEY_E, _key("interactuar")]:
        _close_shop()
    elif k in [KEY_DOWN, KEY_S, KEY_RIGHT, KEY_D]:
        shop_sel = (shop_sel + 1) % SHOP.size()
    elif k in [KEY_UP, KEY_W, KEY_LEFT, KEY_A]:
        shop_sel = (shop_sel + SHOP.size() - 1) % SHOP.size()
    elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
        _shop_buy(shop_sel)
    elif k >= KEY_1 and k <= KEY_5:
        shop_sel = int(k) - int(KEY_1)
        _shop_buy(shop_sel)


func _shop_tap(at: Vector2) -> void:
    for i in range(SHOP.size()):
        if _shop_row(i).has_point(at):
            shop_sel = i
            _shop_buy(i)
            return
    _close_shop()


## Se paga primero: las almas van al cuenco y después él entrega.
func _shop_buy(i: int) -> bool:
    var item: Array = SHOP[i]
    var key: String = item[0]
    var price: int = _shop_price(i)
    if _shop_maxed(i):
        _say("Todavía no tienes Resonancia: se consigue en el altar." if key == "resonancia" and not has_pulse else "Ya está al nivel máximo.", 2.4)
        _sfx("toque", -10.0)
        return false
    if souls < price:
        _say("El cuenco sigue vacío: necesitas %d almas." % price, 2.4)
        _sfx("toque", -10.0)
        return false
    souls -= price
    var got: String = _tc(str(item[1]))
    match key:
        "pan":
            bag["pan"] = int(bag.get("pan", 0)) + 1
        "fosforos":
            matches += 3
        "resonancia":
            ability_level += 1
            got = "Resonancia nivel %d" % ability_level
        _:
            if trinkets.has(key):
                trinket_levels[key] = _trinket_level(key) + 1
                got = "%s nivel %d" % [got, _trinket_level(key)]
            else:
                trinkets.append(key)
                trinket_levels[key] = 1
    shop_flash[i] = 1.0
    _save_progress()
    _sfx("alma", -6.0, 0.8)
    _sfx("objeto", -8.0, 0.9)
    _say("Dejas %d almas en el cuenco. Sin una palabra, el Mercader te entrega: %s." % [price, got], 3.2)
    return true


func _draw_shop() -> void:
    _overlay()
    var panel := Rect2(150, 86, 660, 494)
    _panel(panel, Color(0.05, 0.045, 0.06, 0.97), UI_GOLD)
    _title_text("El Mercader Silencioso", Vector2(150, 134), 40, CREAM, panel.size.x)
    var mark_note: String = ""
    match _mark():
        "bendicion":
            mark_note = "  ·  BENDICIÓN: te cobra menos"
        "maldicion":
            mark_note = "  ·  MALDICIÓN: te cobra más"
    _text_outline("Se paga primero. No se toca el manto." + mark_note, Vector2(150, 164), 13, Color("#d1747b"), panel.size.x)
    for i in range(SHOP.size()):
        var row: Rect2 = _shop_row(i)
        var item: Array = SHOP[i]
        var sel: bool = shop_sel == i
        var maxed: bool = _shop_maxed(i)
        var flash: float = float(shop_flash.get(i, 0.0))
        _panel(row, Color("#241c2c").lerp(Color("#5a4a2a"), flash) if sel or flash > 0.0 else Color("#141018"), UI_GOLD if sel else UI_EDGE)
        draw_texture_rect(ICONS[item[0]], Rect2(row.position + Vector2(12, 7), Vector2(44, 44)), false, Color(1, 1, 1, 0.5) if maxed else Color.WHITE)
        _text("[%d] %s" % [i + 1, item[1]], row.position + Vector2(70, 24), 16, CREAM)
        _text(item[3], row.position + Vector2(70, 46), 11, Color("#b9b29b"))
        var right: String = "MÁXIMO" if maxed else "%d ALMAS" % _shop_price(i)
        var tone: Color = SOUL if maxed else (CREAM if souls >= _shop_price(i) else RED)
        draw_string(font, row.position + Vector2(0, 24), right, HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 14.0, 15, tone)
        # Lo que ya llevas: el número salta al comprar.
        var owned: String = _shop_owned_text(i)
        var pop: float = 1.0 + 0.5 * flash
        draw_string(font, row.position + Vector2(0, 46), owned, HORIZONTAL_ALIGNMENT_RIGHT, row.size.x - 14.0, int(13.0 * pop), Color("#ffd36b").lerp(SOUL, 1.0 - flash))
    draw_texture_rect(ICONS["alma"], Rect2(180, 520, 26, 26), false)
    _text("ALMAS: %d" % souls, Vector2(212, 540), 16, SOUL)
    _text("VIDA MÁXIMA: %d" % int(max_hp), Vector2(360, 540), 14, RED if hand_lost else CREAM)
    var hint: String = _hint("ENTER comprar · ESC salir", "Toca para comprar · fuera para salir", "A comprar · B salir")
    draw_string(font, Vector2(180, 566), hint, HORIZONTAL_ALIGNMENT_RIGHT, 600, 13, CREAM)
    if toast_left > 0.0:
        _draw_toast()


# --- Dibujo ----------------------------------------------------------------------
func _draw_merchant() -> void:
    var m: Vector2 = _room()["merchant"]
    # Cuenco de las ofrendas, delante.
    var bowl: Vector2 = m + Vector2(0, 30)
    _draw_soft_shadow(bowl + Vector2(0, 4), 14.0)
    draw_rect(Rect2(bowl.x - 6.0, bowl.y - 6.0, 12, 8), Color("#3a3036"))
    _draw_ellipse(bowl + Vector2(0, -8), 15.0, 5.0, Color("#6a5440"))
    _draw_ellipse(bowl + Vector2(0, -9), 12.0, 3.5, Color("#1a1420"))
    var frame: int = 2 if merchant_open_t > 0.0 else int(elapsed * 1.2) % 2
    _draw_soft_shadow(m + Vector2(0, 2), 22.0)
    draw_texture_rect_region(MERCHANT_TEX, Rect2(m.x - MERCHANT_CELL.x * 0.5, m.y + 2.0 - MERCHANT_BASE, MERCHANT_CELL.x, MERCHANT_CELL.y),
        Rect2(float(frame) * MERCHANT_CELL.x, 0, MERCHANT_CELL.x, MERCHANT_CELL.y))


## Lo que brilla bajo el manto: un cebo. Se ve también en la penumbra.
func _draw_merchant_glow() -> void:
    if not _room().has("merchant"):
        return
    var hem: Vector2 = _merchant_hem() + Vector2(-16, 4)
    var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.4)
    draw_circle(hem, 9.0 + 3.0 * pulse, Color(0.95, 0.8, 0.45, 0.08 + 0.06 * pulse))
    draw_rect(Rect2(hem.round() - Vector2(1, 1), Vector2(2, 2)), Color(1.0, 0.9, 0.6, 0.5 + 0.4 * pulse))
    var eyes: Vector2 = Vector2(_room()["merchant"]) + Vector2(0, -67)
    draw_circle(eyes, 7.0, Color(1.0, 0.85, 0.5, 0.06))


func _draw_offering_labels() -> void:
    if _has("guias") and not guiding:
        for ally in allies:
            if str(ally["name"]) == "IRENE":
                _label_center(_prompt("GUIAR AL GRUPO"), Vector2(ally["pos"]) + Vector2(0, -84), Color("#e3bd7b"))
    if not _room().has("merchant"):
        return
    var m: Vector2 = _room()["merchant"]
    if player_pos.distance_to(m) < 170.0:
        _label_center(_prompt("OFRENDA"), m + Vector2(0, 60), CREAM)
    if player_pos.distance_to(_merchant_hem()) < 44.0:
        _label_center(_prompt("¿METER LA MANO BAJO EL MANTO?"), _merchant_hem() + Vector2(0, -60), Color("#d1747b"))


# ------------------------------------------------------------ NIVELES DEL PERSONAJE
## Experiencia por lo que haces (almas, alimañas, entidades desterradas,
## misiones y pisos). Cada nivel sube la vida máxima, el daño (golpe y
## Resonancia) y la recarga del vigor, y te cura. Se guarda con el progreso;
## si el alma es absorbida, la persona nueva empieza en el nivel 1.
## Valores PROVISIONALES.
const LEVEL_MAX := 20
const LEVEL_HP := 6.0 # vida máxima por nivel
const LEVEL_POWER := 0.04 # daño por nivel (+4 %)
const LEVEL_VIGOR := 0.03 # recarga del vigor por nivel (+3 %)
const XP_RELIC := 2
const XP_CRITTER := 3
const XP_BANISH := 25
const XP_MISSION := 8
const XP_FLOOR := 30
var player_level: int = 1
var xp: int = 0
var level_flash: float = 0.0
var level_banner_t: float = 0.0


func _xp_needed(level: int) -> int:
    return 30 + 20 * (level - 1)


func _xp_fraction() -> float:
    if player_level >= LEVEL_MAX:
        return 1.0
    return clampf(float(xp) / float(_xp_needed(player_level)), 0.0, 1.0)


func _base_max_hp() -> float:
    return 100.0 + LEVEL_HP * float(player_level - 1)


func _level_power() -> float:
    return 1.0 + LEVEL_POWER * float(player_level - 1)


func _gain_xp(amount: int) -> void:
    if amount <= 0 or in_tutorial or player_level >= LEVEL_MAX:
        return
    xp += amount
    var ups: int = 0
    while player_level < LEVEL_MAX and xp >= _xp_needed(player_level):
        xp -= _xp_needed(player_level)
        player_level += 1
        ups += 1
    if player_level >= LEVEL_MAX:
        xp = 0
    if ups > 0:
        _level_up(ups)


func _level_up(ups: int) -> void:
    # La vida máxima crece lo mismo aunque la hayas perdido bajo el manto.
    max_hp += LEVEL_HP * float(ups)
    hp = maxf(hp, max_hp) # cura sin borrar la vida extra
    level_flash = 1.0
    level_banner_t = 3.4
    _save_progress()
    _sfx("sello", -5.0, 1.3)
    _sfx("k_campana", -9.0, 1.4)
    _emit(player_pos + Vector2(0, -24), 40, Color(0.95, 0.8, 0.45), 30.0, 120.0, 1.3, 2.0, -60.0, Vector2.UP, 1.2, true)


func _update_level_fx(dt: float) -> void:
    level_flash = maxf(0.0, level_flash - dt * 1.5)
    level_banner_t = maxf(0.0, level_banner_t - dt)


func _draw_level_banner() -> void:
    if level_banner_t <= 0.0:
        return
    var a: float = clampf(level_banner_t * 2.0, 0.0, 1.0) * clampf((3.4 - level_banner_t) * 4.0, 0.0, 1.0)
    var box := Rect2(270, 236, 420, 74)
    _panel(box, Color(0.1, 0.06, 0.12, 0.94 * a), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, a))
    _title_text("Nivel %d" % player_level, Vector2(box.position.x, box.position.y + 38.0), 36, Color(1.0, 0.9, 0.6, a), box.size.x)
    _text_outline("+%d VIDA MÁX · +%d %% DAÑO · +%d %% VIGOR" % [int(LEVEL_HP), int(LEVEL_POWER * 100.0), int(LEVEL_VIGOR * 100.0)],
        Vector2(box.position.x, box.position.y + 62.0), 13, Color(CREAM.r, CREAM.g, CREAM.b, a), box.size.x)


# ------------------------------------------------------------ PISO VII · LA QUE NO APARTA LA VISTA
## Una figura con yelmo y ojos en el pecho que rodea la sala. Solo ataca si
## la provocas: darle la espalda más de un instante o esquivar (correr). Para
## que la puerta se abra hay que aguantar su mirada el tiempo de la sala.
## Te provoca con amagos y ruidos a tu espalda; los peregrinos que guías
## pueden entrar en pánico: si no los calmas a tiempo, echan a correr y ella
## se los lleva. No se la puede herir. Valores PROVISIONALES.
const VIGIA_TEX := preload("res://assets/visual/enemies/vigia.png")
const VIGIA_CELL := Vector2(64, 96)
const VIGIA_BASE := 92.0
const GAZE_CENTER := Vector2(480, 350)
const GAZE_RADIUS := Vector2(250, 130)
const GAZE_GRACE := 0.7 # segundos de espalda que tolera
const GAZE_FACING := -0.2 # producto escalar mínimo para «mirarla»
const GAZE_WINDUP := 0.55
const GAZE_DAMAGE := 30.0
const GAZE_PENALTY := 6.0 # segundos de mirada que pierdes si la provocas
const GAZE_PANIC := 4.0 # tiempo para calmar a un peregrino
var gaze_active: bool = false
var gaze_pos: Vector2 = Vector2.ZERO
var gaze_angle: float = 0.0
var gaze_t: float = 0.0
var gaze_need: float = 0.0
var gaze_state: String = "mira" # mira | aviso | golpe | caza | vencida
var gaze_state_t: float = 0.0
var gaze_away_t: float = 0.0
var gaze_target: Vector2 = Vector2.ZERO
var gaze_feint_t: float = 0.0
var gaze_feint: float = 0.0
var gaze_noise_t: float = 0.0
var gaze_noise: Dictionary = {}
var gaze_panic_done: bool = false
var gaze_prey: Dictionary = {}


func _load_gaze() -> void:
    gaze_active = false
    if in_tutorial or not _room().has("gaze"):
        return
    gaze_need = float(_room()["gaze"])
    if missions_done.has(_room_key()):
        return # ya la venciste en esta sala
    gaze_active = true
    gaze_state = "mira"
    gaze_t = 0.0
    gaze_away_t = 0.0
    gaze_angle = -0.4
    gaze_pos = _gaze_orbit()
    gaze_feint_t = randf_range(5.0, 8.0)
    gaze_noise_t = randf_range(7.0, 10.0)
    gaze_noise = {}
    gaze_panic_done = false
    gaze_prey = {}


func _gaze_orbit() -> Vector2:
    return GAZE_CENTER + Vector2(cos(gaze_angle) * GAZE_RADIUS.x, sin(gaze_angle) * GAZE_RADIUS.y)


## ¿La está mirando? Basta con no darle la espalda.
func _gaze_facing() -> bool:
    var to_her: Vector2 = gaze_pos - player_pos
    if to_her.length() < 1.0 or player_dir.length() < 0.1:
        return true
    return player_dir.normalized().dot(to_her.normalized()) > GAZE_FACING


func _update_gaze(dt: float) -> void:
    if not gaze_active:
        return
    gaze_state_t = maxf(0.0, gaze_state_t - dt)
    if gaze_state == "vencida":
        return
    fear = minf(100.0, fear + dt * 2.5)
    var facing: bool = _gaze_facing()
    match gaze_state:
        "mira":
            gaze_angle += dt * 0.22
            var orbit: Vector2 = _gaze_orbit()
            gaze_feint = maxf(0.0, gaze_feint - dt)
            var lunge: Vector2 = (player_pos - orbit).normalized() * 70.0 * sin(PI * gaze_feint / 0.5) if gaze_feint > 0.0 else Vector2.ZERO
            gaze_pos = gaze_pos.move_toward(orbit + lunge, 260.0 * dt)
            gaze_away_t = gaze_away_t + dt if not facing else maxf(0.0, gaze_away_t - dt * 2.0)
            if gaze_state_t <= 0.0 and (gaze_away_t > GAZE_GRACE or dash_left > 0.0):
                _gaze_provoke("¡Le diste la espalda!" if dash_left <= 0.0 else "¡Corriste!")
                return
            if facing:
                gaze_t += dt
            # Amagos: se lanza sin aviso rojo y vuelve. Esquivar la provoca.
            gaze_feint_t -= dt
            if gaze_feint_t <= 0.0:
                gaze_feint_t = randf_range(6.0, 9.0)
                gaze_feint = 0.5
                _sfx("latigo", -12.0, 0.7)
            # Ruidos a tu espalda para que te des la vuelta.
            gaze_noise_t -= dt
            if gaze_noise_t <= 0.0:
                gaze_noise_t = randf_range(8.0, 12.0)
                var behind: Vector2 = player_pos - (gaze_pos - player_pos).normalized() * 110.0
                gaze_noise = {"pos": behind, "t": 1.6}
                _sfx("k_piedra", -6.0, 0.6)
                _emit(behind, 10, Color(0.55, 0.5, 0.45, 0.6), 10.0, 50.0, 0.7, 2.0, 60.0, Vector2.UP, 1.4)
            # Pánico de un peregrino a mitad de la prueba.
            if not gaze_panic_done and gaze_t > gaze_need * 0.4 and guiding:
                gaze_panic_done = true
                _gaze_panic()
            _update_panic(dt)
            if gaze_t >= gaze_need:
                _gaze_defeat()
        "aviso":
            if gaze_state_t <= 0.0:
                gaze_state = "golpe"
                gaze_state_t = 0.8
                gaze_target = player_pos
                _sfx("latigo", -4.0, 0.9)
        "golpe":
            gaze_pos = gaze_pos.move_toward(gaze_target, 560.0 * dt)
            if gaze_pos.distance_to(player_pos) < 34.0 and damage_cd <= 0.0 and dash_left <= 0.0:
                hp -= GAZE_DAMAGE * _depth_mult()
                fear = minf(100.0, fear + 20.0)
                damage_cd = 1.0
                shake = maxf(shake, 0.5)
                _on_hurt()
                _sfx("dano", -4.0, 0.8)
                gaze_state_t = 0.0
            if gaze_state_t <= 0.0 or gaze_pos.distance_to(gaze_target) < 4.0:
                gaze_state = "mira"
                gaze_away_t = 0.0
                gaze_state_t = 0.8 # respiro: el esquive con el que la evitaste no cuenta
        "caza":
            if gaze_prey.is_empty() or not bool(gaze_prey["alive"]):
                gaze_state = "mira"
                return
            gaze_pos = gaze_pos.move_toward(gaze_prey["pos"], 520.0 * dt)
            if gaze_pos.distance_to(gaze_prey["pos"]) < 30.0:
                gaze_prey["flee"] = false
                _ally_die(gaze_prey)
                _karma(-1, "No llegaste a calmarlo")
                _emit(Vector2(gaze_prey["pos"]) + Vector2(0, -20), 30, Color(0.6, 0.05, 0.1), 40.0, 160.0, 0.9, 3.0, 300.0, Vector2.UP, 1.6)
                gaze_prey = {}
                gaze_state = "mira"
    if not gaze_noise.is_empty():
        gaze_noise["t"] = float(gaze_noise["t"]) - dt
        if float(gaze_noise["t"]) <= 0.0:
            gaze_noise = {}


func _gaze_provoke(reason: String) -> void:
    gaze_state = "aviso"
    gaze_state_t = GAZE_WINDUP
    gaze_away_t = 0.0
    gaze_t = maxf(0.0, gaze_t - GAZE_PENALTY)
    _sfx("ojo", -4.0, 0.8)
    _sfx("aviso", -6.0, 0.9)
    float_fx.append({"pos": player_pos + Vector2(0, -64), "text": reason.to_upper(), "color": RED, "t": 0.0})


func _gaze_defeat() -> void:
    gaze_state = "vencida"
    gaze_noise = {}
    for ally in allies:
        ally["panic"] = 0.0
    _complete_mission()
    _sfx("k_campana", -6.0, 0.6)
    _emit(gaze_pos + Vector2(0, -50), 30, Color(0.85, 0.85, 0.9), 15.0, 60.0, 1.4, 2.0, -30.0, Vector2.UP, 1.2, true)
    _say("Los ojos de su pecho se cierran uno a uno. Ya no te mira.", 4.0)


func _gaze_panic() -> void:
    var alive: Array = allies.filter(func(a): return bool(a["alive"]))
    if alive.is_empty():
        return
    var who: Dictionary = alive[randi() % alive.size()]
    who["panic"] = GAZE_PANIC
    who["line"] = "¡No puedo más! ¡Me voy de aquí!"
    who["line_t"] = GAZE_PANIC
    _sfx("aviso", -8.0, 1.3)


func _update_panic(dt: float) -> void:
    for ally in allies:
        var p: float = float(ally.get("panic", 0.0))
        if p <= 0.0 or not bool(ally["alive"]):
            continue
        p -= dt
        ally["panic"] = p
        if p <= 0.0:
            # No llegaste a tiempo: corre, y ella va a por él.
            ally["flee"] = true
            ally["line"] = "¡AAAH!"
            ally["line_t"] = 1.5
            gaze_prey = ally
            gaze_state = "caza"
            _sfx("dano", -8.0, 1.4)


## E / A junto a un peregrino en pánico: lo calmas.
func _calm_ally() -> bool:
    for ally in allies:
        if float(ally.get("panic", 0.0)) > 0.0 and bool(ally["alive"]) and player_pos.distance_to(ally["pos"]) < 80.0:
            ally["panic"] = 0.0
            _karma(1, "Calmaste a un peregrino")
            ally["line"] = "...Vale. Vale. No corro."
            ally["line_t"] = 2.5
            float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -60), "text": "CALMADO", "color": Color("#9fd8b0"), "t": 0.0})
            _gain_xp(10)
            _sfx("k_campana", -12.0, 1.3)
            return true
    return false


func _draw_vigia() -> void:
    var frame: int = int(elapsed * 1.5) % 2
    if gaze_state == "aviso" or gaze_state == "caza":
        frame = 2
    elif gaze_state == "golpe" or gaze_feint > 0.0:
        frame = 3
    var tint := Color(1, 1, 1, 0.45) if gaze_state == "vencida" else Color.WHITE
    var bob: float = sin(elapsed * 2.0) * 2.0
    _draw_soft_shadow(gaze_pos + Vector2(0, 4), 18.0, 0.6)
    draw_texture_rect_region(VIGIA_TEX, Rect2(gaze_pos.x - VIGIA_CELL.x * 0.5, gaze_pos.y + 2.0 + bob - VIGIA_BASE, VIGIA_CELL.x, VIGIA_CELL.y),
        Rect2(float(frame) * VIGIA_CELL.x, 0, VIGIA_CELL.x, VIGIA_CELL.y), tint)


## Medidor de la mirada, aviso de espalda, flecha hacia ella y ruidos.
func _draw_gaze_hud() -> void:
    if not gaze_active:
        return
    # Sus ojos brillan en la penumbra.
    if gaze_state != "vencida":
        var chest: Vector2 = gaze_pos + Vector2(0, -50)
        draw_circle(chest, 12.0, Color(1.0, 0.3, 0.3, 0.12) if gaze_state in ["aviso", "golpe", "caza"] else Color(0.95, 0.92, 0.85, 0.07))
    if not gaze_noise.is_empty():
        var a: float = clampf(float(gaze_noise["t"]), 0.0, 1.0)
        _label_center("¿...?", Vector2(gaze_noise["pos"]) + Vector2(0, -20), Color(CREAM.r, CREAM.g, CREAM.b, a))
    if gaze_state == "vencida":
        return
    var box := Rect2(300, 116, 360, 34)
    _panel(box, Color(0.06, 0.04, 0.06, 0.9), UI_CRIMSON if gaze_away_t > 0.0 else UI_GOLD)
    var k: float = clampf(gaze_t / maxf(1.0, gaze_need), 0.0, 1.0)
    var bar := Rect2(box.position + Vector2(8, 20), Vector2(box.size.x - 16.0, 8))
    draw_rect(bar, Color(0, 0, 0, 0.7))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * k, bar.size.y)), Color("#c9a25e"))
    _text_outline("RESISTE · %d / %d s" % [int(gaze_t), int(gaze_need)], Vector2(box.position.x, box.position.y + 16.0), 12, CREAM, box.size.x)
    if gaze_away_t > 0.0 and gaze_state == "mira":
        var blink: float = 0.6 + 0.4 * sin(elapsed * 14.0)
        # Sin instrucciones: solo una flecha roja que parpadea hacia ella.
        var dir: Vector2 = (gaze_pos - player_pos).normalized()
        var tip: Vector2 = player_pos + Vector2(0, -24) + dir * 46.0
        var side := Vector2(-dir.y, dir.x)
        draw_colored_polygon(PackedVector2Array([tip, tip - dir * 14.0 + side * 7.0, tip - dir * 14.0 - side * 7.0]), Color(1.0, 0.4, 0.4, blink))
    elif gaze_state == "aviso":
        _label_center("¡VIENE!", player_pos + Vector2(0, -100), Color("#ffd36b"))


# ------------------------------------------------------------ MÓVIL
## Controles táctiles pensados para el pulgar: joystick flotante en la mitad
## izquierda y cuatro botones en abanico a la derecha. El botón grande es de
## ACCIÓN y cambia según lo que tengas cerca (hablar, comprar, cruzar, calmar,
## golpear...), así no hace falta saber qué tecla es cada cosa.
const JOY_HOME := Vector2(135, 480)
const JOY_RADIUS := 76.0
const JOY_ZONE_X := 400.0
const JOY_ZONE_Y := 300.0
## [centro, radio]. Radios generosos: el dedo no apunta como el ratón.
const TOUCH_BUTTONS := {
    "accion": [Vector2(858, 494), 58.0],
    "esquivar": [Vector2(734, 540), 42.0],
    "antorcha": [Vector2(748, 420), 40.0],
    "resonancia": [Vector2(904, 596), 38.0],
}
var joy_center: Vector2 = JOY_HOME


func _touch_button_at(at: Vector2) -> String:
    var best: String = ""
    var best_d: float = INF
    for id in TOUCH_BUTTONS:
        var d: float = at.distance_to(TOUCH_BUTTONS[id][0])
        if d <= float(TOUCH_BUTTONS[id][1]) + 12.0 and d < best_d:
            best = id
            best_d = d
    return best


## Qué hará el botón de ACCIÓN aquí: [texto, icono, es un golpe, hay algo cerca].
func _touch_context() -> Array:
    for ally in allies:
        if float(ally.get("panic", 0.0)) > 0.0 and bool(ally["alive"]) and player_pos.distance_to(ally["pos"]) < 80.0:
            return ["CALMAR", "corazon", false, true]
    if _has("guias") and not guiding:
        for ally in allies:
            if player_pos.distance_to(ally["pos"]) < 72.0:
                return ["GUIAR", "habilidades", false, true]
    if _room().has("merchant"):
        if player_pos.distance_to(_merchant_hem()) < 30.0:
            return ["¿LA MANO?", "calavera", false, true]
        if player_pos.distance_to(Vector2(_room()["merchant"]) + Vector2(0, 40)) < 56.0:
            return ["COMPRAR", "alma", false, true]
    if _fountain_here() and player_pos.distance_to(FOUNTAIN_POS) < FOUNTAIN_REACH and not fountains_used.has(_room_key()):
        return ["CURAR", "corazon", false, true]
    if _has("sello") and not seal_acquired and player_pos.distance_to(seal_pos) < 60.0:
        return ["SELLO", "llama_interior", false, true]
    if _has("altar") and player_pos.distance_to(altar_pos) < 64.0:
        return ["ALTAR", "alma", false, true]
    if _has("archivo") and player_pos.distance_to(archive_pos) < 72.0:
        return ["LEER", "habilidades", false, true]
    if player_pos.distance_to(door_pos) < 74.0:
        return ["PUERTA", "", false, true]
    if has_torch and torch_on:
        return ["GOLPE", "golpe", true, false]
    return ["USAR", "golpe", false, false]


## Texto de una etiqueta del mundo: con la tecla o el botón entre corchetes,
## o solo el texto en pantalla táctil (allí lo hace el botón de ACCIÓN).
func _prompt(text: String) -> String:
    if touch_enabled and not pad_active:
        return text
    return "%s [%s]" % [text, _key_label("interactuar")]


## Ayuda al pie de los menús según cómo juegues.
func _hint(keyboard: String, touch: String, pad: String) -> String:
    if pad_active:
        return pad
    if touch_enabled:
        return touch
    return keyboard


# ------------------------------------------------------------ PISO VIII · EL TEMPLO QUE CAMBIA
## Las salas del Piso I, pero cambiadas: las estatuas y los objetos miran al
## otro lado («mirror»), el Testigo persigue al que se queda quieto
## («inverted»), el sello está en el Archivo y una inscripción firmada con tu
## nombre miente. El Eco del piso, Memoria de eco, muestra tu silueta donde
## moriste en otras vidas (las muertes se recuerdan entre partidas).
const DEATH_MARKS_PER_ROOM := 3
var death_marks: Dictionary = {} # "piso:sala" -> [[x, y], ...]
var inverted_seen: bool = false


func _mark_death() -> void:
    if in_tutorial:
        return
    var key: String = _room_key()
    var marks: Array = death_marks.get(key, [])
    marks.append([roundf(player_pos.x), roundf(player_pos.y)])
    while marks.size() > DEATH_MARKS_PER_ROOM:
        marks.pop_front()
    death_marks[key] = marks


func _room_death_marks() -> Array:
    if in_tutorial or not ecos.has("memoria"):
        return []
    return (death_marks.get(_room_key(), []) as Array).map(func(m): return Vector2(float(m[0]), float(m[1])))


func _memory_whisper() -> void:
    if not _room_death_marks().is_empty():
        _say("Memoria de eco: ya moriste aquí. Tu silueta marca el sitio.", 3.5)


## Silueta translúcida del personaje tendido donde cayó en otra vida.
func _draw_death_marks() -> void:
    var marks: Array = _room_death_marks()
    for i in range(marks.size()):
        var at: Vector2 = marks[i]
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 2.0 + float(i))
        _draw_ellipse(at + Vector2(0, 2), 20.0, 7.0, Color(0.56, 0.86, 0.95, 0.10 + 0.08 * pulse))
        if art.has("visual_hero"):
            draw_texture_rect_region(_hero_sheet(), Rect2(at.x - 20.0, at.y + 4.0 - 54.0, 40.0, 56.0), Rect2(0, 0, 40, 56),
                Color(0.7, 0.95, 1.0, 0.38 + 0.15 * pulse))
        if player_pos.distance_to(at) < 150.0:
            _label_center("AQUÍ MORISTE", at + Vector2(0, -62), Color(0.62, 0.86, 0.95, 0.6 + 0.4 * pulse))


## Cierre con confirmación (autoload ConfirmarSalida, scenes/confirmar_salida.tscn).
func _ask_quit() -> void:
    var confirm: Node = get_node_or_null("/root/ConfirmarSalida")
    if confirm != null:
        confirm.call("preguntar")
    else:
        get_tree().quit()


# ------------------------------------------------------------ OBJETOS, MEJORAS Y VIDA EXTRA
## La bolsa guarda consumibles (pan y lo que traiga la Vigilia) entre partidas.
## El brazalete y el amuleto se mejoran con almas hasta el nivel 5; la
## Resonancia, hasta el 5 en el altar o el puesto del Mercader.
## Curarse por encima del máximo deja vida extra (hasta +50) que no se regenera.
const ITEM_LEVEL_MAX := 5
const ABILITY_LEVEL_MAX := 5
const RESONANCE_UPGRADE_BASE := 10
const RESONANCE_UPGRADE_STEP := 8
const OVERHEAL_MAX := 50.0
## Consumibles de la bolsa: [nombre, descripción, icono]. Los de la Vigilia
## (scripts/botin.gd) llegan aquí.
const BAG_ITEMS := {
    "pan": ["PAN DE CENIZA", "+50 de vida (pasa del máximo), vigor lleno y +10 de vida máx. perdida.", "pan"],
    "fosforos_caja": ["CAJA DE FÓSFOROS", "+3 fósforos para la antorcha.", "fosforos"],
    "vial": ["VIAL DE SANGRE", "+80 de vida, aunque pase del máximo.", "vial"],
    "incienso": ["INCIENSO", "El miedo baja a cero.", "incienso"],
    "bolsa_almas": ["BOLSA DE ALMAS", "+25 almas.", "bolsa_almas"],
    "reliquia": ["RELIQUIA DE ECOS", "+60 de experiencia.", "reliquia"],
}
var bag: Dictionary = {} # clave -> cantidad
var trinket_levels: Dictionary = {} # clave -> nivel
var profile_tab: int = 0 # 0 equipo, 1 objetos
var shop_flash: Dictionary = {}


func _trinket_level(key: String) -> int:
    if not trinkets.has(key):
        return 0
    return clampi(int(trinket_levels.get(key, 1)), 1, ITEM_LEVEL_MAX)


## Cura; con «overflow», lo que sobra del máximo queda como vida extra.
func _heal(amount: float, overflow: bool = true) -> void:
    var cap: float = max_hp + (OVERHEAL_MAX if overflow else 0.0)
    if hp >= cap:
        return
    var before: float = hp
    hp = minf(cap, hp + amount)
    hp_prev = hp
    float_fx.append({"pos": player_pos + Vector2(0, -60), "text": "+%d" % int(round(hp - before)), "color": Color("#9fd8b0") if hp <= max_hp else Color("#ffd36b"), "t": 0.0})


func _profile_tab_rect(t: int) -> Rect2:
    return Rect2(372.0 + float(t) * 168.0, 72.0, 160.0, 24.0)


func _profile_switch_tab() -> void:
    profile_tab = 1 - profile_tab
    inventory_sel = 0
    _sfx("toque", -14.0, 1.0)


## Casillas de la pestaña OBJETOS: [icono, nombre, detalle, descripción, se usa].
func _object_slots() -> Array:
    var list: Array = []
    for key in ["brazalete", "amuleto"]:
        if trinkets.has(key):
            var info: Array = SHOP[2] if key == "brazalete" else SHOP[3]
            list.append([key, info[1], "EQUIPADO · NV %d" % _trinket_level(key),
                "%s Ahora: +%d %%. Se mejora con almas en el puesto del Mercader." % [info[3].split(".")[0] + ".", 10 * _trinket_level(key)], false, key])
    if has_mask:
        list.append(["mascara", "MÁSCARA DE PORCELANA", "EQUIPADA", "Tu Resonancia es Rugido: llega un 50 % más lejos y espanta a los mastines.", false, "mascara"])
    for key in bag:
        if int(bag[key]) > 0 and BAG_ITEMS.has(key):
            list.append([BAG_ITEMS[key][2], BAG_ITEMS[key][0], "×%d · USAR" % int(bag[key]), BAG_ITEMS[key][1], true, key])
    return list


func _profile_use_selected() -> void:
    if profile_tab != 1:
        return
    var list: Array = _object_slots()
    if inventory_sel < 0 or inventory_sel >= list.size() or not bool(list[inventory_sel][4]):
        return
    _use_bag_item(str(list[inventory_sel][5]))


func _use_bag_item(key: String) -> bool:
    if int(bag.get(key, 0)) <= 0:
        return false
    bag[key] = int(bag[key]) - 1
    if int(bag[key]) <= 0:
        bag.erase(key)
    match key:
        "pan":
            max_hp = minf(_base_max_hp(), max_hp + 10.0) # devuelve vida máxima perdida
            _heal(50.0)
            stamina = 100.0
        "fosforos_caja":
            matches += 3
        "vial":
            _heal(80.0)
        "incienso":
            fear = 0.0
        "bolsa_almas":
            souls += 25
            souls_flash = 0.8
        "reliquia":
            _gain_xp(60)
    _save_progress()
    _sfx("objeto", -6.0, 1.1)
    _say("Usas %s." % _tc(str(BAG_ITEMS.get(key, [key])[0])), 2.0)
    return true


func _draw_object_slots() -> void:
    var list: Array = _object_slots()
    for i in range(INVENTORY_SLOTS.size()):
        var box: Rect2 = _inventory_slot_rect(i)
        var sel: bool = inventory_sel == i
        _panel(box, Color("#222c39") if sel else Color("#141922"), UI_GOLD if sel else UI_EDGE)
        if i >= list.size():
            _text_outline("—", Vector2(box.position.x, box.get_center().y + 6.0), 16, Color("#4a4740"), box.size.x)
            continue
        var o: Array = list[i]
        draw_texture_rect(ICONS[o[0]], Rect2(box.position + Vector2(roundf(box.size.x * 0.5) - 24.0, 8), Vector2(48, 48)), false)
        _text_outline(str(o[2]), Vector2(box.position.x, box.position.y + 74.0), 11, Color("#ffd36b") if bool(o[4]) else SOUL, box.size.x)
        _text_outline(str(o[1]), Vector2(box.position.x, box.end.y - 10.0), 11, CREAM, box.size.x)


func _draw_object_desc() -> void:
    var list: Array = _object_slots()
    if inventory_sel < 0 or inventory_sel >= list.size():
        _text_outline("SIN OBJETOS", Vector2(388, 478), 15, Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), "Cómpralos al Mercader del Piso VI o gánalos en la Vigilia.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, Color("#8a8778"))
        return
    var o: Array = list[inventory_sel]
    _text_outline(str(o[1]), Vector2(388, 478), 15, CREAM)
    draw_string(font, Vector2(388, 502), str(o[3]), HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, SOUL)
    if bool(o[4]):
        draw_string(font, Vector2(388, 522), _hint("ENTER: usar", "Toca otra vez: usar", "A: usar"), HORIZONTAL_ALIGNMENT_LEFT, 470.0, 12, Color("#ffd36b"))


# ------------------------------------------------------------ MARCA: BENDICIÓN Y MALDICIÓN
## Ayudar a quien lo pide suma; dejarlo atrás o fallarle resta. Con +2 llevas
## la bendición: los peregrinos confían en ti, te regalan cosas y el Mercader
## cobra menos. Con −2, la maldición: te temen, se apartan, no te siguen, el
## Peregrino siempre te traiciona y el Mercader cobra más. Se guarda.
const KARMA_MARK := 2
var karma: int = 0


func _mark() -> String:
    if karma >= KARMA_MARK:
        return "bendicion"
    if karma <= -KARMA_MARK:
        return "maldicion"
    return ""


func _karma(delta: int, reason: String) -> void:
    if in_tutorial:
        return
    var before: String = _mark()
    karma = clampi(karma + delta, -9, 9)
    float_fx.append({"pos": player_pos + Vector2(0, -84), "text": reason.to_upper(), "color": Color("#ffd36b") if delta > 0 else RED, "t": 0.0})
    var now: String = _mark()
    if now != before:
        match now:
            "bendicion":
                mission_banner = "BENDICIÓN · Los peregrinos confían en ti"
                _sfx("k_campana", -6.0, 1.3)
            "maldicion":
                mission_banner = "MALDICIÓN · Los peregrinos te temen"
                _sfx("k_campana", -6.0, 0.5)
            _:
                mission_banner = "La marca se borra"
        mission_banner_t = 3.2
    _save_progress()


## Salir de una sala dejando atrás a quien pedía ayuda.
func _karma_on_leave() -> void:
    if _room().has("rescue") and rescue_state == "atrapado":
        _karma(-1, "Dejaste atrás a quien pedía ayuda")
    if _has("guias") and not guiding and _mark() != "maldicion":
        _karma(-1, "Ignoraste a quien te pidió guía")


func _karma_price_factor() -> float:
    match _mark():
        "bendicion":
            return 0.8
        "maldicion":
            return 1.2
    return 1.0


func _draw_mark_aura() -> void:
    if game_mode != "play" and game_mode != "dialog":
        return
    match _mark():
        "bendicion":
            for k in range(5):
                var a: float = elapsed * 1.4 + float(k) * TAU / 5.0
                var p: Vector2 = player_pos + Vector2(cos(a) * 18.0, -26.0 + sin(a) * 8.0 - fmod(elapsed * 10.0 + float(k) * 7.0, 20.0))
                draw_rect(Rect2(p.round(), Vector2(2, 2)), Color(1.0, 0.85, 0.45, 0.7))
        "maldicion":
            _draw_ellipse(player_pos + Vector2(0, 3), 20.0, 7.0, Color(0.5, 0.05, 0.1, 0.25 + 0.1 * sin(elapsed * 3.0)))
            for k in range(4):
                var p2: Vector2 = player_pos + Vector2(-12.0 + float(k) * 8.0, -fmod(elapsed * 16.0 + float(k) * 9.0, 40.0))
                draw_circle(p2, 3.0, Color(0.25, 0.02, 0.06, 0.4))


# ------------------------------------------------------------ RELICARIOS DE VIDA
## En las salas sin entidad (entre los encuentros) hay una máquina de vida:
## un relicario de latón con un vial rojo. Se usa una vez por sala y partida y
## cura 60 (puede dejar vida extra).
const FOUNTAIN_POS := Vector2(150, 500)
const FOUNTAIN_REACH := 58.0
const FOUNTAIN_HEAL := 60.0
var fountains_used: Dictionary = {}


func _fountain_here() -> bool:
    if in_tutorial or str(_room()["enemy"]) != "":
        return false
    for t in ["tutorial", "mercader", "guias"]:
        if t in _room()["traits"]:
            return false
    return not (_room().has("hounds") or _room().has("gaze") or _room().has("rams") or _room().has("colossus") or _room().has("braziers") or _room().has("elder_boss") or _room().has("elder"))


func _use_fountain() -> bool:
    if not _fountain_here() or player_pos.distance_to(FOUNTAIN_POS) >= FOUNTAIN_REACH:
        return false
    if fountains_used.has(_room_key()):
        _say("El vial está vacío. Se rellenará en otra partida.", 2.2)
        return true
    fountains_used[_room_key()] = true
    _heal(FOUNTAIN_HEAL)
    _sfx("k_metal", -8.0, 0.9)
    _sfx("alma", -8.0, 0.7)
    _emit(FOUNTAIN_POS + Vector2(0, -30), 24, Color(0.9, 0.2, 0.25), 15.0, 60.0, 1.0, 2.0, -40.0, Vector2.UP, 1.0, true)
    return true


func _draw_fountain() -> void:
    var p: Vector2 = FOUNTAIN_POS
    var used: bool = fountains_used.has(_room_key())
    _draw_soft_shadow(p + Vector2(0, 2), 18.0)
    # Base de piedra y cuerpo de latón con engranajes.
    draw_rect(Rect2(p.x - 16.0, p.y - 10.0, 32, 10), Color("#3a363c"))
    draw_rect(Rect2(p.x - 12.0, p.y - 34.0, 24, 24), Color("#8a6a3a"))
    draw_rect(Rect2(p.x - 12.0, p.y - 34.0, 24, 3), Color("#c9a25e"))
    var spin: float = 0.0 if used else elapsed * 2.0
    for side in [-1.0, 1.0]:
        var g: Vector2 = p + Vector2(side * 14.0, -22.0)
        draw_circle(g, 5.0, Color("#6a5030"))
        draw_line(g + Vector2.from_angle(spin) * 5.0, g - Vector2.from_angle(spin) * 5.0, Color("#c9a25e"), 1.0)
    # Vial con sangre que late; vacío si ya lo usaste.
    var vial := Rect2(p.x - 6.0, p.y - 54.0, 12, 20)
    draw_rect(vial, Color(0.6, 0.7, 0.75, 0.35))
    if not used:
        var pulse: float = 0.5 + 0.5 * sin(elapsed * 3.0)
        draw_rect(Rect2(vial.position + Vector2(2, 6), Vector2(8, 13)), Color(0.75, 0.08, 0.14).lerp(Color(0.95, 0.2, 0.25), pulse))
        draw_circle(vial.get_center(), 14.0, Color(0.9, 0.15, 0.2, 0.08 + 0.06 * pulse))
    draw_rect(vial, Color(0.85, 0.85, 0.9, 0.6), false, 1.0)
    draw_rect(Rect2(p.x - 8.0, p.y - 57.0, 16, 4), Color("#c9a25e"))


func _draw_fountain_label() -> void:
    if not _fountain_here() or player_pos.distance_to(FOUNTAIN_POS) > 150.0:
        return
    if fountains_used.has(_room_key()):
        _label_center("RELICARIO VACÍO", FOUNTAIN_POS + Vector2(0, -68), Color("#8a8574"))
    else:
        _label_center(_prompt("RELICARIO DE VIDA · +%d" % int(FOUNTAIN_HEAL)), FOUNTAIN_POS + Vector2(0, -68), Color("#ff8a8a"))


# ------------------------------------------------------------ ENEMIGOS MÁS FUERTES CUANTO MÁS ABAJO
## Las entidades de siempre (Ghoul, Testigo, Hechicero, Segador, Tejedora,
## mastines, la Vigía) tienen más vida y pegan más fuerte cuanto más profundo
## es el piso: +12 % por piso. Valores PROVISIONALES.
const DEPTH_STEP := 0.12


func _depth_mult() -> float:
    return 1.0 + DEPTH_STEP * float(current_floor) if not in_tutorial else 1.0


# ------------------------------------------------------------ PISO IX · EL COLOSO DEL PÓRTICO
## Arietes de Piedra: golems bajos con cuernos. Son de piedra (los golpes no
## les hacen nada) hasta que embisten: si te alineas con ellos en horizontal o
## en vertical, se preparan 0,6 s (línea roja) y cargan en línea recta. Si
## chocan contra un muro o una columna quedan aturdidos 2 s: entonces se rompen.
## El Coloso: estatua viva inmune a golpes y a la Resonancia. Pisa fuerte
## (aviso con un círculo rojo). Hay que atraerlo junto a una columna agrietada
## y golpear la columna: cae sobre él. Tres columnas lo derriban.
const RAM_TEX := preload("res://assets/visual/enemies/ariete.png")
const COLOSSUS_TEX := preload("res://assets/visual/enemies/coloso.png")
const RAM_HP := 70.0
const RAM_SIGHT := 330.0
const RAM_ALIGN := 24.0
const RAM_WINDUP := 0.6
const RAM_SPEED := 430.0
const RAM_DAMAGE := 28.0
const RAM_STUN := 2.0
const COLOSSUS_SPEED := 40.0
const COLOSSUS_STOMP_RADIUS := 130.0
const COLOSSUS_WINDUP := 0.85
const COLOSSUS_DAMAGE := 32.0
const COLOSSUS_HITS := 3
const PILLAR_REACH := 160.0 # distancia del Coloso a la columna para que le caiga encima
var rams: Array = [] # {pos, prev, home, state, t, dir, hp, facing, cd}
var pillars: Array = [] # {pos, fallen, fall_dir, fall_t}
var colossus_active: bool = false
var colossus_pos: Vector2 = Vector2.ZERO
var colossus_hits: int = 0
var colossus_state: String = "walk" # walk | raise | stomp | stun
var colossus_t: float = 0.0
var colossus_cd: float = 2.0


func _load_colossus_room() -> void:
    rams.clear()
    pillars.clear()
    colossus_active = false
    if in_tutorial:
        return
    var dead_rams: Array = banished.get(_room_key() + ":arietes", [])
    var spots: Array = _room().get("rams", [])
    for i in range(spots.size()):
        if dead_rams.has(i):
            continue
        rams.append({"pos": spots[i], "prev": spots[i], "home": spots[i], "state": "idle", "t": randf_range(0.5, 1.5),
            "dir": Vector2.ZERO, "hp": RAM_HP, "max": RAM_HP, "facing": 3, "cd": 1.0, "id": i, "wander": spots[i]})
    for at in _room().get("pillars", []):
        pillars.append({"pos": at, "fallen": false, "fall_dir": Vector2.DOWN, "fall_t": 0.0})
        obstacles.append(Rect2(at.x - 14.0, at.y - 10.0, 28.0, 12.0))
    if _room().has("colossus") and not banished.has(_room_key()):
        colossus_active = true
        colossus_pos = _room()["colossus"]
        colossus_hits = 0
        colossus_state = "walk"
        colossus_cd = 2.5


func _update_rams(dt: float) -> void:
    for r in rams:
        var pos: Vector2 = r["pos"]
        r["cd"] = maxf(0.0, float(r["cd"]) - dt)
        match str(r["state"]):
            "idle":
                var d: Vector2 = player_pos - pos
                var aligned_x: bool = absf(d.y) < RAM_ALIGN and absf(d.x) < RAM_SIGHT
                var aligned_y: bool = absf(d.x) < RAM_ALIGN and absf(d.y) < RAM_SIGHT
                if float(r["cd"]) <= 0.0 and (aligned_x or aligned_y):
                    r["state"] = "aim"
                    r["t"] = RAM_WINDUP
                    r["dir"] = Vector2(signf(d.x), 0) if aligned_x else Vector2(0, signf(d.y))
                    _sfx("k_piedra", -8.0, 0.7)
                else:
                    r["t"] = float(r["t"]) - dt
                    if float(r["t"]) <= 0.0:
                        r["t"] = randf_range(1.2, 2.4)
                        r["wander"] = Vector2(r["home"]) + Vector2(randf_range(-60, 60), randf_range(-40, 40))
                    var nxt: Vector2 = pos.move_toward(r["wander"], 30.0 * dt)
                    if not _is_blocked(nxt):
                        r["pos"] = nxt
            "aim":
                r["t"] = float(r["t"]) - dt
                if float(r["t"]) <= 0.0:
                    r["state"] = "charge"
                    r["t"] = 1.6
                    _sfx("k_golpe", -8.0, 0.6)
            "charge":
                r["t"] = float(r["t"]) - dt
                var step: Vector2 = Vector2(r["dir"]) * RAM_SPEED * dt
                var nxt2: Vector2 = pos + step
                if _is_blocked(nxt2) or float(r["t"]) <= 0.0:
                    r["state"] = "stun"
                    r["t"] = RAM_STUN
                    shake = maxf(shake, 0.3)
                    _sfx("k_piedra", -4.0, 0.5)
                    _emit(pos + Vector2(r["dir"]) * 20.0 + Vector2(0, -14), 16, Color(0.6, 0.58, 0.52), 30.0, 110.0, 0.7, 2.0, 120.0, -Vector2(r["dir"]), 1.2)
                else:
                    r["pos"] = nxt2
                    if nxt2.distance_to(player_pos) < 30.0 and dash_left <= 0.0 and damage_cd <= 0.0:
                        hp -= RAM_DAMAGE
                        fear = minf(100.0, fear + 12.0)
                        damage_cd = 1.0
                        _on_hurt()
                        var push: Vector2 = player_pos + Vector2(r["dir"]) * 34.0
                        if not _is_blocked(push):
                            player_pos = push
            "stun":
                r["t"] = float(r["t"]) - dt
                if float(r["t"]) <= 0.0:
                    r["state"] = "idle"
                    r["cd"] = 1.2
        var moved: Vector2 = Vector2(r["pos"]) - Vector2(r["prev"])
        var look: Vector2 = Vector2(r["dir"]) if str(r["state"]) in ["aim", "charge"] else (moved if moved.length() > 0.1 else player_pos - Vector2(r["pos"]))
        if look.length() > 0.1:
            r["facing"] = (2 if look.x > 0.0 else 3) if absf(look.x) > absf(look.y) else (0 if look.y > 0.0 else 1)
        r["moving"] = moved.length() > 4.0 * dt
        r["prev"] = r["pos"]


func _strike_rams_and_pillars() -> void:
    for i in range(rams.size() - 1, -1, -1):
        var r: Dictionary = rams[i]
        var to_r: Vector2 = Vector2(r["pos"]) - player_pos
        if to_r.length() > STRIKE_RANGE + 12.0 or (to_r.length() > 24.0 and to_r.normalized().dot(strike_dir) < 0.2):
            continue
        if str(r["state"]) != "stun":
            float_fx.append({"pos": Vector2(r["pos"]) + Vector2(0, -50), "text": "PIEDRA", "color": Color("#b4bba8"), "t": 0.0})
            _sfx("k_metal", -10.0, 0.7)
            continue
        r["hp"] = float(r["hp"]) - _strike_damage() * 1.5
        float_fx.append({"pos": Vector2(r["pos"]) + Vector2(0, -50), "text": "-%d" % int(_strike_damage() * 1.5), "color": Color("#ffd36b"), "t": 0.0})
        _sfx("k_piedra", -6.0, 1.2)
        if float(r["hp"]) <= 0.0:
            _ram_break(i)
    # Columnas agrietadas: caen hacia el Coloso si está cerca.
    for p in pillars:
        if bool(p["fallen"]) or player_pos.distance_to(p["pos"]) > 60.0:
            continue
        if colossus_active and colossus_pos.distance_to(p["pos"]) < PILLAR_REACH:
            _pillar_fall(p)
        else:
            float_fx.append({"pos": Vector2(p["pos"]) + Vector2(0, -70), "text": "CRUJE", "color": Color("#b4bba8"), "t": 0.0})
            _say("La columna cruje, pero aguanta.", 3.0)
            _sfx("k_piedra", -10.0, 0.9)


func _ram_break(i: int) -> void:
    var r: Dictionary = rams[i]
    var key: String = _room_key() + ":arietes"
    var dead: Array = banished.get(key, [])
    dead.append(int(r["id"]))
    banished[key] = dead
    drops.append({"pos": r["pos"], "value": 6})
    _gain_xp(15)
    _emit(Vector2(r["pos"]) + Vector2(0, -16), 26, Color(0.55, 0.53, 0.48), 30.0, 130.0, 0.9, 3.0, 220.0, Vector2.UP, 1.6)
    shake = maxf(shake, 0.25)
    rams.remove_at(i)
    if rams.is_empty() and _mission().get("goal", "") == "arietes":
        _complete_mission()


func _pillar_fall(p: Dictionary) -> void:
    p["fallen"] = true
    p["fall_dir"] = (colossus_pos - Vector2(p["pos"])).normalized()
    p["fall_t"] = 0.0
    for i in range(obstacles.size()):
        if (obstacles[i] as Rect2).get_center().distance_to(Vector2(p["pos"]) + Vector2(0, -4)) < 2.0:
            obstacles.remove_at(i)
            break
    colossus_hits += 1
    colossus_state = "stun"
    colossus_t = 2.5
    shake = maxf(shake, 0.8)
    _sfx("k_piedra", -2.0, 0.4)
    _sfx("k_golpe", -4.0, 0.5)
    _emit(colossus_pos + Vector2(0, -80), 40, Color(0.6, 0.58, 0.52), 40.0, 160.0, 1.0, 3.0, 200.0, Vector2.UP, 1.6)
    float_fx.append({"pos": colossus_pos + Vector2(0, -170), "text": "¡%d / %d!" % [colossus_hits, COLOSSUS_HITS], "color": Color("#ffd36b"), "t": 0.0})
    if colossus_hits >= COLOSSUS_HITS:
        _colossus_defeat()


func _colossus_defeat() -> void:
    colossus_active = false
    banished[_room_key()] = true
    drops.append({"pos": colossus_pos, "value": 30})
    _gain_xp(80)
    _complete_mission()
    dissolve_fx.append({"pos": colossus_pos, "kind": "coloso", "facing": 0, "frame": 6, "t": 0.0})
    _emit(colossus_pos + Vector2(0, -60), 60, Color(0.6, 0.58, 0.52), 40.0, 180.0, 1.4, 3.0, 150.0, Vector2.UP, 1.8)
    _say("El Coloso se derrumba. Entre sus piedras brillan almas.", 4.0)
    _sfx("destierro", -2.0, 0.6)


func _update_colossus(dt: float) -> void:
    for p in pillars:
        if bool(p["fallen"]):
            p["fall_t"] = minf(1.0, float(p["fall_t"]) + dt * 3.0)
    if not colossus_active:
        return
    colossus_cd = maxf(0.0, colossus_cd - dt)
    colossus_t = maxf(0.0, colossus_t - dt)
    fear = minf(100.0, fear + dt * 1.5)
    var d: float = colossus_pos.distance_to(player_pos)
    match colossus_state:
        "walk":
            var target: Vector2 = colossus_pos.move_toward(player_pos, COLOSSUS_SPEED * (1.0 + 0.25 * float(colossus_hits)) * dt)
            colossus_pos = Vector2(clampf(target.x, 110.0, 850.0), clampf(target.y, 220.0, 540.0))
            if d < COLOSSUS_STOMP_RADIUS and colossus_cd <= 0.0:
                colossus_state = "raise"
                colossus_t = COLOSSUS_WINDUP - 0.12 * float(colossus_hits) # cada vez pisa antes
                _sfx("k_piedra", -10.0, 0.5)
        "raise":
            if colossus_t <= 0.0:
                colossus_state = "stomp"
                colossus_t = 0.35
                shake = maxf(shake, 0.6)
                _sfx("k_golpe", -2.0, 0.4)
                _emit(colossus_pos, 30, Color(0.55, 0.5, 0.45), 60.0, 200.0, 0.8, 3.0, 60.0, Vector2.UP, 3.0)
                if d < COLOSSUS_STOMP_RADIUS and dash_left <= 0.0 and damage_cd <= 0.0:
                    hp -= COLOSSUS_DAMAGE
                    fear = minf(100.0, fear + 18.0)
                    damage_cd = 1.0
                    _on_hurt()
        "stomp":
            if colossus_t <= 0.0:
                colossus_state = "walk"
                colossus_cd = maxf(1.0, 2.2 - 0.4 * float(colossus_hits))
        "stun":
            if colossus_t <= 0.0:
                colossus_state = "walk"
                colossus_cd = 1.5


func _draw_ram(i: int) -> void:
    var r: Dictionary = rams[i]
    var frame: int
    match str(r["state"]):
        "aim":
            frame = 6
        "charge":
            frame = 2 + int(elapsed * 14.0) % 4
        "stun":
            frame = 7
        _:
            frame = 2 + int(elapsed * 8.0) % 4 if bool(r.get("moving", false)) else int(elapsed * 2.0 + float(i)) % 2
    var pos: Vector2 = Vector2(r["pos"]).round()
    _draw_soft_shadow(pos + Vector2(0, 3), 16.0)
    var tint := Color(1.0, 0.85, 0.6) if str(r["state"]) == "stun" else Color.WHITE
    draw_texture_rect_region(RAM_TEX, Rect2(pos.x - 24.0, pos.y + 4.0 - ENEMY_FEET_Y, 48, 64), Rect2(float(frame) * 48.0, float(r["facing"]) * 64.0, 48, 64), tint)
    if str(r["state"]) == "stun":
        var bar := Rect2(pos.x - 20.0, pos.y - 62.0, 40, 4)
        draw_rect(bar.grow(1.0), Color(0, 0, 0, 0.7))
        draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(float(r["hp"]) / float(r["max"]), 0.0, 1.0), bar.size.y)), Color("#ffd36b"))


## Línea roja de aviso antes de embestir: siempre visible (juego limpio).
func _draw_ram_warnings() -> void:
    for r in rams:
        if str(r["state"]) != "aim":
            continue
        var from: Vector2 = Vector2(r["pos"]) + Vector2(0, -12)
        var k: float = 1.0 - clampf(float(r["t"]) / RAM_WINDUP, 0.0, 1.0)
        draw_line(from, from + Vector2(r["dir"]) * 360.0, Color(1.0, 0.25, 0.25, 0.25 + 0.5 * k), 2.0 + 4.0 * k)


func _draw_pillar(i: int) -> void:
    var p: Dictionary = pillars[i]
    var at: Vector2 = p["pos"]
    if bool(p["fallen"]):
        # Columna caída: tambores de piedra en línea hacia donde estaba el Coloso.
        var dir: Vector2 = p["fall_dir"]
        var k: float = float(p["fall_t"])
        for n in range(5):
            var c: Vector2 = at + dir * (14.0 + float(n) * 22.0) * k
            draw_rect(Rect2(c - Vector2(12, 8), Vector2(24, 16)), Color("#6a665e"))
            draw_rect(Rect2(c - Vector2(12, 8), Vector2(24, 3)), Color("#8a857b"))
        return
    _draw_soft_shadow(at + Vector2(0, 2), 16.0)
    var body := Rect2(at.x - 12.0, at.y - 92.0, 24, 92)
    draw_rect(body, Color("#7d7a72"))
    draw_rect(Rect2(body.position, Vector2(5, body.size.y)), Color("#a8a49a"))
    draw_rect(Rect2(at.x - 16.0, at.y - 98.0, 32, 8), Color("#8a857b"))
    draw_rect(Rect2(at.x - 16.0, at.y - 8.0, 32, 8), Color("#5f5b54"))
    # Grieta que brilla: aquí se golpea.
    var glow: float = 0.5 + 0.5 * sin(elapsed * 3.0 + at.x)
    draw_polyline(PackedVector2Array([Vector2(at.x - 4, at.y - 70), Vector2(at.x + 4, at.y - 54), Vector2(at.x - 2, at.y - 36), Vector2(at.x + 3, at.y - 22)]), Color(1.0, 0.75, 0.35, 0.5 + 0.5 * glow), 2.0)
    if colossus_active and colossus_pos.distance_to(at) < PILLAR_REACH:
        draw_rect(body.grow(3.0), Color(1.0, 0.8, 0.4, 0.5 + 0.3 * glow), false, 2.0)


func _draw_colossus() -> void:
    var frame: int
    match colossus_state:
        "raise":
            frame = 4
        "stomp":
            frame = 5
        "stun":
            frame = 6
        _:
            frame = 2 + int(elapsed * 3.0) % 2
    var pos: Vector2 = colossus_pos.round()
    _draw_soft_shadow(pos + Vector2(0, 4), 56.0, 1.2)
    draw_texture_rect_region(COLOSSUS_TEX, Rect2(pos.x - 64.0, pos.y + 6.0 - 154.0, 128, 160), Rect2(float(frame) * 128.0, 0, 128, 160))
    if colossus_state == "raise":
        var k: float = 1.0 - clampf(colossus_t / COLOSSUS_WINDUP, 0.0, 1.0)
        _draw_ellipse(pos, COLOSSUS_STOMP_RADIUS * k, COLOSSUS_STOMP_RADIUS * 0.45 * k, Color(1.0, 0.2, 0.2, 0.12 + 0.18 * k))
        draw_arc(pos, COLOSSUS_STOMP_RADIUS, 0, TAU, 48, Color(1.0, 0.3, 0.3, 0.3 + 0.4 * k), 2.0)


func _draw_colossus_hud() -> void:
    if not colossus_active:
        return
    var box := Rect2(300, 116, 360, 34)
    _panel(box, Color(0.06, 0.04, 0.06, 0.9), UI_GOLD)
    _text_outline("EL COLOSO DEL PÓRTICO", Vector2(box.position.x, box.position.y + 16.0), 12, CREAM, box.size.x)
    for i in range(COLOSSUS_HITS):
        var seg := Rect2(box.position.x + 10.0 + float(i) * 114.0, box.position.y + 21.0, 108, 7)
        draw_rect(seg, Color(0, 0, 0, 0.7))
        if i >= colossus_hits:
            draw_rect(seg, Color("#b3263a"))


# ------------------------------------------------------------ PISO X · LA COSECHA (final del arco)
## Ritual de la Cosecha: tres braseros (dos en X-2, uno en X-3) se encienden
## golpeándolos o tocándolos con la antorcha encendida. En la Puerta (X-4) el
## Hermano Mayor te traiciona: es un humano que usa tres reglas robadas.
##  · HILOS: tensa líneas rojas (aviso fino 0,9 s); tocarlas tensas hace daño.
##  · RUGIDO: carga un círculo; si sigues dentro al estallar, daño. Después
##    queda agotado 2,5 s y recibe el doble de daño.
##  · MIRADA (la de la Vigía del Piso VII): sus ojos brillan 3,5 s; si te
##    alejas de él (le das la espalda) o esquivas mientras te mira, daño.
## Tus aliados deciden según tu marca: con bendición luchan contigo; con
## maldición se ponen de su lado y te tiran piedras; sin marca, se apartan.
## Valores PROVISIONALES.
const ELDER_HP := 620.0
const ELDER_SPEED := 62.0
const ELDER_THREAD_DAMAGE := 18.0
const ELDER_ROAR_RADIUS := 230.0
const ELDER_ROAR_DAMAGE := 26.0
const ELDER_GAZE_TICK := 7.0
const ELDER_SWIPE_DAMAGE := 16.0
const BRAZIER_REACH := 64.0
const ELDER_RULES := ["hilos", "rugido", "mirada"]
var braziers: Array = [] # {pos, lit}
var braziers_lit: Dictionary = {} # "piso:sala:i" -> true
var elder_active: bool = false # jefe en X-4
var elder_npc: bool = false # figura tranquila en X-1
var elder_pos: Vector2 = Vector2.ZERO
var elder_hp: float = ELDER_HP
var elder_max: float = ELDER_HP
var elder_state: String = "talk" # talk | walk | threads_aim | threads | roar | tired | gaze | swipe
var elder_t: float = 0.0
var elder_cd: float = 0.0
var elder_rule: int = 0
var elder_hit_t: float = 0.0
var elder_tick: float = 0.0
var elder_facing: int = 3
var elder_threads: Array = [] # [desde, hasta]
var elder_side: String = "" # aliados: "contigo", "contra", "apartados"
var elder_traitors: Array = [] # {pos, cd}
var elder_stones: Array = [] # {pos, t}
var elder_ally_cd: float = 0.0
var elder_last_player: Vector2 = Vector2.ZERO


func _load_harvest_room() -> void:
    braziers.clear()
    elder_active = false
    elder_npc = false
    elder_threads.clear()
    elder_traitors.clear()
    elder_stones.clear()
    if in_tutorial:
        return
    var spots: Array = _room().get("braziers", [])
    for i in range(spots.size()):
        braziers.append({"pos": spots[i], "lit": braziers_lit.has("%s:%d" % [_room_key(), i])})
        obstacles.append(Rect2(Vector2(spots[i]).x - 14.0, Vector2(spots[i]).y - 8.0, 28.0, 10.0))
    if _room().has("elder"):
        elder_npc = true
        elder_pos = _room()["elder"]
        elder_facing = 3
    if _room().has("elder_boss") and not banished.has(_room_key()):
        elder_active = true
        elder_pos = _room()["elder_boss"]
        elder_hp = ELDER_HP * (1.35 if _mark() == "maldicion" else 1.0)
        elder_max = elder_hp
        elder_state = "talk"
        elder_t = 1.4 # la traición llega en cuanto terminan de hablar
        elder_rule = 0
        elder_side = ""
        elder_cd = 1.5
        elder_last_player = player_pos


## Antorcha encendida junto a un brasero apagado: lo prende.
func _light_brazier() -> bool:
    for i in range(braziers.size()):
        var b: Dictionary = braziers[i]
        if bool(b["lit"]) or player_pos.distance_to(b["pos"]) > BRAZIER_REACH:
            continue
        if not (has_torch and torch_on):
            _say("El brasero necesita fuego. Enciende la antorcha.", 2.2)
            return true
        b["lit"] = true
        braziers_lit["%s:%d" % [_room_key(), i]] = true
        _sfx("fosforo", -6.0, 0.8)
        _sfx("k_campana", -12.0, 0.7)
        _emit(Vector2(b["pos"]) + Vector2(0, -30), 26, Color(1.0, 0.6, 0.25), 20.0, 90.0, 0.9, 2.0, -60.0, Vector2.UP, 0.9, true)
        var left: int = braziers.filter(func(x): return not bool(x["lit"])).size()
        if left == 0:
            _complete_mission()
            _say("Arde. %s" % ("Los tres braseros de la Cosecha están encendidos." if current_room >= 2 else "Falta el último, en la sala siguiente."), 3.5)
        else:
            _say("Un brasero arde. Queda %d." % left, 2.4)
        return true
    return false


func _harvest_strike() -> void:
    _light_brazier_quiet()
    if not elder_active or elder_state == "talk":
        return
    var to_e: Vector2 = elder_pos - player_pos
    if to_e.length() < STRIKE_RANGE + 16.0 and (to_e.length() < 26.0 or to_e.normalized().dot(strike_dir) > 0.2):
        _damage_elder(_strike_damage())


## Golpear un brasero con la antorcha también lo prende (sin mensajes extra).
func _light_brazier_quiet() -> void:
    for b in braziers:
        if not bool(b["lit"]) and player_pos.distance_to(b["pos"]) <= BRAZIER_REACH and has_torch and torch_on:
            _light_brazier()
            return


func _harvest_pulse() -> void:
    if not elder_active or elder_state == "talk":
        return
    if player_pos.distance_to(elder_pos) < _pulse_radius() + 16.0:
        _damage_elder(_pulse_damage())
        if elder_state in ["walk", "swipe"]:
            elder_state = "walk"
            elder_cd = maxf(elder_cd, 1.2)
            float_fx.append({"pos": elder_pos + Vector2(0, -90), "text": "ATURDIDO", "color": SOUL, "t": 0.0})


func _damage_elder(amount: float) -> void:
    var mult: float = 2.0 if elder_state == "tired" else 1.0
    elder_hp -= amount * mult
    elder_hit_t = 0.2
    float_fx.append({"pos": elder_pos + Vector2(randf_range(-10, 10), -86), "text": "-%d%s" % [int(amount * mult), " ×2" if mult > 1.0 else ""], "color": Color("#ffd36b"), "t": 0.0})
    _sfx("impacto", -8.0, 0.9)
    if elder_hp <= 0.0:
        _elder_defeat()


func _elder_defeat() -> void:
    elder_active = false
    elder_threads.clear()
    elder_stones.clear()
    banished[_room_key()] = true
    drops.append({"pos": elder_pos, "value": 40})
    _gain_xp(120)
    _complete_mission()
    dissolve_fx.append({"pos": elder_pos, "kind": "peregrino", "facing": elder_facing, "frame": 7, "t": 0.0})
    _emit(elder_pos + Vector2(0, -40), 50, Color(0.85, 0.2, 0.25), 30.0, 160.0, 1.2, 3.0, 120.0, Vector2.UP, 1.8)
    _say("El Hermano Mayor cae. La máscara se parte en dos. La Puerta sigue abierta.", 5.0)
    _sfx("destierro", -2.0, 0.8)
    for t in elder_traitors:
        t["cd"] = 999.0 # sin su líder, dejan de tirar piedras


## Al empezar la pelea: tus aliados eligen bando según tu marca.
func _elder_betray() -> void:
    elder_state = "walk"
    elder_cd = 1.6
    var mark: String = _mark()
    var alive: Array = allies.filter(func(a): return bool(a["alive"]))
    if alive.is_empty():
        elder_side = ""
        _say("«Nadie vendrá a ayudarte, {yo}.» Estás solo con él.".replace("{yo}", _hero_name()), 3.5)
    elif mark == "bendicion":
        elder_side = "contigo"
        _say("«¡No! Nos guiaste hasta aquí.» Tus aliados se ponen de tu lado.", 4.0)
    elif mark == "maldicion":
        elder_side = "contra"
        for i in range(alive.size()):
            elder_traitors.append({"name": alive[i]["name"], "pos": Vector2(820.0 - float(i % 2) * 40.0, 220.0 + float(i) * 70.0), "cd": 2.5 + float(i)})
            alive[i]["alive"] = false
            alive[i]["dead_key"] = "traidor"
        allies = allies.filter(func(a): return bool(a["alive"]))
        _say("«Nos dejaste atrás cuando te necesitábamos.» Tus aliados se unen a él.", 4.0)
    else:
        elder_side = "apartados"
        _say("Tus aliados retroceden. No se atreven a elegir.", 3.5)
    _sfx("grunido", -6.0, 0.7)


func _update_harvest(dt: float) -> void:
    elder_hit_t = maxf(0.0, elder_hit_t - dt)
    for s in elder_stones:
        s["t"] = float(s["t"]) - dt
        if float(s["t"]) <= 0.0:
            if player_pos.distance_to(s["pos"]) < 34.0 and dash_left <= 0.0 and damage_cd <= 0.0:
                hp -= 10.0
                damage_cd = 0.6
                _on_hurt()
            _emit(Vector2(s["pos"]), 10, Color(0.55, 0.52, 0.48), 20.0, 80.0, 0.5, 2.0, 150.0, Vector2.UP, 1.2)
    elder_stones = elder_stones.filter(func(s): return float(s["t"]) > 0.0)
    if not elder_active:
        return
    var step_v: Vector2 = player_pos - elder_last_player
    var moved: float = step_v.length()
    # La mirada robada a la Vigía: castiga darle la espalda (alejarte) o correr (esquivar).
    var fled: bool = (moved > 0.6 and step_v.dot(player_pos - elder_pos) > 0.0) or dash_left > 0.0
    elder_last_player = player_pos
    elder_t = maxf(0.0, elder_t - dt)
    elder_cd = maxf(0.0, elder_cd - dt)
    var look: Vector2 = player_pos - elder_pos
    if look.length() > 1.0:
        elder_facing = (2 if look.x > 0.0 else 3) if absf(look.x) > absf(look.y) else (0 if look.y > 0.0 else 1)
    if elder_state == "talk":
        if elder_t <= 0.0:
            _elder_betray()
        return
    fear = minf(100.0, fear + dt * 1.2)
    var enraged: bool = elder_hp < elder_max * 0.5
    # Aliados: de tu lado le golpean; en su contra te tiran piedras con aviso.
    elder_ally_cd = maxf(0.0, elder_ally_cd - dt)
    if elder_side == "contigo" and elder_ally_cd <= 0.0:
        elder_ally_cd = 3.0
        var n: int = _allies_alive()
        if n > 0:
            elder_hp -= 10.0 * float(n)
            elder_hit_t = 0.2
            float_fx.append({"pos": elder_pos + Vector2(0, -100), "text": "ALIADOS -%d" % (10 * n), "color": Color("#7fd6a0"), "t": 0.0})
            if elder_hp <= 0.0:
                _elder_defeat()
                return
    for t in elder_traitors:
        t["cd"] = float(t["cd"]) - dt
        if float(t["cd"]) <= 0.0:
            t["cd"] = 5.0
            elder_stones.append({"pos": player_pos, "t": 1.0})
    match elder_state:
        "walk":
            if look.length() > 70.0:
                var nxt: Vector2 = elder_pos + look.normalized() * ELDER_SPEED * (1.3 if enraged else 1.0) * dt
                if not _is_blocked(nxt):
                    elder_pos = Vector2(clampf(nxt.x, 110.0, 850.0), clampf(nxt.y, 200.0, 540.0))
            elif elder_cd <= 0.6:
                elder_state = "swipe"
                elder_t = 0.55
            if elder_cd <= 0.0:
                _elder_next_rule(enraged)
        "swipe":
            if elder_t <= 0.0:
                if look.length() < 80.0 and dash_left <= 0.0 and damage_cd <= 0.0:
                    hp -= ELDER_SWIPE_DAMAGE
                    damage_cd = 0.8
                    _on_hurt()
                elder_state = "walk"
                elder_cd = maxf(elder_cd, 1.0)
        "threads_aim":
            if elder_t <= 0.0:
                elder_state = "threads"
                elder_t = 2.6
                _sfx("k_metal", -6.0, 1.4)
        "threads":
            if dash_left <= 0.0 and damage_cd <= 0.0:
                for th in elder_threads:
                    if _dist_to_segment(player_pos, th[0], th[1]) < 12.0:
                        hp -= ELDER_THREAD_DAMAGE
                        damage_cd = 0.9
                        fear = minf(100.0, fear + 8.0)
                        _on_hurt()
                        break
            if elder_t <= 0.0:
                elder_threads.clear()
                elder_state = "walk"
                elder_cd = 1.8 if enraged else 2.4
        "roar":
            if elder_t <= 0.0:
                shake = maxf(shake, 0.6)
                _sfx("grunido", -2.0, 0.6)
                _emit(elder_pos + Vector2(0, -30), 40, Color(0.85, 0.3, 0.3), 80.0, 240.0, 0.7, 3.0, 0.0, Vector2.UP, PI)
                if look.length() < ELDER_ROAR_RADIUS and dash_left <= 0.0:
                    hp -= ELDER_ROAR_DAMAGE
                    fear = minf(100.0, fear + 15.0)
                    damage_cd = 0.8
                    _on_hurt()
                elder_state = "tired"
                elder_t = 2.5
        "tired":
            if elder_t <= 0.0:
                elder_state = "walk"
                elder_cd = 1.6 if enraged else 2.2
        "gaze":
            elder_tick = maxf(0.0, elder_tick - dt)
            if fled and elder_tick <= 0.0:
                elder_tick = 0.5
                hp -= ELDER_GAZE_TICK
                fear = minf(100.0, fear + 6.0)
                _on_hurt()
            if elder_t <= 0.0:
                elder_state = "walk"
                elder_cd = 1.8 if enraged else 2.4


func _elder_next_rule(enraged: bool) -> void:
    var rule: String = ELDER_RULES[elder_rule % ELDER_RULES.size()]
    elder_rule += 1
    match rule:
        "hilos":
            elder_state = "threads_aim"
            elder_t = 0.9
            elder_threads.clear()
            var p: Vector2 = player_pos
            elder_threads.append([Vector2(90, p.y), Vector2(870, p.y)])
            elder_threads.append([Vector2(p.x, 190), Vector2(p.x, 560)])
            if enraged:
                elder_threads.append([elder_pos, elder_pos + (p - elder_pos).normalized() * 900.0])
            _sfx("k_metal", -10.0, 1.8)
        "rugido":
            elder_state = "roar"
            elder_t = 1.1 if not enraged else 0.85
        "mirada":
            elder_state = "gaze"
            elder_t = 3.5
            elder_tick = 0.4
            _sfx("k_campana", -10.0, 0.5)


func _dist_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
    return p.distance_to(Geometry2D.get_closest_point_to_segment(p, a, b))


func _draw_brazier(i: int) -> void:
    var b: Dictionary = braziers[i]
    var at: Vector2 = b["pos"]
    _draw_soft_shadow(at + Vector2(0, 2), 18.0)
    draw_rect(Rect2(at.x - 6.0, at.y - 26.0, 12, 26), Color("#4a4352"))
    draw_colored_polygon(PackedVector2Array([at + Vector2(-22, -34), at + Vector2(22, -34), at + Vector2(14, -22), at + Vector2(-14, -22)]), Color("#6a5030"))
    draw_rect(Rect2(at.x - 22.0, at.y - 36.0, 44, 3), Color("#c9a25e"))
    if bool(b["lit"]):
        var f: float = 0.5 + 0.5 * sin(elapsed * 9.0 + at.x)
        for k in range(4, 0, -1):
            draw_circle(at + Vector2(0, -44), 10.0 + float(k) * 12.0, Color(1.0, 0.6, 0.25, 0.04))
        draw_colored_polygon(PackedVector2Array([at + Vector2(-14, -36), at + Vector2(14, -36), at + Vector2(4, -62 - 6.0 * f), at + Vector2(-2, -54)]), Color("#f08a3a"))
        draw_colored_polygon(PackedVector2Array([at + Vector2(-7, -36), at + Vector2(7, -36), at + Vector2(1, -52 - 4.0 * f)]), Color("#ffd36b"))
    else:
        draw_rect(Rect2(at.x - 12.0, at.y - 38.0, 24, 4), Color("#2a2420"))


func _draw_elder() -> void:
    var sheet: Texture2D = art["enemy_peregrino"]
    var frame: int = int(elapsed * 2.0) % 2
    match elder_state:
        "walk":
            frame = 2 + int(elapsed * 8.0) % 4
        "threads_aim", "roar", "swipe":
            frame = 6
        "threads", "gaze":
            frame = 7
        "tired":
            frame = 0
    if elder_npc:
        frame = int(elapsed * 2.0) % 2
    var scale: float = 1.35
    var cell: Vector2 = ENEMY_CELL * scale
    var feet := Vector2(roundf(elder_pos.x), roundf(elder_pos.y + 4.0))
    _draw_soft_shadow(elder_pos + Vector2(0, 3), 18.0)
    if elder_active and elder_state == "roar":
        var k: float = 1.0 - clampf(elder_t / 1.1, 0.0, 1.0)
        _draw_ellipse(elder_pos, ELDER_ROAR_RADIUS * k, ELDER_ROAR_RADIUS * 0.45 * k, Color(1.0, 0.2, 0.2, 0.1 + 0.15 * k))
        draw_arc(elder_pos, ELDER_ROAR_RADIUS, 0, TAU, 64, Color(1.0, 0.3, 0.3, 0.35 + 0.4 * k), 2.0)
    var tint := Color(1.0, 0.86, 0.7)
    if elder_hit_t > 0.0:
        tint = Color(1.0, 0.45, 0.4)
    elif elder_state == "tired":
        tint = Color(0.8, 0.85, 1.0)
    draw_texture_rect_region(sheet, Rect2(feet.x - cell.x * 0.5, feet.y - ENEMY_FEET_Y * scale, cell.x, cell.y), Rect2(float(frame) * ENEMY_CELL.x, float(elder_facing) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y), tint)
    # Diadema de la Cosecha: lo distingue del resto de peregrinos.
    var head: Vector2 = feet + Vector2(0, -ENEMY_FEET_Y * scale + 12.0)
    draw_rect(Rect2(head.x - 10.0, head.y, 20, 3), Color("#e3bd7b"))
    draw_colored_polygon(PackedVector2Array([head + Vector2(-3, 0), head + Vector2(3, 0), head + Vector2(0, -6)]), Color("#e3bd7b"))
    if elder_active and elder_state == "gaze":
        var g: float = 0.6 + 0.4 * sin(elapsed * 10.0)
        draw_circle(head + Vector2(-4, 10), 2.5, Color(1.0, 0.3, 0.3, g))
        draw_circle(head + Vector2(4, 10), 2.5, Color(1.0, 0.3, 0.3, g))
        for k in range(3, 0, -1):
            draw_circle(head + Vector2(0, 10), 8.0 + float(k) * 8.0, Color(1.0, 0.2, 0.2, 0.05))
    if elder_active and elder_state == "tired":
        _label_center("AGOTADO", feet + Vector2(0, -ENEMY_FEET_Y * scale - 14.0), Color("#8fc7d7"))


func _draw_elder_threads() -> void:
    for th in elder_threads:
        var live: bool = elder_state == "threads"
        var a: float = 0.85 if live else 0.25 + 0.5 * (1.0 - clampf(elder_t / 0.9, 0.0, 1.0))
        draw_line(th[0], th[1], Color(0.9, 0.12, 0.18, a), 3.0 if live else 1.0)
        if live:
            draw_line(th[0], th[1], Color(1.0, 0.6, 0.6, 0.35), 7.0)
    for s in elder_stones:
        var k: float = 1.0 - clampf(float(s["t"]), 0.0, 1.0)
        _draw_ellipse(s["pos"], 34.0, 14.0, Color(1.0, 0.3, 0.2, 0.12 + 0.2 * k))
        draw_circle(Vector2(s["pos"]) + Vector2(0, -160.0 * (1.0 - k)), 5.0, Color("#7d7a72"))


func _draw_traitor(i: int) -> void:
    var t: Dictionary = elder_traitors[i]
    var sheet: Texture2D = art["enemy_peregrino"]
    var at: Vector2 = t["pos"]
    var frame: int = 6 if float(t["cd"]) < 0.6 else int(elapsed * 2.0 + float(i)) % 2
    _draw_soft_shadow(at + Vector2(0, 3), 12.0)
    _draw_ellipse(at + Vector2(0, 3), 17.0, 6.0, Color(0.9, 0.2, 0.25, 0.18))
    draw_texture_rect_region(sheet, Rect2(at.x - ENEMY_CELL.x * 0.5, at.y + 4.0 - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y), Rect2(float(frame) * ENEMY_CELL.x, 3.0 * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y), Color(1.0, 0.7, 0.7))


func _draw_harvest_hud() -> void:
    for b in braziers:
        if not bool(b["lit"]) and player_pos.distance_to(b["pos"]) < 150.0:
            _label_center(_prompt("ENCENDER BRASERO") if has_torch and torch_on else "BRASERO · ENCIENDE LA ANTORCHA", Vector2(b["pos"]) + Vector2(0, -74), Color("#ffd36b"))
    if elder_npc and player_pos.distance_to(elder_pos) < 170.0:
        _label_center("HERMANO MAYOR", elder_pos + Vector2(0, -100), CREAM)
    if not elder_active or elder_state == "talk":
        return
    var box := Rect2(300, 146, 360, 34) # por debajo de los avisos de arriba
    _panel(box, Color(0.06, 0.04, 0.06, 0.9), UI_GOLD)
    var rule: String = {"threads_aim": "HILOS", "threads": "HILOS", "roar": "RUGIDO", "tired": "AGOTADO", "gaze": "MIRADA"}.get(elder_state, "")
    _text_outline("EL HERMANO MAYOR" + ("  ·  " + rule if rule != "" else ""), Vector2(box.position.x, box.position.y + 16.0), 12, CREAM, box.size.x)
    var bar := Rect2(box.position.x + 10.0, box.position.y + 21.0, box.size.x - 20.0, 7)
    draw_rect(bar, Color(0, 0, 0, 0.7))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(elder_hp / elder_max, 0.0, 1.0), bar.size.y)), Color("#b3263a"))
    if elder_side != "":
        var side_txt: String = {"contigo": "TUS ALIADOS LUCHAN CONTIGO", "contra": "TUS ALIADOS SE UNIERON A ÉL", "apartados": "TUS ALIADOS SE APARTAN"}[elder_side]
        _text_outline(side_txt, Vector2(box.position.x, box.end.y + 14.0), 11, Color("#7fd6a0") if elder_side == "contigo" else (Color("#ff8a8a") if elder_side == "contra" else Color("#9a957f")), box.size.x)


# ------------------------------------------------------------ COFRES
## Cofres que dejaron otros que pasaron antes. Cada uno se abre una sola vez
## por perfil; dentro hay un objeto al azar (mejor cuanto más hondo) y una
## nota de quien lo dejó.
const Botin := preload("res://scripts/botin.gd")
const CHEST_REACH := 62.0
var chests_opened: Dictionary = {} # "piso:sala" -> clave del objeto
var chest_open_t: float = 0.0


func _chest_here() -> bool:
    return not in_tutorial and _room().has("chest")


func _chest_pos() -> Vector2:
    return (_room()["chest"] as Array)[0]


func _chest_is_open() -> bool:
    return chests_opened.has(_room_key())


func _chest_obstacle() -> void:
    if _chest_here():
        var p: Vector2 = _chest_pos()
        obstacles.append(Rect2(p.x - 18.0, p.y - 10.0, 36.0, 12.0))


func _open_chest() -> bool:
    if not _chest_here() or _chest_is_open() or player_pos.distance_to(_chest_pos()) > CHEST_REACH:
        return false
    var rng := RandomNumberGenerator.new()
    rng.randomize()
    var key: String = Botin.sortear(1 + current_floor, rng)
    chests_opened[_room_key()] = key
    var item_name: String = _grant_loot(key)
    chest_open_t = 1.0
    _save_progress()
    _sfx("sello", -6.0, 1.3)
    _sfx("alma", -8.0, 0.9)
    _emit(_chest_pos() + Vector2(0, -18), 22, Color(1.0, 0.85, 0.45), 20.0, 80.0, 0.9, 2.0, -40.0, Vector2.UP, 0.8, true)
    var note: String = str((_room()["chest"] as Array)[1]).replace("{yo}", _hero_name())
    _dialog([["NOTA EN EL COFRE", note]])
    _say("Dentro del cofre: %s." % item_name, 3.5)
    return true


## Da un objeto del botín a la partida en curso (en memoria; luego se guarda).
func _grant_loot(key: String) -> String:
    match key:
        "brazalete_up", "amuleto_up":
            var t: String = key.trim_suffix("_up")
            if trinkets.has(t):
                trinket_levels[t] = mini(Botin.NIVEL_OBJETO_MAX, int(trinket_levels.get(t, 1)) + 1)
            else:
                trinkets.append(t)
                trinket_levels[t] = 1
        "resonancia_up":
            if has_pulse:
                ability_level = mini(Botin.NIVEL_HABILIDAD_MAX, ability_level + 1)
            else:
                has_pulse = true
        _:
            bag[key] = int(bag.get(key, 0)) + 1
    return str(Botin.OBJETOS.get(key, [key])[0])


func _draw_chest() -> void:
    var at: Vector2 = _chest_pos()
    var opened: bool = _chest_is_open()
    _draw_soft_shadow(at + Vector2(0, 2), 22.0)
    var body := Rect2(at.x - 20.0, at.y - 22.0, 40, 22)
    draw_rect(body, Color("#5a3b22"))
    draw_rect(Rect2(body.position.x, body.position.y + 8.0, body.size.x, 3), Color("#3a2414"))
    draw_rect(Rect2(at.x - 3.0, body.position.y, 6, body.size.y), Color("#b8955a"))
    draw_rect(body, Color("#1b120a"), false, 1.0)
    if opened:
        # Tapa abierta, hacia atrás.
        draw_colored_polygon(PackedVector2Array([Vector2(body.position.x, body.position.y), Vector2(body.end.x, body.position.y), Vector2(body.end.x - 3.0, body.position.y - 14.0), Vector2(body.position.x + 3.0, body.position.y - 14.0)]), Color("#4a2f1a"))
        draw_rect(Rect2(body.position.x + 3.0, body.position.y - 2.0, body.size.x - 6.0, 3), Color("#140c06"))
    else:
        draw_rect(Rect2(body.position.x - 1.0, body.position.y - 8.0, body.size.x + 2.0, 9), Color("#6b4528"))
        draw_rect(Rect2(at.x - 3.0, body.position.y - 8.0, 6, 9), Color("#c9a25e"))
        draw_rect(Rect2(at.x - 2.0, body.position.y - 1.0, 4, 4), Color("#2a2420"))
        var g: float = 0.5 + 0.5 * sin(elapsed * 3.0 + at.x)
        draw_circle(Vector2(at.x + 12.0, body.position.y - 6.0), 1.5 + g, Color(1.0, 0.9, 0.6, 0.35 + 0.4 * g))


func _draw_chest_label() -> void:
    if not _chest_here() or _chest_is_open() or game_mode != "play":
        return
    if player_pos.distance_to(_chest_pos()) < 150.0:
        _label_center(_prompt("ABRIR COFRE"), _chest_pos() + Vector2(0, -44), Color("#ffd36b"))


# ------------------------------------------------------------ MAPA GRANDE Y DESCENSO
## Tocar el minimapa (o M / Select del mando) abre el mapa a pantalla grande.
## Pestaña 0: el piso actual sala por sala. Pestaña 1: el descenso, que se va
## dibujando con cada piso al que bajas.
const MAP_PANEL := Rect2(48, 34, 864, 572)
const MAP_TAB_RECTS := [Rect2(330, 92, 140, 34), Rect2(490, 92, 140, 34)]
const MINIMAP_RECT := Rect2(634, 6, 258, 96)
var map_tab: int = 0
var map_return: String = "play"


func _open_map() -> void:
    if not game_mode in ["play", "pause"] or in_tutorial:
        return
    map_return = game_mode
    game_mode = "map"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -9.0)


func _close_map() -> void:
    game_mode = map_return
    _sfx("interfaz", -12.0, 0.9)


func _map_key(k: int) -> void:
    if k in [KEY_M, KEY_ESCAPE, KEY_E, KEY_ENTER] or k == _key("interactuar"):
        _close_map()
    elif k in [KEY_TAB, KEY_RIGHT, KEY_D, KEY_LEFT, KEY_A, KEY_PAGEDOWN, KEY_PAGEUP]:
        map_tab = 1 - map_tab
        _sfx("toque", -14.0, 1.0)


func _map_tap(at: Vector2) -> void:
    for i in range(2):
        if (MAP_TAB_RECTS[i] as Rect2).grow(6.0).has_point(at):
            map_tab = i
            _sfx("toque", -14.0, 1.0)
            return
    _close_map()


func _floor_reached() -> int:
    return maxi(max_floor, current_floor)


func _floor_cleared(i: int) -> bool:
    return i < max_floor or (str(FLOORS[i].get("eco", "")) != "" and ecos.has(str(FLOORS[i]["eco"])))


func _deaths_on_floor(i: int) -> int:
    var n: int = 0
    for key in death_marks:
        if str(key).begins_with("%d:" % i):
            n += (death_marks[key] as Array).size()
    return n


func _draw_map() -> void:
    draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.72))
    _panel(MAP_PANEL, Color(0.035, 0.032, 0.045, 0.97), UI_GOLD)
    _title_text("Mapa", Vector2(MAP_PANEL.position.x, MAP_PANEL.position.y + 44.0), 40, CREAM, MAP_PANEL.size.x)
    var names := ["ESTE PISO", "DESCENSO"]
    for i in range(2):
        var r: Rect2 = MAP_TAB_RECTS[i]
        var on: bool = i == map_tab
        _panel(r, Color("#2a1d36") if on else Color("#141018"), UI_GOLD if on else UI_EDGE)
        _text_outline(names[i], Vector2(r.position.x, r.position.y + 22.0), 13, CREAM if on else Color("#8a8574"), r.size.x)
    if map_tab == 0:
        _draw_map_floor()
    else:
        _draw_map_descent()
    _text_outline(_hint("M / ESC: cerrar · TAB: pestaña", "Toca una pestaña · toca fuera para cerrar", "B: cerrar · cruceta: pestaña"), Vector2(MAP_PANEL.position.x, MAP_PANEL.end.y - 14.0), 11, Color("#8a8574"), MAP_PANEL.size.x)


func _draw_map_floor() -> void:
    var count: int = _room_count()
    _text_outline("PISO %s · %s" % [_floor()["number"], _tc(_floor()["title"])], Vector2(MAP_PANEL.position.x, 160.0), 16, UI_GOLD, MAP_PANEL.size.x)
    var card := Vector2(146, 230)
    var gap: float = 22.0
    var total: float = float(count) * card.x + float(count - 1) * gap
    var x0: float = roundf(W * 0.5 - total * 0.5)
    var y0: float = 196.0
    for i in range(count):
        var r := Rect2(x0 + float(i) * (card.x + gap), y0, card.x, card.y)
        var room: Dictionary = _floor()["rooms"][i]
        var seen: bool = i <= current_room
        if i < count - 1:
            draw_rect(Rect2(r.end.x, r.position.y + card.y * 0.5 - 3.0, gap, 6.0), UI_GOLD if i < current_room else Color("#2a2e38"))
        var here: bool = i == current_room
        var pulse: float = 0.6 + 0.4 * sin(elapsed * 4.0)
        _panel(r, Color(0.78, 0.67, 0.43, 0.18 + 0.1 * pulse) if here else (Color("#1d212b") if seen else Color("#0e1016")), UI_GOLD if here else (UI_LIGHT if seen else Color("#2a2e38")))
        if not seen:
            _text_outline("???", Vector2(r.position.x, r.get_center().y + 8.0), 22, Color("#4a4e5a"), r.size.x)
            continue
        var parts: PackedStringArray = str(room["name"]).split(" · ")
        _text_outline(parts[0], Vector2(r.position.x, r.position.y + 26.0), 15, UI_GOLD, r.size.x)
        draw_multiline_string(font, Vector2(r.position.x + 8.0, r.position.y + 50.0), _tc(parts[parts.size() - 1]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16.0, 12, 4, CREAM)
        var y: float = r.position.y + 130.0
        if room.has("mission"):
            var done: bool = i < current_room or (here and _room_ready())
            draw_multiline_string(font, Vector2(r.position.x + 8.0, y - 10.0), ("✓ " if done else "· ") + str(room["mission"]["text"]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16.0, 10, 3, Color("#7fd6a0") if done else Color("#d9d2ba"))
            y += 40.0
        if room.has("chest"):
            var key: String = "%d:%d" % [current_floor, i]
            _text_outline("COFRE ABIERTO" if chests_opened.has(key) else "COFRE", Vector2(r.position.x, y), 10, Color("#8a8574") if chests_opened.has(key) else Color("#ffd36b"), r.size.x)
            y += 20.0
        var deaths: int = (death_marks.get("%d:%d" % [current_floor, i], []) as Array).size()
        if deaths > 0:
            _text_outline("Caíste aquí %d %s" % [deaths, "vez" if deaths == 1 else "veces"], Vector2(r.position.x, y), 10, Color("#ff8a8a"), r.size.x)
        if here:
            _text_outline("ESTÁS AQUÍ", Vector2(r.position.x, r.end.y - 12.0), 11, CREAM, r.size.x)


## El descenso: solo se dibujan los pisos a los que has bajado, y uno más
## por descubrir. El pozo crece a medida que avanzas.
func _draw_map_descent() -> void:
    var reached: int = _floor_reached()
    var rows: int = mini(FLOORS.size(), reached + 2)
    var top: float = 150.0
    var row_h: float = minf(38.0, 380.0 / float(maxi(rows, 1)))
    var shaft_x: float = 170.0
    draw_rect(Rect2(shaft_x - 2.0, top + 8.0, 4.0, row_h * float(rows - 1)), Color("#3a3440"))
    for i in range(rows):
        var y: float = top + float(i) * row_h
        var known: bool = i <= reached
        var here: bool = i == current_floor
        var cleared: bool = known and _floor_cleared(i)
        var dot_col: Color = UI_GOLD if here else (Color("#7fd6a0") if cleared else (CREAM if known else Color("#4a4e5a")))
        draw_circle(Vector2(shaft_x, y + 10.0), 8.0 if here else 6.0, dot_col)
        if here:
            draw_arc(Vector2(shaft_x, y + 10.0), 13.0 + 2.0 * sin(elapsed * 4.0), 0, TAU, 24, UI_GOLD, 2.0)
        if not known:
            _text_outline("PISO ???  ·  más abajo", Vector2(shaft_x + 24.0, y + 15.0), 13, Color("#4a4e5a"))
            continue
        _text_outline("PISO %s" % FLOORS[i]["number"], Vector2(shaft_x + 24.0, y + 15.0), 13, UI_GOLD)
        _text_outline(_tc(FLOORS[i]["title"]), Vector2(shaft_x + 110.0, y + 15.0), 13, CREAM)
        var tag: String = "AQUÍ" if here else ("SUPERADO" if cleared else "")
        if tag != "":
            _text_outline(tag, Vector2(560.0, y + 15.0), 11, UI_GOLD if here else Color("#7fd6a0"))
        var d: int = _deaths_on_floor(i)
        if d > 0:
            _text_outline("%d %s" % [d, "caída" if d == 1 else "caídas"], Vector2(660.0, y + 15.0), 11, Color("#ff8a8a"))
        var opened: int = 0
        var total_chests: int = 0
        for r in range((FLOORS[i]["rooms"] as Array).size()):
            if (FLOORS[i]["rooms"][r] as Dictionary).has("chest"):
                total_chests += 1
                if chests_opened.has("%d:%d" % [i, r]):
                    opened += 1
        if total_chests > 0:
            _text_outline("cofres %d/%d" % [opened, total_chests], Vector2(760.0, y + 15.0), 11, Color("#ffd36b") if opened < total_chests else Color("#8a8574"))
    # Lo descubierto en el último piso superado, como recuerdo del descenso.
    var last: int = -1
    for i in range(FLOORS.size()):
        if i <= reached and _floor_cleared(i):
            last = i
    if last >= 0 and last < Pisos.FLOOR_TRUTHS.size():
        draw_multiline_string(font, Vector2(MAP_PANEL.position.x + 60.0, 560.0), "«%s»" % str(Pisos.FLOOR_TRUTHS[last]), HORIZONTAL_ALIGNMENT_CENTER, MAP_PANEL.size.x - 120.0, 12, 2, Color("#9fb3b3"))
