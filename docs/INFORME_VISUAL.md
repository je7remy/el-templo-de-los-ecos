# Informe de integración visual — propuesta local, sin publicación

## 1. Diagnóstico
- Cinco habitaciones del primer piso son fondos RGBA ya compuestos (960 × 640): no hay generador procedural que corregir.
- El escenario es funcional en términos de rutas de recursos, pero el contraste original era muy bajo y tenía líneas de cuadrícula visualmente predominantes.
- El protagonista es provisional; enemigos de GothicVania están dibujados de perfil y se escalaban a dimensiones fraccionarias.
- La composición de HUD y título no seguía un criterio uniforme.

## 2. Mejoras realizadas
- Se generaron **cinco variantes no destructivas** bajo `assets/visual/rooms/`; conservan la arquitectura y posiciones originales.
- Regraduación de contraste y luminosidad; lámparas con halos suaves, signos de desgaste graduales, mosaico bajo los pies y reducción de la cuadrícula.
- Protagonista original, cuatro direcciones, ocho estados visuales/poses por dirección.
- Render de enemigos a dimensiones nativas y capa de contacto al suelo. Los archivos originales y la IA permanecen intactos.
- Reorganización del HUD, panel de inicio y la presentación de las misiones; sin cambio de teclas ni balances.
- Efectos ambientales ligeros y nearest-neighbor.

## 3. Integridad de mecánicas
No se cambia `func _update_enemy`, `func _update_play`, `func _lose_run`, `func _new_run`, `func _room_ready` ni los archivos originales de enemigos. Se incorpora un contador **solo visual** para el fotograma de interacción y otro uso del temporizador de daño que ya existía.

## 4. Validación
- Los originales conservados y las seis imágenes generadas tienen tamaños legibles y formatos PNG auténticos.
- La implementación usa rutas literales para precarga en la versión actual del repositorio.
- Este entorno de trabajo **no dispone del ejecutable de Godot 4**, por lo que no se ha ejecutado aquí una escena ni se ha comprobado la animación en pantalla en Fedora.
- La comprobación de código incluye anclas y condiciones de integridad antes de la escritura, pero la prueba definitiva de Godot deberá ejecutarse después de aplicar el paquete en la máquina del usuario.

## 5. Evidencia
`docs/capturas/comparacion_room_2.png` compara dos texturas reales de habitación. Es una comparación de recursos, **no una captura tomada desde Godot**.

## 6. Pendientes explícitos
- Asegurar que Godot importa `assets/visual/` y corre el script `tests/visual_asset_test.gd`.
- Ejecutar dos tamaños de ventana y jugar las cinco salas con enemigos visibles.
- Revisar la estética del nuevo protagonista in-engine (alineación de pies, caminata diagonal, frames de daño).
- Construir TileMapLayer real, sombras 2D nativas y una cámara opcional solo tras revisar colisiones.
- Rehacer sprites de enemigos top-down o contratar arte adicional con derechos claros para eliminar la disonancia de perspectiva.
- Corregir si existen, en una fase posterior, las advertencias previas de recursos retenidos al salir de Godot en modo headless.

## 7. Publicación
**Ningún commit, push, release o cambio de rama fue realizado**. El paquete se aplica únicamente mediante un instalador con respaldo externo. No se sustituyen los datos originales al preparar las nuevas variantes.
