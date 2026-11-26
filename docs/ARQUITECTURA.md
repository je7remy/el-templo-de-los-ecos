# Arquitectura y plan de reestructuración

El juego nació como un único script (`scripts/main.gd`) que lo dibujaba todo con `_draw()`. Funciona y va fluido, pero es difícil de mantener: cualquier cambio toca el mismo archivo y nada se puede editar en el editor de Godot. Este documento explica cómo se está separando en escenas y qué reglas sigue el código nuevo.

## Cómo está organizado hoy (v0.5.36)

```text
Autoloads (project.godot → Globales)
├── Eventos           scripts/autoload/eventos.gd     bus de señales global
├── Progreso          scripts/autoload/progreso.gd    único que lee/escribe la partida
├── Escenas           scenes/autoload/escenas.tscn    cambio de escena con pantalla de carga real
└── ConfirmarSalida   scenes/confirmar_salida.tscn    «¿Salir del juego?»

scenes/main.tscn  (TemploDeLosEcos · main.gd: campaña y mundo)
├── Jugador      scenes/entidades/jugador.tscn     posición, movimiento, vida, vigor y miedo
│   ├── Maquina  Quieto, Camina, Esquiva           (scripts/entidades/jugador/)
│   └── Salud    Vivo, Herido, Muerto              señales herido y muerto
├── Entidad      scenes/entidades/entidad.tscn     la entidad de la sala: posición, vida, alerta
│   ├── Ghoul      Reposo, Caza, Aturdida          (scripts/entidades/entidad/)
│   ├── Testigo    Vigila, Caza, Aturdida          señales herida, desterrada, conjuro, regla,
│   ├── Hechicero  Reposo, Conjura, Aturdida       hilos_tensos, hilos_disparados, hilos_cortados,
│   ├── Segador    Acecho, Tensa, Engancha         zarpa_alzada y zarpazo
│   └── Tejedora   Anda, Alza, Zarpa
├── Criaturas    scenes/entidades/criaturas.tscn   manadas: una máquina compartida por tipo
│   ├── Alimanas   Patrulla, Persigue, Muerta      (scripts/entidades/manadas/)
│   ├── Mastines   Vaga, Ronda, Carga, Huye        cada criatura guarda su estado en sus datos
│   └── Arietes    Quieto, Apunta, Embiste, Aturdido
├── Jefes        scenes/entidades/jefes.tscn       (scripts/entidades/jefes/)
│   ├── Coloso       Camina, Alza, Pisa, Aturdido
│   ├── HermanoMayor Habla, Camina, Zarpazo, ApuntaHilos, Hilos, Ruge, Cansado, Mira
│   └── Vigia        Mira, Aviso, Golpe, Caza, Vencida
├── Peregrino    scenes/entidades/peregrino.tscn   Ausente, Espera, Sigue, Desenvaina, Hostil, Amigo, Muerto
├── Objetos      scripts/mundo/objetos.gd          columnas, braseros, cofre, fuente, altar, carta, muros, almas, sello
├── Personajes   scripts/mundo/personajes.gd       aliados, traidores, rescate, Mercader, muñeco
├── Decorado     scripts/mundo/decorado.gd         muros, desgaste, restos, puertas, placa, cadáveres, penumbra, rayos y niebla
├── Peligros     scripts/mundo/peligros.gd         pinchos, rejillas de fuego, péndulos, enredaderas, llamas y canales
├── Hud          scenes/ui/hud.tscn                CanvasLayer 1 · piezas en scripts/ui/hud/
│   └── Piezas   FranjaSuperior, PanelJugador, CartelPiso, Minimapa, FranjaInferior, Mision,
│                PanelArma, AvisoMision, ContadorAlmas, Fundido, Tutorial, ControlesTactiles
├── Pantallas    scenes/pantallas/pantallas.tscn   CanvasLayer 2 · gestor de pantallas
│   └── Maquina  scripts/comun/maquina_estados.gd  una pantalla activa a la vez
│       ├── Splash   scenes/pantallas/splash.tscn
│       ├── Titulo   scenes/pantallas/titulo.tscn  (incluye ui/aviso_actualizacion.tscn)
│       ├── Pausa    scenes/pantallas/pausa.tscn
│       ├── Acuerdo  scenes/pantallas/acuerdo.tscn
│       ├── Pisos    scenes/pantallas/pisos.tscn   (tarjetas: scripts/ui/tarjeta_piso.gd)
│       ├── Ajustes  scenes/pantallas/ajustes.tscn (pestañas y páginas legales)
│       ├── Dialogo, Eleccion, EntradaPiso, ResumenPiso, Final (muerte y victoria)
│       ├── Altar, Tienda                             (pantallas de la partida)
│       ├── Intro, Creacion, Habilidades, Mapa
│       └── Perfil   scenes/pantallas/perfil.tscn  (mochila, objetos, equipo y Ecos)
└── CapaAvisos   scenes/ui/avisos.tscn             CanvasLayer 3 · mensajes y rótulos de nivel/botín

scenes/defense.tscn  (Vigilia del Claustro · defense.gd: reglas y dibujo de la celda)
├── Fases        Portada, Partida, FaseSuperada, Derrota   (scripts/vigilia/fases/)
├── HudVigilia   scenes/vigilia/hud.tscn        CanvasLayer 1 · barras, aviso, tutorial, menú de baldosa
└── PantallasVigilia scenes/vigilia/pantallas.tscn  CanvasLayer 2 · portada, fase superada, derrota, pausa
rooms/sala_N.tscn    salas editables (TileMapLayer, objetos, marcadores, colisiones)
```

