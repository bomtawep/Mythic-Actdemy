"""Fixture tests for scripts/check_placeholders.py.
Usage: python3 -I tests/placeholder_scan_test.py
"""
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'scripts'))
import check_placeholders  # noqa: E402

TRACKER = '''# tracker
| ID | x |
|---|---|
| PH-ACA-001 | ลาน |
Step 06 — PH-PET-001: คู่หู

## ทะเบียนชื่อสำหรับตัวตรวจ

| ชื่อ | ID | แหล่ง | สถานะ | ผ่านภายในระยะ |
|---|---|---|---|---|
| `PH_Floor` | PH-ACA-001 | `src/world/A.model.json` | ดัมมี่ | Slice |
| `Gate` | PH-ACA-001 | `src/world/A.model.json` | พร้อมแทน | Slice |
| `PH_Companion_<UserId>` | PH-PET-001 | `src/client/Pet.luau` | ดัมมี่ | Launch |

## หลังทะเบียน
| `NotARow` | PH-ACA-001 | `src/world/A.model.json` |
'''
ROADMAP = '''| ระยะ | สัปดาห์ | เกณฑ์ |
|---|---|---|
| Proto | 1 | a |
| Slice | 2 | b |
| Launch | 3 | c |

ระยะปัจจุบันสำหรับตัวตรวจดัมมี่: `Proto` — ข้อความต่อท้าย
'''
MODEL = {'ClassName': 'Model', 'Children': [
    {'Name': 'PH_Floor', 'ClassName': 'Part'},
    {'Name': 'Gate', 'ClassName': 'Part', 'Children': [{'Name': 'Interact', 'ClassName': 'ProximityPrompt'}]},
]}
PET = '''local floor = workspace:WaitForChild("PH_Floor")
local found = workspace:FindFirstChild(`PH_{"Fl"}oor`)
model.Name = `PH_Companion_{owner.UserId}`
model:SetAttribute("IsPlaceholder", true)
model:SetAttribute("PlaceholderId", "PH-PET-001")
'''


class PlaceholderScanTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.root = Path(self.folder.name)
        self.write('docs/ASSET_TRACKER.md', TRACKER)
        self.write('docs/ROADMAP.md', ROADMAP)
        self.write('src/world/A.model.json', json.dumps(MODEL))
        self.write('src/client/Pet.luau', PET)

    def tearDown(self):
        self.folder.cleanup()

    def write(self, rel, text):
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def errors(self, stage=None):
        return check_placeholders.check(self.root, stage)['errors']

    def test_matching_fixture_passes_and_skips_lookups(self):
        report = check_placeholders.check(self.root)
        self.assertEqual(report['errors'], [])
        self.assertEqual(report['warnings'], [])
        self.assertEqual(report['stage'], 'Proto')
        self.assertEqual(report['status_counts'], {'ดัมมี่': 2, 'พร้อมแทน': 1, 'เปลี่ยนแล้วรอตรวจ': 0, 'ผ่าน': 0})
        self.assertEqual((report['scene_items'], report['generator_items'], report['registry_rows']), (2, 1, 3))

    def test_new_scene_object_and_generator_must_be_registered(self):
        model = json.loads(json.dumps(MODEL))
        model['Children'].append({'Name': 'Altar', 'ClassName': 'Part'})
        self.write('src/world/A.model.json', json.dumps(model))
        self.write('src/client/Fx.luau', 'part.Name = "PH_Spark_"..id\n')
        self.assertEqual(self.errors(), ['unregistered: src/client/Fx.luau PH_Spark_*',
                                         'unregistered: src/world/A.model.json Altar',
                                         'src/client/Fx.luau creates PH_Spark_ via part.Name but never sets part:SetAttribute("IsPlaceholder", ...)'])

    def test_registry_row_without_source_is_stale(self):
        self.write('src/client/Pet.luau', 'model:SetAttribute("PlaceholderId", "PH-PET-001")\n')
        self.assertEqual(self.errors(), ['stale registry row (not in source): src/client/Pet.luau PH_Companion_*'])

    def test_moved_generator_is_both_unregistered_and_stale(self):
        (self.root / 'src/client/Pet.luau').rename(self.root / 'src/client/Companion.luau')
        errors = self.errors()
        self.assertIn('unregistered: src/client/Companion.luau PH_Companion_*', errors)
        self.assertIn('stale registry row (not in source): src/client/Pet.luau PH_Companion_*', errors)

    def test_ids_must_be_defined_outside_registry_and_match_attributes(self):
        self.write('docs/ASSET_TRACKER.md', TRACKER.replace('| `Gate` | PH-ACA-001', '| `Gate` | PH-ZZZ-999'))
        self.write('src/client/Pet.luau', PET.replace('"PH-PET-001"', '"PH-ACA-001"'))
        self.assertEqual(self.errors(), [
            'unknown id PH-ZZZ-999 for src/world/A.model.json Gate: not defined outside registry',
            "src/client/Pet.luau sets PlaceholderId PH-ACA-001 but its registry rows only list ['PH-PET-001']",
        ])

    def test_model_attribute_id_is_checked(self):
        model = json.loads(json.dumps(MODEL))
        model['Attributes'] = {'IsPlaceholder': True, 'PlaceholderId': 'PH-PET-001'}
        self.write('src/world/A.model.json', json.dumps(model))
        self.assertEqual(self.errors(), [
            "src/world/A.model.json sets PlaceholderId PH-PET-001 but its registry rows only list ['PH-ACA-001']"])

    def test_missing_section_duplicates_and_empty_ids_fail(self):
        self.write('docs/ASSET_TRACKER.md', '# empty\n')
        self.assertIn('missing section "## ทะเบียนชื่อสำหรับตัวตรวจ"', self.errors())
        duplicate = TRACKER.replace('| `Gate` | PH-ACA-001 | `src/world/A.model.json` | พร้อมแทน | Slice |',
                                    '| `Gate` | PH-ACA-001 | `src/world/A.model.json` | พร้อมแทน | Slice |\n'
                                    '| `Gate` | - | `src/world/A.model.json` | ดัมมี่ | Slice |')
        self.write('docs/ASSET_TRACKER.md', duplicate)
        errors = self.errors()
        self.assertTrue(any('Gate has no PH id' in e for e in errors), errors)
        self.assertTrue(any('duplicate row src/world/A.model.json Gate' in e for e in errors), errors)

    def test_placeholder_flag_needs_id_and_unflagged_generators_warn(self):
        self.write('src/client/Pet.luau', PET.replace('model:SetAttribute("PlaceholderId", "PH-PET-001")',
                                                      'model:SetAttribute("IsPlaceholder", true)'))
        report = check_placeholders.check(self.root)
        self.assertEqual(report['errors'], ['src/client/Pet.luau sets IsPlaceholder but no PlaceholderId'])
        self.assertEqual(report['warnings'], [])
        self.write('src/client/Pet.luau', 'model.Name = `PH_Companion_{owner.UserId}`\n')
        report = check_placeholders.check(self.root)
        self.assertEqual(report['errors'], [
            'src/client/Pet.luau creates PH_Companion_* via model.Name but never sets model:SetAttribute("IsPlaceholder", ...)'])
        self.assertEqual(report['warnings'], ['src/client/Pet.luau names PH_ objects but sets no IsPlaceholder/PlaceholderId attribute'])

    def test_each_named_ph_object_needs_its_own_flag(self):
        self.write('src/client/Pet.luau', PET + 'button.Name = "PH_PetToggle"\nmodel:SetAttribute("IsPlaceholder", true)\n')
        self.write('docs/ASSET_TRACKER.md', TRACKER.replace(
            '| `PH_Companion_<UserId>` |', '| `PH_PetToggle` | PH-PET-001 | `src/client/Pet.luau` | ดัมมี่ | Launch |\n| `PH_Companion_<UserId>` |'))
        self.assertEqual(self.errors(), [
            'src/client/Pet.luau creates PH_PetToggle via button.Name but never sets button:SetAttribute("IsPlaceholder", ...)'])
        self.write('src/client/Pet.luau', PET + 'button.Name = "PH_PetToggle"\nbutton:SetAttribute("IsPlaceholder", true)\n')
        self.assertEqual(self.errors(), [])

    def test_deadline_warns_in_its_stage_and_fails_after(self):
        during = check_placeholders.check(self.root, 'Slice')
        self.assertEqual(during['errors'], [])
        self.assertEqual(during['warnings'], ['due this stage (Slice): PH-ACA-001 has 2 rows not ผ่าน: Gate, PH_Floor'])
        self.assertEqual(self.errors('Launch'), [
            'overdue: PH-ACA-001 should have passed by Slice but 2 rows are not ผ่าน: Gate, PH_Floor'])
        self.write('docs/ROADMAP.md', ROADMAP.replace('`Proto`', '`Launch`'))
        self.assertEqual(len(self.errors()), 1)

    def test_passed_rows_clear_deadline_but_must_not_keep_ph_name(self):
        self.write('docs/ASSET_TRACKER.md', TRACKER.replace('พร้อมแทน | Slice', 'ผ่าน | Slice')
                   .replace('| `PH_Floor` | PH-ACA-001 | `src/world/A.model.json` | ดัมมี่', '| `PH_Floor` | PH-ACA-001 | `src/world/A.model.json` | ผ่าน'))
        report = check_placeholders.check(self.root, 'Launch')
        self.assertEqual(report['errors'], ['src/world/A.model.json PH_Floor: marked ผ่าน but the PH_ name is still in source'])
        self.assertEqual(report['warnings'], ['due this stage (Launch): PH-PET-001 has 1 rows not ผ่าน: PH_Companion_*'])

    def test_bad_status_stage_and_columns_fail(self):
        self.write('docs/ASSET_TRACKER.md', TRACKER.replace('พร้อมแทน | Slice', 'เสร็จ | Beta')
                   .replace('| `PH_Floor` | PH-ACA-001 | `src/world/A.model.json` | ดัมมี่ | Slice |',
                            '| `PH_Floor` | PH-ACA-001 | `src/world/A.model.json` |'))
        errors = self.errors()
        self.assertTrue(any('expected 5 columns' in e for e in errors), errors)
        self.assertTrue(any('Gate status "เสร็จ"' in e for e in errors), errors)
        self.assertIn("src/world/A.model.json Gate: deadline stage 'Beta' is not in ROADMAP stages", errors)
        self.assertIn("current stage 'Nope' is not in ROADMAP stages ['Proto', 'Slice', 'Launch']", self.errors('Nope'))
        self.write('docs/ROADMAP.md', ROADMAP.replace('ระยะปัจจุบัน', 'ระยะ'))
        self.assertTrue(any('current stage None' in e for e in self.errors()), self.errors())


if __name__ == '__main__':
    unittest.main(verbosity=2)
