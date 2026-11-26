extends "res://scripts/ui/hud/pieza_hud.gd"
## Cartel del piso y la sala, con el contador de almas.
##
## Datos: «titulo» (largo) y «titulo_corto» con «estado_corto» (si el largo
## no cabe), «sala», «estado», «almas», «destello» (0..0,8 al recoger).

const CARTEL := Rect2(336, 6, 288, 58)


func _draw() -> void:
    Estilo.panel(self, CARTEL)
    var titulo: String = Estilo.t(str(d.get("titulo", "")))
    var estado: String = Estilo.t(str(d.get("estado", "")))
    if Estilo.fuente_titulo().get_string_size(titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x > CARTEL.size.x - 12.0:
        # Título largo: el número en gótica y el nombre del piso abajo, en pequeño.
        titulo = str(d.get("titulo_corto", titulo))
        estado = str(d.get("estado_corto", estado))
    Estilo.titulo(self, titulo, Vector2(CARTEL.position.x, 27), 24, Estilo.ORO, CARTEL.size.x)
    Estilo.texto(self, str(d.get("sala", "")), Vector2(CARTEL.position.x, 44), 14, Estilo.CREMA, CARTEL.size.x)
    Estilo.texto(self, estado, Vector2(CARTEL.position.x, 58), 10, Color("#8a8574"), CARTEL.size.x)
    # Almas: icono y número que destella al recoger.
    Estilo.panel(self, Rect2(420, 68, 120, 34))
    var destello: float = float(d.get("destello", 0.0))
    var salto: float = destello * 6.0
    if d.get("icono_alma") != null:
        draw_texture_rect(d["icono_alma"], Rect2(428, 72.0 - roundf(salto * 0.5), 26, 26), false)
    var color: Color = Estilo.ALMA.lerp(Color.WHITE, clampf(destello / 0.8, 0.0, 1.0))
    Estilo.texto(self, "%d" % int(d.get("almas", 0)), Vector2(460, 93), 18 + int(round(salto)), color)
