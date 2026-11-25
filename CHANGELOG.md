# Historial de versiones

## v0.5.34-alpha — 2026-11-25 · Vigilia por escenas, fase 5c

Sin cambios en las reglas ni en los controles.

- **La partida de la Vigilia es una máquina de estados** (`scripts/vigilia/fases/`): portada, partida, fase superada y derrota. Cada estado decide qué hacen las teclas, el mando y los toques, y qué pantalla se ve; antes todo se repartía en `match phase` por `scripts/defense.gd`.
- Lo común (ESC, el botón de salir, el cursor con el stick) y las reglas de la Vigilia siguen en `defense.gd`.
- Comprobado con una partida simulada a base de toques, teclas y botones del mando: el resultado es idéntico paso a paso. Se ve igual (capturas idénticas).
- Versión Android 0.5.34-alpha (código 41).

## v0.5.33-alpha — 2026-11-25 · Vigilia por escenas, fase 5b

Sin cambios en las reglas ni en el aspecto del juego.

- **El HUD de la Vigilia es una escena propia** (`scenes/vigilia/hud.tscn`), con una pieza por parte: barra de arriba (fase, tiempo, ecos, energía, pausa y salir), barra de abajo (dormir, reparar, potenciar y escudo), el aviso al pie de la celda, el tutorial guiado (recuadro, flecha y tarjeta) y el menú de cada baldosa.
- Las pantallas (portada, fase superada, derrota y pausa) van por encima del HUD, como antes.
- `scripts/defense.gd` solo dibuja la celda y lo que pasa en ella; usa las tipografías de `estilo.gd`.
- Se ve idéntico a antes (comparado píxel a píxel, también en pantalla ancha). Los toques, las teclas y el mando funcionan igual.
- Versión Android 0.5.33-alpha (código 40).

## v0.5.32-alpha — 2026-11-25 · Vigilia por escenas, fase 5a

Sin cambios en las reglas ni en el aspecto del juego.

- **Las pantallas de la Vigilia son escenas propias** (`scenes/vigilia/pantallas.tscn`): la portada, «Fase superada» con su botín, «La puerta ha cedido» y la pausa. Antes se dibujaban dentro de `scripts/defense.gd`.
- Las piezas de interfaz de la Vigilia (cajas, ventanas, fichas, botones redondos, avisos y textos) están en `scripts/ui/estilo_vigilia.gd` y usan las tipografías y colores comunes de `estilo.gd`.
- Se ven idénticas a antes (comparadas píxel a píxel). Los toques, las teclas y el mando funcionan igual.
- Versión Android 0.5.32-alpha (código 39).

## v0.5.31-alpha — 2026-11-25 · Datos editables, fase 4c-2

Sin cambios en las reglas del juego.

- **Las 41 salas son archivos de datos**: `datos/pisos/piso_NN/sala_N.tres`, que se editan desde el inspector de Godot. Cada sala guarda su escena, nombre, entidad, rasgos, susurro, objetos del suelo y misión; lo demás (cofre con su nota, trampas, inscripción, muros, mastines, péndulos, braseros…) va en «extras» con la misma clave de siempre.
- Cada piso (`piso_NN.tres`) lista sus salas en orden: para añadir, quitar o reordenar salas se hace desde el propio piso.
- `scripts/datos/pisos.gd` queda solo con las conversaciones de las salas.
- La campaña recibe copias: cambiar una sala durante la partida no toca el archivo.
- Los valores son los mismos de antes: las salas salen idénticas.
- Versión Android 0.5.31-alpha (código 38).

## v0.5.30-alpha — 2026-11-25 · Datos editables, fase 4c-1

Sin cambios en las reglas del juego.

- **Los diez pisos son archivos de datos** (`datos/pisos/piso_01.tres` … `piso_10.tres`) que se editan desde el inspector de Godot: número, título, estado del templo, desgaste de la piedra, Eco que dan, combustible de la antorcha, si los compañeros te siguen, espejo y regla invertida (Piso VIII), si es el final y la **verdad** que revelan. Cada uno guarda también su nota de inspiración del diseño.
- Las salas de cada piso siguen en `scripts/datos/pisos.gd` (`SALAS`, en el mismo orden); pasarán a archivos de datos en la siguiente parte.
- Los valores son los mismos de antes: los pisos, sus salas y sus verdades salen idénticos.
- Versión Android 0.5.30-alpha (código 37).

## v0.5.29-alpha — 2026-11-25 · Datos editables, fase 4b

Sin cambios en las reglas del juego.

- **La tienda, la bolsa y el botín de la Vigilia son archivos de datos** que se editan desde el inspector de Godot:
  - `datos/tienda/`: los seis artículos del Mercader (nombre, **precio** y descripción), en el orden del puesto.
  - `datos/bolsa/`: los consumibles que se usan desde el perfil (nombre, descripción e icono).
  - `datos/botin/`: los objetos que da la Vigilia (nombre, descripción, nivel de botín 1-4 e icono).
- Se listan en `scripts/datos/catalogo.gd`; para añadir uno, duplica un `.tres` y añádelo a su lista.
- Los valores son los mismos de antes: los datos que leen la campaña y la Vigilia salen idénticos, en el mismo orden.
- Versión Android 0.5.29-alpha (código 36).

## v0.5.28-alpha — 2026-11-25 · Datos editables, fase 4a

Sin cambios en las reglas del juego.

- **Las armas y el equipo son archivos de datos** que se editan desde el inspector de Godot, sin tocar código:
  - `datos/armas/`: daga, espada, lanza, hacha, maza y el golpe base de la antorcha (daño, alcance, ritmo, vigor, apertura del golpe, aturdimiento y descripción).
  - `datos/equipo/`: yelmo, peto y botas (hueco, nombre y descripción).
- `scripts/datos/catalogo.gd` los lista en orden (el de los menús y el de cambiar de arma). Para añadir uno: duplica un `.tres` y añádelo a la lista.
- Los valores son los mismos de antes: comparé los datos que lee la campaña antes y después y salen idénticos, en el mismo orden.
- `entidades_test.gd` comprueba que las armas y el equipo salen de esos archivos.
- Versión Android 0.5.28-alpha (código 35).

## v0.5.27-alpha — 2026-11-25 · Cámara cercana en el móvil

- **En el móvil la cámara se acerca al jugador y lo sigue** en horizontal y en vertical, en vez de mostrar la sala entera en pequeño. Antes el zoom solo llenaba el ancho (hasta un 30 %) y se veía toda la sala; ahora, por defecto, el mundo se ve casi el doble de grande (zoom 1,9).
- Nueva opción en **Configuración > Sonido > Cámara en el móvil**: CERCA (por defecto, 1,9), MEDIA (1,6) o SALA (toda la sala, como antes). Se aplica al momento.
- En PC no cambia nada: se sigue viendo la sala entera. Si en PC pones los controles táctiles en «Siempre», también se usa la cámara del móvil.
- El HUD, los menús y los botones táctiles no cambian de tamaño.
- Versión Android 0.5.27-alpha (código 34).

## v0.5.26-alpha — 2026-11-25 · Arquitectura por escenas, fase 3d-4

Sin cambios en las reglas del juego ni en cómo se ve.

- **Los personajes secundarios se dibujan desde `scripts/mundo/personajes.gd`** (nodo «Personajes»): aliados, traidores del Hermano Mayor, el peregrino enjaulado del rescate, el Mercader y el muñeco de entrenamiento.
- **Las almas y el sello** se dibujan desde `scripts/mundo/objetos.gd`.
- Con esto, todo lo que se mueve, pelea o se recoge se dibuja desde su propio script; en `main.gd` queda la escenografía a ras de suelo (puertas, trampas, enredaderas, decorado, luz y niebla).
- Se ve idéntico: capturas de las 41 salas salen iguales a las de la versión anterior, salvo motas de polvo del ambiente que también cambian entre dos capturas de la misma versión. Los aliados y los traidores no aparecen en esas capturas: su dibujo se pasó tal cual y se revisó en el código.
- `main.gd` baja a unas 9 860 líneas.
- Versión Android 0.5.26-alpha (código 33).

## v0.5.25-alpha — 2026-11-25 · Arquitectura por escenas, fase 3d-3

Sin cambios en las reglas del juego ni en cómo se ve.

- **Los objetos de la sala que van en el orden por profundidad se dibujan desde `scripts/mundo/objetos.gd`** (nodo «Objetos»): columnas (y su caída), braseros, cofre, fuente, altar, carta y muros del laberinto. La campaña decide qué hay y en qué estado está.
- Se ve idéntico: capturas de **las 41 salas del juego** salen iguales a las de la versión anterior, salvo motas de polvo del ambiente que también cambian entre dos capturas de la misma versión.
- `main.gd` baja a unas 9 940 líneas.
- Versión Android 0.5.25-alpha (código 32).

## v0.5.24-alpha — 2026-11-25 · Arquitectura por escenas, fase 3d-2

Sin cambios en las reglas del juego ni en cómo se ve.

- **El jugador dibuja su parte desde su escena** (`scripts/entidades/jugador.gd`): el cuerpo en las cuatro direcciones, las siluetas del esquive, el equipo puesto (yelmo, peto, botas, amuleto, brazalete y máscara), el arma con su tajo, la antorcha encendida o apagada, el polvo del choque y los aros de protección y de daño. La campaña solo le pasa su apariencia del cuadro (`_player_look()`).
- Se ve idéntico: capturas de 22 casos (cuatro direcciones con y sin equipo y con espada a medio tajo, hacha, daga, antorcha apagada, andando, herido, protegido, chocando, esquivando, muerto e interactuando) salen iguales a las de la versión anterior, salvo motas de polvo del ambiente que también cambian entre dos capturas de la misma versión.
- `main.gd` baja a unas 10 050 líneas.
- Versión Android 0.5.24-alpha (código 31).

## v0.5.23-alpha — 2026-11-25 · Arquitectura por escenas, fase 3d-1

Sin cambios en las reglas del juego ni en cómo se ve.

- **Cada entidad dibuja su parte desde su propio script** (`dibujar()`): la entidad de la sala, las alimañas, los mastines, los arietes, el Coloso, el Hermano Mayor, la Vigía y el Peregrino. `main.gd` solo decide el orden por profundidad (lo de abajo tapa a lo de arriba) y les pide que se dibujen en su turno, así que se tapan, iluminan y sombrean igual que antes.
- Ayudas de dibujo comunes en `scripts/comun/lienzo.gd` (sombra suave, elipse, contorno), que usan la campaña y las escenas.
- Se ve idéntico: capturas de 15 salas y estados (alerta, aturdido, golpe, conjuro cargando, pisotón, rugido, cansancio, Vigía avisando, Peregrino con el cuchillo en alto…) salen iguales a las de la versión anterior; solo cambian motas de polvo del ambiente, que también cambian entre dos capturas de la misma versión.
- `main.gd` baja a unas 10 270 líneas.
- Versión Android 0.5.23-alpha (código 30).

## v0.5.22-alpha — 2026-11-25 · Arquitectura por escenas, fase 3c-5

Sin cambios en las reglas del juego.

- **La Vigía y el Peregrino tienen su máquina de estados**, y con ellos ya la tienen todas las entidades del juego:
  - Vigía (`scenes/entidades/jefes.tscn`): Mira (orbita, cuenta tu mirada, amagos y ruidos a tu espalda), Aviso, Golpe, Caza (va a por el peregrino que huye) y Vencida.
  - Peregrino (`scenes/entidades/peregrino.tscn`): Ausente, Espera, Sigue (te acompaña y compite por las almas), Desenvaina, Hostil (te persigue y tira el tajo con aviso), Amigo y Muerto.
- Avisan con señales (`provocada`, `amago`, `ruido_hecho`, `mirando`, `ataca`, `alcanza`, `presa_alcanzada`, `toma_alma`, `prepara_tajo`, `tajo`). El pánico de los aliados, la traición, lo que dice el Peregrino y su muerte siguen en la campaña.
- El comportamiento es idéntico al de antes: una simulación con semilla fija de los pisos del Peregrino (traidor y sincero, sala por sala hasta la cripta) y de la sala de la Vigía da exactamente las mismas posiciones, estados, tiempos, vida y almas.
- `entidades_test.gd` prueba la provocación y la victoria sobre la Vigía, y el Peregrino siguiéndote, desenvainando, atacando y muriendo.
- Versión Android 0.5.22-alpha (código 29).

## v0.5.21-alpha — 2026-11-24 · Arquitectura por escenas, fase 3c-4

Sin cambios en las reglas del juego.

- **El Coloso y el Hermano Mayor son escenas con su máquina de estados** (`scenes/entidades/jefes.tscn`, `scripts/entidades/jefes/`):
  - Coloso: Camina (más rápido con cada columna que le cae), Alza (aviso del pisotón), Pisa y Aturdido.
  - Hermano Mayor: Habla, Camina, Zarpazo, ApuntaHilos, Hilos, Ruge, Cansado y Mira; usa sus reglas robadas en orden (hilos, rugido, mirada).
