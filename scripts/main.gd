## [VISUAL UPGRADE]
extends Node2D
## Primer piso. Adaptación de los tres documentos GDD, Lore v0.2 y Reglas v0.1.
## Knowledge Temple + GothicVania reales incorporados desde los ZIP aportados.
## Mecánicas no canonizadas se indican como provisionales en docs/DECISIONES.md.

const W: float = 960.0
const H: float = 640.0
const ARENA: Rect2 = Rect2(40.0, 122.0, 880.0, 458.0)
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
const Actualizador := preload("res://scripts/actualizador.gd")
const Estilo := preload("res://scripts/ui/estilo.gd")
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
    # Armas y equipo (herramientas/generar_equipo.py).
    "daga": preload("res://assets/visual/iconos/daga.png"),
    "espada": preload("res://assets/visual/iconos/espada.png"),
    "lanza": preload("res://assets/visual/iconos/lanza.png"),
    "hacha": preload("res://assets/visual/iconos/hacha.png"),
    "maza": preload("res://assets/visual/iconos/maza.png"),
    "yelmo": preload("res://assets/visual/iconos/yelmo.png"),
    "peto": preload("res://assets/visual/iconos/peto.png"),
    "botas": preload("res://assets/visual/iconos/botas.png"),
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
    "descansar": preload("res://assets/visual/iconos/descansar.png"),
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
## Texto: Jersey 15 reescalada (herramientas/generar_fuente.py), legible y con cifras claras.
const PIXEL_FONT := preload("res://assets/fonts/Jersey15-Templo.ttf")
## Personaje creado por el jugador (se guarda con el progreso).
var player_name: String = ""
var player_gender: String = "masculino" # masculino | femenino
## Pantalla actual: title, create, play, altar, inventory, floor_intro, dead,
## victory… Al cambiar, el gestor de pantallas muestra la escena que le toca
## (splash, menú y pausa ya son escenas propias: scenes/pantallas/).
var game_mode: String = "title":
    set(v):
        var antes: String = game_mode
        game_mode = v
        if is_node_ready():
            _sync_screens()
            if antes != v:
                Eventos.pantalla_cambiada.emit(antes, v)
## Escenas hijas (main.tscn): pantallas de interfaz y capa de avisos.
@onready var pantallas: CanvasLayer = $Pantallas
@onready var avisos: Control = $CapaAvisos/Avisos
## Busca versiones nuevas en GitHub (solo en copias exportadas).
var actualizador: Node = null
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
    # Tipografía pixel (Jersey 15, OFL), sin suavizado para que encaje con el pixel art.
    font = PIXEL_FONT
    _pixel_font_setup(font)
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
    pantallas.accion.connect(_on_screen_action)
    Eventos.sonido_pedido.connect(_sfx)
    _start_updater()
    # Al abrir el juego se ve la pantalla de inicio; al volver de la Vigilia, el menú.
    game_mode = "title" if Engine.has_meta("splash_visto") else "splash"
    _load_progress()
    _load_art()
    _load_room_scene() # sala 1 como fondo del menú
    _setup_post()
    _setup_transition()
    _setup_fullscreen()
    _setup_glow()
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
    _sync_screens()
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
    if not Progreso.existe():
        return
    var data: Dictionary = Progreso.cargar()
    if not data.is_empty():
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
        souls = maxi(0, int(data.get("souls", 0)))
        vigil_unlocked = bool(data.get("vigil_unlocked", false))
        odon_told = bool(data.get("odon_told", false))
        var w_saved: String = str(data.get("weapon", ""))
        weapon = w_saved if WEAPONS.has(w_saved) else ""
        gear_owned = data.get("gear_owned", {}) if data.get("gear_owned", {}) is Dictionary else {}
        unworn = data.get("unworn", {}) if data.get("unworn", {}) is Dictionary else {}
        var g_saved = data.get("gear", {})
        gear = {}
        if g_saved is Dictionary:
            for slot in g_saved:
                if GEAR.has(str(g_saved[slot])):
                    gear[str(slot)] = str(g_saved[slot])
        var saved_cp = data.get("checkpoint", [-1, -1])
        checkpoint = [int(saved_cp[0]), int(saved_cp[1])] if saved_cp is Array and (saved_cp as Array).size() == 2 else [-1, -1]
        var saved_chests = data.get("chests_opened", {})
        chests_opened = saved_chests if saved_chests is Dictionary else {}
        var saved_trinkets = data.get("trinkets", [])
        trinkets = (saved_trinkets as Array).filter(func(e): return str(e) in ["brazalete", "amuleto"]) if saved_trinkets is Array else []

func _save_progress() -> void:
    Progreso.guardar({
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
        "chests_opened": chests_opened,
        "souls": souls,
        "vigil_unlocked": vigil_unlocked,
        "odon_told": odon_told,
        "weapon": weapon,
        "gear": gear,
        "gear_owned": gear_owned,
        "unworn": unworn,
        "checkpoint": checkpoint
    })


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
    # Las almas se conservan entre partidas: son tu moneda (se guardan).
    floor_souls0 = souls
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
    _set_checkpoint()
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
    _load_hazards()
    _load_vines()
    _load_labyrinth()
    _load_merchant()
    _load_gaze()
    _load_colossus_room()
    _load_harvest_room()
    _chest_obstacle()
    if _fountain_here():
        obstacles.append(Rect2(FOUNTAIN_POS.x - 12.0, FOUNTAIN_POS.y - 10.0, 24.0, 10.0))
    _place_wall_props()
    _load_critters()
    _place_gear_pickup()
    player_vel = Vector2.ZERO
    dash_ghosts.clear()
    _update_camera(0.0, true)
    door_state = "unknown"
    if game_mode == "floor_intro":
        avisos.callar() # el susurro se oye al pulsar ENTRAR
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
    _extend_room_tiles()
    obstacles.clear()
    var scene_shapes: Array = []
    for shape in room_node.find_children("*", "CollisionShape2D", true, false):
        var rect_shape := (shape as CollisionShape2D).shape as RectangleShape2D
        if rect_shape == null or (shape as CollisionShape2D).disabled:
            continue
        var center: Vector2 = (shape as Node2D).global_position - global_position
        scene_shapes.append(Rect2(center - rect_shape.size * 0.5, rect_shape.size))
    # Los objetos los dibuja este script, ordenados por profundidad con los
    # personajes; en el editor se ven y se mueven como Sprite2D normales.
    room_props.clear()
    _update_backdrop()
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
    # Colisiones: las bajas (losas, cofres, tumbas vistas desde arriba) se
    # quedan como están; las de objetos altos se rehacen con la huella real
    # de su dibujo, solo donde la silueta toca el suelo.
    for r in scene_shapes:
        obstacles.append(_shape_footprint(r))
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
    if pantallas.posee(game_mode):
        _input_screen_scene(event)
        return
    _input_game(event)
    # Si esta tecla abrió una pantalla-escena (p. ej. ESC → pausa), el mismo
    # evento no debe llegarle también a ella (la cerraría al instante).
    if pantallas.posee(game_mode) and is_inside_tree():
        get_viewport().set_input_as_handled()


func _input_game(event: InputEvent) -> void:
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
    elif event is InputEventMouseMotion:
        ui_hover = make_input_local(event).position
        if game_mode == "inventory":
            var slot_h: int = _inventory_slot_at(ui_hover)
            if slot_h >= 0:
                inventory_sel = slot_h
        queue_redraw()
        return
    elif event is InputEventMouseButton and event.pressed and event.device == InputEvent.DEVICE_ID_EMULATION:
        # Cada toque llega dos veces: como InputEventScreenTouch (ya atendido) y
        # como clic emulado. Se ignora el clic: abría el perfil, el mapa o el
        # inventario y el mismo toque lo volvía a cerrar, y duplicaba letras.
        return
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var click_at: Vector2 = make_input_local(event).position
        _click_spark(click_at)
        if game_mode == "inventory":
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
    if k == KEY_F11 or (k == KEY_ENTER and event.alt_pressed):
        # F11 o Alt+Enter: pantalla completa / ventana, en cualquier pantalla.
        Ajustes.poner("pantalla_completa", not bool(Ajustes.obtener("pantalla_completa")))
        _apply_window_mode()
        return
    if game_mode == "inventory":
        if k in [_key("perfil"), KEY_TAB, KEY_ESCAPE, KEY_E]:
            _close_inventory()
        elif k == _key("habilidades"):
            _open_abilities()
        elif k == KEY_O:
            _profile_switch_tab()
        elif k in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
            _profile_use_selected()
        elif k in [KEY_RIGHT, KEY_D]:
            inventory_sel = (inventory_sel % 100 + 1) % _inventory_slot_count()
        elif k in [KEY_LEFT, KEY_A]:
            inventory_sel = (inventory_sel % 100 + _inventory_slot_count() - 1) % _inventory_slot_count()
        elif k in [KEY_DOWN, KEY_S]:
            inventory_sel = (inventory_sel % 100 + (OBJECT_COLS if profile_tab == 1 else 3)) % _inventory_slot_count()
        elif k in [KEY_UP, KEY_W]:
            var step: int = OBJECT_COLS if profile_tab == 1 else 3
            inventory_sel = (inventory_sel % 100 + _inventory_slot_count() - step) % _inventory_slot_count()
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


## Splash, menú y pausa son escenas con botones de verdad: el ratón, los
## toques, el teclado y el mando les llegan por la interfaz de Godot. Aquí solo
## se atiende lo global (pantalla completa) y se recuerda con qué se juega.
func _input_screen_scene(event: InputEvent) -> void:
    # La escena decide con los datos de ahora mismo (no los del último cuadro).
    if game_mode in LIVE_SCREENS:
        pantallas.refrescar(game_mode, _screen_data(game_mode))
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        pad_active = true
    elif event is InputEventKey or event is InputEventMouseButton:
        pad_active = false
    if event is InputEventMouseMotion:
        ui_hover = make_input_local(event).position
    if event is InputEventKey and event.pressed and not event.echo:
        var k: Key = event.keycode
        if k == KEY_F11 or (k == KEY_ENTER and event.alt_pressed):
            Ajustes.poner("pantalla_completa", not bool(Ajustes.obtener("pantalla_completa")))
            _apply_window_mode()
            get_viewport().set_input_as_handled()


## Datos que necesita cada pantalla-escena para mostrarse.
func _screen_data(mode: String) -> Dictionary:
    var d := {"margen": screen_pad, "entrada": "mando" if pad_active else ("tactil" if touch_enabled else "teclado")}
    match mode:
        "splash":
            d["subtitulo"] = _t("subtitulo")
            d["continuar"] = _t("continuar_tactil") if touch_enabled else _t("continuar")
            d["ajustes"] = _t("ajustes")
            d["version"] = Actualizador.version_local()
        "title":
            d["nombre"] = player_name
            d["id"] = identity_number
            d["muertes"] = deaths
            d["retrato"] = _portrait(false)
            d["vigilia_abierta"] = vigil_unlocked
            d["ultimo_piso"] = FLOORS[FLOORS.size() - 1]["number"]
            d["ayuda"] = _hint("ENTER  jugar (elegir piso)   ·   H  vigilia   ·   ESC  salir", "Toca JUGAR para elegir piso", _t("mando_titulo"))
            d["cambiar"] = _t("cambiar_pj")
            d["sin_personaje"] = _t("sin_pj")
            d["actualizador"] = actualizador
        "settings":
            d["pestana"] = int(settings_open.get("pestana", 0))
            d["legal"] = str(settings_open.get("legal", ""))
            d["ruta_progreso"] = _save_path()
        "floors":
            d["pisos"] = _floor_cards()
            d["seleccion"] = floors_sel
            d["ayuda"] = _hint("Flechas elegir · ENTER descender · ESC volver", "Toca un piso y luego DESCENDER", "Cruceta elegir · A descender · B volver")
        "dialog":
            if not dialog_queue.is_empty():
                var who: String = dialog_queue[0][0]
                var text: String = dialog_queue[0][1]
                d["quien"] = who
                d["color_quien"] = _speaker_color(who)
                d["texto"] = text
                d["letras"] = int(dialog_chars)
                var tap: String = _hint("clic / E", "toca", "A")
                d["mas"] = "" if int(dialog_chars) < text.length() else ("»  " + tap if dialog_queue.size() > 1 else "»  " + tap + " para cerrar")
            d["tecla_interactuar"] = _key("interactuar")
        "choice":
            d["quien"] = str(choice.get("speaker", ""))
            d["texto"] = str(choice.get("text", ""))
            d["opciones"] = choice.get("options", [])
            d["ayuda"] = _hint("1 / 2 · ←/→ + ENTER · ESC: pensarlo", "Toca una opción", "Cruceta + A · B: pensarlo")
            d["tecla_interactuar"] = _key("interactuar")
        "floor_intro":
            d["numero"] = _floor()["number"]
            d["titulo"] = _tc(_floor()["title"])
            if floor_intro_eco != "":
                var eco: Array = ECOS[floor_intro_eco]
                d["eco_ganado"] = "POR SUPERAR EL PISO ANTERIOR GANASTE EL ECO «%s»: %s" % [eco[0], eco[1]]
            # La recompensa de este piso, dicha antes de entrar.
            var own: String = str(_floor().get("eco", ""))
            if own != "" and ECOS.has(own):
                d["recompensa"] = "RECOMPENSA AL SUPERAR ESTE PISO: ECO «%s» (habilidad pasiva)%s" % [ECOS[own][0], " · ya lo tienes" if ecos.has(own) else ""]
            elif bool(_floor().get("final", false)):
                d["recompensa"] = "AL SUPERAR ESTE PISO: el final del primer arco"
            d["ayuda"] = _hint("ENTRAR  ·  ENTER", "TOCA PARA ENTRAR", "ENTRAR  ·  A")
        "floor_summary":
            d["numero"] = summary.get("floor", "")
            d["titulo"] = _tc(str(summary.get("title", "")))
            d["filas"] = [["Tiempo", summary.get("time", "")], ["Almas ganadas", "%+d" % int(summary.get("souls", 0))],
                ["Muertes", str(summary.get("deaths", 0))], ["Misiones", str(summary.get("missions", ""))],
                ["Alimañas aplastadas", str(summary.get("critters", 0))], ["Aliados con vida", str(summary.get("allies", ""))]]
            var eco_s: String = str(summary.get("eco", ""))
            if eco_s != "" and ECOS.has(eco_s):
                d["eco_icono"] = ICONS.get("eco_" + eco_s, null)
                d["eco_texto"] = "POR SUPERAR EL PISO %s GANAS EL ECO «%s»" % [summary.get("floor", ""), ECOS[eco_s][0]]
                d["eco_detalle"] = ECOS[eco_s][1]
            d["verdad"] = str(summary.get("truth", ""))
            d["ayuda"] = _hint("ENTER / clic: seguir descendiendo", "Toca para seguir descendiendo", "A: seguir descendiendo")
        "dead", "victory":
            _end_screen_data(d, mode == "victory")
        "altar":
            d["ofertas"] = _altar_offers()
            d["almas"] = souls
            d["icono_alma"] = ICONS["alma"]
            d["ayuda"] = _hint("E / ESC: salir", "Toca fuera para salir", "B: salir")
            d["seleccion"] = clampi(inventory_sel, 0, 1)
        "shop":
            _shop_screen_data(d)
        "intro":
            var slide: Array = INTRO[clampi(intro_slide, 0, INTRO.size() - 1)]
            d["tipo"] = slide[2]
            d["fundido"] = clampf(intro_t * 1.5, 0.0, 1.0)
            d["abrir"] = clampf(intro_t * 0.8, 0.0, 1.0)
            d["texto"] = _lang_pick(slide).substr(0, int(intro_t * 38.0))
            d["indice"] = intro_slide
            d["total"] = INTRO.size()
            d["siguiente"] = _t("siguiente")
            d["hoja"] = _hero_sheet()
            d["alma"] = ICONS["alma"]
            d["cuerpos"] = CORPSES
            d["t"] = elapsed
        "create":
            d["paso"] = create_step
            d["nombre"] = create_buf
            d["nombre_limpio"] = _clean_name(create_buf)
            d["genero"] = create_gender
            d["max"] = NAME_MAX
            d["hojas"] = [art["visual_hero"], HERO_SHEET_F]
            d["retratos"] = [PORTRAIT, PORTRAIT_F]
        "abilities":
            _abilities_screen_data(d)
        "map":
            _map_screen_data(d)
        "pause":
            d["titulo"] = _tc(_t("pausa"))
            d["opciones"] = _pause_options().map(func(id): return [id, _t(id)])
            d["aviso_abandono"] = _t("aviso_abandono")
            d["tecla_pausa"] = _key("pausa")
    return d


## Pantalla de muerte o de victoria: qué se cuenta según cómo terminó.
func _end_screen_data(d: Dictionary, win: bool) -> void:
    var lines: Array = []
    var hint: String
    var hint_y: float = 418.0
    var title := func(text: String, y: float, color: Color) -> void:
        lines.append({"texto": text, "y": y, "tam": 48, "color": color, "gotico": true})
    var line := func(text: String, y: float, size: int, color: Color = CREAM) -> void:
        lines.append({"texto": text, "y": y, "tam": size, "color": color})
    if win and bool(_floor().get("final", false)):
        title.call("Fin del primer arco", 214.0, SOUL)
        line.call("La Puerta de la Cosecha no lleva a la salida, sino a otros escalones.", 262.0, 17)
        line.call("«Esto no es una salida. Es una transición.»", 300.0, 20, Color("#e3bd7b"))
        line.call("En el marco, doscientas marcas de alas: este lugar es solo uno de muchos.", 338.0, 15, Color("#9fb3b3"))
        line.call("Continuará.", 376.0, 16)
        hint = _hint("ENTER: volver a empezar  ·  ESC: menú", "Toca para volver a empezar", "A: volver a empezar  ·  B: menú")
        hint_y = 430.0
    elif win:
        line.call("PISO %s SUPERADO" % _floor()["number"], 230.0, 33, SOUL)
        line.call("No has escapado. El siguiente nivel sigue oculto.", 280.0, 18)
        line.call("Nada es lo que parece.", 318.0, 16)
        hint = _hint("ENTER: repetir prueba  ·  ESC: menú", "Toca para repetir la prueba", "A: repetir prueba  ·  B: menú")
    elif soul_fate == "persistencia":
        d["vineta"] = clampf(death_fx / 1.2, 0.0, 1.0) if death_fx >= 0.0 else 1.0
        title.call("%s ha caído" % _tc(_hero_name()), 240.0, Color("#d0475a"))
        line.call("Este lugar todavía no te reclama.", 278.0, 18)
        line.call("Conservas almas, objetos, habilidades y ecos.", 318.0, 17)
        line.call("(Modo de pruebas: la muerte no cuesta progreso.)", 352.0, 15, Color("#9fb3b3"))
        hint = _hint("ENTER: levantarte en la entrada de la sala  ·  ESC: menú", "Toca para levantarte en la entrada de la sala", "A: levantarte  ·  B: menú")
    elif soul_fate == "retorno":
        line.call("TU ALMA HA REGRESADO", 230.0, 30, SOUL)
        line.call("Resultado aleatorio de la muerte: reencarnación (50 %).", 278.0, 18)
        line.call("Eres la misma persona. Conservas memoria y habilidades.", 318.0, 17)
        line.call("Los niveles de habilidad regresaron a cero.", 352.0, 17)
        hint = _hint("ENTER: reaparecer al inicio  ·  ESC: menú", "Toca para reaparecer al inicio", "A: reaparecer  ·  B: menú")
    else:
        line.call("ALMA ABSORBIDA", 230.0, 32, RED)
        line.call("Resultado aleatorio: absorción definitiva (50 %).", 278.0, 18)
        line.call("La persona anterior ha dejado de existir.", 318.0, 17)
        line.call("Un nuevo humano ocupará el lugar, sin sus recuerdos.", 352.0, 17)
        hint = _hint("ENTER: iniciar nueva identidad  ·  ESC: menú", "Toca para iniciar una nueva identidad", "A: nueva identidad  ·  B: menú")
    d["lineas"] = lines
    d["aviso"] = {"texto": hint, "y": hint_y}
    # Se lee primero: hasta END_LOCK los toques y teclas de más no la cierran.
    d["espera"] = 1.0 if _end_ready() else clampf(end_t / END_LOCK, 0.0, 1.0)
    d["t"] = end_t


## Habilidades y Ecos de la página que toca (scenes/pantallas/habilidades.tscn).
func _abilities_screen_data(d: Dictionary) -> void:
    abil_page = clampi(abil_page, 0, _abil_pages() - 1)
    var rows: Array = _ability_rows()
    var per_a: int = _abil_per_page()
    var shown_rows: Array = []
    for i in range(abil_page * per_a, mini(rows.size(), (abil_page + 1) * per_a)):
        var row: Array = rows[i]
        shown_rows.append({"icono": ICONS[row[0]], "nombre": row[1], "tecla": row[2], "detalle": row[3], "tiene": row[4], "coste": row[5]})
    var keys: Array = ECOS.keys()
    var per_e: int = _eco_per_page()
    var shown_ecos: Array = []
    for i in range(abil_page * per_e, mini(keys.size(), (abil_page + 1) * per_e)):
        shown_ecos.append({"icono": ICONS["eco_" + str(keys[i])], "nombre": ECOS[keys[i]][0], "detalle": ECOS[keys[i]][1], "tiene": ecos.has(keys[i])})
    d["filas"] = shown_rows
    d["ecos"] = shown_ecos
    d["vacia"] = abil_page * per_a >= rows.size()
    d["resumen_ecos"] = "%d de %d Ecos despiertos: uno por cada piso superado." % [ecos.size(), keys.size()]
    var pages: int = _abil_pages()
    d["pagina"] = abil_page
    d["paginas"] = pages
    d["arriba"] = ABIL_TOP
    d["alto_fila"] = ABIL_ROW_H
    d["alto_eco"] = ECO_ROW_H
    d["tecla_habilidades"] = _key("habilidades")
    var paging: String = " · ◀ ▶ páginas" if pages > 1 else ""
    d["ayuda"] = _hint("%s / ESC: cerrar%s" % [_key_label("habilidades"), paging], "Flechas: páginas · toca fuera para cerrar" if pages > 1 else "Toca para cerrar", "B: cerrar%s" % (" · cruceta/LB: páginas" if pages > 1 else ""))


## Mapa grande: lo que se sabe de cada sala de este piso y del descenso.
func _map_screen_data(d: Dictionary) -> void:
    d["pestana"] = map_tab
    d["tecla_interactuar"] = _key("interactuar")
    d["ayuda"] = _hint("M / ESC: cerrar · TAB: pestaña", "Toca una pestaña · toca fuera para cerrar", "B: cerrar · cruceta: pestaña")
    d["titulo_piso"] = "PISO %s · %s" % [_floor()["number"], _tc(_floor()["title"])]
    var rooms: Array = []
    var links: Array = []
    for i in range(_room_count()):
        var room: Dictionary = _floor()["rooms"][i]
        var here: bool = i == current_room
        var r := {"vista": i <= current_room, "aqui": here}
        links.append(i < current_room)
        if i <= current_room:
            var parts: PackedStringArray = str(room["name"]).split(" · ")
            r["numero"] = parts[0]
            r["nombre"] = _tc(parts[parts.size() - 1])
            if room.has("mission"):
                r["mision"] = str(room["mission"]["text"])
                r["mision_hecha"] = i < current_room or (here and _room_ready())
            if room.has("chest"):
                var open: bool = chests_opened.has("%d:%d" % [current_floor, i])
                r["cofre"] = "COFRE ABIERTO" if open else "COFRE"
                r["color_cofre"] = Color("#8a8574") if open else Color("#ffd36b")
            var fell: int = (death_marks.get("%d:%d" % [current_floor, i], []) as Array).size()
            if fell > 0:
                r["caidas"] = "Caíste aquí %d %s" % [fell, "vez" if fell == 1 else "veces"]
        rooms.append(r)
    d["salas"] = rooms
    d["enlaces"] = links
    var reached: int = _floor_reached()
    var floors_rows: Array = []
    var last_cleared: int = -1
    for i in range(mini(FLOORS.size(), reached + 2)):
        var known: bool = i <= reached
        var cleared: bool = known and _floor_cleared(i)
        var f := {"conocido": known, "aqui": i == current_floor, "superado": cleared}
        if known:
            if cleared:
                last_cleared = i
            f["numero"] = FLOORS[i]["number"]
            f["titulo"] = _tc(FLOORS[i]["title"])
            f["etiqueta"] = "AQUÍ" if i == current_floor else ("SUPERADO" if cleared else "")
            var fell2: int = _deaths_on_floor(i)
            if fell2 > 0:
                f["caidas"] = "%d %s" % [fell2, "caída" if fell2 == 1 else "caídas"]
            var opened: int = 0
            var total_chests: int = 0
            for r2 in range((FLOORS[i]["rooms"] as Array).size()):
                if (FLOORS[i]["rooms"][r2] as Dictionary).has("chest"):
                    total_chests += 1
                    if chests_opened.has("%d:%d" % [i, r2]):
                        opened += 1
            if total_chests > 0:
                f["cofres"] = "cofres %d/%d" % [opened, total_chests]
                f["color_cofres"] = Color("#ffd36b") if opened < total_chests else Color("#8a8574")
        floors_rows.append(f)
    d["pisos"] = floors_rows
    # Lo descubierto en el último piso superado, como recuerdo del descenso.
    if last_cleared >= 0 and last_cleared < Pisos.FLOOR_TRUTHS.size():
        d["verdad"] = str(Pisos.FLOOR_TRUTHS[last_cleared])


