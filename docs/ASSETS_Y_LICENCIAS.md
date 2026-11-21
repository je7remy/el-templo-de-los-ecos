# Procedencia, créditos y condiciones de uso — v0.3.1

Esta nota distingue los recursos gráficos de terceros, el código del juego y el universo narrativo.

## Knowledge Temple — pingupollas

- **Uso en el proyecto:** escenarios, altares, muros, suelos, estatuas, columnas y composiciones de habitaciones dentro de `assets/knowledge/`.
- **Autor:** **pingupollas**.
- **Enlace oficial:** https://pingupollas.itch.io/knowledge-temple
- **Condiciones publicadas por el creador (verificadas el 16 de octubre de 2026):** permite usar el pack para proyectos personales, comerciales y de otros tipos, así como modificarlo. Requiere acreditar al creador con su nombre y el enlace a su página de itch.io. No permite revender ni redistribuir el **pack como paquete independiente de recursos**, gratuitamente o mediante pago.

**Crédito obligatorio:** Gráficos de escenario: **Knowledge Temple, por pingupollas** — https://pingupollas.itch.io/knowledge-temple

Los recursos integrados forman parte del proyecto jugable; no deben extraerse y publicarse como un pack gráfico independiente. El proyecto utiliza imágenes aportadas por el titular del repositorio y modificadas para componer las habitaciones.

## GothicVania Church Pack — Luis Zuno (Ansimuz)

- **Uso:** los proyectiles de fuego del Hechicero. Los sprites de **Angel, Burning Ghoul y Skeleton Wizard** de `assets/gothic_enemies/` se conservan como respaldo; las entidades del juego son ahora arte original (`assets/visual/enemies/`).
- **Autor:** Luis Zuno (**Ansimuz**).
- **Páginas oficiales:** https://ansimuz.itch.io/gothicvania-church-pack y https://opengameart.org/content/gothicvania-church-pack
- OpenGameArt identifica la publicación de este pack bajo **CC0**, con atribución voluntaria. El paquete aportado también incluía `assets/gothic_enemies/LICENSE-GOTHICVANIA.txt`.

**Crédito voluntario:** Sprites de enemigos: **Luis Zuno (@ansimuz)**.

## Protagonista y otros contenidos

- **Protagonista (variantes masculina y femenina), entidades (incluido el Segador de Hilos) e iconos:** arte original del proyecto, generado por `herramientas/generar_protagonista.py`, `herramientas/generar_enemigos.py`, `herramientas/generar_mercader.py` (Mercader Silencioso), `herramientas/generar_iconos.py`, `herramientas/generar_cuerpos.py` (cuerpos bajo las almas), `herramientas/generar_retrato.py` (retratos masculino y femenino) y `herramientas/generar_decorados.py` (decorados de las salas).
- **Tipografía:** Pixelify Sans, © The Pixelify Sans Project Authors, bajo la SIL Open Font License 1.1 (texto completo en `assets/fonts/OFL_PixelifySans.txt`). Fuente: repositorio google/fonts. Mark todavía no está integrado como personaje con nombre.
- **Audio:** música y efectos de `audio/` son originales, sintetizados por `herramientas/generar_audio.py` (sin muestras de terceros). El código y el audio no comparten necesariamente la licencia del arte de terceros.
- No se declara que el proyecto completo sea CC0, MIT u otra licencia general: el titular decidirá más adelante la licencia de su código y contenido propio.

## Publicación

La release alpha presenta el **código fuente de un prototipo de videojuego**, no una biblioteca de recursos gráficos ni una redistribución comercial independiente de los packs. Antes de publicar un juego comercial conviene volver a revisar las condiciones originales y los créditos en el propio juego.

## Tipografía de rótulos (etapa 2)
- **Jacquard 24** (The Soft Type Project Authors), licencia SIL Open Font License 1.1: `assets/fonts/Jacquard24-Regular.ttf`, licencia en `assets/fonts/OFL_Jacquard24.txt`. Fuente: repositorio de Google Fonts (`ofl/jacquard24`).
- La niebla (`assets/visual/fx/niebla.png`) es original, generada por `herramientas/generar_niebla.py`.

## Recursos del primer juego del autor (etapa 3)
- **Sonidos de impacto y pasos** — Kenney, paquete «Impact Sounds», **CC0**: `audio/kenney/` (ver `audio/kenney/LICENCIA.txt`).
- **Controles en pantalla** — Kenney, paquete «Onscreen Controls», **CC0**: `assets/visual/controles/` (ver su `LICENCIA.txt`).
- **Máscaras de transición** (`assets/visual/fx/transicion_*.png`), **alimañas** (`assets/visual/enemies/alimana.png`) y **cursor** (`assets/visual/cursor.png`): originales, generados por `herramientas/generar_transiciones.py` y `herramientas/generar_alimanas.py`. Las máscaras del primer juego no se copiaron porque su origen y licencia no constan.
- **No se usaron**, por estilo o por licencia dudosa: tiles y personajes de Pixel Platformer, música chiptune, «Competitive – Fired Up», música de Visual Novel Maker, fuentes Pixeldust («All rights reserved») y BitPotion, y la imagen «background clickbait».

