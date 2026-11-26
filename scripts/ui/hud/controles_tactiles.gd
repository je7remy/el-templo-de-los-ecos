extends "res://scripts/ui/hud/pieza_hud.gd"
## Controles táctiles: joystick flotante a la izquierda y botones agrupados a
## la derecha, al alcance del pulgar (controles de Kenney, CC0, teñidos con la
## paleta). Los toques los atiende main.gd; aquí solo se dibujan.
##
## Datos: «centro» (del joystick), «eje», «quieto» (ningún dedo en él),
## «visible_quieto» (opacidad de la base sin dedo; más en el móvil),
## «botones» ({pos, radio, icono, etiqueta, tam, listo, espera, tinte,
## fosforos (-1 si no se muestran)}).

const BASE := preload("res://assets/visual/controles/joystick_base.png")
const BOTON := preload("res://assets/visual/controles/boton.png")


func _draw() -> void:
    var centro: Vector2 = d.get("centro", Vector2.ZERO)
    var quieto: bool = bool(d.get("quieto", true))
    draw_texture_rect(BASE, Rect2(centro - Vector2(76, 76), Vector2(152, 152)), false, Color(0.75, 0.68, 0.8, float(d.get("visible_quieto", 0.35)) if quieto else 0.7))
    draw_texture_rect(BOTON, Rect2(centro + Vector2(d.get("eje", Vector2.ZERO)) * 48.0 - Vector2(30, 30), Vector2(60, 60)), false, Color(0.62, 0.81, 0.83, 0.5 if quieto else 0.85))
    for b in d.get("botones", []):
        var en: Vector2 = b["pos"]
        var r: float = float(b["radio"])
        var listo: bool = bool(b["listo"])
        var espera: float = float(b["espera"])
        draw_texture_rect(BOTON, Rect2(en - Vector2(r, r), Vector2(r * 2.0, r * 2.0)), false, b["tinte"])
        if not listo and espera > 0.0:
            draw_arc(en, r - 6.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - espera), 32, Estilo.ALMA, 3.0)
        var lado: float = r * 0.8
        if b.get("icono") != null:
            draw_texture_rect(b["icono"], Rect2(en - Vector2(lado * 0.5, lado * 0.62), Vector2(lado, lado)), false, Color(1, 1, 1, 0.95 if listo else 0.5))
        Estilo.texto(self, str(b["etiqueta"]), Vector2(en.x - r, en.y + r * 0.62), int(b.get("tam", 11)), Estilo.CREMA, r * 2.0)
        var fosforos: int = int(b.get("fosforos", -1))
        if fosforos >= 0:
            var placa := Rect2(en + Vector2(r * 0.35, -r - 4.0), Vector2(30, 18))
            Estilo.panel(self, placa, Color("#2a1d22"), Estilo.ORO)
            Estilo.texto(self, "×%d" % fosforos, Vector2(placa.position.x, placa.position.y + 14.0), 11, Estilo.CREMA, placa.size.x)
