use crate::addon::{self, Config};
use anyhow::Result;

// The resident Windows tray starts this worker once per check. Configuration
// is read each time so changes made in the settings window apply immediately.
pub fn check() -> Result<bool> {
    let config = Config::load()?;
    let Some(folder) = config.folder else { return Ok(false) };
    if !config.automatic.unwrap_or(true) { return Ok(false); }
    let Some(previous) = addon::installed(&folder, "Tartaro")? else { return Ok(false) };
    addon::update(&folder, false)?;
    Ok(addon::installed(&folder, "Tartaro")?.is_some_and(|current| current > previous))
}
