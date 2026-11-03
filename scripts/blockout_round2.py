"""Blockout round 2 (SCENE_DESIGN_SLICE §5): materials, classroom shells, landmarks, signs, dungeon ceilings.
Usage: python3 -I blockout2.py /path/to/Academy.model.json
Idempotent: removes its own previous output before adding.
"""
import json
import sys

path = sys.argv[1]
w = json.loads(open(path).read())
kids = w['Children']


def props(name):
    return [c['Properties'] for c in kids if c['Name'] == name]


def part(name, pos, size, color, material, extra=None):
    p = {'Anchored': True, 'Position': pos, 'Size': size, 'Color': color, 'Material': material,
         'TopSurface': 'Smooth', 'BottomSurface': 'Smooth'}
    if extra:
        p.update(extra)
    return {'Name': name, 'ClassName': 'Part', 'Properties': p}


# --- Materials/colors on existing pieces (names untouched so gameplay lookups stay valid).
for p in props('PH_Floor'):
    p.update(Material='Grass', Color=[0.32, 0.43, 0.27])
for p in props('PH_Plaza'):
    p.update(Material='Slate', Color=[0.78, 0.74, 0.64])
for p in props('PH_Path'):
    p.update(Material='Cobblestone', Color=[0.6, 0.57, 0.5])
for p in props('PH_Boundary'):  # natural hedge edge instead of grey box walls
    p.update(Material='LeafyGrass', Color=[0.2, 0.38, 0.22])
for p in props('PH_LakeBackdrop'):
    p.update(Material='Glass', Color=[0.25, 0.45, 0.6], Transparency=0.25)
for p in props('PH_LightCore'):
    p.update(Material='Marble', Color=[0.9, 0.86, 0.74])
zone_style = {  # by pad centre (x, z)
    (-60, -185): ('WoodPlanks', [0.7, 0.55, 0.38]), (0, -150): ('WoodPlanks', [0.74, 0.6, 0.4]),
    (60, -175): ('WoodPlanks', [0.7, 0.55, 0.38]), (260, -60): ('Grass', [0.36, 0.48, 0.30]),
    (330, -330): ('Slate', [0.55, 0.55, 0.52]), (-230, 190): ('Sand', [0.76, 0.7, 0.5]),
}
for p in props('PH_ZonePad'):
    material, color = zone_style[(p['Position'][0], p['Position'][2])]
    p.update(Material=material, Color=color)
for p in props('PH_DungeonFloor'):
    p.update(Material='Ground', Color=[0.25, 0.38, 0.36])
for p in props('PH_DungeonWall'):
    p.update(Material='Metal', Color=[0.22, 0.27, 0.28])

# --- New decor, all inside one folder so it never shadows gameplay names.
WALL = ([0.92, 0.88, 0.78], 'Plaster')
ROOF = ([0.62, 0.36, 0.28], 'ClayRoofTiles')
H = 20  # wall height


def room_shell(x0, x1, z0, z1, door_x, door_w):
    """Four walls with a door gap in the south wall (z1, facing the plaza) and a roof."""
    cx, cz, wx, dz = (x0 + x1) / 2, (z0 + z1) / 2, x1 - x0, z1 - z0
    left, right = door_x - door_w / 2, door_x + door_w / 2
    return [
        part('PH_ClassWall', [x0, H / 2, cz], [2, H, dz], *WALL),
        part('PH_ClassWall', [x1, H / 2, cz], [2, H, dz], *WALL),
        part('PH_ClassWall', [cx, H / 2, z0], [wx, H, 2], *WALL),
        part('PH_ClassWall', [(x0 + left) / 2, H / 2, z1], [left - x0, H, 2], *WALL),
        part('PH_ClassWall', [(right + x1) / 2, H / 2, z1], [x1 - right, H, 2], *WALL),
        part('PH_ClassRoof', [cx, H + 0.5, cz], [wx + 4, 1, dz + 4], *ROOF),
    ]


