extends CanvasLayer
## HUD de la Vigilia (scenes/vigilia/hud.tscn): barras de arriba y de abajo,
## aviso, tutorial y menú de la baldosa, en ese orden (lo último tapa a lo
## anterior). La Vigilia (scripts/defense.gd) le pasa los datos de cada pieza
## en cada cuadro; las pantallas (portada, pausa…) van por encima.


## datos: nombre de la pieza → sus datos (vacío = no se ve).
func actualizar(datos: Dictionary) -> void:
    for pieza in get_children():
        pieza.call("actualizar", datos.get(String(pieza.name), {}))


func pieza(nombre: StringName) -> Node:
    return get_node_or_null(NodePath(String(nombre)))


## La celda va centrada en pantallas anchas: el HUD, con ella.
func ajustar_margen(m: Vector2) -> void:
    offset = m
