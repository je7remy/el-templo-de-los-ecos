#!/usr/bin/env python3
"""Sintetiza la música y los efectos ORIGINALES del juego (sin muestras de terceros).

Salida en audio/ (OGG Vorbis, requiere ffmpeg con libvorbis):
  musica_templo.ogg   ambiente del templo, bucle de 64 s sin cortes (estéreo)
  musica_tension.ogg  capa de tensión sincronizable: latido + cuerdas disonantes
  sfx_*.ogg           efectos: alma, daño, ojo, aviso, sello, puerta, conjuro,
                      libro, linterna, muerte, fósforo, apagar, objeto, golpe,
                      impacto, inmune, resonancia, destierro, interfaz, toque,
                      cuchillo
  sfx_paso_1..3.ogg   pisadas sobre losa (tres variaciones)

Diseño: re menor / frigio. Acordes Dm, B♭, Gm y E♭ (el II♭ frigio da la
inquietud). Todo LFO completa un número entero de ciclos en el bucle y la
reverberación se pliega de forma circular, así que el final empalma con el
principio. Semilla fija: el resultado es reproducible.

Uso:  python3 herramientas/generar_audio.py
"""
from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

import numpy as np
from scipy import signal

RAIZ = Path(__file__).resolve().parent.parent
SALIDA = RAIZ / "audio"
SR = 44100
BUCLE = 64.0
rng = np.random.default_rng(20261120)


def nota(n: str) -> float:
    nombres = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6,
               "G": 7, "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}
    octava = int(n[-1])
    return 440.0 * 2 ** ((nombres[n[:-1]] + 12 * (octava + 1) - 69) / 12)


def t_(dur: float) -> np.ndarray:
    return np.arange(int(dur * SR)) / SR


def saw(f, t, fase=0.0):
    return 2.0 * ((f * t + fase) % 1.0) - 1.0


def paso_bajo(x, fc, orden=2):
    b, a = signal.butter(orden, fc / (SR / 2), "low")
    return signal.lfilter(b, a, x, axis=0)


def paso_banda(x, f1, f2, orden=2):
    b, a = signal.butter(orden, [f1 / (SR / 2), f2 / (SR / 2)], "band")
    return signal.lfilter(b, a, x, axis=0)


def circular(fn, x):
    """Aplica un filtro como si la señal se repitiera: sin arranque en frío en el bucle."""
    doble = np.concatenate([x, x], axis=0)
    return fn(doble)[len(x):]


