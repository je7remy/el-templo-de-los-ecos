extends "res://scripts/ui/hud/pieza_hud.gd"
## Panel del jugador: retrato con su equipo, nombre, nivel, marca y las barras
## de vida, vigor y miedo.
##
## Datos: «retrato», «equipo_retrato», «temblor», «herida» (0..1), «nombre»,
## «marca» ("", "bendicion", "maldicion"), «nivel», «xp_fraccion»,
## «destello_nivel», «barras» ([icono, fraccion, color, texto]),
## «vida_extra» (0..1, o -1 sin vida extra), «miedo_alto», «t».

const EquipoRetrato := preload("res://scripts/ui/equipo_retrato.gd")


func _draw() -> void:
    Estilo.panel(self, Rect2(8, 6, 318, 96))
    var marco := Rect2(16, 12, 72, 72)
    Estilo.panel(self, marco, Color("#1a1f2a"), Estilo.ORO)
    var cara := Rect2(marco.position + Vector2(4.0 + float(d.get("temblor", 0.0)), 4.0), Vector2(64, 64))
    if d.get("retrato") != null:
        draw_texture_rect(d["retrato"], cara, false)
    EquipoRetrato.dibujar(self, cara, d.get("equipo_retrato", {}))
    var herida: float = float(d.get("herida", 0.0))
    if herida > 0.0:
        draw_rect(marco.grow(-2.0), Color(0.8, 0.05, 0.08, 0.35 * herida))
    # Placa con el nombre bajo el retrato.
    Estilo.panel(self, Rect2(16, 82, 72, 17), Color("#2a1d22"), Estilo.ORO)
    Estilo.texto(self, str(d.get("nombre", "")), Vector2(16, 95), 12, Estilo.CREMA, 72.0)
    # Marca (bendición o maldición) y nivel en las esquinas del retrato.
    var marca: String = str(d.get("marca", ""))
    if marca != "":
        var mk := Rect2(54, 6, 34, 18)
        var bendicion: bool = marca == "bendicion"
        Estilo.panel(self, mk, Color("#4a3a12") if bendicion else Color("#4a121a"), ICONO_ORO if bendicion else Estilo.CARMESI)
        Estilo.texto(self, "BEN" if bendicion else "MAL", Vector2(mk.position.x, mk.position.y + 14.0), 11, Estilo.CREMA, mk.size.x)
    var placa := Rect2(10, 6, 34, 18)
    Estilo.panel(self, placa, Color("#3b2550"), Estilo.ORO)
    Estilo.texto(self, "NV%d" % int(d.get("nivel", 1)), Vector2(placa.position.x, placa.position.y + 14.0), 11, Estilo.CREMA, placa.size.x)
    var xp := Rect2(122, 94, 196, 4)
    draw_rect(xp, Color(0, 0, 0, 0.7))
    draw_rect(Rect2(xp.position, Vector2(xp.size.x * float(d.get("xp_fraccion", 0.0)), xp.size.y)), Color("#c9a25e").lerp(Color.WHITE, 0.4 * float(d.get("destello_nivel", 0.0))))
    var barras: Array = d.get("barras", [])
    for i in range(barras.size()):
        var y: float = 15.0 + float(i) * 27.0
        var b: Array = barras[i]
        if b[0] != null:
            draw_texture_rect(b[0], Rect2(96, y - 1.0, 22, 22), false)
        Estilo.barra(self, Rect2(122, y, 196, 20), float(b[1]), b[2], str(b[3]))
    var extra: float = float(d.get("vida_extra", -1.0))
    if extra >= 0.0:
        # Vida extra por encima del máximo: franja dorada sobre la barra.
        draw_rect(Rect2(124, 15, 192.0 * extra, 4), ICONO_ORO)
        draw_rect(Rect2(122, 15, 196, 20), Color(1.0, 0.85, 0.4, 0.35 + 0.2 * sin(tiempo() * 4.0)), false, 2.0)
    if bool(d.get("miedo_alto", false)):
        # Al borde del pánico la barra de miedo late.
        var k: float = 0.5 + 0.5 * sin(tiempo() * 9.0)
        draw_rect(Rect2(121, 68, 198, 22), Color(0.7, 0.3, 1.0, 0.35 * k), false, 2.0)
