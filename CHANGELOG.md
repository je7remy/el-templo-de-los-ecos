# Historial de versiones

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
