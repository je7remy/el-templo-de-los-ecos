from pathlib import Path
base=Path(__file__).resolve().parent.parent
expected=['project.godot','scenes/main.tscn','scripts/main.gd']
expected += [f'assets/knowledge/rooms/room_{i}.png' for i in range(5)]
expected += [f'assets/gothic_enemies/angel_{i}.png' for i in range(1,9)]
expected += [f'assets/gothic_enemies/ghoul_{i}.png' for i in range(1,9)]
expected += [f'assets/gothic_enemies/wizard_{i}.png' for i in range(1,6)]
expected += [f'assets/gothic_enemies/fireball_{i}.png' for i in range(1,4)]
missing=[p for p in expected if not (base/p).is_file()]
if missing:
 print('FALTAN:',*missing,sep='\n - ');raise SystemExit(1)
print(f'OK: {len(expected)} archivos fundamentales verificados.')
