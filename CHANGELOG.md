# Historial de versiones

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