def ruido_periodico(n, f1, f2):
    """Ruido de banda generado en frecuencia: es periódico en n muestras por construcción."""
    espectro = np.zeros(n // 2 + 1, complex)
    frecs = np.fft.rfftfreq(n, 1 / SR)
    banda = (frecs >= f1) & (frecs <= f2)
    espectro[banda] = np.exp(2j * np.pi * rng.random(banda.sum())) / np.sqrt(np.maximum(frecs[banda], 1) / f1)
    x = np.fft.irfft(espectro, n)
    return x / (np.abs(x).max() + 1e-9)


def ruido_rosa(n):
    blanco = rng.standard_normal(n)
    b = [0.049922035, -0.095993537, 0.050612699, -0.004408786]
    a = [1, -2.494956002, 2.017265875, -0.522189400]
    return signal.lfilter(b, a, blanco) * 3.0


def reverb_ir(seg: float, oscuridad: float = 3000.0) -> np.ndarray:
    n = int(seg * SR)
    env = np.exp(-np.arange(n) / SR * (6.9 / seg))
    ir = np.stack([rng.standard_normal(n) * env, rng.standard_normal(n) * env], axis=1)
    ir = paso_bajo(ir, oscuridad)
    ir[0] = 0
    return ir / np.abs(ir).sum(axis=0).max() * 40


def reverb_circular(x: np.ndarray, seg: float, mezcla: float, oscuridad: float = 3000.0) -> np.ndarray:
    """Reverberación cuyo rabo vuelve al principio: el bucle empalma sin corte."""
    ir = reverb_ir(seg, oscuridad)
    n = len(x)
    salida = np.zeros_like(x)
    for c in range(2):
        humedo = signal.fftconvolve(x[:, c], ir[:, c])
        plegado = humedo[:n].copy()
        resto = humedo[n:]
        while len(resto):
            k = min(n, len(resto))
            plegado[:k] += resto[:k]
            resto = resto[k:]
        salida[:, c] = plegado
    return x * (1 - mezcla) + salida * mezcla


def fundido_final(x: np.ndarray, seg: float = 0.08) -> np.ndarray:
    n = min(int(seg * SR), len(x))
    x = x.copy()
    rampa = np.linspace(1, 0, n) ** 2
    x[-n:] = x[-n:] * (rampa if x.ndim == 1 else rampa[:, None])
    return x


def reverb_simple(x: np.ndarray, seg: float, mezcla: float, oscuridad: float = 4000.0) -> np.ndarray:
    x = fundido_final(x)
    ir = reverb_ir(seg, oscuridad)
    if x.ndim == 1:
        x = np.stack([x, x], axis=1)
    cola = np.zeros((len(ir), 2))
    seco = np.vstack([x, cola])
    humedo = np.stack([signal.fftconvolve(seco[:, c], ir[:, c])[:len(seco)] for c in range(2)], axis=1)
    return seco * (1 - mezcla) + humedo * mezcla


def estereo(m: np.ndarray, pan: float = 0.0) -> np.ndarray:
    izq = np.cos((pan + 1) * np.pi / 4)
    der = np.sin((pan + 1) * np.pi / 4)
    return np.stack([m * izq, m * der], axis=1)


def normalizar(x: np.ndarray, pico: float = 0.89) -> np.ndarray:
    return x / (np.abs(x).max() + 1e-9) * pico


def lfo(t, ciclos_en_bucle: int, fase: float = 0.0) -> np.ndarray:
    return np.sin(2 * np.pi * ciclos_en_bucle * t / BUCLE + fase)


def guardar(nombre: str, x: np.ndarray, calidad: int = 4) -> None:
    x = np.clip(x, -1, 1)
    if x.ndim == 1:
        x = x[:, None]
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / "a.wav"
        from scipy.io import wavfile
        wavfile.write(wav, SR, (x * 32767).astype(np.int16))
        destino = SALIDA / nombre
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis",
                        "-q:a", str(calidad), str(destino)], check=True)
    print(f"{nombre}: {len(x) / SR:.1f} s, {destino.stat().st_size // 1024} KB")


# ---------------------------------------------------------------- MÚSICA
ACORDES = [  # cada uno 16 s
    ["D3", "F3", "A3", "D4"],
    ["Bb2", "D3", "F3", "Bb3"],
    ["G2", "Bb2", "D3", "G3"],
    ["Eb3", "G3", "Bb3", "Eb4"],
]


def coro(t: np.ndarray) -> np.ndarray:
    """Pad coral: sierras desafinadas filtradas por formantes de 'ah', acordes que se funden."""
    total = np.zeros((len(t), 2))
    tramo = BUCLE / len(ACORDES)
    for i, acorde in enumerate(ACORDES):
        centro = i * tramo + tramo / 2
        # Envolvente circular (empalma en el bucle): campana de 22 s centrada en el tramo.
        d = (t - centro + BUCLE / 2) % BUCLE - BUCLE / 2
        env = np.clip(1 - (np.abs(d) / 11.0) ** 2, 0, 1) ** 1.5
        for j, n in enumerate(acorde):
            f = nota(n)
            voz = np.zeros(len(t))
            for det in (-0.12, 0.0, 0.11):
                ciclos = round(f * (1 + det / 100) * BUCLE)  # frecuencia que cierra el bucle
                voz += saw(ciclos / BUCLE, t, rng.random())
            formantes = circular(lambda v: paso_banda(v, 500, 1300), voz) + circular(lambda v: paso_banda(v, 180, 520), voz) * 0.7
            vibrato = 1 + 0.15 * lfo(t, 64 * 5, j)
            total += estereo(formantes * env * vibrato * 0.10, pan=(j - 1.5) * 0.35)
    return circular(lambda v: paso_bajo(v, 1800), total)


