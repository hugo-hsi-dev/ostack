"""Regression coverage for approved product omissions and retained-file fidelity."""
import importlib.util
import json
import os
import shutil
import sys
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("ostack_sync", Path(__file__).parents[1] / "sync.py")
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class ProductSelection(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "sync/patches").mkdir(parents=True)
        self.policy = self.root / "sync/omissions.json"
        self.policy.write_text(json.dumps({"version": 1, "reason": "fixture", "paths": ["skills/gone/", "automations/demo/"]}))
        self.addCleanup(patch.stopall)
        patch.object(sync, "ROOT", self.root).start()
        patch.object(sync, "PATCHES", self.root / "sync/patches").start()

    def test_directory_boundaries_and_archives_survive(self):
        paths = ["skills/gone/SKILL.md", "skills/gone/references/nested.md", "automations/demo/config.yaml", "skills/gone-extra/SKILL.md", "docs/upstream/plugin.json", "skills/keep/SKILL.md"]
        listing = "".join(f"100644 blob unused\tpstack/{p}\n" for p in paths).encode()
        with patch.object(sync, "fetch"), patch.object(sync, "git", return_value=subprocess.CompletedProcess([], 0, listing)):
            self.assertEqual(set(sync.upstream("pin")), set(paths[3:]))

    def test_brand_mapping_keeps_upstream_sources(self):
        paths = ["skills/poteto-mode/SKILL.md", "skills/poteto-help/SKILL.md", "skills/setup-pstack/SKILL.md", "agents/poteto-agent.md", "docs/guide/02-poteto-mode.md", ".cursor-plugin/plugin.json", "skills/reflect/SKILL.md"]
        policy = json.loads(self.policy.read_text())
        policy["paths"].append("skills/reflect/")
        self.policy.write_text(json.dumps(policy))
        listing = "".join(f"100644 blob unused\tpstack/{p}\n" for p in paths).encode()
        with patch.object(sync, "fetch"), patch.object(sync, "git", return_value=subprocess.CompletedProcess([], 0, listing)):
            files = sync.upstream("pin")
        expected = ["skills/onyo-mode/SKILL.md", "skills/onyo-help/SKILL.md", "skills/setup-ostack/SKILL.md", "agents/onyo-agent.md", "docs/guide/02-onyo-mode.md", "docs/upstream/cursor-plugin.json"]
        self.assertEqual(set(files), set(expected))
        for dest, source in zip(expected, paths):
            self.assertEqual(files[dest].path, "pstack/" + source)
        self.assertEqual(sync.map_names("skills/poteto-mode-extra/SKILL.md"), "skills/poteto-mode-extra/SKILL.md")

    def test_brand_collision_is_rejected(self):
        listing = b"100644 blob unused\tpstack/skills/poteto-mode/SKILL.md\n100644 blob unused\tpstack/skills/onyo-mode/SKILL.md\n"
        with patch.object(sync, "fetch"), patch.object(sync, "git", return_value=subprocess.CompletedProcess([], 0, listing)), self.assertRaises(SystemExit):
            sync.upstream("pin")

    def test_obsolete_brand_metadata_fails(self):
        p = self.root / "skills/poteto-mode/agents/openai.yaml"
        p.parent.mkdir(parents=True)
        p.write_text("stale")
        self.assertEqual(sync.obsolete_brand_content(), ["skills/poteto-mode/agents/openai.yaml"])
        with self.assertRaises(SystemExit):
            sync.cmd_check("pin", {})

    def test_invalid_policy_fails(self):
        for version, paths in [(2, ["skills/gone/"]), (1, ["../skills/gone/"]), (1, ["skills/"]), (1, ["skills/gone/", "skills/gone/"])]:
            with self.subTest(version=version, paths=paths):
                self.policy.write_text(json.dumps({"version": version, "reason": "fixture", "paths": paths}))
                with self.assertRaises(SystemExit):
                    sync.omitted_paths()

    def test_owned_metadata_cannot_remain(self):
        p = self.root / "skills/gone/agents/openai.yaml"
        p.parent.mkdir(parents=True)
        p.write_text("stale")
        self.assertEqual(sync.omitted_content(), ["skills/gone/agents/openai.yaml"])
        with self.assertRaises(SystemExit):
            sync.cmd_check("pin", {})

    def test_omitted_patch_is_orphan(self):
        p = sync.PATCHES / "skills/gone/SKILL.md.patch"
        p.parent.mkdir(parents=True)
        p.write_text("stale")
        self.assertEqual(sync.orphans({"skills/keep/SKILL.md": None}), ["skills/gone/SKILL.md"])
        with self.assertRaises(SystemExit):
            sync.cmd_check("pin", {})

    def test_product_hunks_remain_exact_and_unreviewed_fail(self):
        dest = "README.md"
        for code in ("A", "P", "?"):
            hunks = [sync.Hunk(0, 1, ["old\n"], ["selected\n"], code)]
            sync.save_patch(dest, hunks)
            self.assertEqual(sync.read_patch(dest), hunks)
            self.assertEqual(sync.apply(dest, "old\n", hunks), "selected\n")
            with self.assertRaises(SystemExit):
                sync.apply(dest, "drift\n", hunks)
            (self.root / dest).write_text("selected\n")
            with patch.object(sync, "build", return_value=b"old\n"):
                if code == "?":
                    with self.assertRaises(SystemExit):
                        sync.cmd_check("pin", {dest: sync.Source("pstack/README.md", "100644")})
                else:
                    sync.cmd_check("pin", {dest: sync.Source("pstack/README.md", "100644")})

    def test_retained_drift_fails(self):
        (self.root / "README.md").write_text("changed\n")
        with patch.object(sync, "build", return_value=b"original\n"), self.assertRaises(SystemExit):
            sync.cmd_check("pin", {"README.md": sync.Source("pstack/README.md", "100644")})

    def test_regeneration_keeps_selection(self):
        # Run the real CLI against local Git objects, not a prefiltered file map.
        source_script = Path(sync.__file__).resolve()
        policy = json.loads(source_script.with_name("omissions.json").read_text())
        self.policy.write_text(json.dumps(policy))
        upstream = self.root / "upstream"
        upstream.mkdir()

        def run(*args, cwd=self.root, env=None):
            return subprocess.run(args, cwd=cwd, env=env, capture_output=True, text=True, check=True)

        run("git", "init", "-q", cwd=upstream)
        retained = {"README.md": "retained\n", "skills/keep/SKILL.md": "keep\n",
                    "skills/reflect-extra/SKILL.md": "prefix boundary\n"}
        fixture = dict(retained)
        for prefix in policy["paths"]:
            fixture[prefix + "SKILL.md"] = "omitted skill\n"
            fixture[prefix + "agents/openai.yaml"] = "omitted metadata\n"
            fixture[prefix + "references/nested.md"] = "omitted reference\n"
        for name, text in fixture.items():
            path = upstream / "pstack" / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)
        run("git", "add", ".", cwd=upstream)
        run("git", "-c", "user.name=Sync fixture", "-c", "user.email=fixture@example.invalid",
            "-c", "commit.gpgsign=false", "commit", "-qm", "synthetic upstream", cwd=upstream)
        sha = run("git", "rev-parse", "HEAD", cwd=upstream).stdout.strip()
        (self.root / "sync/PIN").write_text(sha + "\n")
        shutil.copy2(source_script, self.root / "sync/sync.py")
        run("git", "init", "-q")
        env = dict(os.environ, PSTACK_CACHE=str(upstream))

        def cli(*args):
            return run(sys.executable, "-B", "sync/sync.py", *args, env=env)

        def assert_selected_tree():
            for name, text in retained.items():
                self.assertEqual((self.root / name).read_text(), text)
            for prefix in policy["paths"]:
                self.assertFalse((self.root / prefix).exists(), prefix)
            self.assertEqual((self.root / "sync/PIN").read_text(), sha + "\n")

        cli("write", "--force")
        assert_selected_tree()
        cli("check")
        cli("bump", sha)
        assert_selected_tree()
        # A subsequent regeneration must not bring omitted content back either.
        (self.root / "README.md").unlink()
        cli("write", "--force")
        assert_selected_tree()
        cli("check")


if __name__ == "__main__":
    unittest.main()