- Avisan con señales (`hiere`, `alza`, `pisoton`, `regla`, `hilos_activos`, `rugido`). Las columnas, los aliados, las piedras de los traidores y las derrotas siguen en la campaña.
- El comportamiento es idéntico al de antes: una simulación con semilla fija de sus dos salas (25 segundos cada una, andando, esquivando y golpeando) da exactamente las mismas posiciones, estados, tiempos, vida y reglas.
- `entidades_test.gd` prueba los estados del Coloso (incluida la columna que lo aturde) y el ciclo de reglas del Hermano Mayor.
- Versión Android 0.5.21-alpha (código 28).

## v0.5.20-alpha — 2026-11-24 · Arquitectura por escenas, fase 3c-3

Sin cambios en las reglas del juego.

- **Alimañas, mastines y arietes tienen su máquina de estados**, en la nueva escena `scenes/entidades/criaturas.tscn`. Como pueden ser muchas en una sala, cada tipo es una **manada**: una sola máquina compartida, cada criatura guarda en sus datos en qué estado está y los estados son nodos (`scripts/entidades/manadas/`).
  - Alimañas: Patrulla, Persigue (huele la sangre) y Muerta (el nido la repone).
  - Mastines: Vaga, Ronda (con la antorcha guardan distancia y gruñen), Carga (a oscuras) y Huye.
  - Arietes: Quieto, Apunta, Embiste y Aturdido.
- Avisan con señales (`mordisco`, `aplastada`, `grunido`, `apunta`, `embiste`, `choca`, `alcanza`); el daño, las almas, los sonidos y el empujón los decide la campaña.
- El comportamiento es idéntico al de antes: una simulación con semilla fija de las 39 salas con alimañas, mastines o arietes (15 segundos cada una, andando, esquivando, golpeando y encendiendo y apagando la antorcha) da exactamente las mismas posiciones, estados, vida y almas.
- `entidades_test.gd` prueba los estados de las tres manadas.
- Versión Android 0.5.20-alpha (código 27).

## v0.5.19-alpha — 2026-11-24 · Arquitectura por escenas, fase 3c-2

Sin cambios en las reglas del juego.

- **El Segador y la Tejedora tienen su máquina de estados** en la escena de la entidad (`scenes/entidades/entidad.tscn`):
  - Segador: Acecho (ronda y busca línea limpia), Tensa (hilos tensos, va a disparar) y Engancha (atraviesa la línea y queda clavado: solo entonces es vulnerable). Aturdirlo mientras tensa le corta los hilos.
  - Tejedora: Anda (hacia ti, rodeando columnas), Alza (levanta la zarpa) y Zarpa (golpea). Aturdida vuelve a Anda.
- Nuevas señales: `hilos_tensos` (los aliados reaccionan), `hilos_disparados` (golpe a quien esté en la línea), `hilos_cortados`, `zarpa_alzada` y `zarpazo`. El fuego de las enredaderas y las quemaduras siguen en la campaña.
- El comportamiento es idéntico al de antes: una simulación con semilla fija de las salas del Segador y la Tejedora (15 segundos cada una, andando, parando, golpeando y aturdiendo) da exactamente las mismas posiciones, estados, vida y aliados vivos; y la de Ghoul, Testigo y Hechicero sigue igual.
- `entidades_test.gd` prueba los estados de los dos, el corte de hilos y el zarpazo.
- Versión Android 0.5.19-alpha (código 26).

## v0.5.18-alpha — 2026-11-24 · Arquitectura por escenas, fase 3c

Sin cambios en las reglas del juego.

- **La entidad de la sala es una escena propia** (`scenes/entidades/entidad.tscn`): posición, vida, alerta, aturdimiento y hacia dónde mira, con **una máquina de estados por tipo**:
  - Ghoul: Reposo (vuelve a su sitio), Caza (persigue tu luz) y Aturdida.
  - Testigo: Vigila, Caza (persigue lo que se mueve con el ojo abierto; en el Piso VIII, lo quieto) y Aturdida.
  - Hechicero: Reposo, Conjura (lanza su conjuro a tu luz) y Aturdida.
- Avisa con señales: `herida`, `desterrada` (la campaña la destierra y suelta sus almas), `conjuro` (la campaña crea la bola de fuego) y `regla` (la primera vez que el Testigo te persigue se recuerda su regla).
- El comportamiento es idéntico al de antes: una simulación de las 10 salas con Ghoul, Testigo o Hechicero (15 segundos cada una, andando, parando, golpeando y aturdiendo) da exactamente las mismas posiciones, vida, alertas, bolas de fuego y daño.
- `entidades_test.gd` prueba los estados de los tres tipos, el destierro y el conjuro. El Segador, la Tejedora y las demás criaturas son las siguientes partes.
- Versión Android 0.5.18-alpha (código 25).

## v0.5.17-alpha — 2026-11-24 · Arquitectura por escenas, fase 3b

Sin cambios en las reglas del juego.

- **La salud del jugador vive en su escena**: vida, vida máxima, vigor y miedo, con una segunda máquina de estados, **Salud** (Vivo, Herido, Muerto).
- Todos los golpes (entidades, trampas, fuego, péndulos, mastines, alimañas, Coloso, Hermano Mayor…) pasan por un solo `herir()`, que aplica el daño, el miedo y la invulnerabilidad y avisa con la señal `herido` (sonido, sacudida y sangre). Quedarse sin vida avisa con `muerto`, que lleva a la pantalla de muerte.
- El daño es idéntico al de antes: una simulación de 40 salas de 8 pisos, caminando 5 segundos por cada una, da exactamente la misma vida, miedo, posición y muertes.
- `entidades_test.gd` prueba los golpes, la invulnerabilidad, la muerte y volver a empezar.
- Versión Android 0.5.17-alpha (código 24).

## v0.5.16-alpha — 2026-11-24 · Arquitectura por escenas, fase 3a

Sin cambios en las reglas del juego.

- **El jugador es una escena propia** (`scenes/entidades/jugador.tscn`) con su **máquina de estados**: Quieto, Camina y Esquiva (`scripts/entidades/jugador/`). Lleva la posición, la dirección, la inercia al andar, el impulso del esquive, las siluetas que deja, las colisiones con la sala y los pasos.
- Avisa con señales: `paso` (suena y levanta polvo) y `choque`. La campaña le pasa los controles y la velocidad (con Ecos y equipo) y escucha esas señales.
- El movimiento es idéntico al de antes: una simulación de 360 cuadros con andar, girar, parar y cuatro esquives da exactamente las mismas posiciones.
- Nueva prueba `tests/entidades_test.gd` (estados, esquive, pasos y muros), también en los flujos de GitHub.
- La vida, el daño y el dibujo del jugador, y los enemigos, son las siguientes partes de la fase 3 (`docs/ARQUITECTURA.md`).
- Versión Android 0.5.16-alpha (código 23).

## v0.5.15-alpha — 2026-11-24 · Arquitectura por escenas, fase 2e

Sin cambios en las reglas del juego.

- **El HUD es una escena propia** (`scenes/ui/hud.tscn`, capa 1: encima de la sala, debajo de las pantallas), hecha de piezas que se dibujan solas (`scripts/ui/hud/`): franjas, panel del jugador, cartel del piso con las almas, minimapa con los botones de pausa y habilidades, misión y atajos, panel del arma, rótulo de misión, almas de la sala, fundido entre salas, tutorial y controles táctiles. Cada pieza se puede ver y mover en el editor.
- La campaña decide qué muestra cada pieza y le pasa los datos cada cuadro; los toques sobre el HUD (retrato, pausa, minimapa, habilidades, joystick) funcionan igual que antes.
- El HUD se sacude con la sala, como antes. Única diferencia visible: el brillo de las antorchas ya no aclara los rótulos que están dentro de la sala.
- Con esto `main.gd` ya no dibuja ningún menú ni el HUD: queda la campaña y el mundo (unas 10 600 líneas). `pantallas_test.gd` prueba el HUD.
- Versión Android 0.5.15-alpha (código 22).

## v0.5.14-alpha — 2026-11-24 · Arquitectura por escenas, fase 2d

Sin cambios en las reglas del juego.

- **El perfil es una escena propia** (`scenes/pantallas/perfil.tscn`): ficha del personaje, las pestañas MOCHILA Y HABILIDADES, OBJETOS y EQUIPO, los Ecos y la descripción de lo señalado. Se ve y responde como antes al ratón, al toque, al teclado y al mando (I/Tab, O, ENTER, flechas, LB, RB, A, B e Y).
- La campaña conserva la lógica (usar objetos, poner y quitar equipo) y le pasa los datos; el perfil los recibe cada cuadro.
- El equipo sobre el retrato (casco, peto, amuleto y máscara) pasa a `scripts/ui/equipo_retrato.gd`, compartido por el panel del jugador y el perfil.
- `main.gd` baja a unas 10 750 líneas. `pantallas_test.gd` añade el perfil con entrada real. Las capturas de las tres pestañas salen idénticas a las de la versión anterior.
- Versión Android 0.5.14-alpha (código 21).

## v0.5.13-alpha — 2026-11-24 · Arquitectura por escenas, fase 2c

- **Intro, creación del personaje, habilidades y mapa son escenas propias** (`scenes/pantallas/intro.tscn`, `creacion.tscn`, `habilidades.tscn`, `mapa.tscn`). Se ven y responden como antes al ratón, al toque, al teclado y al mando: el teclado en pantalla del nombre, el género, nombre al azar, las páginas de habilidades y las pestañas del mapa.
- **Arreglo:** el texto de la intro vuelve a escribirse letra a letra; antes se quedaba vacío hasta pulsar.
- La campaña conserva la lógica (validar el nombre, crear el personaje, qué habilidades hay) y les pasa los datos; la creación, las habilidades y el mapa los reciben cada cuadro.
- `main.gd` baja a unas 10 900 líneas. `pantallas_test.gd` añade las cuatro pantallas con entrada real.
- Versión Android 0.5.13-alpha (código 20).

## v0.5.12-alpha — 2026-11-24 · Arquitectura por escenas, fase 2b

Sin cambios en las reglas del juego.

- **Las pantallas de la partida son escenas propias** (`scenes/pantallas/`): diálogos (con su botón SALTAR), elección, entrada al piso, resumen del piso, muerte y victoria, altar y tienda del Mercader (con la ficha de la Vigilia). Se ven y responden como antes al ratón, al toque, al teclado y al mando.
- La campaña sigue llevando la lógica (comprar, avanzar el diálogo, cuándo se puede cerrar la pantalla de muerte) y les pasa los datos; las que cambian mientras se ven (diálogo, muerte, tienda, altar) los reciben cada cuadro y justo antes de cada pulsación.
- Más piezas en `estilo.gd`: texto sin borde, texto centrado y corte de líneas.
- `main.gd` baja a unas 11 200 líneas. `pantallas_test.gd` añade diálogo, elección, muerte, altar y tienda con entrada real.
- Versión Android 0.5.12-alpha (código 19).

## v0.5.11-alpha — 2026-11-24 · Arquitectura por escenas, fase 2a

Sin cambios en las reglas del juego.

- **Configuración, acuerdo de usuario y menú de pisos son escenas propias** (`scenes/pantallas/ajustes.tscn`, `acuerdo.tscn`, `pisos.tscn`), gobernadas por el gestor de pantallas. Ya no se dibujan dentro de `main.gd`.
- La configuración edita los ajustes por sí misma y solo avisa a la campaña de lo que la afecta. Mantiene todo: deslizadores que se arrastran, interruptores, reasignar teclas, controles táctiles, idioma, privacidad, textos legales con las pestañas bloqueadas y borrar los datos.
- Las tarjetas del menú de pisos son botones (`scripts/ui/tarjeta_piso.gd`): el primer toque elige y el segundo desciende, como antes.
- En el acuerdo, ACEPTAR tiene el foco al abrirse.
- Todos los textos en español e inglés pasan a `scripts/datos/textos.gd`. Nuevas piezas `parrafo_templo.gd` y, en `estilo.gd`, la barra y el párrafo.
- `Eventos.sonido_pedido`: las escenas piden sonidos sin conocer a la campaña.
- `main.gd` baja de unas 12 000 a 11 500 líneas. `pantallas_test.gd` prueba las tres pantallas nuevas con clics y teclas de verdad.
- Versión Android 0.5.11-alpha (código 18).

## v0.5.10-alpha — 2026-11-24 · Arquitectura por escenas, fase 1

Sin cambios en las reglas del juego: es una reorganización del código (ver `docs/ARQUITECTURA.md`).