def dron(t: np.ndarray) -> np.ndarray:
    base = np.zeros(len(t))
    for f, amp in ((nota("D1"), 1.0), (nota("A1"), 0.55), (nota("D2"), 0.35)):
        for det in (-0.08, 0.08):
            ciclos = round(f * (1 + det / 100) * BUCLE)
            base += amp * (np.sin(2 * np.pi * ciclos / BUCLE * t) + 0.25 * saw(ciclos / BUCLE, t))
    base = circular(lambda v: paso_bajo(v, 220), base)
    respira = 0.75 + 0.25 * lfo(t, 4)
    return estereo(base * respira * 0.16)


def campanas(t: np.ndarray) -> np.ndarray:
    """Campana lejana e inarmónica al cambiar de acorde."""
    total = np.zeros((len(t), 2))
    golpes = [(1.5, "D3", -0.5), (17.5, "Bb2", 0.4), (33.5, "G2", -0.3), (49.5, "Eb3", 0.5), (57.0, "A3", 0.1)]
    for inicio, n, pan in golpes:
        f = nota(n)
        d = (t - inicio) % BUCLE
        env = np.exp(-d / 3.2) * (d < 14)
        tono = np.zeros(len(t))
        for parcial, amp in ((0.5, 0.6), (1.0, 1.0), (2.0, 0.5), (2.4, 0.35), (2.98, 0.25), (4.2, 0.12)):
            tono += amp * np.sin(2 * np.pi * f * parcial * d) * np.exp(-d * parcial * 0.25)
        total += estereo(tono * env * 0.06, pan)
    return total


def viento(t: np.ndarray) -> np.ndarray:
    capas = np.zeros((len(t), 2))
    for k, (f1, f2) in enumerate(((200, 600), (500, 1400))):
        banda = ruido_periodico(len(t), f1, f2)
        mov = 0.5 + 0.5 * lfo(t, 3 + k, k * 1.7)
        capas += estereo(banda * mov * 0.09, pan=(-0.6 if k == 0 else 0.6))
    return capas


def musica_templo() -> np.ndarray:
    t = t_(BUCLE)
    mezcla = dron(t) + coro(t) + campanas(t) + viento(t)
    return normalizar(reverb_circular(mezcla, 4.5, 0.45, 2600), 0.8)


def musica_tension() -> np.ndarray:
    t = t_(BUCLE)
    total = np.zeros((len(t), 2))
    # Latido: 75 latidos en 64 s (~70 lpm), lub-dub.
    periodo = BUCLE / 75
    for k in range(75):
        for desfase, amp in ((0.0, 1.0), (0.22, 0.7)):
            ini = k * periodo + desfase
            d = (t - ini) % BUCLE
            env = np.exp(-d / 0.07) * (d < 0.5)
            golpe = np.sin(2 * np.pi * (52 + 30 * np.exp(-d / 0.03)) * d) * env * amp
            total += estereo(golpe * 0.5)
    # Cúmulo disonante en trémolo: re, mi♭ y sol# (tritono).
    cuerdas = np.zeros(len(t))
    for n in ("D5", "Eb5", "G#4", "D4"):
        ciclos = round(nota(n) * BUCLE)
        cuerdas += saw(ciclos / BUCLE, t, rng.random())
    cuerdas = circular(lambda v: paso_bajo(paso_banda(v, 300, 2600), 1600), cuerdas)
    tremolo = 0.6 + 0.4 * np.sin(2 * np.pi * round(6.5 * BUCLE) / BUCLE * t)
    oleaje = 0.55 + 0.45 * lfo(t, 8)
    total += estereo(cuerdas * tremolo * oleaje * 0.05, -0.3) + estereo(cuerdas * tremolo * (1 - oleaje + 0.3) * 0.04, 0.3)
    # Pulso sub grave.
    sub = np.sin(2 * np.pi * round(nota("D1") * BUCLE) / BUCLE * t) * (0.5 + 0.5 * lfo(t, 16))
    total += estereo(sub * 0.12)
    return normalizar(reverb_circular(total, 2.5, 0.3, 3500), 0.8)


