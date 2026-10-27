import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class OrchestrateRecords(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.store = (ROOT / 'skills/onyo-mode/scripts/orch/store.ts').read_text()
        cls.playbook = (ROOT / 'skills/onyo-mode/playbooks/orchestrate.md').read_text()
        cls.rows = {}
        for row in cls.playbook.splitlines():
            if row.startswith('| `'):
                name, fields = row.strip('|').split('|', 1)
                cls.rows[re.search(r'`([^`]+)`', name).group(1)] = fields

    def interface_fields(self, name):
        body = re.search(r'export interface ' + name + r' \{(.*?)\n\}',
                         self.store, re.S).group(1)
        return re.findall(r'readonly (\w+):', body)

    def test_tabular_records_keep_the_original_fields_and_order(self):
        records = {'units.tsv': 'Unit', 'ledger.tsv': 'LedgerEntry',
                   'inbox/': 'InboxPointer'}
        for record, interface in records.items():
            with self.subTest(record=record):
                columns = self.rows[record].split('Table columns ', 1)[1].split('.', 1)[0]
                self.assertEqual(re.findall(r'`([^`]+)`', columns),
                                 self.interface_fields(interface))

    def test_decision_columns_match_the_original_trail(self):
        trail = (ROOT / 'skills/show-me-your-work/SKILL.md').read_text()
        header = next(line for line in trail.splitlines()
                      if line.startswith('ts\tphase\t'))
        columns = self.rows['decisions.tsv'].split('Table columns ', 1)[1].split('.', 1)[0]
        self.assertEqual(re.findall(r'`([^`]+)`', columns), header.split('\t'))

    def test_frontier_and_status_preserve_the_source_shapes(self):
        for interface, record in [('Frontier', 'frontier.json'),
                                  ('FrontierPr', 'frontier.json'),
                                  ('StatusSummary', 'status.md')]:
            with self.subTest(interface=interface):
                fields = re.findall(r'`([^`]+)`', self.rows[record])
                for field in self.interface_fields(interface):
                    self.assertIn(field, fields)

    def test_project_creation_does_not_require_an_overview_parent(self):
        for path in ['skills/onyo-mode/playbooks/orchestrate.md',
                     'skills/onyo-mode/references/codex.md',
                     'skills/onyo-help/references/guide/02-onyo-mode.md',
                     'skills/onyo-help/references/guide/07-overnight.md']:
            with self.subTest(path=path):
                text = (ROOT / path).read_text()
                self.assertRegex(text, r'top-level (?:project )?Pages?')
                self.assertNotRegex(text, r"(?:Create|create) .*overview's actual Page ID")
                self.assertNotRegex(text, r'one actual child (?:project )?Page per')
                self.assertNotIn('establish actual parent/child placement', text)
                self.assertNotIn('Hsit/dot is the planning/routing coordinator', text)


if __name__ == '__main__':
    unittest.main()
