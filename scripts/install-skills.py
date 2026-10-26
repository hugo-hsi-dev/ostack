#!/usr/bin/env python3
"""Install checkout links without replacing custom files or links."""
import argparse
import os
from pathlib import Path

RENAMED = {"poteto-mode": "onyo-mode", "poteto-help": "onyo-help", "setup-pstack": "setup-ostack"}


def points_to(link, target):
    return link.is_symlink() and (link.parent / os.readlink(link)).resolve() == target.resolve()


def install(checkout, skills_dir, agents_dir=None):
    checkout = checkout.resolve()
    links = [(skills_dir / p.name, p) for p in sorted((checkout / "skills").iterdir())
             if (p / "SKILL.md").is_file()]
    if not links:
        raise ValueError(f"No skills found in {checkout}")
    old = [(skills_dir / name, checkout / "skills" / name) for name in RENAMED]
    if agents_dir is not None:
        links += [(agents_dir / p.name, p) for p in sorted((checkout / ".codex/agents").glob("*.toml"))]
        old.append((agents_dir / "poteto-agent.toml", checkout / ".codex/agents/poteto-agent.toml"))
    conflicts = [str(dest) for dest, source in links + old
                 if (dest.exists() or dest.is_symlink()) and not points_to(dest, source)]
    if conflicts:
        raise ValueError("Custom or unmanaged destinations preserved; resolve these conflicts before retrying:\n" + "\n".join(conflicts))
    # Preflight every destination before changing any link. Never remove regular files.
    for dest, source in links:
        if not dest.is_symlink():
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.symlink_to(source)
    for dest, source in old:
        if points_to(dest, source):
            dest.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--checkout", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--skills-dir", type=Path, required=True)
    parser.add_argument("--agents-dir", type=Path)
    args = parser.parse_args()
    try:
        install(args.checkout, args.skills_dir, args.agents_dir)
    except (ValueError, OSError) as error:
        parser.exit(1, f"{error}\n")
    print("Checkout links installed; existing managed links retained and renamed managed links retired.")


if __name__ == "__main__":
    main()
