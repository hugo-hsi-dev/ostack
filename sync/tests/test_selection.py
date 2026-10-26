"""Regression coverage for approved product omissions and retained-file fidelity."""
import importlib.util
import json
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
        files = {"README.md": sync.Source("pstack/README.md", "100644")}
        with patch.object(sync, "git", return_value=subprocess.CompletedProcess([], 0, b"")), patch.object(sync, "build", return_value=b"retained\n"):
            sync.cmd_write("pin", files, type("Args", (), {"force": True})())
        self.assertEqual((self.root / "README.md").read_bytes(), b"retained\n")
        self.assertFalse((self.root / "skills/gone").exists())
        self.assertFalse((self.root / "automations/demo").exists())


if __name__ == "__main__":
    unittest.main()