## Ofertas del altar: Resonancia (o su mejora) y Llama Interior.
func _altar_offers() -> Array:
    var offers := [
        ["resonancia", "[1] RESONANCIA" if not has_pulse else "[1] MEJORAR RESONANCIA", "Onda (Q) que daña y aturde a las entidades cercanas." if not has_pulse else "Nivel %d → %d: la onda hace más daño." % [ability_level, ability_level + 1], 14 if not has_pulse else RESONANCE_UPGRADE_BASE + RESONANCE_UPGRADE_STEP * ability_level, has_pulse and ability_level >= ABILITY_LEVEL_MAX, "NIVEL MÁXIMO"],
        ["llama_interior", "[2] LLAMA INTERIOR", "Enciendes la antorcha sin gastar fósforos.", INNER_FLAME_PRICE, has_inner_flame, "ADQUIRIDA"],
    ]
    var out: Array = []
    for o in offers:
        out.append({"icono": ICONS[o[0]], "titulo": o[1], "detalle": o[2],
            "derecha": o[5] if o[4] else "%d ALMAS" % o[3],
            "color_derecha": SOUL if o[4] else (CREAM if souls >= o[3] else RED)})
    return out


## Puesto del Mercader: filas, almas y la ficha de la Vigilia.
func _shop_screen_data(d: Dictionary) -> void:
    match _mark():
        "bendicion":
            d["nota"] = "  ·  BENDICIÓN: te cobra menos"
        "maldicion":
            d["nota"] = "  ·  MALDICIÓN: te cobra más"
    var rows: Array = []
    for i in range(SHOP.size()):
        var item: Array = SHOP[i]
        var maxed: bool = _shop_maxed(i)
        rows.append({"icono": ICONS.get(item[0], ICONS["descansar"]), "nombre": item[1], "detalle": item[3], "tenue": maxed,
            "derecha": ("COMPRADA" if item[0] == "vigilia" else "MÁXIMO") if maxed else "%d ALMAS" % _shop_price(i),
            "color_derecha": SOUL if maxed else (CREAM if souls >= _shop_price(i) else RED),
            "llevas": _shop_owned_text(i), "destello": float(shop_flash.get(i, 0.0))})
    d["filas"] = rows
    d["almas"] = souls
    d["icono_alma"] = ICONS["alma"]
    d["vida"] = "VIDA MÁXIMA: %d" % int(max_hp)
    d["color_vida"] = RED if hand_lost else CREAM
    d["ayuda"] = _hint("ENTER comprar · ESC salir", "Toca para comprar · fuera para salir", "A comprar · B salir")
    d["seleccion"] = shop_sel
    d["info"] = shop_info
    var price: int = _shop_price(shop_sel)
    d["ficha"] = {"icono": VIGIL_ICON, "filas": VIGIL_INFO, "precio": price, "puede": souls >= price, "almas": souls}
    d["tecla_interactuar"] = _key("interactuar")


## Pantallas que cambian mientras se ven: se les pasan datos nuevos cada cuadro.
const LIVE_SCREENS := ["dialog", "dead", "victory", "shop", "altar", "intro", "create", "abilities", "map"]


## Muestra la escena de la pantalla actual (o ninguna) y ajusta los avisos.
func _sync_screens() -> void:
    if pantallas == null:
        return
    pantallas.mostrar(game_mode, _screen_data(game_mode) if pantallas.posee(game_mode) else {})
    avisos.en_juego = game_mode == "play"
    avisos.ocultar_rotulos = game_mode in ["title", "create", "floors", "splash", "eula", "intro"]


## Lo que el jugador elige en una pantalla-escena.
func _on_screen_action(screen: StringName, choice: StringName, value: Variant = null) -> void:
    match screen:
        &"Acuerdo":
            match choice:
                &"aceptar":
                    _accept_eula()
                &"leer":
                    _open_settings("eula", 3, "acuerdo")
                &"salir":
                    _ask_quit()
        &"Pisos":
            match choice:
                &"piso":
                    floors_sel = int(value)
                    _choose_floor(floors_sel)
                &"marcar":
                    _sfx("toque", -14.0, 1.0)
                &"volver":
                    game_mode = "title"
                    _sfx("interfaz", -10.0, 0.8)
        &"Ajustes":
            match choice:
                &"volver":
                    _close_settings()
                &"repetir_tutorial":
                    Ajustes.poner("tutorial_hecho", false)
                    _start_tutorial()
                &"ver_intro":
                    _start_intro("title")
                &"borrar":
                    _wipe_everything()
                &"ventana":
                    _apply_window_mode()
                &"actualizaciones":
                    _start_updater()
                &"tactil":
                    _apply_touch_setting()
        &"Splash":
            if choice == &"ajustes":
                _open_settings("splash")
            else:
                _splash_continue()
        &"Titulo":
            match choice:
                &"jugar":
                    _open_floors() # los pisos son la entrada al juego
                &"vigilia":
                    _open_defense()
                &"salir":
                    _ask_quit()
                &"ajustes":
                    _open_settings("title")
                &"cambiar_personaje":
                    _start_creation("title")
        &"Dialogo":
            if choice == &"saltar":
                _dialog_skip()
            else:
                _dialog_advance()
        &"Eleccion":
            if choice == &"opcion":
                _choice_pick(int(value))
            else:
                _choice_cancel()
        &"EntradaPiso":
            _enter_floor()
        &"ResumenPiso":
            _after_floor_summary()
        &"Final":
            # Se lee primero: los toques y teclas de más no la cierran.
            if _end_ready():
                if choice == &"menu":
                    game_mode = "title"
                else:
                    _after_end()
        &"Altar":
            if choice == &"comprar":
                inventory_sel = int(value) - 1
                _buy_upgrade(int(value))
            else:
                game_mode = "play"
                _sfx("interfaz", -12.0, 0.9)
        &"Tienda":
            match choice:
                &"elegir":
                    shop_sel = int(value)
                    _shop_choose(shop_sel)
                &"info_si":
                    shop_info = false
                    _shop_buy(shop_sel)
                &"info_no":
                    shop_info = false
                    _sfx("interfaz", -12.0, 0.9)
                &"salir":
                    _close_shop()
        &"Intro":
            if choice == &"saltar":
                _end_intro()
            else:
                _intro_next()
        &"Creacion":
            match choice:
                &"letra":
                    _create_type(str(value))
                    _name_edit_sync()
                &"borrar":
                    create_buf = create_buf.substr(0, maxi(0, create_buf.length() - 1))
                    _sfx("toque", -14.0, 0.8)
                    _name_edit_sync()
                &"espacio":
                    _create_type(" ")
                    _name_edit_sync()
                &"azar":
                    create_buf = RANDOM_NAMES[randi() % RANDOM_NAMES.size()]
                    _sfx("toque", -12.0, 1.2)
                    _name_edit_sync()
                &"siguiente":
                    _create_next()
                &"genero":
                    create_gender = int(value)
                    _sfx("toque", -14.0, 1.0)
                &"comenzar":
                    _create_finish()
                &"atras":
                    _create_back()
                &"foco_nativo":
                    _name_edit_focus() # tocar el recuadro del nombre abre el teclado del móvil
        &"Habilidades":
            if choice == &"pagina":
                _abil_turn(int(value))
            else:
                _close_abilities()
        &"Mapa":
            match choice:
                &"pestana":
                    map_tab = int(value)
                    _sfx("toque", -14.0, 1.0)
                &"cambiar":
                    map_tab = 1 - map_tab
                    _sfx("toque", -14.0, 1.0)
                _:
                    _close_map()
        &"Pausa":
            var opts: Array = _pause_options()
            if opts.has(String(choice)):
                _pause_choose(opts.find(String(choice)))
    if pantallas.posee(game_mode):
        pantallas.refrescar(game_mode, _screen_data(game_mode))
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
    if dpad.has(b):
        _pad_menu_step(dpad[b])
        return
    match game_mode:
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
    match b:
        JOY_BUTTON_A, JOY_BUTTON_START:
            _pad_key(KEY_ENTER)
        JOY_BUTTON_B, JOY_BUTTON_BACK:
            _pad_key(KEY_ESCAPE)


func _pad_menu_step(dir: Vector2i) -> void:
    _pad_key(_pad_dir_key(dir))


## Teclado en pantalla para el nombre: la cruceta mueve un recuadro sobre las
## teclas (se reutiliza el resaltado de «cursor encima»).
## Mueve la selección a la tecla más cercana en esa dirección.
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


## La Vigilia se compra al Mercader Silencioso (Piso VI) por VIGIL_PRICE almas.
## Así, cuando se juega, el botín que da ya tiene sentido en la campaña.
const VIGIL_PRICE := 500
var vigil_unlocked: bool = false


func _open_defense() -> void:
    if not vigil_unlocked:
        _say("La Vigilia está cerrada. Alguien en las profundidades guarda su llave.", 3.2)
        _sfx("toque", -10.0, 0.8)
        return
    Escenas.ir_a("res://scenes/defense.tscn")

func _mobile_touch(finger: int, at: Vector2, pressed: bool) -> void:
    if not pressed:
        if finger == mobile_finger:
            mobile_finger = -1
            mobile_axis = Vector2.ZERO
            joy_center = _joy_home()
        queue_redraw()
        return
    if game_mode == "play" and at.x <= JOY_ZONE_X and at.y >= JOY_ZONE_Y:
        mobile_finger = finger
        # Joystick flotante: si el dedo cae lejos de la base, la base va al dedo.
        if at.distance_to(joy_center) > JOY_RADIUS + 10.0:
            joy_center = Vector2(clampf(at.x, 90.0 - screen_pad.x, JOY_ZONE_X - 40.0), clampf(at.y, JOY_ZONE_Y + 50.0, 560.0 + screen_pad.y))
        _mobile_update_axis(at)
    else:
        _mobile_tap(at)
    queue_redraw()

func _mobile_update_axis(at: Vector2) -> void:
    mobile_axis = ((at - joy_center) / 68.0).limit_length(1.0)
    queue_redraw()

func _mobile_tap(at: Vector2) -> void:
    ui_hover = at
    if game_mode == "inventory":
        if PROFILE_ABIL_BTN.has_point(at):
            _open_abilities()
            return
        for t in range(3):
            if _profile_tab_rect(t).has_point(at):
                if profile_tab != t:
                    profile_tab = t
                    inventory_sel = 0
                    _sfx("toque", -14.0, 1.0)
                return
        if profile_tab == 2:
            for i in range(EQUIP_SLOTS.size()):
                if _equip_slot_rect(i).has_point(at):
                    inventory_sel = i
                    _equip_tap(i)
                    return
            for i in range(8):
                if _equip_owned_rect(i).has_point(at):
                    inventory_sel = 10 + i
                    _equip_tap(10 + i)
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
        var at: Vector2 = _tb_pos(id)
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
                label = "RUGIDO" if _mask_worn() else "ONDA"
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
    if _mask_worn():
        _sfx("grunido", -4.0, 1.4) # Rugido: la máscara amplifica la onda
    for h in hounds:
        if player_pos.distance_to(h["pos"]) < _pulse_radius() + 12.0:
            h["flee"] = 5.0 if _mask_worn() else 3.0
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
    # Una sola mano: con un arma empuñada, F la guarda y saca la antorcha;
    # con la antorcha encendida y un arma guardada, F la apaga y empuña el arma.
    if weapon != "" and has_torch:
        stowed_weapon = weapon
        weapon = ""
        _say("Guardas %s y sacas la antorcha." % str(WEAPONS[stowed_weapon]["name"]).to_lower(), 1.8)
    elif torch_on and stowed_weapon != "" and gear_owned.has(stowed_weapon):
        torch_on = false
        weapon = stowed_weapon
        stowed_weapon = ""
        _sfx("k_metal", -10.0, 1.2)
        _say("Apagas la antorcha y empuñas %s." % str(WEAPONS[weapon]["name"]).to_lower(), 1.8)
        return
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
    if matches <= 0 and not in_tutorial:
        _say("No te quedan fósforos. Búscalos o compra la Llama interior.", 2.8)
        _sfx("toque", -10.0)
        return
    _spend_match()
    torch_on = true
    _sfx("fosforo", -7.0)
    _say("Antorcha encendida. Fósforos: %s." % _matches_label(), 1.8)


## En el tutorial nada se gasta: fósforos y objetos sin límite, para practicar.
func _spend_match() -> void:
    if not in_tutorial:
        matches -= 1


func _matches_label() -> String:
    return "∞" if in_tutorial else str(matches)


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
    if has_torch or not has_wood or (matches <= 0 and not in_tutorial):
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


## EQUIPO Y MOCHILA: arriba lo que llevas (madera, fósforos, antorcha) y,
## bajo su título, las HABILIDADES NATIVAS (llama interior, golpe, Resonancia).
func _inventory_slot_rect(i: int) -> Rect2:
    return Rect2(372.0 + float(i % 3) * 168.0, 116.0 + float(i / 3) * 128.0, 160.0, 98.0)


## OBJETOS: rejilla de 4 × 3 (doce huecos; ya no se pierden los del séptimo en adelante).
const OBJECT_COLS := 4
const OBJECT_SLOTS_MAX := 12
func _object_slot_rect(i: int) -> Rect2:
    return Rect2(372.0 + float(i % OBJECT_COLS) * 126.0, 104.0 + float(i / OBJECT_COLS) * 84.0, 118.0, 78.0)


func _inventory_slot_count() -> int:
    if profile_tab == 2:
        return EQUIP_SLOTS.size()
    return OBJECT_SLOTS_MAX if profile_tab == 1 else INVENTORY_SLOTS.size()


func _inventory_slot_at(at: Vector2) -> int:
    if profile_tab == 2:
        return -1 # EQUIPO tiene sus propios huecos (se resuelven antes)
    for i in range(_inventory_slot_count()):
        if (_object_slot_rect(i) if profile_tab == 1 else _inventory_slot_rect(i)).has_point(at):
            return i
    for i in range(ECOS.size()):
        if _profile_eco_rect(i).has_point(at):
            return 100 + i
    return -1


func _profile_eco_rect(i: int) -> Rect2:
    return Rect2(372.0 + float(i) * 49.0, 382.0, 44.0, 44.0) # caben los diez Ecos


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
    if not (has_torch and torch_on) and weapon == "":
        return false
    var wcost: float = _weapon_stat("cost")
    if strike_cd > 0.0 or stamina < wcost:
        return true
    strike_cd = _weapon_stat("cd")
    stamina -= wcost
    strike_fx = 0.25
    strike_dir = player_dir.normalized() if player_dir.length() > 0.1 else Vector2.RIGHT
    visual_interaction_left = 0.24
    if weapon != "":
        _sfx("k_metal", -6.0, 1.3 if weapon == "daga" else (0.75 if weapon in ["hacha", "maza"] else 1.0))
        _sfx("toque", -12.0, 0.7) # silbido del tajo, sin chisporroteo de fuego
    else:
        _sfx("golpe", -7.0)
    if in_tutorial:
        var to_d := DUMMY_POS - player_pos
        if to_d.length() < _strike_range() + 14.0 and (to_d.length() < 26.0 or to_d.normalized().dot(strike_dir) > 0.2):
            dummy_hits += 1
            dummy_shake = 0.25
            float_fx.append({"pos": DUMMY_POS + Vector2(26, -60), "text": "-%d" % int(_strike_damage()), "color": Color("#ffd36b"), "t": 0.0})
            _sfx("impacto", -8.0, 1.2)
    if _pilgrim_present() and _pilgrim_can_be_hit():
        var to_p := pilgrim_pos - player_pos
        if to_p.length() < _strike_range() + 10.0 and (to_p.length() < 24.0 or to_p.normalized().dot(strike_dir) > 0.25):
            _damage_pilgrim(_strike_damage())
            var shove := pilgrim_pos + to_p.normalized() * 16.0
            if not _is_blocked(shove):
                pilgrim_pos = shove
    if has_torch and torch_on:
        _try_ignite(player_pos + strike_dir * 28.0)
    _strike_hounds_and_rescue()
    _strike_rams_and_pillars()
    _harvest_strike()
    for cr in critters:
        if bool(cr["alive"]):
            var to_c: Vector2 = Vector2(cr["pos"]) - player_pos
            if to_c.length() < _strike_range() + 12.0 and (to_c.length() < 24.0 or to_c.normalized().dot(strike_dir) > 0.2):
                _critter_die(cr)
    if _enemy_active():
        var to := enemy_pos - player_pos
        if to.length() < _strike_range() + 10.0 and (to.length() < 24.0 or to.normalized().dot(strike_dir) > _weapon_stat("arc")):
            if _damage_enemy(_strike_damage()):
                enemy_stun = maxf(enemy_stun, _weapon_stat("stun"))
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
    if _give_odon_message():
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
    if _enemy_blocks_door():
        return false
    if _mission_pending(true):
        return false
    if _door_roots_left() > 0:
        return false
    return _pilgrim_allows_exit()


## Toda sala con una entidad de verdad (Ghoul, Hechicero, Segador, Tejedora,
## Testigo) se cierra hasta desterrarla. Mastines, arietes, la vigía y el
## Coloso no cuentan: no son «el enemigo de la sala».
const DOOR_ENEMIES := ["ghoul", "hechicero", "segador", "tejedora", "testigo"]
const ENEMY_TITLES := {"ghoul": "AL GHOUL", "hechicero": "AL HECHICERO", "segador": "AL SEGADOR", "tejedora": "A LA TEJEDORA", "testigo": "AL TESTIGO"}
func _enemy_blocks_door() -> bool:
    return not in_tutorial and _enemy_kind() in DOOR_ENEMIES and _enemy_active()


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
    guides_refused = false
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
    checkpoint = [-1, -1]
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
    avisos.decir(message, duration)


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


## Radio de los pies del jugador (y de quien camina): antes 15,5, ahora más
## ajustado para pasar cómodo entre columnas y estanterías.
const FOOT_RADIUS := 11.0


## Huella de un objeto en el suelo, leída de sus píxeles: las filas opacas
## más bajas de su silueta (la base, las patas, el pedestal) y el ancho que
## ocupan ahí. Lo que sobresale por arriba (capiteles, cuencos, brazos) no choca.
var footprint_cache: Dictionary = {}


func _alpha_footprint(tex: Texture2D, dest: Rect2, flip: bool, region: Rect2 = Rect2()) -> Rect2:
    if tex == null:
        return Rect2()
    var key: String = "%s|%s" % [tex.resource_path if tex.resource_path != "" else str(tex.get_rid()), str(region)]
    var local: Rect2
    if footprint_cache.has(key):
        local = footprint_cache[key]
    else:
        var img: Image = tex.get_image()
        if img == null:
            return Rect2()
        if img.is_compressed():
            img.decompress()
        var reg: Rect2i = Rect2i(region) if region.size != Vector2.ZERO else Rect2i(Vector2i.ZERO, img.get_size())
        var bottom: int = -1
        for y in range(reg.end.y - 1, reg.position.y - 1, -1):
            var n: int = 0
            for x in range(reg.position.x, reg.end.x):
                if img.get_pixel(x, y).a > 0.5:
                    n += 1
                    if n >= 3:
                        break
            if n >= 3:
                bottom = y
                break
        if bottom < 0:
            return Rect2()
        # Columnas cuyo píxel opaco más bajo queda cerca del suelo: son las
        # que apoyan (patas, base, libros de la fila de abajo…).
        var band: int = maxi(3, int(reg.size.y * 0.1))
        var reach: int = maxi(4, int(reg.size.y * 0.22))
        var x0: int = reg.end.x
        var x1: int = reg.position.x - 1
        for x in range(reg.position.x, reg.end.x):
            for y in range(bottom, maxi(reg.position.y, bottom - reach) - 1, -1):
                if img.get_pixel(x, y).a > 0.5:
                    x0 = mini(x0, x)
                    x1 = maxi(x1, x)
                    break
        local = Rect2(float(x0 - reg.position.x), float(bottom - band + 1 - reg.position.y), float(x1 - x0 + 1), float(band))
        footprint_cache[key] = local
    var size_src: Vector2 = region.size if region.size != Vector2.ZERO else tex.get_size()
    var k := dest.size / size_src
    var x: float = local.position.x * k.x
    if flip:
        x = dest.size.x - (local.position.x + local.size.x) * k.x
    var fp := Rect2(dest.position + Vector2(x, local.position.y * k.y), local.size * k)
    # Altura máxima de la huella: una franja junto al suelo.
    var h: float = minf(fp.size.y, 16.0)
    return Rect2(fp.position.x + 2.0, fp.end.y - h, maxf(4.0, fp.size.x - 4.0), h)


## Colisión de la escena → huella real del objeto que la tiene debajo.
func _shape_footprint(r: Rect2) -> Rect2:
    if r.size.y <= 24.0:
        return r # baja: la escena ya la marca bien
    var best = null
    var best_area: float = 0.0
    for prop in room_props:
        var pr: Rect2 = prop["rect"]
        var inter: Rect2 = pr.intersection(r)
        if inter.get_area() > best_area:
            best_area = inter.get_area()
            best = prop
    if best != null:
        var fp: Rect2 = _alpha_footprint(best["tex"], best["rect"], bool(best["flip"]))
        if fp.size.x > 2.0 and fp.end.y > r.position.y:
            return fp
    return _tighten_obstacle(r)


## Los objetos altos (columnas, estanterías, estatuas) solo chocan por su
## base, como en una vista cenital: se puede pasar por detrás de ellos.
func _tighten_obstacle(r: Rect2) -> Rect2:
    if r.size.y <= 24.0:
        return r
    var h: float = 20.0
    return Rect2(r.position.x + r.size.x * 0.08, r.end.y - h, r.size.x * 0.84, h)


## Choca con un objeto de la sala (no con los muros): para el polvo del impacto.
func _hits_obstacle(at: Vector2) -> bool:
    for rect in obstacles:
        if rect.grow(FOOT_RADIUS).has_point(at):
            return true
    return false


func _is_blocked(at: Vector2) -> bool:
    if at.x < 63.0 or at.x > 895.0 or at.y < 155.0 or at.y > 552.0:
        return true
    for rect in obstacles:
        if rect.grow(FOOT_RADIUS).has_point(at):
            return true
    return false


