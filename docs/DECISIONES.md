# Decisiones del primer piso y reglas — v0.3

## Canon confirmado (fuentes: GDD 0.1, Lore 0.2, Reglas 0.1)

- El templo sirve para explotar a los cautivos y circular almas.
- El ángel caído administra el sistema pero no persigue al protagonista personalmente.
- 50 % del alma absorbida de manera definitiva y 50 % de reencarnación con recuerdos y habilidades; nivel de las habilidades se reinicia a 0.
- El alma funciona como recurso, moneda y combustible.
- Las entidades están limitadas por reglas y el jugador puede aprenderlas.

## Mecánicas de prototipo no canonizadas (cambiables)

- Escenario: 5 salas de un solo piso, con una misión que exige recuperar el sello.
- La criatura del área central se representa con Angel y el nombre provisional «Testigo»: solo persigue si tiene el ojo abierto y el jugador se mueve. La regla del Testigo es **provisional**, no canon definitivo de entidades.
- Burning Ghoul (sala II) persigue si la linterna está encendida y se aleja al apagarla.
- Wizard (sala IV) lanza proyectiles hacia el jugador si la linterna está encendida y detecta al personaje.
- Cantidad de fragmentos, precios, duración de enfriamientos, niveles, salud, nombres, pistas y resultados de superar el piso son valores de prueba.
- El sprite provisional del protagonista se mantiene para permitir probar el circuito de principio a fin.
- Las salas ya son escenas editables (`rooms/sala_N.tscn`): la arquitectura es un `TileMapLayer` de 32 × 32 (`rooms/templo_tileset.tres`) y los objetos son `Sprite2D` con su colisión (ver `docs/EDITAR_SALAS.md`). Antes eran cinco fondos compuestos.

El juego sigue siendo una **vertical slice**. No se ha añadido lore definitivo que contradiga los tres documentos.
