extends RefCounted
## Equipo dibujado encima del retrato del personaje (peto, amuleto, máscara y
## casco). El retrato base mide 64 × 64; se escala al rectángulo que se pida.
## Lo usan el panel del jugador (main.gd) y la pantalla de perfil.

const ACERO := Color("#8d949a")
const ACERO_OSCURO := Color("#4f565c")
const ACERO_CLARO := Color("#c9d0d4")
const CUERO := Color("#6e4630")
const ORO := Color("#e3bd7b")
const MASCARA_BLANCO := Color("#fbfaf6")
const MASCARA_SOMBRA := Color("#d9d6e0")
const MASCARA_ROJO := Color("#b0242f")
const CONTORNO := Color("#140f12")


## «puesto»: {"peto", "amuleto", "mascara", "casco"} → bool.
static func dibujar(ci: CanvasItem, r: Rect2, puesto: Dictionary) -> void:
    var k: float = r.size.x / 64.0
    var o: Vector2 = r.position
    var R := func(x: float, y: float, w: float, h: float, col: Color) -> void:
        ci.draw_rect(Rect2(o + Vector2(x, y) * k, Vector2(w, h) * k), col)
    if bool(puesto.get("peto", false)):
        R.call(6, 47, 52, 17, CONTORNO)
        R.call(7, 48, 50, 16, ACERO)
        R.call(7, 48, 50, 3, ACERO_CLARO)
        R.call(31, 50, 2, 14, ACERO_OSCURO)
        R.call(2, 46, 10, 8, CUERO)
        R.call(52, 46, 10, 8, CUERO)
    if bool(puesto.get("amuleto", false)):
        for i in range(5):
            R.call(23.0 + float(i) * 2.0, 44.0 + float(i), 2, 1, ORO)
            R.call(39.0 - float(i) * 2.0, 44.0 + float(i), 2, 1, ORO)
        R.call(30, 49, 5, 7, Color("#d8f0dc"))
        R.call(31, 51, 3, 3, Color("#5f8f6a"))
    if bool(puesto.get("mascara", false)):
        R.call(18, 15, 29, 27, CONTORNO)
        R.call(19, 16, 27, 25, MASCARA_BLANCO)
        R.call(19, 34, 27, 7, MASCARA_SOMBRA)
        R.call(22, 22, 8, 5, Color(0.05, 0.04, 0.06))
        R.call(35, 22, 8, 5, Color(0.05, 0.04, 0.06))
        R.call(25, 27, 2, 6, MASCARA_ROJO)
        R.call(38, 27, 2, 6, MASCARA_ROJO)
        R.call(28, 35, 9, 2, MASCARA_ROJO)
        R.call(33, 16, 1, 7, CONTORNO)
    if bool(puesto.get("casco", false)):
        R.call(14, 3, 37, 19, CONTORNO)
        R.call(15, 4, 35, 17, ACERO)
        R.call(18, 4, 29, 3, ACERO_CLARO)
        R.call(15, 18, 35, 3, ACERO_OSCURO)
        R.call(30, 21, 4, 9, ACERO_OSCURO)
        R.call(30, 0, 5, 4, Color(0.75, 0.2, 0.18))
