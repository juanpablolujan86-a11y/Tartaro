use anyhow::{bail, ensure, Context, Result};
use directories::{BaseDirs, ProjectDirs};
use fs2::FileExt;
use semver::Version;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::{
    collections::BTreeSet,
    fs,
    io::{self, Read, Write},
    path::{Path, PathBuf},
    process::Command,
};

pub const OVERLORD: &str = "https://github.com/leliondoc/overlord-forever-addon/releases/latest";
const PROJECT: &str = "juanpablolujan86-a11y/Tartaro";
const LIMIT: u64 = 64 * 1024 * 1024;

#[derive(Default, Serialize, Deserialize, Clone)]
#[serde(default)]
pub struct Config {
    pub folder: Option<PathBuf>,
    pub automatic: Option<bool>,
}

fn config_path() -> Result<PathBuf> {
    Ok(ProjectDirs::from("org", "Tartaro", "TartaroInstaller")
        .context("No se encontró la carpeta de configuración del usuario.")?
        .config_dir()
        .join("config.json"))
}

impl Config {
    pub fn load() -> Result<Self> {
        match fs::read(config_path()?) {
            Ok(bytes) => Ok(serde_json::from_slice(&bytes)?),
            Err(e) if e.kind() == io::ErrorKind::NotFound => Ok(Self::default()),
            Err(e) => Err(e.into()),
        }
    }
    pub fn save(&self) -> Result<()> {
        let path = config_path()?;
        let dir = path.parent().unwrap();
        fs::create_dir_all(dir)?;
        let mut tmp = tempfile::NamedTempFile::new_in(dir)?;
        serde_json::to_writer(tmp.as_file_mut(), self)?;
        tmp.as_file().sync_all()?;
        tmp.persist(path)?;
        Ok(())
    }
}

pub fn resolve(selected: &Path) -> Result<PathBuf> {
    for candidate in [
        selected.to_path_buf(),
        selected.join("AddOns"),
        selected.join("Interface/AddOns"),
        selected.join("_forever_/Interface/AddOns"),
    ] {
        let Some(game) = candidate.parent().and_then(Path::parent) else {
            continue;
        };
        if candidate
            .file_name()
            .is_some_and(|s| s.eq_ignore_ascii_case("AddOns"))
            && candidate
                .parent()
                .and_then(Path::file_name)
                .is_some_and(|s| s.eq_ignore_ascii_case("Interface"))
            && game
                .file_name()
                .is_some_and(|s| s.eq_ignore_ascii_case("_forever_"))
            && candidate.is_dir()
        {
            return Ok(candidate.canonicalize()?);
        }
    }
    bail!("Elegí World of Warcraft, _forever_ o su carpeta Interface/AddOns.")
}

pub fn detect() -> Vec<PathBuf> {
    let mut roots = Vec::new();
    for var in ["ProgramFiles(x86)", "ProgramFiles"] {
        if let Some(path) = std::env::var_os(var) {
            roots.push(PathBuf::from(path).join("World of Warcraft"));
        }
    }
    roots.push(PathBuf::from("/Applications/World of Warcraft"));
    if let Some(home) = BaseDirs::new() {
        for tail in [
            "Games/World of Warcraft",
            ".wine/drive_c/Program Files (x86)/World of Warcraft",
            "Games/battlenet/drive_c/Program Files (x86)/World of Warcraft",
        ] {
            roots.push(home.home_dir().join(tail));
        }
    }
    if let Some(prefix) = std::env::var_os("WINEPREFIX") {
        roots.push(PathBuf::from(prefix).join("drive_c/Program Files (x86)/World of Warcraft"));
    }
    #[cfg(windows)]
    for letter in b'C'..=b'Z' {
        let base = PathBuf::from(format!("{}:/", letter as char));
        for tail in [
            "World of Warcraft",
            "Games/World of Warcraft",
            "Juegos/World of Warcraft",
            "Program Files (x86)/World of Warcraft",
        ] {
            roots.push(base.join(tail));
        }
    }
    roots
        .iter()
        .filter_map(|p| resolve(p).ok())
        .collect::<BTreeSet<_>>()
        .into_iter()
        .collect()
}