# ---------------------------------------------------------------- EFECTOS
def env_ad(t, ataque, caida):
    return np.minimum(t / max(ataque, 1e-4), 1.0) * np.exp(-np.maximum(t - ataque, 0) / caida)


def sfx_alma() -> np.ndarray:
    t = t_(1.3)
    x = np.zeros(len(t))
    for k, n in enumerate(("E5", "B5", "E6", "G#6", "B6")):
        ini = k * 0.06
        d = np.maximum(t - ini, 0)
        x += np.sin(2 * np.pi * nota(n) * d) * env_ad(d, 0.01, 0.45) * (t >= ini) * (0.9 - k * 0.1)
    chispa = paso_banda(rng.standard_normal(len(t)), 5000, 11000) * env_ad(t, 0.005, 0.25) * 0.15
    return normalizar(reverb_simple(x * 0.4 + chispa, 1.8, 0.4, 7000), 0.7)


def sfx_dano() -> np.ndarray:
    t = t_(0.7)
    golpe = np.sin(2 * np.pi * (40 + 90 * np.exp(-t / 0.05)) * t) * env_ad(t, 0.002, 0.18)
    ruido = paso_bajo(rng.standard_normal(len(t)), 1800) * env_ad(t, 0.001, 0.08)
    disonante = (np.sin(2 * np.pi * nota("D4") * t) + np.sin(2 * np.pi * nota("Eb4") * t)) * env_ad(t, 0.01, 0.25) * 0.25
    x = np.tanh((golpe + ruido * 0.6 + disonante) * 2.2)
    return normalizar(reverb_simple(x, 1.2, 0.25, 2500), 0.85)


def sfx_ojo() -> np.ndarray:
    """El ojo se abre: soplo grave que crece y un cúmulo que se clava."""
    t = t_(1.6)
    crece = np.clip(t / 0.9, 0, 1) ** 2 * np.exp(-np.maximum(t - 0.9, 0) / 0.35)
    soplo = paso_banda(rng.standard_normal(len(t)), 120, 900) * crece * 0.6
    cumulo = sum(np.sin(2 * np.pi * nota(n) * t) for n in ("A4", "Bb4", "E5")) * crece * 0.25
    sub = np.sin(2 * np.pi * nota("D2") * t) * crece * 0.5
    return normalizar(reverb_simple(soplo + cumulo + sub, 2.5, 0.4, 3000), 0.8)


def sfx_aviso() -> np.ndarray:
    """Aviso previo: crujido de piedra y susurro ascendente."""
    t = t_(0.6)
    susurro = paso_banda(rng.standard_normal(len(t)), 1200, 4000) * env_ad(t, 0.4, 0.15) * 0.3
    crujido = np.zeros(len(t))
    for k in range(14):
        p = int(rng.uniform(0.0, 0.5) * SR)
        crujido[p:p + 300] += rng.standard_normal(300) * np.exp(-np.arange(300) / 60)
    crujido = paso_banda(crujido, 300, 2000) * 0.4
    return normalizar(reverb_simple(susurro + crujido, 1.0, 0.3), 0.6)


