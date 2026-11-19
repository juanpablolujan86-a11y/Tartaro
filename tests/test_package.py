import importlib.util
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("package_addon", ROOT / "tools/package_addon.py")
package = importlib.util.module_from_spec(spec)
spec.loader.exec_module(package)


class PackageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.files = package.source_files(ROOT)

    def test_source_metadata_and_resources(self):
        metadata, entries = package.validate_source(self.files)
        self.assertEqual(metadata["SavedVariables"], "TartaroDB")
        self.assertIn("Donations.lua", entries)

    def test_missing_toc_file_rejected(self):
        files = dict(self.files)
        del files["Tartaro/Core.lua"]
        with self.assertRaisesRegex(ValueError, "TOC file absent"):
            package.validate_source(files)

    def test_resource_case_mismatch_rejected(self):
        files = dict(self.files)
        files["Tartaro/crest.tga"] = files.pop("Tartaro/Crest.tga")
        with self.assertRaisesRegex(ValueError, "Missing resource"):
            package.validate_source(files)

    def test_unexpected_user_file_rejected(self):
        files = dict(self.files)
        files["Tartaro/SavedVariables.lua"] = b"user data"
        with self.assertRaisesRegex(ValueError, "Files not part"):
            package.validate_source(files)

    def test_valid_archive(self):
        with tempfile.TemporaryDirectory() as folder:
            archive = Path(folder) / "addon.zip"
            with ZipFile(archive, "w") as zip_file:
                for name, data in self.files.items():
                    zip_file.writestr(name, data)
            package.verify_zip(archive, self.files)

    def test_wrong_content_and_extra_paths_rejected(self):
        for name in ("Tartaro/Core.lua", "../private.txt", "Tartaro/Tartaro/extra.lua", "other/file.txt"):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as folder:
                archive = Path(folder) / "addon.zip"
                with ZipFile(archive, "w") as zip_file:
                    zip_file.writestr(name, b"wrong content")
                with self.assertRaises(ValueError):
                    package.verify_zip(archive, self.files)

    def test_case_duplicate_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            archive = Path(folder) / "addon.zip"
            with ZipFile(archive, "w") as zip_file:
                zip_file.writestr("Tartaro/Core.lua", b"one")
                zip_file.writestr("Tartaro/core.lua", b"two")
            with self.assertRaisesRegex(ValueError, "Duplicate ZIP path"):
                package.verify_zip(archive, self.files)


if __name__ == "__main__":
    unittest.main()
