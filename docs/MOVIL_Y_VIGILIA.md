# Móvil Android y modo Vigilia del Claustro

## Qué incluye
- La campaña original de cinco habitaciones, almas y reencarnación se mantiene intacta.
- El menú principal incorpora acceso al modo alternativo **Vigilia del Claustro** (tecla H o toque en la parte derecha).
- En la campaña aparece un joystick flotante a la izquierda (la base va donde apoyes el pulgar) y cuatro botones en abanico a la derecha: **ACCIÓN** (grande), LUZ, ESQUIVA y ONDA. El botón de ACCIÓN cambia según lo que tengas cerca (COMPRAR, GUIAR, CALMAR, PUERTA, LEER, ALTAR, SELLO...) y brilla cuando hay algo con qué interactuar; si no, golpea con la antorcha. La LUZ muestra los fósforos que te quedan. Tocar el retrato abre el perfil y el botón de pausa del minimapa pausa la partida. Los controles táctiles se pueden forzar o desactivar en *Configuración > Controles* (Auto / Siempre / Nunca).
- El nuevo modo cuenta con una sola cámara, cama productora de ecos, puerta reforzable, cuatro centinelas automáticos, reparación y oleadas crecientes hasta el amanecer (135 s). La derrota sucede cuando cae la puerta.
- El nuevo modo tiene una economía **independiente** para no alterar el lore, las almas ni el personaje de la campaña.

## Controles
| Acción | Pantalla táctil | Escritorio |
| --- | --- | --- |
| Campaña | Tocar mitad izquierda en menú | Enter |
| Vigilia | Tocar mitad derecha en menú | H |
| Caminar en campaña | Joystick virtual | WASD o flechas |
| Interactuar o golpear / antorcha / esquivar / resonancia | Botones ACCIÓN / LUZ / ESQUIVA / ONDA | E o clic / F / Espacio / Q |
| Perfil | Tocar el retrato | I o Tab |
| Pausa | Botón de pausa (arriba a la derecha) | Esc |
| Descansar | Tocar lecho o botón DESCANSAR | Espacio |
| Mejorar lecho/puerta/centinela/reparar | Botones inferiores | 2/3/4/5 |
| Ver qué hace un botón | Tocarlo (la descripción se ve un momento) | Pasar el cursor por encima |
| Salir del modo defensa | Icono de salida (arriba a la derecha) | Esc |

## Android
La configuración contiene orientación **horizontal** y un preset de exportación Android, pero un APK requiere las plantillas oficiales de la versión exacta de Godot, JDK y Android SDK. Un APK de desarrollo no es un lanzamiento firmado para Play Store. Nunca publiques tu keystore de producción.

## Alcance
Inspirado en mecánicas generales de defensa de habitación y supervivencia: **no se han copiado** sprites, personajes, interfaz comercial ni marcas de Haunted Dorm. No incluye anuncios, multijugador, mercado ni monetización. La validación automatizada no sustituye probar el rendimiento y los controles en un teléfono físico.


## Ampliación de jugabilidad (v0.4.1)
- **Un solo modo** (antes había tres cámaras): combina sus ventajas en una partida equilibrada (2,5 ecos/s iniciales, puerta de 210 y 4 de energía). La portada se toca para empezar.
- **Botones de imagen**: cada botón muestra un icono y su coste; el nombre y la descripción aparecen al pasar el cursor o al tocarlo.
- **Dos recursos:** ecos al descansar y energía mediante generadores. Sin descanso, no produce ninguno.
- **Construcción y mejora:** cama, puerta, hasta 4 centinelas, nivel de daño de las torres, generadores y escudo temporal.
- **Pausa**, reinicio, variaciones Ghoul/Wizard/Angel por oleada, récord local y puntuación al terminar.
- El estado de la Vigilia se guarda en un archivo propio `user://vigilia_claustro_records.json`; no se comparte con el archivo de reencarnación.
- Los cuatro botones de tecnología están sobre la fila inferior. Teclado: 6 generador, 7 potenciar, 8 escudo, P pausa; 1-5 siguen como antes.
