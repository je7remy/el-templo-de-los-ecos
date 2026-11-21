extends SceneTree
## Paso 2/2 de la conversión a salas editables (el paso 1 es construir_salas.py).
## Genera rooms/templo_tileset.tres y rooms/sala_N.tscn a partir de herramientas/salas.json.
##
##   godot --headless --path . --import
##   godot --headless --path . --script res://herramientas/construir_salas.gd
##
## AVISO: sobrescribe las escenas de las salas; los cambios hechos en el editor
## se pierden. Úsalo solo para regenerar desde cero.

const DATOS := "res://herramientas/salas.json"
const ATLAS := "res://assets/visual/tiles/templo.png"
const TILESET := "res://rooms/templo_tileset.tres"
const SHADER := "res://shaders/luz_sala.gdshader"


func _initialize() -> void:
	call_deferred("_construir")


func _construir() -> void:
	var texto := FileAccess.get_file_as_string(DATOS)
	var datos: Dictionary = JSON.parse_string(texto)
	if datos.is_empty():
		push_error("No se pudo leer " + DATOS)
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://rooms"))
	var tile: int = int(datos["tile"])
	var columnas: int = int(datos["atlas_columnas"])
	var rejilla: Array = datos["rejilla"]
	var total: int = 0
	for fila in rejilla:
		for indice in fila:
			total = maxi(total, int(indice) + 1)

	var conjunto := TileSet.new()
	conjunto.tile_size = Vector2i(tile, tile)
	var fuente := TileSetAtlasSource.new()
	fuente.texture = load(ATLAS)
	fuente.texture_region_size = Vector2i(tile, tile)
	for i in range(total):
		fuente.create_tile(Vector2i(i % columnas, i / columnas))
	conjunto.add_source(fuente, 0)
	if ResourceSaver.save(conjunto, TILESET) != OK:
		push_error("No se pudo guardar " + TILESET)
		quit(1)
		return
	conjunto = load(TILESET)
	var shader: Shader = load(SHADER)

	var salas: Array = datos["salas"]
	for n in range(salas.size()):
		var sala: Dictionary = salas[n]
		var raiz := Node2D.new()
		raiz.name = "Sala%d" % (n + 1)

		var capa := TileMapLayer.new()
		capa.name = "Arquitectura"
		capa.tile_set = conjunto
		capa.position = Vector2(datos["origen"][0], datos["origen"][1])
		var material := ShaderMaterial.new()
		material.shader = shader
		var luz: Dictionary = sala["luz"]
		material.set_shader_parameter("ganancia", Vector3(luz["ganancia"][0], luz["ganancia"][1], luz["ganancia"][2]))
		material.set_shader_parameter("desplazamiento", Vector3(luz["desplazamiento"][0], luz["desplazamiento"][1], luz["desplazamiento"][2]))
		capa.material = material
		for fy in range(rejilla.size()):
			var fila: Array = rejilla[fy]
			for fx in range(fila.size()):
				var indice: int = int(fila[fx])
				capa.set_cell(Vector2i(fx, fy), 0, Vector2i(indice % columnas, indice / columnas))
		_agregar(raiz, raiz, capa)

		# Detalles pintados en el suelo: siempre bajo personajes y objetos.
		var suelo := Node2D.new()
		suelo.name = "Suelo"
		_agregar(raiz, raiz, suelo)
		for d in sala.get("decales", []):
			var decal := Sprite2D.new()
			decal.name = d["nodo"]
			decal.texture = load(d["textura"])
			decal.centered = false
			decal.position = Vector2(d["posicion"][0], d["posicion"][1])
			_agregar(raiz, suelo, decal)

		var objetos := Node2D.new()
		objetos.name = "Objetos"
		_agregar(raiz, raiz, objetos)
		for o in sala["objetos"]:
			var sprite := Sprite2D.new()
			sprite.name = o["nodo"]
			sprite.texture = load(o["textura"])
			sprite.centered = false
			# La posición del nodo es la base del objeto: ordena la profundidad.
			sprite.position = Vector2(o["ancla"][0], o["ancla"][1])
			sprite.offset = Vector2(o["offset"][0], o["offset"][1])
			sprite.set_meta("sombra", bool(o["sombra"]))
			sprite.set_meta("luz", bool(o["luz"]))
			# Parejas simétricas: el objeto de la derecha es el espejo del izquierdo.
			sprite.flip_h = bool(o.get("flip", false))
			_agregar(raiz, objetos, sprite)
			if o.has("colision"):
				_colision(raiz, sprite, "Colision", o["colision"], sprite.position)

		var sueltas := StaticBody2D.new()
		sueltas.name = "Colisiones"
		_agregar(raiz, raiz, sueltas)
		var k: int = 1
		for c in sala["colisiones"]:
			_colision(raiz, sueltas, "Bloqueo%d" % k, c, Vector2.ZERO, true)
			k += 1

		var marcas := Node2D.new()
		marcas.name = "Marcadores"
		_agregar(raiz, raiz, marcas)
		var nombres: Array = sala["marcadores"].keys()
		nombres.sort()
		for nombre in nombres:
			var m := Marker2D.new()
			m.name = nombre
			m.position = Vector2(sala["marcadores"][nombre][0], sala["marcadores"][nombre][1])
			m.gizmo_extents = 14.0
			_agregar(raiz, marcas, m)

		var escena := PackedScene.new()
		escena.pack(raiz)
		var ruta := "res://rooms/sala_%d.tscn" % n
		if ResourceSaver.save(escena, ruta) != OK:
			push_error("No se pudo guardar " + ruta)
			quit(1)
			return
		raiz.free()
		print("OK: ", ruta)
	quit(0)


func _agregar(raiz: Node, padre: Node, hijo: Node) -> void:
	padre.add_child(hijo)
	hijo.owner = raiz


func _colision(raiz: Node, padre: Node, nombre: String, datos: Dictionary, origen: Vector2, directo: bool = false) -> void:
	var cuerpo: Node = padre
	if not directo:
		cuerpo = StaticBody2D.new()
		cuerpo.name = nombre
		_agregar(raiz, padre, cuerpo)
	var forma := CollisionShape2D.new()
	forma.name = nombre if directo else "Forma"
	var rect := RectangleShape2D.new()
	rect.size = Vector2(datos["tamano"][0], datos["tamano"][1])
	forma.shape = rect
	forma.position = Vector2(datos["centro"][0], datos["centro"][1]) - origen
	_agregar(raiz, cuerpo, forma)
