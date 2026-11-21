# El Templo de los Ecos

![Identidad visual de El Templo de los Ecos](assets/branding/logo.svg)

**Un lugar sagrado. Un sistema oculto. Un ciclo del que quizás no exista escapatoria.**

[![Estado: Alpha](https://img.shields.io/badge/estado-alpha-orange)](https://github.com/je7remy/el-templo-de-los-ecos/releases)
[![Godot 4.3](https://img.shields.io/badge/Godot-4.3%2B-478cbf?logo=godot-engine&logoColor=white)](https://godotengine.org/)
[![Validación Godot](https://github.com/je7remy/el-templo-de-los-ecos/actions/workflows/validar-godot.yml/badge.svg)](https://github.com/je7remy/el-templo-de-los-ecos/actions/workflows/validar-godot.yml)
[![Último lanzamiento](https://img.shields.io/github/v/release/je7remy/el-templo-de-los-ecos?include_prereleases&label=versi%C3%B3n)](https://github.com/je7remy/el-templo-de-los-ecos/releases)

**El Templo de los Ecos** es un juego independiente de terror psicológico y cósmico, supervivencia y elementos roguelite, desarrollado en **Godot Engine 4** con **GDScript**. El jugador explora un templo cuyo funcionamiento desconoce. Cada entidad obedece reglas propias, y entenderlas vale tanto como cualquier habilidad.

> **Estado:** prototipo de un solo piso con cinco salas. Las misiones, entidades y estadísticas del prototipo no son canon definitivo del universo. No es un juego terminado.

![Sala del Testigo: el ojo del muro está abierto y el Testigo vigila el sello](docs/galeria/04_testigo.png)

*Captura real del juego en Godot. En la Sala del Testigo, moverse mientras el ojo del muro está abierto atrae a la entidad.*

## ¿Qué incluye el prototipo?

- **Dos pisos jugables** (de los diez diseñados, inspirados en la estructura de L.A.G.):
  - **Piso I · El Despertar**, cinco salas: Umbral del despertar, Claustro de las ofrendas, Sala del Testigo, Archivo de los ausentes y Pórtico del siguiente piso.
  - **Piso II · Los Peregrinos**, cuatro salas con las primeras grietas del templo. Un Peregrino se ofrece a reunir almas contigo… y en la mayoría de las vidas te traiciona al llegar a la Cripta del Reparto. Tiene indicios: se queda a tu espalda y miente sobre cuántas almas lleva. Si lo atacas primero y era sincero, lo pagas.
- **Ecos**: al superar cada piso ganas una pasiva que se acumula (Respiración contenida, Nuca fría). Se conservan si tu alma regresa y se pierden si es absorbida.
- **Tres entidades con reglas que se pueden aprender**, con arte propio en vista cenital y cuatro direcciones:
  - **Testigo**: solo persigue si el ojo está abierto y el jugador se mueve. Solo recibe daño con el ojo cerrado.
  - **Ghoul de brasas**: le atrae la luz de la antorcha. Siempre vulnerable.
  - **Hechicero del archivo**: lanza conjuros hacia la luz. Solo recibe daño mientras carga el conjuro.
- **Antorcha e inventario**: despiertas a oscuras; en la primera sala encuentras madera y fósforos y se construye la antorcha. Encenderla gasta un fósforo (apagarla no); hay más cajas en las salas 3 y 4, y el altar vende la **Llama interior**, que la enciende sin gastar.
- **Combate**: golpe de antorcha (clic o E) y **Resonancia** (Q), una onda visible que daña y aturde. Las entidades tienen barra de vida, avisan si son INMUNES o VULNERABLES y, a 0, se disuelven dejando almas. Vuelven si mueres.
- **Exploración e interacción**: almas que se recogen al tocarlas, cada una sobre el cuerpo ensangrentado de su antiguo dueño; el sello del Testigo, la carta del archivo y el altar del Mercader Silencioso. Las puertas se cruzan al tocarlas.
- **Salas simétricas**: los objetos de cada sala van en el eje central o en parejas en espejo.
- **Penumbra dinámica**: tu antorcha, los braseros y las almas abren claros en la oscuridad; apagarla te esconde, pero también te ciega.
- **Peligro que se anuncia**: el ojo del Testigo tiembla antes de abrirse y el Hechicero carga su conjuro a la vista. Los golpes sacuden la pantalla y dan un breve margen de invulnerabilidad.
- **Música y sonido originales** que reaccionan al miedo y a la persecución.
- **Muerte 50/50**: el alma regresa (misma persona, con memoria y habilidades) o es absorbida y aparece un humano nuevo, sin recuerdos.
- **Vigilia del Claustro**: modo alternativo de defensa con lecho, puerta, centinelas y oleadas hasta el amanecer. Botones de imagen con su descripción al pasar el cursor.
- **Salas editables en Godot**: arquitectura en `TileMapLayer`, objetos como `Sprite2D` con su colisión y marcadores para todas las posiciones de juego.
- **Controles táctiles para Android** y **pruebas automatizadas** con Godot 4.3 en GitHub Actions.

La idea narrativa central es que el templo no es una prisión convencional, sino parte de un sistema de explotación de almas. El antagonista permanece fuera de escena mientras el sistema sigue funcionando.

## Galería

Todas las imágenes, salvo las tres láminas finales, son capturas reales del juego ejecutándose en Godot 4.3.

| | |
| --- | --- |
| ![Menú principal](docs/galeria/01_menu.png) | ![Umbral del despertar](docs/galeria/02_umbral.png) |
| **Menú principal.** Elige entre Explorar o Vigilia. | **I · Umbral del despertar.** Despiertas a oscuras: la madera y los fósforos brillan en el suelo; cada alma flota sobre un cadáver. |
| ![Claustro de las ofrendas con el Ghoul de brasas](docs/galeria/03_claustro_ghoul.png) | ![Altar del Mercader Silencioso](docs/galeria/07_altar.png) |
| **II · Claustro de las ofrendas.** El Ghoul de brasas persigue tu luz. El altar está en el centro. | **El Mercader Silencioso.** Cambia almas por Resonancia o por la Llama interior. |
| ![Golpe de antorcha contra el Ghoul](docs/galeria/12_combate.png) | ![Inventario](docs/galeria/13_inventario.png) |
| **Combate.** El golpe de antorcha deja una estela de fuego; la barra indica la vida de la entidad. | **Inventario (I).** Iconos de objetos y habilidades con su descripción. |
| ![Entrada al Piso II](docs/galeria/14_piso2_entrada.png) | ![El Peregrino traiciona en la Cripta del Reparto](docs/galeria/15_peregrino.png) |
| **Entrada al Piso II.** Solo un fragmento de la sala: lo demás se descubre al entrar. | **La Cosecha.** «Lo siento. Las almas no alcanzan para dos.» |
| ![Archivo de los ausentes con el Hechicero](docs/galeria/05_archivo.png) | ![Pórtico del siguiente piso](docs/galeria/06_portico.png) |
| **IV · Archivo de los ausentes.** El libro se abre al leer la carta; el Hechicero responde a la antorcha. | **V · Pórtico del siguiente piso.** «Esto no es una salida. Es una transición.» |

### Vigilia del Claustro

![Vigilia del Claustro: lecho, centinelas y puerta frente a una entidad](docs/galeria/08_vigilia.png)

Descansa en el lecho para ganar ecos, levanta centinelas en los pedestales rúnicos y refuerza la puerta hasta que amanezca. Su economía es independiente de la campaña.

### Entidades

![Testigo, Ghoul de brasas y Hechicero del archivo en sus cuatro direcciones](docs/galeria/09_entidades.png)

### Salas editables

![Sala con sus colisiones, marcadores y la base de cada objeto](docs/galeria/10_sala_editable.png)

Cada sala es una escena (`rooms/sala_N.tscn`). Los objetos están en simetría respecto al eje central. Puedes mover columnas y estatuas en el editor y su colisión las acompaña. Las posiciones de juego (jugador, enemigo, salida, reliquias, altar…) son `Marker2D`. Consulta la [guía para editar salas](docs/EDITAR_SALAS.md).

### Evolución visual

![Comparación entre el prototipo inicial y el estado actual del Claustro de las ofrendas](docs/galeria/11_antes_despues.png)

## Música y sonido

Todo el audio es original y se sintetiza con `herramientas/generar_audio.py`, sin muestras de terceros:

- **Ambiente del templo**: dron grave, coro sintético en re menor con un giro frigio (mi♭) que no termina de resolver, campanas lejanas y viento. Es un bucle de 64 s que empalma sin cortes.
- **Capa de tensión**: latido y cuerdas disonantes en trémolo. Sube con el miedo, cuando una entidad te persigue o con el ojo del Testigo abierto, y baja al calmarse la situación.
- **Efectos por evento**: pasos sobre la losa (tres variaciones), alma, daño, aviso y apertura del ojo, sello, puerta, conjuro, carta, fósforo, apagar, recoger objeto, golpe de antorcha, impacto, inmune, Resonancia, destierro, interfaz y muerte.

## Jugar en Android

Puedes descargar el [APK de prueba de v0.4.2-alpha](https://github.com/je7remy/el-templo-de-los-ecos/releases/tag/v0.4.2-alpha) para teléfonos Android ARM64. No está publicado en Google Play y necesita pruebas en dispositivos reales. **Ese APK es anterior a la renovación visual** que muestran las capturas; los cambios llegarán en el próximo release.

Para los controles móviles y sus limitaciones, consulta la [guía Android y Vigilia](docs/MOVIL_Y_VIGILIA.md).

## Descargar y ejecutar en Fedora / Linux

La [sección Releases](https://github.com/je7remy/el-templo-de-los-ecos/releases) ofrece **el proyecto fuente**, no un ejecutable listo para instalar. Descarga el ZIP del código fuente, descomprímelo y abre `project.godot` con Godot 4.3 o superior.

También puedes clonar el repositorio:

```bash
git clone https://github.com/je7remy/el-templo-de-los-ecos.git
cd el-templo-de-los-ecos

# Importación inicial de texturas
godot --headless --path . --import

# Jugar
godot --path .
```

Para abrir el editor:

```bash
godot --editor --path .
```

Si Godot está instalado por Flatpak, sustituye `godot` por `flatpak run org.godotengine.Godot`. También está disponible `bash herramientas/abrir_fedora.sh`.

## Controles

| Tecla | Acción |
| --- | --- |
| Enter | Iniciar la exploración o reiniciar |
| H | Abrir Vigilia del Claustro desde el menú |
| W / A / S / D o flechas | Moverse |
| E | Interactuar (sello, carta, altar). Si no hay nada cerca y la antorcha arde, golpear. Almas, objetos y puertas abiertas funcionan al tocarlos |
| Clic izquierdo | Golpe de antorcha |
| F | Encender (gasta un fósforo) o apagar la antorcha |
| I o Tab | Inventario |
| Espacio | Esquivar |
| Q | Resonancia: onda que daña y aturde (después de adquirirla) |
| Esc | Volver al menú o cerrar un panel |
| 1–8 en Vigilia | Descansar, construir, mejorar, reparar y activar tecnología |
| P en Vigilia | Pausar o reanudar |

**Recorrido:** Umbral del despertar → Claustro de las ofrendas → Sala del Testigo → Archivo de los ausentes → Pórtico del siguiente piso. Algunas reglas de las entidades todavía son provisionales.

## Pruebas de integridad y compatibilidad

Requisitos para desarrollo: **Godot 4.3 o superior**. La CI usa Godot 4.3, y el entorno Fedora del proyecto, Godot 4.7.2. Las pruebas automáticas no reemplazan las pruebas manuales en Fedora ni en dispositivos Android.

```bash
python3 herramientas/comprobar_archivos.py
godot --headless --path . --import
godot --headless --path . --script res://tests/visual_asset_test.gd
godot --headless --path . --script res://tests/smoke_test.gd
godot --headless --path . --script res://tests/defense_test.gd
godot --headless --path . --script res://tests/mobile_input_test.gd
godot --headless --path . --script res://tests/balance_test.gd
godot --headless --path . --script res://tests/brand_test.gd
```

`comprobar_archivos.py` comprueba los archivos esenciales, que cada PNG conserve su `.import`, que no haya `.gd.uid` huérfanos y que el proyecto declare Godot 4.3 y filtrado nearest-neighbor. `visual_asset_test.gd` verifica además que las cinco salas conserven su arquitectura, objetos, marcadores y colisiones.

**Publicación:** cada push a `main` valida Godot y puede producir un APK como artefacto de GitHub Actions, pero no reemplaza automáticamente los APK de releases existentes. Publicar una versión nueva requiere un proceso de etiquetado específico.

## Estructura del proyecto

```text
assets/                 Arte: escenario (Knowledge Temple), entidades, tiles, objetos y marca
  visual/enemies/       Entidades originales (Testigo, Ghoul de brasas, Hechicero)
  visual/tiles/         Atlas de la arquitectura de las salas
  visual/objetos/       Columnas, estatuas, braseros, mesa, sarcófago… por sala
  visual/iconos/        Iconos de inventario, habilidades y botones de Vigilia
audio/                  Música y efectos originales (OGG)
rooms/                  Escenas editables de las cinco salas y su TileSet
shaders/                Luz y tinte de cada sala
scenes/                 Escena principal y Vigilia del Claustro
scripts/                Lógica de juego en GDScript
tests/                  Pruebas para Godot sin interfaz
herramientas/           Validación, apertura en Fedora y generadores de salas, protagonista, entidades, iconos y audio
docs/                   Diseño, licencias, guías, notas de versión y galería del README
.github/workflows/      Integración continua y publicación de alpha
project.godot           Configuración del motor
```

## Progreso y limitaciones

- **Versiones:** [registro de cambios](CHANGELOG.md) · [lanzamientos](https://github.com/je7remy/el-templo-de-los-ecos/releases).
- **CI:** [verificación automática](https://github.com/je7remy/el-templo-de-los-ecos/actions/workflows/validar-godot.yml).
- El arte de las entidades es original y funcional, pero todavía de **prototipo**; se puede retocar directamente en los PNG o con `herramientas/generar_enemigos.py`.
- El protagonista tiene arte original cenital (`herramientas/generar_protagonista.py`); Mark aún no está integrado como personaje con nombre.
- Vida, daño y precios del combate son **provisionales** y deben ajustarse jugando.
- Las pruebas automatizadas no sustituyen una partida manual, sobre todo en un teléfono Android real.

## Créditos y uso de los assets

- **Knowledge Temple — pingupollas:** escenario, suelos, muros y decoraciones (columnas, estatuas, braseros, altar, mesa, libro). [Página original](https://pingupollas.itch.io/knowledge-temple). El autor **exige crédito** y permite usar y modificar el material en proyectos personales y comerciales, pero **prohíbe redistribuir el pack como un paquete de recursos independiente**. Los recursos integrados aquí no se ofrecen como paquete de sprites.
- **GothicVania Church Pack — Luis Zuno (Ansimuz):** proyectiles de fuego del Hechicero. Los sprites de Angel, Burning Ghoul y Skeleton Wizard se conservan en el repositorio como respaldo. [Página original](https://ansimuz.itch.io/gothicvania-church-pack) · [Publicación CC0](https://opengameart.org/content/gothicvania-church-pack). Atribución voluntaria y apreciada.
- **Arte original del proyecto:** entidades, pilares y remates del marco de las salas (sobre ladrillos de Knowledge Temple), interfaz e identidad gráfica.

**Importante:** las licencias de terceros no significan que todo el código y el universo narrativo del juego estén bajo CC0. Consulta [assets y licencias](docs/ASSETS_Y_LICENCIAS.md) antes de reutilizar el contenido.

---

Desarrollado por [@je7remy](https://github.com/je7remy). **Último release publicado: v0.4.2-alpha.** La rama `main` contiene mejoras posteriores que aún no tienen un release propio.