- **Autoloads nuevos:** `Eventos` (bus de señales), `Progreso` (el único que lee y escribe la partida; el botín de la Vigilia también pasa por él) y `Escenas` (cambio de escena con **pantalla de carga real**: fundido y barra con el progreso de la carga en segundo plano). Ir a la Vigilia y volver ya la usa.
- **Inicio, menú principal y pausa son escenas propias** (`scenes/pantallas/`), con botones de verdad: ratón, toque, teclado y mando van por la interfaz de Godot. Las gobierna un gestor con una **máquina de estados** genérica (`scripts/comun/maquina_estados.gd`), que servirá también para el jugador y las entidades.
- **Capa de avisos** (`scenes/ui/avisos.tscn`): el mensaje breve y los rótulos de nivel y de objeto, siempre por encima de cualquier menú.
- **Estilo común** (`scripts/ui/estilo.gd`): paneles, textos y botones se dibujan igual en las escenas y en `main.gd`. El menú, la pausa y el inicio se ven como antes.
- En el menú y la pausa, el botón con el foco se resalta (para jugar con teclado o mando). En la pausa, la cruceta da la vuelta de la última opción a la primera.
- El aviso de versión nueva es un componente propio del menú.
- La pantalla de inicio muestra la versión real del juego (antes decía «v0.9 · demo»).
- `main.gd` pierde unas 290 líneas de menús. Prueba nueva `tests/pantallas_test.gd`, que pulsa los botones de verdad.
- Versión Android 0.5.10-alpha (código 17).

## v0.5.9-alpha — 2026-11-23 · Actualizaciones automáticas en Android, Windows y Linux

- **El juego avisa y se actualiza solo.** Al abrir una copia instalada, consulta las versiones publicadas en GitHub. Si hay una más nueva, el menú muestra «NUEVA VERSIÓN … DISPONIBLE» con ACTUALIZAR y AHORA NO (también la tecla **U**):
  - Windows instalado: descarga el instalador, lo ejecuta en silencio y el juego se vuelve a abrir ya actualizado.
  - Windows portable: cambia el `.exe` por el nuevo.
  - Linux: cambia el ejecutable por el nuevo y vuelve a abrir el juego.
  - Android: abre la descarga del APK para confirmar la instalación.
  - Si algo falla, ofrece la descarga a mano. Sin internet no aparece nada. La partida no se toca.
- **Nuevo ajuste** «Buscar actualizaciones al abrir» (Configuración > Sonido), activado por defecto.
- **APK con firma fija:** si el repositorio tiene los secretos `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD` y `ANDROID_KEY_ALIAS`, el CI firma siempre con la misma llave y cada APK se instala encima del anterior. Sin ellos, usa una llave temporal como antes.
- El APK pide permiso de internet (para consultar las versiones).
- El instalador de Windows, ejecutado con `/S`, vuelve a abrir el juego al terminar.
- La versión del juego vive en `project.godot` y el CI comprueba que coincida con la del APK y los instaladores.
- Prueba nueva `tests/update_test.gd`. Versión Android 0.5.9-alpha (código 16).
- **Publicación:** cada versión se publica como la última (*Latest*) en vez de *pre-release*, con copias de nombre fijo para enlaces de descarga permanentes (`releases/latest/download/ElTemploDeLosEcos-Windows-Setup.exe`, etc.). El README tiene ahora una sección «Descargar la última versión».

## v0.5.8-alpha — 2026-11-23 · Quitarse el equipo, golpes propios de cada arma y avisos siempre visibles

- **Todo se puede quitar.** En Perfil > EQUIPO hay siete huecos: arma, casco, peto, botas y los accesorios (máscara de porcelana, amuleto y brazalete).
  - Tocar un hueco ocupado lo quita: el personaje y el retrato vuelven a su aspecto normal y se pierde el bono (daño, vigor, Rugido, vida…).
  - Tocar un hueco vacío vuelve a poner lo que tengas para él.
  - Lo quitado se guarda entre partidas.
- **Cada arma golpea a su manera**, sin el fuego de la antorcha:
  - Daga: dos tajos rápidos.
  - Espada: media luna de acero.
  - Lanza: estocada recta.
  - Hacha: barrido ancho con polvo.
  - Maza: impacto con onda y chispas.
  - Suenan a metal, no a llama.
- **Avisos siempre visibles:** «Nivel N» y los objetos de cofres o PNJ se dibujan encima de todo, también con el perfil, el mapa o la pausa abiertos. Aparecen junto al personaje (encima, o debajo si está muy arriba), nunca fuera de la pantalla; si salen dos a la vez, se apilan.
- Pruebas nuevas. Versión Android 0.5.8-alpha (código 15).

## v0.5.7-alpha — 2026-11-23 · El equipo se ve puesto, avisos encima y colisiones por silueta

- **Todo lo equipado se ve en el personaje**, en las cuatro direcciones, y en su retrato (HUD y perfil):
  - Yelmo: casco de hierro con cresta.
  - Máscara de porcelana: sustituye el rostro, con cuencas y lágrimas pintadas; de espaldas se ve la cinta.
  - Amuleto: cadena y colgante en el pecho.
  - Peto: placa y hombreras.
  - Botas de cuero.
  - Brazalete dorado en la muñeca.
- **El arma se lleva en la mano** en lugar de la antorcha y traza un arco al golpear.
  - Con un arma empuñada la antorcha se guarda: no da luz.
  - **F** alterna: guarda el arma y saca la antorcha (y la enciende), o apaga la antorcha y vuelve a empuñar el arma.
- **Avisos de botín encima de todo:** el rótulo del cofre se dibuja lo último y ya no queda debajo de otros paneles. También se ve mientras se lee la nota (el tiempo se detiene hasta cerrarla).
- **Regalos de los PNJ con rótulo:** lo que te da Odón (reliquia de ecos) o el grupo al llegar todos (vial de sangre) aparece en el mismo rótulo grande.
- **Colisiones según la silueta:** la huella de cada objeto alto se calcula de los píxeles de su dibujo que tocan el suelo (base, patas, pedestal, fila baja de libros). Lo que sobresale por arriba ya no choca. Aplica también al mobiliario del templo.
- Pruebas nuevas. Versión Android 0.5.7-alpha (código 14).

## v0.5.6-alpha — 2026-11-23 · Retoques: armas, equipo, pantalla completa real y estilo más vivo

- **Pantalla completa de verdad.**
  - En PC el juego arranca a pantalla completa. F11 o Alt+Enter cambian a ventana y de vuelta; también está en Configuración. Los ajustes guardados antes pasan una vez a pantalla completa.
  - En pantallas más anchas que la sala (móviles 20:9, portátiles 16:9) el mundo se acerca hasta un 30 % y ocupa todo el ancho, sin franjas negras. Una cámara suave sigue al jugador en vertical. En 3:2 no cambia nada.
- **Estilo más vivo (inspirado en Soul Knight):** colores más saturados y algo más de contraste y luz, penumbra más clara y violácea, y contorno oscuro en el jugador, los PNJ y las entidades.
- **Tipografía nueva y algo más grande:** Jersey 15 (OFL), reescalada un 10 %. Letras, tildes y cifras más claras, en todo el juego y la Vigilia. Sustituye a Pixelify Sans y a la fuente aparte de cifras.
- **Armas tiradas por las salas** (se equipan al recogerlas):
  - Daga de hueso: rápida y ligera.
  - Espada oxidada: equilibrada.
  - Lanza del peregrino: mucho alcance, solo de frente.
  - Hacha de verdugo: lenta, barre a tu alrededor.
  - Maza de campana: aturde casi un segundo.
  - Con arma se golpea siempre; la antorcha encendida sigue prendiendo raíces.
- **Equipo:** yelmo abollado (−12 % de daño recibido), peto de guardia (+20 de vida máxima) y botas de peregrino (+8 % de velocidad, esquive un 10 % antes).
- **Perfil > EQUIPO:** nueva pestaña con lo que llevas puesto (arma, casco, peto, botas) y lo encontrado, para cambiar de arma. Armas y equipo se guardan entre partidas. Borrar perfil los quita.
- **Movimiento más fluido:** el personaje acelera y frena en una décima de segundo, sin tirones. El esquive sale disparado, se frena solo, enlaza con el paso normal y deja siluetas.
- **Colisiones más justas:** columnas, estanterías y estatuas solo chocan por la base, así que se puede pasar por detrás. El radio de los pies baja de 15,5 a 11 px. El I-4 (Archivo) ya no forma un muro.
- **PNJ:** si un aliado que te quitó almas muere, suelta todo lo que tomó más 5 almas propias.
- **Tutorial sin gasto:** fósforos (∞) y objetos de la bolsa no se consumen, para practicar.
- **Términos y condiciones:** mientras se lee un texto legal, las pestañas de Configuración quedan apagadas; se sale con VOLVER.
- Pruebas nuevas para todo lo anterior. Versión Android 0.5.6-alpha (código 13).

## v0.5.5-alpha — 2026-11-22 · Linux, puertas, PNJ y arreglos de la revisión

- **Versión para Linux.** Cada release publica `ElTemploDeLosEcos-vX-Linux-x86_64.tar.gz`: el juego listo para abrir, `instalar.sh` (menú de aplicaciones, sin `sudo`), `desinstalar.sh` y un `LEEME.txt` con cómo reportar errores. El CI lo exporta y lo sube junto al APK y los archivos de Windows.
- **Pantalla de muerte legible.** Se queda al menos 2,6 s: los toques y teclas de más no la cierran. Mientras tanto se llena una barra; luego aparece «toca para continuar».
- **Perfil:**
  - En EQUIPO Y MOCHILA hay dos grupos con título: **MOCHILA** (madera, fósforos, antorcha) y **HABILIDADES NATIVAS** (llama interior, golpe, Resonancia).
  - La pestaña OBJETOS tiene **12 huecos** (antes 6: el séptimo objeto no se veía). Las descripciones largas ya no se cortan.
- **Números legibles.** Todos los números del juego (vida, almas, precios, «SALA 3/4»…) salen con una fuente de cifras clara (Silkscreen, OFL); las letras siguen con Pixelify Sans. `herramientas/fuente_cifras.py` genera las dos fuentes.
- **Las salas con entidad se cierran hasta desterrarla.** Ghoul, Hechicero, Segador, Tejedora y Testigo sellan la puerta («PUERTA SELLADA: DESTIERRA AL…»). Mastines, arietes, la vigía y el Coloso no cuentan. Las salas sin entidad siguen abriéndose con su condición.
- **Más puertas en cada sala:** la entrada por la que llegaste (izquierda) y dos pasos laterales con rastrillo. Cuando un grupo se despide (los cazadores en III-4, los guiados en VII-4), se le ve cruzar el paso lateral («X SE SEPARA») y ya no te sigue. En VI-1, si no aceptas guiarlos, al acercarte a la salida se ve «SE QUEDA AQUÍ».
- **Cuidar a los PNJ cuenta.** Cada cazador o guiado que muere mientras lo acompañas resta 1 a la marca. Si llegan todos con vida, +1 a la marca y un vial de sangre.
- **El mensaje de Mara para Odón.** Tras leer la nota del cofre del III-1, sobre Odón aparece «!» y «DARLE EL MENSAJE DE MARA». Al dárselo, Odón responde, te entrega una reliquia de ecos y suma a la marca (una sola vez).
- **Péndulo:** hiere toda la hoja (el filo entero y su anchura), no solo el centro; quien pasa por delante o por detrás no recibe daño.
- **Vigilia:**
  - Al salir (botón, ESC o cerrar la app) **se guarda la vigilia**: lo construido, ecos, energía, puerta y fase. En la portada sale «CONTINUAR · FASE N» y «EMPEZAR DE CERO». Si saliste a mitad de fase, esa fase se repite; si estaba superada, sigues en la siguiente. Perder la borra.
  - El menú de una estructura se actualiza en tiempo real: al llegar los ecos al precio, «MEJORAR» se enciende sin cerrarlo y abrirlo.
- **Vida extra sin tope.** Curarse con objetos (pan, vial, relicario, fuente) con la vida llena suma por encima del máximo, sin límite. La regeneración natural no pasa del máximo.
- Pruebas nuevas para todo lo anterior. Versión Android 0.5.5-alpha (código 12).

## v0.5.4-alpha — 2026-11-22 · Versión de prueba para Windows

- **Instalador de Windows.** Cada release publica, junto al APK:
  - `ElTemploDeLosEcos-vX-Windows-Setup.exe`: instala solo para el usuario (sin administrador), con accesos en el menú Inicio y el escritorio, «Jugar ahora» al terminar y desinstalador en «Aplicaciones instaladas». Actualizar encima conserva la partida.
  - `ElTemploDeLosEcos-vX-Windows-Portable.zip`: el juego sin instalar.