def sign(pos, text):
    return {'Name': 'PH_Signpost', 'ClassName': 'Part', 'Properties': {
        'Anchored': True, 'Position': pos, 'Size': [1, 8, 1], 'Color': [0.45, 0.33, 0.22], 'Material': 'Wood',
        'TopSurface': 'Smooth', 'BottomSurface': 'Smooth'},
        'Children': [{'Name': 'Sign', 'ClassName': 'BillboardGui', 'Properties': {
            'Size': {'UDim2': [[0, 260], [0, 44]]}, 'StudsOffset': [0, 6, 0], 'MaxDistance': 140},
            'Children': [{'Name': 'Label', 'ClassName': 'TextLabel', 'Properties': {
                'Size': {'UDim2': [[1, 0], [1, 0]]}, 'Text': text, 'TextScaled': True,
                'BackgroundColor3': [0.12, 0.13, 0.16], 'BackgroundTransparency': 0.2,
                'TextColor3': [1, 0.96, 0.88]}}]}]}


decor = []
# Classrooms: L1 shrinks its east wall to x=-20 so the 30-wide main path (x -15..15) stays clear.
decor += room_shell(-115, -20, -255, -115, -60, 30)
decor += room_shell(25, 95, -220, -130, 60, 24)
# Light core: crystal crown on the existing shaft (shaft centre y=60, height 120).
decor.append(part('PH_LightCoreCrystal', [0, 126, 0], [12, 12, 12], [1, 0.82, 0.4], 'Neon'))
# Ruins around the dungeon gate: broken columns and an arch over the entry prompt.
for (x, z, h) in [(306, -354, 14), (354, -354, 9), (306, -306, 6), (354, -306, 12)]:
    decor.append(part('PH_RuinPillar', [x, h / 2, z], [4, h, 4], [0.6, 0.6, 0.56], 'Slate'))
decor.append(part('PH_RuinPillar', [320, 9, -356], [3, 18, 3], [0.6, 0.6, 0.56], 'Slate'))
decor.append(part('PH_RuinPillar', [340, 9, -356], [3, 18, 3], [0.6, 0.6, 0.56], 'Slate'))
decor.append(part('PH_RuinArch', [330, 19, -356], [26, 3, 4], [0.56, 0.56, 0.52], 'Slate'))
# Garden hedges on the east and south edges; west (from the plaza) and north (to the ruins) stay open.
for (x, z, sx, sz) in [(320, -60, 4, 100), (210, -2, 20, 4), (310, -2, 20, 4)]:
    decor.append(part('PH_Hedge', [x, 2, z], [sx, 4, sz], [0.24, 0.45, 0.26], 'LeafyGrass'))
# Wayfinding at the first junctions a new player meets.
decor += [
    sign([12, 4, 128], '↑ ลานแกนแสง • ห้องเรียน'),
    sign([24, 4, -100], '↖ ห้องเรียนแรงลอยตัว  ↑ โถงบันทึก  ↗ ห้องเรียนแสง'),
    sign([118, 4, -40], '→ สวนอักขระ → ซากวิหาร (ดันเจียน)'),
    sign([-118, 4, -4], '← หอพัก'),
    sign([-112, 4, 100], '↙ สนามฝึก'),
]

# Dungeon: greenhouse glass ceiling over each room (closes the sky; the theme is underground).
ceilings = [part('PH_DungeonCeiling', [x, 11.5, 0], [wdt, 1, dep], [0.45, 0.7, 0.65], 'Glass', {'Transparency': 0.55})
            for (x, wdt, dep) in [(1200, 70, 90), (1320, 90, 120), (1430, 60, 70)]]

own = {'PH_Decor', 'PH_DungeonCeiling'}
kids[:] = [c for c in kids if c['Name'] not in own]
kids.append({'Name': 'PH_Decor', 'ClassName': 'Folder', 'Children': decor})
kids.extend(ceilings)


def tidy(v):
    return int(v) if isinstance(v, float) and v.is_integer() else v


def walk(node):
    p = node.get('Properties', {})
    for key in ('Position', 'Size'):
        if isinstance(p.get(key), list):
            p[key] = [tidy(v) for v in p[key]]
    for c in node.get('Children', []):
        walk(c)


walk(w)
open(path, 'w').write(json.dumps(w, indent=2) + '\n')
print(len(decor), 'decor parts,', len(ceilings), 'ceilings')
