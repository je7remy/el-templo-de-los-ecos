# Informe de integración visual — estado del repositorio

## 1. Diagnóstico
- Cinco habitaciones del primer piso son fondos RGBA ya compuestos (960 × 640): no hay generador procedural que corregir.
- El escenario es funcional en términos de rutas de recursos, pero el contraste original era muy bajo y tenía líneas de cuadrícula visualmente predominantes.
- El protagonista es provisional; enemigos de GothicVania están dibujados de perfil y se escalaban a dimensiones fraccionarias.
- La composición de HUD y título no seguía un criterio uniforme.

## 2. Mejoras realizadas
- Se generaron **cinco variantes no destructivas** bajo `assets/visual/rooms/`; conservan la arquitectura y posiciones originales.
- Regraduación de contraste y luminosidad; lámparas con halos suaves, signos de desgaste graduales, mosaico bajo los pies y reducción de la cuadrícula.
- Protagonista original, cuatro direcciones y nueve poses por dirección (dos de reposo, cuatro de caminata, interacción, daño y muerte).
- Render de enemigos a dimensiones nativas y capa de contacto al suelo. Los archivos originales y la IA permanecen intactos.
- Reorganización del HUD, panel de inicio y la presentación de las misiones; sin cambio de teclas ni balances.
- Efectos ambientales ligeros y nearest-neighbor.

## 3. Integridad de mecánicas
No se cambia `func _update_enemy`, `func _update_play`, `func _lose_run`, `func _new_run`, `func _room_ready` ni los archivos originales de enemigos. Se incorpora un contador **solo visual** para el fotograma de interacción y otro uso del temporizador de daño que ya existía.

## 4. Validación actual
- La actualización visual original está publicada desde el commit `9d3997c`, no se encuentra solo en un instalador local.
- `assets/visual/` conserva cinco fondos de 960 × 640 y una hoja del protagonista de 360 × 224, con nueve fotogramas de 40 × 56 por cada una de las cuatro direcciones.
- El pipeline Godot 4.3 ejecuta importación, prueba visual, campaña, Vigilia, controles táctiles, marca e incluso una simulación completa. El test visual también comprueba los fotogramas finales de Angel, Ghoul y Wizard.
- La retención de WAV que ocurría al terminar los tests antiguos se corrigió en `scripts/main.gd`; el workflow actual rechaza errores en lugar de permitirlos.
- Sigue pendiente comprobar manualmente animaciones, FPS y controles en Fedora 4.7.2 y en un teléfono Android real.

## 5. Evidencia
`docs/capturas/comparacion_room_2.png` compara dos texturas reales de habitación. Es una comparación de recursos, **no una captura tomada desde Godot**.

## 6. Pendientes reales
- Revisar en juego la alineación de pies, la caminata diagonal, las poses de daño y la legibilidad del HUD en pantallas distintas.
- Los cinco fondos siguen siendo composiciones, no TileMapLayer editables.
- Los enemigos GothicVania se dibujaron originalmente de perfil; sustituirlos por arte top-down exigiría recursos adicionales con permisos claros.
- Evaluar manualmente FPS, audio y comportamiento táctil en Android. Las pruebas sintéticas no equivalen a una partida física.

## 7. Publicación
El commit original de actualización visual fue `9d3997c`. El repositorio evolucionó posteriormente hasta `v0.4.2-alpha`, con campaña y Vigilia, APK de depuración, branding y mejoras de QA. La auditoría retrospectiva de `v0.3.2-alpha` no representa un release publicado y no debe revertir funcionalidades del `main` moderno.
