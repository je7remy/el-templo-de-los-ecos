extends "res://scripts/entidades/manadas/manada.gd"
## Arietes de Piedra: de piedra hasta que embisten. Estados (guardados en
## «state» como antes): Quieto ("idle"), Apunta ("aim", línea roja), Embiste
## ("charge") y Aturdido ("stun", tras chocar: entonces se rompen).
## Valores PROVISIONALES.

## Se alinea contigo y apunta.
signal apunta(ariete: Dictionary)
## Arranca la embestida.
signal embiste(ariete: Dictionary)
## Choca contra un muro o columna («en»: dónde estaba).
signal choca(ariete: Dictionary, en: Vector2)
## Te alcanza en plena carrera: la campaña decide si te hiere y te empuja.
signal alcanza(ariete: Dictionary)

const VISTA := 330.0
const ALINEADO := 24.0
const APUNTA := 0.6
const VELOCIDAD := 430.0
const ATURDIDO := 2.0


func _ready() -> void:
    clave = "state"
    nombres = {"idle": "Quieto", "aim": "Apunta", "charge": "Embiste", "stun": "Aturdido"}


func actualizar(lista: Array, dt: float) -> void:
    for r in lista:
        r["cd"] = maxf(0.0, float(r["cd"]) - dt)
        actuar(r, dt, {"pos": Vector2(r["pos"])})
        var hacia: Variant = Vector2(r["dir"]) if str(r["state"]) in ["aim", "charge"] else null
        var movido: Vector2 = Vector2(r["pos"]) - Vector2(r["prev"])
        if hacia == null:
            hacia = movido if movido.length() > 0.1 else jugador.position - Vector2(r["pos"])
        if (hacia as Vector2).length() > 0.1:
            r["facing"] = (2 if hacia.x > 0.0 else 3) if absf(hacia.x) > absf(hacia.y) else (0 if hacia.y > 0.0 else 1)
        r["moving"] = movido.length() > 4.0 * dt
        r["prev"] = r["pos"]


# ------------------------------------------------------------ DIBUJO
const Lienzo := preload("res://scripts/comun/lienzo.gd")
const HOJA := preload("res://assets/visual/enemies/ariete.png")


## Dibuja el ariete «i»; aturdido, con su barra de vida.
func dibujar(c: CanvasItem, i: int, r: Dictionary, t: float) -> void:
    var cuadro: int
    match str(r["state"]):
        "aim":
            cuadro = 6
        "charge":
            cuadro = 2 + int(t * 14.0) % 4
        "stun":
            cuadro = 7
        _:
            cuadro = 2 + int(t * 8.0) % 4 if bool(r.get("moving", false)) else int(t * 2.0 + float(i)) % 2
    var pos: Vector2 = Vector2(r["pos"]).round()
    Lienzo.sombra(c, pos + Vector2(0, 3), 16.0)
    var tinte := Color(1.0, 0.85, 0.6) if str(r["state"]) == "stun" else Color.WHITE
    c.draw_texture_rect_region(HOJA, Rect2(pos.x - 24.0, pos.y + 4.0 - Lienzo.PIES, 48, 64), Rect2(float(cuadro) * 48.0, float(r["facing"]) * 64.0, 48, 64), tinte)
    if str(r["state"]) == "stun":
        var barra := Rect2(pos.x - 20.0, pos.y - 62.0, 40, 4)
        c.draw_rect(barra.grow(1.0), Color(0, 0, 0, 0.7))
        c.draw_rect(Rect2(barra.position, Vector2(barra.size.x * clampf(float(r["hp"]) / float(r["max"]), 0.0, 1.0), barra.size.y)), Color("#ffd36b"))