func _process(delta: float) -> void:
    if name_edit != null and name_edit.visible and (game_mode != "create" or create_step != 0):
        _name_edit_close()
    elapsed += delta
    if game_mode == "intro":
        intro_t += delta # el texto de la intro se escribe solo
    _update_camera(delta)
    end_t = end_t + delta if game_mode in ["dead", "victory"] else 0.0
    _tick_glow(delta)
    _update_pad_repeat(delta)
    _update_level_fx(delta)
    for i in shop_flash.keys():
        shop_flash[i] = maxf(0.0, float(shop_flash[i]) - delta * 1.8)
    if game_mode in LIVE_SCREENS:
        pantallas.refrescar(game_mode, _screen_data(game_mode))
    avisos.ancla = world_xf * player_pos
    avisos.zoom = cam_zoom
    avisos.tactil = touch_enabled
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
    position = screen_pad + (Vector2(sin(elapsed * 47.0) + 0.6 * sin(elapsed * 83.0), cos(elapsed * 41.0) + 0.6 * sin(elapsed * 67.0)) * 0.6 * shake * shake * 14.0 if shake > 0.0 else Vector2.ZERO)
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
    for gh in dash_ghosts:
        gh["t"] = float(gh["t"]) + dt
    dash_ghosts = dash_ghosts.filter(func(gh): return float(gh["t"]) < 0.22)
    enemy_stun = maxf(0.0, enemy_stun - dt)
    stamina = minf(100.0, stamina + _stamina_regen() * dt)
    var move: Vector2 = _controls_axis()
    var walk: float = WALK_SPEED * (1.05 if ecos.has("paso") else 1.0) * _gear_speed_mult()
    # Movimiento con inercia corta: arranca y frena en décimas de segundo, sin
    # tirones. El esquive sale disparado y se frena solo, y su impulso enlaza
    # con el paso normal (curva de velocidad, no un salto de 157 a 480).
    var target: Vector2
    if dash_left > 0.0:
        var p: float = 1.0 - dash_left / DASH_TIME
        target = dash_dir * lerpf(DASH_PEAK, DASH_END, p * p)
        player_vel = target
    else:
        target = move * walk
        var rate: float = WALK_ACCEL if move.length_squared() > 0.001 else WALK_DECEL
        player_vel = player_vel.move_toward(target, rate * dt)
    player_moving = player_vel.length() > 12.0
    if move.length_squared() > 0.001 and dash_left <= 0.0:
        player_dir = move
    elif dash_left > 0.0:
        player_dir = dash_dir
    if player_moving:
        var nx := Vector2(player_pos.x + player_vel.x * dt, player_pos.y)
        var blocked_x: bool = absf(player_vel.x) > walk * 0.3 and _hits_obstacle(nx)
        if not _is_blocked(nx):
            player_pos.x = nx.x
        else:
            player_vel.x = 0.0
        var ny := Vector2(player_pos.x, player_pos.y + player_vel.y * dt)
        var blocked_y: bool = absf(player_vel.y) > walk * 0.3 and _hits_obstacle(ny)
        if not _is_blocked(ny):
            player_pos.y = ny.y
        else:
            player_vel.y = 0.0
        if dash_left > 0.0:
            dash_ghost_t -= dt
            if dash_ghost_t <= 0.0:
                dash_ghost_t = 0.035
                dash_ghosts.append({"pos": player_pos, "dir": player_dir, "t": 0.0})
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
    if gear_pickup.size() > 0 and player_pos.distance_to(gear_pickup["pos"]) < 30.0:
        _take_gear()
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
    _update_side_doors(dt)
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
    _update_hazards(dt)
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
    _begin_world()
    _draw_side_fade()
    _end_world()
    if room_node == null:
        draw_rect(_full_rect(), BG)
    elif game_mode in ["title", "create", "floors", "splash", "eula"] or (game_mode == "settings" and settings_return in ["title", "splash", "eula", "floors"]):
        # En el menú se ve la sala completa, con sus objetos, detrás del panel.
        var objetos: Node = room_node.get_node_or_null("Objetos")
        if objetos != null:
            (objetos as CanvasItem).visible = true
    _draw_background()
    var screen: String = settings_return if game_mode == "settings" else game_mode
    if screen in ["title", "create", "floors", "splash", "eula", "intro"]:
        # Inicio, menú, acuerdo, pisos, intro, creación y configuración son
        # escenas (scenes/pantallas/): aquí solo queda la sala de fondo.
        return
    _begin_world()
    _draw_room()
    _end_world()
    _draw_topbar()
    _draw_footer()
    _draw_mission_banner()
    _draw_room_souls_counter()
    _draw_room_fade()
    # Altar, tienda, elección, diálogo, resumen, muerte/victoria y entrada al
    # piso son escenas (scenes/pantallas/), por encima de esto.
    if game_mode == "inventory":
        _draw_inventory_overlay()
    _draw_tutorial_overlay()
    _draw_mobile_controls()
    # Los avisos de nivel y de botín los dibuja la capa de avisos
    # (scenes/ui/avisos.tscn), encima de cualquier menú.


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
    _draw_kprop_books()
    _draw_gear_pickup()
    _draw_prop_shadows()
    # Nuevos efectos ambientales; no forman parte de colisiones ni IA.
    _draw_visual_atmosphere()
    # Objetos a ras de suelo: siempre por debajo de personajes y estatuas.
    _draw_side_doors()
    _draw_door()
    _draw_inscription_plaque()
    _draw_traps()
    _draw_hazards_floor()
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
    _draw_hazards_air()
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
    # Penumbra más clara y de color (sombras violáceas, no negras): se sigue
    # necesitando la antorcha, pero la sala se lee mejor.
    var base_dark: float = 0.40 if torch_on else 0.60
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
    var tint := Color(0.035, 0.02, 0.07)
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
        if bool(allies[i]["alive"]) and allies_here and not bool(allies[i].get("gone", false)):
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
                if prop.has("region"):
                    _draw_kprop(prop)
                else:
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
    _draw_guides_request()
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
    _xf(center, 0.0, Vector2(1.0, radius_y / radius_x))
    draw_circle(Vector2.ZERO, radius_x, color)
    _xf(Vector2.ZERO, 0.0, Vector2.ONE)


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
    _xf(at + Vector2(0.0, 6.0), 0.0, Vector2(1.0, 0.46))
    draw_arc(Vector2.ZERO, 42.0, 0.0, TAU, 48, Color(ring.r, ring.g, ring.b, 0.75), 2.0)
    draw_arc(Vector2.ZERO, 33.0, 0.0, TAU, 40, Color(ring.r, ring.g, ring.b, 0.35), 1.0)
    for i in range(8):
        var t: float = float(i) / 8.0 * TAU + elapsed * 0.25
        draw_line(Vector2(cos(t), sin(t)) * 34.0, Vector2(cos(t), sin(t)) * 41.0, Color(ring.r, ring.g, ring.b, 0.8), 2.0)
    _xf(Vector2.ZERO, 0.0, Vector2.ONE)
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
    _draw_outlined(sheet, dest, region, tint)
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
    if weapon != "":
        _draw_weapon_strike_fx()
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


## Golpe con arma: cada una tiene su trazo, de acero y sin fuego.
##   daga: dos tajos cortos y rápidos · espada: media luna limpia
##   lanza: estocada recta y larga · hacha: barrido ancho y pesado con polvo
##   maza: impacto con onda y chispas
func _draw_weapon_strike_fx() -> void:
    var k: float = 1.0 - strike_fx / 0.25
    var fade: float = 1.0 - k
    var c := player_pos + Vector2(0.0, -20.0)
    var mid: float = strike_dir.angle()
    var steel := Color(0.88, 0.93, 0.97, 0.9 * fade)
    var edge := Color(1.0, 1.0, 1.0, fade)
    var shade := Color(0.55, 0.62, 0.70, 0.6 * fade)
    var reach: float = _strike_range()
    match weapon:
        "daga":
            for j in range(2):
                var off: float = (float(j) - 0.5) * 0.5
                var a0: float = mid - 0.6 + off
                var a1: float = a0 + 1.2 * minf(1.0, k * 2.2 - float(j) * 0.5)
                if a1 > a0:
                    draw_arc(c, reach * 0.6, a0, a1, 10, steel, 3.0)
                    draw_arc(c, reach * 0.6 + 2.0, a0, a1, 10, edge, 1.0)
        "espada":
            var a0: float = mid - 1.0
            var a1: float = a0 + 2.0 * minf(1.0, k * 1.8)
            draw_arc(c, reach * 0.62, a0, a1, 18, shade, 9.0)
            draw_arc(c, reach * 0.7, a0, a1, 18, steel, 4.0)
            draw_arc(c, reach * 0.76, a0, a1, 18, edge, 1.5)
        "lanza":
            var dir: Vector2 = Vector2.from_angle(mid)
            var out: float = reach * (0.35 + 0.65 * sin(minf(1.0, k * 1.4) * PI * 0.5))
            var tip: Vector2 = c + dir * out
            draw_line(c + dir * 10.0, tip, shade, 7.0)
            draw_line(c + dir * 10.0, tip, steel, 3.0)
            var side := Vector2(-dir.y, dir.x)
            draw_colored_polygon(PackedVector2Array([tip + dir * 12.0, tip + side * 5.0, tip - side * 5.0]), edge)
            for j in range(3):
                draw_line(tip - dir * (14.0 + float(j) * 10.0) + side * (float(j) - 1.0) * 6.0, tip - dir * (24.0 + float(j) * 10.0) + side * (float(j) - 1.0) * 6.0, Color(1, 1, 1, 0.35 * fade), 1.0)
        "hacha":
            var a0: float = mid - 1.9
            var a1: float = a0 + 3.8 * minf(1.0, k * 1.5)
            draw_arc(c, reach * 0.55, a0, a1, 24, Color(0.45, 0.4, 0.36, 0.5 * fade), 14.0)
            draw_arc(c, reach * 0.66, a0, a1, 24, steel, 5.0)
            draw_arc(c, reach * 0.73, a0, a1, 24, edge, 2.0)
            if k > 0.55:
                for j in range(5):
                    var p: Vector2 = player_pos + Vector2.from_angle(a0 + float(j) * 0.8) * reach * 0.6
                    draw_circle(p, 3.0 * fade, Color(0.75, 0.7, 0.6, 0.5 * fade))
        "maza":
            var hit: Vector2 = c + Vector2.from_angle(mid) * reach * 0.7
            var a0: float = mid - 0.9
            var a1: float = a0 + 1.8 * minf(1.0, k * 2.4)
            draw_arc(c, reach * 0.65, a0, a1, 14, shade, 6.0)
            if k > 0.4:
                var kk: float = (k - 0.4) / 0.6
                draw_arc(hit, 6.0 + kk * 26.0, 0.0, TAU, 24, Color(0.95, 0.9, 0.75, 0.8 * (1.0 - kk)), 3.0)
                for j in range(6):
                    var sp: Vector2 = hit + Vector2.from_angle(float(j) * TAU / 6.0 + 0.3) * (8.0 + kk * 22.0)
                    draw_rect(Rect2(sp - Vector2(1.5, 1.5), Vector2(3, 3)), Color(1.0, 0.85, 0.5, 1.0 - kk))
                if kk < 0.3:
                    draw_circle(hit, 9.0, Color(1, 1, 1, 0.6 * (1.0 - kk / 0.3)))


## Onda de Resonancia: anillo que se expande hasta su alcance de daño.
func _draw_pulse_fx() -> void:
    if pulse_fx < 0.0:
        return
    var k: float = clampf(pulse_fx / 0.45, 0.0, 1.0)
    var r: float = _pulse_radius() * (1.0 - pow(1.0 - k, 3.0))
    var a: float = 1.0 - clampf(pulse_fx / 0.6, 0.0, 1.0)
    _xf(player_pos + Vector2(0.0, -6.0), 0.0, Vector2(1.0, 0.6))
    draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, Color(0.75, 0.93, 1.0, a), 4.0)
    draw_arc(Vector2.ZERO, r * 0.8, 0.0, TAU, 64, Color(0.56, 0.78, 0.84, a * 0.6), 2.0)
    draw_circle(Vector2.ZERO, r, Color(0.56, 0.78, 0.84, a * 0.08))
    _xf(Vector2.ZERO, 0.0, Vector2.ONE)


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
## Personaje con contorno oscuro de un píxel de su arte (estilo Soul Knight):
## se separa del suelo y se lee de un vistazo.
func _draw_outlined(tex: Texture2D, dest: Rect2, region: Rect2, tint: Color) -> void:
    var px: float = maxf(1.0, roundf(dest.size.x / maxf(1.0, region.size.x)))
    var oc := Color(0.03, 0.02, 0.05, 0.9 * tint.a)
    for o in [Vector2(px, 0), Vector2(-px, 0), Vector2(0, px), Vector2(0, -px)]:
        draw_texture_rect_region(tex, Rect2(dest.position + o, dest.size), region, oc)
    draw_texture_rect_region(tex, dest, region, tint)


func _draw_texture_flipped(tex: Texture2D, dest: Rect2, flip: bool) -> void:
    if not flip:
        draw_texture_rect(tex, dest, false)
        return
    _xf(Vector2(dest.position.x + dest.size.x, dest.position.y), 0.0, Vector2(-1.0, 1.0))
    draw_texture_rect(tex, Rect2(Vector2.ZERO, dest.size), false)
    _xf(Vector2.ZERO, 0.0, Vector2.ONE)


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
        for gh in dash_ghosts:
            var gk: float = 1.0 - float(gh["t"]) / 0.22
            var gloc := Vector2(roundf(Vector2(gh["pos"]).x) - 20.0, roundf(Vector2(gh["pos"]).y) - 50.0)
            draw_texture_rect_region(_hero_sheet(), Rect2(gloc, Vector2(40.0, 56.0)), Rect2(float(2 * 40), float(direction_index * 56), 40.0, 56.0), Color(0.55, 0.85, 1.0, 0.35 * gk))
        var blink: bool = damage_cd > 0.0 and int(elapsed * 14.0) % 2 == 0
        # La antorcha va en la mano; de espaldas queda detrás del cuerpo.
        var hand: Vector2 = player_pos + [Vector2(12, -18), Vector2(-12, -20), Vector2(9, -19), Vector2(-9, -19)][direction_index]
        var in_hand_torch: bool = has_torch and weapon == ""
        if direction_index == 1 and game_mode != "dead":
            if weapon != "":
                _draw_hand_weapon(hand, direction_index)
            elif in_hand_torch:
                _draw_hand_torch(hand)
        _draw_outlined(_hero_sheet(), Rect2(location, Vector2(40.0, 56.0)), atlas, Color(1, 1, 1, 0.35 if blink else 1.0))
        if game_mode != "dead":
            _draw_worn_gear(location, direction_index, 0.35 if blink else 1.0)
        if direction_index != 1 and game_mode != "dead":
            if weapon != "":
                _draw_hand_weapon(hand, direction_index)
            elif in_hand_torch:
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
    _vgradient(Rect2(-screen_pad.x, -screen_pad.y, W + screen_pad.x * 2.0, 112.0 + screen_pad.y), Color(0.02, 0.025, 0.035, 0.96), Color(0.02, 0.025, 0.035, 0.55))
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
    _draw_portrait_gear(Rect2(frame.position + Vector2(4.0 + shake_x, 4.0), Vector2(64, 64)))
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
    Estilo.panel(self, rect, fill, edge)


func _px_bar(rect: Rect2, fraction: float, color: Color, label: String) -> void:
    Estilo.barra(self, rect, fraction, color, label)


func _text_outline(msg: String, at: Vector2, size: int, color: Color, width: float = -1.0) -> void:
    Estilo.texto(self, msg, at, size, color, width)


func _draw_footer() -> void:
    ## Abajo: misión a la izquierda; arma y habilidades a la derecha.
    _vgradient(Rect2(-screen_pad.x, 572, W + screen_pad.x * 2.0, 68.0 + screen_pad.y), Color(0.02, 0.025, 0.035, 0.55), Color(0.02, 0.025, 0.035, 0.96))
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
    var name_txt: String = "ANTORCHA" if has_torch else ("MADERA" if has_wood else "SIN ARMA")
    if weapon != "":
        name_txt = str(WEAPONS[weapon]["name"])
        owned = true
        icon = weapon
    draw_texture_rect(ICONS[icon], Rect2(slot.position + Vector2(8, 8), Vector2(32, 32)), false, Color.WHITE if owned else Color(0.3, 0.3, 0.3, 0.5))
    _text_outline(name_txt, Vector2(650, 600), 14, CREAM if owned else Color("#6d6a60"))
    var ammo: String = "LLAMA INTERIOR" if has_inner_flame else "FÓSFOROS x%s" % _matches_label()
    var ammo_col: Color = SOUL if has_inner_flame else (Color("#f0c98a") if matches > 0 else RED)
    draw_texture_rect(ICONS["llama_interior" if has_inner_flame else "fosforos"], Rect2(648, 608, 20, 20), false)
    _text_outline(ammo, Vector2(672, 624), 12, ammo_col)
    _draw_torch_fuel()
    _draw_ability_icon(Rect2(780, 583, 48, 48), "vigor", true, _dash_wait(), _short_key("esquivar"))
    _draw_ability_icon(Rect2(838, 583, 48, 48), "golpe", (has_torch and torch_on) or weapon != "", maxf(strike_cd / _weapon_stat("cd"), _vigor_wait(_weapon_stat("cost"))), _short_key("interactuar"))
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
        var must: bool = bool(m["required"]) or (str(m.get("goal", "")) == "desterrar" and _enemy_blocks_door())
        return "MISIÓN%s: %s · +%d almas" % ["" if must else " (OPCIONAL)", m["text"], int(m["reward"])]
    if hunt_task != "":
        return hunt_task
    if _has("almas") and collected.has(false):
        return "MISIÓN: reúne las almas de la sala (%d/3)" % (3 - collected.count(false))
    if _enemy_blocks_door():
        return "PUERTA SELLADA: DESTIERRA %s" % ENEMY_TITLES.get(_enemy_kind(), "A LA ENTIDAD")
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


## ---- Actualizaciones -------------------------------------------------------
## El aviso del menú es un componente propio (scenes/ui/aviso_actualizacion.tscn)
## que escucha al nodo Actualizador.


func _start_updater() -> void:
    if actualizador != null or not bool(Ajustes.obtener("buscar_actualizaciones")) or not Actualizador.permitido():
        return
    actualizador = Actualizador.new()
    actualizador.name = "Actualizador"
    add_child(actualizador)
    actualizador.buscar()
    _sync_screens()


func _draw_inventory_overlay() -> void:
    ## PERFIL del jugador (I / Tab, o tocar el retrato): ficha de personaje al
    ## estilo de los roguelike de acción. Izquierda: retrato y estadísticas.
    ## Derecha: equipo y habilidades, Ecos y la descripción de lo señalado.
    draw_rect(_full_rect(), Color(0, 0, 0, 0.78))
    var sheet := Rect2(70, 46, 820, 548)
    _panel(sheet, Color(0.05, 0.06, 0.08, 0.97), UI_GOLD)
    _panel(Rect2(380, 34, 200, 30), Color("#2a1d22"), UI_GOLD)
    _title_text("Perfil", Vector2(380, 58), 24, CREAM, 200.0)
    # --- Columna izquierda: retrato y datos.
    var frame := Rect2(102, 84, 140, 140)
    _panel(frame, Color("#1a1f2a"), UI_GOLD)
    draw_texture_rect(_portrait(hp / max_hp < 0.35), Rect2(frame.position + Vector2(6, 6), Vector2(128, 128)), false)
    _draw_portrait_gear(Rect2(frame.position + Vector2(6, 6), Vector2(128, 128)))
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
    for t in range(3):
        var tr: Rect2 = _profile_tab_rect(t)
        var on: bool = profile_tab == t
        _panel(tr, Color("#2a1d22") if on else Color("#141922"), UI_GOLD if on else UI_EDGE)
        _text_outline(["MOCHILA Y HABILIDADES", "OBJETOS (%d)" % _object_slots().size(), "EQUIPO"][t], Vector2(tr.position.x, tr.position.y + 17.0), 12, CREAM if on else Color("#9a957f"), tr.size.x)
    if profile_tab == 0:
        # Dos grupos con título: lo que llevas y lo que sabes hacer.
        _text_outline("MOCHILA", Vector2(372, 111), 12, UI_GOLD)
        draw_rect(Rect2(440, 106, 428, 1), Color(UI_GOLD.r, UI_GOLD.g, UI_GOLD.b, 0.3))
        _text_outline("HABILIDADES NATIVAS", Vector2(372, 239), 12, SOUL)
        draw_rect(Rect2(528, 234, 340, 1), Color(SOUL.r, SOUL.g, SOUL.b, 0.3))
    for i in range(INVENTORY_SLOTS.size() if profile_tab == 0 else 0):
        var box: Rect2 = _inventory_slot_rect(i)
        var owned: bool = _slot_owned(i)
        var sel: bool = inventory_sel == i
        _panel(box, Color("#222c39") if sel else Color("#141922"), UI_GOLD if sel else UI_EDGE)
        var key: String = INVENTORY_SLOTS[i][0]
        if key == "antorcha" and torch_on:
            key = "antorcha_encendida"
        draw_texture_rect(ICONS[key], Rect2(box.position + Vector2(roundf(box.size.x * 0.5) - 22.0, 8), Vector2(44, 44)), false, Color.WHITE if owned else Color(0.1, 0.1, 0.12, 0.9))
        var title: String = INVENTORY_SLOTS[i][1] if owned else "???"
        if INVENTORY_SLOTS[i][0] == "fosforos" and owned:
            title = "FÓSFOROS x%s" % _matches_label()
        _text_outline(title, Vector2(box.position.x, box.end.y - 10.0), 11, CREAM if owned else Color("#5d5a52"), box.size.x)
    if profile_tab == 1:
        _draw_object_slots()
    elif profile_tab == 2:
        _draw_equip_tab()
    # --- Ecos: iconos compactos (caben los diez pisos); el detalle está en HABILIDADES.
    var keys: Array = ECOS.keys() if profile_tab != 2 else []
    if profile_tab != 2:
        _text_outline("ECOS", Vector2(372, 368), 13, UI_GOLD)
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
    elif profile_tab == 2:
        _draw_equip_desc()
    else:
        var owned_sel: bool = _slot_owned(inventory_sel)
        _text_outline(INVENTORY_SLOTS[inventory_sel][1] if owned_sel else "???", Vector2(388, 478), 15, CREAM if owned_sel else Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), INVENTORY_SLOTS[inventory_sel][2] if owned_sel else "Aún no lo tienes.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, SOUL if owned_sel else Color("#8a8778"))
    _text_outline(_hint("I / ESC: cerrar", "Toca fuera para cerrar", "B: cerrar"), Vector2(372, 564), 12, Color("#8a8574"), 320.0)


## Pantalla de entrada al piso (GDD §7): solo una vista parcial del interior,
## sin desvelar lo que hay tras las puertas.
## ¿Ya se puede cerrar la pantalla de muerte o de victoria? (se lee primero).
func _end_ready() -> bool:
    return end_t >= END_LOCK


func _overlay() -> void:
    draw_rect(_full_rect(), Color(0, 0, 0, 0.75))


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


# ============================================================ LUZ ADITIVA
## Capa de luz que se SUMA a la imagen (como el «bloom» de los motores grandes):
## el fuego, las almas y la antorcha brillan de verdad sobre la penumbra.
## Se dibuja por encima de la sala (es un hijo de este nodo) y solo en juego.
var glow_node: Node2D = null
var glow_tex: Texture2D = null
var sparks: Array = [] # {p, v, life, max, col, size}
var spark_acc: float = 0.0


func _setup_glow() -> void:
    var grad := Gradient.new()
    grad.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
    grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)])
    var tex := GradientTexture2D.new()
    tex.gradient = grad
    tex.fill = GradientTexture2D.FILL_RADIAL
    tex.fill_from = Vector2(0.5, 0.5)
    tex.fill_to = Vector2(1.0, 0.5)
    tex.width = 128
    tex.height = 128
    glow_tex = tex
    glow_node = Node2D.new()
    glow_node.name = "LuzAditiva"
    var mat := CanvasItemMaterial.new()
    mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    glow_node.material = mat
    glow_node.draw.connect(_draw_glow)
    # Recortada a la sala: la luz no se derrama sobre los marcadores de arriba.
    var clip := Control.new()
    clip.name = "RecorteLuz"
    clip.clip_contents = true
    clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip.position = ARENA.position
    clip.size = ARENA.size
    add_child(clip)
    glow_node.position = -ARENA.position
    clip.add_child(glow_node)


func _tick_glow(dt: float) -> void:
    if glow_node == null:
        return
    var on: bool = game_mode == "play" and room_node != null and not in_tutorial
    (glow_node.get_parent() as CanvasItem).visible = on
    if not on:
        return
    _update_sparks(dt)
    glow_node.queue_redraw()