- **`LEEME.txt` para quien prueba:** controles, cómo reportar un error (qué pasó, piso y sala, captura, versión de Windows y el registro `godot.log`) y problemas frecuentes, como el aviso de SmartScreen.
- Nuevo preset de exportación «Windows Desktop» (x86_64, un solo `.exe` con los datos dentro). El CI lo exporta, comprueba que no haya errores, arma el instalador con NSIS y sube los dos archivos al mismo prerelease.
- Versión Android 0.5.4-alpha (código 11).

## v0.5.3-alpha — 2026-11-22 · Arte de las salas, luz, más alimañas y trampas nuevas

- **Pantalla completa sin rarezas.** Se quitó la copia ampliada de la sala en los lados. Ahora los muros de la propia sala siguen hasta el borde de la pantalla y se apagan hacia la oscuridad, sobre un fondo continuo. La sala parece flotar de lado a lado, sin marco. Igual en la Vigilia: el fondo y las barras llegan de borde a borde.
- **Salas amuebladas** con piezas de Knowledge Temple que antes no se usaban: sarcófagos, mesas de lectura (con libros caídos alrededor), altares, estatuas encapuchadas, columnas rotas y braseros animados.
  - Cada piso tiene su estilo: libros en los Peregrinos, sarcófagos y altares en la Cacería, braseros en el Laberinto, etc.
  - Siempre las mismas en la misma sala, en espejo, con sombra y una base que no se atraviesa.
  - Nunca tapan almas, objetos, cofres, trampas, PNJ ni la puerta: el juego comprueba al colocarlas que desde la entrada se llega a todo.
- **Luz de motor grande.** Una capa de luz aditiva (como el *bloom*) hace que el fuego, las almas, la antorcha, las bolas de fuego y la salida abierta brillen sobre la penumbra. Los braseros sueltan chispas; las almas, motas azules.
- **Estatuas completas.** A las estatuas de arquero les faltaba el fuste entre el capitel y el pedestal; ahora tienen su columna de piedra (`herramientas/completar_estatuas.py`).
- **Más alimañas, en todos los pisos** (salvo el tutorial y el puesto del Mercader):
  - **Murciélagos** (nuevo): vuelan por encima de columnas y muros, rápidos pero de mordisco flojo.
  - **Arañas** (nuevo): lentas al patrullar, pero huelen desde lejos, saltan y su mordisco da más miedo.
  - Las **ratas** siguen igual. Cada piso mezcla las suyas; desde el Piso V salen de nidos.
  - Sprites originales en `herramientas/generar_bichos.py` (la rata no se tocó).
- **Trampas nuevas.** Avisan antes de herir, el esquive las cruza y también hieren a los aliados.
  - **Llamaradas:** rejillas que se ponen al rojo y escupen una columna de fuego (III-4, VII-4, IX-2).
  - **Péndulos:** una cuchilla colgada de una cadena barre la sala de lado a lado y te empuja. Su surco en el suelo marca por dónde pasa (II-4, IV-4, VII-4, IX-4).
- **Más entidades:** un Hechicero en II-4 y IX-4 y un Ghoul en IV-4 y VIII-4, salas que antes estaban vacías.
- **La llave de la Vigilia, explicada.** Al elegirla en el puesto del Mercader se abre una ficha: qué es el modo, cómo se juega, qué lo hace perder y qué da sobrevivir (un objeto para la campaña por cada fase superada, mejor cuanto más aguantas). Solo se paga al confirmar.
- Pruebas: mobiliario en las salas, llamaradas que queman salvo esquivando, péndulo que hiere, los tres tipos de alimaña presentes y la ficha de la Vigilia antes de cobrar.
- Versión Android 0.5.3-alpha (código 10).

## v0.5.2-alpha — 2026-11-22 · Pantalla completa real y arreglos táctiles

- **Pantalla completa de verdad, sin bordes negros**, en cualquier pantalla: teléfono 20:9, tableta 4:3 o portátil 16:9.
  - La ventana usa `expand` y el juego mide la pantalla al arrancar y cada vez que cambia de tamaño.
  - La zona de juego (960×640) queda centrada, sin deformar el pixel art. Lo que sobra a los lados se rellena con la propia sala, ampliada y en penumbra.
  - Los controles táctiles se pegan a los bordes reales: el joystick a la esquina inferior izquierda, los botones a la inferior derecha.
  - Lo mismo en la Vigilia.
- **Toques que contaban dos veces (móvil).** Cada toque llegaba como toque y como clic emulado. Ahora se ignora el clic emulado. Eso arregla:
  - el perfil, el mapa y el inventario, que se abrían y cerraban con el mismo toque;
  - el teclado del nombre, que escribía y borraba dos letras;
  - en la Vigilia, los botones que se activaban dos veces (por ejemplo, dormir y levantarse a la vez).
- **Teclado del móvil para el nombre.** En pantallas táctiles, al crear el personaje se abre el teclado del teléfono; también al tocar el recuadro del nombre. Lo escrito pasa por el mismo filtro que el teclado del juego (mayúsculas y letras, hasta el máximo), y el teclado en pantalla sigue disponible.
- El subtítulo del menú ya no da pistas («Despiertas a oscuras. Nadie te dice por qué.»).
- Pruebas: un toque con clic emulado abre el perfil o el mapa una sola vez y escribe una sola letra, y el campo del teléfono filtra el nombre.

## v0.5.1-alpha — 2026-11-22 · Experiencia de juego: Vigilia por llave, puntos de control y PNJ vivos

- **La Vigilia se compra.** El Mercader Silencioso (Piso VI) vende la **llave de la Vigilia** por 500 almas (más si llevas la maldición; nunca menos). Hasta entonces, el botón del menú sale como «BLOQUEADA». Así el botín que da la Vigilia (fósforos, pan…) llega cuando ya tiene sentido en la campaña.
- **Las almas se guardan** entre partidas y sesiones: son tu moneda. Borrar el perfil las pone a cero.
- **Fósforos de la bolsa:** usarlos con la madera en la mano hace la antorcha. Ya no hace falta recoger los del suelo.
- **Puntos de control por sala.** Cada sala a la que entras queda guardada. En el menú de pisos, ese piso dice «SEGUIR · SALA N» y se retoma desde ahí, con antorcha y fósforos. Al morir ya se reaparecía en la misma sala; ahora tampoco se pierde al cerrar el juego.
- **Cofres:** el objeto se ve claro. Tras la nota aparece «OBJETO ENCONTRADO» con su descripción, y un rótulo con icono, nombre y rareza.
- **Contador de la sala:** lo que decía «SALA 0/3» eran los fragmentos de almas de la sala. Ahora dice **«ALMAS 0/3»**; el número de sala sigue en el minimapa.
- **PNJ con vida propia** (los cazadores del III, Saúl, el grupo del VI y VII, los aliados del X):
  - Tienen vida (barra cuando están heridos). Les dañan las trampas y la entidad de la sala, y pueden morir.
  - Se defienden: empujan a la entidad («¡ATRÁS!», la frenan un instante) y aplastan alimañas.
  - Van a lo suyo: recogen almas sueltas, fragmentos y pan que tengan más cerca que tú, y vacían el relicario de vida si están heridos. Con la bendición te dan la mitad; si no, se lo quedan.
- **Piso VI, petición clara.** Sobre el grupo aparece un «!» y «EL GRUPO PIDE AYUDA». Al hablar, una ventana con dos opciones grandes: **AYUDARLOS** o **NEGARSE**. Negarse cuenta en contra de tu marca (una vez); puedes cambiar de idea.
- **Recompensas dichas:**
  - Antes de entrar a un piso: «RECOMPENSA AL SUPERAR ESTE PISO: ECO «…» (habilidad pasiva)».
  - En el resumen: «POR SUPERAR EL PISO … GANAS EL ECO «…»».
  - Al entrar al siguiente piso se recuerda qué ganaste en el anterior.

## v0.5.0-alpha — 2026-11-22 · Cofres, mapa grande, mapa del descenso y APK al día

- **Mapa grande:** se abre tocando o haciendo clic en el minimapa, con M o con SELECT del mando. Tiene dos pestañas:
  - **Este piso:** sala por sala, con nombre, misión (✓ si está hecha), cofre y dónde caíste. Las salas sin visitar salen como «???».
  - **Descenso:** un pozo que se dibuja a medida que bajas. Muestra cada piso alcanzado, si está superado, tus caídas y los cofres abiertos, y abajo «PISO ???». Al pie, la última verdad descubierta.
- **Cofres** en 12 salas, al menos uno por piso. Cada uno guarda un objeto del botín (mejor cuanto más hondo) y una nota de quien lo dejó. Se abren una sola vez por perfil y se guardan. Borrar el perfil también los vacía.
- **Android al día:** versión 0.5.0-alpha (código 7). Al fusionar en `main`, el CI compila el APK y publica la prerelease `v0.5.0-alpha` con él. Si esa versión ya existe, no la toca. Hay que desinstalar la versión anterior del teléfono antes de instalar la nueva.
- Mando: SELECT abre el mapa; el perfil sigue en LB.

## En `main` (sin nuevo release) — 2026-11-22 · El Peregrino ya no se delata por un golpe accidental

- En el Piso II, mientras el Peregrino te acompaña **no se le puede tocar**: ni el golpe de antorcha (por ejemplo, al aplastar alimañas a su lado) ni la Resonancia lo hieren ni lo ponen en guardia. La traición llega por sorpresa, en su momento. Solo se le puede herir cuando desenvaina.

## En `main` (sin nuevo release) — 2026-11-22 · Borrar perfil de verdad, pisos en orden y ajuste de Resonancia y esquivar

- **Borrar el perfil** (Configuración > Privacidad) borra todo: el progreso de la campaña, los récords de la Vigilia y los ajustes. El juego se reinicia desde cero en este orden:
  1. intro;
  2. **tutorial**;
  3. **creación del personaje** (nombre y género);
  4. Piso I.
- **Primera partida en ese orden:** intro, tutorial, personaje y Piso I (antes se creaba el personaje antes del tutorial).
- **Pisos en orden:** solo el Piso I está abierto al empezar; superar un piso desbloquea el siguiente. No se puede entrar en un piso bloqueado.
- **Resonancia −90 % de daño** (era demasiado fuerte). Las mejoras del altar o el puesto y los niveles la siguen subiendo. El aturdimiento no cambia.
- **Esquivar tiene recarga propia, un 50 % más larga** que lo que tarda la barra en recuperar su coste (unos 2,6 s al principio). La acortan Reflejos, el amuleto y los niveles. El icono muestra la recarga.

## En `main` (sin nuevo release) — 2026-11-22 · Revisión de la historia y sin pistas fáciles

- **Sin referencias al templo dentro del juego.** Ningún texto lo nombra: el jugador descubre por sí mismo dónde está. Solo queda el título del juego, que es la marca.
  - Cambian la intro, el subtítulo, los avisos, los menús y las verdades.
  - El Piso VIII pasa a llamarse **Las Salas que Cambian**.
  - La inscripción del VIII dice: «Esto nunca fue un santuario. Es una fábrica…».
- **Menús sin pistas:**
  - en el menú de pisos, los no alcanzados muestran «???»;
  - el icono del Eco solo aparece en los pisos ya superados;
  - los Ecos sin despertar no dicen dónde se consiguen;
  - las habilidades y los objetos que no tienes solo dicen «Aún no la tienes» o «Aún no lo tienes».
- **Reglas por descubrir.** Los avisos describen lo que pasa, no la solución. Ejemplos:
  - «El golpe rebota. Ahora mismo es piedra.»
  - «La columna cruje, pero aguanta.»
  - «Raíces vivas tapan la puerta.»

  Se quitan los textos de instrucción en pantalla. Se mantienen los avisos visuales (círculos, líneas y flechas rojas).
  - En la Vigía: «¡NO LE DES LA ESPALDA!» y «ESQUIVA AHORA».
  - En el Coloso: «SAL DEL CÍRCULO».
  - En el Hermano Mayor: «¡QUIETO!» y los avisos de sus reglas.
- **Inscripciones, susurros y diálogos más sutiles:** la mirada del VII, los Arietes y el Coloso del IX, los mastines del V, las raíces del IV y el Segador del III.
- **Misiones sin solución en el texto:**
  - «Derrota al Coloso»;
  - «Destierra a la Tejedora»;
  - «Libera al peregrino atrapado»;
  - «Resiste 45 s en la sala».
- **Coherencia:**
  - Las salas de los pisos I a IV se numeran como las demás (I-1, II-3…).
  - El Piso II ya no dice que «nadie llega acompañado» cuando el Peregrino sincero sigue contigo.
  - El Hermano Mayor:
    - te conoce por el Muro de los Nombres del Piso IV;
    - explica de dónde salen sus reglas: los hilos del Segador, la mirada de la Vigía y una Máscara de Porcelana repuesta para él, como la tuya;
    - su mirada sigue la misma regla que la del Piso VII (castiga alejarte o esquivar, no quedarte quieto).
  - La sala final ya no anuncia el final antes de la pelea.