pub fn installed(folder: &Path, addon: &str) -> Result<Option<Version>> {
    let dir = folder.join(addon);
    if !dir.try_exists()? {
        return Ok(None);
    }
    let toc = fs::read_to_string(dir.join(format!("{addon}.toc")))
        .context("No se pudo leer la versión instalada.")?;
    let raw = toc
        .lines()
        .find_map(|s| s.trim().strip_prefix("## Version:"))
        .context("Falta la versión en el archivo .toc")?;
    Ok(Some(Version::parse(raw.trim().trim_start_matches('v'))?))
}

#[derive(Deserialize)]
struct Release {
    tag_name: String,
    draft: bool,
    prerelease: bool,
    assets: Vec<Asset>,
}
#[derive(Deserialize)]
struct Asset {
    name: String,
    digest: Option<String>,
    size: u64,
    browser_download_url: String,
}

fn download(url: &str, dest: &Path, limit: u64) -> Result<()> {
    let mut cmd = Command::new("curl");
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        cmd.creation_flags(0x08000000);
    }
    let out = cmd
        .args([
            "-q",
            "--fail",
            "--silent",
            "--show-error",
            "--location",
            "--proto",
            "=https",
            "--proto-redir",
            "=https",
            "--connect-timeout",
            "12",
            "--max-time",
            "90",
            "--max-filesize",
            &limit.to_string(),
            "-A",
            "Tartaro-Installer/0.1",
            "-o",
        ])
        .arg(dest)
        .arg(url)
        .output()
        .context("No se pudo ejecutar curl para descargar desde GitHub.")?;
    ensure!(
        out.status.success(),
        "GitHub no completó la descarga: {}",
        String::from_utf8_lossy(&out.stderr).trim()
    );
    ensure!(
        fs::metadata(dest)?.len() <= limit,
        "El archivo supera el límite."
    );
    Ok(())
}

pub fn update(folder: &Path, allow_first: bool) -> Result<String> {
    let folder = resolve(folder)?;
    let state = folder.parent().unwrap().join(".tartaro-installer");
    fs::create_dir_all(&state)?;
    let lock = fs::OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .open(state.join("install.lock"))?;
    lock.try_lock_exclusive()
        .context("Ya hay otra instalación en curso.")?;
    let target = folder.join("Tartaro");
    let backup = state.join("previous");
    if !target.try_exists()? && backup.try_exists()? {
        fs::rename(&backup, &target).context("No se pudo recuperar la instalación anterior.")?;
    }
    let local = installed(&folder, "Tartaro")?;
    if local.is_none() && !allow_first {
        return Ok("Esperando la primera instalación.".into());
    }
    let temp = tempfile::tempdir_in(&state)?;
    let metadata = temp.path().join("release.json");
    download(
        &format!("https://api.github.com/repos/{PROJECT}/releases/latest"),
        &metadata,
        1024 * 1024,
    )?;
    let r: Release = serde_json::from_slice(&fs::read(metadata)?)?;
    ensure!(!r.draft && !r.prerelease, "La publicación no es estable.");
    let version = Version::parse(r.tag_name.trim_start_matches('v'))?;
    ensure!(version.pre.is_empty(), "La versión es de prueba.");
    if local.as_ref().is_some_and(|v| v >= &version) {
        return Ok(format!("Tártaro {} está al día.", local.unwrap()));
    }
    let name = format!("Tartaro-{version}.zip");
    let asset = r
        .assets
        .into_iter()
        .find(|a| a.name == name)
        .context("La publicación no incluye el ZIP instalable.")?;
    let url = format!(
        "https://github.com/{PROJECT}/releases/download/{}/{}",
        r.tag_name, name
    );
    ensure!(
        asset.browser_download_url == url && asset.size <= LIMIT,
        "El archivo publicado no coincide con el esperado."
    );
    let zip = temp.path().join(&name);
    download(&url, &zip, LIMIT)?;
    let data = fs::read(zip)?;
    let digest = format!("sha256:{:x}", Sha256::digest(&data));
    ensure!(
        data.len() as u64 == asset.size && asset.digest.as_deref() == Some(&digest),
        "Falló la verificación del ZIP."
    );
    apply(&folder, &state, temp.path(), &data, &version)?;
    Ok(format!(
        "Tártaro {version} instalado. Si estás jugando, hacé /reload cuando puedas."
    ))
}

