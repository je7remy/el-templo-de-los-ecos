extends Node
## Orbita y te observa. Sostenerle la mirada suma tiempo; darle la espalda
## un momento o esquivar la provoca. Hace amagos y ruidos a tu espalda.


func actuar(v: Node, dt: float, ctx: Dictionary) -> void:
    var miras: bool = bool(ctx["la_miras"])
    v.angulo = float(v.angulo) + dt * 0.22
    var orb: Vector2 = v.orbita()
    v.amago_k = maxf(0.0, float(v.amago_k) - dt)
    var yo: Vector2 = v.jugador.position
    var lance: Vector2 = (yo - orb).normalized() * 70.0 * sin(PI * float(v.amago_k) / 0.5) if float(v.amago_k) > 0.0 else Vector2.ZERO
    v.position = (v.position as Vector2).move_toward(orb + lance, 260.0 * dt)
    v.espalda_t = float(v.espalda_t) + dt if not miras else maxf(0.0, float(v.espalda_t) - dt * 2.0)
    var esquiva: bool = float(v.jugador.esquiva_t) > 0.0
    if float(v.estado_t) <= 0.0 and (float(v.espalda_t) > v.GRACIA or esquiva):
        v.cortar = true
        v.provocada.emit("¡Le diste la espalda!" if not esquiva else "¡Corriste!")
        return
    if miras:
        v.mirada_t = float(v.mirada_t) + dt
    # Amagos: se lanza sin aviso rojo y vuelve. Esquivar la provoca.
    v.amago_t = float(v.amago_t) - dt
    if float(v.amago_t) <= 0.0:
        v.amago_t = randf_range(6.0, 9.0)
        v.amago_k = 0.5
        v.amago.emit()
    # Ruidos a tu espalda para que te des la vuelta.
    v.ruido_t = float(v.ruido_t) - dt
    if float(v.ruido_t) <= 0.0:
        v.ruido_t = randf_range(8.0, 12.0)
        var detras: Vector2 = yo - ((v.position as Vector2) - yo).normalized() * 110.0
        v.ruido = {"pos": detras, "t": 1.6}
        v.ruido_hecho.emit(detras)
    # Pánico de los aliados y victoria: los revisa la campaña.
    v.mirando.emit(dt)