Piezas de interfaz reutilizables (`scenes/ui/` y `scripts/ui/`):

| Pieza | Para qué |
| --- | --- |
| `estilo.gd` | Colores, tipografías y el dibujo común (panel, texto con borde, rótulo gótico, botones). `main.gd` y las escenas dibujan con lo mismo, así todo se ve igual. |
| `boton_templo.tscn` | Botón de verdad (`TextureButton` sin texturas): ratón, toque, foco de teclado y mando, señal `pressed`. Variantes `menu`, `grande`, `chico` e `icono`. |
| `texto_templo.gd`, `parrafo_templo.gd`, `panel_templo.gd`, `adorno_templo.gd` | Texto pixel o gótico, párrafo con saltos de línea, panel ornamentado y filete dorado como nodos colocables en el editor. |
| `scripts/datos/textos.gd` | Textos de los menús en español e inglés y los textos legales. Las escenas los piden con `Textos.t("clave")`. |
| `scripts/comun/idioma.gd` + `scripts/datos/en/*.gd` | Inglés del resto del juego. El juego se escribe en español; las piezas de dibujo (`estilo.gd`, `estilo_vigilia.gd`, los rótulos de `main.gd`) pasan cada texto por `Idioma.t()` al pintarlo. Las tablas van de «español» a «inglés», admiten plantillas con `%d`, `%s` y `%.1f`, `{yo}` para el nombre del personaje y traducen por partes los rótulos con « · ». Para un texto nuevo: escribirlo en español y añadir su línea en la tabla de su parte. |
| `equipo_retrato.gd` | Casco, peto, amuleto y máscara dibujados sobre el retrato; lo comparten el panel del jugador y el perfil. |
| `hud.tscn` | HUD de la partida: cada pieza (`scripts/ui/hud/`) es un nodo que se dibuja solo con sus datos. La campaña le pasa `{pieza: datos}` cada cuadro; sin datos, la pieza no se ve. Los toques sobre el HUD los sigue atendiendo `main.gd`. |
| `avisos.tscn` | Mensaje breve, «Nivel N» y objeto conseguido, siempre por encima de cualquier pantalla. |
| `pantalla_carga.gd` | Barra con el progreso real de `ResourceLoader.load_threaded_request`. |

### Cómo hablan las piezas

