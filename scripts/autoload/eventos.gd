extends Node
## Bus de eventos global (autoload «Eventos»).
##
## Solo declara señales. Cualquier nodo puede emitirlas o escucharlas sin
## tener una referencia directa al otro: la campaña, la Vigilia, las
## pantallas y los avisos se comunican por aquí en vez de buscarse entre sí.
##
##   Eventos.aviso_pedido.emit("Texto", 2.5)
##   Eventos.progreso_guardado.connect(_al_guardar)
##
## Regla: quien se conecta a una señal de este bus desde un nodo que puede
## desaparecer se desconecta en _exit_tree() (o usa CONNECT_ONE_SHOT), para
## que el bus nunca llame a un nodo ya liberado.

## Mensaje breve para el jugador (lo muestra la capa de avisos).
signal aviso_pedido(texto: String, segundos: float)

## Un sonido de interfaz (lo toca la campaña con su banco de efectos).
signal sonido_pedido(nombre: String, volumen_db: float, tono: float)

## El progreso del personaje se escribió en disco / se borró.
signal progreso_guardado
signal progreso_borrado

## La pantalla visible cambió (splash, title, pause, play…).
signal pantalla_cambiada(anterior: String, nueva: String)

## El gestor de escenas empezó o terminó de cambiar de escena.
signal escena_cambiando(ruta: String)
signal escena_cambiada(ruta: String)
