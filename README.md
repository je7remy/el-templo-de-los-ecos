# El Templo de los Ecos

![Identidad visual de El Templo de los Ecos](assets/branding/logo.svg)

**Un lugar sagrado. Un sistema oculto. Un ciclo del que quizás no exista escapatoria.**

[![Estado: Alpha](https://img.shields.io/badge/estado-alpha-orange)](https://github.com/je7remy/el-templo-de-los-ecos/releases)
[![Godot 4.3](https://img.shields.io/badge/Godot-4.3%2B-478cbf?logo=godot-engine&logoColor=white)](https://godotengine.org/)
[![Validación Godot](https://github.com/je7remy/el-templo-de-los-ecos/actions/workflows/validar-godot.yml/badge.svg)](https://github.com/je7remy/el-templo-de-los-ecos/actions/workflows/validar-godot.yml)
[![Último lanzamiento](https://img.shields.io/github/v/release/je7remy/el-templo-de-los-ecos?sort=semver&include_prereleases&label=versi%C3%B3n&cacheSeconds=3600)](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest)

**El Templo de los Ecos** es un juego independiente de terror psicológico y cósmico, supervivencia y elementos roguelite, desarrollado en **Godot Engine 4** con **GDScript**. El jugador explora un templo cuyo funcionamiento desconoce. Cada entidad obedece reglas propias, y entenderlas vale tanto como cualquier habilidad.

> **Estado:** prototipo con diez pisos jugables. Las misiones, entidades y estadísticas del prototipo no son canon definitivo del universo. No es un juego terminado.

## Descargar la última versión

Estos enlaces bajan siempre la versión más reciente:

| Plataforma | Descarga |
|---|---|
| **Windows 10/11** (instalador) | [ElTemploDeLosEcos-Windows-Setup.exe](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest/download/ElTemploDeLosEcos-Windows-Setup.exe) |
| **Windows 10/11** (portable, sin instalar) | [ElTemploDeLosEcos-Windows-Portable.zip](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest/download/ElTemploDeLosEcos-Windows-Portable.zip) |
| **Linux x86_64** | [ElTemploDeLosEcos-Linux-x86_64.tar.gz](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest/download/ElTemploDeLosEcos-Linux-x86_64.tar.gz) |
| **Android ARM64** | [ElTemploDeLosEcos-Android.apk](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest/download/ElTemploDeLosEcos-Android.apk) |

Las notas de cada versión están en la [página de la última versión](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest). Una vez instalado, el juego avisa solo cuando sale una versión nueva (ver «Actualizaciones automáticas»). Es una alpha: no está firmada, así que Windows puede mostrar «Windows protegió tu PC» (**Más información → Ejecutar de todas formas**).

![Sala del Testigo: el ojo del muro está abierto y el Testigo vigila el sello](docs/galeria/04_testigo.png)

*Captura real del juego en Godot. En la Sala del Testigo, moverse mientras el ojo del muro está abierto atrae a la entidad.*

## ¿Qué incluye el prototipo?

- **Tu personaje**: antes de la primera exploración eliges nombre (teclado o letras en pantalla) y género (masculino o femenino, cada uno con su sprite y su retrato). El nombre aparece en el HUD, el perfil y el menú; se puede cambiar desde el menú (C).
- **Diez pisos jugables** (el primer arco completo, inspirado en la estructura de L.A.G.):
  - **Piso I · El Despertar**, cinco salas: Umbral del despertar, Claustro de las ofrendas, Sala del Testigo, Archivo de los ausentes y Pórtico del siguiente piso.
  - **Piso II · Los Peregrinos**, cuatro salas con las primeras grietas del templo. Un Peregrino se ofrece a reunir almas contigo… y en la mayoría de las vidas te traiciona al llegar a la Cripta del Reparto. Tiene indicios: se queda a tu espalda y miente sobre cuántas almas lleva. Mientras te acompaña no se le puede herir: la traición llega por sorpresa.
  - **Piso III · La Cacería**, cuatro salas. El templo ordena cazar al **Segador de Hilos** con tres peregrinos aliados. Antes de atacar tensa una línea roja: lo que esté sobre ella (tú o tus aliados, también los que van detrás de ti) recibe el hilo. Después queda enganchado y solo entonces se le puede herir. A media vida huye a la sala siguiente; la puerta no se abre mientras viva.
  - **Piso IV · El Claustro Enraizado**, cuatro salas. Las enredaderas secas arden y el fuego se propaga; las Tejedoras de Raíz apenas notan los golpes: hay que atraerlas al fuego. Raíces vivas tapan la puerta del Atrio.
  - **Piso V · El Laberinto de los Mastines**, cuatro salas con muros de laberinto. Los mastines de bronce son inmunes pero temen al fuego, y la antorcha se consume. Puedes rescatar a un peregrino atrapado y obtener la Máscara de Porcelana, que convierte la Resonancia en Rugido.
  - **Piso VI · La Ofrenda**, cuatro salas sin entidades (piso de respiro). Un grupo de peregrinos pide que lo guíes (Saúl va con ellos si lo salvaste). El **Mercader Silencioso** abre su puesto: pan, fósforos y objetos con porcentajes. Se paga primero y **nunca se mete la mano bajo su manto**: quien lo hace pierde vida máxima en esa vida.
  - **Piso VII · La Que No Aparta la Vista**, cuatro salas. Una figura con yelmo y ojos en el pecho rodea la sala: solo ataca si le das la espalda o corres. Hay que aguantar su mirada para que la puerta se abra mientras te provoca con amagos y ruidos a tu espalda. Los peregrinos que guiaste pueden entrar en pánico: cálmalos antes de que echen a correr.
  - **Piso VIII · Las Salas que Cambian**, las salas del Piso I alteradas: las estatuas miran al otro lado, el Testigo persigue al que se queda quieto, el sello está en el Archivo y una inscripción firmada con tu nombre miente.
  - **Piso IX · El Coloso del Pórtico**, cuatro salas. Los **Arietes de Piedra** embisten en línea recta si te alineas con ellos y solo se rompen aturdidos tras chocar. El **Coloso**, una estatua viva inmune a golpes, se derriba atrayéndolo junto a columnas agrietadas y golpeándolas para que caigan sobre él.
  - **Piso X · La Cosecha**, el final del primer arco. Enciendes con la antorcha los tres braseros del ritual (entre un Ghoul y dos Arietes) y, al abrirse la Puerta, el **Hermano Mayor** te traiciona. Es un humano con tres reglas robadas:
    - **hilos**: líneas rojas que hacen daño al tensarse;
    - **rugido**: un círculo del que hay que salir; después queda agotado y recibe el doble de daño;
    - **mirada**: hay que quedarse quieto mientras te mira.

    Tus aliados eligen bando según tu marca: con bendición luchan contigo, con maldición le ayudan tirándote piedras, y sin marca se apartan.
- **Enemigos más fuertes cuanto más abajo**: las entidades tienen más vida y daño en los pisos profundos (+12 % por piso).
- **Profundidad**: cada personaje proyecta una sombra alargada contra las luces fuertes (tu antorcha, los braseros, el fuego), que gira y tiembla con la llama; las columnas y estatuas cercanas también la proyectan con tu antorcha. La sangre de los golpes se queda en el suelo de la sala, el aire tiembla sobre braseros y llamas, y con mucho miedo los colores se separan en los bordes y la viñeta late.
- **Sustos**: cuando todo está tranquilo pasa algo: una silueta o unos ojos en la parte oscura que se desvanecen si la luz los alcanza; pasos, golpes o arrastres que suenan detrás de ti; la luz que se va, la pantalla que se descompone o tu nombre escrito en sangre en el muro; y, a partir del Piso II, alguna cara que salta a la pantalla (como mucho una por piso; se puede apagar en Ajustes). Nunca durante un jefe ni en el tutorial, y cada susto sube el miedo.
- **Logros**: veinte logros de la cuenta (descenso, muerte, reglas de las entidades, peregrinos, personaje y Vigilia; cuatro ocultos). Se ven en Pausa > LOGROS y avisan con un rótulo dorado y una campana al conseguirlos. No se pierden al morir ni al cambiar de personaje.
- **Armas y equipo**: por las salas hay cinco armas (daga, espada, lanza, hacha y maza, cada una con su daño, alcance, ritmo y ángulo) y tres piezas de equipo (yelmo: menos daño; peto: más vida; botas: más velocidad). Se equipan solas al recogerlas y se cambian en Perfil > EQUIPO; se guardan entre partidas. Todo lo equipado se ve en el personaje y en su retrato (yelmo, máscara de porcelana, amuleto, peto, botas, brazalete y el arma en la mano). El arma ocupa la mano de la antorcha: con ella no hay luz, y F alterna entre antorcha y arma. Cada arma tiene su propio trazo al golpear. Todo (también la máscara y los accesorios) se puede quitar en Perfil > EQUIPO: vuelve el aspecto normal y se pierde su bono.
- **Arte y luz**: cada sala se amuebla con piezas de Knowledge Temple (sarcófagos, mesas de lectura con libros caídos, altares, estatuas, columnas rotas y braseros animados) según el estilo de su piso, siempre en espejo y sin tapar el paso. Encima va una capa de luz aditiva: el fuego, las almas y la antorcha brillan y sueltan chispas sobre la penumbra.
- **Niveles**: ganas experiencia con almas, alimañas, entidades desterradas, misiones y pisos. Cada nivel sube la vida máxima (+6), el daño (+4 %) y la recarga del vigor (+3 %) y te cura. El nivel se ve en el retrato del HUD y en el perfil.
- **Objetos y mejoras**: el perfil tiene una pestaña OBJETOS con lo equipado (brazalete, amuleto, máscara) y la bolsa (pan), que se usa desde ahí. Comprar otra vez el brazalete o el amuleto los sube de nivel (hasta 5), y la Resonancia se mejora con almas en el altar o el puesto. En el puesto se ve cuánto llevas de cada cosa y el número salta al comprar.
- **Vida extra**: curarte con objetos (pan, viales, relicarios, la fuente) con la vida llena suma por encima del máximo, sin tope: se acumula todo lo que consumas (franja dorada en la barra). La regeneración natural no pasa del máximo.
- **Relicarios de vida** en las salas sin entidad: una cura de 60 por sala y partida.
- **Bendición y maldición**: ayudar a quien lo pide (liberar a Saúl, guiar al grupo, calmar a un peregrino) suma; dejarlo atrás o fallarle resta. Con la bendición confían en ti, te regalan cosas y el Mercader cobra menos; con la maldición te temen, se apartan, no te siguen y el Mercader cobra más.
- **Vigilia renovada** (se desbloquea comprando su llave al Mercader del Piso VI por 500 almas): defensa de una celda vista en planta, con rejilla, lecho, puerta y pasillo (estilo de defensa de cuarto, con arte propio). **Fases sin fin**, cada una más dura: más vida, velocidad y daño, más entidades a la vez y un **jefe cada 5 fases**. Cada fase superada da un **objeto al azar para la campaña** (pan, fósforos, vial de sangre, incienso, bolsa de almas, mejoras del brazalete, el amuleto o la Resonancia, reliquia de experiencia); cuanto más alta la fase, mejor el botín.
- **Menú más simple**: JUGAR abre los pisos (el I empieza desde el principio) y salir del juego pide confirmación.
- **Pensado para móvil**: joystick flotante, botón de ACCIÓN que cambia según lo que tengas cerca, botones grandes al alcance del pulgar y textos de ayuda que hablan de toques, no de teclas.
- **Herencia del primer juego**: alimañas (ratas, murciélagos que vuelan por encima de las columnas y arañas que saltan desde lejos) que mueren de un esquive o un golpe y salen de nidos, tu cuerpo de la vida anterior en la sala donde caíste, transiciones con máscara, resumen al superar cada piso, sonidos de Kenney con variantes, cursor propio y créditos.
- **Dirección de arte gótica**: rótulos con tipografía gótica de píxel, interfaz oscura con dorado envejecido, bloom, niebla, haces de luz, partículas y fundidos. **Menú de pisos** para volver a cualquier piso alcanzado.
- **Diálogos, misiones y trampas**: conversaciones que avanzan con clic, misiones con premio en las salas con monstruo, trampas con aviso (pinchos, llamaradas que brotan del suelo y péndulos con cuchilla que barren la sala; el esquive las cruza) e inscripciones de lore. La vida se recupera poco a poco y esquivar funciona aunque estés quieto. Pantalla de habilidades con la tecla K.
- **Morir no cuesta progreso (temporal, modo de pruebas)**: te levantas en la entrada de la misma sala con almas, objetos, habilidades y Ecos. Se desactiva con `MUERTE_SIN_PERDIDA` en `scripts/main.gd`.
- **Ecos**: al superar cada piso ganas una pasiva que se acumula (Respiración contenida, Nuca fría, Reflejos, Piel curtida, Paso ligero, Huesos firmes, Mente serena, Memoria de eco y Fuerza acumulada). Se conservan si tu alma regresa y se pierden si es absorbida.
- **Tres entidades con reglas que se pueden aprender**, con arte propio en vista cenital y cuatro direcciones:
  - **Testigo**: solo persigue si el ojo está abierto y el jugador se mueve. Solo recibe daño con el ojo cerrado.
  - **Ghoul de brasas**: le atrae la luz de la antorcha. Siempre vulnerable.
  - **Hechicero del archivo**: lanza conjuros hacia la luz. Solo recibe daño mientras carga el conjuro.
- **Inicio, intro y tutorial**: pantalla «haz clic para continuar» con el engranaje de configuración abajo a la izquierda; acuerdo de usuario la primera vez; intro breve (saltable) y una sala de práctica con 8 pasos guiados (mover, esquivar, recoger un alma, encender la antorcha, golpear un muñeco, abrir el perfil, pausar y cruzar la puerta). Se puede repetir desde Configuración.
- **Pausa y configuración**: ESC pausa la partida (continuar, configuración, perfil, saltar tutorial, volver al inicio). Configuración con Sonido (general, música, efectos, silencio), Controles (todas las teclas reasignables y modo táctil), Idioma (español / inglés: todo el juego, incluidas salas, diálogos y la Vigilia) y Privacidad (acuerdo, política y borrar mis datos).
- **Estilo roguelike de acción**: HUD de paneles biselados con el retrato de Mark (con sangre cuando está herido), barras de vida, vigor y miedo con icono y números, minimapa del piso, contador de almas, panel de arma con su munición (fósforos) y habilidades redondas con su recuperación. Tipografía pixel (Pixelify Sans, OFL) y salas con restos, sangre, velas, estandartes y cadenas.
- **Perfil del jugador (I)**: retrato, estadísticas de la partida y de tus vidas, equipo y mochila, y los Ecos despertados.
- **Antorcha y mochila**: despiertas a oscuras; en la primera sala encuentras madera y fósforos y se construye la antorcha. Encenderla gasta un fósforo (apagarla no); hay más cajas en las salas 3 y 4, y el altar vende la **Llama interior**, que la enciende sin gastar.
- **Combate**: golpe de antorcha (clic o E) y **Resonancia** (Q), una onda visible que daña y aturde. Las entidades tienen barra de vida, avisan si son INMUNES o VULNERABLES y, a 0, se disuelven dejando almas. Vuelven si mueres.
- **Exploración e interacción**: almas que se recogen al tocarlas, cada una sobre el cuerpo ensangrentado de su antiguo dueño; el sello del Testigo, la carta del archivo y el altar del Mercader Silencioso. Las puertas se cruzan al tocarlas.
- **Salas simétricas**: los objetos de cada sala van en el eje central o en parejas en espejo.
- **Penumbra dinámica**: tu antorcha, los braseros y las almas abren claros en la oscuridad; apagarla te esconde, pero también te ciega.
- **Peligro que se anuncia**: el ojo del Testigo tiembla antes de abrirse y el Hechicero carga su conjuro a la vista. Los golpes sacuden la pantalla y dan un breve margen de invulnerabilidad.
- **Música y sonido originales** que reaccionan al miedo y a la persecución.
- **Muerte 50/50**: el alma regresa (misma persona, con memoria y habilidades) o es absorbida y aparece un humano nuevo, sin recuerdos.
- **Vigilia del Claustro** (bloqueada hasta comprar su llave): modo alternativo de defensa con lecho, puerta, centinelas y oleadas hasta el amanecer. Botones de imagen con su descripción al pasar el cursor.
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
| ![Golpe de antorcha contra el Ghoul](docs/galeria/12_combate.png) | ![Perfil del jugador](docs/galeria/13_inventario.png) |
| **Combate.** El golpe de antorcha deja una estela de fuego; la barra indica la vida de la entidad. | **Perfil (I).** Retrato, estadísticas, equipo, mochila y Ecos. |
| ![Entrada al Piso II](docs/galeria/14_piso2_entrada.png) | ![El Peregrino traiciona en la Cripta del Reparto](docs/galeria/15_peregrino.png) |
| **Entrada al Piso II.** Solo un fragmento de la sala: lo demás se descubre al entrar. | **La Cosecha.** «Lo siento. Las almas no alcanzan para dos.» |
| ![Pantalla de inicio](docs/galeria/16_inicio.png) | ![Configuración: controles](docs/galeria/17_configuracion.png) |
| **Inicio.** Haz clic para continuar; el engranaje abre la configuración. | **Configuración.** Sonido, controles reasignables, idioma y privacidad. |
| ![Tutorial](docs/galeria/18_tutorial.png) | ![Pausa](docs/galeria/19_pausa.png) |
| **Tutorial.** Sala de práctica con pasos guiados y un muñeco de entrenamiento. | **Pausa.** Continuar, configuración, perfil o volver al inicio. |
| ![Menú con la nueva dirección de arte](docs/galeria/24_arte_menu.png) | ![Menú de pisos](docs/galeria/25_arte_pisos.png) |
| **Menú.** Rótulo gótico, paneles oscuros con dorado envejecido. | **Pisos.** Los diez pisos del templo; se puede volver a cualquiera ya alcanzado. |
| ![Nave del Agua con niebla y haces de luz](docs/galeria/26_arte_nave.png) | ![Muerte](docs/galeria/27_arte_muerte.png) |
| **Atmósfera.** Haces de luz, niebla baja, polvo, bloom y viñeta. | **Muerte.** El alma se desprende; te levantas en una columna de luz. |
| ![El Coloso](docs/galeria/52_piso9_coloso.png) | ![Arietes](docs/galeria/53_piso9_arietes.png) |
| **Piso IX.** El Coloso pisa fuerte: sal del círculo rojo y atráelo junto a una columna agrietada. | **Arietes de Piedra.** Embisten en línea recta; aturdidos, se rompen. |
| ![El Hermano Mayor](docs/galeria/54_piso10_hermano.png) | ![Tutorial de la Vigilia](docs/galeria/55_vigilia_tutorial.png) |
| **Piso X.** El Hermano Mayor usa la mirada: quédate quieto. Tus aliados luchan contigo si llevas la bendición. | **Tutorial de la Vigilia.** 15 pasos guiados: dormir, construir, mejorar, potenciar, reparar, escudo y vender. |
| ![Vigilia por fases](docs/galeria/50_vigilia_fases.png) | ![Botín de la Vigilia](docs/galeria/51_vigilia_botin.png) |
| **Vigilia.** Toca cualquier baldosa para construir centinelas, generadores o campanas. | **Botín.** Cada fase da objetos que pasan a la campaña. |
| ![Objetos en el perfil](docs/galeria/46_objetos.png) | ![Puesto con mejoras](docs/galeria/47_puesto_mejoras.png) |
| **Objetos.** Lo equipado con su nivel y la bolsa, que se usa desde aquí. | **El puesto.** Cuánto llevas de cada cosa y las mejoras por nivel. |
| ![Relicario de vida](docs/galeria/48_relicario.png) | ![Menú](docs/galeria/49_menu_jugar.png) |
| **Relicario de vida.** En las salas sin entidad; la vida extra se ve en dorado. | **Menú.** JUGAR lleva a los pisos; SALIR pide confirmación. |
| ![Umbral que no recuerdas](docs/galeria/44_piso8_umbral.png) | ![Testigo invertido](docs/galeria/45_piso8_testigo.png) |
| **Piso VIII.** La primera sala, cambiada, con una inscripción que te miente y tu silueta donde moriste. | **Testigo invertido.** Ahora viene si te quedas quieto. |
| ![La Que No Aparta la Vista](docs/galeria/40_piso7_mirada.png) | ![Piso VII en el móvil](docs/galeria/41_piso7_movil.png) |
| **Piso VII.** Aguanta su mirada; el medidor de arriba cuenta los segundos. | **En el móvil.** El botón de ACCIÓN cambia a CALMAR junto a un peregrino en pánico. |
| ![Controles táctiles](docs/galeria/42_movil_controles.png) | ![Subida de nivel](docs/galeria/43_nivel.png) |
| **Controles táctiles.** Joystick flotante y botones en abanico; ACCIÓN dice qué hará. | **Nivel.** Cada nivel mejora vida, daño y vigor. |
| ![Atrio de los Guías](docs/galeria/36_piso6_guias.png) | ![Puesto del Mercader](docs/galeria/37_piso6_mercader.png) |
| **Piso VI.** Un grupo de peregrinos espera a que aceptes guiarlo. | **El Mercader Silencioso.** El cuenco de las ofrendas y algo que brilla bajo el manto. |
| ![El puesto](docs/galeria/38_piso6_puesto.png) | ![Mando en la configuración](docs/galeria/39_mando_ajustes.png) |
| **El puesto.** Se paga primero: pan, fósforos, brazalete y amuleto. | **Mando.** Esquema de Xbox en *Configuración > Controles*. |
| ![Galería del Manto](docs/galeria/34_piso5_galeria.png) | ![Canales de Almas](docs/galeria/35_piso5_canales.png) |
| **Piso V.** Muros de laberinto, mastines que no se acercan a la luz y un peregrino atrapado. | **Canales de Almas.** La Máscara de Porcelana y los surcos por donde corren las almas. |
| ![Atrio de las Raíces](docs/galeria/31_piso4_atrio_antes.png) | ![Tejedora de Raíz ardiendo](docs/galeria/32_piso4_tejedora.png) |
| **Piso IV.** Enredaderas secas y raíces vivas que tapan la puerta. | **La Tejedora.** Su corteza resiste los golpes; el fuego la consume. |
| ![Resumen del piso](docs/galeria/28_primer_juego_resumen.png) | ![Cuerpo de la vida anterior](docs/galeria/29_primer_juego_cuerpo.png) |
| **Resumen del piso.** Tiempo, almas, muertes, misiones y la verdad del piso. | **Tu vida anterior.** Tu cuerpo queda donde caíste; tocarlo devuelve almas. |
| ![Creación del personaje: nombre](docs/galeria/20_crear_nombre.png) | ![Creación del personaje: género](docs/galeria/21_crear_genero.png) |
| **Tu nombre.** Escribe con el teclado o toca las letras; también hay nombres al azar. | **Tu género.** Masculino o femenino, con su sprite y su retrato. |
| ![El Segador de Hilos tensa la línea](docs/galeria/22_caza_hilos.png) | ![El Segador queda enganchado](docs/galeria/23_caza_enganche.png) |
| **La Cacería.** El Segador tensa sus hilos: sal de la línea y no dejes a tus aliados detrás de ti. | **Enganchado.** El hilo mató a Odón; el Segador queda clavado y vulnerable. |
| ![Archivo de los ausentes con el Hechicero](docs/galeria/05_archivo.png) | ![Pórtico del siguiente piso](docs/galeria/06_portico.png) |
| **IV · Archivo de los ausentes.** El libro se abre al leer la carta; el Hechicero responde a la antorcha. | **V · Pórtico del siguiente piso.** «Esto no es una salida. Es una transición.» |

### Vigilia del Claustro

![Vigilia del Claustro: lecho, centinelas y puerta frente a una entidad](docs/galeria/08_vigilia.png)

Duerme en el lecho para ganar ecos y construye en cualquier baldosa libre de la celda: centinelas (disparan), generadores (energía) y campanas (frenan a las entidades). Toca cualquier cosa para mejorarla; el lecho, la puerta y cada estructura tienen muchos niveles. Fases sin fin, cada una más dura, con botín para la campaña. La primera vez empieza con un **tutorial guiado de 15 pasos**, que se puede saltar o repetir desde la portada.

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

Puedes descargar el [APK de la última versión](https://github.com/je7remy/el-templo-de-los-ecos/releases/latest/download/ElTemploDeLosEcos-Android.apk) para teléfonos Android ARM64, con los diez pisos y la Vigilia v3. Cuando una versión nueva llega a `main`, el CI la publica sola con el APK, los archivos de Windows y Linux, y la marca como la última. No está en Google Play y necesita pruebas en dispositivos reales.

Desde v0.5.9 el CI firma el APK con una **llave fija** guardada en los secretos del repositorio (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`), así que cada APK nuevo se instala encima del anterior y conserva la partida. Si esos secretos no existen, el CI usa una llave temporal y avisa: en ese caso hay que desinstalar la versión anterior antes de instalar la nueva. El paso de la llave temporal a la fija también exige desinstalar una vez.

Cómo crear la llave y guardarla en los secretos (una sola vez, en tu equipo; la llave **nunca** va al repositorio):

```bash
mkdir -p ~/llaves && cd ~/llaves
keytool -genkeypair -storetype PKCS12 -keystore templo.keystore -alias templo \
  -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=El Templo de los Ecos,C=DO"
base64 -w0 templo.keystore | gh secret set ANDROID_KEYSTORE_BASE64 -R je7remy/el-templo-de-los-ecos
gh secret set ANDROID_KEYSTORE_PASSWORD -R je7remy/el-templo-de-los-ecos   # pide la contraseña
gh secret set ANDROID_KEY_ALIAS -R je7remy/el-templo-de-los-ecos --body templo
```

Guarda `templo.keystore` y su contraseña en un lugar seguro y con copia: si se pierden, ningún APK nuevo podrá instalarse encima de los anteriores.

## Actualizaciones automáticas

Desde v0.5.9, las copias instaladas (Android, Windows y Linux) consultan al abrir la lista de [releases](https://github.com/je7remy/el-templo-de-los-ecos/releases). Si hay una versión más nueva con archivo para su plataforma, el menú principal muestra **NUEVA VERSIÓN … DISPONIBLE** con **ACTUALIZAR** y **AHORA NO**:

- **Windows (instalador):** descarga el `Setup.exe`, lo ejecuta sin ventanas (`/S`), y el instalador reemplaza el juego y lo vuelve a abrir.
- **Windows (portable):** descarga el `.zip` y cambia `ElTemploDeLosEcos.exe` por el nuevo (el anterior queda como `.old.exe` y se borra al abrir).
- **Linux:** descarga el `.tar.gz` y cambia el ejecutable por el nuevo, en su misma carpeta.
- **Android:** abre la descarga del APK; Android pide confirmar la instalación (ninguna app puede instalarse sola).

Si algo falla, el aviso ofrece **DESCARGAR** para bajarla a mano. Sin internet no se muestra nada. Se apaga en Configuración > Sonido > «Buscar actualizaciones al abrir». La partida vive aparte y no se toca. La versión del juego está en `project.godot` (`application/config/version`) y el CI comprueba que coincida con `export_presets.cfg`. El código está en `scripts/actualizador.gd` y sus pruebas en `tests/update_test.gd`.

La arquitectura del código, las buenas prácticas que sigue y el plan por fases para separarlo en escenas están en [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md).

Para los controles móviles y sus limitaciones, consulta la [guía Android y Vigilia](docs/MOVIL_Y_VIGILIA.md).

## Jugar en Windows (versión de prueba)

Cada release incluye, junto al APK, dos archivos para Windows 10/11 de 64 bits:

- **`ElTemploDeLosEcos-vX-Windows-Setup.exe`**: instalador. No pide permisos de administrador. Instala en `%LOCALAPPDATA%\Programs\El Templo de los Ecos`, crea accesos en el menú Inicio y el escritorio, y se desinstala desde «Aplicaciones instaladas». Se actualiza solo desde el juego (ver «Actualizaciones automáticas») o instalando la versión nueva encima: la partida se conserva.
- **`ElTemploDeLosEcos-vX-Windows-Portable.zip`**: el mismo juego sin instalar. Se descomprime y se abre `ElTemploDeLosEcos.exe`.

No está firmado, así que Windows puede avisar con «Windows protegió tu PC»: **Más información → Ejecutar de todas formas**. El instalador trae un `LEEME.txt` (también en el menú Inicio) con los controles y cómo reportar errores. Lo más útil de un reporte es el registro del juego, en `%APPDATA%\Godot\app_userdata\El Templo de los Ecos\logs\godot.log`.

El instalador se genera con NSIS a partir de `instalador/windows/instalador.nsi` (ver el comentario del archivo para compilarlo a mano).

## Jugar en Linux (versión de prueba)

Cada release incluye también **`ElTemploDeLosEcos-vX-Linux-x86_64.tar.gz`** (Linux de 64 bits con OpenGL 3.3). Se descomprime y:

- **sin instalar:** se abre `ElTemploDeLosEcos.x86_64` (doble clic o `./ElTemploDeLosEcos.x86_64`);
- **instalado:** `./instalar.sh` lo copia a `~/.local/share/el-templo-de-los-ecos` y lo añade al menú de aplicaciones, sin `sudo`. Volver a ejecutarlo con una versión nueva actualiza el juego y conserva la partida.

El registro para reportar errores está en `~/.local/share/godot/app_userdata/El Templo de los Ecos/logs/godot.log`. Los scripts y el `LEEME.txt` están en `instalador/linux/`.

## Descargar y ejecutar en Fedora / Linux (desde el código)

Para jugar no hace falta el código: usa las descargas de arriba. Si quieres el proyecto fuente, cada [versión publicada](https://github.com/je7remy/el-templo-de-los-ecos/releases) trae también el ZIP del código: descomprímelo y abre `project.godot` con Godot 4.3 o superior.

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
| Enter | En el menú, JUGAR (elegir piso); tras morir, levantarte |
| O (perfil) | Cambiar entre EQUIPO y OBJETOS; Enter usa el objeto señalado |
| H | Abrir Vigilia del Claustro desde el menú |
| W / A / S / D o flechas | Moverse |
| E | Interactuar (sello, carta, altar). Si no hay nada cerca y la antorcha arde, golpear. Almas, objetos y puertas abiertas funcionan al tocarlos |
| Clic izquierdo | Golpe de antorcha |
| F | Encender (gasta un fósforo) o apagar la antorcha |
| I o Tab | Perfil (en móvil, tocar el retrato) |
| ESC | Pausa (en móvil, el botón de pausa) |
| Espacio | Esquivar |
| Q | Resonancia: onda que daña y aturde (después de adquirirla) |
| K | Habilidades |
| Flechas/WASD + Enter en Vigilia | Elegir baldosa y abrir su menú (1–3 eligen opción) |
| Espacio en Vigilia | Dormir o levantarse |
| P en Vigilia | Pausar o reanudar |

Todas las teclas se pueden cambiar en *Configuración > Controles*; las flechas siempre mueven.

### Mando (Xbox 360, Xbox One/Series, PlayStation, Switch Pro y similares)

Basta con conectarlo; el juego avisa al detectarlo y cambia los textos de ayuda a los botones del mando. Los nombres son los de Xbox: en PlayStation, A = ✕, B = ○, X = □, Y = △.

| Botón | En la partida | En los menús |
| --- | --- | --- |
| Stick izquierdo / cruceta | Moverse | Recorrer opciones |
| A | Interactuar o golpear | Aceptar |
| RT | Golpe de antorcha | — |
| B / LT | Esquivar | Volver |
| X | Encender o apagar la antorcha | Borrar letra (nombre) |
| Y | Resonancia | Nombre al azar · Pisos (menú) |
| SELECT | Mapa grande (piso y descenso) |
| LB | Perfil | Pestañas (configuración) · SELECT abre la configuración en el menú |
| RB | Habilidades | Pestañas · Vigilia (menú) |
| START | Pausa | Aceptar · Seguir (nombre) |

En la Vigilia, la cruceta mueve el recuadro por las baldosas, A abre el menú o elige, Y duerme, RB potencia, X activa el escudo y B cierra o sale. El esquema del mando es fijo; las teclas se reasignan con el teclado. Si el mando se desconecta durante la partida, el juego se pausa.

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
godot --headless --path . --script res://tests/update_test.gd
godot --headless --path . --script res://tests/pantallas_test.gd
godot --headless --path . --script res://tests/entidades_test.gd
```

`pantallas_test.gd` comprueba la arquitectura por escenas: los autoloads, la máquina de estados, que todas las pantallas respondan a clics y teclas de verdad y el HUD. `entidades_test.gd` comprueba el jugador, la entidad de la sala y las manadas de criaturas, los jefes y el Peregrino con sus máquinas de estados. `comprobar_archivos.py` comprueba los archivos esenciales, que cada PNG conserve su `.import`, que no haya `.gd.uid` huérfanos y que el proyecto declare Godot 4.3 y filtrado nearest-neighbor. `visual_asset_test.gd` verifica además que las cinco salas conserven su arquitectura, objetos, marcadores y colisiones.

**Publicación:** cuando un cambio llega a `main` con una versión nueva en `export_presets.cfg` (y sus notas en `docs/releases/vX.md`), el CI compila Android, Windows y Linux, publica la versión con esos archivos y la marca como **la última** (*Latest*). También sube copias con nombre fijo (`ElTemploDeLosEcos-Windows-Setup.exe`, etc.) para que los enlaces `releases/latest/download/…` sirvan siempre. Una versión ya publicada no se recompila.

## Estructura del proyecto

```text
assets/                 Arte: escenario (Knowledge Temple), entidades, tiles, objetos y marca
  visual/enemies/       Entidades originales (Testigo, Ghoul de brasas, Hechicero)
  visual/tiles/         Atlas de la arquitectura de las salas
  visual/objetos/       Columnas, estatuas, braseros, mesa, sarcófago… por sala
  visual/iconos/        Iconos de mochila, habilidades, HUD y botones de Vigilia
  visual/retratos/      Retrato de Mark (normal y herido)
  visual/decorados/     Restos, sangre, velas, estandartes y cadenas de las salas
  fonts/                Jersey 15 y Jacquard 24 (licencia OFL)
audio/                  Música y efectos originales (OGG)
rooms/                  Escenas editables de las cinco salas y su TileSet
shaders/                Luz y tinte de cada sala
scenes/                 Escena principal y Vigilia del Claustro
  pantallas/            Inicio, menú principal y pausa (una escena cada una) y su gestor
  ui/                   Piezas de interfaz: botón, avisos, aviso de actualización
  autoload/             Cambio de escena con pantalla de carga
scripts/                Lógica de juego en GDScript
  autoload/             Eventos (bus de señales) y Progreso (guardado)
  comun/                Máquina de estados genérica
  pantallas/            Scripts de las pantallas
  ui/                   Estilo común y piezas de interfaz
  datos/                Pisos, conversaciones y textos en español e inglés
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

## Acuerdo de usuario y privacidad

El juego muestra un acuerdo de usuario la primera vez y no recoge datos personales: solo guarda progreso y ajustes en el equipo. Los textos completos están en [`docs/legal/`](docs/legal/) y son **borradores** pendientes de revisión legal antes de vender el juego.

## Créditos y uso de los assets

- **Knowledge Temple — pingupollas:** escenario, suelos, muros y decoraciones (columnas, estatuas, braseros, altar, mesa, libro). [Página original](https://pingupollas.itch.io/knowledge-temple). El autor **exige crédito** y permite usar y modificar el material en proyectos personales y comerciales, pero **prohíbe redistribuir el pack como un paquete de recursos independiente**. Los recursos integrados aquí no se ofrecen como paquete de sprites.
- **GothicVania Church Pack — Luis Zuno (Ansimuz):** proyectiles de fuego del Hechicero. Los sprites de Angel, Burning Ghoul y Skeleton Wizard se conservan en el repositorio como respaldo. [Página original](https://ansimuz.itch.io/gothicvania-church-pack) · [Publicación CC0](https://opengameart.org/content/gothicvania-church-pack). Atribución voluntaria y apreciada.
- **Arte original del proyecto:** entidades, pilares y remates del marco de las salas (sobre ladrillos de Knowledge Temple), interfaz e identidad gráfica.

**Importante:** las licencias de terceros no significan que todo el código y el universo narrativo del juego estén bajo CC0. Consulta [assets y licencias](docs/ASSETS_Y_LICENCIAS.md) antes de reutilizar el contenido.

---

Desarrollado por [@je7remy](https://github.com/je7remy). **Último release: v0.5.49-alpha** (se publica al fusionar esta versión en `main`).