func _glow(at: Vector2, radius: float, col: Color) -> void:
    glow_node.draw_texture_rect(glow_tex, Rect2(at - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, col)


## Chispas que suben de los braseros y del fuego; motas de alma sobre las almas.
func _update_sparks(dt: float) -> void:
    for sp in sparks:
        sp["life"] = float(sp["life"]) - dt
        sp["v"] = (sp["v"] as Vector2) + Vector2(sin(elapsed * 3.0 + float(sp["max"]) * 9.0) * 14.0, -10.0) * dt
        sp["p"] = (sp["p"] as Vector2) + (sp["v"] as Vector2) * dt
    sparks = sparks.filter(func(sp): return float(sp["life"]) > 0.0 and ARENA.grow(-4.0).has_point(sp["p"]))
    var cap: int = 60 if touch_enabled else 120
    spark_acc += dt
    if spark_acc < 0.06 or sparks.size() >= cap:
        return
    spark_acc = 0.0
    for prop in room_props:
        if prop["light"] and randf() < 0.5:
            var r: Rect2 = prop["rect"]
            _spark(Vector2(r.get_center().x + randf_range(-8, 8), r.position.y + r.size.y * 0.3), Vector2(randf_range(-12, 12), randf_range(-60, -30)),
                randf_range(0.8, 1.6), Color(1.0, randf_range(0.45, 0.7), 0.2), randf_range(1.0, 2.0))
    for b in braziers:
        if bool(b.get("lit", false)) and randf() < 0.5:
            _spark(Vector2(b["pos"]) + Vector2(randf_range(-6, 6), -30), Vector2(randf_range(-10, 10), randf_range(-60, -30)), randf_range(0.8, 1.4), Color(1.0, 0.55, 0.2), 1.6)
    for i in range(relics.size()):
        if not collected[i] and randf() < 0.25:
            _spark(Vector2(relics[i]) + Vector2(randf_range(-10, 10), -12), Vector2(randf_range(-4, 4), randf_range(-26, -12)), randf_range(1.0, 1.8), Color(0.5, 0.88, 1.0), 1.4)
    if torch_on and randf() < 0.35:
        _spark(player_pos + Vector2(10 if player_dir.x >= 0.0 else -10, -40), Vector2(randf_range(-8, 8), randf_range(-40, -20)), randf_range(0.4, 0.8), Color(1.0, 0.6, 0.25), 1.2)


func _spark(at: Vector2, vel: Vector2, life: float, col: Color, size: float) -> void:
    sparks.append({"p": at, "v": vel, "life": life, "max": life, "col": col, "size": size})


func _draw_glow() -> void:
    if glow_tex == null:
        return
    var flick: float = 0.9 + 0.1 * sin(elapsed * 11.0) * sin(elapsed * 3.7)
    # Antorcha del jugador: calor suave alrededor de la llama.
    if torch_on:
        _glow(player_pos + Vector2(8 if player_dir.x >= 0.0 else -8, -40), 70.0 * flick, Color(0.55, 0.32, 0.12, 0.55))
        _glow(player_pos + Vector2(8 if player_dir.x >= 0.0 else -8, -40), 18.0, Color(1.0, 0.7, 0.35, 0.7))
    for prop in room_props:
        if prop["light"]:
            var r: Rect2 = prop["rect"]
            var c := Vector2(r.get_center().x, r.position.y + r.size.y * 0.32)
            var f: float = 0.85 + 0.15 * sin(elapsed * 9.0 + r.position.x) * sin(elapsed * 2.9 + r.position.y)
            _glow(c, 92.0 * f, Color(0.6, 0.32, 0.1, 0.5))
            _glow(c, 26.0 * f, Color(1.0, 0.75, 0.4, 0.75))
    for b in braziers:
        if bool(b.get("lit", false)):
            _glow(Vector2(b["pos"]) + Vector2(0, -28), 90.0 * flick, Color(0.6, 0.3, 0.1, 0.55))
    for d in decor_cache:
        if d[0] == "velas" and decor_cache_key == _room_key():
            _glow(Vector2(d[1]) + Vector2(11, 6), 30.0 * flick, Color(0.6, 0.4, 0.15, 0.45))
    for i in range(relics.size()):
        if not collected[i]:
            var pulse: float = 0.8 + 0.2 * sin(elapsed * 2.4 + float(i))
            _glow(Vector2(relics[i]) + Vector2(0, -16), 46.0 * pulse, Color(0.15, 0.45, 0.6, 0.6))
            _glow(Vector2(relics[i]) + Vector2(0, -16), 12.0, Color(0.6, 0.95, 1.0, 0.8))
    for drop in drops:
        _glow(Vector2(drop["pos"]) + Vector2(0, -14), 40.0, Color(0.15, 0.45, 0.6, 0.55))
    for item in room_items:
        _glow(Vector2(item["pos"]) + Vector2(0, -10), 30.0, Color(0.45, 0.38, 0.18, 0.4))
    for ball in fireballs:
        _glow(ball["pos"], 52.0, Color(0.8, 0.35, 0.1, 0.7))
    if _enemy_active() and _enemy_kind() == "ghoul":
        _glow(enemy_pos + Vector2(0, -26), 70.0 * flick, Color(0.6, 0.25, 0.08, 0.5))
    for v in flame_vents:
        var t: float = _flame_t(v)
        if t >= FLAME_ON:
            _glow(Vector2(v["pos"]) + Vector2(0, -30), 96.0 * flick, Color(0.85, 0.38, 0.1, 0.75))
        elif t >= FLAME_WARN:
            _glow(Vector2(v["pos"]), 34.0, Color(0.7, 0.25, 0.05, 0.5 * (t - FLAME_WARN) / (FLAME_ON - FLAME_WARN)))
    for cell in vines:
        if str(vines[cell]["state"]) == "fuego":
            _glow(_cell_center(cell) + Vector2(0, -8), 44.0 * flick, Color(0.7, 0.3, 0.08, 0.35))
    if _room_ready():
        _glow(door_pos + Vector2(4, -10), 80.0, Color(0.35, 0.3, 0.2, 0.35))
    # Destello frío del filo del péndulo al barrer.
    for pd in pendulums:
        var vel: float = absf(cos(room_elapsed * TAU / PENDULUM_PERIOD + float(pd["phase"])))
        _glow(_pendulum_blade(pd) + Vector2(0, -8), 26.0, Color(0.4, 0.45, 0.5, 0.35 * vel))
    for cr in critters:
        if bool(cr["alive"]) and str(cr.get("kind", "rata")) != "rata":
            var at: Vector2 = Vector2(cr["pos"]) + Vector2(0, -12.0 - _critter_lift(cr, 0))
            _glow(at, 12.0, Color(0.7, 0.1, 0.1, 0.4))
    for sp in sparks:
        var k: float = clampf(float(sp["life"]) / float(sp["max"]), 0.0, 1.0)
        var col: Color = sp["col"]
        _glow(sp["p"], 6.0 * float(sp["size"]), Color(col.r, col.g, col.b, 0.5 * k))
        glow_node.draw_rect(Rect2((sp["p"] as Vector2).round(), Vector2(1, 1) * maxf(1.0, round(float(sp["size"])))), Color(col.r, col.g, col.b, k))


# ============================================================ ARMAS Y EQUIPO
## Armas tiradas por las salas: cada una cambia el golpe (daño, alcance,
## ritmo, ángulo y vigor). Sin arma, se golpea con la antorcha encendida; con
## arma se golpea siempre, y la antorcha sigue prendiendo raíces si está
## encendida. Equipo: yelmo (menos daño), peto (más vida) y botas (más rápido).
## Lo encontrado se guarda entre partidas; se cambia en Perfil > EQUIPO.
const WEAPONS := {
    "daga": {"name": "DAGA DE HUESO", "dmg": 0.8, "range": 52.0, "cd": 0.32, "cost": 6.0, "arc": 0.2, "stun": 0.2,
        "desc": "Rápida y ligera: golpes cortos y seguidos, gasta poco vigor."},
    "espada": {"name": "ESPADA OXIDADA", "dmg": 1.25, "range": 66.0, "cd": 0.5, "cost": 10.0, "arc": 0.25, "stun": 0.3,
        "desc": "Equilibrada: más daño que la antorcha al mismo ritmo."},
    "lanza": {"name": "LANZA DEL PEREGRINO", "dmg": 1.1, "range": 94.0, "cd": 0.62, "cost": 11.0, "arc": 0.55, "stun": 0.3,
        "desc": "Llega muy lejos, pero solo hiere lo que tienes justo delante."},
    "hacha": {"name": "HACHA DE VERDUGO", "dmg": 1.8, "range": 70.0, "cd": 0.95, "cost": 18.0, "arc": -0.2, "stun": 0.4,
        "desc": "Lenta y pesada: barre casi todo a tu alrededor."},
    "maza": {"name": "MAZA DE CAMPANA", "dmg": 1.35, "range": 60.0, "cd": 0.75, "cost": 14.0, "arc": 0.15, "stun": 0.9,
        "desc": "Aturde: la entidad queda quieta casi un segundo."},
}
## Golpe base (antorcha), para comparar.
const TORCH_WEAPON := {"dmg": 1.0, "range": 64.0, "cd": 0.6, "cost": 10.0, "arc": 0.25, "stun": 0.3}
const GEAR := {
    "yelmo": {"slot": "casco", "name": "YELMO ABOLLADO", "desc": "Recibes un 12 % menos de daño."},
    "peto": {"slot": "peto", "name": "PETO DE GUARDIA", "desc": "+20 de vida máxima."},
    "botas": {"slot": "botas", "name": "BOTAS DE PEREGRINO", "desc": "Caminas un 8 % más rápido y el esquive se recarga un 10 % antes."},
}
const YELMO_REDUCTION := 0.12
const PETO_HP := 20.0
## Dónde aparece cada pieza (piso:sala). Se coloca sola en un hueco libre.
const GEAR_SPOTS := {
    "0:1": "daga", "0:3": "botas", "1:1": "espada", "2:1": "yelmo",
    "3:1": "lanza", "4:2": "peto", "5:2": "hacha", "7:1": "maza",
}
var weapon: String = "" # arma en la mano ("" = antorcha)
var stowed_weapon: String = "" # arma guardada al sacar la antorcha con F
var gear: Dictionary = {} # hueco -> pieza
var gear_owned: Dictionary = {} # pieza o arma -> true
var gear_pickup: Dictionary = {} # {key, pos} en la sala actual


func _weapon_stat(stat: String) -> float:
    var w: Dictionary = WEAPONS[weapon] if WEAPONS.has(weapon) else TORCH_WEAPON
    return float(w.get(stat, TORCH_WEAPON[stat]))


func _strike_range() -> float:
    return _weapon_stat("range")


func _gear_speed_mult() -> float:
    return 1.08 if gear.get("botas", "") != "" else 1.0


func _place_gear_pickup() -> void:
    gear_pickup = {}
    var key: String = str(GEAR_SPOTS.get(_room_key(), ""))
    if key == "" or gear_owned.has(key) or in_tutorial:
        return
    var keep: Array = _kprop_keep_points()
    for c in [Vector2(250, 470), Vector2(710, 470), Vector2(480, 300), Vector2(250, 300), Vector2(710, 300), Vector2(380, 520), Vector2(580, 520), Vector2(480, 440)]:
        if _is_blocked(c):
            continue
        var ok: bool = true
        for q in keep:
            if Vector2(q).distance_to(c) < 56.0:
                ok = false
                break
        if ok:
            gear_pickup = {"key": key, "pos": c}
            return


func _take_gear() -> void:
    var key: String = gear_pickup["key"]
    var at: Vector2 = gear_pickup["pos"]
    gear_pickup = {}
    gear_owned[key] = true
    var label: String = ""
    if WEAPONS.has(key):
        weapon = key
        torch_on = false # el arma ocupa la mano: la antorcha se guarda
        label = WEAPONS[key]["name"]
        _say("%s: %s Se equipa sola; cámbiala en Perfil > EQUIPO." % [label, WEAPONS[key]["desc"]], 4.5)
    else:
        _equip_gear(key)
        label = GEAR[key]["name"]
        _say("%s: %s" % [label, GEAR[key]["desc"]], 4.0)
    loot_banner = {"key": key, "t": 3.5, "info": [label, "", 3, key]}
    pickup_fx.append({"pos": at, "t": 0.0, "text": "+" + label, "color": Color("#ffd36b")})
    _sfx("objeto", -4.0, 0.9)
    _sfx("k_metal", -10.0, 1.1)
    _save_progress()


func _equip_gear(key: String) -> void:
    var slot: String = GEAR[key]["slot"]
    var had_peto: bool = gear.get("peto", "") != ""
    gear[slot] = key
    if slot == "peto" and not had_peto:
        max_hp += PETO_HP
        hp += PETO_HP


## Cambia de arma en el perfil (vuelta entre las que tienes y la antorcha).
func _cycle_weapon() -> void:
    var owned: Array = [""]
    for k in WEAPONS:
        if gear_owned.has(k):
            owned.append(k)
    var i: int = owned.find(weapon)
    weapon = owned[(i + 1) % owned.size()]
    if weapon != "":
        torch_on = false
    _sfx("k_metal", -12.0, 1.2)
    _save_progress()


func _draw_gear_pickup() -> void:
    if gear_pickup.is_empty():
        return
    var at: Vector2 = gear_pickup["pos"]
    var bob: float = sin(elapsed * 3.0) * 3.0
    _draw_ellipse(at + Vector2(0, 4), 18.0, 6.0, Color(0, 0, 0, 0.35))
    draw_circle(at + Vector2(0, -14 + bob), 22.0, Color(1.0, 0.85, 0.45, 0.10 + 0.05 * sin(elapsed * 4.0)))
    draw_texture_rect(ICONS[gear_pickup["key"]], Rect2(at + Vector2(-16, -30 + bob), Vector2(32, 32)), false)
    var name_g: String = WEAPONS[gear_pickup["key"]]["name"] if WEAPONS.has(gear_pickup["key"]) else GEAR[gear_pickup["key"]]["name"]
    if player_pos.distance_to(at) < 140.0:
        _label_center(name_g, at + Vector2(0, -44), Color("#ffd36b"))


# --- Lo que se lleva puesto, a la vista ------------------------------------------
## Todo lo equipado se dibuja sobre el personaje (en las cuatro direcciones) y
## sobre su retrato: yelmo, máscara de porcelana, amuleto, peto, botas,
## brazalete y el arma en la mano. Coordenadas en píxeles de la celda 40×56.
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


func _px(loc: Vector2, x: float, y: float, w: float, h: float, col: Color) -> void:
    draw_rect(Rect2(loc + Vector2(x, y), Vector2(w, h)), col)


func _draw_worn_gear(loc: Vector2, dir: int, a: float) -> void:
    var side: bool = dir >= 2
    var left: bool = dir == 3
    var steel := Color(GEAR_STEEL, a)
    var dark := Color(GEAR_STEEL_DARK, a)
    var light := Color(GEAR_STEEL_LIGHT, a)
    var ol := Color(GEAR_OUTLINE, a)
    # Botas: cubren los pies.
    if gear.get("botas", "") != "":
        var lea := Color(GEAR_LEATHER, a)
        var lead := Color(GEAR_LEATHER_DARK, a)
        if side:
            _px(loc, 15, 44, 13, 7, lead)
            _px(loc, 16, 44, 11, 5, lea)
        else:
            _px(loc, 11, 44, 8, 7, lead)
            _px(loc, 21, 44, 8, 7, lead)
            _px(loc, 12, 44, 6, 5, lea)
            _px(loc, 22, 44, 6, 5, lea)
    # Peto: placa sobre el torso, con hombreras.
    if gear.get("peto", "") != "":
        if side:
            _px(loc, 14, 25, 13, 15, ol)
            _px(loc, 15, 26, 11, 13, steel)
            _px(loc, 15, 26, 11, 2, light)
            _px(loc, 15, 32, 11, 1, dark)
        else:
            _px(loc, 10, 24, 21, 16, ol)
            _px(loc, 11, 25, 19, 14, steel)
            _px(loc, 11, 25, 19, 2, light)
            _px(loc, 20, 27, 1, 12, dark)
            _px(loc, 11, 32, 19, 1, dark)
            _px(loc, 7, 24, 5, 5, Color(GEAR_LEATHER, a))
            _px(loc, 29, 24, 5, 5, Color(GEAR_LEATHER, a))
    # Amuleto de hueso: cadena y colgante sobre el pecho.
    if _worn("amuleto") and dir != 1:
        var chain := Color(GEAR_GOLD, a)
        if side:
            var cx: float = 23.0 if not left else 17.0
            _px(loc, cx, 25, 1, 4, chain)
            _px(loc, cx - 1.0, 29, 3, 3, Color("#d8f0dc", a))
        else:
            _px(loc, 15, 24, 2, 1, chain)
            _px(loc, 16, 25, 2, 1, chain)
            _px(loc, 17, 26, 2, 1, chain)
            _px(loc, 23, 24, 2, 1, chain)
            _px(loc, 22, 25, 2, 1, chain)
            _px(loc, 21, 26, 2, 1, chain)
            _px(loc, 19, 27, 3, 4, Color("#d8f0dc", a))
            _px(loc, 20, 28, 1, 2, Color("#5f8f6a", a))
    # Brazalete: aro dorado en la muñeca.
    if _worn("brazalete"):
        var band := Color(GEAR_GOLD, a)
        match dir:
            0: _px(loc, 30, 35, 4, 2, band)
            1: _px(loc, 6, 35, 4, 2, band)
            2: _px(loc, 24, 36, 4, 2, band)
            3: _px(loc, 12, 36, 4, 2, band)
    # Máscara de porcelana: tapa el rostro (de espaldas, solo la cinta).
    if _mask_worn():
        var w := Color(MASK_WHITE, a)
        var sh := Color(MASK_SHADE, a)
        var eye := Color(0.05, 0.04, 0.06, a)
        match dir:
            0:
                _px(loc, 12, 7, 17, 17, ol)
                _px(loc, 13, 8, 15, 15, w)
                _px(loc, 13, 19, 15, 4, sh)
                _px(loc, 14, 12, 5, 3, eye) # cuencas vacías
                _px(loc, 22, 12, 5, 3, eye)
                _px(loc, 15, 15, 1, 3, Color(MASK_RED, a)) # lágrimas pintadas
                _px(loc, 25, 15, 1, 3, Color(MASK_RED, a))
                _px(loc, 18, 19, 5, 1, Color(MASK_RED, a)) # boca
                _px(loc, 21, 8, 1, 4, ol) # grieta
            1:
                _px(loc, 10, 14, 21, 1, Color(0.3, 0.12, 0.1, a))
            2:
                _px(loc, 20, 7, 12, 17, ol)
                _px(loc, 21, 8, 10, 15, w)
                _px(loc, 21, 19, 10, 4, sh)
                _px(loc, 25, 12, 4, 3, eye)
                _px(loc, 27, 15, 1, 3, Color(MASK_RED, a))
                _px(loc, 26, 19, 4, 1, Color(MASK_RED, a))
            3:
                _px(loc, 8, 7, 12, 17, ol)
                _px(loc, 9, 8, 10, 15, w)
                _px(loc, 9, 19, 10, 4, sh)
                _px(loc, 11, 12, 4, 3, eye)
                _px(loc, 12, 15, 1, 3, Color(MASK_RED, a))
                _px(loc, 10, 19, 4, 1, Color(MASK_RED, a))
    # Yelmo: casco de hierro sobre el pelo, con cresta roja.
    if gear.get("casco", "") != "":
        var hx: float = 10.0 if not side else (11.0 if not left else 9.0)
        var hw: float = 21.0 if not side else 20.0
        # Cúpula redondeada: las filas de arriba son más estrechas.
        _px(loc, hx + 2.0, -1, hw - 4.0, 2, ol)
        _px(loc, hx - 1.0, 1, hw + 2.0, 11, ol)
        _px(loc, hx + 3.0, 0, hw - 6.0, 1, steel)
        _px(loc, hx + 1.0, 1, hw - 2.0, 1, steel)
        _px(loc, hx, 2, hw, 9, steel)
        _px(loc, hx + 3.0, 1, hw - 8.0, 2, light)
        _px(loc, hx + 1.0, 3, 2, 5, light)
        _px(loc, hx, 9, hw, 2, dark)
        for rv in range(3):
            _px(loc, hx + 3.0 + float(rv) * (hw - 6.0) * 0.5, 10, 1, 1, light) # remaches
        _px(loc, hx + hw * 0.5 - 1.0, -4, 3, 4, Color(0.75, 0.2, 0.18, a))
        if dir == 0:
            _px(loc, 19, 11, 3, 5, dark) # nasal
        elif side:
            _px(loc, (27.0 if not left else 12.0), 11, 2, 4, dark)


## El arma en la mano, en lugar de la antorcha (sin luz). Al golpear, describe
## un arco en la dirección del golpe.
func _draw_hand_weapon(hand: Vector2, dir: int) -> void:
    var tex: Texture2D = ICONS.get(weapon)
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
    _xf(hand, base_angle + swing, Vector2(-1.0 if flip else 1.0, 1.0))
    draw_texture_rect(tex, Rect2(Vector2(-sz * 0.2, -sz * 0.8), Vector2(sz, sz)), false)
    _xf(Vector2.ZERO, 0.0, Vector2.ONE)


## Lo mismo sobre el retrato (64×64 de base, escalado al rectángulo dado).
func _draw_portrait_gear(r: Rect2) -> void:
    var k: float = r.size.x / 64.0
    var o: Vector2 = r.position
    var R := func(x: float, y: float, w: float, h: float, col: Color) -> void:
        draw_rect(Rect2(o + Vector2(x, y) * k, Vector2(w, h) * k), col)
    if gear.get("peto", "") != "":
        R.call(6, 47, 52, 17, GEAR_OUTLINE)
        R.call(7, 48, 50, 16, GEAR_STEEL)
        R.call(7, 48, 50, 3, GEAR_STEEL_LIGHT)
        R.call(31, 50, 2, 14, GEAR_STEEL_DARK)
        R.call(2, 46, 10, 8, GEAR_LEATHER)
        R.call(52, 46, 10, 8, GEAR_LEATHER)
    if _worn("amuleto"):
        for i in range(5):
            R.call(23.0 + float(i) * 2.0, 44.0 + float(i), 2, 1, GEAR_GOLD)
            R.call(39.0 - float(i) * 2.0, 44.0 + float(i), 2, 1, GEAR_GOLD)
        R.call(30, 49, 5, 7, Color("#d8f0dc"))
        R.call(31, 51, 3, 3, Color("#5f8f6a"))
    if _mask_worn():
        R.call(18, 15, 29, 27, GEAR_OUTLINE)
        R.call(19, 16, 27, 25, MASK_WHITE)
        R.call(19, 34, 27, 7, MASK_SHADE)
        R.call(22, 22, 8, 5, Color(0.05, 0.04, 0.06))
        R.call(35, 22, 8, 5, Color(0.05, 0.04, 0.06))
        R.call(25, 27, 2, 6, MASK_RED)
        R.call(38, 27, 2, 6, MASK_RED)
        R.call(28, 35, 9, 2, MASK_RED)
        R.call(33, 16, 1, 7, GEAR_OUTLINE)
    if gear.get("casco", "") != "":
        R.call(14, 3, 37, 19, GEAR_OUTLINE)
        R.call(15, 4, 35, 17, GEAR_STEEL)
        R.call(18, 4, 29, 3, GEAR_STEEL_LIGHT)
        R.call(15, 18, 35, 3, GEAR_STEEL_DARK)
        R.call(30, 21, 4, 9, GEAR_STEEL_DARK)
        R.call(30, 0, 5, 4, Color(0.75, 0.2, 0.18))


## Pestaña EQUIPO del perfil: siete huecos (arma, casco, peto, botas y los
## accesorios: máscara, amuleto, brazalete) y, debajo, lo encontrado. Tocar un
## hueco ocupado lo QUITA (vuelve el aspecto normal y se pierde su bono);
## tocar uno vacío pone lo primero que tengas para él.
const EQUIP_SLOTS := [["arma", "ARMA"], ["casco", "CASCO"], ["peto", "PETO"], ["botas", "BOTAS"],
    ["mascara", "MÁSCARA"], ["amuleto", "AMULETO"], ["brazalete", "BRAZALETE"]]
var unworn: Dictionary = {} # accesorios que tienes pero te has quitado


func _mask_worn() -> bool:
    return has_mask and not unworn.has("mascara")


func _worn(key: String) -> bool:
    return trinkets.has(key) and not unworn.has(key)


func _equip_slot_rect(i: int) -> Rect2:
    if i < 4:
        return Rect2(372.0 + float(i) * 126.0, 120.0, 118.0, 96.0)
    return Rect2(372.0 + float(i - 4) * 126.0, 246.0, 118.0, 80.0)


func _equip_owned_rect(i: int) -> Rect2:
    return Rect2(372.0 + float(i % 8) * 62.0, 360.0, 56.0, 56.0)


func _equip_owned_list() -> Array:
    var list: Array = []
    for k in WEAPONS:
        if gear_owned.has(k):
            list.append(k)
    for k in GEAR:
        if gear_owned.has(k):
            list.append(k)
    return list


## Lo que hay puesto en el hueco i ("" = vacío).
func _equip_in_slot(i: int) -> String:
    var slot: String = EQUIP_SLOTS[i][0]
    match slot:
        "arma":
            return weapon
        "mascara":
            return "mascara" if _mask_worn() else ""
        "amuleto", "brazalete":
            return slot if _worn(slot) else ""
    return str(gear.get(slot, ""))


## ¿Tienes algo que poner en ese hueco?
func _equip_candidate(i: int) -> String:
    var slot: String = EQUIP_SLOTS[i][0]
    match slot:
        "arma":
            for k in WEAPONS:
                if gear_owned.has(k):
                    return k
            return ""
        "mascara":
            return "mascara" if has_mask else ""
        "amuleto", "brazalete":
            return slot if trinkets.has(slot) else ""
    for k in GEAR:
        if gear_owned.has(k) and str(GEAR[k]["slot"]) == slot:
            return k
    return ""


func _unequip_slot(i: int) -> void:
    var slot: String = EQUIP_SLOTS[i][0]
    match slot:
        "arma":
            weapon = ""
            stowed_weapon = ""
        "mascara", "amuleto", "brazalete":
            unworn[slot] = true
        _:
            if slot == "peto" and gear.get("peto", "") != "":
                max_hp -= PETO_HP
                if hp > max_hp:
                    hp = maxf(max_hp, hp - PETO_HP)
            gear.erase(slot)


func _equip_slot(i: int, key: String) -> void:
    var slot: String = EQUIP_SLOTS[i][0]
    match slot:
        "arma":
            weapon = key
            torch_on = false
        "mascara", "amuleto", "brazalete":
            unworn.erase(slot)
        _:
            _equip_gear(key)


func _equip_tap(i: int) -> void:
    # 0-6: huecos (ocupado → se quita; vacío → se pone); 10+: lo encontrado.
    if i < EQUIP_SLOTS.size():
        if _equip_in_slot(i) != "":
            _unequip_slot(i)
            _sfx("toque", -10.0, 0.8)
        else:
            var cand: String = _equip_candidate(i)
            if cand == "":
                return
            _equip_slot(i, cand)
            _sfx("k_metal", -12.0, 1.2)
        _save_progress()
        return
    var list: Array = _equip_owned_list()
    if i - 10 >= list.size():
        return
    var k: String = list[i - 10]
    if WEAPONS.has(k):
        if weapon == k:
            weapon = ""
        else:
            weapon = k
            torch_on = false
    else:
        var si: int = ["casco", "peto", "botas"].find(str(GEAR[k]["slot"])) + 1
        if gear.get(GEAR[k]["slot"], "") == k:
            _unequip_slot(si)
        else:
            _equip_gear(k)
    _sfx("k_metal", -12.0, 1.2)
    _save_progress()


func _equip_icon(key: String) -> String:
    return key if ICONS.has(key) else ""


func _equip_name(key: String) -> String:
    if WEAPONS.has(key):
        return str(WEAPONS[key]["name"])
    if GEAR.has(key):
        return str(GEAR[key]["name"])
    match key:
        "mascara":
            return "MÁSCARA DE PORCELANA"
        "amuleto":
            return str(SHOP[3][1])
        "brazalete":
            return str(SHOP[2][1])
    return key.to_upper()


func _equip_desc(key: String) -> String:
    if WEAPONS.has(key):
        return str(WEAPONS[key]["desc"])
    if GEAR.has(key):
        return str(GEAR[key]["desc"])
    match key:
        "mascara":
            return "Tu Resonancia es Rugido: llega un 50 % más lejos y espanta a los mastines."
        "amuleto":
            return "Vigor: se recupera un %d %% más rápido." % (10 * _trinket_level("amuleto"))
        "brazalete":
            return "Golpe: +%d %% de daño." % (10 * _trinket_level("brazalete"))
    return ""


func _draw_equip_tab() -> void:
    _text_outline("LO QUE LLEVAS PUESTO · toca un hueco para quitar o poner", Vector2(372, 111), 12, UI_GOLD)
    _text_outline("ACCESORIOS", Vector2(372, 240), 11, Color("#9a957f"))
    for i in range(EQUIP_SLOTS.size()):
        var box: Rect2 = _equip_slot_rect(i)
        var key: String = _equip_in_slot(i)
        var cand: String = _equip_candidate(i)
        var sel: bool = inventory_sel == i
        _panel(box, Color("#222c39") if sel else Color("#141922"), UI_GOLD if sel or key != "" else UI_EDGE)
        _text_outline(EQUIP_SLOTS[i][1], Vector2(box.position.x, box.position.y + 15.0), 10, Color("#9a957f"), box.size.x)
        var icon: String = key
        var ghost: bool = false
        if icon == "" and i == 0 and has_torch:
            icon = "antorcha"
        elif icon == "" and cand != "":
            icon = cand
            ghost = true # lo tienes, pero quitado
        if icon != "" and ICONS.has(icon):
            var isz: float = 40.0 if i < 4 else 32.0
            draw_texture_rect(ICONS[icon], Rect2(box.position + Vector2(roundf(box.size.x * 0.5 - isz * 0.5), 20), Vector2(isz, isz)), false, Color(1, 1, 1, 0.3) if ghost else Color.WHITE)
        var nm: String = "—"
        if key != "":
            nm = _equip_name(key)
        elif i == 0:
            nm = "ANTORCHA" if has_torch else "SIN ARMA"
        elif cand != "":
            nm = "QUITADO"
        var nsize: int = 10
        while nsize > 8 and font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, nsize).x > box.size.x - 8.0:
            nsize -= 1
        _text_outline(nm, Vector2(box.position.x, box.end.y - 9.0), nsize, CREAM if key != "" or (i == 0 and has_torch) else Color("#5d5a52"), box.size.x)
    _text_outline("ENCONTRADO · toca para ponerlo o quitarlo", Vector2(372, 352), 12, SOUL)
    var list: Array = _equip_owned_list()
    for i in range(8):
        var r: Rect2 = _equip_owned_rect(i)
        var sel2: bool = inventory_sel == 10 + i
        if i >= list.size():
            _panel(r, Color("#10131a"), UI_EDGE)
            continue
        var k: String = list[i]
        var on: bool = weapon == k or gear.values().has(k)
        _panel(r, Color("#222c39") if sel2 else Color("#141922"), UI_GOLD if sel2 else (SOUL if on else UI_EDGE))
        draw_texture_rect(ICONS[k], Rect2(r.position + Vector2(8, 8), Vector2(40, 40)), false, Color.WHITE if on else Color(1, 1, 1, 0.45))


