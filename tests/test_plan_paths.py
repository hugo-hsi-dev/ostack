"""Smoke the plan's installed paths and repository-relative trunk reads."""
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("node"), "node is required for the plan checker")
class PlanPaths(unittest.TestCase):
    def test_relocated_install_and_trunk_reads(self):
        with tempfile.TemporaryDirectory(prefix="plan paths ") as tmp:
            base = Path(tmp)
            repo = base / "arbitrary checkout"
            files = ["skills/onyo-mode/playbooks/multi-phase-plan.md",
                     "skills/onyo-mode/playbooks/autopilot-stack.md",
                     "skills/onyo-mode/playbooks/opening-a-pr.md",
                     "skills/swarm/SKILL.md", "skills/onyo-mode/scripts/check-plan.mjs"]
            for name in files:
                dest = repo / name
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(ROOT / name, dest)
            def git(*args):
                return subprocess.run(["git", *args], cwd=repo, capture_output=True, text=True, check=True)
            git("init", "-q")
            git("add", ".")
            git("-c", "user.name=Plan fixture", "-c", "user.email=fixture@example.invalid",
                "-c", "commit.gpgsign=false", "commit", "-qm", "fixture")
            git("update-ref", "refs/remotes/origin/main", "HEAD")
            project = base / "other project"
            link = project / ".agents/skills/onyo-mode"
            link.parent.mkdir(parents=True)
            link.symlink_to(repo / "skills/onyo-mode")
            installed = link.resolve()
            self.assertEqual(installed, repo / "skills/onyo-mode")
            repository = Path(git("rev-parse", "--show-toplevel").stdout.strip())
            for name in files[:4]:
                absolute = (repo / name).resolve()
                relative = absolute.relative_to(repository).as_posix()
                self.assertEqual(git("show", f"origin/main:{relative}").stdout, absolute.read_text())
            # Run the actual checker from the unrelated consuming project. An
            # invalid plan must produce structural diagnostics, not a path error.
            plan = project / "plan.md"
            plan.write_text("# Empty plan\n")
            result = subprocess.run(["node", str(installed / "scripts/check-plan.mjs"), str(plan)],
                                    cwd=project, capture_output=True, text=True)
            self.assertEqual(result.returncode, 1)
            self.assertIn('no "## How to read this" section', result.stderr)
            self.assertNotIn("MODULE_NOT_FOUND", result.stderr)
            self.assertFalse((project / "ostack").exists())


if __name__ == "__main__":
    unittest.main()