## En `main` (sin nuevo release) — 2026-11-22 · Piso X (final del arco), tutorial de la Vigilia y habilidades por páginas

- **Piso X · La Cosecha**, el último piso del primer arco (cuatro salas):
  - **X-1 · Atrio de los Supervivientes**: el Hermano Mayor explica el ritual (tres braseros abren la Puerta).
  - **X-2 · Galería de los Braseros**: dos braseros, con un Ghoul atraído por la luz.
  - **X-3 · Coro de la Cosecha**: el tercer brasero, entre dos Arietes.

  Los braseros se encienden tocándolos o golpeándolos con la antorcha encendida.
  - **X-4 · Puerta de la Cosecha**: el **Hermano Mayor** (jefe) te traiciona para quedarse con tus almas. Usa tres reglas robadas, por turnos, con aviso:
    - **Hilos**: líneas rojas finas que, al tensarse, hacen daño (se esquivan).
    - **Rugido**: un círculo que se carga; al estallar hace daño. Después queda **agotado** 2,5 s y recibe el doble de daño.
    - **Mirada**: sus ojos brillan; si te mueves mientras te mira, te hace daño.

    Por debajo de la mitad de vida va más rápido y tensa un hilo más.
  - **Tus aliados deciden** según tu marca:
    - con bendición luchan contigo (le quitan vida cada pocos segundos);
    - con maldición se unen a él (tiran piedras con aviso, y él tiene más vida);
    - sin marca se apartan.
  - **Final**: la Puerta no lleva a la salida, sino a otros escalones. Pantalla «Fin del primer arco»: «Esto no es una salida. Es una transición.». La verdad 8: doscientas marcas de alas.
  - En el menú de pisos, el Piso X aparece con una calavera.
- **Tutorial guiado de la Vigilia** (15 pasos). La primera vez, EMPEZAR lo lanza; desde la portada se puede saltar o repetir (T o Y). Cada paso señala dónde tocar y espera a que lo hagas:
  1. bienvenida;
  2. dormir;
  3. ahorrar ecos;
  4. construir un centinela;
  5. ver cómo dispara a una entidad;
  6. mejorarlo;
  7. construir un generador;
  8. potenciar;
  9. construir una campana;
  10. reforzar la puerta;
  11. repararla;
  12. activar el escudo;
  13. mejorar el lecho;
  14. vender;
  15. empezar.

  Durante el tutorial el reloj de la fase no corre, la puerta no cae y el juego te da los ecos o la energía justos para cada paso. Al terminar empieza una Vigilia limpia.
- **Habilidades por páginas** (arreglo definitivo del desborde): cada columna muestra solo las filas que caben y el resto pasa a la página siguiente. Se cambia de página con las flechas en pantalla, ←/→, la rueda del ratón o la cruceta y LB del mando. Funciona igual por muchos Ecos o habilidades que se añadan.
- Valores provisionales: vida y daño del Hermano Mayor, ritmo de sus reglas y ayuda de los aliados.

## En `main` (sin nuevo release) — 2026-11-21 · Vigilia v3: construir en todo el suelo, más niveles y más dura

- **Más fácil de jugar, sobre todo en el móvil**:
  - se construye en **cualquier baldosa libre** de la celda (11 × 7, menos el lecho);
  - al tocar algo se abre un **menú junto a ello**:
    - una baldosa libre: construir;
    - una estructura: mejorar o vender;
    - el lecho: dormir o mejorar;
    - la puerta: reparar o reforzar;
  - el menú sigue abierto tras mejorar, con los precios nuevos, para subir varios niveles seguidos;
  - abajo quedan solo cuatro botones grandes: dormir, reparar, potenciar y escudo; la pausa pasa arriba;
  - con teclado o mando, un recuadro recorre las baldosas (a la derecha del todo, la puerta). Enter o A abren el menú, izquierda y derecha eligen, y 1-3 eligen directamente.
- **Estructura nueva: la campana**. Su tañido frena a las entidades del pasillo y sus golpes (5 % por nivel, hasta el 45 %).
- **Muchos más niveles**, con costes que suben cada vez más:
  - lecho 20;
  - puerta 20;
  - cada estructura 15;
  - poder de los centinelas 15.

  Cada centinela, generador o campana extra cuesta más que el anterior. Vender devuelve la mitad de lo gastado.
- **Entidades más duras**:
  - más vida desde la fase 1 (unas 1,6 veces);
  - la vida crece más rápido con cada fase;
  - los jefes tienen 5 veces la vida normal y el Ariete se une a las entidades y los jefes;
  - el daño a la puerta crece cada vez más;
  - hasta 6 entidades a la vez;
  - reparar cuesta más cuanto más reforzada está la puerta.
- Iconos nuevos originales: campana y vender (`herramientas/generar_iconos.py`; los demás iconos no cambian).
- Valores provisionales. En la simulación, un jugador automático que construye y mejora sin parar cae hacia la fase 16, sin llegar a subir todo al máximo.

## En `main` (sin nuevo release) — 2026-11-21 · Tanda C: Piso IX, jefes y enemigos más fuertes

- **Piso IX · El Coloso del Pórtico** (cuatro salas: Nave de los Arietes, Galería Agrietada, Pórtico del Coloso y Vitral Roto).
  - **Arietes de Piedra** (enemigo nuevo, sprite original): golems con cuernos, de piedra. Si te alineas con uno en horizontal o vertical se prepara 0,6 s (línea roja) y embiste en línea recta (28 de daño y empujón). Si choca contra un muro o una columna queda aturdido 2 s, y solo entonces se rompe con golpes.
  - **El Coloso** (jefe, sprite original): estatua viva inmune a golpes y a la Resonancia. Pisotón con aviso (círculo rojo, 32 de daño). Hay que atraerlo junto a una de las cuatro **columnas agrietadas** y golpearla: cae sobre él. Tres columnas lo derriban; con cada una camina y pisa más rápido. Barra de jefe con tres segmentos.
  - **Eco Fuerza acumulada**: el golpe hace un 4 % más de daño por cada Eco que tienes.
  - **Verdad**: tras el vitral roto, un ala inmensa; el dueño del templo es un ángel caído.
- **Enemigos más fuertes cuanto más abajo**: Ghoul, Testigo, Hechicero, Segador, Tejedora, mastines y la Vigía tienen +12 % de vida y daño por cada piso de profundidad (el Ghoul y el Testigo del Piso VIII son casi el doble de duros que los del Piso I).
- **Reestructuración, primer paso**: los datos de los pisos, las conversaciones y las verdades pasan a `scripts/datos/pisos.gd`. Plan para separar el resto en escenas en `docs/ARQUITECTURA.md`.
- Arreglo: el ataque de la Vigía ya no aplicaba dos veces la reducción de Piel curtida.
- Valores provisionales (vida y velocidad de Arietes y Coloso, radio de las columnas, escalado por piso).

## En `main` (sin nuevo release) — 2026-11-21 · Tanda B: Vigilia por fases con botín

- **Nuevo aspecto** (estilo de defensa de cuarto, con arte e interfaz propios):
  - la celda en planta sobre una rejilla de baldosas, con alfombra, velas, lecho con dosel y puerta con barra de vida y nivel en puntos;
  - el pasillo oscuro por donde llegan las entidades;
  - barra superior con la fase, el tiempo, los ecos y la energía;
  - ocho botones grandes abajo con icono, nombre y coste;
  - se puede tocar el mundo: el lecho para dormir, una casilla vacía para construir un centinela y la puerta para repararla.
- **Fases sin fin** de 90 s. Ecos, defensas y mejoras se conservan entre fases; la puerta recupera un 25 %. Cada fase es más dura:
  - las entidades tienen más vida (crece cada vez más rápido), más velocidad y más daño;
  - llegan más a la vez (hasta 5);
  - van apareciendo el Mastín, el Segador y la Tejedora;
  - **cada 5 fases hay un jefe** (más grande, con 4 veces más vida y el doble de daño).
- **Botín para la campaña**: cada fase superada da un objeto al azar (dos en las de jefe), que se guarda en el progreso del personaje.
  - Fases 1-2: pan y caja de fósforos.
  - Desde la 3: vial de sangre e incienso.
  - Desde la 5: bolsa de almas y mejoras del brazalete o el amuleto.
  - Desde la 7: mejora de la Resonancia y reliquia de experiencia.
  - Los de la bolsa se usan desde la pestaña OBJETOS del perfil.
- Récord de la mejor fase. Mando: cruceta, A, START (pausa) y B (salir).
- Valores provisionales (curva de dificultad y probabilidades del botín).

## En `main` (sin nuevo release) — 2026-11-21 · Tanda A: objetos, mejoras, marca y menús

- **Menú**: se quita EXPLORAR. JUGAR abre el menú de pisos (el Piso I empieza desde el principio, con intro y tutorial la primera vez). Hay un botón SALIR.
- **Confirmación al salir**: cerrar la ventana, pulsar «Atrás» en Android, SALIR o ESC en el menú preguntan «¿Salir del templo?». Es una escena de interfaz propia (`scenes/confirmar_salida.tscn`, autoload `ConfirmarSalida`) que pausa el juego y funciona con ratón, toque, teclado y mando.
- **Pestaña OBJETOS en el perfil** (tecla O, botón Y o tocar la pestaña): lo equipado con su nivel (Brazalete, Amuleto, Máscara) y la bolsa. El pan ya no se come al comprarlo: va a la bolsa y se usa desde ahí (+50 de vida, vigor lleno y +10 de vida máxima perdida). La bolsa se guarda.
- **Mejoras con almas**: comprar otra vez el Brazalete o el Amuleto los sube de nivel (+10 % por nivel, hasta el 5; 12, 24, 36... almas). La Resonancia se mejora hasta el nivel 5 en el altar o en el puesto (10 + 8 por nivel).
- **Puesto del Mercader**: cada fila muestra cuánto llevas (LLEVAS ×N o NV N). Al comprar, el número salta y la fila brilla. Cinco filas: pan, fósforos, brazalete, amuleto y mejorar Resonancia.
- **Vida extra**: curarse con la vida llena suma hasta +50 por encima del máximo. Se ve en dorado en la barra y no se regenera.
- **Relicarios de vida**: en las salas sin entidad (las que quedan entre encuentros) hay una máquina de latón con un vial de sangre. Cura 60, una vez por sala y partida.
- **Bendición y maldición** (se guardan):
  - Suman: liberar a Saúl, aceptar guiar al grupo y calmar a un peregrino.
  - Restan: salir de una sala dejando atrás a quien pedía ayuda o guía, no llegar a calmar a un peregrino y atacar a un Peregrino sincero (−2).
  - Con +2 llevas la **bendición** (placa BEN y motas doradas): el Peregrino del Piso II traiciona la mitad de veces, el grupo del Piso VI te regala un pan y el Mercader cobra un 20 % menos.
  - Con −2 llevas la **maldición** (placa MAL y humo carmesí): el Peregrino siempre traiciona, el grupo se niega a seguirte, los aliados caminan lejos de ti y el Mercader cobra un 20 % más.
- Valores provisionales (precios, curas, umbrales de la marca).

## En `main` (sin nuevo release) — 2026-11-21 · Piso VIII: El Templo que Cambia

Las salas del Piso I, alteradas para que creas saber qué hacer. Cuatro salas: Umbral que no recuerdas, Sala del Testigo, Archivo que se reescribe y Pórtico que no es el mismo.
- **Todo mira al otro lado**: estatuas y objetos aparecen en espejo (campo `mirror` del piso).
- **Pista falsa**: una inscripción firmada con tu nombre dice que el sello sigue en la Sala del Testigo y que te quedes quieto. Las dos cosas son mentira.
- **Testigo invertido** (campo `inverted`): con el ojo abierto persigue al que se queda quieto; moverse lo frena. Hay que reunir las almas de su sala. Misión opcional: desterrarlo.
- **El sello está en el Archivo**, custodiado por un Ghoul de brasas. Una carta con tu letra avisa de no fiarse de las inscripciones.
- **Verdad del piso**: el edificio es un sistema de producción; el miedo entra, las almas salen.
- **Eco Memoria de eco**: ves tu silueta donde moriste en otras vidas (hasta 3 por sala). Las muertes se recuerdan con el progreso.

## En `main` (sin nuevo release) — 2026-11-21 · Arreglo: la Máscara de Porcelana reaparece

- Al volver al Piso V con la Máscara ya conseguida, la puerta de los Canales de Almas quedaba cerrada para siempre: la máscara no volvía a su pedestal y la misión obligatoria no se podía cumplir. Ahora la máscara está en el pedestal en cada visita hasta que la recoges en esa partida; si ya la llevabas, solo abre la puerta.

## En `main` (sin nuevo release) — 2026-11-21 · Niveles, Piso VII y móvil