func _draw_equip_desc() -> void:
    var key: String = ""
    if inventory_sel < 10:
        var si: int = clampi(inventory_sel, 0, EQUIP_SLOTS.size() - 1)
        key = _equip_in_slot(si)
        if key == "":
            key = _equip_candidate(si)
    else:
        var list: Array = _equip_owned_list()
        if inventory_sel - 10 < list.size():
            key = list[inventory_sel - 10]
    if key == "":
        _text_outline("HUECO VACÍO", Vector2(388, 476), 15, Color("#6d6a60"))
        draw_string(font, Vector2(388, 498), "Las armas y piezas de equipo están tiradas por las salas.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 12, Color("#8a8778"))
        return
    var worn_now: bool = weapon == key or gear.values().has(key) or (key == "mascara" and _mask_worn()) or (key in ["amuleto", "brazalete"] and _worn(key))
    _text_outline(_equip_name(key) + ("" if worn_now else " · QUITADO"), Vector2(388, 476), 15, CREAM if worn_now else Color("#8a8778"))
    var lines: PackedStringArray = _wrap_lines(_equip_desc(key), 470.0, 12)
    for li in range(mini(2, lines.size())):
        draw_string(font, Vector2(388, 496 + li * 15), lines[li], HORIZONTAL_ALIGNMENT_LEFT, 470.0, 12, SOUL if worn_now else Color("#6d6a60"))
    if WEAPONS.has(key):
        var w: Dictionary = WEAPONS[key]
        draw_string(font, Vector2(388, 526), "DAÑO ×%.2f · ALCANCE %d · RITMO %.2f s · VIGOR %d" % [float(w["dmg"]), int(w["range"]), float(w["cd"]), int(w["cost"])], HORIZONTAL_ALIGNMENT_LEFT, 470.0, 11, Color("#ffd36b"))


# ============================================================ MOBILIARIO DEL TEMPLO
## Piezas del pack «Knowledge Temple» (assets/knowledge) colocadas en cada sala:
## sarcófagos, mesas de lectura, altares, estatuas, columnas rotas y braseros
## animados. Siempre las mismas en la misma sala, en espejo, con sombra,
## colisión baja y comprobación de que todo sigue alcanzable.
const KPROPS := {
    "sarcofago": {"tex": preload("res://assets/knowledge/sarcophagus.png"), "region": Rect2(1, 8, 78, 84), "foot": 0.8},
    "mesa_a": {"tex": preload("res://assets/knowledge/table.png"), "region": Rect2(0, 16, 64, 72), "foot": 0.85},
    "mesa_b": {"tex": preload("res://assets/knowledge/table.png"), "region": Rect2(64, 16, 64, 72), "foot": 0.85},
    "mesa_c": {"tex": preload("res://assets/knowledge/table.png"), "region": Rect2(128, 6, 64, 82), "foot": 0.85},
    "mesa_d": {"tex": preload("res://assets/knowledge/table.png"), "region": Rect2(0, 110, 64, 74), "foot": 0.85},
    "mesa_e": {"tex": preload("res://assets/knowledge/table.png"), "region": Rect2(128, 112, 64, 72), "foot": 0.85},
    "altar_mano": {"tex": preload("res://assets/knowledge/altar.png"), "region": Rect2(7, 28, 66, 72), "foot": 0.8},
    "estatua": {"tex": preload("res://assets/knowledge/statue.png"), "region": Rect2(0, 5, 48, 63), "foot": 0.75},
    "columna_rota": {"tex": preload("res://assets/knowledge/broken_column.png"), "region": Rect2(0, 0, 48, 116), "foot": 0.6},
    "brasero": {"tex": preload("res://assets/knowledge/torch_sheet.png"), "region": Rect2(0, 0, 48, 64), "foot": 0.7, "frames": 8, "light": true},
}
## Estilo de cada piso: qué piezas aparecen (en orden de preferencia).
const FLOOR_KPROPS := [
    ["estatua", "brasero", "columna_rota", "mesa_a"],
    ["mesa_a", "mesa_b", "brasero", "sarcofago"],
    ["sarcofago", "columna_rota", "altar_mano", "brasero"],
    ["columna_rota", "estatua", "mesa_d", "brasero"],
    ["brasero", "columna_rota", "sarcofago", "estatua"],
    ["altar_mano", "brasero", "mesa_c", "mesa_e"],
    ["estatua", "sarcofago", "brasero", "altar_mano"],
    ["mesa_b", "mesa_c", "estatua", "columna_rota"],
    ["columna_rota", "sarcofago", "brasero", "estatua"],
    ["brasero", "altar_mano", "sarcofago", "estatua"],
]
## Huecos posibles: [x de la base, y de la base, altura máxima de la pieza].
## Fila del fondo (junto al muro) y huecos laterales, lejos de la entrada y la salida.
const KPROP_SLOTS := [
    [140.0, 206.0, 92.0], [252.0, 206.0, 92.0], [366.0, 206.0, 92.0],
    [100.0, 262.0, 130.0], [210.0, 546.0, 90.0], [350.0, 546.0, 90.0],
]
const KPROP_BOOKS := preload("res://assets/knowledge/books.png")
var kprop_books: Array = [] # [posición, región] libros caídos junto a las mesas


func _place_wall_props() -> void:
    kprop_books.clear()
    if in_tutorial or _has("tutorial") or _room().has("walls") or _room().has("colossus"):
        return
    var rng := RandomNumberGenerator.new()
    rng.seed = hash("mobiliario:" + _room_key())
    var style: Array = FLOOR_KPROPS[clampi(current_floor, 0, FLOOR_KPROPS.size() - 1)]
    var keep: Array = _kprop_keep_points()
    var mirror: bool = bool(_floor().get("mirror", false))
    var wanted: int = 3 + rng.randi_range(0, 1) # parejas (pieza + su reflejo)
    var slots: Array = KPROP_SLOTS.duplicate()
    # Barajado estable: cada sala usa sus huecos.
    for i in range(slots.size() - 1, 0, -1):
        var j: int = rng.randi_range(0, i)
        var tmp = slots[i]
        slots[i] = slots[j]
        slots[j] = tmp
    var placed: int = 0
    var used: Array = [] # cada pieza, una sola pareja por sala: variedad
    for slot in slots:
        if placed >= wanted:
            break
        var candidates: Array = style.filter(func(kk): return not used.has(kk))
        if candidates.is_empty():
            break
        var first: int = rng.randi_range(0, candidates.size() - 1)
        for k in range(candidates.size()):
            var key: String = candidates[(first + k) % candidates.size()]
            var info: Dictionary = KPROPS[key]
            var reg: Rect2 = info["region"]
            if reg.size.y > float(slot[2]):
                continue
            var pair: Array = []
            for side in [0, 1]:
                var bx: float = float(slot[0]) if side == 0 else 960.0 - float(slot[0])
                pair.append(_kprop_entry(key, Vector2(bx, float(slot[1])), (side == 1) != mirror))
            if not (_kprop_fits(pair[0], keep) and _kprop_fits(pair[1], keep)):
                continue
            var added: Array = []
            for e in pair:
                room_props.append(e)
                obstacles.append(e["foot_rect"])
                added.append(e)
            if _kprop_reachable(keep):
                placed += 1
                used.append(key)
                if key.begins_with("mesa"):
                    _kprop_scatter_books(pair, rng)
                break
            for e in added: # tapaba el paso: fuera
                room_props.erase(e)
                obstacles.erase(e["foot_rect"])


func _kprop_entry(key: String, base: Vector2, flip: bool) -> Dictionary:
    var info: Dictionary = KPROPS[key]
    var reg: Rect2 = info["region"]
    var rect := Rect2(base.x - reg.size.x * 0.5, base.y - reg.size.y, reg.size.x, reg.size.y)
    var fw: float = reg.size.x * float(info["foot"])
    var foot: Rect2 = _alpha_footprint(info["tex"], rect, flip, reg)
    if foot.size.x <= 2.0:
        foot = Rect2(base.x - fw * 0.5, base.y - 14.0, fw, 12.0)
    return {"tex": info["tex"], "rect": rect, "base": base.y, "shadow": true, "light": bool(info.get("light", false)),
        "flip": flip, "region": reg, "frames": int(info.get("frames", 1)), "kkey": key,
        "foot_rect": foot}


## Lo que nunca se tapa: almas, objetos, cofre, puerta, entrada, enemigos, PNJ,
## trampas y todo lo que se usa en la sala.
func _kprop_keep_points() -> Array:
    var keep: Array = relics.duplicate()
    keep.append_array([door_pos, Vector2(115, 359), enemy_pos])
    for p in [seal_pos, altar_pos, archive_pos, book_pos]:
        if Vector2(p) != Vector2.ZERO and (_has("sello") or _has("altar") or _has("archivo") or _room().has("seal")):
            keep.append(p)
    for item in room_items:
        keep.append(item["pos"])
    var rd: Dictionary = _room()
    for k in ["chest", "inscription"]:
        if rd.has(k):
            keep.append(rd[k][0])
    for k in ["merchant", "elder", "elder_boss", "rescue", "mask"]:
        if rd.has(k) and rd[k] is Vector2:
            keep.append(rd[k])
    for k in ["traps", "flames", "braziers", "rams", "hounds", "pillars", "guides"]:
        for q in rd.get(k, []):
            if q is Vector2:
                keep.append(q)
    for pd in rd.get("pendulums", []):
        for t in range(-2, 3):
            keep.append(Vector2(pd[0]) + Vector2(float(pd[1]) * float(t) * 0.5, 0.0))
    if _pilgrim_present():
        keep.append(pilgrim_pos)
    return keep


func _kprop_fits(e: Dictionary, keep: Array) -> bool:
    var rect: Rect2 = e["rect"]
    var foot: Rect2 = e["foot_rect"]
    if foot.position.x < 66.0 or foot.end.x > 894.0:
        return false
    for q in keep:
        var p := Vector2(q)
        if foot.grow(60.0).has_point(p) or rect.grow(26.0).has_point(p):
            return false
    for prop in room_props:
        if (prop["rect"] as Rect2).grow(6.0).intersects(rect):
            return false
    for o in obstacles:
        if (o as Rect2).grow(20.0).intersects(foot):
            return false
    return true


## Búsqueda en anchura sobre una rejilla: desde la entrada hay que poder
## llegar junto a cada punto importante y a la puerta.
func _kprop_reachable(keep: Array) -> bool:
    var step: float = 12.0
    var x0: float = 66.0
    var y0: float = 158.0
    var cols: int = int((894.0 - x0) / step)
    var rows: int = int((550.0 - y0) / step)
    var seen := PackedByteArray()
    seen.resize(cols * rows)
    var start := Vector2i(int((115.0 - x0) / step), int((359.0 - y0) / step))
    var queue: Array = [start]
    seen[start.y * cols + start.x] = 1
    while not queue.is_empty():
        var c: Vector2i = queue.pop_back()
        for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
            var n: Vector2i = c + d
            if n.x < 0 or n.y < 0 or n.x >= cols or n.y >= rows or seen[n.y * cols + n.x] != 0:
                continue
            if _is_blocked(Vector2(x0 + float(n.x) * step, y0 + float(n.y) * step)):
                seen[n.y * cols + n.x] = 2
                continue
            seen[n.y * cols + n.x] = 1
            queue.append(n)
    var targets: Array = keep.duplicate()
    targets.append(door_pos + Vector2(-30, 0))
    for q in targets:
        var p := Vector2(q)
        if p.x < x0 or p.y < y0 or p.x > 894.0 or p.y > 550.0:
            continue
        var ok: bool = false
        var cx: int = int((p.x - x0) / step)
        var cy: int = int((p.y - y0) / step)
        for dy in range(-4, 5):
            for dx in range(-4, 5):
                var nx: int = cx + dx
                var ny: int = cy + dy
                if nx >= 0 and ny >= 0 and nx < cols and ny < rows and seen[ny * cols + nx] == 1:
                    ok = true
                    break
            if ok:
                break
        if not ok:
            return false
    return true


func _kprop_scatter_books(pair: Array, rng: RandomNumberGenerator) -> void:
    for e in pair:
        var r: Rect2 = e["rect"]
        for n in range(rng.randi_range(1, 2)):
            var cell := Vector2i(rng.randi_range(0, 3), rng.randi_range(1, 3))
            var at := Vector2(r.get_center().x + rng.randf_range(-40.0, 40.0), r.end.y + rng.randf_range(6.0, 22.0))
            if not _is_blocked(at):
                kprop_books.append([at, Rect2(float(cell.x) * 32.0, float(cell.y) * 20.0, 32, 20)])


func _draw_kprop(prop: Dictionary) -> void:
    var reg: Rect2 = prop["region"]
    var frames: int = int(prop.get("frames", 1))
    if frames > 1:
        var f: int = int(elapsed * 10.0 + (prop["rect"] as Rect2).position.x * 0.07) % frames
        reg = Rect2(reg.position + Vector2(float(f) * reg.size.x, 0.0), reg.size)
    var rect: Rect2 = prop["rect"]
    var tint := Color(1, 1, 1).lerp(Color(0.80, 0.82, 0.76), clampf(float(_floor().get("wear", 0.0)) * 0.6, 0.0, 1.0))
    if bool(prop["flip"]):
        _xf(Vector2(rect.end.x, rect.position.y), 0.0, Vector2(-1, 1))
        draw_texture_rect_region(prop["tex"], Rect2(Vector2.ZERO, rect.size), reg, tint)
        _xf(Vector2.ZERO, 0.0, Vector2.ONE)
    else:
        draw_texture_rect_region(prop["tex"], rect, reg, tint)


func _draw_kprop_books() -> void:
    for b in kprop_books:
        draw_texture_rect_region(KPROP_BOOKS, Rect2(Vector2(b[0]) - Vector2(16, 10), Vector2(32, 20)), b[1])


# ============================================================ INICIO, AJUSTES, INTRO, TUTORIAL Y PAUSA
## Los textos en español e inglés viven en scripts/datos/textos.gd.
const Textos := preload("res://scripts/datos/textos.gd")
const T = Textos.T
const LEGAL = Textos.LEGAL
const Ajustes := preload("res://scripts/ajustes.gd")
const GEAR_RECT := Rect2(16, 572, 52, 52)
var settings_return: String = "splash"
## Con qué pestaña (y página legal) se abre la configuración.
var settings_open: Dictionary = {}
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
    return Textos.t(key)


func _lang_pick(pair: Array) -> String:
    return Textos.elegir(pair)


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


## Texto con saltos de línea automáticos dentro de un rectángulo.
func _draw_text_block(text: String, box: Rect2, size: int, color: Color) -> float:
    return Estilo.parrafo(self, text, box, size, color)


## Botón de interfaz con bisel; resaltado al pasar el cursor.
func _ui_button(rect: Rect2, label: String, primary: bool = false, selected: bool = false) -> void:
    Estilo.boton(self, rect, label, primary, rect.has_point(ui_hover) or selected)


# ------------------------------------------------------------ CONFIGURACIÓN
## La configuración es una escena (scenes/pantallas/ajustes.tscn).
func _open_settings(from_mode: String, tab: int = 0, legal: String = "") -> void:
    settings_return = from_mode
    settings_open = {"pestana": tab, "legal": legal}
    game_mode = "settings"
    _sfx("interfaz", -8.0)


func _close_settings() -> void:
    game_mode = settings_return
    _sfx("interfaz", -12.0, 0.9)


## Lista de controles de la pestaña actual: se usa para dibujar y para la entrada.
## Borrar perfil: se borran el progreso de la campaña, los récords de la
## Vigilia y los ajustes, y el juego se reinicia desde cero (intro, tutorial
## y creación del personaje, con todos los pisos bloqueados salvo el I).
const VIGILIA_SAVES := ["user://vigilia_claustro_records.json", "user://prueba_vigilia.json"]


func _wipe_everything() -> void:
    Ajustes.borrar_todo(_save_path())
    Progreso.borrar()
    for path in VIGILIA_SAVES:
        if (path.contains("prueba") == Engine.has_meta("modo_prueba")) and FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    Ajustes.aplicar_audio()
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
    vigil_unlocked = false
    odon_told = false
    weapon = ""
    stowed_weapon = ""
    gear = {}
    gear_owned = {}
    unworn = {}
    checkpoint = [-1, -1]


# ------------------------------------------------------------ PAUSA
func _open_pause() -> void:
    if game_mode != "play":
        return
    game_mode = "pause"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -8.0, 0.8)


func _pause_options() -> Array:
    var opts := ["reanudar", "ajustes", "perfil", "habilidades"]
    if in_tutorial:
        opts.append("saltar_tutorial")
    opts.append("volver_inicio")
    return opts


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
    _name_edit_open()


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
    _name_edit_close()
    create_step = 1
    _sfx("interfaz", -8.0, 1.0)


func _create_finish() -> void:
    _name_edit_close()
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
        _name_edit_open()
    else:
        _name_edit_close()
        game_mode = "title"
    _sfx("interfaz", -10.0, 0.8)


## Teclas en pantalla: [rect, acción]. Acción: una letra o «borrar»,
## «espacio», «azar», «siguiente».
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
    return DASH_COOLDOWN_MULT * _dash_cost() / _stamina_regen() * (0.9 if gear.get("botas", "") != "" else 1.0)


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


# --- Puertas laterales y PNJ que se separan ------------------------------------
## Cada sala tiene más puertas que la salida: la entrada por la que llegaste
## (izquierda) y dos pasos laterales con rastrillo, abajo a cada lado. Cuando
## un grupo se separa de ti, se le ve cruzar uno de esos pasos y desaparecer.
const SIDE_DOOR_Y := 485.0
var side_door_open := {-1: 0.0, 1: 0.0}


func _side_door_gap(side: int, y: float) -> Rect2:
    var x: float = 46.0 if side < 0 else W - 46.0 - 19.0
    return Rect2(x, y - 36.0, 19.0, 72.0)


func _draw_side_doors() -> void:
    if in_tutorial:
        return
    # Entrada: la puerta por la que llegaste, cerrada a tu espalda.
    var entry: Rect2 = _side_door_gap(-1, 359.0)
    draw_rect(entry, Color("#2a2119"))
    for k in range(3):
        draw_rect(Rect2(entry.position.x + 2.0 + float(k) * 6.0, entry.position.y + 2.0, 4.0, entry.size.y - 4.0), Color("#3b2e22"))
    draw_rect(Rect2(entry.position.x + 3.0, entry.get_center().y - 2.0, entry.size.x - 6.0, 4.0), Color("#5c5446"))
    _side_door_jambs(entry)
    # Pasos laterales: rastrillo de hierro que sube cuando alguien lo cruza.
    for side in [-1, 1]:
        var gap: Rect2 = _side_door_gap(side, SIDE_DOOR_Y)
        var open_k: float = float(side_door_open[side])
        draw_rect(gap, Color("#07090b"))
        if open_k > 0.0:
            var tone := Color(0.89, 0.74, 0.48)
            var dir: float = 1.0 if side < 0 else -1.0
            var mouth: float = gap.end.x if side < 0 else gap.position.x
            draw_polygon(PackedVector2Array([Vector2(mouth, gap.position.y), Vector2(mouth, gap.end.y), Vector2(mouth + dir * 70.0, gap.end.y + 16.0), Vector2(mouth + dir * 70.0, gap.position.y - 16.0)]),
                PackedColorArray([Color(tone, 0.18 * open_k), Color(tone, 0.18 * open_k), Color(tone, 0.0), Color(tone, 0.0)]))
        var lift: float = gap.size.y * open_k
        for k in range(4):
            var bx: float = gap.position.x + 2.0 + float(k) * 5.0
            draw_rect(Rect2(bx, gap.position.y, 2.0, gap.size.y - lift), Color("#4a4f55"))
        for k in range(3):
            var by: float = gap.position.y + 12.0 + float(k) * 20.0
            if by < gap.end.y - lift:
                draw_rect(Rect2(gap.position.x, by, gap.size.x, 2.0), Color("#5d636a"))
        _side_door_jambs(gap)


