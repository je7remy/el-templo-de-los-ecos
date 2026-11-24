# Arquitectura y plan de reestructuración

El juego nació como un único script (`scripts/main.gd`) que lo dibujaba todo con `_draw()`. Funciona y va fluido, pero es difícil de mantener: cualquier cambio toca el mismo archivo y nada se puede editar en el editor de Godot. Este documento explica cómo se está separando en escenas y qué reglas sigue el código nuevo.

## Cómo está organizado hoy (v0.5.17)

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

scenes/defense.tscn  (Vigilia del Claustro · defense.gd)
rooms/sala_N.tscn    salas editables (TileMapLayer, objetos, marcadores, colisiones)
```

Piezas de interfaz reutilizables (`scenes/ui/` y `scripts/ui/`):

| Pieza | Para qué |
| --- | --- |
| `estilo.gd` | Colores, tipografías y el dibujo común (panel, texto con borde, rótulo gótico, botones). `main.gd` y las escenas dibujan con lo mismo, así todo se ve igual. |
| `boton_templo.tscn` | Botón de verdad (`TextureButton` sin texturas): ratón, toque, foco de teclado y mando, señal `pressed`. Variantes `menu`, `grande`, `chico` e `icono`. |
| `texto_templo.gd`, `parrafo_templo.gd`, `panel_templo.gd`, `adorno_templo.gd` | Texto pixel o gótico, párrafo con saltos de línea, panel ornamentado y filete dorado como nodos colocables en el editor. |
| `scripts/datos/textos.gd` | Todos los textos en español e inglés y los textos legales. Las escenas los piden con `Textos.t("clave")`. |
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
6. **Datos fuera del código.** Pisos, precios y botín en `Resource` (`.tres`) editables en el inspector (ya empezado con `scripts/datos/pisos.gd`).
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
| 3c | Entidades (Ghoul, Testigo, Hechicero, Segador, Tejedora, mastines…) como escenas con su máquina de estados y señales (`herida`, `desterrada`). | Pendiente |
| 3d | El mundo como nodos con orden por profundidad (`y_sort_enabled`): cada escena (jugador, entidades, objetos) se dibuja sola con `AnimatedSprite2D`, y `main.gd` solo las instancia en la sala. | Pendiente |
| 4 | Datos en recursos `.tres`: pisos, precios de la tienda, botín, armas y equipo. | Pendiente |
| 5 | La Vigilia con las mismas piezas (pantallas, avisos, `estilo.gd`). | Pendiente |

La fase 2 está terminada: `main.gd` ya no dibuja menús ni el HUD. Al terminar la 3, no tendrá código del jugador ni de enemigos.

Por qué la fase 3 va en partes: el jugador, los enemigos y los objetos se dibujan juntos, ordenados por su altura en la sala (lo de abajo tapa a lo de arriba). Mientras el mundo no sea de nodos con orden por profundidad (3d), sus dibujos siguen en `main.gd`; primero se mueven la lógica y los estados, que es lo que más se toca al ajustar el juego.

## Fuentes

- Documentación de Godot (español), sección «Buenas prácticas»: [organización de la escena](https://docs.godotengine.org/es/4.x/tutorials/best_practices/scene_organization.html), [cuándo usar escenas y cuándo scripts](https://docs.godotengine.org/es/4.x/tutorials/best_practices/scenes_versus_scripts.html), [autoloads frente a nodos corrientes](https://docs.godotengine.org/es/4.x/tutorials/best_practices/autoloads_versus_internal_nodes.html), [recomendaciones de lógica](https://docs.godotengine.org/es/4.x/tutorials/best_practices/logic_preferences.html).
- Documentación de Godot: [Singletons (Autoload)](https://docs.godotengine.org/es/4.x/tutorials/scripting/singletons_autoload.html).
- Canal [Leedeo Studio](https://www.youtube.com/@Leedeo) (Javo, traductor oficial de Godot al español), serie «Introducción a Godot 4»: autoloads y singletons, señales, máquina de estados y pantalla de carga real. Los temas se tomaron de los títulos de la serie; los videos no se transcribieron aquí.
