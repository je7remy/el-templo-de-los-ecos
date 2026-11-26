extends RefCounted
## Traducción del juego al inglés.
##
## El juego se escribe en español; los textos en inglés están en tablas
## (scripts/datos/en/*.gd: «texto en español» → «texto en inglés»). Se
## traduce al dibujar: las piezas comunes de dibujo (estilo.gd,
## estilo_vigilia.gd, los rótulos de main.gd…) pasan cada texto por
## Idioma.t() justo antes de pintarlo. Con el idioma en español no se hace nada.
##
## Qué encuentra:
##   · el texto exacto («SALA DEL TESTIGO»);
##   · el mismo texto en mayúsculas, si la tabla lo tiene en minúsculas;
##   · textos con números o nombres dentro, si la tabla tiene su plantilla
##     con %d, %s o %.1f («FASE %d» → «PHASE %d»). Lo que va en un %s se
##     traduce también (nombres de objetos, de entidades…);
##   · el nombre del personaje se escribe {yo} en las tablas.
## Un texto que no está en las tablas se deja como está (en español).
##
## Para añadir un texto nuevo al juego: escríbelo en español donde toque y
## añade su traducción en la tabla de su parte (scripts/datos/en/).

const Ajustes := preload("res://scripts/ajustes.gd")
const TABLAS := [
    preload("res://scripts/datos/en/datos.gd"),
    preload("res://scripts/datos/en/campana.gd"),
    preload("res://scripts/datos/en/vigilia.gd"),
    preload("res://scripts/datos/en/interfaz.gd"),
]

## Nombre del personaje (lo pone la campaña) para encontrar «{yo}».
static var nombre: String = ""

static var _exactas: Dictionary = {}
static var _mayusculas: Dictionary = {}
static var _plantillas: Array = [] # [prefijo literal, RegEx, inglés, tipos] (con %s)
static var _esqueletos: Dictionary = {} # plantillas solo con números: «FASE #» → inglés
static var _numero := RegEx.create_from_string("[-+]?[0-9]+(?:\\.[0-9]+)?")
static var _hueco_numero := RegEx.create_from_string("%[-+0-9.]*[df]")
static var _cache: Dictionary = {}
static var _listo: bool = false
## Para buscar textos sin traducir (pruebas): se apuntan aquí los que no
## estaban en las tablas y parecen español.
static var apuntar_faltas: bool = false
static var faltas: Dictionary = {}
static var todas_las_faltas: bool = false
static var _espanol := RegEx.create_from_string("[áéíóúñÁÉÍÓÚÑ¿¡]|\\b(el|la|los|las|de|del|que|con|para|una|por|tu|te|sin|más|está|PISO|SALA|ALMAS|VIDA|MIEDO|DAÑO)\\b")


static func ingles() -> bool:
    return str(Ajustes.obtener("idioma", "es")) == "en"


## El texto en el idioma elegido.
static func t(s: String) -> String:
    if s == "" or not ingles():
        return s
    if not _listo:
        _preparar()
    if _cache.has(s):
        return _cache[s]
    var r: String = _buscar(s)
    if r == "" and nombre != "" and s.contains(nombre):
        r = _buscar(s.replace(nombre, "{yo}"))
        if r != "":
            r = r.replace("{yo}", nombre)
    if r == "":
        r = s
        if apuntar_faltas and (_espanol.search(s) != null or todas_las_faltas):
            faltas[s] = true
    if _cache.size() > 4000:
        _cache.clear()
    _cache[s] = r
    if r != s:
        _cache[r] = r # el texto ya traducido no se vuelve a buscar
    return r


## Varios textos a la vez (líneas de un diálogo, opciones de un menú).
static func todas(lista: Array) -> Array:
    return lista.map(func(x): return t(str(x)))


