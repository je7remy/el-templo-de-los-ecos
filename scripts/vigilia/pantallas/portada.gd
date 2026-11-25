extends "res://scripts/vigilia/pantallas/pantalla_vigilia.gd"
## Portada de la Vigilia: cómo se juega, empezar (o continuar la fase
## guardada), el tutorial y los récords.
##
## Datos: «t», «guardada» (hay fase guardada), «fase_guardada»,
## «tutorial_hecho», «mejor_fase», «mejor_puntuacion».

const BOTON_EMPEZAR := Rect2(260, 380, 260, 48)
const BOTON_TUTORIAL := Rect2(540, 380, 160, 48)
const PASOS := [["descansar", "1 · DUERME", "toca el lecho: ganas ecos"], ["centinela", "2 · CONSTRUYE", "toca cualquier baldosa"], ["potenciar", "3 · MEJORA", "toca lo construido"], ["bolsa_almas", "4 · GANA", "botín para la campaña"]]


func _draw() -> void:
    velo(Color(0, 0, 0, 0.6))
    var panel := Rect2(130, 100, 700, 395)
    EV.modal(self, panel)
    EV.rotulo(self, "Vigilia del Claustro", Vector2(130, 158), 44, EV.CREMA, panel.size.x)
    EV.centrado(self, "Defiende tu celda. Fases sin fin, cada una más dura.", 190, 15, EV.ALMA)
    for i in range(PASOS.size()):
        var cx: float = panel.position.x + 100.0 + float(i) * 166.0
        draw_texture_rect(EV.icono(PASOS[i][0]), Rect2(cx - 28.0, 214, 56, 56), false)
        EV.en_caja(self, PASOS[i][1], Rect2(cx - 80.0, 278, 160, 18), 15, EV.CREMA)
        EV.en_caja(self, PASOS[i][2], Rect2(cx - 80.0, 298, 160, 16), 11, EV.ALMA)
    EV.centrado(self, "Centinelas disparan · generadores dan energía · campanas frenan a las entidades.", 344, 13, EV.ORO_CLARO)
    var p: float = pulso()
    var b := BOTON_EMPEZAR
    EV.caja(self, b, Color("#2a1d36"), Color(EV.ORO_CLARO.r, EV.ORO_CLARO.g, EV.ORO_CLARO.b, 0.6 + 0.4 * p))
    var guardada: bool = bool(datos.get("guardada", false))
    var hecho: bool = bool(datos.get("tutorial_hecho", false))
    var principal: String = ("CONTINUAR · FASE %d" % int(datos.get("fase_guardada", 1))) if guardada else ("EMPEZAR" if hecho else "EMPEZAR CON TUTORIAL")
    EV.en_caja(self, principal, Rect2(b.position.x, b.position.y + 8.0, b.size.x, 18), 16, EV.CREMA)
    EV.en_caja(self, "ENTER / A", Rect2(b.position.x, b.position.y + 30.0, b.size.x, 12), 10, EV.ALMA)
    var t := BOTON_TUTORIAL
    EV.caja(self, t, Color("#141018"), EV.ORO)
    if guardada:
        EV.en_caja(self, "EMPEZAR DE CERO", Rect2(t.position.x, t.position.y + 8.0, t.size.x, 18), 12, EV.CREMA)
        EV.en_caja(self, "N · se pierde la guardada", Rect2(t.position.x, t.position.y + 30.0, t.size.x, 12), 10, EV.APAGADO)
    else:
        EV.en_caja(self, "REPETIR TUTORIAL" if hecho else "SALTAR TUTORIAL", Rect2(t.position.x, t.position.y + 8.0, t.size.x, 18), 12, EV.CREMA)
        EV.en_caja(self, "T / Y" if hecho else "toca aquí", Rect2(t.position.x, t.position.y + 30.0, t.size.x, 12), 10, EV.APAGADO)
    EV.centrado(self, "MEJOR FASE: %d   ·   MEJOR PUNTUACIÓN: %d" % [int(datos.get("mejor_fase", 0)), int(datos.get("mejor_puntuacion", 0))], 456, 13, EV.CREMA)
