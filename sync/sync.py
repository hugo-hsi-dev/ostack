#!/usr/bin/env python3
"""Generate ostack's pstack-origin files from upstream pstack at the pinned commit.

Each generated file is build(upstream file) plus its patch in sync/patches/<path>.patch.
See sync/README.md.
"""
import argparse, difflib, json, os, re, subprocess, sys, tempfile
from pathlib import Path
from typing import NamedTuple

URL = "https://github.com/cursor/plugins.git"
SRC = "pstack/"
ROOT = Path(__file__).resolve().parent.parent
PIN = ROOT / "sync" / "PIN"
PATCHES = ROOT / "sync" / "patches"
CACHE = Path(os.environ.get("PSTACK_CACHE", Path.home() / ".cache" / "ostack-pstack.git"))
RENAMES = {".cursor-plugin/plugin.json": "docs/upstream/cursor-plugin.json", "plugin.json": "docs/upstream/plugin.json", "docs/harness/claude-code.md": "docs/upstream/claude-code.md"}
BRAND_DIRS = {"skills/poteto-mode/": "skills/onyo-mode/", "skills/poteto-help/": "skills/onyo-help/", "skills/setup-pstack/": "skills/setup-ostack/"}
BRAND_FILES = {"agents/poteto-agent.md": "agents/onyo-agent.md", "docs/guide/02-poteto-mode.md": "docs/guide/02-onyo-mode.md"}
RESOURCE_DIRS = {"docs/guide/": "skills/onyo-help/references/guide/"}
RESOURCE_FILES = {"agents/onyo-agent.md": "skills/onyo-mode/references/onyo-agent.md",
                  "agents/comment-sicko.md": "skills/no-comments/references/comment-sicko.md"}
CODES = re.compile(r"\[(A|P|\?)\]")
HEADER = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+\d+(?:,\d+)? @@ ?(.*)$")
NO_EOL = "\\ No newline at end of file\n"


class Source(NamedTuple):
    path: str
    mode: str


class Hunk(NamedTuple):
    at: int
    n: int
    minus: list
    plus: list
    code: str


def git(*args, cwd=None, input=None, ok=(0,)):
    r = subprocess.run(["git", *args], cwd=cwd, input=input, capture_output=True)
    if r.returncode not in ok:
        sys.exit(f"git {' '.join(args)}: {r.stderr.decode().strip()}")
    return r


def fetch(sha):
    if not CACHE.exists():
        git("init", "-q", "--bare", str(CACHE))
    if git("cat-file", "-e", f"{sha}^{{commit}}", cwd=CACHE, ok=(0, 1, 128)).returncode:
        git("fetch", "-q", "--depth", "1", URL, sha, cwd=CACHE)


def map_names(s):
    for source, dest in BRAND_DIRS.items():
        if s.startswith(source):
            return dest + s[len(source):]
    s = BRAND_FILES.get(s, s)
    for source, dest in RESOURCE_DIRS.items():
        if s.startswith(source):
            return dest + s[len(source):]
    return RESOURCE_FILES.get(s, s)


def obsolete_brand_content():
    paths = [ROOT / p for p in BRAND_FILES]
    paths += [ROOT / ".codex/agents/poteto-agent.toml"]
    paths += [p for prefix in BRAND_DIRS for p in (ROOT / prefix).rglob("*")]
    return sorted(str(p.relative_to(ROOT)) for p in paths if p.is_file())


def omitted_paths():
    policy = json.loads((ROOT / "sync/omissions.json").read_text())
    if policy.get("version") != 1 or set(policy) != {"version", "reason", "paths"}:
        sys.exit("unsupported omission policy; expected version 1, reason and paths")
    paths = policy["paths"]
    if not isinstance(paths, list) or not paths or not all(isinstance(p, str) for p in paths) or len(paths) != len(set(paths)):
        sys.exit("omission paths must be a nonempty unique list")
    for path in paths:
        if not isinstance(path, str) or not re.fullmatch(r"(?:skills|automations)/[a-z0-9-]+/", path):
            sys.exit(f"invalid omission directory: {path!r}")
    return tuple(paths)


def omitted_content():
    return sorted(str(p.relative_to(ROOT)) for prefix in omitted_paths()
                  for p in (ROOT / prefix).rglob("*") if p.is_file())