**Niveles del personaje**
- Experiencia por recoger almas (2), aplastar alimañas (3), calmar a un peregrino (10), desterrar entidades (25), cumplir misiones (8 + el premio) y superar pisos (30).
- Cada nivel: +6 de vida máxima, +4 % de daño (golpe y Resonancia), +3 % de recarga del vigor, y te cura. Nivel máximo 20; cada nivel pide 20 XP más que el anterior.
- Placa «NV» en el retrato del HUD, barra de experiencia bajo las barras, rótulo al subir y nivel y experiencia en el perfil. Se guarda con el progreso; si el alma es absorbida, la persona nueva empieza en el nivel 1.

**Piso VII · La Que No Aparta la Vista** (cuatro salas: Antesala de los Ojos, Sala de la Mirada, Coro de los Ciegos y Umbral del Octavo)
- Entidad nueva (sprite original): yelmo cerrado del que cae sangre y una hilera de ojos en el pecho. Rodea la sala y no se la puede herir.
- **Regla**: solo ataca si la provocas: darle la espalda más de 0,7 s o esquivar (correr). Avisa medio segundo con los ojos rojos; esquiva entonces. Provocarla resta 6 s de mirada.
- **Misión**: aguantar su mirada 45 s (Sala de la Mirada) y 60 s mientras recoges almas (Coro de los Ciegos). Medidor arriba y flecha hacia ella cuando le das la espalda.
- **Provocaciones**: amagos sin aviso rojo (si esquivas, la provocas) y ruidos a tu espalda.
- **Los peregrinos que guiaste en el Piso VI bajan contigo.** A mitad de la prueba uno entra en pánico: tienes 4 s para calmarlo (acción a su lado). Si no, echa a correr y ella se lo lleva. Los que llegan al Umbral te dan almas y siguen guardados.
- **Eco Mente serena**: el miedo al máximo ya no te hace daño.

**Móvil**
- Joystick flotante: la base se coloca donde apoyas el pulgar en la mitad izquierda.
- Botones en abanico a la derecha, al alcance del pulgar: **ACCIÓN** grande, LUZ, ESQUIVA y ONDA. ACCIÓN cambia según lo que tengas cerca (COMPRAR, GUIAR, CALMAR, PUERTA, LEER, ALTAR, SELLO o GOLPE) y brilla cuando hay algo con qué interactuar. La LUZ muestra los fósforos que quedan.
- En pantalla táctil, las etiquetas del mundo ya no muestran teclas, son más grandes y los avisos también. Las ayudas de los menús (pisos, muerte, resumen, perfil, puesto, diálogos, creación del personaje) hablan de toques.
- Sin el panel del arma en móvil: su información está en los botones.
- Perfil: caben los diez Ecos y el botón HABILIDADES se movió abajo.

## En `main` (sin nuevo release) — 2026-11-21 · Piso VI: La Ofrenda

Piso de respiro, sin entidades. Cuatro salas: Atrio de los Guías, Puesto del Mercader, Refectorio Vacío y Escalera del Séptimo.
- **Guiar al grupo** (Atrio): Irene, Teo y Bas piden que los guíes; Saúl va con ellos si lo salvaste en el Piso V. Habla con Irene para aceptar (misión opcional). Te siguen por el piso y, si llegan contigo a la escalera, te dan 3 almas cada uno y quedan guardados para el Piso VII.
- **El Mercader Silencioso** (sprite original: figura alta encapuchada, sin rostro). Puesto completo junto a su cuenco: **pan de ceniza** (vida, vigor y 10 de vida máxima perdida), **fósforos ×3**, **Brazalete de bronce** (+10 % al golpe) y **Amuleto de hueso** (+10 % a la recarga del vigor). Los dos objetos se guardan con el progreso y aparecen en el perfil.
- **Regla del manto**: se paga primero y no se toca. Algo brilla bajo su manto; meter la mano cuesta 25 de vida máxima en esta vida. Si guías al grupo, Teo lo intenta al entrar y lo paga.
- **Refectorio Vacío**: un mendrugo de pan (+40 de vida) y la verdad del piso: el miedo y la desesperanza alimentan algo.
- **Eco Huesos firmes**: una vez por piso, un golpe mortal te deja con 1 de vida.
- Iconos nuevos: Huesos firmes, pan, brazalete y amuleto. Las etiquetas «[E]» de los objetos muestran el botón del mando cuando lo usas.
- Valores provisionales (precios, vida máxima perdida, almas del grupo).

## En `main` (sin nuevo release) — 2026-11-21 · Mando de Xbox y similares

- **Soporte de mando** (Xbox 360, Xbox One/Series, PlayStation, Switch Pro y otros que reconoce Godot): stick o cruceta para moverse, A interactuar/golpear, RT golpe, B o LT esquivar, X antorcha, Y Resonancia, LB perfil, RB habilidades, START pausa.
- Todos los menús se recorren con la cruceta o el stick (con repetición al mantener): inicio, pisos, pausa, configuración (LB/RB cambian de pestaña), altar, perfil, diálogos (A avanza, Y salta) y resumen del piso.
- **Nombre con mando**: la cruceta mueve un recuadro por las letras en pantalla; A escribe, X borra, Y elige un nombre al azar y START sigue.
- Los textos de ayuda (HUD, tutorial, habilidades, menú) muestran los botones del mando cuando es lo último que usaste, y las teclas cuando vuelves al teclado.
- Aviso al conectar o desconectar el mando; si se desconecta en plena partida, el juego se pausa.
- **Vigilia**: la cruceta elige la acción, A la usa y B sale.
- Esquema del mando en *Configuración > Controles* y en el README.

## En `main` (sin nuevo release) — 2026-11-21 · Piso V: El Laberinto de los Mastines

Cuatro salas: Corredor de los Relicarios, Galería del Manto, Perrera de Bronce y Canales de Almas.
- **Laberinto**: muros bajos de sillares con musgo (campo `walls` de cada sala) que bloquean el paso y forman corredores.
- **Mastines de Relicario** (sprite original: bronce y máscara de porcelana agrietada): son inmunes y no sienten dolor. **Temen al fuego**: con la antorcha encendida guardan dos casillas de distancia y rondan gruñendo; a oscuras cargan y muerden (20). Un golpe de antorcha los aparta y la Resonancia los hace huir. Sus máscaras reflejan la luz y se ven en la penumbra.
- **La antorcha se consume** en este piso: 25 s por fósforo, con una barra bajo el arma. Al apagarse hay que volver a encenderla.
- **Peregrino atrapado** (Galería del Manto): su manto quedó bajo una reja. Golpéala para liberarlo: Saúl te da dos fósforos y queda guardado entre los aliados salvados, para el Piso X. Misión opcional.
- **Máscara de Porcelana** (Canales de Almas): misión obligatoria. Convierte tu Resonancia en **Rugido**: más alcance y espanta a los mastines 5 s. Se guarda con el progreso.
- **Canales de almas** en el suelo por donde corren motas azules: la verdad del piso es que las almas no se pierden, el templo las recoge.
- **Eco Paso ligero**: +5 % de velocidad.
- Sonido nuevo: gruñido con resonancia de bronce.
- Los títulos de piso largos ya no se cortan en el cartel.


## En `main` (sin nuevo release) — 2026-11-21 · Piso IV: El Claustro Enraizado

Cuatro salas: Atrio de las Raíces, Claustro Enraizado, Jardín de Ceniza y Muro de los Nombres.
- **Enredaderas que arden**: un golpe de antorcha prende las secas (gasta un fósforo, salvo con Llama Interior) y el fuego salta a las vecinas cada 0,3 s; cada tramo arde 3,6 s y queda en ceniza con brasas. Lo que pisa el fuego se quema, tú incluido (esquivando lo cruzas sin daño); las alimañas también. Las secas vuelven a crecer a los 14 s.
- **Raíces vivas en la puerta** (Atrio): no prenden con la antorcha; hay que hacerles llegar el fuego desde las secas.
- **Tejedora de Raíz** (sprite original): criatura de corteza que te persigue rodeando columnas, alza las garras 0,65 s y da un zarpazo (22). Los golpes y la Resonancia apenas la marcan (18 %); el fuego la consume. Misión de sala: quemarla.
- **Muro de los Nombres**: entre cientos de nombres grabados aparece el tuyo (verdad del piso: otros también vuelven).
- **Eco Piel curtida**: recibes un 25 % menos de daño.
- Sonidos nuevos: fuego que prende y raíces que crujen. Conversaciones internas al entrar.
- El menú de pisos ya permite elegir el IV.
- Valores provisionales (vida 110, daño, tiempos de fuego).


## En `main` (sin nuevo release) — 2026-11-21 · Saltar diálogos y volver a la pausa

- Botón **SALTAR (ESC) »»** sobre el cuadro de diálogo y en la intro; se puede pulsar con el ratón o tocar en el móvil. ESC sigue saltando.
- El **perfil** y las **habilidades** recuerdan desde dónde se abrieron: si fue desde la pausa, ESC (o cerrarlos) vuelve a la pausa; si fue jugando, vuelve al juego. Pasar del perfil a las habilidades conserva el origen.


## En `main` (sin nuevo release) — 2026-11-21 · Etapa 3: lo aprovechable del primer juego (*Craving Candy*)

- **Alimañas del osario** (sprite original): patrullan entre dos puntos y dan media vuelta; si te huelen cerca se lanzan y muerden (6). Mueren de un **esquive** (como el dash del primer juego), de un golpe de antorcha o de Resonancia, y sueltan 1 alma. En la Nave del Agua y el Umbral del Tercer Piso salen de un **nido** y reaparecen a los 9 s. Sus ojos rojos brillan en la oscuridad. Están en el Pórtico, la Nave del Agua, el Umbral del Tercer Piso y el Claustro del Encargo.
- **El cuerpo de tu vida anterior**: al morir, tu cuerpo queda tendido en la sala, con su charco de sangre. Tocarlo devuelve almas (2 en el modo sin pérdida; la mitad de las perdidas en el modo canónico) y una frase de tu personaje.
- **Transiciones con máscara** (máscaras originales recreadas, `herramientas/generar_transiciones.py`, `shaders/transicion.gdshader`): nubes de humo al morir, estallido desde el centro al reaparecer, barrido al terminar un piso y espiral al entrar en el siguiente, con un filo del color de las almas.
- **Resumen del piso** (como «nivel completado»): tiempo, almas ganadas, muertes, misiones, alimañas aplastadas, aliados con vida, Eco despertado y la **verdad** que revela el piso.
- **Contador de almas de la sala** («SALA 2/3») en la esquina de la sala, y **la puerta se abre con un estallido de luz y una campana** cuando cumples lo que pedía.
- **Sonidos de Kenney** (CC0, los mismos del primer juego): pasos sobre piedra, campanas (misiones, piso nuevo, tañido al morir), metal de los pinchos, vidrio al reunir almas y al desterrar, golpes y cuerpos. Cada grupo tiene varias tomas que se eligen al azar con el tono algo distinto.
- **Cursor gótico** propio (estilete dorado con gema de alma) y chispa dorada al hacer clic.
- **Pantalla completa** en Configuración › Sonido.
- **Controles táctiles de Kenney** (CC0) para el joystick y los botones, teñidos con la paleta; los botones muestran cuánto vigor les falta.
- **Créditos** en Configuración › Privacidad: autoría, recursos de terceros con su crédito y la dedicatoria del primer juego («En memoria de Leudy Antonio Mendez»).


## En `main` (sin nuevo release) — 2026-11-21 · Esquivar y Resonancia se recargan con el vigor

- Esquivar y Resonancia ya no tienen un reloj de recarga propio: están listas en cuanto la barra de vigor cubre su coste (el vigor se llena a 16 por segundo). Esquivar cuesta 28 (unos 1,75 s de barra) y Resonancia 40 (unos 2,5 s); antes, 2,65 s y 8 s.
- En el panel del arma hay un botón de Esquivar junto al golpe y Resonancia; los tres muestran como un reloj el vigor que les falta. Las letras de los botones siguen las teclas configuradas.
- El Eco Reflejos ahora abarata Esquivar un 40 % (antes acortaba su recarga).


## En `main` (sin nuevo release) — 2026-11-21 · Etapa 2: dirección de arte y menú de pisos

**Menú de pisos** (botón PISOS del menú o tecla P): los diez pisos del diseño como tarjetas con su número gótico, nombre, Eco y estado (superado, disponible, sin alcanzar, en las profundidades). Se puede empezar directamente en cualquier piso ya alcanzado, con antorcha y fósforos. El piso más profundo alcanzado se guarda (las partidas antiguas lo deducen de sus Ecos).

