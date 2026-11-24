extends Node
## Progreso del personaje (autoload «Progreso»).
##
## Es el ÚNICO que lee y escribe el archivo de progreso. Antes lo hacían la
## campaña (main.gd) y el botín de la Vigilia (botin.gd) cada uno por su lado,
## con el riesgo de pisarse. Ahora los dos pasan por aquí:
##
##   var datos := Progreso.cargar()      # Dictionary (vacío si no hay partida)
##   Progreso.guardar(datos)             # escribe todo el diccionario
##   Progreso.borrar()                   # borrar perfil
##
## Las pruebas automáticas (Engine.has_meta("modo_prueba")) usan un archivo
## propio para no tocar tu partida.

const RUTA := "user://templo_personaje_v03.json"
const RUTA_PRUEBA := "user://prueba_progreso.json"

## Copia en memoria de lo último que se leyó o escribió.
var datos: Dictionary = {}


static func ruta() -> String:
    return RUTA_PRUEBA if Engine.has_meta("modo_prueba") else RUTA


func existe() -> bool:
    return FileAccess.file_exists(ruta())


## Lee el archivo (siempre de disco: otra escena pudo cambiarlo).
func cargar() -> Dictionary:
    datos = {}
    if existe():
        var leido = JSON.parse_string(FileAccess.get_file_as_string(ruta()))
        if leido is Dictionary:
            datos = leido
    return datos


## Escribe el diccionario completo. Devuelve false si no se pudo escribir.
func guardar(nuevos: Dictionary) -> bool:
    datos = nuevos.duplicate(true)
    var archivo := FileAccess.open(ruta(), FileAccess.WRITE)
    if archivo == null:
        push_warning("No se pudo guardar el progreso en %s." % ruta())
        return false
    archivo.store_string(JSON.stringify(datos))
    archivo.close()
    Eventos.progreso_guardado.emit()
    return true


## Cambia solo algunas claves y guarda (lo usa el botín de la Vigilia).
func actualizar(cambios: Dictionary) -> bool:
    var todo := cargar()
    todo.merge(cambios, true)
    return guardar(todo)


func borrar() -> void:
    if existe():
        DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta()))
    datos = {}
    Eventos.progreso_borrado.emit()