fn apply(folder: &Path, state: &Path, stage: &Path, bytes: &[u8], version: &Version) -> Result<()> {
    let staged = stage.join("Tartaro");
    fs::create_dir(&staged)?;
    let mut zip = zip::ZipArchive::new(io::Cursor::new(bytes))?;
    ensure!(zip.len() <= 512, "Demasiados archivos.");
    let mut total = 0u64;
    let mut seen = BTreeSet::new();
    for i in 0..zip.len() {
        let mut entry = zip.by_index(i)?;
        if entry.is_dir() && entry.name() == "Tartaro/" {
            continue;
        }
        let name = entry
            .name()
            .strip_prefix("Tartaro/")
            .context("Carpeta inesperada en el ZIP.")?
            .to_string();
        ensure!(
            name.bytes()
                .all(|b| b.is_ascii_alphanumeric() || b"_.-".contains(&b))
                && !name.starts_with('.')
                && !name.ends_with('.')
                && seen.insert(name.to_ascii_lowercase()),
            "Nombre de archivo no válido o duplicado."
        );
        ensure!(
            matches!(
                Path::new(&name).extension().and_then(|v| v.to_str()),
                Some("lua" | "xml" | "toc" | "mp3" | "tga" | "md" | "txt")
            ),
            "Tipo de archivo inesperado."
        );
        let mode = entry.unix_mode().unwrap_or(0) & 0o170000;
        ensure!(
            mode == 0 || mode == 0o100000,
            "Entrada no regular en el ZIP."
        );
        let size = entry.size();
        ensure!(
            size <= LIMIT - total,
            "El contenido supera el límite de extracción."
        );
        total += size;
        let mut out = fs::File::create_new(staged.join(name))?;
        let copied = io::copy(&mut (&mut entry).take(size + 1), &mut out)?;
        ensure!(copied == size, "Archivo incompleto.");
        out.flush()?;
    }
    ensure!(
        installed(stage, "Tartaro")?.as_ref() == Some(version),
        "La versión interna no coincide."
    );
    let toc = fs::read_to_string(staged.join("Tartaro.toc"))?;
    ensure!(
        toc.lines()
            .any(|l| l.trim() == "## AllowLoadGameType: camelot"),
        "El paquete no es para Forever."
    );
    let mut entries = 0;
    for line in toc
        .lines()
        .map(str::trim)
        .filter(|s| !s.is_empty() && !s.starts_with('#'))
    {
        ensure!(
            seen.contains(&line.to_ascii_lowercase()),
            "Falta un archivo del addon: {line}"
        );
        entries += 1;
    }
    ensure!(entries > 0, "El paquete no tiene módulos.");
    let target = folder.join("Tartaro");
    let backup = state.join("previous");
    let replacing = target.try_exists()?;
    if replacing {
        if backup.try_exists()? {
            fs::remove_dir_all(&backup)?;
        }
        fs::rename(&target, &backup).context("No se pudo mover la versión anterior.")?;
    }
    if let Err(error) = fs::rename(&staged, &target) {
        if replacing {
            fs::rename(&backup, &target)
                .context("La versión anterior quedó en .tartaro-installer/previous.")?;
        }
        return Err(error.into());
    }
    Ok(())
}
#[cfg(test)]
mod tests {
    use super::*;
    use zip::{write::SimpleFileOptions, ZipWriter};
    fn fixture() -> (tempfile::TempDir, PathBuf, PathBuf) {
        let temp = tempfile::tempdir().unwrap();
        let folder = temp.path().join("_forever_/Interface/AddOns");
        let state = folder.parent().unwrap().join(".tartaro-installer");
        fs::create_dir_all(&folder).unwrap();
        fs::create_dir_all(&state).unwrap();
        (temp, folder, state)
    }
    fn archive(version: &str) -> Vec<u8> {
        let mut w = ZipWriter::new(io::Cursor::new(Vec::new()));
        w.start_file("Tartaro/Tartaro.toc", SimpleFileOptions::default())
            .unwrap();
        write!(
            w,
            "## Version: {version}\n## AllowLoadGameType: camelot\nCore.lua\n"
        )
        .unwrap();
        w.start_file("Tartaro/Core.lua", SimpleFileOptions::default())
            .unwrap();
        w.write_all(b"-- fixture").unwrap();
        w.finish().unwrap().into_inner()
    }
    #[test]
    fn install_update_and_reject_invalid_package() {
        let (temp, folder, state) = fixture();
        for p in [temp.path(), folder.parent().unwrap(), folder.as_path()] {
            assert_eq!(resolve(p).unwrap(), folder.canonicalize().unwrap());
        }
        assert!(resolve(&temp.path().join("_retail_")).is_err());
        let other = folder.join("Other");
        fs::create_dir(&other).unwrap();
        for v in ["1.0.0", "1.0.1"] {
            let stage = tempfile::tempdir_in(&state).unwrap();
            let version = Version::parse(v).unwrap();
            apply(&folder, &state, stage.path(), &archive(v), &version).unwrap();
            assert_eq!(installed(&folder, "Tartaro").unwrap(), Some(version));
        }
        let stage = tempfile::tempdir_in(&state).unwrap();
        assert!(apply(
            &folder,
            &state,
            stage.path(),
            &archive("2.0.0"),
            &Version::new(3, 0, 0)
        )
        .is_err());
        assert!(other.exists());
        assert_eq!(
            installed(&folder, "Tartaro").unwrap(),
            Some(Version::new(1, 0, 1))
        );
        assert!(state.join("previous/Core.lua").exists());
    }
    #[test]
    #[ignore = "uses the public GitHub release and a temporary game directory"]
    fn official_release_round_trip() {
        let (_temp, folder, _state) = fixture();
        let first = update(&folder, true).unwrap();
        assert!(first.contains("instalado"));
        let local = installed(&folder, "Tartaro").unwrap().unwrap();
        assert!(update(&folder, true).unwrap().contains("al día"));
        assert_eq!(installed(&folder, "Tartaro").unwrap(), Some(local));
    }
}

pub fn overlord_status(folder: Option<&Path>) -> Result<String> {
    let dir = tempfile::tempdir()?;
    let meta = dir.path().join("release.json");
    download(
        "https://api.github.com/repos/leliondoc/overlord-forever-addon/releases/latest",
        &meta,
        1024 * 1024,
    )?;
    let release: Release = serde_json::from_slice(&fs::read(meta)?)?;
    let latest = Version::parse(release.tag_name.trim_start_matches('v'))?;
    ensure!(
        !release.draft && !release.prerelease && latest.pre.is_empty(),
        "Sin publicación estable."
    );
    let local = match folder {
        Some(path) => installed(path, "Overlord")?,
        None => None,
    };
    Ok(match local {
        Some(v) if v >= latest => format!("Versión instalada · {v} · Al día"),
        Some(v) => format!("Instalado · {v}    Disponible · {latest}"),
        None => format!("Versión publicada · {latest}"),
    })
}
