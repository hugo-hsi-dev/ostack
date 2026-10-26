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
        if 'docs/harness/codex.md)' not in text:
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
    md = (root / 'agents' / (path.stem + '.md')).read_text()
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
for path in [root / dest for dest in files if dest.endswith('.md') and not dest.startswith('docs/upstream/')] + [root / 'docs/harness/codex.md']:
    text = re.sub(r'```.*?```', '', path.read_text(), flags=re.S)
    for target in re.findall(r'\]\(([^\s)]+)\)', text):
        if target == 'url' or target.startswith(('#', 'http:', 'https:', 'mailto:')) or '<' in target:
            continue
        target = target.split('#', 1)[0]
        if target and not (path.parent / target).exists():
            errors.append(f'{path.relative_to(root)}: broken link {target}')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
print(f'ok: {skills} skills, {len(policies)} explicit-only policies, agent TOML, license, links, and legacy exclusions')
