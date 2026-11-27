extends SceneTree
## Fondo limpio (sin HUD) para las cápsulas de la tienda: sala VII-4.
##   godot --path . --resolution 1920x1080 --script res://herramientas/tienda/fondo.gd -- --out=/tmp/tienda
var g: Node
var step := 0
var out := "/tmp/tienda"
func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="): out = a.substr(6)
	DirAccess.make_dir_recursive_absolute(out)
	Engine.set_meta("modo_prueba", true)
	Engine.set_meta("splash_visto", true)
	g = load("res://scenes/main.tscn").instantiate()
	root.add_child(g)
func _process(_d: float) -> bool:
	step += 1
	if step == 4:
		g.call("_start_floor", 6); g.call("_enter_floor"); g.call("_dialog_skip")
		g.set("current_room", 3); g.call("_enter_room")
		for k in 6: g.call("_dialog_skip")
		g.set("game_mode", "play"); g.set("has_torch", true); g.set("torch_on", true)
		g.set("player_pos", Vector2(480, 560)); g.set("player_dir", Vector2(0, -1))
	if step > 4:
		g.set("toast_left", 0.0); g.set("damage_cd", 0.0); g.set("hp", g.get("max_hp"))
		for n in ["Hud", "Pantallas", "CapaAvisos"]:
			var c = g.get_node_or_null(n)
			if c: c.visible = false
	if step == 40:
		root.get_texture().get_image().save_png(out + "/fondo.png")
		return true
	return false
