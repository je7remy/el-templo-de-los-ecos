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