func _side_door_jambs(gap: Rect2) -> void:
    for y in [gap.position.y - 9.0, gap.end.y]:
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#454c3c"))
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 2.0), Color("#68715a"))
        draw_rect(Rect2(gap.position.x - 6.0, y, 31.0, 9.0), Color("#15170f"), false, 1.0)


## El grupo se despide y sale por el paso lateral más cercano: no te siguen más.
func _allies_part_ways(msg: String) -> void:
    var any: bool = false
    for ally in allies:
        if bool(ally["alive"]) and not bool(ally.get("gone", false)):
            ally["leaving"] = true
            ally["exit_side"] = -1 if Vector2(ally["pos"]).x < 480.0 else 1
            any = true
    if any:
        mission_banner = msg
        mission_banner_t = 4.0


func _ally_walk_out(ally: Dictionary, dt: float) -> void:
    var side: int = int(ally.get("exit_side", -1))
    var gap: Rect2 = _side_door_gap(side, SIDE_DOOR_Y)
    var inside := Vector2(gap.end.x + 26.0 if side < 0 else gap.position.x - 26.0, SIDE_DOOR_Y + 8.0)
    var out := Vector2(gap.get_center().x, SIDE_DOOR_Y + 8.0)
    var pos: Vector2 = ally["pos"]
    var target: Vector2 = out if pos.distance_to(inside) < 8.0 or absf(pos.x - out.x) < absf(inside.x - out.x) else inside
    var nxt: Vector2 = pos.move_toward(target, 85.0 * dt)
    var moved: Vector2 = nxt - pos
    ally["moving"] = moved.length() > 0.1
    if moved.length() > 0.1:
        ally["facing"] = (2 if moved.x > 0.0 else 3) if absf(moved.x) > absf(moved.y) else (0 if moved.y > 0.0 else 1)
    ally["pos"] = nxt
    ally["prev"] = nxt
    if nxt.distance_to(out) < 4.0:
        ally["gone"] = true
        _emit(out + Vector2(0, -20), 10, Color(0.6, 0.58, 0.5, 0.6), 20.0, 60.0, 0.6, 3.0, -10.0, Vector2.UP, 1.0)
        _sfx("k_metal", -16.0, 0.7)


func _update_side_doors(dt: float) -> void:
    for side in [-1, 1]:
        var want: float = 0.0
        for ally in allies:
            if bool(ally.get("leaving", false)) and not bool(ally.get("gone", false)) and int(ally.get("exit_side", 0)) == side \
                    and Vector2(ally["pos"]).distance_to(_side_door_gap(side, SIDE_DOOR_Y).get_center()) < 150.0:
                want = 1.0
        side_door_open[side] = move_toward(float(side_door_open[side]), want, dt * (1.6 if want > 0.0 else 0.8))


## Cuidar al grupo: si llegan todos, bendición y un regalo; cada muerte ya restó.
func _escort_blessing(all_alive: bool) -> void:
    if not all_alive:
        return
    _karma(1, "Protegiste a todo el grupo")
    bag["vial"] = int(bag.get("vial", 0)) + 1
    float_fx.append({"pos": player_pos + Vector2(0, -104), "text": "+1 VIAL DE SANGRE", "color": Color("#ffd36b"), "t": 0.0})
    _gift_banner("vial", "EL GRUPO TE DA")
    _save_progress()


# --- El mensaje de Mara para Odón (Piso III) ----------------------------------------
## La nota del cofre del III-1 es para Odón, que caza contigo en ese piso.
const MARA_CHEST := "2:0"
var odon_told: bool = false


func _odon_message_ready() -> bool:
    if odon_told or not chests_opened.has(MARA_CHEST) or not allies_here:
        return false
    return _ally_alive_named("ODÓN")


func _give_odon_message() -> bool:
    if not _odon_message_ready():
        return false
    for ally in allies:
        if str(ally["name"]) == "ODÓN" and bool(ally["alive"]) and player_pos.distance_to(ally["pos"]) < 70.0:
            odon_told = true
            _dialog([[_hero_name(), "Odón. En un cofre de arriba había una nota de Mara. Dice que te esperó todo lo que pudo."],
                ["ODÓN", "...Mara. Entonces llegó hasta aquí. Siempre le dije que no me esperara."],
                ["ODÓN", "Gracias por decírmelo. Toma: era para cuando la encontrara. Ya no lo voy a necesitar."]])
            bag["reliquia"] = int(bag.get("reliquia", 0)) + 1
            float_fx.append({"pos": player_pos + Vector2(0, -90), "text": "+1 RELIQUIA DE ECOS", "color": Color("#ffd36b"), "t": 0.0})
            _gift_banner("reliquia", "ODÓN TE DA")
            _karma(1, "Le diste a Odón el mensaje de Mara")
            _save_progress()
            return true
    return false


# --- Aliados ---------------------------------------------------------------
func _allies_reset() -> void:
    for d in side_door_open:
        side_door_open[d] = 0.0
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
            _escort_blessing(alive == allies.size())
            _allies_part_ways("Los cazadores bajan por otra puerta. Desde aquí sigues solo.")
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


## Almas propias que cada PNJ lleva encima desde el principio.
const ALLY_OWN_SOULS := 5


func _ally_die(ally: Dictionary) -> void:
    ally["alive"] = false
    ally["dead_key"] = _room_key()
    ally["dead_pos"] = ally["pos"]
    # Suelta todo lo que te quitó más sus propias almas, ahí mismo.
    var loot: int = int(ally.get("hoard", 0)) + ALLY_OWN_SOULS
    ally["hoard"] = 0
    drops.append({"pos": Vector2(ally["pos"]) + Vector2(0, 6), "value": loot})
    float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -78), "text": "SUELTA %d ALMAS" % loot, "color": SOUL, "t": 0.0})
    fear = minf(100.0, fear + 12.0)
    shake = maxf(shake, 0.35)
    float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -60), "text": "%s HA MUERTO" % ally["name"], "color": RED, "t": 0.0})
    _sfx("dano", -6.0, 0.8)
    _ally_say_random(["¡%s! ¡No...!" % ally["name"], "Estaba justo detrás de ti...", "¡Apártate de la línea, maldita sea!"])
    # Ibas a cuidarlos: cada uno que cae pesa en tu marca.
    if _floor_has_trait("aliados") or guiding:
        _karma(-1, "Dejaste morir a %s" % ally["name"])


func _update_allies(dt: float) -> void:
    if not allies_here:
        return
    var tense: bool = _enemy_active() and _enemy_kind() == "segador" and seg_state == "tensa"
    var back: Vector2 = -player_dir.normalized() if player_dir.length() > 0.1 else Vector2.LEFT
    var side := Vector2(-back.y, back.x)
    var idx: int = 0
    for ally in allies:
        ally["line_t"] = maxf(0.0, float(ally["line_t"]) - dt)
        if not bool(ally["alive"]) or bool(ally.get("gone", false)):
            continue
        if bool(ally.get("leaving", false)):
            _ally_walk_out(ally, dt)
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
        # Van a lo suyo: almas, pan o el relicario de vida (si nadie corre peligro).
        if not bool(ally.get("waiting", false)) and not bool(ally.get("flee", false)) and float(ally.get("panic", 0.0)) <= 0.0 and not tense:
            var greed = _ally_greed_target(ally)
            if greed != null:
                target = greed
                speed = 165.0
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
        _ally_pickups(ally)
        _ally_hazards(ally, dt)


func _draw_ally(i: int) -> void:
    var ally: Dictionary = allies[i]
    var sheet: Texture2D = art["enemy_peregrino"]
    var frame: int = 2 + int(elapsed * 8.0 + float(i)) % 4 if bool(ally["moving"]) else int(elapsed * 2.0 + float(i)) % 2
    var region := Rect2(float(frame) * ENEMY_CELL.x, float(ally["facing"]) * ENEMY_CELL.y, ENEMY_CELL.x, ENEMY_CELL.y)
    var pos: Vector2 = ally["pos"]
    var feet := Vector2(roundf(pos.x), roundf(pos.y + 4.0))
    _draw_soft_shadow(pos + Vector2(0.0, 3.0), 12.0)
    _draw_ellipse(pos + Vector2(0.0, 3.0), 17.0, 6.0, Color(0.45, 0.85, 0.6, 0.16))
    _draw_outlined(sheet, Rect2(feet.x - ENEMY_CELL.x * 0.5, feet.y - ENEMY_FEET_Y, ENEMY_CELL.x, ENEMY_CELL.y), region, ALLY_TINTS[i % ALLY_TINTS.size()])


func _draw_ally_labels() -> void:
    if not allies_here:
        return
    for ally in allies:
        if not bool(ally["alive"]) or bool(ally.get("gone", false)):
            continue
        var pos: Vector2 = ally["pos"]
        if bool(ally.get("leaving", false)):
            _label_center("%s SE SEPARA" % ally["name"], pos + Vector2(0.0, -66.0), Color("#e3bd7b"))
            continue
        if bool(ally.get("waiting", false)) and not guiding and player_pos.distance_to(door_pos) < 170.0:
            _label_center("%s · SE QUEDA AQUÍ" % ally["name"], pos + Vector2(0.0, -66.0), Color("#e3bd7b"))
            continue
        if str(ally["name"]) == "ODÓN" and _odon_message_ready():
            var bob: float = sin(elapsed * 4.0) * 3.0
            _label_center("!", pos + Vector2(0.0, -96.0 + bob), Color("#ffd36b"))
            _label_center("DARLE EL MENSAJE DE MARA (%s)" % _key_label("interactuar"), pos + Vector2(0.0, -82.0), Color("#ffd36b"))
        _label_center(str(ally["name"]) + (" · SIN MANO" if bool(ally.get("maimed", false)) else ""), pos + Vector2(0.0, -66.0), Color("#d1747b") if bool(ally.get("maimed", false)) else Color("#9fd8b0"))
        if float(ally["line_t"]) > 0.0:
            _label_center("«%s»" % ally["line"], pos + Vector2(0.0, -84.0), CREAM)
        var ahp: float = float(ally.get("hp", ALLY_HP))
        if ahp < ALLY_HP:
            var bar := Rect2(pos.x - 18.0, pos.y - 58.0, 36.0, 4.0)
            draw_rect(bar.grow(1.0), Color(0, 0, 0, 0.7))
            draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(ahp / ALLY_HP, 0.0, 1.0), bar.size.y)), Color("#c0464f"))
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
const DASH_TIME := 0.22
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


const WALK_SPEED := 157.0
const WALK_ACCEL := 1500.0 # px/s²: a toda velocidad en una décima
const WALK_DECEL := 2100.0
const DASH_PEAK := 640.0 # el esquive arranca rápido…
const DASH_END := 170.0 # …y se frena hasta el paso normal
var player_vel: Vector2 = Vector2.ZERO
var dash_ghosts: Array = [] # siluetas que deja el esquive {pos, dir, t}
var dash_ghost_t: float = 0.0


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
    if hp < hp_prev - 0.01 and gear.get("casco", "") != "":
        hp += (hp_prev - hp) * YELMO_REDUCTION # el yelmo se queda una parte del golpe
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


# --- Llamaradas y péndulos ------------------------------------------------------
## Dos trampas más, con el mismo trato justo que los pinchos: avisan antes de
## herir, el esquive te hace inmune y también hieren a los aliados.
##   flames (en los datos de la sala): rejillas que escupen una columna de fuego.
##   pendulums: [centro, amplitud] — una cuchilla que barre la sala de lado a lado.
const FLAME_CYCLE := 4.2
const FLAME_WARN := 2.4 # chispas y brillo: va a salir
const FLAME_ON := 3.1 # desde aquí quema
const FLAME_DAMAGE := 16.0
const PENDULUM_PERIOD := 3.6
const PENDULUM_DAMAGE := 20.0
var flame_vents: Array = [] # {pos, phase, warned}
var pendulums: Array = [] # {center, amp, phase}


func _load_hazards() -> void:
    flame_vents.clear()
    pendulums.clear()
    var fl: Array = _room().get("flames", [])
    for i in range(fl.size()):
        flame_vents.append({"pos": fl[i], "phase": float(i % 2) * FLAME_CYCLE * 0.5, "warned": false})
    var pl: Array = _room().get("pendulums", [])
    for i in range(pl.size()):
        pendulums.append({"center": pl[i][0], "amp": float(pl[i][1]), "phase": float(i) * 0.9})


func _flame_t(v: Dictionary) -> float:
    return fmod(room_elapsed + float(v["phase"]), FLAME_CYCLE)


## Zona que quema: la rejilla y la columna de fuego que sube de ella.
func _flame_rect(v: Dictionary) -> Rect2:
    var p: Vector2 = v["pos"]
    return Rect2(p.x - 18.0, p.y - 20.0, 36.0, 36.0)


func _pendulum_blade(pd: Dictionary) -> Vector2:
    var w: float = TAU / PENDULUM_PERIOD
    return Vector2(pd["center"]) + Vector2(sin(room_elapsed * w + float(pd["phase"])) * float(pd["amp"]), 0.0)


func _pendulum_pivot(pd: Dictionary) -> Vector2:
    return Vector2(pd["center"]) + Vector2(0.0, -150.0)


## ¿Este punto recibe daño de alguna llamarada o péndulo ahora mismo?
func _hazard_hit(at: Vector2) -> String:
    for v in flame_vents:
        if _flame_t(v) >= FLAME_ON and _flame_rect(v).has_point(at):
            return "llama"
    for pd in pendulums:
        if _pendulum_hits(pd, at):
            return "pendulo"
    return ""


## La cuchilla entera hiere, no solo su punta: se comprueba el cuerpo (tres
## puntos, de la cintura a la cabeza) contra la hoja girada, con margen.
func _pendulum_hits(pd: Dictionary, at: Vector2) -> bool:
    var b: Vector2 = _pendulum_blade(pd)
    if absf(at.y - b.y) > 24.0:
        return false # pasa por delante o por detrás de ti
    var lift: Vector2 = b + Vector2(0, -16)
    var ang: float = (lift - _pendulum_pivot(pd)).angle() - PI * 0.5
    var inv: Transform2D = Transform2D(ang, lift).affine_inverse()
    for h in [10.0, 26.0, 42.0]:
        var q: Vector2 = inv * (at + Vector2(0.0, -h))
        if q.x >= -38.0 and q.x <= 38.0 and q.y >= -14.0 and q.y <= 27.0:
            return true
    return false


func _update_hazards(_dt: float) -> void:
    for v in flame_vents:
        var t: float = _flame_t(v)
        if t >= FLAME_WARN and not bool(v["warned"]):
            v["warned"] = true
            if player_pos.distance_to(v["pos"]) < 280.0:
                _sfx("fuego", -14.0, 1.2)
        elif t < FLAME_WARN:
            v["warned"] = false
        if t >= FLAME_ON and randf() < 0.5:
            _emit(Vector2(v["pos"]) + Vector2(randf_range(-10, 10), -10), 1, Color(1.0, 0.55, 0.2), 30.0, 70.0, 0.5, 2.0, -120.0, Vector2.UP, 0.4, true)
        elif t >= FLAME_WARN and randf() < 0.15:
            _emit(Vector2(v["pos"]) + Vector2(randf_range(-8, 8), -2), 1, Color(1.0, 0.7, 0.3), 10.0, 30.0, 0.4, 1.5, -60.0, Vector2.UP, 0.5, true)
    if dash_left > 0.0 or damage_cd > 0.0:
        return # esquivando se cruza el fuego y la cuchilla
    var hit: String = _hazard_hit(player_pos)
    if hit == "":
        return
    hp -= FLAME_DAMAGE if hit == "llama" else PENDULUM_DAMAGE
    fear = minf(100.0, fear + 10.0)
    damage_cd = 1.0
    if hit == "pendulo":
        # La cuchilla te empuja en la dirección en que barre.
        for pd in pendulums:
            if _pendulum_hits(pd, player_pos):
                var push: float = signf(cos(room_elapsed * TAU / PENDULUM_PERIOD + float(pd["phase"])))
                var to: Vector2 = player_pos + Vector2(push * 34.0, 0.0)
                if not _is_blocked(to):
                    player_pos = to
        _emit(player_pos + Vector2(0, -20), 12, Color(0.6, 0.05, 0.1), 40.0, 140.0, 0.6, 2.0, 260.0, Vector2.UP, 1.2)
        _sfx("k_metal", -8.0, 0.8)
        _say("Una cuchilla barre la sala. Esquiva a su paso.", 3.0)
    else:
        _emit(player_pos + Vector2(0, -18), 14, Color(1.0, 0.5, 0.15), 30.0, 110.0, 0.6, 2.5, -80.0, Vector2.UP, 0.9, true)
        _say("El suelo escupe fuego. Espera a que se apague o esquiva.", 3.0)
    _on_hurt()


func _draw_hazards_floor() -> void:
    for v in flame_vents:
        var p: Vector2 = v["pos"]
        var t: float = _flame_t(v)
        var g := Rect2(p - Vector2(15, 11), Vector2(30, 22))
        draw_rect(g.grow(3.0), Color(0.03, 0.025, 0.03, 0.6))
        draw_rect(g, Color("#2a2522"))
        draw_rect(Rect2(g.position, Vector2(g.size.x, 2)), Color("#544a40"))
        var heat: float = 0.0
        if t >= FLAME_ON:
            heat = 1.0
        elif t >= FLAME_WARN:
            heat = (t - FLAME_WARN) / (FLAME_ON - FLAME_WARN)
        for k in range(4):
            var slot := Rect2(g.position + Vector2(4.0 + k * 6.5, 5), Vector2(3.5, 12))
            draw_rect(slot, Color(0.06, 0.04, 0.03).lerp(Color(1.0, 0.45, 0.12), heat * (0.7 + 0.3 * sin(elapsed * 18.0 + k))))
        # Hollín alrededor.
        _draw_ellipse(p + Vector2(0, 2), 24.0, 8.0, Color(0.0, 0.0, 0.0, 0.18))
        if t >= FLAME_WARN and t < FLAME_ON:
            draw_rect(g.grow(4.0), Color(1.0, 0.5, 0.2, 0.25 + 0.2 * sin(elapsed * 20.0)), false, 1.0)
    for pd in pendulums:
        # Surco en el suelo: dice por dónde pasará la cuchilla.
        var c: Vector2 = pd["center"]
        var a: float = float(pd["amp"])
        draw_line(c + Vector2(-a - 10.0, 4), c + Vector2(a + 10.0, 4), Color(0.0, 0.0, 0.0, 0.35), 6.0)
        draw_line(c + Vector2(-a - 10.0, 3), c + Vector2(a + 10.0, 3), Color(0.55, 0.5, 0.42, 0.18), 1.0)
        var b: Vector2 = _pendulum_blade(pd)
        _draw_ellipse(b + Vector2(0, 6), 18.0, 5.0, Color(0, 0, 0, 0.35))


## Lo que se alza: la columna de fuego y la cuchilla con su cadena.
func _draw_hazards_air() -> void:
    for v in flame_vents:
        var t: float = _flame_t(v)
        if t < FLAME_ON:
            continue
        var p: Vector2 = v["pos"]
        var k: float = clampf((t - FLAME_ON) / 0.2, 0.0, 1.0) * clampf((FLAME_CYCLE - t) / 0.25, 0.0, 1.0)
        for i in range(7):
            var h: float = (78.0 + 12.0 * sin(elapsed * 14.0 + float(i))) * k
            var wv: float = (18.0 - float(i) * 2.0) * k
            var y0: float = p.y - h * (float(i) / 6.0)
            var col := Color(1.0, 0.35 + 0.1 * float(i), 0.1 + 0.08 * float(i), 0.55 - float(i) * 0.06)
            draw_polygon(PackedVector2Array([p + Vector2(-wv, 2), p + Vector2(wv, 2), Vector2(p.x + wv * 0.3 + sin(elapsed * 11.0 + i) * 3.0, y0 - 14.0)]),
                PackedColorArray([col, col, Color(col.r, col.g, col.b, 0.0)]))
    for pd in pendulums:
        var pivot: Vector2 = _pendulum_pivot(pd)
        var b: Vector2 = _pendulum_blade(pd)
        var lift: Vector2 = b + Vector2(0, -16) # la hoja vuela a la altura del pecho
        # Cadena por eslabones.
        var n: int = 14
        for i in range(n):
            var q: Vector2 = pivot.lerp(lift, float(i) / float(n))
            draw_rect(Rect2(q - Vector2(2, 3), Vector2(4, 6)), Color("#14110f"))
            draw_rect(Rect2(q - Vector2(1, 2), Vector2(2, 4)), Color("#8a857a") if i % 2 == 0 else Color("#5c5850"))
        var ang: float = (lift - pivot).angle() - PI * 0.5
        _xf(lift, ang, Vector2.ONE)
        # Media luna de acero con filo brillante y contorno oscuro.
        var blade := PackedVector2Array([Vector2(-30, -2), Vector2(30, -2), Vector2(24, 10), Vector2(10, 17), Vector2(0, 19), Vector2(-10, 17), Vector2(-24, 10)])
        var outline := blade.duplicate()
        outline.append(blade[0])
        draw_colored_polygon(blade, Color("#6f767c"))
        draw_colored_polygon(PackedVector2Array([Vector2(-26, 0), Vector2(26, 0), Vector2(18, 6), Vector2(-18, 6)]), Color("#4d5358"))
        draw_polyline(outline, Color("#101214"), 2.0)
        draw_polyline(PackedVector2Array([Vector2(-24, 10), Vector2(-10, 17), Vector2(0, 19), Vector2(10, 17), Vector2(24, 10)]), Color("#eef3f5"), 2.0)
        draw_rect(Rect2(-6, -8, 12, 8), Color("#3b2f28"))
        draw_rect(Rect2(-6, -8, 12, 8), Color("#101214"), false, 1.0)
        _xf(Vector2.ZERO, 0.0, Vector2.ONE)
        # Estela al barrer.
        var vel: float = cos(room_elapsed * TAU / PENDULUM_PERIOD + float(pd["phase"]))
        for k in range(1, 4):
            draw_circle(lift + Vector2(-vel * float(k) * 9.0, 8), 10.0 - float(k) * 2.0, Color(0.85, 0.9, 0.95, 0.06 * absf(vel)))


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
        ["resonancia", ("RUGIDO" if _mask_worn() else "RESONANCIA") + " · NIVEL %d" % ability_level, _key_label("resonancia"),
            ("Con la Máscara de Porcelana la onda llega más lejos y espanta a los mastines 5 s. " if _mask_worn() else "") + "Aturde a las entidades cercanas y les hace %d de daño." % int(_pulse_damage()), has_pulse, "%d vigor · se recarga con la barra" % int(RESONANCE_COST)],
        ["vigor", "ESQUIVAR", _key_label("esquivar"),
            "Impulso hacia donde te mueves o, quieto, hacia donde miras. Pasas por encima de las trampas.", true, "%d vigor · %.1f s de recarga" % [int(_dash_cost()), _dash_cooldown()]],
        ["llama_interior", "LLAMA INTERIOR", "PASIVA",
            "Enciendes la antorcha sin gastar fósforos.", has_inner_flame, "altar"],
        ["corazon", "RESPIRO", "PASIVA",
            "Tras %d s sin recibir daño recuperas %d de vida por segundo (no con el miedo al máximo)." % [int(REGEN_WAIT), int(REGEN_RATE)], true, "siempre"],
    ]


func _eco_floor(key: String) -> String:
    for f in FLOORS:
        if str(f.get("eco", "")) == key:
            return str(f["number"])
    return "?"


# ------------------------------------------------------------ ARTE (etapa 2)
## Capas visuales nuevas: tipografía gótica de rótulos, partículas, niebla,
## rayos de luz, fundidos y un postproceso con bloom, gradación y viñeta.
const FADE_TIME := 0.5
var title_font: Font
var motes: Array = [] # {p, v, s, f, ph}
var fx_parts: Array = [] # {p, v, life, max, size, col, grav, glow}
var fade_t: float = 0.0
var death_fx: float = -1.0
## Pantalla de muerte (y de victoria): se queda unos segundos sin poder
## cerrarse, para que un toque de más no se la lleve antes de leerla.
const END_LOCK := 2.6
var end_t: float = 0.0
var respawn_fx: float = 0.0
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
    Estilo.titulo(self, msg, at, size, color, width)


## Filete ornamental dorado con rombo central.
func _ornament_line(center: Vector2, half: float) -> void:
    Estilo.adorno(self, center, half)


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
        mat.set_shader_parameter("vignette", 0.36 + fear / 100.0 * 0.3)


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