def sfx_sello() -> np.ndarray:
    t = t_(3.2)
    f = nota("D3")
    campana = sum(a * np.sin(2 * np.pi * f * p * t) * np.exp(-t * p * 0.5) for p, a in
                  ((1, 1.0), (2.0, 0.6), (2.4, 0.4), (3.0, 0.3), (4.2, 0.2), (5.4, 0.1)))
    coro_ = sum(np.sin(2 * np.pi * nota(n) * t) for n in ("D4", "F4", "A4", "D5")) * env_ad(t, 0.8, 1.2) * 0.15
    return fundido_final(normalizar(reverb_simple(campana * 0.5 + coro_, 3.0, 0.45, 3500), 0.8), 0.3)


def sfx_puerta() -> np.ndarray:
    t = t_(1.6)
    roce = paso_bajo(rng.standard_normal(len(t)), 700) * (0.6 + 0.4 * np.sin(2 * np.pi * 9 * t)) * env_ad(t, 0.15, 0.6)
    retumbo = np.sin(2 * np.pi * 45 * t) * env_ad(t, 0.05, 0.5)
    return normalizar(reverb_simple(roce * 0.8 + retumbo * 0.6, 2.0, 0.35, 2000), 0.8)


def sfx_conjuro() -> np.ndarray:
    t = t_(0.8)
    barrido = paso_banda(rng.standard_normal(len(t)), 400, 3000) * env_ad(t, 0.12, 0.25)
    chisporroteo = (rng.random(len(t)) > 0.995).astype(float) * rng.standard_normal(len(t)) * env_ad(t, 0.05, 0.4)
    tono = np.sin(2 * np.pi * (300 + 500 * t) * t) * env_ad(t, 0.05, 0.3) * 0.3
    return normalizar(reverb_simple(barrido + chisporroteo * 2 + tono, 1.0, 0.25), 0.75)


def sfx_libro() -> np.ndarray:
    t = t_(1.6)
    compuerta = np.clip((np.sin(2 * np.pi * 7 * t) - 0.5) / 0.5, 0, 1) ** 2
    paginas = paso_banda(rng.standard_normal(len(t)), 2000, 7000) * compuerta * env_ad(t, 0.05, 0.5) * 0.4
    brillo = sum(np.sin(2 * np.pi * nota(n) * t) for n in ("A5", "D6", "F6")) * env_ad(t, 0.3, 0.6) * 0.15
    return normalizar(reverb_simple(paginas + brillo, 2.0, 0.4, 6000), 0.6)


def sfx_linterna() -> np.ndarray:
    t = t_(0.12)
    clic = rng.standard_normal(len(t)) * np.exp(-t / 0.006) + np.sin(2 * np.pi * 1800 * t) * np.exp(-t / 0.01) * 0.5
    return normalizar(paso_banda(clic, 800, 6000), 0.5)


def sfx_muerte() -> np.ndarray:
    t = t_(4.0)
    caida = 1 - 0.35 * np.clip(t / 3.0, 0, 1)
    x = sum(saw(nota(n) * caida, t) for n in ("D3", "Eb3", "A3"))
    x = paso_bajo(x, 900) * env_ad(t, 0.3, 1.5) * 0.4
    sub = np.sin(2 * np.pi * 38 * t) * env_ad(t, 0.2, 2.0) * 0.6
    return normalizar(reverb_simple(x + sub, 3.5, 0.5, 2500), 0.85)


def _paso(semilla: int) -> np.ndarray:
    """Pisada sobre losa: golpe sordo del talón y roce corto de la suela."""
    r = np.random.default_rng(semilla)
    t = t_(0.22)
    talon = paso_bajo(r.standard_normal(len(t)), 420 + 60 * semilla) * env_ad(t, 0.002, 0.03)
    roce = paso_banda(r.standard_normal(len(t)), 1500, 5000) * env_ad(np.maximum(t - 0.03, 0), 0.01, 0.04) * (t > 0.03) * 0.25
    cuerpo = np.sin(2 * np.pi * (85 + 10 * semilla) * t) * env_ad(t, 0.002, 0.04) * 0.5
    return normalizar(reverb_simple(talon + roce + cuerpo, 0.6, 0.18, 2500), 0.55)


