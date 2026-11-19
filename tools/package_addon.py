"""Build/verify the installable ZIP locally. Never uploads or publishes anything."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import subprocess
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN = {".git", ".github", ".codex", "tests", "tools", "wtf", "savedvariables", "__pycache__"}
EXTENSIONS = {".lua", ".xml", ".toc", ".mp3", ".tga", ".md", ".txt"}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def source_files(root):
    folder = root / "Tartaro"
    require(folder.is_dir() and not folder.is_symlink(), "Missing regular Tartaro folder")
    result = {}
    for path in sorted(folder.rglob("*")):
        require(not path.is_symlink(), f"Symbolic link excluded: {path}")
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix()
        require(not any(p.lower() in FORBIDDEN for p in Path(relative).parts), f"Private path excluded: {relative}")
        require(path.suffix.lower() in EXTENSIONS, f"Unexpected file type: {relative}")
        require(not path.name.startswith("."), f"Hidden file excluded: {relative}")
        result[relative] = path.read_bytes()
    require(len({name.casefold() for name in result}) == len(result), "Case-colliding source filenames")
    return result


def validate_source(files):
    require("Tartaro/Tartaro.toc" in files, "Missing Tartaro/Tartaro.toc")
    toc = files["Tartaro/Tartaro.toc"].decode("utf-8-sig")
    metadata, entries = {}, []
    for line in toc.splitlines():
        line = line.strip()
        if line.startswith("##") and ":" in line:
            key, value = line[2:].split(":", 1)
            metadata[key.strip()] = value.strip()
        elif line and not line.startswith("#"):
            entry = line.replace("\\", "/")
            require(not PurePosixPath(entry).is_absolute() and ".." not in PurePosixPath(entry).parts,
                    f"Unsafe TOC entry: {entry}")
            require("Tartaro/" + entry in files, f"TOC file absent or case mismatch: {entry}")
            entries.append(entry)
    require(entries and len(set(entries)) == len(entries), "Empty or duplicate TOC entries")
    require(re.fullmatch(r"\d{1,3}\.\d{1,3}\.\d{1,3}", metadata.get("Version", "")), "Invalid numeric version")
    require(metadata.get("SavedVariables") == "TartaroDB", "SavedVariables differs from TartaroDB")
    require(metadata.get("AllowLoadGameType") == "camelot", "Unexpected client flavor")
    require(re.fullmatch(r"\d+", metadata.get("Interface", "")), "Missing Interface metadata")
    allowed = {"Tartaro/Tartaro.toc", "Tartaro/LEEME.md", "Tartaro/CREDITS.md",
               "Tartaro/LICENSE.txt", "Tartaro/CHANGELOG.md"}
    allowed.update("Tartaro/" + name for name in entries)
    for name, data in files.items():
        if not name.endswith((".lua", ".xml")):
            continue
        text = data.decode("utf-8-sig").replace("\\\\", "\\")
        for asset in re.findall(r"Interface\\AddOns\\Tartaro\\([A-Za-z][A-Za-z0-9_.-]*)", text):
            matches = {"Tartaro/" + asset + suffix for suffix in ("", ".tga", ".mp3")
                       if "Tartaro/" + asset + suffix in files}
            require(matches, f"Missing resource referenced in {name}: {asset}")
            allowed.update(matches)
    # Sound paths are composed at runtime rather than literal resource paths.
    for base in ("CallToArms", "CallNature"):
        for suffix in ("", "20", "40", "60", "80"):
            require(f"Tartaro/{base}{suffix}.mp3" in files, f"Missing sound variant: {base}{suffix}")
            allowed.add(f"Tartaro/{base}{suffix}.mp3")
    require(not set(files) - allowed, f"Files not part of the addon: {sorted(set(files) - allowed)}")
    return metadata, entries


def verify_zip(archive, expected):
    with ZipFile(archive) as package:
        require(package.testzip() is None, "ZIP CRC check failed")
        names, actual = set(), {}
        for info in package.infolist():
            require(not stat.S_ISLNK(info.external_attr >> 16), f"ZIP symbolic link excluded: {info.filename}")
            name = info.filename
            parts = PurePosixPath(name).parts
            require("\\" not in name and parts and parts[0] == "Tartaro" and ".." not in parts,
                    f"Unsafe or unexpected ZIP path: {name}")
            require(not PurePosixPath(name).is_absolute(), f"Absolute ZIP path: {name}")
            require(name.casefold() not in names, f"Duplicate ZIP path: {name}")
            names.add(name.casefold())
            if not info.is_dir():
                actual[name] = package.read(info)
        require(actual == expected, "ZIP differs from the installable source folder")


def git_value(*args):
    try:
        result = subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", action="store_true", help="Build ZIP before verifying it")
    args = parser.parse_args()
    files = source_files(ROOT)
    metadata, entries = validate_source(files)
    version = metadata["Version"]
    archive = ROOT / f"Tartaro-{version}.zip"
    if args.build:
        with ZipFile(archive, "w", ZIP_DEFLATED) as package:
            for name, data in files.items():
                package.writestr(name, data)
    verify_zip(archive, files)
    status = git_value("status", "--porcelain", "--", "Tartaro")
    report = {
        "version": version,
        "package": archive.name,
        "bytes": archive.stat().st_size,
        "sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
        "source_commit": git_value("rev-parse", "HEAD"),
        "addon_has_uncommitted_changes": None if status is None else bool(status),
        "source_note": "Local folder verified against ZIP; commit identity applies only if addon is clean.",
        "interface_declared_not_live_verified": metadata["Interface"],
        "flavor": metadata["AllowLoadGameType"],
        "toc_files": len(entries),
        "file_count": len(files),
        "in_game_tests": "pending",
        "curseforge_publication": "deferred_by_owner",
        "files": {name: hashlib.sha256(data).hexdigest() for name, data in files.items()},
    }
    target = ROOT / "distribution/package-report.json"
    target.parent.mkdir(exist_ok=True)
    target.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Verified {archive.name}: {len(files)} files; SHA256 {report['sha256']}")
    print("No publication performed. In-game validation remains pending.")


if __name__ == "__main__":
    main()
