# Móvil Android y modo Vigilia del Claustro

## Qué incluye
- La campaña original de cinco habitaciones, almas y reencarnación se mantiene intacta.
- El menú principal incorpora acceso al modo alternativo **Vigilia del Claustro** (tecla H o toque en la parte derecha).
- En la campaña aparece un joystick flotante a la izquierda (la base va donde apoyes el pulgar) y cuatro botones en abanico a la derecha: **ACCIÓN** (grande), LUZ, ESQUIVA y ONDA. El botón de ACCIÓN cambia según lo que tengas cerca (COMPRAR, GUIAR, CALMAR, PUERTA, LEER, ALTAR, SELLO...) y brilla cuando hay algo con qué interactuar; si no, golpea con la antorcha. La LUZ muestra los fósforos que te quedan. Tocar el retrato abre el perfil y el botón de pausa del minimapa pausa la partida. Los controles táctiles se pueden forzar o desactivar en *Configuración > Controles* (Auto / Siempre / Nunca).
- **Vista de móvil** (en Android, o con los controles táctiles en «Siempre»): la cámara se acerca a lo que exploras (*Configuración > Zoom en el móvil*: cerca, medio o lejos), el HUD se ve un 20 % más grande (las piezas de arriba crecen desde el borde superior y las de abajo desde el inferior, sin salirse en pantallas anchas) y los botones táctiles también, desde la esquina de abajo a la derecha, con letras más grandes. La base del joystick se ve más aunque no lo toques.
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


## Vigilia por fases (Tanda B)
- La partida ya no termina al amanecer: son **fases de 90 s sin fin**, cada una más difícil, con un **jefe cada 5 fases**.
- Cada fase superada da **botín para la campaña** (se guarda en el archivo del personaje y se usa desde la pestaña OBJETOS del perfil). Cuanto más alta la fase, mejor el botín.
- En el móvil se puede tocar el lecho (dormir), una casilla vacía (centinela) y la puerta (reparar), además de los ocho botones de abajo. *(Sustituido por la v3.)*

## Vigilia v3: construir en todo el suelo
- **Toca cualquier baldosa libre** y se abre un menú para construir centinela, generador o campana. Toca algo construido para **mejorarlo o venderlo**, el lecho para **dormir o mejorarlo** y la puerta para **repararla o reforzarla**.
- El menú se queda abierto tras mejorar, para subir varios niveles seguidos. Tocar fuera lo cierra.
- Abajo quedan cuatro botones grandes: dormir, reparar, potenciar y escudo. La pausa está arriba, junto a salir.
- Niveles máximos:
  - lecho 20;
  - puerta 20;
  - cada estructura 15;
  - poder 15.

  Los costes suben con cada nivel y con cada estructura del mismo tipo.
- Las entidades tienen más vida y hacen más daño, cada vez más deprisa. Hay hasta 6 a la vez y un jefe cada 5 fases con 5 veces la vida.
- Teclado y mando:
  - flechas, WASD o la cruceta mueven el recuadro;
  - Enter o A abren el menú o eligen;
  - 1-3 eligen una opción;
  - Esc o B cierran.


## Tutorial guiado
- La primera vez, **EMPEZAR CON TUTORIAL** lanza 15 pasos guiados. La tarjeta de la derecha dice qué hacer y una flecha dorada señala dónde tocar.
- El reloj de la fase no corre y la puerta no cae mientras dura. Si te faltan ecos o energía para un paso, el juego te los da.
- **SALTAR** (o Retroceso) lo termina en cualquier momento. Desde la portada se puede repetir con **REPETIR TUTORIAL** (T en el teclado, Y en el mando).