def upstream(sha):
    fetch(sha)
    out = git("ls-tree", "-r", sha, SRC, cwd=CACHE).stdout.decode()
    files = {}
    omitted = omitted_paths()
    for line in out.splitlines():
        meta, path = line.split("\t", 1)
        rel = path[len(SRC):]
        if not rel.startswith(omitted):
            dest = map_names(RENAMES.get(rel, rel))
            if dest in files:
                sys.exit(f"upstream paths collide at {dest}")
            files[dest] = Source(path, meta.split()[0])
    return files


def is_binary(data):
    return b"\0" in data


def build(sha, dest, src):
    data = git("cat-file", "blob", f"{sha}:{src}", cwd=CACHE).stdout
    if is_binary(data):
        return data
    return data


def lines(text):
    return re.findall(r"[^\n]*\n|[^\n]+$", text)


def patch_path(dest):
    return PATCHES / f"{dest}.patch"


def read_patch(dest):
    p = patch_path(dest)
    if not p.exists():
        return []
    hunks = []
    for raw in lines(p.read_text())[2:]:
        h = HEADER.match(raw.rstrip("\n"))
        if h:
            code = CODES.fullmatch(h.group(3))
            if not code:
                sys.exit(f"{p}: hunk marker must be [A], [P], or [?], got {raw!r}. "
                         "[A] is a harness adaptation; [P] is approved product selection or branding.")
            start, n = int(h.group(1)), 1 if h.group(2) is None else int(h.group(2))
            hunks.append(Hunk(start - 1 if n else start, n, [], [], code.group(1)))
        elif raw == NO_EOL:
            side[-1] = side[-1][:-1]
        else:
            side = hunks[-1].minus if raw[0] == "-" else hunks[-1].plus
            side.append(raw[1:])
    return hunks


def format_patch(dest, hunks):
    rng = lambda at, k: f"{at + 1}" if k == 1 else f"{at + (k > 0)},{k}"
    out = [f"--- a/{dest}\n", f"+++ b/{dest}\n"]
    shift = 0
    for h in hunks:
        out.append(f"@@ -{rng(h.at, h.n)} +{rng(h.at + shift, len(h.plus))} @@ [{h.code}]\n")
        for sign, side in (("-", h.minus), ("+", h.plus)):
            for line in side:
                out.append(sign + line if line.endswith("\n") else sign + line + "\n" + NO_EOL)
        shift += len(h.plus) - h.n
    return "".join(out)


def apply(dest, base, hunks):
    out = lines(base)
    for h in reversed(hunks):
        if out[h.at:h.at + h.n] != h.minus:
            sys.exit(f"sync/patches/{dest}.patch: hunk at line {h.at + 1} does not match upstream")
        out[h.at:h.at + h.n] = h.plus
    return "".join(out)


def diff(base, tree):
    a, b = lines(base), lines(tree)
    ops = difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes()
    return [Hunk(i1, i2 - i1, a[i1:i2], b[j1:j2], "?") for tag, i1, i2, j1, j2 in ops if tag != "equal"]


def inherit(old, new, code):
    pool = list(old)
    out = []
    for h in new:
        match = next((o for o in pool if (o.minus, o.plus) == (h.minus, h.plus)), None)
        if match:
            pool.remove(match)
        out.append(h._replace(code=match.code if match else code))
    return out


def expected(sha, files):
    result = {}
    for dest, (src, mode) in files.items():
        data, hunks = build(sha, dest, src), read_patch(dest)
        if hunks:
            data = apply(dest, data.decode(), hunks).encode()
        result[dest] = (data, mode, hunks)
    return result


def write_file(dest, data, mode):
    p = ROOT / dest
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(data)
    p.chmod(0o755 if mode == "100755" else 0o644)


def save_patch(dest, hunks):
    p = patch_path(dest)
    if hunks:
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(format_patch(dest, hunks))
    elif p.exists():
        p.unlink()


def refresh(sha, files, dest, code="?"):
    tree = (ROOT / dest).read_text()
    if re.search(r"^(<{7}|>{7}) ", tree, re.M):
        sys.exit(f"{dest}: resolve the conflict markers first")
    src = files[dest].path
    hunks = inherit(read_patch(dest), diff(build(sha, dest, src).decode(), tree), code)
    save_patch(dest, hunks)
    return [h for h in hunks if h.code == "?"]


def orphans(files):
    dests = (str(p.relative_to(PATCHES)).removesuffix(".patch") for p in PATCHES.rglob("*.patch"))
    return sorted(d for d in dests if d not in files)


