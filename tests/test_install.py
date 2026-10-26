import importlib.util
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("installer", Path(__file__).parents[1] / "scripts/install-skills.py")
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class InstallLinks(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.checkout = self.root / "checkout with spaces"
        self.skills = self.root / "project/.agents/skills"
        self.agents = self.root / "project/.codex/agents"
        self.names = ["architect", *installer.RENAMED.values()]
        for name in self.names:
            p = self.checkout / "skills" / name / "SKILL.md"
            p.parent.mkdir(parents=True)
            p.write_text(name)
        p = self.checkout / ".codex/agents/onyo-agent.toml"
        p.parent.mkdir(parents=True)
        p.write_text('name = "onyo-agent"')

    def run_install(self):
        installer.install(self.checkout, self.skills, self.agents)
        for name in self.names:
            self.assertTrue(installer.points_to(self.skills / name, self.checkout / "skills" / name))

    def test_fresh_and_rerun(self):
        self.run_install()
        self.run_install()

    def test_old_broken_links_upgrade(self):
        self.skills.mkdir(parents=True)
        for name in installer.RENAMED:
            (self.skills / name).symlink_to(self.checkout / "skills" / name)
        self.agents.mkdir(parents=True)
        (self.agents / "poteto-agent.toml").symlink_to(self.checkout / ".codex/agents/poteto-agent.toml")
        self.run_install()
        for name in installer.RENAMED:
            self.assertFalse((self.skills / name).is_symlink())
        self.assertFalse((self.agents / "poteto-agent.toml").is_symlink())
        self.assertTrue((self.agents / "onyo-agent.toml").is_symlink())

    def test_partial_install(self):
        self.skills.mkdir(parents=True)
        (self.skills / "architect").symlink_to(self.checkout / "skills/architect")
        self.run_install()

    def test_custom_file_preflight_preserves_everything(self):
        self.skills.mkdir(parents=True)
        p = self.skills / "onyo-help"
        p.write_text("custom")
        with self.assertRaises(ValueError):
            self.run_install()
        self.assertEqual(p.read_text(), "custom")
        self.assertFalse((self.skills / "architect").exists())

    def test_custom_legacy_link_preserved(self):
        self.skills.mkdir(parents=True)
        p = self.skills / "poteto-mode"
        p.symlink_to(self.root / "custom missing skill")
        with self.assertRaises(ValueError):
            self.run_install()
        self.assertTrue(p.is_symlink())
        self.assertEqual(p.readlink(), self.root / "custom missing skill")
        self.assertFalse((self.skills / "architect").exists())

    def test_copied_or_custom_agent_preserved(self):
        self.agents.mkdir(parents=True)
        p = self.agents / "poteto-agent.toml"
        p.write_text("user-owned definition")
        with self.assertRaises(ValueError):
            self.run_install()
        self.assertEqual(p.read_text(), "user-owned definition")
        self.assertFalse(self.skills.exists())


if __name__ == "__main__":
    unittest.main()
