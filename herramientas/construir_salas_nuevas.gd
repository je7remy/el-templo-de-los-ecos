extends SceneTree
## Crea rooms/sala_5.tscn … sala_9.tscn: cada una parte de una sala base
## (arquitectura, marcadores y bloqueos) y coloca otros objetos, con su
## colisión, copiados de las salas existentes. Sobrescribe esas cinco escenas.
##   godot --headless --path . --script res://herramientas/construir_salas_nuevas.gd

## Prototipos: [sala, nodo] de donde se copia cada objeto (textura, offset,
## metadatos y colisión).
const PROTO := {
    "brasero": [0, "Brasero1"], "columna": [0, "Columna1"], "arquero": [0, "EstatuaArquero1"],
    "orante_centro": [0, "EstatuaOrante1"], "pedestal": [0, "EstatuaPedestal1"], "orante": [1, "EstatuaOrante1"],
    "mesa": [3, "Mesa1"], "cirios": [3, "Cirios1"], "rota": [4, "ColumnaRota1"], "sarcofago": [4, "Sarcofago1"],
}

## Los braseros de las esquinas (88, 226) tapan el nicho del muro: van en todas.
## Cada sala nueva: base, tinte de la luz (ganancia, desplazamiento), si se
## quitan los bloqueos de la base, y objetos: [tipo, x, y, en espejo].
## «en espejo» pone además su pareja en 960 - x, girada.
const SALAS := {
    5: {"base": 0, "luz": [Vector3(1.45, 1.30, 1.25), Vector3(0.040, 0.030, 0.028)], "objetos": [
        ["columna", 190, 300, true], ["columna", 190, 470, true], ["rota", 390, 300, true],
        ["pedestal", 480, 400, false], ["orante_centro", 480, 200, false], ["brasero", 88, 226, true]]},
    6: {"base": 1, "luz": [Vector3(1.40, 1.45, 1.62), Vector3(0.030, 0.034, 0.045)], "objetos": [
        ["brasero", 88, 226, true], ["brasero", 360, 250, true], ["arquero", 170, 300, true], ["orante", 250, 520, true], ["columna", 360, 470, true]]},
    7: {"base": 2, "luz": [Vector3(1.55, 1.38, 1.30), Vector3(0.042, 0.032, 0.030)], "objetos": [
        ["arquero", 380, 240, true], ["sarcofago", 300, 410, true], ["pedestal", 180, 250, true],
        ["columna", 200, 500, true], ["brasero", 88, 226, true]]},
    8: {"base": 3, "luz": [Vector3(1.38, 1.42, 1.38), Vector3(0.032, 0.036, 0.030)], "objetos": [
        ["mesa", 480, 345, false], ["columna", 200, 250, true], ["orante_centro", 480, 200, false], ["rota", 380, 510, true],
        ["cirios", 318, 416, true], ["cirios", 298, 415, true], ["cirios", 280, 415, true], ["cirios", 260, 416, true],
        ["arquero", 150, 520, true], ["brasero", 88, 226, true]]},
    9: {"base": 4, "luz": [Vector3(1.32, 1.36, 1.50), Vector3(0.028, 0.030, 0.040)], "objetos": [
        ["sarcofago", 300, 470, true], ["columna", 380, 250, true], ["rota", 170, 300, true],
        ["orante", 200, 525, true], ["brasero", 88, 226, true]]},
}


func _initialize() -> void:
    var escenas := {}
    for i in 5:
        escenas[i] = load("res://rooms/sala_%d.tscn" % i).instantiate()
    for n in SALAS:
        var cfg: Dictionary = SALAS[n]
        var sala: Node = load("res://rooms/sala_%d.tscn" % cfg["base"]).instantiate()
        sala.name = "Sala%d" % (n + 1)
        var objetos: Node = sala.get_node("Objetos")
        for o in objetos.get_children():
            objetos.remove_child(o)
            o.free()
        var mat: ShaderMaterial = (sala.get_node("Arquitectura").material as ShaderMaterial).duplicate()
        mat.set_shader_parameter("ganancia", cfg["luz"][0])
        mat.set_shader_parameter("desplazamiento", cfg["luz"][1])
        sala.get_node("Arquitectura").material = mat
        var cuenta := {}
        for d in cfg["objetos"]:
            var posiciones := [[Vector2(d[1], d[2]), false]]
            if d[3]:
                posiciones.append([Vector2(960 - d[1], d[2]), true])
            for p in posiciones:
                var proto: Sprite2D = escenas[PROTO[d[0]][0]].get_node("Objetos/" + PROTO[d[0]][1])
                var copia: Sprite2D = proto.duplicate()
                cuenta[d[0]] = int(cuenta.get(d[0], 0)) + 1
                copia.name = (d[0] as String).capitalize().replace(" ", "") + str(cuenta[d[0]])
                copia.position = p[0]
                if p[1]:
                    copia.flip_h = not proto.flip_h
                    for hijo in copia.get_children():
                        if hijo is Node2D:
                            hijo.position.x = -hijo.position.x
                            for f in hijo.get_children():
                                if f is Node2D:
                                    f.position.x = -f.position.x
                objetos.add_child(copia)
        _poseer(sala, sala)
        var empaquetada := PackedScene.new()
        assert(empaquetada.pack(sala) == OK)
        assert(ResourceSaver.save(empaquetada, "res://rooms/sala_%d.tscn" % n) == OK)
        print("rooms/sala_%d.tscn: %d objetos" % [n, objetos.get_child_count()])
        sala.free()
    for i in escenas:
        escenas[i].free()
    quit(0)


func _poseer(n: Node, raiz: Node) -> void:
    for h in n.get_children():
        h.owner = raiz
        _poseer(h, raiz)
