import importlib.util
import sys
import types
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).parents[1] / "scripts" / "import_datasus_oncology.py"
dbc_reader_stub = types.ModuleType("dbc_reader")
dbc_reader_stub.DbcReader = object
sys.modules.setdefault("dbc_reader", dbc_reader_stub)
SPEC = importlib.util.spec_from_file_location("datasus_importer", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(MODULE)


class DatasusFilenameTest(unittest.TestCase):
    def test_accepts_regular_file(self):
        match = MODULE.FILE_RE.match("PAMG2401.dbc")
        self.assertIsNotNone(match)
        self.assertIsNone(match.group("part"))

    def test_accepts_split_sia_file(self):
        match = MODULE.FILE_RE.match("PASP2401a.dbc")
        self.assertIsNotNone(match)
        self.assertEqual(match.group("uf"), "SP")
        self.assertEqual(match.group("part"), "a")

    def test_rejects_non_production_file(self):
        self.assertIsNone(MODULE.FILE_RE.match("BOSP2401.dbc"))


if __name__ == "__main__":
    unittest.main()
