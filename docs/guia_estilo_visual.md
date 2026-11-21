# Guía de estilo visual — El Templo de los Ecos

## Identidad
**Templo gótico reconocible + pixel art cenital + horror cósmico sutil.** La arquitectura conserva sentido físico antes de revelar pequeñas anomalías. No todo el juego debe estar a oscuras; la visibilidad genera confianza que el relato puede quebrar.

## Paleta
- Vacío: `#0D1219` · marcos: `#455452` · bordes ceremoniales: `#8D7957`.
- Texto principal: `#D9D2BA` · alma/resonancia: `#8FC7D7`.
- Sombra profunda: `#13181E` · verde pizarra protagonista: `#395359`.
- Daño: `#BD6B70` · sospecha/corrupción: `#843844`.
- Espectro de luz: ámbar tenue, no manchas blancas sin explicación.

## Pixel art y escala
- Base visual de los tiles originales Knowledge Temple: **16 × 16 px**. Las salas son escenas editables (`rooms/sala_N.tscn`) con `TileMapLayer` de **32 × 32 px** para la arquitectura y `Sprite2D` para los objetos. Ver `docs/EDITAR_SALAS.md`.
- Protagonista: **40 × 56 px** por fotograma, dibujado a tamaño nativo.
- Entidades: sprites originales cenitales de **48 × 64 px** por celda, en 4 direcciones (`assets/visual/enemies/`). Los de GothicVania (de perfil) se conservan como respaldo.
- Filtrado `Nearest` en el CanvasItem principal y parámetro de filtrado más próximo en `project.godot`. Si se amplía la ventana, se recomienda escala de pantalla entera. Un tamaño de pantalla de 1152 × 768 a partir de 960 × 640 no implica escalado entero perfecto.

## Diseño de escenarios
- Toda la composición existente se conserva: obstáculos, accesos, zonas transitables, altares e interacciones NO se desplazan.
- Las nuevas variantes solo corrigen contraste, reducen líneas de cuadrícula de construcción, añaden iluminación ambiental discreta y pequeños detalles de suelo.
- Cuatro nichos góticos originales y los dos braseros de cada lado funcionan como invariantes visuales; ahora son objetos editables de cada escena de sala.
- Simetría para la arquitectura ceremonial; una grieta o símbolo asimétrico será deliberado, no un error de colocación.
- Transición visual prevista: templo conservado → primera anomalía → corrupción localizada → arquitectura improbable. En el piso 1 solo se sugieren señales incipientes; NO se generan automáticamente nuevos pisos.

## Profundidad y capas
1. Textura de habitación.
2. Partículas de polvo simbólicas y pequeños halos.
3. Puertas y objetos con comportamientos intactos.
4. Enemigos y protagonista, ordenados según coordenada Y al dibujarse.
5. Efectos de linterna y de daño.
6. HUD y pantallas, por encima del mundo.

## Interfaz
- Cabecera de altura aproximada 103 px, pie de 65 px, contenido dentro de 960 × 640.
- Datos vitales con jerarquía cromática: vida roja, vigor verde, miedo ámbar; almas azul claro.
- Tipografía de respaldo de Godot. Pendiente integrar una fuente de pixel art licenciada y revisar acentos a resolución real.

## Iluminación y cámara
- Luz base de cada sala: `shaders/luz_sala.gdshader` sobre el TileMapLayer.
- **Penumbra dinámica** (`_draw_lighting` en `scripts/main.gd`): rejilla de oscuridad interpolada. El personaje lleva su luz (205 px con la linterna, 120 px sin ella); braseros, almas, conjuros, la salida abierta y el altar iluminan su entorno; las entidades siempre tienen algo de luz para que la amenaza se lea (juego limpio). La oscuridad máxima es 0,85: nunca negro total. Con miedo alto se oscurecen los bordes.
- El polvo ambiental se dibuja en tiempo real.
- No se incorporó una cámara nueva: la escena utiliza canvas fijo sin scroll. Alterar la cámara cambiaría la composición y la zona visible; necesita revisión independiente.
- La luz ha de proporcionar lectura de esquinas, puertas y amenazas. Se prohíbe usar negro uniforme como único medio de horror.

## Nuevos recursos
- Verificar licencia y perspectiva, escala, densidad de píxel, balance de contraste y anclaje de pies antes de integrar.
- No mezclar packs completos sin adaptar la dirección artística.
- Conservar assets originales intactos; crear variantes con rutas explícitas y pruebas de carga.