## Tarjetas del menú de pisos (scenes/pantallas/pisos.tscn).
func _floor_cards() -> Array:
    var unlocked: int = _floors_unlocked()
    var cards: Array = []
    for i in range(FLOOR_PLAN.size()):
        var playable: bool = i < FLOORS.size()
        var open: bool = playable and i <= unlocked
        var c := {"numero": FLOOR_PLAN[i][0], "abierto": open,
            # Sin pistas: lo que no has alcanzado no tiene nombre todavía.
            "nombre": _tc(FLOOR_PLAN[i][1]) if open else "???"}
        if not playable:
            c["estado"] = "EN LAS PROFUNDIDADES"
            c["color_estado"] = Color("#5d5865")
        elif not open:
            c["estado"] = "SIN ALCANZAR"
            c["color_estado"] = Color("#8a5a64")
        else:
            var eco: String = str(FLOORS[i].get("eco", ""))
            var done: bool = eco != "" and ecos.has(eco)
            c["estado"] = "SUPERADO" if done else "DISPONIBLE"
            c["color_estado"] = SOUL if done else Color("#9fd8b0")
            if _has_checkpoint(i):
                c["estado"] = "SEGUIR · SALA %d" % (int(checkpoint[1]) + 1)
                c["color_estado"] = Color("#ffd36b")
            if done and ICONS.has("eco_" + eco):
                c["icono"] = ICONS["eco_" + eco]
            elif bool(FLOORS[i].get("final", false)) and ICONS.has("calavera"):
                c["icono"] = ICONS["calavera"]
                c["icono_tinte"] = Color(1.0, 0.75, 0.6)
        if not open:
            c["candado"] = ICONS["calavera"]
        cards.append(c)
    return cards


func _open_floors() -> void:
    game_mode = "floors"
    floors_sel = mini(current_floor, _floors_unlocked())
    _sfx("interfaz", -8.0, 0.9)


## Punto de control: cada sala a la que entras queda guardada. Si cierras el
## juego o vuelves al menú, el piso se retoma desde esa sala (no desde la I).
var checkpoint: Array = [-1, -1] # [piso, sala]


func _set_checkpoint() -> void:
    # Solo en partida (el menú también usa _enter_room para el fondo).
    if in_tutorial or not game_mode in ["play", "floor_intro"] or player_name == "" or current_floor < 0 or current_floor >= FLOORS.size():
        return
    if checkpoint == [current_floor, current_room]:
        return
    checkpoint = [current_floor, current_room]
    _save_progress()


func _has_checkpoint(i: int) -> bool:
    return int(checkpoint[0]) == i and int(checkpoint[1]) > 0


## Retoma un piso desde la última sala alcanzada, con la antorcha y fósforos.
func _resume_at(i: int, room: int) -> void:
    _new_run()
    current_floor = i
    current_room = clampi(room, 0, (FLOORS[i]["rooms"] as Array).size() - 1)
    has_wood = true
    has_torch = true
    matches = maxi(matches, MATCHES_FIRST_BOX)
    floor_intro_eco = ""
    _on_floor_start()
    game_mode = "floor_intro"
    _enter_room()
    _say("Vuelves a la última sala que alcanzaste: %s." % str(_room()["name"]), 3.5)
    _sfx("puerta", -4.0, 0.7)
    _transition("espiral", false, 1.0)


func _choose_floor(i: int) -> void:
    if i >= FLOORS.size():
        _say("Este piso todavía se está construyendo en las profundidades.", 2.6)
        _sfx("toque", -10.0)
        return
    if i > _floors_unlocked():
        _say("Aún no has llegado tan abajo. Supera el piso anterior.", 2.6)
        _sfx("toque", -10.0)
        return
    if player_name != "" and _has_checkpoint(i) and bool(Ajustes.obtener("tutorial_hecho")):
        _resume_at(i, int(checkpoint[1]))
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


# ------------------------------------------------------------ DEL PRIMER JUEGO (etapa 3)
## Lo que se aprovecha de «Craving Candy», el primer juego del autor:
## alimañas que patrullan y mueren de un esquive, nidos que las reponen,
## el cuerpo que queda al morir, transiciones con máscara, resumen al
## terminar el piso, cursor propio y controles táctiles de Kenney.
const ALIMANA_TEX := preload("res://assets/visual/enemies/alimana.png")
## Más alimañas (herramientas/generar_bichos.py), misma hoja de 4 x 2 celdas.
const CRITTER_TEX := {
    "rata": ALIMANA_TEX,
    "murcielago": preload("res://assets/visual/enemies/murcielago.png"),
    "arana": preload("res://assets/visual/enemies/arana.png"),
}
## Cómo es cada bicho: velocidad, persecución, olfato (px), mordisco y miedo.
##   murciélago: vuela (cruza columnas), rápido y de mordisco flojo.
##   araña: lenta al patrullar, pero salta lejos y su veneno da más miedo.
const CRITTER_KINDS := {
    "rata": {"speed": 62.0, "chase": 92.0, "smell": 95.0, "bite": 6.0, "fear": 4.0, "fly": false},
    "murcielago": {"speed": 84.0, "chase": 128.0, "smell": 130.0, "bite": 4.0, "fear": 5.0, "fly": true},
    "arana": {"speed": 40.0, "chase": 118.0, "smell": 110.0, "bite": 9.0, "fear": 9.0, "fly": false},
}
## Qué alimañas viven en cada piso (las salas sin trayectos propios las reparten así).
const FLOOR_CRITTERS := [
    ["rata"], ["rata", "murcielago"], ["rata", "arana"], ["arana", "murcielago"], ["rata", "murcielago"],
    ["murcielago", "rata"], ["arana", "murcielago"], ["rata", "arana"], ["murcielago", "arana"], ["rata", "murcielago", "arana"],
]
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
    if in_tutorial or _has("tutorial") or _room().has("merchant"):
        return
    var spot: Dictionary = CRITTER_SPOTS[_room_key()] if CRITTER_SPOTS.has(_room_key()) else _critter_spots_auto()
    var kinds: Array = spot.get("kinds", [])
    var paths: Array = spot.get("paths", [])
    for i in range(paths.size()):
        var path: Array = paths[i]
        critters.append({"pos": path[0] + (path[1] - path[0]) * randf_range(0.1, 0.9), "a": path[0], "b": path[1], "to_b": randf() < 0.5,
            "alive": true, "dead_t": 0.0, "respawn": bool(spot.get("nest", false)), "flip": false, "bite_cd": 0.0,
            "kind": str(kinds[i]) if i < kinds.size() else "rata"})


## Trayectos para las salas sin trayectos escritos: siempre los mismos en la
## misma sala, libres de columnas (los voladores no lo necesitan) y lejos de la
## entrada para que nada muerda nada más cruzar la puerta.
func _critter_spots_auto() -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = hash("bichos:" + _room_key())
    var pool: Array = FLOOR_CRITTERS[clampi(current_floor, 0, FLOOR_CRITTERS.size() - 1)]
    var want: int = clampi(1 + current_floor / 3 + rng.randi_range(0, 1), 1, 3)
    var lanes: Array = [195.0, 290.0, 425.0, 455.0, 505.0, 530.0]
    var paths: Array = []
    var kinds: Array = []
    var tries: int = 0
    while paths.size() < want and tries < 40:
        tries += 1
        var kind: String = pool[rng.randi() % pool.size()]
        var y: float = lanes[rng.randi() % lanes.size()]
        if kind == "murcielago":
            y = rng.randf_range(200.0, 420.0)
        var x0: float = rng.randf_range(220.0, 420.0)
        var x1: float = rng.randf_range(560.0, 840.0)
        var a := Vector2(x0, y)
        var b := Vector2(x1, y)
        var ok: bool = true
        for q in paths:
            if absf(float(q[0].y) - y) < 40.0:
                ok = false
        if ok and kind != "murcielago":
            var steps: int = int((x1 - x0) / 12.0)
            for k in range(steps + 1):
                if _is_blocked(a.lerp(b, float(k) / float(maxi(1, steps)))):
                    ok = false
                    break
        if not ok:
            continue
        paths.append([a, b])
        kinds.append(kind)
    return {"paths": paths, "kinds": kinds, "nest": current_floor >= 4}


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
        var info: Dictionary = CRITTER_KINDS.get(str(cr.get("kind", "rata")), CRITTER_KINDS["rata"])
        var pos: Vector2 = cr["pos"]
        var d: float = pos.distance_to(player_pos)
        var target: Vector2
        var speed: float = float(info["speed"])
        var smell: float = float(info["smell"])
        if d < smell:
            target = player_pos # huele la sangre y se lanza
            speed = float(info["chase"])
        else:
            target = cr["b"] if bool(cr["to_b"]) else cr["a"]
            if pos.distance_to(target) < 6.0:
                cr["to_b"] = not bool(cr["to_b"]) # al llegar, da media vuelta
        var nxt: Vector2 = pos.move_toward(target, speed * dt)
        if bool(info["fly"]) or not _is_blocked(nxt) or d >= smell:
            if absf(nxt.x - pos.x) > 0.01:
                cr["flip"] = nxt.x < pos.x
            cr["pos"] = nxt
        # Contacto: esquivando la aplastas; si no, muerde.
        if d < 20.0:
            if dash_left > 0.0:
                _critter_die(cr)
            elif float(cr["bite_cd"]) <= 0.0 and damage_cd <= 0.0:
                cr["bite_cd"] = 1.0
                hp -= float(info["bite"])
                damage_cd = 0.6
                fear = minf(100.0, fear + float(info["fear"]))
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


## Altura de vuelo del murciélago (los demás van por el suelo).
func _critter_lift(cr: Dictionary, i: int) -> float:
    if str(cr.get("kind", "rata")) != "murcielago":
        return 0.0
    if not bool(cr["alive"]):
        return maxf(0.0, 26.0 - float(cr["dead_t"]) * 90.0) # cae al morir
    return 26.0 + 6.0 * sin(elapsed * 5.0 + float(i) * 1.7)


func _draw_critter(i: int) -> void:
    var cr: Dictionary = critters[i]
    var kind: String = str(cr.get("kind", "rata"))
    var tex: Texture2D = CRITTER_TEX.get(kind, ALIMANA_TEX)
    var at: Vector2 = Vector2(cr["pos"]).round()
    var region: Rect2
    if bool(cr["alive"]):
        var fps: float = 16.0 if kind == "murcielago" else (13.0 if kind == "arana" else 10.0)
        var frame: int = int(elapsed * fps + float(i) * 1.3) % 4
        region = Rect2(float(frame) * 24.0, 0, 24, 16)
    else:
        var df: int = mini(3, int(float(cr["dead_t"]) * 8.0))
        region = Rect2(float(df) * 24.0, 16, 24, 16)
    var lift: float = _critter_lift(cr, i)
    _draw_soft_shadow(at + Vector2(0, 2), 10.0 - lift * 0.15, 1.0 - lift * 0.015)
    var y: float = at.y - 28.0 - lift
    if bool(cr["flip"]):
        _xf(Vector2(at.x, 0), 0.0, Vector2(-1, 1))
        draw_texture_rect_region(tex, Rect2(-24.0, y, 48, 32), region)
        _xf(Vector2.ZERO, 0.0, Vector2.ONE)
    else:
        draw_texture_rect_region(tex, Rect2(at.x - 24.0, y, 48, 32), region)


# --- El cuerpo de tu vida anterior -------------------------------------------
func _draw_life_corpse() -> void:
    if life_corpse.is_empty() or str(life_corpse["key"]) != _room_key():
        return
    var at: Vector2 = life_corpse["pos"]
    # Charco de sangre y tu propio cuerpo tendido (tu hoja de sprites, girada).
    _draw_ellipse(at + Vector2(4, 2), 30.0, 10.0, Color(0.32, 0.02, 0.05, 0.85))
    _draw_ellipse(at + Vector2(-6, 4), 18.0, 6.0, Color(0.45, 0.03, 0.07, 0.8))
    _xf(at + Vector2(-4, -2), PI * 0.5, Vector2.ONE)
    draw_texture_rect_region(_hero_sheet(), Rect2(-28, -20, 40, 56), Rect2(0, 0, 40, 56), Color(0.55, 0.5, 0.55, 1.0))
    _xf(Vector2.ZERO, 0.0, Vector2.ONE)
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
    _text_outline("ALMAS %d/%d" % [got, relics.size()], Vector2(box.position.x + 30.0, box.position.y + 17.0), 12, SOUL if got == relics.size() else CREAM)


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
        var at: Vector2 = Vector2(cr["pos"]).round() + Vector2(0.0, -_critter_lift(cr, i))
        var kind: String = str(cr.get("kind", "rata"))
        var eye: Vector2 = at + (Vector2(0.0, -14.0) if kind == "murcielago" else Vector2((-8.0 if bool(cr["flip"]) else 8.0) if kind == "arana" else (-12.0 if bool(cr["flip"]) else 12.0), -12.0))
        var blink: float = 0.0 if int(elapsed * 1.3 + float(i) * 0.7) % 5 == 0 and fmod(elapsed * 1.3, 1.0) < 0.12 else 1.0
        draw_circle(eye, 5.0, Color(1.0, 0.15, 0.15, 0.12 * blink))
        draw_rect(Rect2(eye - Vector2(1, 1), Vector2(2, 2)), Color(1.0, 0.3, 0.3, 0.9 * blink))


func _save_path() -> String:
    return Progreso.ruta()


# ------------------------------------------------------------ SALTAR Y VOLVER A LA PAUSA
## Botón para saltar diálogos y la intro (además de ESC); se puede tocar.
const SKIP_BTN := Rect2(690, 390, 160, 34) # sobre el cuadro de diálogo
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
        if matches <= 0 and not in_tutorial:
            _say("Sin fósforos no hay chispa para prender las raíces.", 2.4)
            return
        _spend_match()
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
    return PULSE_RADIUS * (1.5 if _mask_worn() else 1.0)


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
        if to_h.length() < _strike_range() + 14.0 and (to_h.length() < 26.0 or to_h.normalized().dot(strike_dir) > 0.2):
            h["flee"] = 1.4
            h["pos"] = Vector2(h["pos"]) + to_h.normalized() * 18.0 if not _is_blocked(Vector2(h["pos"]) + to_h.normalized() * 18.0) else h["pos"]
            float_fx.append({"pos": Vector2(h["pos"]) + Vector2(0, -50), "text": "INMUNE", "color": Color("#b4bba8"), "t": 0.0})
            _sfx("k_metal", -10.0, 0.8)
    if _room().has("rescue") and rescue_state == "atrapado" and player_pos.distance_to(_room()["rescue"]) < _strike_range() + 20.0:
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
    ["vigilia", "LLAVE DE LA VIGILIA", 500, "Abre la Vigilia del Claustro en el menú. Su botín llega a tu bolsa."],
]
var guiding: bool = false
var guided: Array = [] # peregrinos que bajaron contigo (para el Piso VII)
var trinkets: Array = [] # objetos del Mercader que se quedan contigo
var hand_lost: bool = false
var bones_used: bool = false
var shop_sel: int = 0
var shop_info: bool = false # ficha de la Vigilia abierta antes de pagar
var merchant_open_t: float = 0.0
var guides_rewarded: bool = false


func _strike_damage() -> float:
    var fuerza: float = 1.0 + (0.04 * float(ecos.size()) if ecos.has("fuerza") else 0.0)
    return STRIKE_DAMAGE * _weapon_stat("dmg") * (1.0 + 0.1 * float(_trinket_bonus("brazalete"))) * _level_power() * fuerza


func _stamina_regen() -> float:
    return STAMINA_REGEN * (1.0 + 0.1 * float(_trinket_bonus("amuleto"))) * (1.0 + LEVEL_VIGOR * float(player_level - 1))


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
            _escort_blessing(alive_n == allies.size())
            _allies_part_ways("El grupo toma otra puerta. «Desde aquí, cada uno a lo suyo.»")
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
        if alive > 0:
            _escort_blessing(alive == allies.size())


## E / A junto al grupo, al cuenco del Mercader o al borde de su manto.
func _offering_interact() -> bool:
    if _has("guias") and not guiding:
        for ally in allies:
            if player_pos.distance_to(ally["pos"]) < 72.0:
                _ask_guides()
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
    shop_info = false
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -8.0, 0.8)


func _close_shop() -> void:
    game_mode = "play"
    _sfx("interfaz", -12.0, 0.9)


## Precio real: crece con el nivel de lo que mejoras y cambia con tu marca.
func _shop_price(i: int) -> int:
    var key: String = SHOP[i][0]
    var base: float = float(SHOP[i][2])
    match key:
        "brazalete", "amuleto":
            base *= float(_trinket_level(key) + 1) # comprar: 12; mejorar a NV 2: 24; a NV 3: 36...
        "resonancia":
            base = float(RESONANCE_UPGRADE_BASE + RESONANCE_UPGRADE_STEP * ability_level)
        "vigilia":
            return maxi(VIGIL_PRICE, int(roundf(base * _karma_price_factor()))) # nunca por debajo de 500
    return maxi(1, int(roundf(base * _karma_price_factor())))


func _shop_maxed(i: int) -> bool:
    var key: String = SHOP[i][0]
    if key in ["brazalete", "amuleto"]:
        return _trinket_level(key) >= ITEM_LEVEL_MAX
    if key == "resonancia":
        return not has_pulse or ability_level >= ABILITY_LEVEL_MAX
    if key == "vigilia":
        return vigil_unlocked
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
        "vigilia":
            return "ES TUYA" if vigil_unlocked else "CERRADA"
    return ""


## La llave de la Vigilia no se compra a ciegas: antes se explica qué abre.
func _shop_choose(i: int) -> void:
    if str(SHOP[i][0]) == "vigilia" and not _shop_maxed(i):
        shop_info = true
        _sfx("interfaz", -8.0, 0.8)
        return
    _shop_buy(i)


## Se paga primero: las almas van al cuenco y después él entrega.
func _shop_buy(i: int) -> bool:
    var item: Array = SHOP[i]
    var key: String = item[0]
    var price: int = _shop_price(i)
    if _shop_maxed(i):
        _say("Todavía no tienes Resonancia: se consigue en el altar." if key == "resonancia" and not has_pulse else ("La llave ya es tuya." if key == "vigilia" else "Ya está al nivel máximo."), 2.4)
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
        "vigilia":
            vigil_unlocked = true
            got = "la llave de la Vigilia (ya puedes jugarla desde el menú)"
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


const VIGIL_INFO := [
    ["QUÉ ES", "Un modo aparte, fuera del descenso: una celda que defiendes fase tras fase, sin final."],
    ["CÓMO SE JUEGA", "Duermes en el lecho para ganar ecos; con ellos levantas centinelas, campanas y generadores en las losas, y reparas la puerta."],
    ["EL PELIGRO", "Cada fase trae cazadores más duros que golpean la puerta. Si la puerta cae, la vigilia termina."],
    ["LA RECOMPENSA", "Cada fase superada te da un objeto al azar que pasa a tu campaña. Cuanto más aguantas, mejor: de pan y fósforos a viales de sangre, incienso, bolsas de almas, mejoras gratis y reliquias de ecos."],
    ["DÓNDE", "Una vez comprada, entras desde el menú principal, botón VIGILIA. Un tutorial guiado te enseña los primeros pasos."],
]


## Corta un texto en líneas que caben en «width» con la fuente del juego.
func _wrap_lines(msg: String, width: float, size: int) -> PackedStringArray:
    var out := PackedStringArray()
    var line: String = ""
    for word in msg.split(" ", false):
        var test: String = word if line == "" else line + " " + word
        if font.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width and line != "":
            out.append(line)
            line = word
        else:
            line = test
    if line != "":
        out.append(line)
    return out


const VIGIL_ICON := preload("res://assets/visual/iconos/lecho.png")


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


func _xp_needed(level: int) -> int:
    return 30 + 20 * (level - 1)


func _xp_fraction() -> float:
    if player_level >= LEVEL_MAX:
        return 1.0
    return clampf(float(xp) / float(_xp_needed(player_level)), 0.0, 1.0)


func _base_max_hp() -> float:
    return 100.0 + LEVEL_HP * float(player_level - 1) + (PETO_HP if gear.get("peto", "") != "" else 0.0)


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
    avisos.mostrar_nivel(player_level, "+%d VIDA MÁX · +%d %% DAÑO · +%d %% VIGOR" % [int(LEVEL_HP), int(LEVEL_POWER * 100.0), int(LEVEL_VIGOR * 100.0)])
    _save_progress()
    _sfx("sello", -5.0, 1.3)
    _sfx("k_campana", -9.0, 1.4)
    _emit(player_pos + Vector2(0, -24), 40, Color(0.95, 0.8, 0.45), 30.0, 120.0, 1.3, 2.0, -60.0, Vector2.UP, 1.2, true)


func _update_level_fx(dt: float) -> void:
    level_flash = maxf(0.0, level_flash - dt * 1.5)


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
        var d: float = at.distance_to(_tb_pos(id))
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
## Curarse con objetos por encima del máximo deja vida extra, SIN TOPE: cada pan,
## vial o relicario suma entero. La regeneración natural nunca pasa del máximo.
const ITEM_LEVEL_MAX := 5
const ABILITY_LEVEL_MAX := 5
const RESONANCE_UPGRADE_BASE := 10
const RESONANCE_UPGRADE_STEP := 8
const OVERHEAL_MAX := 50.0 # solo para dibujar: con +50 la franja dorada se ve llena
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
var profile_tab: int = 0 # 0 mochila, 1 objetos, 2 equipo
var shop_flash: Dictionary = {}


## Bono que da un accesorio ahora mismo: 0 si te lo has quitado.
func _trinket_bonus(key: String) -> int:
    return 0 if unworn.has(key) else _trinket_level(key)


func _trinket_level(key: String) -> int:
    if not trinkets.has(key):
        return 0
    return clampi(int(trinket_levels.get(key, 1)), 1, ITEM_LEVEL_MAX)


## Cura; con «overflow», lo que sobra del máximo queda como vida extra.
func _heal(amount: float, overflow: bool = true) -> void:
    if not overflow and hp >= max_hp:
        return
    var before: float = hp
    hp = hp + amount if overflow else minf(max_hp, hp + amount)
    hp_prev = hp
    float_fx.append({"pos": player_pos + Vector2(0, -60), "text": "+%d" % int(round(hp - before)), "color": Color("#9fd8b0") if hp <= max_hp else Color("#ffd36b"), "t": 0.0})


func _profile_tab_rect(t: int) -> Rect2:
    return Rect2(372.0 + float(t) * 168.0, 72.0, 160.0, 24.0)


func _profile_switch_tab() -> void:
    profile_tab = (profile_tab + 1) % 3
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
    if profile_tab == 2:
        _equip_tap(inventory_sel)
        return
    if profile_tab != 1:
        return
    var list: Array = _object_slots()
    if inventory_sel < 0 or inventory_sel >= list.size() or not bool(list[inventory_sel][4]):
        return
    _use_bag_item(str(list[inventory_sel][5]))


