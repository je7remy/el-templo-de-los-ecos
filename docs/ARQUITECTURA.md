# Arquitectura y plan de reestructuración

## Cómo está hecho hoy

| Pieza | Dónde | Estado |
| --- | --- | --- |
| Salas (suelo, muros, objetos, marcadores, colisiones) | `rooms/sala_N.tscn` | Escenas editables en Godot (buena práctica) |
| Datos de los pisos, conversaciones y verdades | `scripts/datos/pisos.gd` | Separado del código (Tanda C) |
| Ajustes del jugador | `scripts/ajustes.gd` | Script propio |
| Confirmación al salir | `scenes/confirmar_salida.tscn` + autoload `ConfirmarSalida` | Escena de interfaz real (Tanda A) |
| Botín de la Vigilia | `scripts/botin.gd` | Script propio (Tanda B) |
| Vigilia | `scenes/defense.tscn` + `scripts/defense.gd` | Escena propia, dibujo inmediato |
| Campaña: jugador, entidades, HUD, menús, tienda, diálogos | `scripts/main.gd` | **Un solo script grande** que dibuja con `_draw()` |

Dibujar a mano en `_draw()` es barato: hay pocos objetos y el juego va fluido. El problema no es el rendimiento, es el **mantenimiento**:
- `main.gd` concentra casi todo;
- las entidades y los menús no se pueden editar en el editor de Godot;
- dos cambios distintos tocan siempre el mismo archivo.

## Hacia dónde ir (por pasos, sin romper nada)

Cada paso se entrega con las pruebas en verde.

1. **Datos fuera del código** (hecho): pisos, conversaciones y verdades en `scripts/datos/pisos.gd`. Siguiente: precios, botín y textos en recursos (`Resource`, `.tres`) editables en el inspector.
2. **Progreso como autoload**: un nodo `Progreso` que cargue y guarde el personaje (nivel, ecos, bolsa, objetos, marca). Hoy lo hacen `main.gd` y `botin.gd` cada uno por su lado.
3. **Entidades como escenas**: cada enemigo en su `.tscn` con su script (`ghoul.tscn`, `ariete.tscn`, `coloso.tscn`…), con `Sprite2D`/`AnimatedSprite2D`, área de colisión y señales (`herido`, `muerto`). `main.gd` solo las instancia en la sala.
4. **Interfaz como escenas `Control`**: HUD, perfil, tienda, pausa y diálogos con `Container`, `Button` y un `Theme` común. Ganan foco de mando y teclado, escalado y accesibilidad sin código propio.
5. **Máquina de estados de pantallas**: cambiar el `game_mode` de texto por escenas o nodos por pantalla (`TituloScreen`, `PisosScreen`…).

Orden recomendado: 2 → 3 (empezando por los enemigos nuevos) → 4 → 5. Así cada piso nuevo ya nace como escena.