def sfx_fosforo() -> np.ndarray:
    """Raspado del fósforo y la llama que prende."""
    t = t_(0.9)
    raspado = paso_banda(rng.standard_normal(len(t)), 2500, 9000) * env_ad(t, 0.01, 0.06) * 0.8
    prende = paso_bajo(rng.standard_normal(len(t)), 900) * env_ad(np.maximum(t - 0.08, 0), 0.06, 0.25) * (t > 0.08)
    crepita = (rng.random(len(t)) > 0.997).astype(float) * env_ad(t, 0.1, 0.4) * 0.6
    return normalizar(reverb_simple(raspado + prende * 0.7 + crepita, 0.8, 0.2), 0.6)


def sfx_apagar() -> np.ndarray:
    """Soplo que apaga la antorcha."""
    t = t_(0.5)
    soplo = paso_banda(rng.standard_normal(len(t)), 300, 2500) * env_ad(t, 0.05, 0.12)
    return normalizar(reverb_simple(soplo, 0.6, 0.2, 2000), 0.45)


def sfx_objeto() -> np.ndarray:
    """Recoger un objeto: roce de tela y un tintineo breve."""
    t = t_(0.6)
    tela = paso_banda(rng.standard_normal(len(t)), 800, 4000) * env_ad(t, 0.03, 0.08) * 0.5
    tin = sum(np.sin(2 * np.pi * nota(n) * t) * env_ad(t, 0.004, 0.18) for n in ("A5", "E6")) * 0.25
    return normalizar(reverb_simple(tela + tin, 0.8, 0.25, 6000), 0.55)


def sfx_golpe() -> np.ndarray:
    """Golpe de antorcha: silbido del aire y fuego que ruge."""
    t = t_(0.4)
    silbido = paso_banda(rng.standard_normal(len(t)), 600, 3500) * np.sin(np.pi * np.clip(t / 0.18, 0, 1)) * 0.7
    fuego = paso_bajo(rng.standard_normal(len(t)), 500) * env_ad(t, 0.05, 0.12)
    return normalizar(silbido + fuego * 0.6, 0.6)


def sfx_impacto() -> np.ndarray:
    """La entidad recibe daño: choque seco con chasquido de brasas."""
    t = t_(0.5)
    choque = np.sin(2 * np.pi * (70 + 160 * np.exp(-t / 0.03)) * t) * env_ad(t, 0.001, 0.09)
    chasquido = paso_banda(rng.standard_normal(len(t)), 1500, 6000) * env_ad(t, 0.001, 0.05) * 0.6
    return normalizar(reverb_simple(np.tanh((choque + chasquido) * 2.0), 0.8, 0.2), 0.75)


def sfx_inmune() -> np.ndarray:
    """El golpe rebota: tañido metálico apagado."""
    t = t_(0.6)
    f = nota("G4")
    x = sum(a * np.sin(2 * np.pi * f * p * t) * np.exp(-t * 9 * p) for p, a in ((1, 1.0), (2.7, 0.5), (5.1, 0.3)))
    return normalizar(reverb_simple(x, 0.8, 0.3, 3000), 0.55)


def sfx_resonancia() -> np.ndarray:
    """Onda de Resonancia: sub grave que barre hacia afuera y un coro breve."""
    t = t_(1.4)
    onda = np.sin(2 * np.pi * (110 - 50 * np.clip(t / 0.6, 0, 1)) * t) * env_ad(t, 0.01, 0.35)
    coro_ = sum(np.sin(2 * np.pi * nota(n) * t) for n in ("D5", "A5", "D6")) * env_ad(t, 0.02, 0.4) * 0.2
    aire = paso_banda(rng.standard_normal(len(t)), 200, 1800) * env_ad(t, 0.03, 0.25) * 0.4
    return normalizar(reverb_simple(onda + coro_ + aire, 2.0, 0.4, 4000), 0.8)


