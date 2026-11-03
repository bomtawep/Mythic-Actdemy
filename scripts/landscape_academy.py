"""Original primitive landscape study. Re-run after blockout_round2.py; no external assets.

Usage: python3 scripts/landscape_academy.py src/world/Academy.model.json
Only replaces PH_Landscape; all added parts are decorative and non-collidable.
"""
import json
import sys
from pathlib import Path

STONE = [0.79, 0.76, 0.65]
GOLD = [0.67, 0.52, 0.26]
BLUE = [0.18, 0.29, 0.36]
WOOD = [0.30, 0.23, 0.16]
LEAF = [[0.25, 0.39, 0.26], [0.33, 0.47, 0.29], [0.40, 0.51, 0.31]]
items = []


def part(name, pos, size, color, material='SmoothPlastic', shape=None):
    p = dict(Anchored=True, Position=pos, Size=size, Color=color,
             Material=material, CanCollide=False, CanTouch=False, CanQuery=False,
             TopSurface='Smooth', BottomSurface='Smooth')
    if shape:
        p['Shape'] = shape
    node = dict(Name=name, ClassName='Part', Properties=p,
                Attributes=dict(IsPlaceholder=True, PlaceholderId='PH-ACA-001'))
    items.append(node)
    return node


def tree(x, z, scale=1, variant=0):
    part('PH_TreeTrunk', [x, 10*scale, z], [3*scale, 20*scale, 3*scale], WOOD, 'Wood')
    # Unequal overlapping crowns avoid a uniform row of spheres.
    for dx, dy, dz, sx, sy, sz, tone in [
        (-5, 21, 0, 19, 15, 18, 0), (5, 25, 2, 21, 18, 20, 1),
        (0, 31, -3, 19, 17, 17, 2),
    ]:
        part('PH_TreeCanopy', [x+dx*scale, dy*scale, z+dz*scale],
             [sx*scale, sy*scale, sz*scale], LEAF[(tone+variant)%3], 'Grass', 'Ball')


def planter(x, z):
    part('PH_Planter', [x, 1, z], [22, 2, 14], STONE, 'Limestone')
    part('PH_Planter', [x, 2.05, z], [19, .3, 11], WOOD, 'Ground')
    for dx, dz, s in [(-6, -1, 7), (0, 1, 8), (6, -1, 6)]:
        part('PH_Shrub', [x+dx, 3.7, z+dz], [s, 5, 7], LEAF[1], 'Grass', 'Ball')


def lamp(x, z):
    part('PH_Lantern', [x, .8, z], [3, 1.6, 3], STONE, 'Limestone')
    part('PH_Lantern', [x, 5.8, z], [.7, 9, .7], BLUE, 'Metal')
    part('PH_Lantern', [x, 10.8, z], [2.5, .5, 2.5], GOLD, 'Metal')
    part('PH_Lantern', [x, 12.2, z], [1.6, 2.3, 1.6], [1, .84, .53], 'Neon')
    part('PH_Lantern', [x, 13.6, z], [3, .5, 3], BLUE, 'Metal')


def bench(x, z):
    for dx in [-6, 6]:
        part('PH_GardenBench', [x+dx, 1.4, z], [1.5, 2.8, 4], STONE, 'Limestone')
    part('PH_GardenBench', [x, 3, z], [16, .8, 4.5], WOOD, 'WoodPlanks')
    part('PH_GardenBench', [x, 5, z+2], [16, 3, .7], WOOD, 'WoodPlanks')


def build():
    # Frame the courtyard without crossing any route, station or sign.
    for x, z, s, v in [(-145,-95,1.2,0), (-150,55,1.1,1), (150,30,1.25,0),
                       (145,105,1,1), (-145,-285,1.35,0), (125,-255,1.2,1),
                       (-300,-100,1.4,0), (-335,80,1.2,1), (-310,245,1,0),
                       (345,100,1.35,1), (350,-180,1.15,0), (205,-155,1.1,1),
                       (-110,240,.9,1), (105,245,1.05,0), (225,20,.8,0)]:
        tree(x,z,s,v)
    for x,z in [(-82,82), (82,82), (-82,-82), (82,-82)]:
        planter(x,z)
    for x,z in [(-80,65), (80,65), (-80,-64), (80,-64)]:
        bench(x,z)
    for x,z in [(-22,100),(22,100),(-22,-90),(22,-90),(-140,-42),
                (-220,-42),(135,-82),(185,-82),(238,-145),(238,-260)]:
        lamp(x,z)
    # Cream pilasters, cornices and blue/gold entrance lintels on both classrooms.
    for x0,x1,z0,z1,door in [(-115,-20,-255,-115,-60),(25,95,-220,-130,60)]:
        for x in [x0,x1]:
            for z in [z0,z1]:
                part('PH_ArchitectureTrim',[x,10,z],[3,20,3],STONE,'Limestone')
                part('PH_ArchitectureTrim',[x,19,z],[4,1.5,4],GOLD,'Metal')
        for y, height in [(1,1.5),(19,1)]:
            part('PH_ArchitectureTrim',[(x0+x1)/2,y,z0],[x1-x0+3,height,3],STONE,'Limestone')
        part('PH_ArchitectureTrim',[(x0+x1)/2,21,z0+(z1-z0)/2],
             [x1-x0+7,1,z1-z0+7],BLUE,'Slate')
        part('PH_ArchitectureTrim',[door,17,z1+1.3],[26,4,.8],BLUE,'Metal')
        part('PH_ArchitectureTrim',[door,14.7,z1+1.4],[27,.5,1],GOLD,'Metal')
        for x in [x0+10,x1-10]:
            part('PH_ArchitectureTrim',[x,11,z1+1.2],[7,9,.4],[.40,.60,.62],'Glass')
            for dx in [-3.8,3.8]:
                part('PH_ArchitectureTrim',[x+dx,11,z1+1.5],[.6,10,.6],GOLD,'Metal')
    # Low stone edging only at quiet plaza stretches; openings stay unobstructed.
    for x in [-105,105]:
        for z in [-75,65]:
            part('PH_StoneEdging',[x,.5,z],[2,1,44],STONE,'Limestone')
    # Irregular shoreline rocks give the lake a readable land edge.
    for i,(x,z) in enumerate([(-330,274),(-290,277),(-210,273),(-160,276),
                            (-60,275),(30,277),(150,274),(220,277),(310,274)]):
        part('PH_ShoreRock',[x,1.7,z],[12+i%3*4,5+i%2,8+i%3],
             [.44,.47,.40],'Slate','Ball')


if __name__ == '__main__':
    path = Path(sys.argv[1])
    world = json.loads(path.read_text())
    build()
    world['Children'] = [n for n in world['Children'] if n.get('Name') != 'PH_Landscape']
    world['Children'].append(dict(Name='PH_Landscape', ClassName='Folder',
        Attributes=dict(IsPlaceholder=True, PlaceholderId='PH-ACA-001'), Children=items))
    path.write_text(json.dumps(world, indent=2)+'\n')
    print(f'Landscape: {len(items)} decorative parts; no lights, scripts or external assets')