**Dirección de arte** (dark fantasy gótico, sin cambiar sprites ni reglas):
- Paleta: negros profundos, carbón, dorado envejecido, violeta oscuro y carmesí en toda la interfaz.
- Rótulos con **Jacquard 24** (gótica de píxel, OFL) en el título, pisos, perfil, habilidades, pausa, configuración y muerte; el texto corrido sigue en Pixelify Sans.
- Paneles translúcidos con filete fino y esquinas ornamentadas; barras en degradado con brillo y marcas; botones del menú que crecen y brillan al pasar el cursor.
- **Postproceso** (`shaders/postproceso.gdshader`, compatible con OpenGL): bloom moderado de almas, fuego y velas; gradación (sombras violeta, luces doradas); viñeta que se cierra con el miedo y grano leve. Solo dentro de la sala: el HUD queda nítido. Sin bloom en móvil.
- **Atmósfera**: haces de luz desde los ventanales con polvo que brilla, niebla baja en dos capas (`assets/visual/fx/niebla.png`, `herramientas/generar_niebla.py`), polvo y brasas suspendidos (más brasas en pisos gastados).
- **Efectos**: polvo al pisar y al esquivar con estela espiritual; chispas y sangre al herir; sangre al recibir daño; destellos al reunir almas; disolución violeta al desterrar; al morir, el alma se desprende en motas y un estallido carmesí; al reaparecer, una columna de luz. Fundido al cruzar de sala y temblor de cámara suave.


## En `main` (sin nuevo release) — 2026-11-21 · Etapa 1: diálogos, misiones, trampas y habilidades

- **Diálogos con clic**: lo que dicen el Peregrino y los aliados aparece en un cuadro inferior con el nombre de quien habla; el texto se escribe solo y avanza con clic, E, Enter o Espacio (el primer clic muestra la frase entera; ESC salta la conversación). El juego se detiene mientras lees. En pleno combate se usa un bocadillo que dura según lo largo de la frase.
- **Conversaciones** al entrar en salas con más personajes (Piso II con el Peregrino; Piso III con Odón, Bruna y Ciro). Quien ha muerto no habla.
- **Misiones de sala** en las salas con monstruo, con premio en almas y aviso «MISIÓN CUMPLIDA»: desterrar al Ghoul (obligatoria), al Testigo (opcional), al Hechicero (obligatoria), herir al Segador hasta que huya y matarlo. Las obligatorias mantienen la puerta cerrada.
- **Respiro**: tras 4 s sin recibir daño, la vida se recupera (2 por segundo), salvo con el miedo al máximo.
- **Esquivar estando quieto**: el impulso sale hacia donde miras; durante el impulso mantiene su dirección.
- **Pantalla de HABILIDADES** (tecla K, botón del libro bajo la pausa, desde el perfil o la pausa): activas y propias con su tecla, coste y descripción; Ecos con su piso de origen. La acción es reasignable en Controles.
- **Perfil**: los Ecos ya no se salen del cuadro; ahora son iconos (caben los diez pisos) y al señalarlos se lee su descripción. Botón a Habilidades.
- **Trampas de pinchos** (del primer juego del autor): asoman, tiemblan y suenan antes de herir (18). Esquivar te hace pasar por encima. En el Pórtico (Piso I), la Nave del Agua (Piso II) y el Coro Desgarrado (Piso III).
- **Inscripciones** de lore que se leen al acercarse (también del primer juego: los carteles). En el Pórtico, la Nave del Agua y el Claustro del Encargo.
- Pruebas nuevas: diálogo que se cierra con clic, misión que bloquea y premia, esquivar quieto, regeneración, pinchos (y su inmunidad al esquivar) y pantalla de habilidades.


## En `main` (sin nuevo release) — 2026-11-21 · Personaje propio, muerte sin pérdida y Piso III

**Creación del personaje**
- Al explorar por primera vez: **nombre** (teclado físico o letras en pantalla, hasta 12 caracteres, con Ñ y tildes; botón «al azar») y luego **género** (masculino o femenino) con vista previa animada y retrato.
- Variante femenina original del sprite (`assets/visual/protagonist_sheet_f.png`: melena larga, hombros más estrechos, abrigo más largo) y de los retratos (`femenina.png`, `femenina_herida.png`). Las hojas masculinas no cambian.
- El nombre sustituye a «MARK» en el HUD, el perfil, el menú y la pantalla de muerte. Se guarda con el progreso. En el menú, «CAMBIAR (C)» vuelve a la creación (conserva el progreso).

**Muerte sin pérdida (temporal)**
- Con `MUERTE_SIN_PERDIDA = true` (por defecto, mientras se prueban los pisos), morir te levanta en la entrada de la misma sala con la vida llena y todo lo que llevabas: almas, objetos, habilidades, Ecos, entidades desterradas y almas ya recogidas (no reaparecen). En `false` vuelve el 50 % retorno / absorción.
- Ir al menú desde la pantalla de muerte y volver a explorar sigue empezando una partida nueva.

**Piso III · La Cacería** (4 salas: Claustro del Encargo, Nave de los Hilos, Coro Desgarrado y Umbral del Cuarto Piso)
- **Segador de Hilos** (sprite original, 4 direcciones): ronda rápido a media distancia; antes de atacar **tensa** una línea roja durante 0,9 s y dispara: lo que esté en la línea recibe 45 de daño (esquivar a tiempo lo evita). Atraviesa el sitio donde estabas y queda **enganchado** 1,6 s: solo entonces es vulnerable. Las columnas te cubren. Aturdirlo con Resonancia mientras tensa rompe el ataque.
- En la Nave huye a media vida (conserva sus heridas); en el Coro hay que matarlo. La puerta no se abre mientras la presa viva.
- **Tres aliados** (Odón, Bruna y Ciro) te siguen por el piso y reaccionan tarde a veces: si la línea los alcanza, mueren y dejan su cuerpo. Los que lleguen al Umbral te dan +6 almas cada uno y 3 fósforos.
- **Eco Reflejos**: esquivar se recarga un 40 % antes.
- Sonidos nuevos: hilos que se tensan y latigazo.
- Valores provisionales (vida 140, daño, tiempos): ajustar tras probarlo.

**Pruebas**: creación por toques (nombre y género), reaparición sin pérdida, y Piso III (aliados, puerta cerrada, inmunidad, línea que hiere a jugador y aliado, enganche, huida con heridas, recompensa y Reflejos).


## En `main` (sin nuevo release) — 2026-11-21 · Inicio, configuración, intro, tutorial y pausa

- **Pantalla de inicio** al abrir el juego: «Haz clic para continuar» (o toca), con el engranaje de **Configuración** abajo a la izquierda. Al volver de la Vigilia se va directo al menú.
- **Acuerdo de usuario** la primera vez (aceptar, leer completo o salir). Textos en borrador en `docs/legal/`.
- **Configuración** (desde el inicio, el menú o la pausa; ratón, teclado o táctil):
  - **Sonido:** volumen general, música y efectos (buses de audio propios) y silenciar.
  - **Controles:** las 10 acciones son reasignables (si una tecla ya estaba en uso, se intercambian); restablecer; controles táctiles Auto / Siempre / Nunca; repetir el tutorial y ver la intro.
  - **Idioma:** español / inglés. El inglés cubre por ahora los menús nuevos.
  - **Privacidad:** qué se guarda y dónde, acuerdo de usuario, política de privacidad y «Borrar mis datos» (con confirmación).
  - Los ajustes se guardan en `user://ajustes.cfg` (`scripts/ajustes.gd`), aparte del progreso.
- **Intro** de cinco escenas con texto que se escribe solo (clic para avanzar, ESC para saltar). Se ve la primera vez que exploras.
- **Tutorial**: sala de práctica antes del Piso I con 8 pasos guiados y un muñeco de entrenamiento. Los textos usan las teclas configuradas (o los botones táctiles). Al cruzar la puerta empieza el Piso I limpio.
- **Pausa** con ESC o el botón de pausa: continuar, configuración, perfil, saltar tutorial y volver a la pantalla de inicio (abandona la partida).
- Pruebas: arranque inicio → acuerdo → menú, configuración, tutorial (golpe al muñeco), pausa y salida al Piso I.

## En `main` (sin nuevo release) — 2026-11-21 · Estilo roguelike de acción

**HUD** (paneles biselados flotantes, como en los roguelike de acción tipo Soul Knight)
- Panel del jugador: retrato de Mark (con sangre y brecha cuando la vida baja del 35 %), barras de vida, vigor y miedo con icono, marcas cada 10 % y números. La barra de miedo late por encima del 70 %.
- Cartel del piso y la sala, y contador de almas con icono.
- Minimapa del piso: salas en cadena, la actual resaltada, una marca roja si hay una amenaza viva y una calavera al final del piso. Incluye un botón de pausa.
- Pie: misión en su panel; panel de arma con la antorcha y su «munición» (fósforos o Llama interior); habilidades redondas (golpe y Resonancia) con recuperación en forma de reloj.
- Tipografía pixel **Pixelify Sans** (OFL), sin suavizado, en todo el juego y en la Vigilia.

**Perfil** (antes, inventario): retrato grande, nombre e identidad, barras, estadísticas (daño, almas, muertes, retornos, absorciones, pisos superados), equipo y mochila, Ecos y descripción de lo señalado. En móvil se abre tocando el retrato.

**Salas con más detalle** (`herramientas/generar_decorados.py`): calaveras, huesos, costillares, vasijas rotas, velas encendidas que dan luz, charcos y regueros de sangre en el suelo; estandartes rasgados con el ojo del templo, cadenas, telarañas, manos ensangrentadas y goteos en el muro. Colocados en espejo y siempre iguales en la misma sala; cada piso tiene más sangre que el anterior. La oscuridad no se reduce.

**Menú y altar** con los mismos paneles; botones gruesos con icono.

## En `main` (sin nuevo release) — 2026-11-21 · Pisos y Piso II: Los Peregrinos

**Estructura de pisos**
- El juego se organiza en pisos (`FLOORS` en `scripts/main.gd`). Cada sala declara su escena, su entidad, sus rasgos y sus objetos; el código ya no depende de «la sala 2 es la del Testigo».
- Al cruzar la última puerta de un piso aparece la **pantalla de entrada** del siguiente (GDD §7), con solo una vista parcial de la sala.
- **Ecos**: pasivas acumulables que se ganan al superar cada piso. *Respiración contenida* (Piso I: el miedo sube un 25 % más despacio) y *Nuca fría* (Piso II: notas a quien te quiere mal cuando está a tu espalda). Se guardan, se conservan si el alma regresa y se pierden si es absorbida. Se ven en el inventario.
- Desgaste progresivo: el Piso II tiene grietas, cascotes y un tono más apagado.

**Piso II · Los Peregrinos** (cuatro salas)
- El **Peregrino**, un NPC original, te acompaña y compite por las almas. Hay que reunir las tres almas de cada sala para que la puerta se abra.
- En la mayoría de las vidas (70 %) es un **traidor**: se queda a tu espalda, va a por las almas a las que no te diriges y miente sobre cuántas lleva. Al reunir la última alma de la Cripta del Reparto desenvaina, avisa durante 0,9 s y ataca con tajos que se anuncian con un destello.
- Si es **sincero**, en la Cosecha te da agua (+30 de vida) y la mitad de sus almas.
- Atacarlo primero: el traidor lo admite; si era sincero muere sin entenderlo y el miedo se dispara.
- Al morir deja su cuerpo y sus almas.
- Arte original (`generar_enemigos.py`, celdas de 48 × 64) y sonido de cuchillo nuevo.

**Pruebas**
- Prueba de humo: paso del Piso I al II, Eco, aparición del Peregrino, puerta que exige las almas, traición en la Cosecha y muerte del Peregrino.

## En `main` (sin nuevo release) — 2026-11-21 · Puertas por contacto, cuerpos y salas simétricas

- **Puertas por contacto:** al tocar la puerta con la sala lista se pasa a la siguiente sin pulsar E (E sigue funcionando). Si está sellada, avisa de lo que falta.
- **Cuerpos bajo las almas:** cada alma flota sobre el cadáver de su antiguo dueño, con charco de sangre, salpicaduras y heridas. Tres variantes originales (`herramientas/generar_cuerpos.py`), algunas en espejo. El cuerpo se queda al recoger el alma.
- **Salas simétricas:** en las cinco salas los objetos van en el eje central (x = 480) o en parejas en espejo, y lo mismo las almas, la runa del suelo, el altar, la mesa, el sello y el ojo. Lo aplica `herramientas/simetrizar_salas.py`; las colisiones acompañan a cada objeto.
- Corregido el dibujo de los objetos volteados (se desplazaban un ancho a la derecha).

## En `main` (sin nuevo release) — 2026-11-20 · Antorcha, inventario y combate

**Antorcha e inventario**
- Se despierta a oscuras. En el Umbral hay **madera** y una caja de **5 fósforos**; con ambas cosas se construye la antorcha.
- **F** enciende la antorcha (gasta 1 fósforo) o la apaga (gratis). Conserva su estado entre salas. Hay cajas de +3 fósforos en la Sala del Testigo y en el Archivo.
- El altar vende **Llama interior** (10 almas): enciende la antorcha sin gastar fósforos. Se guarda y se pierde como Resonancia.
- Inventario con iconos en la barra superior y panel con descripciones (**I** o Tab; en móvil, tocar la barra superior).

