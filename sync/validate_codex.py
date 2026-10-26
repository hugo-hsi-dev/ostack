#!/usr/bin/env python3
"""Validate only the Codex port's derived metadata and harness boundaries."""
import re
import sys
import tomllib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sync

root = sync.ROOT
sha = sync.PIN.read_text().strip()
files = sync.upstream(sha)
errors = [f"omitted content remains: {p}" for p in sync.omitted_content()]
errors += [f"obsolete branding content remains: {p}" for p in sync.obsolete_brand_content()]


def setup_defaults(text):
    block = next(block for block in re.findall(r'```[^\n]*\n(.*?)```', text, re.S)
                 if 'feature, refactoring:' in block)
    return {role: entries.split(', ') for role, entries in
            re.findall(r'^([a-z][a-z ,/-]*): (.+)$', block, re.M)
            if role not in {'description', 'alwaysApply'}}


setup_path = 'skills/setup-ostack/SKILL.md'
upstream_defaults = setup_defaults(sync.build(sha, setup_path, files[setup_path].path).decode())
model_map = {'claude-opus-5-5-xhigh': 'gpt-6.1-sol',
             'grok-4.7-xhigh-fast': 'gpt-6.1-terra'}
expected_defaults = {}
for role, entries in upstream_defaults.items():
    if role.startswith('reflect ') and 'skills/reflect/' in sync.omitted_paths():
        continue
    if any(entry not in model_map for entry in entries):
        errors.append(f'{setup_path}: review new upstream defaults for {role}')
        continue
    expected_defaults[role] = [f'{model_map[entry]} <budget-effort>' for entry in entries]
if setup_defaults((root / setup_path).read_text()) != expected_defaults:
    errors.append(f'{setup_path}: defaults must preserve upstream roles and panel counts, '
                  'map Opus to Sol and Grok to Terra, and leave effort to the budget')

policies = set()
skills = 0
for dest, source in files.items():
    if not dest.endswith('/SKILL.md'):
        continue
    skills += 1
    text = (root / dest).read_text()
    front = re.match(r'---\n(.*?)\n---\n', text, re.S)
    if not front or not all(re.search(rf'^{key}: .+', front[1], re.M) for key in ('name', 'description')):
        errors.append(f'{dest}: missing skill frontmatter')
    if dest.startswith('skills/'):
        if front and not re.search(rf'^name: {re.escape(Path(dest).parent.name)}$', front[1], re.M):
            errors.append(f'{dest}: skill name differs from directory')
        if 'references/codex.md)' not in text or 'In a cloud skill reader' not in text:
            errors.append(f'{dest}: missing compatibility entry point')
        if front and re.search(r'^(disable-model-invocation|icon|color):', front[1], re.M):
            errors.append(f'{dest}: unported Cursor metadata')
        original = sync.build(sha, dest, source.path).decode()
        if 'disable-model-invocation: true\n' in original.split('---', 2)[1]:
            policy = root / dest.replace('SKILL.md', 'agents/openai.yaml')
            policies.add(policy)
            if not policy.exists() or policy.read_text() != 'policy:\n  allow_implicit_invocation: false\n':
                errors.append(f'{dest}: explicit-only invocation policy lost')
for path in (root / 'skills').rglob('agents/openai.yaml'):
    if path not in policies:
        errors.append(f'{path.relative_to(root)}: unexpected invocation override')
for path in (root / '.codex/agents').glob('*.toml'):
    data = tomllib.loads(path.read_text())
    if data.get('name') != path.stem:
        errors.append(f'{path}: agent name differs from filename')
    owner = 'onyo-mode' if path.stem == 'onyo-agent' else 'no-comments'
    md = (root / 'skills' / owner / 'references' / (path.stem + '.md')).read_text()
    body = md.split('---', 2)[2].strip()
    if set(data) != {'name', 'description', 'developer_instructions'} or data['developer_instructions'].strip() != body:
        errors.append(f'{path}: role differs from its Markdown source')
if (root / 'LICENSE').read_bytes() != sync.build(sha, 'LICENSE', files['LICENSE'].path):
    errors.append('LICENSE differs from upstream')
for folder in ('hooks', 'skills/onyo-projects', '.claude-plugin', '.cursor-plugin'):
    path = root / folder
    if path.exists() and any(p.is_file() for p in path.rglob('*')):
        errors.append(f'{folder}: legacy fork content remains')
# Resolve actual relative Markdown links, leaving fenced examples and archive intact.
for path in [root / dest for dest in files if dest.endswith('.md') and not dest.startswith('docs/upstream/')] + [root / 'skills/onyo-mode/references/codex.md', root / 'docs/harness/codex.md']:
    text = re.sub(r'```.*?```', '', path.read_text(), flags=re.S)
    if re.search(r'\bmissing roles inherit (?:the )?parent\b|'
                 r'\broles inherit the parent model (?:unless|until)\b', text, re.I):
        errors.append(f'{path.relative_to(root)}: stale inheritance default; '
                      'missing roles use the selected Sol/Terra mapping, while saved aliases remain overrides')
    if re.search(r'\btargeting xhigh by default\b|'
                 r'\bwithout a recorded budget, `large` supplies\b|'
                 r'\blarge (?:budget[’\']s starting effort|starting budget)\b|'
                 r'\bWith no configuration, offer `large`', text, re.I):
        errors.append(f'{path.relative_to(root)}: stale starting budget; '
                      'without a saved choice, start at medium/high and retain explicit budget overrides')
    for target in re.findall(r'\]\(([^\s)]+)\)', text):
        if target == 'url' or target.startswith(('#', 'http:', 'https:', 'mailto:')) or '<' in target:
            continue
        target = target.split('#', 1)[0]
        if target and not (path.parent / target).exists():
            errors.append(f'{path.relative_to(root)}: broken link {target}')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
print(f'ok: {skills} skills, {len(policies)} explicit-only policies, upstream model-role mapping, '
      'agent TOML, license, links, and legacy exclusions')