- **La campaña no dibuja las pantallas migradas.** Cuando cambia `game_mode`, su *setter* llama a `_sync_screens()`, que pide al gestor la pantalla que toca y le pasa los datos (`_screen_data()`): nombre, textos traducidos, si se juega con mando…
- **Las pantallas no conocen a la campaña.** Lo que elige el jugador sale por la señal `accion(nombre)`; el gestor la reenvía y `main.gd` decide (`_on_screen_action()`).
- **La entrada va por la interfaz de Godot.** En las pantallas migradas, `main.gd` solo atiende lo global (F11). Botones, foco, teclado y mando los resuelve Godot. Si una tecla de la campaña abre una pantalla (ESC → pausa), se marca como atendida para que no la cierre en el mismo instante.
- **El progreso pasa siempre por `Progreso`.** Antes la campaña y el botín de la Vigilia escribían el mismo archivo cada uno por su lado.
- **Cambiar de escena pasa por `Escenas.ir_a(ruta)`**: fundido, carga en segundo plano con barra y fundido de vuelta.
- **Pantallas que cambian mientras se ven** (el diálogo que se escribe, la cuenta atrás de la muerte, las almas en la tienda y el altar) reciben datos nuevos cada cuadro con `pantallas.refrescar(modo, datos)`, y también justo antes de cada tecla o clic. La lógica (comprar, avanzar el diálogo, si ya se puede cerrar la muerte) sigue en la campaña: la escena muestra y avisa de lo que se pulsa.
- **Mensajes y sonidos desde cualquier sitio:** `Eventos.aviso_pedido.emit(texto, segundos)` y `Eventos.sonido_pedido.emit(nombre, db, tono)` (la campaña tiene el banco de efectos).
- **La configuración edita los ajustes directamente** (`scripts/ajustes.gd`); a la campaña solo le avisa de lo que la afecta (pantalla completa, controles táctiles, buscar actualizaciones, repetir el tutorial, borrar los datos).

## Reglas para el código nuevo

Son las buenas prácticas de la documentación oficial de Godot y de los temas que trata el canal de Leedeo (autoloads y señales, máquinas de estados, pantallas de carga). Ver «Fuentes».

1. **Una escena por cosa.** Si algo tiene aspecto, entrada o estado propio (una pantalla, un enemigo, un objeto), es una escena `.tscn` con su script. Se instancia; no se dibuja a mano dentro de otro script.
2. **Escenas sin dependencias.** Una escena debe funcionar sola: recibe datos (`entrar(datos)`, propiedades `@export`) y avisa con señales. Nunca busca a su padre ni a sus hermanos por ruta.
3. **«Las señales suben, las llamadas bajan».** El padre llama a métodos de sus hijos; los hijos emiten señales. Para hablar entre escenas lejanas, `Eventos`.
4. **Autoloads solo para lo global**: el bus de eventos, el guardado, el cambio de escena y los ajustes. La lógica de un piso o de un enemigo no va en un autoload.
5. **Máquinas de estados en vez de `if modo == …` encadenados.** `maquina_estados.gd` sirve para las pantallas y servirá para el jugador y las entidades: cada estado es un nodo con `entrar`, `salir` y `actualizar`.
6. **Datos fuera del código.** Pisos, precios y botín en `Resource` (`.tres`) editables en el inspector (armas, equipo, tienda, bolsa, botín y pisos ya en `datos/`).
7. **Interfaz con nodos de interfaz** (`Control`, `Container`, botones): ganan foco de teclado y mando, escalado y accesibilidad sin código propio. El aspecto se mantiene con `estilo.gd`.
8. **Pantallas de carga reales** con `ResourceLoader.load_threaded_request` en vez de cambiar de escena en seco.
9. **Cada paso se entrega con las pruebas en verde.** Las pruebas tocan los botones de verdad (`root.push_input`), no funciones internas.

Y lo que se mantiene de antes: no borrar ni alterar texturas o enemigos existentes, y el arte nuevo en scripts generadores aparte.

## Plan por fases

