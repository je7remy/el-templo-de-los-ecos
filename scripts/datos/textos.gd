extends RefCounted
## Textos de la interfaz en español e inglés ([es, en]) y los textos legales.
## Los usan la campaña (main.gd) y las escenas de pantalla.
## El resto de los textos del juego se traduce al dibujarlos con las tablas de
## scripts/datos/en/ (ver scripts/comun/idioma.gd).
##
## Uso:  const Textos := preload("res://scripts/datos/textos.gd")
##       Textos.t("volver")        # según el idioma de Configuración

const Ajustes := preload("res://scripts/ajustes.gd")

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
    "zoom_movil": ["Cámara en el móvil", "Camera on mobile"],
    "cerca": ["CERCA", "CLOSE"],
    "medio": ["MEDIA", "MEDIUM"],
    "lejos": ["SALA", "ROOM"],
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
    "buscar_actualizaciones": ["Buscar actualizaciones al abrir", "Check for updates on launch"],
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
        ["Escenario: Knowledge Temple, por pingupollas (pingupollas.itch.io/knowledge-temple). Proyectiles de fuego: GothicVania Church Pack, por Luis Zuno (Ansimuz).", "Environment: Knowledge Temple by pingupollas (pingupollas.itch.io/knowledge-temple). Fire projectiles: GothicVania Church Pack by Luis Zuno (Ansimuz)."],
        ["Protagonistas, entidades, iconos, efectos, música y la mayoría de sonidos: originales del proyecto. Sonidos de impacto y pasos, y controles táctiles: Kenney (kenney.nl), CC0.", "Protagonists, entities, icons, effects, music and most sounds: original to the project. Impact and footstep sounds and touch controls: Kenney (kenney.nl), CC0."],
        ["Tipografías: Jersey 15 y Jacquard 24 (SIL Open Font License 1.1).", "Fonts: Jersey 15 and Jacquard 24 (SIL Open Font License 1.1)."],
        ["Nacido de un primer juego: Craving Candy. En memoria de Leudy Antonio Mendez.", "Born from a first game: Craving Candy. In memory of Leudy Antonio Mendez."],
    ],
    "acuerdo": [
        ["1. Licencia. Puedes jugar esta copia para uso personal. No puedes revender, redistribuir ni descompilar el juego salvo lo que permita la ley.", "1. License. You may play this copy for personal use. You may not resell, redistribute or decompile the game except as the law allows."],
        ["2. Contenido. Incluye terror, sangre, violencia y temas perturbadores. No recomendado para menores.", "2. Content. It includes horror, blood, violence and disturbing themes. Not recommended for minors."],
        ["3. Demo en desarrollo. Puede contener errores; el progreso puede perderse entre versiones.", "3. Demo in development. It may contain bugs; progress may be lost between versions."],
        ["4. Sin garantía. Se ofrece «tal cual», sin garantías, en la medida que permita la ley.", "4. No warranty. It is provided \"as is\", without warranties, to the extent the law allows."],
        ["5. Terceros. Las tipografías Jersey 15 y Jacquard 24 se usan bajo la licencia SIL OFL 1.1.", "5. Third parties. The Jersey 15 and Jacquard 24 fonts are used under the SIL OFL 1.1 license."],
    ],
    "politica": [
        ["Qué guarda: tu progreso (almas, identidad, habilidades, Ecos) y tus ajustes (volumen, teclas, idioma, si aceptaste este acuerdo).", "What is stored: your progress (souls, identity, abilities, Echoes) and your settings (volume, keys, language, whether you accepted this agreement)."],
        ["Dónde: solo en este equipo, en la carpeta de datos del juego. Tus datos no se envían por internet.", "Where: only on this device, in the game's data folder. Your data is not sent over the internet."],
        ["Actualizaciones: al abrir, el juego pregunta a GitHub si hay versión nueva; GitHub ve tu IP y la versión del juego. Se apaga en Configuración > Sonido.", "Updates: on launch, the game asks GitHub whether there is a new version; GitHub sees your IP and the game version. Turn it off in Settings > Sound."],
        ["Qué no hace: no hay cuentas, ni publicidad, ni estadísticas, ni seguimiento.", "What it does not do: no accounts, no ads, no analytics, no tracking."],
        ["Tus derechos: puedes borrar todos tus datos desde Configuración > Privacidad > Borrar mis datos.", "Your rights: you can delete all your data from Settings > Privacy > Delete my data."],
    ],
}


static func en_ingles() -> bool:
    return Ajustes.obtener("idioma") == "en"


static func t(clave: String) -> String:
    var par: Array = T.get(clave, [clave, clave])
    return par[1] if en_ingles() else par[0]


## Elige la mitad de un par [es, en].
static func elegir(par: Array) -> String:
    return par[1] if en_ingles() else par[0]