func _use_bag_item(key: String) -> bool:
    if int(bag.get(key, 0)) <= 0:
        return false
    if not in_tutorial: # en el tutorial se prueba sin gastar
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
            _try_craft() # con madera, los fósforos de la bolsa también hacen la antorcha
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
    for i in range(OBJECT_SLOTS_MAX):
        var box: Rect2 = _object_slot_rect(i)
        var sel: bool = inventory_sel == i
        _panel(box, Color("#222c39") if sel else Color("#141922"), UI_GOLD if sel else UI_EDGE)
        if i >= list.size():
            _text_outline("—", Vector2(box.position.x, box.get_center().y + 6.0), 16, Color("#4a4740"), box.size.x)
            continue
        var o: Array = list[i]
        draw_texture_rect(ICONS[o[0]], Rect2(box.position + Vector2(roundf(box.size.x * 0.5) - 16.0, 4), Vector2(32, 32)), false)
        _text_outline(str(o[2]), Vector2(box.position.x, box.position.y + 50.0), 10, Color("#ffd36b") if bool(o[4]) else SOUL, box.size.x)
        var nsize: int = 10
        while nsize > 8 and font.get_string_size(str(o[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, nsize).x > box.size.x - 8.0:
            nsize -= 1
        _text_outline(str(o[1]), Vector2(box.position.x, box.end.y - 8.0), nsize, CREAM, box.size.x)


func _draw_object_desc() -> void:
    var list: Array = _object_slots()
    if inventory_sel < 0 or inventory_sel >= list.size():
        _text_outline("SIN OBJETOS", Vector2(388, 478), 15, Color("#6d6a60"))
        draw_string(font, Vector2(388, 502), "Cómpralos al Mercader del Piso VI o gánalos en la Vigilia.", HORIZONTAL_ALIGNMENT_LEFT, 470.0, 13, Color("#8a8778"))
        return
    var o: Array = list[inventory_sel]
    _text_outline(str(o[1]), Vector2(388, 476), 15, CREAM)
    var lines: PackedStringArray = _wrap_lines(str(o[3]), 470.0, 12)
    for li in range(mini(2, lines.size())):
        draw_string(font, Vector2(388, 496 + li * 15), lines[li], HORIZONTAL_ALIGNMENT_LEFT, 470.0, 12, SOUL)
    if bool(o[4]):
        draw_string(font, Vector2(388, 526), _hint("ENTER: usar", "Toca otra vez: usar", "A: usar"), HORIZONTAL_ALIGNMENT_RIGHT, 470.0, 11, Color("#ffd36b"))


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
        if to_r.length() > _strike_range() + 12.0 or (to_r.length() > 24.0 and to_r.normalized().dot(strike_dir) < 0.2):
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
    if to_e.length() < _strike_range() + 16.0 and (to_e.length() < 26.0 or to_e.normalized().dot(strike_dir) > 0.2):
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
## Rótulo grande con el objeto que acabas de conseguir ({key, t, info?, header?}).
## Lo dibuja y lo descuenta la capa de avisos.
var loot_banner: Dictionary:
    get:
        return avisos.botin if avisos != null else {}
    set(v):
        if avisos != null:
            avisos.botin = v


## Rótulo grande para lo que te da un PNJ (mismo aspecto que el del cofre).
func _gift_banner(key: String, who: String) -> void:
    var info: Array = Botin.OBJETOS.get(key, [key.to_upper(), "", 2, key])
    loot_banner = {"key": key, "t": 5.0, "info": [str(info[0]), "", int(info[2]), str(info[3])], "header": who}


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
    var info: Array = Botin.OBJETOS.get(key, [item_name, "", 1, "alma"])
    _dialog([["NOTA EN EL COFRE", note], ["OBJETO ENCONTRADO", "%s. %s" % [item_name, str(info[1])]]])
    loot_banner = {"key": key, "t": 5.0}
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


## El descenso: solo se dibujan los pisos a los que has bajado, y uno más
## por descubrir. El pozo crece a medida que avanzas.
# ------------------------------------------------------------ PNJ CON VIDA PROPIA
## Los aliados tienen vida: las trampas y las entidades también les hacen
## daño, y se defienden (empujan a la entidad y aplastan alimañas). Además van
## a lo suyo: recogen almas sueltas, fragmentos y pan, y usan el relicario de
## vida si están heridos. Con la bendición te dan la mitad de lo que cogen.
const ALLY_HP := 60.0
const ALLY_GREED_RANGE := 170.0
const ALLY_ENEMY_DAMAGE := 10.0
const ALLY_DEFEND_CD := 3.0


## Lo más cercano que le interesa y que tiene más a mano que tú (o null).
func _ally_greed_target(ally: Dictionary):
    var pos: Vector2 = ally["pos"]
    var best = null
    var best_d: float = ALLY_GREED_RANGE
    var cands: Array = []
    for d in drops:
        cands.append(Vector2(d["pos"]))
    for i in range(relics.size()):
        if i < collected.size() and not collected[i]:
            cands.append(Vector2(relics[i]))
    for it in room_items:
        if str(it["kind"]) == "pan":
            cands.append(Vector2(it["pos"]))
    if float(ally.get("hp", ALLY_HP)) < ALLY_HP * 0.6 and _fountain_here() and not fountains_used.has(_room_key()):
        cands.append(FOUNTAIN_POS + Vector2(0, 24))
    for c in cands:
        var d: float = pos.distance_to(c)
        if d < best_d and d < player_pos.distance_to(c):
            best_d = d
            best = c
    return best


func _ally_share(ally: Dictionary, amount: int, what: String) -> void:
    var name_a: String = str(ally["name"])
    var kept: int = amount
    if _mark() == "bendicion" and amount > 1:
        var half: int = amount / 2
        kept = amount - half
        souls += half
        souls_flash = 0.6
        float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -70), "text": "%s COMPARTE +%d" % [name_a, half], "color": Color("#7fd6a0"), "t": 0.0})
    else:
        float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -70), "text": "%s SE QUEDA %s" % [name_a, what], "color": Color("#ffb36b"), "t": 0.0})
    # Lo que se guarda lo lleva encima: si muere, lo suelta.
    ally["hoard"] = int(ally.get("hoard", 0)) + kept


func _ally_pickups(ally: Dictionary) -> void:
    var pos: Vector2 = ally["pos"]
    for i in range(drops.size() - 1, -1, -1):
        if pos.distance_to(drops[i]["pos"]) < 24.0:
            var v: int = int(drops[i].get("value", BANISH_SOULS))
            drops.remove_at(i)
            _ally_share(ally, v, "%d ALMAS" % v)
            _sfx("alma", -12.0, 1.2)
    for i in range(relics.size()):
        if i < collected.size() and not collected[i] and pos.distance_to(relics[i]) < 24.0:
            collected[i] = true # el fragmento ya no está, aunque las almas se las lleve él
            _ally_share(ally, 7, "LAS ALMAS")
            _sfx("k_vidrio", -16.0, 1.2)
    for i in range(room_items.size() - 1, -1, -1):
        if str(room_items[i]["kind"]) == "pan" and pos.distance_to(room_items[i]["pos"]) < 24.0:
            items_taken["%s:pan" % _room_key()] = true
            room_items.remove_at(i)
            ally["hp"] = ALLY_HP
            float_fx.append({"pos": pos + Vector2(0, -70), "text": "%s SE COME EL PAN" % ally["name"], "color": Color("#ffb36b"), "t": 0.0})
    if _fountain_here() and not fountains_used.has(_room_key()) and float(ally.get("hp", ALLY_HP)) < ALLY_HP * 0.6 and pos.distance_to(FOUNTAIN_POS) < 40.0:
        fountains_used[_room_key()] = true
        ally["hp"] = ALLY_HP
        float_fx.append({"pos": pos + Vector2(0, -70), "text": "%s VACÍA EL RELICARIO" % ally["name"], "color": Color("#ff8a8a"), "t": 0.0})
        _sfx("k_metal", -10.0, 1.0)


func _hurt_ally(ally: Dictionary, amount: float) -> void:
    if float(ally.get("hurt_cd", 0.0)) > 0.0 or not bool(ally["alive"]):
        return
    ally["hp"] = float(ally.get("hp", ALLY_HP)) - amount
    ally["hurt_cd"] = 0.8
    float_fx.append({"pos": Vector2(ally["pos"]) + Vector2(0, -56), "text": "-%d" % int(amount), "color": RED, "t": 0.0})
    _sfx("k_cuerpo", -12.0, 1.2)
    if float(ally["hp"]) <= 0.0:
        _ally_die(ally)


func _ally_hazards(ally: Dictionary, dt: float) -> void:
    if not bool(ally["alive"]) or bool(ally.get("gone", false)) or bool(ally.get("leaving", false)):
        return
    if not ally.has("hp"):
        ally["hp"] = ALLY_HP
    ally["hurt_cd"] = maxf(0.0, float(ally.get("hurt_cd", 0.0)) - dt)
    ally["defend_cd"] = maxf(0.0, float(ally.get("defend_cd", 0.0)) - dt)
    var pos: Vector2 = ally["pos"]
    # Trampas: los pinchos también les atraviesan.
    for trap in traps:
        if _trap_t(trap) >= TRAP_UP and _trap_rect(trap).has_point(pos):
            _hurt_ally(ally, TRAP_DAMAGE * 0.6)
    match _hazard_hit(pos):
        "llama":
            _hurt_ally(ally, FLAME_DAMAGE * 0.6)
        "pendulo":
            _hurt_ally(ally, PENDULUM_DAMAGE * 0.6)
    # Alimañas: las aplastan antes de que muerdan.
    for cr in critters:
        if bool(cr["alive"]) and pos.distance_to(cr["pos"]) < 26.0:
            cr["alive"] = false
            cr["dead_t"] = 0.0
            _emit(Vector2(cr["pos"]) + Vector2(0, -6), 8, Color(0.55, 0.06, 0.1), 30.0, 100.0, 0.5, 2.0, 260.0, Vector2.UP, 1.4)
    # La entidad de la sala: si los alcanza, les hace daño; si está cerca, se defienden.
    if _enemy_active():
        var d: float = pos.distance_to(enemy_pos)
        if d < 34.0:
            _hurt_ally(ally, ALLY_ENEMY_DAMAGE)
        if d < 80.0 and float(ally["defend_cd"]) <= 0.0 and bool(ally["alive"]):
            ally["defend_cd"] = ALLY_DEFEND_CD
            enemy_stun = maxf(enemy_stun, 0.6)
            float_fx.append({"pos": pos + Vector2(0, -72), "text": "¡ATRÁS!", "color": Color("#9fd8b0"), "t": 0.0})
            _sfx("golpe", -12.0, 1.1)


# ------------------------------------------------------------ ELECCIONES CLARAS
## Ventana con dos opciones grandes (p. ej. guiar o no al grupo del Piso VI).
## Teclas 1/2, ←/→ + Enter, toque o mando (cruceta + A; B cancela).
var choice: Dictionary = {} # {speaker, text, options: [[id, título, detalle]]}
var choice_sel: int = 0
var guides_refused: bool = false


func _open_choice(speaker: String, text: String, options: Array) -> void:
    choice = {"speaker": speaker, "text": text, "options": options}
    choice_sel = 0
    game_mode = "choice"
    mobile_axis = Vector2.ZERO
    mobile_finger = -1
    _sfx("interfaz", -9.0)


func _choice_pick(i: int) -> void:
    var opts: Array = choice.get("options", [])
    if i < 0 or i >= opts.size():
        return
    var id: String = opts[i][0]
    choice = {}
    game_mode = "play"
    match id:
        "guiar":
            _accept_guides()
        "rechazar":
            _refuse_guides()


func _choice_cancel() -> void:
    choice = {}
    game_mode = "play"


func _ask_guides() -> void:
    if _mark() == "maldicion":
        _accept_guides() # con la maldición ni siquiera te lo piden: se niegan
        return
    _open_choice("IRENE, EN NOMBRE DEL GRUPO",
        "«Llevamos días aquí abajo. Tú tienes luz y sabes moverte. ¿Nos guías hasta el siguiente piso?»",
        [["guiar", "AYUDARLOS", "Te seguirán a tu paso. Si sobreviven, te lo agradecerán."],
         ["rechazar", "NEGARSE", "Seguirás solo. Ellos se quedarán aquí."]])


func _refuse_guides() -> void:
    if not guides_refused:
        guides_refused = true
        _karma(-1, "Te negaste a guiar al grupo")
    _dialog([["IRENE", "Entendido. Bajaremos como podamos... si podemos."],
        ["BAS", "Si cambias de idea, seguiremos aquí."]])
    _sfx("toque", -8.0, 0.7)


## Marca clara sobre el grupo mientras espera tu respuesta.
func _draw_guides_request() -> void:
    if not _has("guias") or guiding or allies.is_empty() or game_mode != "play":
        return
    var lead: Vector2 = allies[0]["pos"]
    var bob: float = 3.0 * sin(elapsed * 4.0)
    draw_circle(lead + Vector2(0, -98 + bob), 11.0, Color("#ffd36b"))
    _text_outline("!", Vector2(lead.x - 10.0, lead.y - 91.0 + bob), 16, Color("#1a1420"), 20.0)
    var near: bool = false
    for ally in allies:
        if player_pos.distance_to(ally["pos"]) < 72.0:
            near = true
    _label_center(_prompt("HABLAR: PIDEN AYUDA") if near else "EL GRUPO PIDE AYUDA", lead + Vector2(0, -118), Color("#ffd36b"))


# ------------------------------------------------------------ PANTALLA COMPLETA REAL
## El juego se dibuja en 960x640, pero la ventana usa «expand»: en cualquier
## pantalla (teléfono 20:9, tableta 4:3, portátil 16:9) se llena todo. La
## zona de juego queda centrada (sin deformar el pixel art) y lo que sobra
## no es negro: se rellena con la propia sala, ampliada y en penumbra. Los
## controles táctiles se pegan a los bordes reales de la pantalla.
var screen_pad: Vector2 = Vector2.ZERO # margen a cada lado (en píxeles del juego)
var backdrop_rect: TextureRect


func _setup_fullscreen() -> void:
    var layer := CanvasLayer.new()
    layer.layer = -1 # por debajo de todo
    add_child(layer)
    # Fondo continuo: el mismo azul oscuro que rodea la sala, apagándose hacia
    # los bordes. Sin copias ampliadas de la sala: la sala parece flotar en la
    # oscuridad, de lado a lado, sin «marco» visible.
    var grad := Gradient.new()
    grad.set_color(0, Color8(26, 31, 44))
    grad.set_color(1, Color8(5, 6, 9))
    var tex := GradientTexture2D.new()
    tex.gradient = grad
    tex.fill = GradientTexture2D.FILL_RADIAL
    tex.fill_from = Vector2(0.5, 0.5)
    tex.fill_to = Vector2(1.05, 0.5)
    tex.width = 256
    tex.height = 256
    backdrop_rect = TextureRect.new()
    backdrop_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    backdrop_rect.stretch_mode = TextureRect.STRETCH_SCALE
    backdrop_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    backdrop_rect.texture = tex
    layer.add_child(backdrop_rect)
    get_viewport().size_changed.connect(_fit_screen)
    _fit_screen()


## Márgenes: los muros siguen, pero se apagan hacia el borde de la pantalla.
func _draw_side_fade() -> void:
    if screen_pad == Vector2.ZERO:
        return
    var dark := Color(0.02, 0.022, 0.032)
    var steps: int = 14
    var inner: float = 44.0 # empieza justo en el muro de la sala
    for side in [-1, 1]:
        var width: float = screen_pad.x + inner
        for i in range(steps):
            var t0: float = float(i) / float(steps)
            var a: float = lerpf(0.72, 1.0, t0)
            var seg: float = width / float(steps)
            var x: float = inner - seg * float(i + 1) if side < 0 else W - inner + seg * float(i)
            draw_rect(Rect2(x, -screen_pad.y, seg + 1.0, H + screen_pad.y * 2.0), Color(dark.r, dark.g, dark.b, a))
    if screen_pad.y > 0.0:
        draw_rect(Rect2(-screen_pad.x, H, W + screen_pad.x * 2.0, screen_pad.y), dark)
        draw_rect(Rect2(-screen_pad.x, -screen_pad.y, W + screen_pad.x * 2.0, screen_pad.y), dark)


## Toda la pantalla, en coordenadas del juego (incluye los márgenes).
func _full_rect() -> Rect2:
    return Rect2(-screen_pad, Vector2(W, H) + screen_pad * 2.0)


# ------------------------------------------------------------ CÁMARA (PANTALLA ANCHA)
## En pantallas más anchas que la sala (móviles 20:9, portátiles 16:9) el
## mundo se acerca hasta un 30 % para llenar todo el ancho, y una cámara suave
## sigue al jugador en vertical. El marcador queda fijo en los bordes. En 3:2
## (y en las pruebas sin pantalla) no cambia nada: zoom 1, sin cámara.
const CAM_MAX_ZOOM := 1.3
const CAM_WINDOW_TOP := 112.0 # entre la barra superior…
const CAM_WINDOW_BOTTOM := 578.0 # …y la inferior
var cam_zoom: float = 1.0
var cam_center: Vector2 = Vector2(480, 351)
var world_xf: Transform2D = Transform2D.IDENTITY
var draw_base_xf: Transform2D = Transform2D.IDENTITY


## draw_set_transform que respeta la cámara cuando se dibuja el mundo.
func _xf(pos: Vector2, rot: float, scl: Vector2) -> void:
    draw_set_transform_matrix(draw_base_xf * Transform2D(rot, scl, 0.0, pos))


func _begin_world() -> void:
    draw_base_xf = world_xf
    draw_set_transform_matrix(world_xf)


func _end_world() -> void:
    draw_base_xf = Transform2D.IDENTITY
    draw_set_transform_matrix(Transform2D.IDENTITY)


func _cam_target() -> Vector2:
    var want: Vector2 = player_pos if game_mode in ["play", "dialog", "dead", "choice", "shop", "altar", "inventory", "abilities", "map", "pause", "floor_summary", "victory"] else Vector2(480, 351)
    var vis := Vector2(W + screen_pad.x * 2.0, CAM_WINDOW_BOTTOM - CAM_WINDOW_TOP) / cam_zoom
    var lo := Vector2(30.0 + vis.x * 0.5, 112.0 + vis.y * 0.5)
    var hi := Vector2(930.0 - vis.x * 0.5, 592.0 - vis.y * 0.5)
    return Vector2(480.0 if lo.x >= hi.x else clampf(want.x, lo.x, hi.x), 351.0 if lo.y >= hi.y else clampf(want.y, lo.y, hi.y))


func _update_camera(dt: float, snap: bool = false) -> void:
    if cam_zoom <= 1.001:
        world_xf = Transform2D.IDENTITY
    else:
        var target: Vector2 = _cam_target()
        cam_center = target if snap else cam_center.lerp(target, 1.0 - exp(-7.0 * dt))
        var win_center := Vector2(480.0, (CAM_WINDOW_TOP + CAM_WINDOW_BOTTOM) * 0.5)
        world_xf = Transform2D(0.0, Vector2(cam_zoom, cam_zoom), 0.0, (win_center - cam_center * cam_zoom).round())
    if room_node != null:
        room_node.transform = world_xf
    if glow_node != null:
        var clip := glow_node.get_parent() as Control
        if cam_zoom > 1.001:
            clip.position = Vector2(-screen_pad.x, CAM_WINDOW_TOP)
            clip.size = Vector2(W + screen_pad.x * 2.0, CAM_WINDOW_BOTTOM - CAM_WINDOW_TOP)
        else:
            clip.position = ARENA.position
            clip.size = ARENA.size
        glow_node.transform = Transform2D(0.0, -clip.position) * world_xf
    if post_rect != null and post_rect.material is ShaderMaterial:
        var a: Vector2 = world_xf * Vector2(40.0, 122.0) + screen_pad
        var b: Vector2 = world_xf * Vector2(920.0, 580.0) + screen_pad
        (post_rect.material as ShaderMaterial).set_shader_parameter("arena", Vector4(a.x, a.y, b.x, b.y))


func _fit_screen() -> void:
    var view: Vector2 = get_viewport_rect().size
    screen_pad = ((view - Vector2(W, H)) * 0.5).floor().max(Vector2.ZERO)
    if DisplayServer.get_name() == "headless":
        screen_pad = Vector2.ZERO # sin pantalla (pruebas automáticas): disposición base
    position = screen_pad
    pantallas.ajustar_margen(screen_pad)
    ($CapaAvisos as CanvasLayer).offset = screen_pad
    avisos.margen = screen_pad
    if name_edit != null:
        name_edit.position = NAME_BOX.position + screen_pad
    if mobile_finger < 0:
        joy_center = _joy_home()
    cam_zoom = clampf((W + screen_pad.x * 2.0) / float(W), 1.0, CAM_MAX_ZOOM)
    if post_rect != null and post_rect.material is ShaderMaterial:
        var pm := post_rect.material as ShaderMaterial
        pm.set_shader_parameter("canvas_size", view)
    _update_camera(0.0, true)
    for r in [backdrop_rect, post_rect, trans_rect]:
        if r != null:
            (r as Control).position = Vector2.ZERO
            (r as Control).size = view
    _update_backdrop()
    _sync_screens()
    queue_redraw()


func _update_backdrop() -> void:
    _extend_room_tiles()


## Alarga los muros exteriores de la sala (sus tiles de borde) hasta cubrir los
## márgenes de la pantalla: la sala continúa de lado a lado, sin recuadro.
func _extend_room_tiles() -> void:
    if room_node == null or screen_pad == Vector2.ZERO:
        return
    var tm := room_node.get_node_or_null("Arquitectura") as TileMapLayer
    if tm == null:
        return
    var used: Rect2i = tm.get_used_rect()
    if used.size.x <= 0:
        return
    var tile: float = 32.0
    var extra_x: int = int(ceil(screen_pad.x / tile)) + 2
    var extra_y: int = int(ceil(screen_pad.y / tile)) + 2
    # Ya alargada lo suficiente (al cambiar el tamaño de la ventana solo se
    # añade lo que falta).
    var done: Vector2i = tm.get_meta("extendida", Vector2i(-1, -1))
    if done.x >= extra_x and done.y >= extra_y:
        return
    tm.set_meta("extendida", Vector2i(extra_x, extra_y))
    var x0: int = used.position.x
    var x1: int = used.end.x - 1
    var y0: int = used.position.y
    var y1: int = used.end.y - 1
    for y in range(y0, y1 + 1):
        var left := Vector2i(x0, y)
        var right := Vector2i(x1, y)
        for k in range(1, extra_x + 1):
            tm.set_cell(Vector2i(x0 - k, y), tm.get_cell_source_id(left), tm.get_cell_atlas_coords(left), tm.get_cell_alternative_tile(left))
            tm.set_cell(Vector2i(x1 + k, y), tm.get_cell_source_id(right), tm.get_cell_atlas_coords(right), tm.get_cell_alternative_tile(right))
    for x in range(x0 - extra_x, x1 + extra_x + 1):
        var top := Vector2i(clampi(x, x0, x1), y0)
        var bottom := Vector2i(clampi(x, x0, x1), y1)
        for k in range(0, extra_y + 1):
            tm.set_cell(Vector2i(x, y0 - k), tm.get_cell_source_id(top), tm.get_cell_atlas_coords(top), tm.get_cell_alternative_tile(top))
            tm.set_cell(Vector2i(x, y1 + k), tm.get_cell_source_id(bottom), tm.get_cell_atlas_coords(bottom), tm.get_cell_alternative_tile(bottom))


## Botones táctiles: anclados a la esquina inferior derecha real de la pantalla.
func _tb_pos(id: String) -> Vector2:
    return Vector2(TOUCH_BUTTONS[id][0]) + screen_pad


## Joystick: anclado a la esquina inferior izquierda real de la pantalla.
func _joy_home() -> Vector2:
    return JOY_HOME + Vector2(-screen_pad.x, screen_pad.y)


# ------------------------------------------------------------ TECLADO DEL MÓVIL
## En pantallas táctiles, un campo de texto nativo (invisible) va encima del
## recuadro del nombre: al tocarlo se abre el teclado del teléfono. Lo que se
## escribe pasa por el mismo filtro que el teclado del juego (mayúsculas,
## letras y como mucho NAME_MAX). El teclado en pantalla sigue funcionando.
const NAME_BOX := Rect2(300, 182, 360, 54)
var name_edit: LineEdit
var name_edit_layer: CanvasLayer


func _name_edit_open() -> void:
    if not touch_enabled or create_step != 0:
        return
    if name_edit == null:
        name_edit_layer = CanvasLayer.new()
        name_edit_layer.layer = 3
        add_child(name_edit_layer)
        name_edit = LineEdit.new()
        name_edit.modulate = Color(1, 1, 1, 0.0) # se ve el recuadro del juego, no el campo
        name_edit.max_length = NAME_MAX
        name_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
        name_edit.context_menu_enabled = false
        name_edit.text_changed.connect(_on_name_edit_changed)
        name_edit.text_submitted.connect(func(_t): _create_next())
        name_edit_layer.add_child(name_edit)
    name_edit.position = NAME_BOX.position + screen_pad
    name_edit.size = NAME_BOX.size
    name_edit.visible = true
    _name_edit_sync()
    _name_edit_focus()


func _name_edit_focus() -> void:
    if name_edit == null or not name_edit.visible:
        return
    name_edit.grab_focus()
    name_edit.caret_column = name_edit.text.length()
    if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
        DisplayServer.virtual_keyboard_show(name_edit.text, Rect2(NAME_BOX.position + screen_pad, NAME_BOX.size), DisplayServer.KEYBOARD_TYPE_DEFAULT, NAME_MAX)


func _name_edit_close() -> void:
    if name_edit == null:
        return
    name_edit.release_focus()
    name_edit.visible = false
    if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
        DisplayServer.virtual_keyboard_hide()


func _name_edit_sync() -> void:
    if name_edit != null and name_edit.text != create_buf:
        name_edit.text = create_buf
        name_edit.caret_column = create_buf.length()


func _on_name_edit_changed(new_text: String) -> void:
    var before: String = create_buf
    create_buf = ""
    for ch in new_text:
        if create_buf.length() >= NAME_MAX:
            break
        var up: String = ch.to_upper()
        var code: int = up.unicode_at(0)
        if not ((code >= 65 and code <= 90) or up in "ÁÉÍÓÚÜÑ -'"):
            continue
        if up == " " and (create_buf == "" or create_buf.ends_with(" ")):
            continue
        create_buf += up
    if create_buf != before:
        _sfx("toque", -14.0, 1.1)
    _name_edit_sync()
    queue_redraw()


## La tipografía sin suavizado, como el pixel art.
static func _pixel_font_setup(f: Font) -> void:
    if f is FontFile:
        (f as FontFile).antialiasing = TextServer.FONT_ANTIALIASING_NONE
        (f as FontFile).hinting = TextServer.HINTING_NONE
        (f as FontFile).subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
