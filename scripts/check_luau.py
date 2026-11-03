"""Compile project Luau and run deterministic progress tests with official Luau CLI.
Usage: python3 scripts/check_luau.py --bin-dir /path/to/luau-tools
No Roblox credentials or network requests are used by this runner.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--bin-dir', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent.parent
# Placeholder registry check needs no Luau tools, so run it first and stop on drift.
subprocess.run([sys.executable, str(root / 'scripts/check_placeholders.py')], check=True)
compiler = args.bin_dir / 'luau-compile'
runtime = args.bin_dir / 'luau'
files = sorted((root / 'src').rglob('*.luau')) + sorted((root / 'tests').rglob('*.luau'))
for path in files:
    result = subprocess.run([str(compiler), str(path)], capture_output=True)
    if result.returncode:
        raise SystemExit((result.stderr or result.stdout).decode("utf-8", errors="replace"))
print(f'PASS: {len(files)} Luau files compile', flush=True)
schema = (root / 'src/server/ProgressSchema.luau').read_text()
service = (root / 'src/server/ProgressService.luau').read_text()
test = (root / 'tests/progress_service.luau').read_text()
bundle = '\n'.join([
    'local Schema = (function()\n' + schema + '\nend)()',
    'local function newService(game, task)\nlocal function warn(_) end\n'
    'local script = {Parent = {WaitForChild = function(_, name) return name end}}\n'
    'local function require(_) return Schema end\n' + service + '\nend',
    'local run = (function()\n' + test + '\nend)()',
    'run(newService, Schema)',
    'local Journal = (function()\n' + (root / 'src/client/JournalModel.luau').read_text() + '\nend)()',
    'local testJournal = (function()\n' + (root / 'tests/journal_model.luau').read_text() + '\nend)()',
    'testJournal(Journal)',
    'local Pet = (function()\n' + (root / 'src/shared/PetPolicy.luau').read_text() + '\nend)()',
    'local testPet = (function()\n' + (root / 'tests/pet_policy.luau').read_text() + '\nend)()',
    'testPet(Pet)',
    'local Dungeon = (function()\n' + (root / 'src/shared/DungeonRules.luau').read_text() + '\nend)()',
    'local testDungeon = (function()\n' + (root / 'tests/dungeon_rules.luau').read_text() + '\nend)()',
    'testDungeon(Dungeon)',
    'local Levitation = (function()\n' + (root / 'src/server/LevitationRules.luau').read_text() + '\nend)()',
    'local testLevitation = (function()\n' + (root / 'tests/levitation_rules.luau').read_text() + '\nend)()',
    'testLevitation(Levitation)',
    'local Encounter = (function()\n' + (root / 'src/shared/EncounterRules.luau').read_text() + '\nend)()',
    'local testEncounter = (function()\n' + (root / 'tests/encounter_rules.luau').read_text() + '\nend)()',
    'testEncounter(Encounter)',
    'local DungeonView = (function()\n' + (root / 'src/client/DungeonViewModel.luau').read_text() + '\nend)()',
    'local testDungeonView = (function()\n' + (root / 'tests/dungeon_view_model.luau').read_text() + '\nend)()',
    'testDungeonView(DungeonView)',
    'local Lifetime = (function()\n' + (root / 'src/client/VisualLifetime.luau').read_text() + '\nend)()',
    'local testLifetime = (function()\n' + (root / 'tests/visual_lifetime.luau').read_text() + '\nend)()',
    'testLifetime(Lifetime)',
    'local Scope = (function()\n' + (root / 'src/client/ControllerScope.luau').read_text() + '\nend)()',
    'local testScope = (function()\n' + (root / 'tests/controller_scope.luau').read_text() + '\nend)()',
    'testScope(Scope)',
    'local Light = (function()\n' + (root / 'src/shared/LightRules.luau').read_text() + '\nend)()',
    'local testLight = (function()\n' + (root / 'tests/light_rules.luau').read_text() + '\nend)()',
    'testLight(Light)',
    'local Shield = (function()\n' + (root / 'src/shared/ShieldRules.luau').read_text() + '\nend)()',
    'local testShield = (function()\n' + (root / 'tests/shield_rules.luau').read_text() + '\nend)()',
    'testShield(Shield)',
    'local ShieldJournal = (function()\n' + (root / 'src/client/ShieldJournalModel.luau').read_text() + '\nend)()',
    'local LightJournal = (function()\n' + (root / 'src/client/LightJournalModel.luau').read_text() + '\nend)()',
    'local Scroll = (function()\n' + (root / 'src/client/ScrollModel.luau').read_text() + '\nend)()',
    'local testScroll = (function()\n' + (root / 'tests/scroll_model.luau').read_text() + '\nend)()',
    'testScroll(Scroll)',
    'local testLightJournal = (function()\n' + (root / 'tests/light_journal.luau').read_text() + '\nend)()',
    'testLightJournal(LightJournal)',
    'local Dorm = (function()\n' + (root / 'src/shared/DormRules.luau').read_text() + '\nend)()',
    'local testDorm = (function()\n' + (root / 'tests/dorm_rules.luau').read_text() + '\nend)()',
    'testDorm(Dorm)',
    'local Preview = (function()\n' + (root / 'src/client/DormPreviewModel.luau').read_text() + '\nend)()',
    'local testPreview = (function()\n' + (root / 'tests/dorm_preview.luau').read_text() + '\nend)()',
    'testPreview(Preview,Dorm)',
    'local DormSchema = (function()\n' + (root / 'src/server/DormSchema.luau').read_text() + '\nend)()',
    'local DormRepository = (function()\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(_) return DormSchema end\n' + (root / 'src/server/DormRepository.luau').read_text() + '\nend)()',
    'local testDormRepository = (function()\n' + (root / 'tests/dorm_repository.luau').read_text() + '\nend)()',
    'testDormRepository(DormRepository,DormSchema)',
    'local Catalog = (function()\n' + (root / 'src/shared/FurnitureCatalog.luau').read_text() + '\nend)()',
    'local DormV2 = (function()\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal game={GetService=function() return {WaitForChild=function() return {WaitForChild=function(_,n) return n end} end} end}\nlocal function require(n) return if n=="DormSchema" then DormSchema else Catalog end\n' + (root / 'src/server/DormSchemaV2.luau').read_text() + '\nend)()',
    'local testMigration = (function()\n' + (root / 'tests/dorm_migration.luau').read_text() + '\nend)()',
    'testMigration(DormV2,Catalog)',
    'local Placement = (function()\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(_) return Catalog end\n' + (root / 'src/shared/FurniturePlacement.luau').read_text() + '\nend)()',
    'local testPlacement = (function()\n' + (root / 'tests/furniture_placement.luau').read_text() + '\nend)()',
    'testPlacement(Placement)',
    'local RepositoryV2 = (function()\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(_) return DormV2 end\n' + (root / 'src/server/DormRepositoryV2.luau').read_text() + '\nend)()',
    'local testRepositoryV2 = (function()\n' + (root / 'tests/dorm_repository_v2.luau').read_text() + '\nend)()',
    'testRepositoryV2(RepositoryV2,DormRepository,DormV2)',
    'local ManagerV2 = (function()\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(_) return DormV2 end\n' + (root / 'src/server/DormDataManagerV2.luau').read_text() + '\nend)()',
    'local testManagerV2 = (function()\n' + (root / 'tests/dorm_manager_v2.luau').read_text() + '\nend)()',
    'testManagerV2(ManagerV2,RepositoryV2)',
    'local DormManager = (function()\n' + (root / 'src/server/DormDataManager.luau').read_text() + '\nend)()',
    'local testDormManager = (function()\n' + (root / 'tests/dorm_data_manager.luau').read_text() + '\nend)()',
    'testDormManager(DormManager,DormRepository)',
])
# Load the unmodified service sources in a small Roblox API double environment.
flow_parts = ["local function loadFlowServices(env, progress)",
              "local deps = {ProgressService=progress, DungeonRules=Dungeon, EncounterRules=Encounter, LevitationRules=Levitation,ShieldRules=Shield}",
              "deps.LevitationConfig = (function()\n" + (root / 'src/shared/LevitationConfig.luau').read_text() + "\nend)()"]
for module_name in ['ShieldGuard','DungeonService', 'EncounterService', 'LessonService']:
    source = (root / f'src/server/{module_name}.luau').read_text()
    flow_parts.append(f"deps.{module_name} = (function()\n"
                      "local game, workspace, Vector3, os, task = env.game, env.workspace, env.Vector3, env.os, env.task\n"
                      "local script = {Parent={WaitForChild=function(_, name) return name end}}\n"
                      "local function require(name) return assert(deps[name], name) end\n" + source + "\nend)()")
flow_parts.extend(["return deps.DungeonService, deps.LessonService, deps.EncounterService,deps.ShieldGuard", "end"])
world = json.loads((root / 'src/world/Academy.model.json').read_text())
geometry = {item['Name']: item['Properties']['Position'] for item in world['Children'] if 'Position' in item.get('Properties', {})}
geometry_luau = '{' + ','.join('[' + json.dumps(name) + ']={' + ','.join(map(str, pos)) + '}' for name, pos in geometry.items()) + '}'
flow_parts.append('local runFlow = (function()\n' + (root / 'tests/service_flow.luau').read_text() + '\nend)()')
flow_parts.append('runFlow(loadFlowServices, ' + geometry_luau + ')')
flow_parts.append('runFlow(loadFlowServices, ' + geometry_luau + ',true)')
bundle += '\n' + '\n'.join(flow_parts)
dorm_world = json.loads((root / 'src/dorm/Room.model.json').read_text())
dorm_geometry = {item['Name']: item['Properties']['Position'] for item in dorm_world['Children']}
dorm_geometry_luau = '{' + ','.join('[' + json.dumps(name) + ']={' + ','.join(map(str, pos)) + '}' for name, pos in dorm_geometry.items()) + '}'
bundle += '\nlocal function loadDormService(env)\nlocal game,workspace,Vector3,CFrame,os=env.game,env.workspace,env.Vector3,env.CFrame,env.os\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal saved={}\nlocal persistence={Start=function() end,Load=function(p) if not saved[p] then saved[p]={x=0,z=0,rotation=0,placed=false} end; return table.clone(saved[p]) end,Get=function(p) return saved[p] end,Set=function(p,s) saved[p]=table.clone(s); return true end,Close=function(p) saved[p]=nil end}\nlocal function require(name) return if name=="DormPersistence" then persistence elseif name=="DormSchema" then DormSchema else Dorm end\n' + (root / 'src/server/DormService.luau').read_text() + '\nend\n'
bundle += 'local runDormFlow=(function()\n' + (root / 'tests/dorm_service_flow.luau').read_text() + '\nend)()\nrunDormFlow(loadDormService,' + dorm_geometry_luau + ')\n'
stack_parts = ["local function loadRealDormService(env)", "local deps={DormRepository=DormRepository,DormDataManager=DormManager}"]
for module_name in ['DormPersistence', 'DormService']:
    source = (root / f'src/server/{module_name}.luau').read_text()
    stack_parts.append(f"deps.{module_name}=(function()\n"
                       "local game,workspace,Vector3,CFrame,os,task=env.game,env.workspace,env.Vector3,env.CFrame,env.os,env.task\n"
                       "local script={Parent={WaitForChild=function(_,n) return n end}}\n"
                       "local function require(name) if name=='DormRules' then return Dorm end; if name=='DormSchema' then return DormSchema end; return assert(deps[name],name) end\n" + source + "\nend)()")
stack_parts.extend(["return deps.DormService", "end", 'runDormFlow(loadRealDormService,' + dorm_geometry_luau + ',true)'])
bundle += '\n' + '\n'.join(stack_parts)
bundle += '\nlocal function loadDormController(env)\n'
bundle += 'local game,workspace,Instance,Vector3,Vector2,CFrame,UDim2,Color3,typeof,os=env.game,env.workspace,env.Instance,env.Vector3,env.Vector2,env.CFrame,env.UDim2,env.Color3,env.typeof,env.os\n'
bundle += 'local function warn(message) error(message) end\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(name) return ({ControllerScope=Scope,DormPreviewModel=Preview,DormRules=Dorm})[name] end\n'
bundle += (root / 'src/client/DormController.luau').read_text() + '\nend\n'
bundle += 'local runDormController=(function()\n' + (root / 'tests/dorm_controller_flow.luau').read_text() + '\nend)()\nrunDormController(loadDormController)\n'
v2_stack=["local function loadV2DormService(env)", "local deps={DormRepositoryV2=RepositoryV2,DormDataManagerV2=ManagerV2,DormSchemaV2=DormV2,FurnitureCatalog=Catalog,FurniturePlacement=Placement}"]
for module_name in ['DormPersistenceV2','DormServiceV2']:
    v2_stack.append(f"deps.{module_name}=(function()\n"
        "local game,workspace,Vector3,CFrame,os,task=env.game,env.workspace,env.Vector3,env.CFrame,env.os,env.task\n"
        "local script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(n) return assert(deps[n],n) end\n"
        + (root / f'src/server/{module_name}.luau').read_text() + "\nend)()")
v2_stack.extend(["return deps.DormServiceV2", "end", "local runV2Flow=(function()\n"+(root/'tests/dorm_v2_service_flow.luau').read_text()+"\nend)()", 'runV2Flow(loadV2DormService,'+dorm_geometry_luau+')'])
bundle+='\n'+'\n'.join(v2_stack)
bundle+='\nlocal function loadV2DormController(env)\nlocal game,workspace,Instance,Vector3,Vector2,CFrame,UDim2,Color3,typeof,os=env.game,env.workspace,env.Instance,env.Vector3,env.Vector2,env.CFrame,env.UDim2,env.Color3,env.typeof,env.os\n'
bundle+='local function warn(m) error(m) end\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(n) return ({ControllerScope=Scope,DormPreviewModel=Preview,FurniturePlacement=Placement,FurnitureCatalog=Catalog})[n] end\n'
bundle+=(root/'src/client/DormControllerV2.luau').read_text()+'\nend\nrunDormController(loadV2DormController,true)\n'
bundle+='\nlocal LightConfigs=(function()\n'+(root/'src/server/LightPuzzleConfigs.luau').read_text()+'\nend)()\nlocal function loadLightVariant(env,key)\nlocal game,workspace,os=env.game,env.workspace,env.os\nlocal function require(_) return Light end\nlocal Factory=(function()\n'+(root/'src/server/LightPuzzleService.luau').read_text()+'\nend)()\nreturn Factory.new(LightConfigs[key])\nend\nlocal function loadLightService(env) return loadLightVariant(env,"Lesson") end\n'
bundle+='local runLightService=(function()\n'+(root/'tests/light_service_flow.luau').read_text()+'\nend)()\nrunLightService(loadLightService,'+geometry_luau+',function(env) return loadLightVariant(env,"Explore") end)\n'
client_parts=["local function loadLightClients(env)","local deps={CombatRules=(function()\n"+(root/'src/shared/CombatRules.luau').read_text()+"\nend)(),ControllerScope=Scope,LightRules=Light,LightJournalModel=LightJournal,ShieldJournalModel=ShieldJournal,JournalModel=Journal,DungeonViewModel=DungeonView,ScrollModel=Scroll,PetPolicy=Pet}"]
for module_name in ['KeyHint','LightPresentationConfigs','LightPresentation','HudController','LightLessonController','LightExploreController','ShieldLessonController','JournalController','CombatController']:
    client_parts.append(f"deps.{module_name}=(function()\n"
      "local game,workspace,Instance,Vector2,Vector3,UDim,UDim2,Color3,Enum,os=env.game,env.workspace,env.Instance,env.Vector2,env.Vector3,env.UDim,env.UDim2,env.Color3,env.Enum,env.os\n"
      "local function warn(m) error(m) end\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(n) return assert(deps[n],n) end\n"
      +(root/f'src/client/{module_name}.luau').read_text()+"\nend)()")
client_parts.extend(["return deps.HudController,deps.LightLessonController,deps.JournalController,deps.LightExploreController,deps.ShieldLessonController,deps.CombatController", "end",'local runLightClients=(function()\n'+(root/'tests/light_client_flow.luau').read_text()+'\nend)()','runLightClients(loadLightClients)'])
bundle+='\n'+'\n'.join(client_parts)
bundle+='\nlocal function loadLightExplore(env) return loadLightVariant(env,"Explore") end\n'
bundle+='local runLightExplore=(function()\n'+(root/'tests/light_explore_flow.luau').read_text()+'\nend)()\nrunLightExplore(loadLightExplore,'+geometry_luau+')\n'
bundle+='\nlocal function loadShieldService(env)\nlocal game,workspace=env.game,env.workspace\nlocal function require(_) return Shield end\nlocal Guard=(function()\n'+(root/'src/server/ShieldGuard.luau').read_text()+'\nend)()\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(n) return if n=="ShieldGuard" then Guard else Shield end\n'+(root/'src/server/ShieldLessonService.luau').read_text()+'\nend\n'
bundle+='local runShieldService=(function()\n'+(root/'tests/shield_service_flow.luau').read_text()+'\nend)()\nrunShieldService(loadShieldService,'+geometry_luau+')\n'
bundle+='\nlocal function loadGuard(env)\nlocal game,workspace=env.game,env.workspace\nlocal function require(_) return Shield end\n'+(root/'src/server/ShieldGuard.luau').read_text()+'\nend\n'
bundle+='local runGuard=(function()\n'+(root/'tests/shield_guard.luau').read_text()+'\nend)()\nrunGuard(loadGuard)\n'
combat_parts=["local function loadShieldCombat(env)","local deps={ShieldRules=Shield,EncounterRules=Encounter,DungeonRules=Dungeon}"]
for module_name in ['ShieldGuard','DungeonService','ShieldLessonService','EncounterService']:
    combat_parts.append(f"deps.{module_name}=(function()\nlocal game,workspace=env.game,env.workspace\nlocal script={{Parent={{WaitForChild=function(_,n) return n end}}}}\nlocal function require(n) return assert(deps[n],n) end\n"+(root/f'src/server/{module_name}.luau').read_text()+"\nend)()")
combat_parts.extend(["return deps.ShieldLessonService,deps.EncounterService", "end",'local runShieldCombat=(function()\n'+(root/'tests/shield_combat_flow.luau').read_text()+'\nend)()','runShieldCombat(loadShieldCombat,'+geometry_luau+')'])
bundle+='\n'+'\n'.join(combat_parts)
metadata_parts=["local function loadMetadataControllers(env)","local deps={ControllerScope=Scope,PetPolicy=Pet,EncounterRules=Encounter,VisualLifetime=Lifetime}",
    "deps.LevitationConfig=(function()\n"+(root/'src/shared/LevitationConfig.luau').read_text()+"\nend)()"]
for module_name in ['KeyHint','PetController','EncounterController','LevitationController']:
    metadata_parts.append(f"deps.{module_name}=(function()\n"
      "local game,workspace,Instance,Vector2,Vector3,UDim2,Color3,Enum,CFrame,TweenInfo,os=env.game,env.workspace,env.Instance,env.Vector2,env.Vector3,env.UDim2,env.Color3,env.Enum,env.CFrame,env.TweenInfo,env.os\n"
      "local function warn(m) error(m) end\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(n) return assert(deps[n],n) end\n"
      +(root/f'src/client/{module_name}.luau').read_text()+"\nend)()")
metadata_parts.extend(["return deps.PetController,deps.EncounterController,deps.LevitationController","end",'local runMetadata=(function()\n'+(root/'tests/placeholder_metadata_flow.luau').read_text()+'\nend)()','runMetadata(loadMetadataControllers)'])
bundle+='\n'+'\n'.join(metadata_parts)
# Real Lesson+Progress+light/shield services; loaders above must exist before this runs.
bundle += '\nlocal function loadPetService(env)\nlocal game,os=env.game,env.os\nlocal function require(_) return Pet end\n' + (root / 'src/server/PetService.luau').read_text() + '\nend\n'
bundle += '\nlocal runReward = (function()\n' + (root / 'tests/reward_persistence_flow.luau').read_text() + '\nend)()\nrunReward(loadFlowServices, newService, loadLightVariant, loadShieldService, loadPetService, ' + geometry_luau + ', Scroll)\n'
combat_attack_parts = ["local CombatRules=(function()\n"+(root/'src/shared/CombatRules.luau').read_text()+"\nend)()", "local function loadCombatAttack(env)", "local deps={CombatRules=CombatRules,EncounterRules=Encounter,DungeonRules=Dungeon,ShieldRules=Shield}"]
for name in ['ShieldGuard', 'DungeonService', 'EncounterService', 'CombatService']:
    combat_attack_parts.append("deps."+name+"=(function()\nlocal game,workspace,RaycastParams,Enum=env.game,env.workspace,env.RaycastParams,env.Enum\nlocal script={Parent={WaitForChild=function(_,n) return n end}}\nlocal function require(n) return assert(deps[n],n) end\n"+(root/f'src/server/{name}.luau').read_text()+"\nend)()")
combat_attack_parts.extend(["return deps.CombatService,deps.EncounterService", "end", "local runCombatAttack=(function()\n"+(root/'tests/combat_flow.luau').read_text()+"\nend)()", "runCombatAttack(loadCombatAttack,CombatRules,Scroll)"])
bundle += '\n'+'\n'.join(combat_attack_parts)
with tempfile.TemporaryDirectory(prefix='mythic-luau-') as folder:
    bundled = Path(folder) / 'progress_tests.luau'
    bundled.write_text(bundle)
    result = subprocess.run([str(runtime), str(bundled)], cwd=root, capture_output=True, text=True)
    print(result.stdout, end='')
    if result.returncode:
        raise SystemExit(result.stderr)
report = {
    'syntax_files': len(files),
    'syntax_passed': True,
    'runtime_tests': result.stdout.strip(),
    'runtime_scope': 'Actual progress modules with mocked Roblox services; not Studio or live DataStore',
    'source_sha256': {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
}
output = root / 'build/luau-checks.json'
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps(report, indent=2) + '\n')
