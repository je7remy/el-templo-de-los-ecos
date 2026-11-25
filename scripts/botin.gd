extends RefCounted
## Botín de la Vigilia: cada fase superada da un objeto al azar que pasa a la
## campaña (se escribe en el progreso del personaje a través del autoload
## Progreso). Cuanto más alta la fase, mejor el botín.
##
## Uso:  const Botin := preload("res://scripts/botin.gd")
##       var clave := Botin.sortear(fase)
##       var texto := Botin.aplicar(clave)


## clave: [nombre, descripción, nivel de botín (1-4), icono]. Los objetos son
## archivos de datos en datos/botin/*.tres (scripts/datos/catalogo.gd).
const Catalogo := preload("res://scripts/datos/catalogo.gd")
static var OBJETOS: Dictionary = Catalogo.botin()
const NIVEL_OBJETO_MAX := 5
const NIVEL_HABILIDAD_MAX := 5


## Nivel de botín según la fase: 1-2 → 1, 3-4 → 2, 5-6 → 3, 7 o más → 4.
static func nivel(fase: int) -> int:
    return clampi(1 + (fase - 1) / 2, 1, 4)


## Elige un objeto: los del nivel de la fase pesan el triple que los de abajo.
static func sortear(fase: int, rng: RandomNumberGenerator = null) -> String:
    var top: int = nivel(fase)
    var bolsa: Array = []
    for clave in OBJETOS:
        var n: int = int(OBJETOS[clave][2])
        if n > top:
            continue
        for i in range(3 if n == top else 1):
            bolsa.append(clave)
    var r: int = rng.randi_range(0, bolsa.size() - 1) if rng != null else randi() % bolsa.size()
    return bolsa[r]


## Aplica el objeto al progreso de la campaña y devuelve su nombre.
static func aplicar(clave: String) -> String:
    var progreso: Node = Engine.get_main_loop().root.get_node("/root/Progreso")
    var datos: Dictionary = progreso.cargar()
    var bolsa: Dictionary = datos.get("bag", {}) if datos.get("bag", {}) is Dictionary else {}
    var objetos: Array = datos.get("trinkets", []) if datos.get("trinkets", []) is Array else []
    var niveles: Dictionary = datos.get("trinket_levels", {}) if datos.get("trinket_levels", {}) is Dictionary else {}
    match clave:
        "brazalete_up", "amuleto_up":
            var t: String = clave.trim_suffix("_up")
            if objetos.has(t):
                niveles[t] = mini(NIVEL_OBJETO_MAX, int(niveles.get(t, 1)) + 1)
            else:
                objetos.append(t)
                niveles[t] = 1
        "resonancia_up":
            if bool(datos.get("has_pulse", false)):
                datos["ability_level"] = mini(NIVEL_HABILIDAD_MAX, int(datos.get("ability_level", 0)) + 1)
            else:
                datos["has_pulse"] = true
        _:
            bolsa[clave] = int(bolsa.get(clave, 0)) + 1
    datos["bag"] = bolsa
    datos["trinkets"] = objetos
    datos["trinket_levels"] = niveles
    progreso.guardar(datos)
    return str(OBJETOS.get(clave, [clave])[0])
