# Historial de versiones

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
