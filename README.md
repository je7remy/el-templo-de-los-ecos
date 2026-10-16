# El Templo de los Ecos — Prototipo 0.3

**Godot 4.3+ · Knowledge Temple (mapa) + GothicVania Church Pack (enemigos)**

Proyecto editable y jugable de un piso, cinco habitaciones y tres encuentros prototipo, basado en los documentos GDD 0.1, Lore 0.2 y Reglas 0.1.

## Abrir en Fedora

1. Extraer el ZIP en `~/Juegos`.
2. Abrir el editor: `godot --editor --path ~/Juegos/El_Templo_de_los_Ecos_v0_3`.
3. Presionar **F5** para importar recursos e iniciar. En Flatpak: `flatpak run org.godotengine.Godot --editor --path ...`.
4. Para jugar sin editor, una vez importado: `godot --path ~/Juegos/El_Templo_de_los_Ecos_v0_3`.

Hay un script opcional `herramientas/abrir_fedora.sh` que abre el editor detectando Godot o Flatpak.

## Controles

- **ENTER:** empezar o reiniciar
- **WASD / flechas:** caminar
- **E:** recoger fragmentos, abrir puerta, interactuar con altar y carta
- **F:** linterna (puede cambiar el comportamiento de ciertas criaturas)
- **ESPACIO:** esquivar
- **Q:** habilidad Resonancia, al adquirirla en el altar
- **ESC:** menú o cerrar panel de altar

## Recorrido

1. Umbral: avanza hasta la puerta este y pulsa E.
2. Claustro: experimenta con la linterna para evitar al Burning Ghoul; hay un altar.
3. Sala del Testigo: no te muevas cuando el ojo esté abierto; recupera el sello cerca del fondo y sal.
4. Archivo: el Wizard reacciona a tu luz. Interactúa con el libro en el centro.
5. Pórtico: ve a la salida para completar la prueba vertical.

El personaje puede morir. Resultado aleatorio de dos vías: reencarnación (50 %) o absorción definitiva (50 %). Los recursos reunidos en esta prueba no persisten en una nueva vida.

## Integración de recursos

Las texturas originales seleccionadas están **incluidas en el proyecto**, no requieren descargas adicionales. Fondos derivados se encuentran en `assets/knowledge/rooms/`, fotogramas enemigos en `assets/gothic_enemies/`. Ver `docs/ASSETS_Y_LICENCIAS.md` antes de publicar o distribuir comercialmente.

## Alcance y prueba

No se dispone de Godot ejecutable en el entorno donde se preparó este ZIP, así que no se ha completado una prueba de arranque real. Hay verificaciones estáticas del proyecto, sus rutas y archivos. Cualquier error de importación o parser que aparezca al ejecutar en Fedora debe corregirse tras observar el mensaje exacto del editor.
