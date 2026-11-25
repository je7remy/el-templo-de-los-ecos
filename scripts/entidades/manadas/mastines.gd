extends "res://scripts/entidades/manadas/manada.gd"
## Mastines de Relicario: temen al fuego. Estados: Vaga (lejos, alrededor de
## su sitio), Ronda (te ven con la antorcha encendida: guardan distancia y
## gruñen), Carga (a oscuras: cargan y muerden) y Huye (tras morder, un golpe
## de antorcha o la Resonancia). Valores PROVISIONALES.

## Gruñe (la campaña pone el sonido).
signal grunido(mastin: Dictionary)
## Muerde: la campaña decide si te alcanza (esquive, invulnerabilidad).
signal mordisco(mastin: Dictionary)

const VELOCIDAD := 70.0
const CARGA := 165.0
const DISTANCIA := 100.0 # distancia que guardan ante el fuego (≈ dos casillas)
const VISTA := 290.0


## «antorcha»: si la llevas encendida.
func actualizar(lista: Array, dt: float, antorcha: bool) -> void:
    for h in lista:
        var pos: Vector2 = h["pos"]
        var d: float = pos.distance_to(jugador.position)
        var lejos: Vector2 = (pos - jugador.position).normalized() if d > 0.1 else Vector2.RIGHT
        h["bite_cd"] = maxf(0.0, float(h["bite_cd"]) - dt)
        h["bite_t"] = maxf(0.0, float(h["bite_t"]) - dt)
        if float(h["flee"]) > 0.0:
            poner(h, "Huye")
        elif d < VISTA:
            poner(h, "Ronda" if antorcha else "Carga")
        else:
            poner(h, "Vaga")
        actuar(h, dt, {"d": d, "lejos": lejos, "pos": pos})
        mirar(h, 5.0, dt)


## Avanza en «dir»; si choca, rodea un momento por un lado.
func mover(h: Dictionary, dir: Vector2, velocidad: float, dt: float) -> void:
    if dir.length() < 0.01:
        return
    if float(h["detour_t"]) > 0.0:
        h["detour_t"] = float(h["detour_t"]) - dt
        dir = h["detour"]
    var pos: Vector2 = h["pos"]
    var sig: Vector2 = pos + dir.normalized() * velocidad * dt
    if not bloqueado(sig):
        h["pos"] = sig
        return
    var perp := Vector2(-dir.y, dir.x).normalized()
    for c in [perp, -perp, -dir.normalized()]:
        var prueba: Vector2 = pos + (c as Vector2) * velocidad * dt
        if not bloqueado(prueba):
            h["pos"] = prueba
            h["detour"] = c
            h["detour_t"] = 0.6
            return