**Combate**
- Todas las entidades tienen **barra de vida** (Ghoul 60, Testigo 90, Hechicero 70; provisional) y reciben daño.
- **Debilidades:** el Testigo solo con el ojo cerrado; el Hechicero solo mientras carga el conjuro (1 s visible); el Ghoul siempre. Sobre la entidad se lee INMUNE, VULNERABLE o ATURDIDO.
- **Golpe de antorcha** (clic, o E sin nada cerca): arco de fuego, 18 de daño, recuperación 0,6 s.
- **Resonancia** (Q): anillo visible que daña (30 + 10 por nivel) y aturde; recuperación 8 s.
- A 0 de vida la entidad se **disuelve** y deja almas (+10). Vuelve si mueres.
- Iconos de habilidades con su recuperación en la parte inferior derecha.

**Vista cenital y arte**
- Protagonista redibujado (`herramientas/generar_protagonista.py`): coronilla y hombros iluminados, cartera, bufanda animada; lleva la antorcha en la mano.
- Entidades con más detalle: grietas, musgo, cadena y halo roto en el Testigo; chispas y hombros iluminados en el Ghoul; ribetes y runas en el Hechicero. Luz cenital en el contorno superior.
- Salas con profundidad: cara del muro del fondo con luz arriba y sombra al pie, sombra proyectada sobre el suelo y remates iluminados en los demás muros.

**Sonido**
- Pasos (tres variaciones), fósforo, apagar, recoger objeto, golpe, impacto, inmune, Resonancia, destierro, interfaz y toque sin respuesta.

**Vigilia**
- Un solo modo (se fusionan las tres cámaras) con portada «toca para comenzar».
- Botones de imagen (`herramientas/generar_iconos.py`) con su descripción al pasar el cursor o al tocarlos.

## En `main` (sin nuevo release) — 2026-11-20 · Almas por contacto, luz, avisos y audio original

**Jugabilidad**
- Las almas se recogen al tocarlas (antes había que pulsar E), con anillo de luz, «+7» ascendente, pulso del contador y sonido propio. El sello, la carta, el altar y las puertas siguen con E.

**Sensación de juego (sin cambiar reglas)**
- Penumbra dinámica: la linterna del personaje, los braseros, las almas, los conjuros, el altar y la salida abierta iluminan; las entidades siempre se distinguen. Nunca negro total. Con miedo alto se oscurecen los bordes.
- Avisos justos: el ojo del Testigo tiembla, muestra una rendija roja y cruje 0,6 s antes de abrirse; el Hechicero carga un orbe visible antes de lanzar.
- Daño legible: sacudida de pantalla, destello rojo que se apaga y parpadeo del personaje durante la invulnerabilidad.

**Audio original** (`herramientas/generar_audio.py`)
- Ambiente del templo en bucle sin cortes, capa de tensión adaptativa (latido y cuerdas disonantes) y diez efectos por evento, en la campaña y en Vigilia.
- Retirados `audio/ambient.wav` y `audio/chime.wav`, sustituidos por los nuevos.

## En `main` (sin nuevo release) — 2026-11-20 · Todos los objetos son sólidos

- Braseros, estatuas orantes y estatuas del arquero ya no se atraviesan: tienen colisión en su base (pedestal o pie), como el resto de objetos. Se puede pasar por detrás de la figura y esta tapa al personaje.
- Al chocar con un objeto se levanta un poco de polvo a los pies (solo visual).
- `tests/visual_asset_test.gd` falla si algún objeto de una sala queda sin colisión.

## En `main` (sin nuevo release) — 2026-11-20 · Marco de las salas

- Marco de la sala rehecho y simétrico: muros completos que cierran en las cuatro esquinas con pilares de piedra, muro derecho igual al izquierdo, muro inferior que ya no sobresale, remate de piedra sobre el muro superior y sombra de los muros sobre el suelo.
- Eliminados la franja de suelo exterior con su línea gris, el filo suelto bajo el muro superior y los cuatro nichos con arco del muro superior.
- El menú y Vigilia usan el mismo marco (el menú muestra la escena de la sala; `vigilia.png` se genera ahora con `construir_salas.py`).

## En `main` (sin nuevo release) — 2026-11-20 · Salas editables, entidades originales y Vigilia

**Salas editables en Godot**
- Las cinco salas son escenas `rooms/sala_N.tscn`: arquitectura en `TileMapLayer` (atlas de 59 tiles de 32 × 32), objetos como `Sprite2D` con su colisión como hija, marcadores (`Jugador`, `Enemigo`, `Salida`, reliquias, altar, sello, ojo, libro) y la runa del suelo.
- `scripts/main.gd` lee de la escena posiciones, colisiones y objetos; ya no están fijos en el código.
- Luz y tinte por sala con `shaders/luz_sala.gdshader`; braseros con halo animado.
- Herramientas `herramientas/construir_salas.py` + `.gd` para regenerar desde las composiciones originales. Guía: `docs/EDITAR_SALAS.md`.
- Sustituyen a las capas `room_N_props.png` y a `scripts/room_props.gd` de la tanda anterior.

**Entidades originales cenitales**
- Testigo (creación de piedra con un solo ojo; el sprite muestra si el ojo está abierto o cerrado), Ghoul de brasas y Hechicero del archivo, en 4 direcciones, generados por `herramientas/generar_enemigos.py`.
- Miran hacia donde se mueven y, quietos, hacia el jugador. Los sprites de GothicVania se conservan como respaldo.

**Vigilia del Claustro como escena**
- Claustro despejado (`assets/visual/rooms/vigilia.png`), cámara con muros de sillares, luz cálida, lecho con durmiente, pedestales rúnicos para centinelas y puerta en el hueco del muro. Misma lógica y mismas zonas táctiles.

## En `main` (sin nuevo release) — 2026-11-20 · Pulido visual, segunda tanda

- Sin costuras donde la antigua cuadrícula cruzaba estatuas y columnas: el relleno copia el píxel vecino en vez de promediarlo.
- Altar del claustro legible: luz cálida de ofrenda, velas a los lados y sprite aclarado.
- Libro del archivo a 1,5× para que quepa en la mesa y sin glifos flotando sobre la estatua; la etiqueta desaparece tras leer la carta.

## En `main` (sin nuevo release) — 2026-11-20 · Pulido visual de la jugabilidad

**Fondos de sala**
- Eliminadas las guías de maquetación que quedaron pintadas en los cinco fondos: líneas de cuadrícula verdes y elipses negras separadas de los objetos. Eran píxeles semitransparentes del original que se volvieron opacos al aplanar la versión visual.
- Sombras de contacto suaves y coherentes pegadas a la base de cada columna, estatua y mueble.
- Borrado el trozo del fotograma vecino que aparecía junto a cada brasero.
- Nueva herramienta reproducible `herramientas/limpiar_fondos.py` (no toca `assets/knowledge/`).

**Profundidad y objetos**
- Ordenación por profundidad: personajes y enemigos que pasan por detrás de una estatua o columna quedan tapados por ella (capas `assets/visual/rooms/room_N_props.png` + `scripts/room_props.gd`, generadas por la herramienta).
- Reliquias como cristales de alma flotantes con sombra; sello del Testigo como círculo rúnico en el suelo.
- Ojo del Testigo tallado en el muro del fondo (ya no tapa una estatua) con su mirada proyectada cuando está abierto.
- Salida dibujada como vano en el muro derecho: losa con runas cuando está sellada y luz entrante cuando está abierta (antes era un sprite de muro estirado al doble de alto).
- Altar con proporciones reales, delante de la estatua del claustro; libro del archivo sobre la mesa, animado con `magic_book_sheet.png` tras leer la carta.
- Colisiones añadidas al altar, la mesa del archivo y el sarcófago (antes se podían atravesar). Verificado que todos los objetivos siguen siendo alcanzables.

**Enemigos**
- Escalas unificadas a partir de la caja útil de cada sprite; Ghoul y Wizard se voltean hacia el jugador; el Ángel flota sobre su sombra.
- Sombra suave en lugar del disco negro; alerta y aturdimiento como halos en el suelo en lugar de anillos dobles.

**Interfaz**
- Menú: corregidos los textos superpuestos y los textos que invadían los botones (las zonas táctiles no cambian).
- Partida: los mensajes flotan bajo la barra superior y ya no tapan los controles; la misión pasa a su propia fila del pie (en rojo cuando el ojo está abierto).
- Vigilia: lecho, puerta con herrajes y grietas por daño, centinelas de cristal, enemigos sin deformar y barra de vida siempre dentro de la pantalla.

Sin cambios en reglas, economía, IA ni controles: los seis tests pasan y el balance de Vigilia da la misma puntuación de referencia (2645).

## En `main` (sin nuevo release) — 2026-11-01

- Normalizado el marcador de compatibilidad de `project.godot` a Godot 4.3, conservando nearest-neighbor y la configuración móvil.
- Ampliado el test visual para validar las cinco salas, la hoja de nueve poses por dirección y los fotogramas finales de Angel, Ghoul y Wizard.
- Añadida auditoría automática de PNG/.import y `.gd.uid` no huérfanos, además de los recursos críticos.
- Protegida la inmutabilidad del APK de `v0.4.2-alpha`: GitHub Actions puede generar nuevos artefactos, pero no sobrescribe releases anteriores al hacer push.
- Actualizados el README, el informe visual y el registro de procedencia de la identidad gráfica.


## [0.4.2-alpha] — 2026-11-01

**Correcciones técnicas y compilación Android validada.**

- Reparado el ciclo de vida de los reproductores AudioStreamPlayer; se liberan streams al cambiar de escena y se evita reproducción innecesaria en headless.
- Eliminados los errores de recursos retenidos de audio WAV en las pruebas automatizadas.
- Las pruebas CI ya no ignoran errores de memoria, de importación ni de ejecución.
- Tests de identidad gráfica, sprites, controles táctiles y simulación completa de Vigilia.
- GitHub Actions actualizado a versiones compatibles con Node.js 24.
- Se publica APK Android con verificación de ZIP, firma y paquete/versión por AAPT.
- Pendiente: validar FPS y controles en teléfono físico.


## [0.4.1-alpha] — 2026-11-01

**Vigilia del Claustro ampliada y controles móviles depurados.**

- Emblema y banner originales SVG integrados en el proyecto y su README.
- Menú de dos opciones táctiles claras: Explorar o Vigilia.
- Ventajas diferenciadas de tres cámaras, generadores de energía, mejora de centinelas, escudo, pausa y récord local.
- Sprites Ghoul / Wizard / Angel con rotación por oleadas.
- Corrección de la bonificación de ingresos al mejorar el lecho.
- Nuevas pruebas de iconografía, economía, balance y supervivencia completa; empaquetado Android validado mediante AAPT, apksigner y ZIP.
- Pendientes: pruebas físicas de Android y avisos de recursos retenidos al terminar tests headless.

## [0.4.0-alpha] — 2026-11-01

**Primera preparación Android.**

- Joystick y controles táctiles experimentales para la campaña.
- Primer modo Vigilia: cama, puerta, torretas y oleadas.
- Exportación APK ARM64 de depuración mediante GitHub Actions.
- Correcciones de Android SDK, preset de exportación y ETC2/ASTC.


Formato: cambios relevantes por versión. Las versiones alpha son prototipos.

## [0.3.1-alpha] — 2026-10-16

**Mantenimiento, recuperación visual y publicación del prototipo fuente.**

- Restaurados los 65 metadatos de importación `.png.import` eliminados accidentalmente en el mantenimiento previo.
- Cambiada la carga dinámica por referencias explícitas a las texturas originales.
- Añadidas pruebas para verificar la carga de texturas Knowledge Temple y sprites GothicVania.
- Incorporada validación automática con Godot 4.3, con advertencia documentada sobre recursos retenidos al cerrar el test headless.
- Documentados los controles, el estado del prototipo, créditos/licencias y notas de release.
- **Sin nuevos pisos ni nuevas mecánicas definitivas:** esta versión no sustituye el diseño narrativo original.

## [0.3.0-alpha] — 2026-10-16

**Primer prototipo con assets originales.**

- Un piso de cinco habitaciones con misión y encuentros experimentales.
- Fondos construidos a partir de Knowledge Temple.
- Sprites de Angel, Burning Ghoul y Wizard de GothicVania Church Pack.
- Sistema experimental de almas, supervivencia y muerte/reencarnación 50/50.
- Documentación de decisiones del canon y mecánicas todavía provisionales.

[0.3.1-alpha]: https://github.com/je7remy/el-templo-de-los-ecos/compare/v0.3.0-alpha...v0.3.1-alpha
[0.3.0-alpha]: https://github.com/je7remy/el-templo-de-los-ecos/releases/tag/v0.3.0-alpha