def cmd_check(sha, files, args=None):
    bad = [f"omitted content remains: {p}" for p in omitted_content()]
    bad += [f"obsolete branding content remains: {p}" for p in obsolete_brand_content()]
    for dest, (data, mode, hunks) in expected(sha, files).items():
        p = ROOT / dest
        if not p.exists():
            bad.append(f"missing: {dest}")
        elif p.read_bytes() != data:
            bad.append(f"differs from upstream + patch: {dest}")
        elif os.access(p, os.X_OK) != (mode == "100755"):
            bad.append(f"exec bit differs from upstream: {dest}")
        if any(h.code == "?" for h in hunks):
            bad.append(f"unclassified [?] hunk: sync/patches/{dest}.patch")
    bad += [f"patch for an omitted or absent upstream file: sync/patches/{o}.patch" for o in orphans(files)]
    for b in bad:
        print(b)
    if bad:
        sys.exit("check failed. After a hand edit, run `python3 sync/sync.py refresh <path>`; "
                 "to discard it, run `python3 sync/sync.py write --force`.")
    print(f"ok: {len(files)} pstack-origin files match pstack {sha[:12]} + sync/patches")


def cmd_write(sha, files, args):
    dirty = git("status", "--porcelain", "--", *files, cwd=ROOT).stdout.decode()
    if dirty and not args.force:
        sys.exit(f"uncommitted edits to generated files; refresh them or pass --force:\n{dirty}")
    for dest, (data, mode, _) in expected(sha, files).items():
        write_file(dest, data, mode)


def cmd_refresh(sha, files, args):
    for dest in args.paths or [d for d in files if (ROOT / d).exists() and not is_binary((ROOT / d).read_bytes())]:
        for h in refresh(sha, files, dest, args.code):
            print(f"sync/patches/{dest}.patch: [?] hunk at line {h.at + 1}, mark it [A] or [P]")


def cmd_bump(old, old_files, args):
    new = args.sha
    new_files = upstream(new)
    conflicts, review = [], []
    for dest in sorted(set(old_files) | set(new_files)):
        base = build(old, dest, old_files[dest].path) if dest in old_files else None
        theirs = build(new, dest, new_files[dest].path) if dest in new_files else None
        if base == theirs:
            continue
        patched = patch_path(dest).exists()
        if theirs is None:
            if patched:
                review.append(f"deleted upstream, patch kept: {dest}")
            else:
                (ROOT / dest).unlink()
            continue
        mode = new_files[dest].mode
        if base is None:
            review.append(f"new upstream file, check it for Cursor text: {dest}")
            if (ROOT / dest).exists():
                conflicts.append(f"{dest} (an ostack file already sits at this path)")
                continue
        if not patched or is_binary(theirs):
            write_file(dest, theirs, mode)
            continue
        with tempfile.TemporaryDirectory() as tmp:
            ours = ROOT / dest
            Path(tmp, "base").write_bytes(base)
            Path(tmp, "theirs").write_bytes(theirs)
            r = git("merge-file", "-L", "ostack", "-L", f"pstack@{old[:7]}", "-L", f"pstack@{new[:7]}",
                    str(ours), f"{tmp}/base", f"{tmp}/theirs", ok=range(0, 128))
        if r.returncode:
            conflicts.append(dest)
        else:
            review.append(f"merged, recheck its patch: {dest}")
            refresh(new, new_files, dest)
    PIN.write_text(new + "\n")
    for line in review:
        print(line)
    for c in conflicts:
        print(f"conflict: {c}")
    print("Resolve each conflict, run `refresh <path>`, mark every [?] hunk, then run `check`.")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("check", help="fail when a generated file differs from upstream + patch").set_defaults(fn=cmd_check)
    w = sub.add_parser("write", help="regenerate every pstack-origin file")
    w.add_argument("--force", action="store_true", help="overwrite uncommitted edits")
    w.set_defaults(fn=cmd_write)
    r = sub.add_parser("refresh", help="rewrite patches from the edited tree")
    r.add_argument("paths", nargs="*")
    r.add_argument("--code", choices=("A", "P", "?"), default="?", help="marker for new or changed hunks (default ?)")
    r.set_defaults(fn=cmd_refresh)
    b = sub.add_parser("bump", help="move the pin and merge ostack's patches onto the new upstream")
    b.add_argument("sha")
    b.set_defaults(fn=cmd_bump)
    args = ap.parse_args()
    sha = PIN.read_text().strip()
    files = upstream(sha)
    if args.fn is cmd_bump:
        cmd_check(sha, files)
    args.fn(sha, files, args)


if __name__ == "__main__":
    main()
