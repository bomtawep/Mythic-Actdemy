"""Compare placeholder names in scene JSON and Luau generators with docs/ASSET_TRACKER.md,
and check each row's replacement deadline against the current stage in docs/ROADMAP.md.
Usage: python3 scripts/check_placeholders.py [--root PATH] [--stage NAME]
Source scan only: it does not open Studio, inspect visuals, or prove a placeholder was replaced.
"""
import argparse
from fnmatch import fnmatchcase
import json
from pathlib import Path
import re

REGISTRY_HEADING = '## ทะเบียนชื่อสำหรับตัวตรวจ'
ID_PATTERN = re.compile(r'PH-[A-Z]{2,4}-\d{3}')
# Proximity prompts and remotes are behaviour hooks, not visible stand-ins.
IGNORED_CLASSES = {'ProximityPrompt', 'RemoteEvent', 'RemoteFunction'}
LUAU_NAME = re.compile(r'"(PH_[A-Za-z0-9_]*)"(\s*\.\.)?|`(PH_[^`]*)`')
LUAU_ID = re.compile(r'"(' + ID_PATTERN.pattern + r')"')
LUAU_FLAG = re.compile(r'SetAttribute\(\s*"IsPlaceholder"\s*,\s*true\s*\)')
LUAU_ID_CALL = re.compile(r'SetAttribute\(\s*"PlaceholderId"\s*,')
LUAU_NAME_ASSIGN = re.compile(r'\b(\w+)\.Name\s*=\s*(?:"(PH_[A-Za-z0-9_]*)"|`(PH_[^`]*)`)')
# Status flow from ASSET_TRACKER: ดัมมี่ → พร้อมแทน → เปลี่ยนแล้วรอตรวจ → ผ่าน
STATUSES = ('ดัมมี่', 'พร้อมแทน', 'เปลี่ยนแล้วรอตรวจ', 'ผ่าน')
PASSED = 'ผ่าน'
STAGE_MARKER = 'ระยะปัจจุบันสำหรับตัวตรวจดัมมี่:'


def normalize(name):
    """Dynamic suffixes (`{id}`, `..id`, `<UserId>`) all compare as `*`."""
    return re.sub(r'\{[^}]*\}|<[^>]*>', '*', name)


def scan_models(root):
    """Every non-root instance in *.model.json is a stand-in until registered."""
    found, ids = set(), {}
    for path in sorted((root / 'src').rglob('*.model.json')):
        rel = path.relative_to(root).as_posix()

        def walk(node, is_root):
            attributes = node.get('Attributes') or {}
            if isinstance(attributes.get('PlaceholderId'), str):
                ids.setdefault(rel, set()).add(attributes['PlaceholderId'])
            if not is_root and node.get('ClassName') not in IGNORED_CLASSES:
                found.add((rel, normalize(node['Name'])))
            for child in node.get('Children', []):
                walk(child, False)

        walk(json.loads(path.read_text()), True)
    return found, ids


def scan_generators(root, scene_names):
    """PH_ literals in Luau that match no scene object (lookups like `PH_{name}Crystal`) are runtime generators."""
    found, ids, flagged, tagged, untagged = set(), {}, set(), set(), []
    for path in sorted((root / 'src').rglob('*.luau')):
        rel = path.relative_to(root).as_posix()
        text = path.read_text()
        for match in LUAU_NAME.finditer(text):
            if match.group(1) is not None:
                name = match.group(1) + ('*' if match.group(2) else '')
            else:
                name = normalize(match.group(3))
            if not any(fnmatchcase(scene, name) for scene in scene_names):
                found.add((rel, name))
        for match in LUAU_ID.finditer(text):
            ids.setdefault(rel, set()).add(match.group(1))
        if LUAU_FLAG.search(text):
            flagged.add(rel)
        if LUAU_ID_CALL.search(text):
            tagged.add(rel)
        # A literal `x.Name = "PH_..."` must be paired with `x:SetAttribute("IsPlaceholder", ...)` in the same file.
        for match in LUAU_NAME_ASSIGN.finditer(text):
            if not re.search(r'\b' + re.escape(match.group(1)) + r':SetAttribute\(\s*"IsPlaceholder"', text):
                untagged.append((rel, match.group(1), normalize(match.group(2) or match.group(3))))
    return found, ids, flagged, tagged, untagged


def parse_tracker(text):
    """Return (registry rows, IDs defined elsewhere in the tracker, row errors)."""
    lines = text.splitlines()
    errors, registry = [], {}
    try:
        start = lines.index(REGISTRY_HEADING)
    except ValueError:
        return {}, set(ID_PATTERN.findall(text)), [f'missing section "{REGISTRY_HEADING}"']
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith('## ')), len(lines))
    outside = '\n'.join(lines[:start] + lines[end:])
    for number, line in enumerate(lines[start + 1:end], start + 2):
        cells = [cell.strip().strip('`') for cell in line.strip().strip('|').split('|')]
        if not line.startswith('|') or cells[0] in ('ชื่อ', '') or set(cells[0]) <= {'-'}:
            continue
        if len(cells) != 5:
            errors.append(f'tracker line {number}: expected 5 columns (ชื่อ|ID|แหล่ง|สถานะ|ผ่านภายในระยะ), got {len(cells)}')
            continue
        name, id_cell, source, status, due = cells
        key = (source, normalize(name))
        row_ids = set(ID_PATTERN.findall(id_cell))
        if not row_ids:
            errors.append(f'tracker line {number}: {name} has no PH id')
        if status not in STATUSES:
            errors.append(f'tracker line {number}: {name} status "{status}" is not one of {" / ".join(STATUSES)}')
        if key in registry:
            errors.append(f'tracker line {number}: duplicate row {source} {name}')
        registry[key] = {'ids': row_ids, 'status': status, 'due': due}
    return registry, set(ID_PATTERN.findall(outside)), errors