| Fase | Qué | Estado |
| --- | --- | --- |
| 1 | Autoloads `Eventos`, `Progreso` y `Escenas` (pantalla de carga), máquina de estados, piezas de interfaz, capa de avisos. Inicio, menú principal y pausa como escenas. | **Hecha (v0.5.10)** |
| 2a | Configuración (con las páginas legales), acuerdo y menú de pisos como escenas. Textos en `scripts/datos/textos.gd`. | **Hecha (v0.5.11)** |
| 2b | Pantallas de la partida: diálogos, elección, entrada y resumen del piso, muerte y victoria, altar y tienda (con la ficha de la Vigilia). | **Hecha (v0.5.12)** |
| 2c | Intro, creación del personaje, habilidades y mapa. | **Hecha (v0.5.13)** |
| 2d | Perfil: mochila, objetos, equipo y Ecos. El equipo sobre el retrato pasa a `scripts/ui/equipo_retrato.gd`. | **Hecha (v0.5.14)** |
| 2e | El HUD como escena de piezas (`scenes/ui/hud.tscn`): barras, minimapa, misión, arma, rótulos y controles táctiles. | **Hecha (v0.5.15)** |
| 3a | Jugador como escena (`scenes/entidades/jugador.tscn`) con su máquina de estados Quieto, Camina y Esquiva: posición, dirección, inercia, esquive, colisiones con la sala y señales `paso` y `choque`. `main.gd` le pasa los controles y escucha las señales. | **Hecha (v0.5.16)** |
| 3b | Vida, vigor, miedo y daño del jugador en su escena: segunda máquina «Salud» (Vivo, Herido, Muerto), `herir()` para todos los golpes y señales `herido` y `muerto`. La regeneración, los Ecos y el equipo, que dependen de la partida, siguen en `main.gd`. | **Hecha (v0.5.17)** |
| 3c | La entidad de la sala como escena (`scenes/entidades/entidad.tscn`) con una máquina de estados por tipo: Ghoul (Reposo, Caza, Aturdida), Testigo (Vigila, Caza, Aturdida) y Hechicero (Reposo, Conjura, Aturdida). Señales `herida`, `desterrada`, `conjuro` y `regla`. Las bolas de fuego, los golpes al jugador y el destierro los decide la campaña. | **Hecha (v0.5.18)** |
| 3c-2 | Segador (Acecho, Tensa, Engancha) y Tejedora (Anda, Alza, Zarpa) con su máquina en la misma escena. Los aliados que mueren en la línea, el fuego de las enredaderas y las quemaduras de la Tejedora siguen en la campaña. | **Hecha (v0.5.19)** |
| 3c-3 | Alimañas, mastines y arietes como **manadas** (`scenes/entidades/criaturas.tscn`): una máquina de estados compartida por tipo; cada criatura es un diccionario de datos que guarda su estado, y los estados son nodos. Señales `mordisco`, `aplastada`, `grunido`, `apunta`, `embiste`, `choca` y `alcanza`. | **Hecha (v0.5.20)** |
| 3c-4 | Jefes en `scenes/entidades/jefes.tscn`: Coloso (Camina, Alza, Pisa, Aturdido) y Hermano Mayor (Habla, Camina, Zarpazo, ApuntaHilos, Hilos, Ruge, Cansado, Mira). Señales `hiere`, `alza`, `pisoton`, `regla`, `hilos_activos` y `rugido`. Las columnas, los aliados, las piedras de los traidores y las derrotas siguen en la campaña. | **Hecha (v0.5.21)** |
| 3c-5 | La Vigía (Mira, Aviso, Golpe, Caza, Vencida) en `jefes.tscn` y el Peregrino (Ausente, Espera, Sigue, Desenvaina, Hostil, Amigo, Muerto) en `peregrino.tscn`. Señales `provocada`, `amago`, `ruido_hecho`, `mirando`, `ataca`, `alcanza`, `presa_alcanzada`, `toma_alma`, `prepara_tajo` y `tajo`. El pánico de los aliados, la traición, lo que dice el Peregrino y su muerte siguen en la campaña. Con esto, **todas las entidades tienen su máquina de estados**. | **Hecha (v0.5.22)** |
| 3d-1 | Cada entidad dibuja su parte con `dibujar(lienzo, …)` en su script (entidad de la sala, alimañas, mastines, arietes, Coloso, Hermano Mayor, Vigía y Peregrino), con ayudas comunes en `scripts/comun/lienzo.gd` (sombra, elipse, contorno). `main.gd` solo decide el orden por profundidad y les pide que se dibujen sobre el lienzo del mundo en su turno; así se tapan igual que antes. | **Hecha (v0.5.23)** |
| 3d-2 | El jugador dibuja su parte en `scripts/entidades/jugador.gd`: cuerpo en cuatro direcciones, siluetas del esquive, equipo puesto, arma con su tajo, antorcha, polvo del choque y aros de protección y daño. La campaña le pasa su apariencia (`_player_look()`: hoja, arma, antorcha, equipo puesto…). | **Hecha (v0.5.24)** |
| 3d-3 | Objetos de la sala que van en el orden por profundidad (columnas, braseros, cofre, fuente, altar, carta y muros del laberinto) se dibujan desde `scripts/mundo/objetos.gd` (nodo «Objetos»). | **Hecha (v0.5.25)** |
| 3d-4 | Personajes secundarios (aliados, traidores, rescate, Mercader y muñeco) en `scripts/mundo/personajes.gd`; almas y sello en `objetos.gd`. **Con esto, todo lo que se mueve, pelea o se recoge se dibuja desde su propio script.** | **Hecha (v0.5.26)** |
| 3d-5 | Decorado a ras de suelo en `scripts/mundo/decorado.gd` (nodo «Decorado»: relieve de los muros, desgaste, restos, sombras de los objetos, motas, puertas, placa de la inscripción, cadáveres, tu cuerpo y las marcas de muerte, penumbra con sus luces, rayos y niebla) y trampas en `scripts/mundo/peligros.gd` (nodo «Peligros»: pinchos, rejillas de fuego, péndulos, enredaderas, llamas y canales). `main.gd` decide qué hay, cuándo hiere y el orden; los rótulos («SALIDA», «AQUÍ MORISTE») siguen en él. | **Hecha (v0.5.36)** |
| 4a | Armas (y el golpe base de la antorcha) y piezas de equipo en `datos/armas/*.tres` y `datos/equipo/*.tres`, con sus scripts de recurso (`scripts/datos/arma.gd`, `pieza_equipo.gd`) y el catálogo que los lista en orden (`scripts/datos/catalogo.gd`). Se editan desde el inspector de Godot. | **Hecha (v0.5.28)** |
| 4b | Puesto del Mercader (`datos/tienda`), consumibles de la bolsa (`datos/bolsa`) y botín de la Vigilia (`datos/botin`) en `.tres`, con sus scripts de recurso en `scripts/datos/`. | **Hecha (v0.5.29)** |
| 4c-1 | Datos generales de cada piso (número, título, estado, desgaste, Eco, combustible de la antorcha, seguidores, espejo, regla invertida, final y la verdad que revela) en `datos/pisos/piso_NN.tres`, con su script de recurso `scripts/datos/piso.gd`. | **Hecha (v0.5.30)** |
| 4c-2 | Las 41 salas en `datos/pisos/piso_NN/sala_N.tres` (`scripts/datos/sala.gd`): escena, nombre, entidad, rasgos, susurro, objetos, misión y los elementos opcionales (cofre, trampas, muros, mastines, péndulos…) en «extras», con la misma clave que lee la campaña. Cada piso lista sus salas en orden. En `scripts/datos/pisos.gd` quedan solo las conversaciones. **Con esto, la campaña entera es de datos editables.** | **Hecha (v0.5.31)** |
| 5a | Pantallas de la Vigilia como escenas: portada, fase superada, puerta cedida y pausa (`scenes/vigilia/pantallas.tscn`, `scripts/vigilia/pantallas/*.gd`), con su máquina de estados. Piezas de interfaz de la Vigilia (caja, modal, ficha, botón redondo, pastilla, textos) en `scripts/ui/estilo_vigilia.gd`, sobre las tipografías y colores de `estilo.gd`. `defense.gd` decide cuál se ve (`_sync_pantallas`); los toques y teclas los sigue leyendo él. | **Hecha (v0.5.32)** |
| 5b | HUD de la Vigilia como escena (`scenes/vigilia/hud.tscn`, `scripts/vigilia/hud/*.gd`): barras de arriba y de abajo, aviso, tutorial (recuadro, flecha y tarjeta) y menú de la baldosa. Sus medidas (botones, tarjeta, menú) viven en cada pieza y `defense.gd` las usa para los toques; `_datos_hud()` les pasa los datos en cada cuadro. Las fuentes salen de `estilo.gd`. En `defense.gd` queda el dibujo de la celda (suelo, lecho, puerta, estructuras, entidades y disparos). | **Hecha (v0.5.33)** |
| 5c | La partida de la Vigilia es una máquina de estados («Fases» en `scenes/defense.tscn`, `scripts/vigilia/fases/*.gd`): Portada, Partida, FaseSuperada y Derrota. Cada estado decide qué hacen sus teclas, botones del mando y toques, qué pantalla se ve y (en Partida) cuándo avanza la fase. `defense.gd` recibe la entrada y se la pasa al estado; lo común (ESC, salir, el cursor) y las reglas siguen en él. `phase` es un acceso a la máquina con los nombres de siempre. | **Hecha (v0.5.34)** |
| 5d | Datos de la Vigilia en `datos/vigilia/`: estructuras (centinela, generador y campana con sus costes), entidades (nombre, hoja de animación, vida y si flota), qué entidades salen en cada fase y los jefes (`oleadas.tres`) y los 15 pasos del tutorial. Scripts de recurso en `scripts/datos/*_vigilia.gd` y catálogo en `scripts/datos/catalogo_vigilia.gd`. **Con esto termina la fase 5.** | **Hecha (v0.5.35)** |

