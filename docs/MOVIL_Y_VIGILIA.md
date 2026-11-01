# Móvil Android y modo Vigilia del Claustro

## Qué incluye
- La campaña original de cinco habitaciones, almas y reencarnación se mantiene intacta.
- El menú principal incorpora acceso al modo alternativo **Vigilia del Claustro** (tecla H o toque en la parte derecha).
- En la campaña aparece un joystick virtual y botones E/F/DASH/Q para pantallas táctiles.
- El nuevo modo cuenta con elección de refugio, cama productora de ecos, puerta reforzable, cuatro centinelas automáticos, reparación y oleadas crecientes hasta el amanecer (135 s). La derrota sucede cuando cae la puerta.
- El nuevo modo tiene una economía **independiente** para no alterar el lore, las almas ni el personaje de la campaña.

## Controles
| Acción | Pantalla táctil | Escritorio |
| --- | --- | --- |
| Campaña | Tocar mitad izquierda en menú | Enter |
| Vigilia | Tocar mitad derecha en menú | H |
| Caminar en campaña | Joystick virtual | WASD o flechas |
| Interactuar / linterna / esquivar / resonancia | Botones E/F/DASH/Q | E/F/Espacio/Q |
| Descansar | Tocar lecho o botón DESCANSAR | Espacio |
| Mejorar lecho/puerta/centinela/reparar | Botones inferiores | 2/3/4/5 |
| Salir del modo defensa | Botón SALIR | Esc |

## Android
La configuración contiene orientación **horizontal** y un preset de exportación Android, pero un APK requiere las plantillas oficiales de la versión exacta de Godot, JDK y Android SDK. Un APK de desarrollo no es un lanzamiento firmado para Play Store. Nunca publiques tu keystore de producción.

## Alcance
Inspirado en mecánicas generales de defensa de habitación y supervivencia: **no se han copiado** sprites, personajes, interfaz comercial ni marcas de Haunted Dorm. No incluye anuncios, multijugador, mercado ni monetización. La validación automatizada no sustituye probar el rendimiento y los controles en un teléfono físico.


## Ampliación de jugabilidad (v0.4.1)
- **Tres habitaciones** con ventajas mecánicas diferentes: Umbral (+1 eco/s), Claustro (+125 salud inicial de puerta), Archivo (+8 de energía inicial).
- **Dos recursos:** ecos al descansar y energía mediante generadores. Sin descanso, no produce ninguno.
- **Construcción y mejora:** cama, puerta, hasta 4 centinelas, nivel de daño de las torres, generadores y escudo temporal.
- **Pausa**, reinicio, variaciones Ghoul/Wizard/Angel por oleada, récord local y puntuación al terminar.
- El estado de la Vigilia se guarda en un archivo propio `user://vigilia_claustro_records.json`; no se comparte con el archivo de reencarnación.
- Los cuatro botones de tecnología están sobre la fila inferior. Teclado: 6 generador, 7 potenciar, 8 escudo, P pausa; 1-5 siguen como antes.