def parse_stages(text):
    """Stage order comes from the ROADMAP stage table; the current stage from its marker line."""
    lines = text.splitlines()
    header = next((i for i, line in enumerate(lines) if line.startswith('| ระยะ |')), None)
    stages = []
    if header is not None:
        for line in lines[header + 2:]:
            if not line.startswith('|'):
                break
            stages.append(line.strip('|').split('|')[0].strip())
    marker = re.search(STAGE_MARKER + r'\s*`([^`]+)`', text)
    return stages, marker.group(1) if marker else None


def check_deadlines(registry, stages, current):
    """Unpassed rows warn during their deadline stage and fail once the project is past it."""
    errors, warnings = [], []
    if not stages:
        return ['ROADMAP has no "| ระยะ |" stage table'], warnings
    if current not in stages:
        return [f'current stage {current!r} is not in ROADMAP stages {stages}'], warnings
    now = stages.index(current)
    due_now, overdue = {}, {}
    for (source, name), row in sorted(registry.items()):
        if row['due'] not in stages:
            errors.append(f'{source} {name}: deadline stage {row["due"]!r} is not in ROADMAP stages')
            continue
        if row['status'] == PASSED:
            if name.startswith('PH_'):
                errors.append(f'{source} {name}: marked {PASSED} but the PH_ name is still in source')
            continue
        bucket = overdue if now > stages.index(row['due']) else due_now if now == stages.index(row['due']) else None
        if bucket is not None:
            for row_id in sorted(row['ids']):
                bucket.setdefault((row_id, row['due']), []).append(name)
    for (row_id, due), names in sorted(overdue.items()):
        errors.append(f'overdue: {row_id} should have passed by {due} but {len(names)} rows are not {PASSED}: {", ".join(names)}')
    for (row_id, due), names in sorted(due_now.items()):
        warnings.append(f'due this stage ({due}): {row_id} has {len(names)} rows not {PASSED}: {", ".join(names)}')
    return errors, warnings


def check(root, stage=None):
    tracker = (root / 'docs/ASSET_TRACKER.md').read_text()
    registry, known_ids, errors = parse_tracker(tracker)
    stages, current = parse_stages((root / 'docs/ROADMAP.md').read_text())
    current = stage or current
    scene, scene_ids = scan_models(root)
    generated, generated_ids, flagged, tagged, untagged = scan_generators(root, {name for _, name in scene})
    found = scene | generated
    for source, name in sorted(found - registry.keys()):
        errors.append(f'unregistered: {source} {name}')
    for source, name in sorted(registry.keys() - found):
        errors.append(f'stale registry row (not in source): {source} {name}')
    for (source, name), row in sorted(registry.items()):
        for unknown in sorted(row['ids'] - known_ids):
            errors.append(f'unknown id {unknown} for {source} {name}: not defined outside registry')
    for source, ids in sorted({**scene_ids, **generated_ids}.items()):
        expected = set().union(*(row['ids'] for (row_source, _), row in registry.items() if row_source == source))
        for wrong in sorted(ids - expected):
            errors.append(f'{source} sets PlaceholderId {wrong} but its registry rows only list {sorted(expected) or "nothing"}')
    for source, variable, name in untagged:
        errors.append(f'{source} creates {name} via {variable}.Name but never sets {variable}:SetAttribute("IsPlaceholder", ...)')
    for source in sorted(flagged - tagged):
        errors.append(f'{source} sets IsPlaceholder but no PlaceholderId')
    deadline_errors, warnings = check_deadlines(registry, stages, current)
    errors += deadline_errors
    for source in sorted({source for source, _ in generated} - flagged - generated_ids.keys()):
        warnings.append(f'{source} names PH_ objects but sets no IsPlaceholder/PlaceholderId attribute')
    return {
        'scene_items': len(scene),
        'generator_items': len(generated),
        'registry_rows': len(registry),
        'ids': sorted(set().union(*(row['ids'] for row in registry.values()))),
        'stage': current,
        'status_counts': {status: sum(row['status'] == status for row in registry.values()) for status in STATUSES},
        'errors': errors,
        'warnings': warnings,
        'scope': 'Source scan of src/*.model.json and PH_ Luau literals; not a Studio scan, visual check, or replacement proof',
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument('--stage', help='check deadlines as if the project were in this ROADMAP stage')
    args = parser.parse_args()
    report = check(args.root, args.stage)
    output = args.root / 'build/placeholder-scan.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n')
    for warning in report['warnings']:
        print('WARN:', warning)
    for error in report['errors']:
        print('FAIL:', error)
    if report['errors']:
        raise SystemExit(f'{len(report["errors"])} placeholder registry problems')
    counts = ', '.join(f'{status} {count}' for status, count in report['status_counts'].items())
    print(f'PASS: {report["scene_items"]} scene + {report["generator_items"]} generator placeholders '
          f'match {report["registry_rows"]} registry rows ({len(report["ids"])} ids); stage {report["stage"]}: {counts}')


if __name__ == '__main__':
    main()
