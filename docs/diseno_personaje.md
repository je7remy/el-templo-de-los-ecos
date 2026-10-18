# Protagonista — identidad visual (propuesta)

## Concepto
Humano ordinario y vulnerable, atrapado en el templo. Se evita una silueta heroica, armaduras o mutaciones. La identidad corporal se conserva en todas las reencarnaciones; los cambios narrativos no se representan como alteraciones anatómicas.

## Diseño implementado
- Hoja de sprites nueva: `assets/visual/protagonist_sheet.png`, **360 × 224 px**, nueve columnas de **40 × 56** y cuatro filas direccionales.
- Filas: frente, espalda, derecha e izquierda. Columnas: dos estados de reposo (respiración), cuatro fotogramas distintos de caminar (extremidades alternas), interactuar, recibir daño y morir.
- Abrigo de tela verde pizarra con costuras y sombras, pantalón carbón, pelo oscuro, piel humana, tirante color latón y **pañuelo granate** distintivo.
- Fotogramas hechos con dibujos pixelados estructurales: cambian brazos y piernas al caminar; no se simula movimiento desplazando una sola imagen.
- Los fotogramas de daño y muerte se integran en el dibujado cuando los estados existentes lo permiten; la interacción emplea únicamente un temporizador visual nuevo.
- Sin edición del sprite anterior, que continúa en `assets/fallback/player.png`.

## Paleta hexadecimal de referencia
| Uso | Color |
|---|---|
| Silueta exterior | `#13181E` |
| Cabello | `#1F1F24` |
| Abrigo base | `#395359` |
| Abrigo iluminado | `#58706F` |
| Tela granate | `#843844` |
| Brillo granate | `#BA575B` |
| Piel | `#C59C81` |
| Calzado | `#1B1D23` |
| Latón | `#B5A986` |

## Limitaciones y próximos pasos
Este spritesheet es una **primera integración pixel art realizada con herramientas de dibujo programático**, no un reemplazo definitivo de un artista de personajes. Falta probarlo en movimiento dentro de Godot, suavizar la anatomía de espaldas y laterales, perfeccionar la secuencia de muerte, y realizar una revisión animada frame a frame. `Mark — 2D Adventure Game Sprite` NO se halló en el paquete inspeccionado: no se ha usado ni se ha atribuido su licencia.
