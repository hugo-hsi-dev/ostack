"""Check instruction reads in a skills-only install, without root docs or agents."""
import re
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class SkillResources(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.skills = Path(self.temp.name) / "skills"
        shutil.copytree(ROOT / "skills", self.skills,
                        ignore=shutil.ignore_patterns("node_modules", "__pycache__"))

    def test_required_reads_have_an_existing_skill_owner(self):
        required = {
            "onyo-mode": ["references/codex.md", "references/onyo-agent.md",
                          "playbooks/investigation.md"],
            "no-comments": ["references/comment-sicko.md"],
            "onyo-help": ["references/guide/01-setup.md", "references/guide/README.md"],
            "how": ["references/explorer-prompt.md", "references/explainer-prompt.md"],
            "architect": ["references/runner-prompt.md"],
            "interrogate": ["references/reviewer-prompt.md", "references/rubric.md",
                            "references/code-quality-review.md"],
            "principle-prove-it-works": ["SKILL.md"],
        }
        for owner, resources in required.items():
            self.assertTrue((self.skills / owner / "SKILL.md").is_file())
            for resource in resources:
                with self.subTest(owner=owner, resource=resource):
                    self.assertTrue((self.skills / owner / resource).read_text().strip())

    def test_runtime_links_stay_in_readable_skill_resources(self):
        for path in self.skills.rglob("*.md"):
            text = re.sub(r"```.*?```", "", path.read_text(), flags=re.S)
            for target in re.findall(r"\]\(([^\s)]+)\)", text):
                if target == "url" or target.startswith(("#", "http:", "https:", "mailto:")) or "<" in target:
                    continue
                target = target.split("#", 1)[0]
                if not target:
                    continue
                resolved = (path.parent / target).resolve()
                with self.subTest(source=path.relative_to(self.skills), target=target):
                    self.assertTrue(resolved.is_relative_to(self.skills), str(resolved))
                    self.assertTrue(resolved.is_file(), str(resolved))
                    owner = resolved.relative_to(self.skills).parts[0]
                    self.assertTrue((self.skills / owner / "SKILL.md").is_file())

    def test_each_skill_bootstraps_the_owning_compatibility_package(self):
        entries = list(self.skills.glob("*/SKILL.md"))
        self.assertEqual(len(entries), 49)
        for path in entries:
            with self.subTest(skill=path.parent.name):
                bootstrap = path.read_text().split("before using this workflow.", 1)[1].split("\n", 1)[0]
                self.assertIn("`onyo-mode` package from this same plugin", bootstrap)
                self.assertIn("`references/codex.md` resource", bootstrap)


if __name__ == "__main__":
    unittest.main()