def sfx_destierro() -> np.ndarray:
    """La entidad se disuelve: barrido descendente y polvo de ceniza."""
    t = t_(2.0)
    caida = np.exp(-t / 0.9)
    tono = sum(np.sin(2 * np.pi * nota(n) * (0.5 + 0.5 * caida) * t) for n in ("D5", "F5", "A5")) * env_ad(t, 0.02, 0.7) * 0.3
    polvo = paso_banda(rng.standard_normal(len(t)), 3000, 9000) * env_ad(t, 0.2, 0.6) * 0.25
    return fundido_final(normalizar(reverb_simple(tono + polvo, 2.5, 0.45, 5000), 0.75), 0.3)


def sfx_interfaz() -> np.ndarray:
    """Abrir el inventario o el altar: roce de cuero y clic de broche."""
    t = t_(0.35)
    cuero = paso_banda(rng.standard_normal(len(t)), 500, 2500) * env_ad(t, 0.02, 0.07) * 0.6
    clic = np.sin(2 * np.pi * 2400 * t) * np.exp(-np.maximum(t - 0.09, 0) / 0.008) * (t > 0.09) * 0.4
    return normalizar(cuero + clic, 0.5)


def sfx_toque() -> np.ndarray:
    """Tocar piedra sin respuesta: golpecito apagado."""
    t = t_(0.3)
    x = paso_bajo(rng.standard_normal(len(t)), 900) * env_ad(t, 0.001, 0.025) + np.sin(2 * np.pi * 180 * t) * env_ad(t, 0.001, 0.04) * 0.4
    return normalizar(reverb_simple(x, 0.5, 0.2, 2000), 0.4)


def sfx_cuchillo() -> np.ndarray:
    """Un cuchillo sale de entre la ropa: roce de tela y filo que silba."""
    t = t_(0.7)
    tela = paso_banda(rng.standard_normal(len(t)), 500, 2500) * env_ad(t, 0.02, 0.08) * 0.5
    filo = np.sin(2 * np.pi * (3200 + 900 * t) * t) * env_ad(np.maximum(t - 0.1, 0), 0.03, 0.18) * (t > 0.1) * 0.25
    roce = paso_banda(rng.standard_normal(len(t)), 4000, 9000) * env_ad(np.maximum(t - 0.1, 0), 0.05, 0.12) * (t > 0.1) * 0.4
    return normalizar(reverb_simple(tela + filo + roce, 1.0, 0.25, 6000), 0.65)


def sfx_hilo() -> np.ndarray:
    """El Segador tensa los hilos: cuerda que cruje y un tono que sube (0,9 s de aviso)."""
    t = t_(0.95)
    f = 180 + 520 * (t / t[-1]) ** 2
    tono = saw(f, t) * 0.18 * np.minimum(1.0, t / 0.6)
    cruje = paso_banda(rng.standard_normal(len(t)), 900, 3000) * (0.25 + 0.5 * (np.sin(2 * np.pi * 23 * t) > 0.6)) * 0.35
    return normalizar(fundido_final(reverb_simple(paso_bajo(tono, 2400) + cruje, 0.8, 0.2, 5000), 0.05), 0.6)


def sfx_latigo() -> np.ndarray:
    """Los hilos se disparan: chasquido seco de látigo y vibración que se clava en la piedra."""
    t = t_(0.8)
    chasquido = paso_banda(rng.standard_normal(len(t)), 2500, 9000) * env_ad(t, 0.002, 0.035)
    silbido = np.sin(2 * np.pi * (2400 - 1800 * np.minimum(t / 0.12, 1.0)) * t) * env_ad(t, 0.005, 0.09) * 0.35
    vibra = np.sin(2 * np.pi * 95 * t) * np.sin(2 * np.pi * 7 * t) * env_ad(np.maximum(t - 0.05, 0), 0.01, 0.4) * (t > 0.05) * 0.5
    return normalizar(reverb_simple(chasquido + silbido + vibra, 1.1, 0.3, 5000), 0.8)


