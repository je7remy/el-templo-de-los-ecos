extends SceneTree
## Capturas 1920x1080 (16:9) para la página de tienda: siete momentos de
## juego en el idioma pedido. Ejecutar con pantalla (no headless):
##   godot --path . --resolution 1920x1080 --script res://herramientas/tienda/capturas.gd -- --lang=en --out=/tmp/tienda
## Usa el modo de pruebas (no toca la partida guardada).
var g: Node
var step := 0
var lang := "es"
var out := ""
var sc := []
var i := 0
var t0 := 4
func _initialize() -> void:
	var base := "/tmp/tienda"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--lang="): lang = a.substr(7)
		if a.begins_with("--out="): base = a.substr(6)
	out = "%s/%s/" % [base, lang]
	DirAccess.make_dir_recursive_absolute(out)
	Engine.set_meta("modo_prueba", true)
	Engine.set_meta("splash_visto", true)
	for f in ["user://prueba_progreso.json", "user://prueba_ajustes.cfg"]:
		if FileAccess.file_exists(f): DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
	load("res://scripts/ajustes.gd").poner("idioma", lang)
	g = load("res://scenes/main.tscn").instantiate()
	root.add_child(g)
	sc = [
		["01_testigo", 30, func():
			_floor(0, 2); g.set("player_pos", Vector2(430, 480)); g.set("player_dir", Vector2(0, -1))
			g.set("enemy_pos", Vector2(660, 300)); g.set("enemy_alert", true); g.set("enemy_facing", 3),
		 func(): g.set("watcher_open", true); g.set("room_elapsed", 1.0)],
		["03_tejedora", 25, func():
			_floor(3, 1)
			var cells: Dictionary = g.get("vines")
			for c in cells:
				if c.y == int(410 / 32): g.call("_ignite", c)
			g.set("enemy_pos", Vector2(600, 300)); g.set("player_pos", Vector2(420, 330)); g.set("player_dir", Vector2(1, 0)),
		 func(): pass],
		["04_mastines", 40, func():
			_floor(4, 1); g.set("player_pos", Vector2(560, 480))
			var hs: Array = g.get("hounds")
			if hs.size() >= 2: hs[0]["pos"] = Vector2(470, 480); hs[1]["pos"] = Vector2(640, 380),
		 func(): pass],
		["05_vigia", 40, func():
			g.set("guided", ["IRENE", "BAS", "SAÚL"])
			_floor(6, 1); g.set("player_pos", Vector2(480, 470))
			g.set("gaze_t", 17.0); g.set("gaze_feint_t", 99.0); g.set("gaze_noise_t", 99.0),
		 func(): g.set("player_dir", (Vector2(g.get("gaze_pos")) - Vector2(480, 470)).normalized())],
		["06_coloso", 14, func():
			_floor(8, 2); g.set("player_pos", Vector2(520, 470)); g.set("colossus_pos", Vector2(640, 440))
			g.set("colossus_hits", 1); var cols: Array = g.get("pillars")
			if cols.size() > 3: cols[3]["fallen"] = true; cols[3]["fall_dir"] = Vector2(1, -0.3),
		 func(): g.set("colossus_state", "raise"); g.set("colossus_t", 0.4)],
		["07_hermano", 60, func():
			g.set("guided", ["IRENE", "BAS", "SAÚL"]); g.set("karma", 5)
			_floor(9, 3); g.set("player_pos", Vector2(420, 400))
			g.call("_update_harvest", 2.0); g.set("elder_rule", 0); g.set("elder_cd", 0.0),
		 func(): pass],
	]
var vg: Node
var vs := 0
## La Vigilia, con defensas puestas, a mitad de la fase 3.
func _vigilia() -> bool:
	vs += 1
	match vs:
		1:
			g.queue_free()
			vg = load("res://scenes/defense.tscn").instantiate()
			root.add_child(vg)
		4: vg.call("_start", 0)
		8:
			vg.call("_action", 0); vg.set("income", 3000.0)
			for t in [Vector2i(8,3), Vector2i(9,2), Vector2i(9,4), Vector2i(4,1), Vector2i(5,5)]: vg.call("_build", "centinela", t)
			vg.call("_build", "generador", Vector2i(0,0)); vg.call("_build", "campana", Vector2i(10,0)); vg.call("_build", "campana", Vector2i(10,6))
			for k in 4: vg.call("_upgrade", Vector2i(8,3))
			vg.set("stage", 3); vg.call("_begin_stage"); vg.call("_advance", 10.0); vg.set("info_time", 0.0)
		60: root.get_texture().get_image().save_png(out + "08_vigilia.png")
	return vs > 62


func _floor(f: int, r: int) -> void:
	g.set("player_name", "SELENE"); g.set("player_gender", "femenino")
	if f != 9: g.set("karma", 0)
	g.call("_start_floor", f); g.call("_enter_floor"); g.call("_dialog_skip")
	g.set("current_room", r); g.call("_enter_room")
	for k in range(6): g.call("_dialog_skip")
	g.set("game_mode", "play"); g.set("has_torch", true); g.set("torch_on", true); g.set("matches", 3)
	g.set("toast_left", 0.0); g.set("motes", [])
func _process(_d: float) -> bool:
	step += 1
	if step < 4: return false
	if i >= sc.size(): return _vigilia()
	var k := step - t0
	if k == 0: sc[i][2].call()
	if k == 2: sc[i][3].call()
	if k > 0:
		g.set("damage_cd", 0.0); g.set("hp", g.get("max_hp")); g.set("xp", 0); g.set("fear", 0.0); g.set("toast_left", 0.0)
		if k > 1: g.call("_dialog_skip")
		for h in (g.get("hounds") as Array): h["bite_cd"] = 99.0
	if sc[i][0] == "07_hermano" and k == int(sc[i][1]) - 14:
		g.call("_elder_next_rule", true); g.set("elder_pos", Vector2(640, 330))
	if k == int(sc[i][1]):
		root.get_texture().get_image().save_png(out + sc[i][0] + ".png")
		i += 1; t0 = step + 1
	return false
