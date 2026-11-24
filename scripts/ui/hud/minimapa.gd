extends "res://scripts/ui/hud/pieza_hud.gd"
## Minimapa del piso (salas en cadena, la actual resaltada) y los botones de
## pausa y habilidades. Tocarlos lo resuelve main.gd.
##
## Datos: «resaltado», «ayuda», «salas» ({estado: "pasada"/"actual"/"futura",
## amenaza, final, cosecha}), «sala_texto», «id», «boton_habilidades» (Rect2),
## «habilidades_resaltado», «icono_calavera», «icono_pausa»,
## «icono_habilidades», «t».

const PANEL := Rect2(634, 6, 318, 96)
const CELDA := Vector2(28, 22)
const HUECO := 12.0
const GRIS := Color("#8a8574")
const OSCURO := Color("#2a2e38")


func _draw() -> void:
    Estilo.panel(self, PANEL)
    Estilo.texto(self, "MAPA DEL PISO", Vector2(644, 24), 11, Estilo.ORO if bool(d.get("resaltado", false)) else GRIS)
    Estilo.texto(self, str(d.get("ayuda", "")), Vector2(760, 24), 9, Color("#6d6772"), 128.0)
    var salas: Array = d.get("salas", [])
    var n: int = salas.size()
    var total: float = float(n) * CELDA.x + float(n - 1) * HUECO
    var x0: float = roundf(634.0 + (258.0 - total) * 0.5)
    var calavera: Variant = d.get("icono_calavera")
    for i in range(n):
        var s: Dictionary = salas[i]
        var r := Rect2(x0 + float(i) * (CELDA.x + HUECO), 40.0, CELDA.x, CELDA.y)
        var estado: String = str(s.get("estado", "futura"))
        if i < n - 1:
            var siguiente_vista: bool = estado == "pasada"
            draw_rect(Rect2(r.end.x, r.position.y + 9.0, HUECO, 4.0), Estilo.ORO if siguiente_vista else OSCURO)
        match estado:
            "pasada":
                Estilo.panel(self, r, Color("#3a3f4c"), Estilo.CLARO)
            "actual":
                var pulso: float = 0.6 + 0.4 * sin(tiempo() * 4.0)
                Estilo.panel(self, r, Color(0.78, 0.67, 0.43, 0.35 + 0.2 * pulso), Estilo.ORO)
                draw_rect(Rect2(r.get_center() - Vector2(3, 3), Vector2(6, 6)), Estilo.CREMA)
            _:
                Estilo.panel(self, r, Color("#12151c"), OSCURO)
                if i < n - 1:
                    Estilo.texto(self, "?", Vector2(r.position.x, r.position.y + 16.0), 12, Color("#4a4e5a"), r.size.x)
        # Marcas: amenaza viva en la sala actual; el final del piso, una calavera.
        if bool(s.get("amenaza", false)):
            draw_rect(Rect2(r.end.x - 7.0, r.position.y + 3.0, 4, 4), Estilo.ROJO)
        if calavera != null and bool(s.get("final", false)):
            draw_texture_rect(calavera, Rect2(r.position + Vector2(5, 2), Vector2(18, 18)), false, Color(1, 1, 1, 0.8))
        if calavera != null and bool(s.get("cosecha", false)):
            draw_texture_rect(calavera, Rect2(r.position + Vector2(-5, -10), Vector2(14, 14)), false)
    Estilo.texto(self, str(d.get("sala_texto", "")), Vector2(644, 92), 12, Estilo.CREMA)
    Estilo.texto(self, "ID %03d" % int(d.get("id", 0)), Vector2(800, 92), 11, GRIS)
    # Botón de pausa (en móvil vuelve al menú) y de habilidades.
    var pausa := Rect2(898, 12, 46, 46)
    Estilo.panel(self, pausa, Color("#1a1f2a"), Estilo.CLARO)
    if d.get("icono_pausa") != null:
        draw_texture_rect(d["icono_pausa"], Rect2(pausa.position + Vector2(7, 7), Vector2(32, 32)), false, Color(1, 1, 1, 0.85))
    var hab: Rect2 = d.get("boton_habilidades", Rect2(898, 62, 46, 36))
    var hot: bool = bool(d.get("habilidades_resaltado", false))
    Estilo.panel(self, hab, Color("#241a30") if hot else Color("#1a1f2a"), Estilo.ORO if hot else Estilo.CLARO)
    if d.get("icono_habilidades") != null:
        draw_texture_rect(d["icono_habilidades"], Rect2(hab.position + Vector2(11, 4), Vector2(24, 24)), false)
    Estilo.texto(self, "K", Vector2(hab.end.x - 9.0, hab.end.y - 3.0), 9, Estilo.ORO)
