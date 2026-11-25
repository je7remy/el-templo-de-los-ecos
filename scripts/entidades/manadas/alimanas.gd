extends "res://scripts/entidades/manadas/manada.gd"
## Alimañas (ratas, murciélagos, arañas): patrullan su trayecto, huelen la
## sangre y se lanzan; esquivando se aplastan, si no, muerden. Estados:
## Patrulla, Persigue y Muerta (el nido la repone al rato).

## Te muerde (ya con su espera puesta). «info»: datos del tipo.
signal mordisco(criatura: Dictionary, info: Dictionary)
## La aplastas esquivando.
signal aplastada(criatura: Dictionary)

const REAPARECE := 9.0


## «tipos»: CRITTER_KINDS de la campaña.
func actualizar(lista: Array, dt: float, tipos: Dictionary) -> void:
    for cr in lista:
        if not bool(cr["alive"]):
            poner(cr, "Muerta")
            actuar(cr, dt, {})
            continue
        cr["bite_cd"] = maxf(0.0, float(cr["bite_cd"]) - dt)
        var info: Dictionary = tipos.get(str(cr.get("kind", "rata")), tipos["rata"])
        var d: float = Vector2(cr["pos"]).distance_to(jugador.position)
        poner(cr, "Persigue" if d < float(info["smell"]) else "Patrulla")
        actuar(cr, dt, {"info": info, "d": d})
        # Contacto: esquivando la aplastas; si no, muerde.
        if d < 20.0:
            if float(jugador.esquiva_t) > 0.0:
                aplastada.emit(cr)
            elif float(cr["bite_cd"]) <= 0.0 and float(jugador.invulnerable_t) <= 0.0:
                cr["bite_cd"] = 1.0
                mordisco.emit(cr, info)


## Paso hacia «destino»: las voladoras no chocan; las demás, solo fuera de la
## persecución (patrullando su trayecto, que está libre de columnas).
func avanzar(cr: Dictionary, destino: Vector2, velocidad: float, dt: float, ctx: Dictionary) -> void:
    var pos: Vector2 = cr["pos"]
    var sig: Vector2 = pos.move_toward(destino, velocidad * dt)
    if bool(ctx["info"]["fly"]) or not bloqueado(sig) or float(ctx["d"]) >= float(ctx["info"]["smell"]):
        if absf(sig.x - pos.x) > 0.01:
            cr["flip"] = sig.x < pos.x
        cr["pos"] = sig


# ------------------------------------------------------------ DIBUJO
const Lienzo := preload("res://scripts/comun/lienzo.gd")
const HOJA := preload("res://assets/visual/enemies/alimana.png")
const HOJAS := {
    "rata": HOJA,
    "murcielago": preload("res://assets/visual/enemies/murcielago.png"),
    "arana": preload("res://assets/visual/enemies/arana.png"),
}


## Altura de vuelo (solo murciélagos; al morir caen).
static func altura(cr: Dictionary, i: int, t: float) -> float:
    if str(cr.get("kind", "rata")) != "murcielago":
        return 0.0
    if not bool(cr["alive"]):
        return maxf(0.0, 26.0 - float(cr["dead_t"]) * 90.0)
    return 26.0 + 6.0 * sin(t * 5.0 + float(i) * 1.7)


## Dibuja la alimaña «i» sobre el lienzo del mundo («t»: tiempo de juego).
func dibujar(c: CanvasItem, i: int, cr: Dictionary, t: float) -> void:
    var tipo: String = str(cr.get("kind", "rata"))
    var tex: Texture2D = HOJAS.get(tipo, HOJA)
    var en: Vector2 = Vector2(cr["pos"]).round()
    var region: Rect2
    if bool(cr["alive"]):
        var fps: float = 16.0 if tipo == "murcielago" else (13.0 if tipo == "arana" else 10.0)
        var cuadro: int = int(t * fps + float(i) * 1.3) % 4
        region = Rect2(float(cuadro) * 24.0, 0, 24, 16)
    else:
        var df: int = mini(3, int(float(cr["dead_t"]) * 8.0))
        region = Rect2(float(df) * 24.0, 16, 24, 16)
    var alto: float = altura(cr, i, t)
    Lienzo.sombra(c, en + Vector2(0, 2), 10.0 - alto * 0.15, 1.0 - alto * 0.015)
    var y: float = en.y - 28.0 - alto
    if bool(cr["flip"]):
        Lienzo.xf(c, Vector2(en.x, 0), 0.0, Vector2(-1, 1))
        c.draw_texture_rect_region(tex, Rect2(-24.0, y, 48, 32), region)
        Lienzo.xf(c, Vector2.ZERO, 0.0, Vector2.ONE)
    else:
        c.draw_texture_rect_region(tex, Rect2(en.x - 24.0, y, 48, 32), region)