def sfx_pinchos() -> np.ndarray:
    """Trampa: chasquido del mecanismo y hierro que sale del suelo."""
    t = t_(0.6)
    clic = paso_banda(rng.standard_normal(len(t)), 1500, 6000) * env_ad(t, 0.001, 0.02) * 0.6
    hierro = sum(np.sin(2 * np.pi * f * t) * a for f, a in ((1830, 0.3), (2710, 0.2), (3950, 0.12))) * env_ad(np.maximum(t - 0.04, 0), 0.004, 0.22) * (t > 0.04)
    roce = paso_banda(rng.standard_normal(len(t)), 3000, 9000) * env_ad(np.maximum(t - 0.04, 0), 0.01, 0.08) * (t > 0.04) * 0.4
    return normalizar(reverb_simple(clic + hierro + roce, 0.9, 0.25, 6000), 0.6)


def sfx_fuego() -> np.ndarray:
    """Las enredaderas prenden: bocanada de aire y chisporroteo seco."""
    t = t_(1.3)
    bocanada = paso_bajo(rng.standard_normal(len(t)), 900) * env_ad(t, 0.06, 0.5) * 0.7
    chispas = np.zeros(len(t))
    for _ in range(40):
        i = int(rng.uniform(0.05, 1.2) * SR)
        n = int(0.006 * SR)
        if i + n < len(t):
            chispas[i:i + n] += rng.standard_normal(n) * np.exp(-np.linspace(0, 6, n)) * rng.uniform(0.2, 0.6)
    return normalizar(reverb_simple(bocanada + paso_banda(chispas, 1500, 8000), 0.9, 0.2, 5000), 0.7)


def sfx_raices() -> np.ndarray:
    """La Tejedora alza las garras: madera que cruje y se retuerce."""
    t = t_(0.9)
    cruje = paso_banda(rng.standard_normal(len(t)), 200, 1400) * (0.4 + 0.6 * (np.sin(2 * np.pi * 17 * t) > 0.3))
    gemido = saw(70 + 30 * np.sin(2 * np.pi * 1.3 * t), t) * 0.25
    return normalizar(reverb_simple((cruje * 0.6 + gemido) * env_ad(t, 0.05, 0.6), 1.0, 0.3, 4000), 0.65)


def main() -> None:
    SALIDA.mkdir(exist_ok=True)
    guardar("musica_templo.ogg", musica_templo(), 3)
    guardar("musica_tension.ogg", musica_tension(), 3)
    for nombre, fn in (("sfx_alma", sfx_alma), ("sfx_dano", sfx_dano), ("sfx_ojo", sfx_ojo),
                       ("sfx_aviso", sfx_aviso), ("sfx_sello", sfx_sello), ("sfx_puerta", sfx_puerta),
                       ("sfx_conjuro", sfx_conjuro), ("sfx_libro", sfx_libro),
                       ("sfx_linterna", sfx_linterna), ("sfx_muerte", sfx_muerte),
                       ("sfx_fosforo", sfx_fosforo), ("sfx_apagar", sfx_apagar), ("sfx_objeto", sfx_objeto),
                       ("sfx_golpe", sfx_golpe), ("sfx_impacto", sfx_impacto), ("sfx_inmune", sfx_inmune),
                       ("sfx_resonancia", sfx_resonancia), ("sfx_destierro", sfx_destierro),
                       ("sfx_interfaz", sfx_interfaz), ("sfx_toque", sfx_toque),
                       ("sfx_cuchillo", sfx_cuchillo), ("sfx_hilo", sfx_hilo), ("sfx_latigo", sfx_latigo),
                       ("sfx_pinchos", sfx_pinchos), ("sfx_fuego", sfx_fuego), ("sfx_raices", sfx_raices)):
        guardar(f"{nombre}.ogg", fn(), 4)
    for i in range(3):
        guardar(f"sfx_paso_{i + 1}.ogg", _paso(i + 1), 3)


if __name__ == "__main__":
    main()
