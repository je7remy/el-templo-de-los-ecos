# Editar salas y entidades

Las salas son escenas normales de Godot: `rooms/sala_0.tscn` … `rooms/sala_9.tscn` (diez distribuciones que comparten los 41 cuartos de la campaña; cada sala de `datos/pisos/` dice cuál usa en «escena»). Las cinco últimas (`sala_5` … `sala_9`) parten de la arquitectura y los marcadores de `sala_0` … `sala_4` con otros objetos y otra luz; se generan con `herramientas/construir_salas_nuevas.gd` (o se retocan a mano en el editor). Ábrelas en el editor y modifícalas como cualquier escena. El juego (`scripts/main.gd`) lee de ellas la arquitectura, los objetos, las posiciones y las colisiones al entrar en cada sala.

## Estructura de una sala

| Nodo | Tipo | Para qué sirve |
| --- | --- | --- |
| `Arquitectura` | `TileMapLayer` | Suelo, muros cerrados con pilares en las esquinas y vacío exterior. Tiles de 32 × 32 del atlas `assets/visual/tiles/templo.png` (`rooms/templo_tileset.tres`). Pinta, borra o mueve tiles con el editor de TileMap. |
| `Suelo` | `Node2D` | Detalles pintados sobre el suelo (p. ej. `RunaSuelo`). Siempre quedan bajo personajes y objetos. |
| `Objetos` | `Node2D` | Columnas, estatuas, braseros, mesa, sarcófago… Un `Sprite2D` por objeto. |
| `Objetos/<objeto>/Colision` | `StaticBody2D` + `CollisionShape2D` | Bloqueo del objeto. Es hija del sprite: **si mueves el objeto, su colisión lo acompaña**. |
| `Colisiones` | `StaticBody2D` | Bloqueos que no pertenecen a un solo objeto (altar, grupo de cirios). |
| `Marcadores` | `Marker2D` | Posiciones de juego: `Jugador`, `Enemigo`, `Salida`, `Reliquia1-3`, y según la sala `Altar`, `Sello`, `Ojo`, `Libro`, `Lectura`, `Madera` (sala 1) y `Fosforos` (salas 1, 3 y 4). |

### Reglas importantes
- **La posición de cada objeto es su base** (el punto donde toca el suelo). Esa `y` decide si un personaje se dibuja delante o detrás. El dibujo se desplaza con `offset`; si cambias la textura de un objeto, ajusta `offset` para que la base siga en la posición del nodo.
- En partida los `Sprite2D` de `Objetos` se ocultan porque el juego los dibuja ordenados junto con los personajes. En el editor se ven normales.
- Metadatos de cada objeto: `sombra` (bool, sombra de contacto suave) y `luz` (bool, halo animado de brasero).
- **Simetría:** los objetos van en el eje central (x = 480) o en parejas en espejo. El de la derecha usa la misma textura con `flip_h` activado. Si mueves uno de una pareja, mueve el otro a `960 - x` para conservar la simetría.
- **Almas y cuerpos:** bajo cada `Reliquia` el juego dibuja el cuerpo de su antiguo dueño (`assets/visual/cuerpos/`, generados con `herramientas/generar_cuerpos.py`). Al mover el marcador, el cuerpo lo acompaña.
- **Puerta:** al tocar el marcador `Salida` con la sala lista, el personaje cruza solo (también con E).
- Solo se usan colisiones **rectangulares** (`RectangleShape2D`). Una forma desactivada (`disabled`) no bloquea.
- **Todos los objetos son sólidos.** La colisión cubre solo la base (pedestal o pie) para poder pasar por detrás de la figura. Si añades un objeto nuevo, dale su `Colision`; el test `visual_asset_test.gd` falla si alguno queda atravesable. El juego amplía cada colisión 15,5 px (radio del personaje).
- Si borras un marcador, el juego usa la posición por defecto de `scripts/main.gd`. Los tests (`tests/visual_asset_test.gd`) exigen que existan los marcadores básicos.
- La luz y el tinte de cada sala se aplican a `Arquitectura` con `shaders/luz_sala.gdshader` (parámetros `ganancia` y `desplazamiento`). Los objetos ya traen su luz en el PNG.

### Comprobar tras editar
```bash
godot --headless --path . --script res://tests/visual_asset_test.gd
godot --headless --path . --script res://tests/smoke_test.gd
```
Comprueba también a mano que las reliquias, la puerta y los objetos interactivos siguen siendo alcanzables.

## Pisos
Los pisos se declaran en `FLOORS`, al principio de `scripts/main.gd`. Cada sala indica qué escena usa (`scene`: el número de `rooms/sala_N.tscn`), su nombre, su susurro, su entidad (`enemy`), sus rasgos (`traits`: `tutorial`, `altar`, `sello`, `archivo`, `almas`, `peregrino`, `cosecha`, `aliados`, `caza`, `huida`, `recuento`, `raices_puerta`). Campos opcionales: `mission`, `traps`, `inscription`, `vines` y sus objetos (`items`). Una misma escena se puede reutilizar en varios pisos: el desgaste (`wear`) añade grietas, cascotes y un tono más apagado. El código consulta rasgos, nunca números de sala, así que un piso nuevo es, sobre todo, una entrada de datos más. El diseño de los diez pisos está en el documento del proyecto «DISEÑO DE 10 PISOS».

## Regenerar desde las composiciones originales
Solo si quieres empezar de cero (**sobrescribe las escenas y se pierden los cambios hechos a mano**):
```bash
python3 herramientas/construir_salas.py          # atlas, objetos y herramientas/salas.json (aplica la simetría)
godot --headless --path . --import
godot --headless --path . --script res://herramientas/construir_salas.gd   # escenas .tscn
```

## Entidades
Los sprites originales y cenitales del Testigo, el Ghoul de brasas y el Hechicero del archivo se generan con `python3 herramientas/generar_enemigos.py` en `assets/visual/enemies/`. Son celdas de 48 × 64 (pies en y = 61). Las filas son abajo, arriba, derecha e izquierda. El Testigo tiene las columnas 0-3 con el ojo abierto y las 4-7 cerrado. Puedes retocar los PNG directamente o cambiar el generador y volver a ejecutarlo. Los sprites de GothicVania siguen en `assets/gothic_enemies/` como respaldo.