La fase 2 está terminada: `main.gd` ya no dibuja menús ni el HUD. Al terminar la 3, no tendrá código del jugador ni de enemigos.

Sobre el dibujo (3d): se eligió que cada escena dibuje su parte sobre el lienzo del mundo en vez de rehacerlo todo con nodos `AnimatedSprite2D` y `y_sort_enabled`: se ve idéntico, mantiene el orden por profundidad, la luz y las sombras, y deja `main.gd` sin el dibujo de cada entidad.

Por qué la fase 3 va en partes: el jugador, los enemigos y los objetos se dibujan juntos, ordenados por su altura en la sala (lo de abajo tapa a lo de arriba). Mientras el mundo no sea de nodos con orden por profundidad (3d), sus dibujos siguen en `main.gd`; primero se mueven la lógica y los estados, que es lo que más se toca al ajustar el juego.

## Fuentes

- Documentación de Godot (español), sección «Buenas prácticas»: [organización de la escena](https://docs.godotengine.org/es/4.x/tutorials/best_practices/scene_organization.html), [cuándo usar escenas y cuándo scripts](https://docs.godotengine.org/es/4.x/tutorials/best_practices/scenes_versus_scripts.html), [autoloads frente a nodos corrientes](https://docs.godotengine.org/es/4.x/tutorials/best_practices/autoloads_versus_internal_nodes.html), [recomendaciones de lógica](https://docs.godotengine.org/es/4.x/tutorials/best_practices/logic_preferences.html).
- Documentación de Godot: [Singletons (Autoload)](https://docs.godotengine.org/es/4.x/tutorials/scripting/singletons_autoload.html).
- Canal [Leedeo Studio](https://www.youtube.com/@Leedeo) (Javo, traductor oficial de Godot al español), serie «Introducción a Godot 4»: autoloads y singletons, señales, máquina de estados y pantalla de carga real. Los temas se tomaron de los títulos de la serie; los videos no se transcribieron aquí.