static func _buscar(s: String) -> String:
    if _exactas.has(s):
        return _exactas[s]
    if _mayusculas.has(s):
        return _mayusculas[s]
    # Textos con números: «FASE 12» → esqueleto «FASE #» (sin recorrer plantillas).
    var nums: Array[RegExMatch] = _numero.search_all(s)
    if not nums.is_empty():
        var esq: String = _numero.sub(s, "#", true)
        if _esqueletos.has(esq):
            var en0: String = _esqueletos[esq]
            var out0 := ""
            var k0 := 0
            var piezas: PackedStringArray = _hueco_numero.sub(en0, "\u0001", true).split("\u0001")
            for i in range(piezas.size()):
                out0 += piezas[i]
                if i < piezas.size() - 1:
                    out0 += nums[k0].get_string() if k0 < nums.size() else ""
                    k0 += 1
            return out0
    for p in _plantillas:
        if not s.begins_with(p[0]):
            continue
        var m: RegExMatch = (p[1] as RegEx).search(s)
        if m == null:
            continue
        var en: String = p[2]
        var tipos: Array = p[3]
        var out := ""
        var i := 0
        var k := 1
        while i < en.length():
            var c := en[i]
            if c == "%" and i + 1 < en.length():
                if en[i + 1] == "%":
                    out += "%"
                    i += 2
                    continue
                var j := i + 1
                while j < en.length() and not (en[j] in ["d", "s", "f"]):
                    j += 1
                var v: String = m.get_string(k)
                out += (t(v) if tipos[k - 1] == "s" else v)
                k += 1
                i = j + 1
                continue
            out += c
            i += 1
        return out
    # Rótulos compuestos con « · »: cada parte por separado.
    if s.contains(" · "):
        var partes: PackedStringArray = s.split(" · ")
        var cambio := false
        for i in range(partes.size()):
            var p: String = t(partes[i])
            if p != partes[i]:
                partes[i] = p
                cambio = true
        if cambio:
            return " · ".join(partes)
    return ""


static func _preparar() -> void:
    _listo = true
    var formato := RegEx.create_from_string("%[-+0-9.]*[dsf]|%%")
    for tabla in TABLAS:
        var d: Dictionary = tabla.T
        for es in d:
            var en: String = d[es]
            if not formato.search(es):
                _exactas[es] = en
                _mayusculas[(es as String).to_upper()] = en.to_upper()
                # «IV-1 · ATRIO DE LAS RAÍCES»: también el nombre solo.
                var sala := (es as String).split(" · ")
                if sala.size() == 2 and (en as String).contains(" · ") and sala[0].contains("-"):
                    _exactas[sala[1]] = (en as String).split(" · ")[1]
                    _mayusculas[sala[1].to_upper()] = (en as String).split(" · ")[1].to_upper()
                continue
            # Solo con números: va al índice de esqueletos.
            var fijo: String = _hueco_numero.sub(es, "", true)
            if not (es as String).contains("%s") and not (es as String).contains("%%") and _numero.search(fijo) == null:
                var e2: String = _hueco_numero.sub(es, "#", true)
                _esqueletos[e2] = en
                _esqueletos[e2.to_upper()] = en.to_upper() if e2 != e2.to_upper() else en
                continue
            # Plantilla: el texto fijo se escapa y cada %… es un hueco.
            var patron := "^"
            var tipos: Array = []
            var prefijo := ""
            var resto: String = es
            var primero := true
            for m in formato.search_all(es):
                var antes: String = resto.substr(0, resto.find(m.get_string()))
                if primero:
                    prefijo = antes
                    primero = false
                patron += _escapar(antes)
                resto = resto.substr(antes.length() + m.get_string().length())
                var f: String = m.get_string()
                if f == "%%":
                    patron += "%"
                elif f.ends_with("s"):
                    patron += "(.*?)"
                    tipos.append("s")
                elif f.ends_with("f"):
                    patron += "(-?[0-9]+(?:\\.[0-9]+)?)"
                    tipos.append("f")
                else:
                    patron += "([-+]?[0-9]+)"
                    tipos.append("d")
            patron += _escapar(resto) + "$"
            var re := RegEx.create_from_string(patron)
            if re.is_valid():
                _plantillas.append([prefijo, re, en, tipos])


static func _escapar(s: String) -> String:
    var out := ""
    for c in s:
        if c in ["\\", ".", "^", "$", "|", "?", "*", "+", "(", ")", "[", "]", "{", "}"]:
            out += "\\" + c
        else:
            out += c
    return out


## Para cambiar de idioma en marcha (Configuración).
static func olvidar() -> void:
    _cache.clear()
