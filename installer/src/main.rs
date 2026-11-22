#![cfg_attr(target_os = "windows", windows_subsystem = "windows")]
mod addon;
#[cfg(windows)]
mod background;

use addon::{Config, OVERLORD};
use eframe::egui::{self, Color32, RichText};
use std::{
    path::PathBuf,
    sync::mpsc::{self, Receiver},
    time::{Duration, Instant},
};

const INTERVAL: Duration = Duration::from_secs(60 * 60);
const LOGO: &[u8] = include_bytes!("../assets/escudo.rgba");

struct Installer {
    config: Config,
    candidates: Vec<PathBuf>,
    status: String,
    current: String,
    installed: bool,
    confirmed: bool,
    resident: bool,
    pending: Option<Receiver<Result<String, String>>>,
    check: Instant,
    overlord_check: Instant,
    overlord_text: String,
    overlord_result: Option<Receiver<(Option<PathBuf>, String)>>,
    emblem: egui::TextureHandle,
}

impl Installer {
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        let (mut config, mut status) = match Config::load() {
            Ok(c) => (c, String::new()),
            Err(e) => (
                Config::default(),
                format!("Error al leer la configuración: {e}"),
            ),
        };
        let confirmed = config.folder.is_some();
        let candidates = addon::detect();
        if config.folder.is_none() && candidates.len() == 1 {
            config.folder = Some(candidates[0].clone());
        }
        if config
            .folder
            .as_deref()
            .is_some_and(|p| addon::resolve(p).is_err())
        {
            config.folder = None;
            status = "La carpeta guardada ya no está disponible. Elegí la instalación de Forever."
                .into();
        }
        let emblem = cc.egui_ctx.load_texture(
            "Tártaro",
            egui::ColorImage::from_rgba_unmultiplied([112, 112], LOGO),
            Default::default(),
        );
        let mut app = Self {
            config,
            candidates,
            status,
            current: String::new(),
            installed: false,
            confirmed,
            resident: cfg!(windows) && std::env::args().any(|a| a == "--resident-ui"),
            pending: None,
            check: Instant::now(),
            overlord_check: Instant::now(),
            overlord_text: String::new(),
            overlord_result: None,
            emblem,
        };
        app.refresh();
        app
    }
    fn refresh(&mut self) {
        let result = self
            .config
            .folder
            .as_deref()
            .map(|p| addon::installed(p, "Tartaro"));
        self.installed = matches!(result, Some(Ok(Some(_))));
        self.current = match result {
            Some(Ok(Some(v))) => format!("Versión instalada · {v}"),
            Some(Ok(None)) => "Disponible para instalar".into(),
            Some(Err(e)) => e.to_string(),
            None => "Elegí la carpeta de Forever".into(),
        };
    }
    fn select(&mut self, path: PathBuf) {
        match addon::resolve(&path) {
            Ok(folder) => {
                self.confirmed = true;
                self.config.folder = Some(folder);
                self.overlord_check = Instant::now();
                self.overlord_text.clear();
                self.status = String::new();
                self.persist();
                self.refresh();
                self.check = Instant::now();
            }
            Err(e) => self.status = e.to_string(),
        }
    }
    fn persist(&mut self) {
        if let Err(e) = self.config.save() {
            self.status = format!("No se pudo guardar la configuración: {e}");
        }
    }
    fn start(&mut self, manual: bool, ctx: &egui::Context) {
        let Some(folder) = self.config.folder.clone() else {
            return;
        };
        if self.pending.is_some() {
            return;
        }
        self.confirmed = true;
        self.persist();
        self.check = Instant::now() + INTERVAL;
        self.status = "Consultando la versión estable en GitHub…".into();
        let (tx, rx) = mpsc::channel();
        self.pending = Some(rx);
        let ctx = ctx.clone();
        std::thread::spawn(move || {
            let result = addon::update(&folder, manual).map_err(|e| format!("{e:#}"));
            let _ = tx.send(result);
            ctx.request_repaint();
        });
    }
}

impl eframe::App for Installer {
    fn update(&mut self, ctx: &egui::Context, _: &mut eframe::Frame) {
        if let Some(rx) = &self.pending {
            match rx.try_recv() {
                Ok(result) => {
                    self.status = result.unwrap_or_else(|e| e);
                    self.pending = None;
                    self.refresh();
                }
                Err(mpsc::TryRecvError::Disconnected) => {
                    self.status = "La comprobación se interrumpió.".into();
                    self.pending = None;
                }
                Err(mpsc::TryRecvError::Empty) => {}
            }
        }
        if self.pending.is_some() && ctx.input(|i| i.viewport().close_requested()) {
            ctx.send_viewport_cmd(egui::ViewportCommand::CancelClose);
        }
        if !self.resident && self.confirmed
            && self.installed
            && self.config.automatic.unwrap_or(true)
            && Instant::now() >= self.check
        {
            self.start(false, ctx);
        }
        if let Some(rx) = &self.overlord_result {
            match rx.try_recv() {
                Ok((path, text)) => {
                    if self.config.folder == path {
                        self.overlord_text = text;
                    }
                    self.overlord_result = None;
                }
                Err(mpsc::TryRecvError::Disconnected) => {
                    self.overlord_result = None;
                }
                Err(mpsc::TryRecvError::Empty) => {}
            }
        }
        if self.overlord_result.is_none() && Instant::now() >= self.overlord_check {
            self.overlord_check = Instant::now() + INTERVAL;
            let path = self.config.folder.clone();
            let ctx = ctx.clone();
            let (tx, rx) = mpsc::channel();
            self.overlord_result = Some(rx);
            std::thread::spawn(move || {
                let text = addon::overlord_status(path.as_deref())
                    .unwrap_or_else(|_| "No se pudo consultar la versión publicada.".into());
                let _ = tx.send((path, text));
                ctx.request_repaint();
            });
        }
        ctx.request_repaint_after(Duration::from_secs(20));
        egui::CentralPanel::default()
            .frame(
                egui::Frame::new()
                    .fill(Color32::from_rgb(32, 26, 25))
                    .inner_margin(22),
            )
            .show(ctx, |ui| {
                let copper = Color32::from_rgb(239, 180, 123);
                ui.vertical_centered(|ui| {
                    ui.image((self.emblem.id(), egui::vec2(82., 82.)));
                    ui.label(RichText::new("TÁRTARO").size(29.).color(copper));
                    ui.label(concat!("Instalador de la hermandad · ", env!("CARGO_PKG_VERSION")));
                    #[cfg(windows)]
                    if self.resident && ui.button("Buscar actualización del programa").clicked() {
                        let result = std::env::current_exe().and_then(|exe|
                            std::process::Command::new(exe.with_file_name("Tartaro.exe")).arg("--program-check").spawn());
                        if let Err(error) = result { self.status = format!("No se pudo abrir el actualizador: {error}"); }
                    }
                });
                ui.add_space(12.);
                egui::ScrollArea::vertical().show(ui, |ui| {
                    ui.heading("Instalación de Forever");
                    if let Some(path) = &self.config.folder {
                        ui.label(path.display().to_string().trim_start_matches(r"\\?\"));
                    } else if self.candidates.len() > 1 {
                        ui.label("Se encontraron varias instalaciones:");
                        for path in self.candidates.clone() {
                            if ui.button(path.display().to_string()).clicked() {
                                self.select(path);
                            }
                        }
                    }
                    let busy = self.pending.is_some();
                    if ui
                        .add_enabled(!busy, egui::Button::new("Elegir carpeta…"))
                        .clicked()
                    {
                        if let Some(p) = rfd::FileDialog::new()
                            .set_title("Elegí la carpeta de Forever o de AddOns")
                            .pick_folder()
                        {
                            self.select(p);
                        }
                    }
                    ui.add_space(12.);
                    ui.separator();
                    ui.heading("Tártaro");
                    ui.label(&self.current);
                    let action = if self.installed {
                        "Buscar actualización"
                    } else {
                        "Instalar Tártaro"
                    };
                    if ui
                        .add_enabled(
                            !busy && self.config.folder.is_some(),
                            egui::Button::new(RichText::new(action).color(Color32::BLACK))
                                .fill(copper),
                        )
                        .clicked()
                    {
                        self.start(true, ctx);
                    }
                    let mut automatic = self.config.automatic.unwrap_or(true);
                    if ui
                        .checkbox(
                            &mut automatic,
                            if self.resident { "Actualizar automáticamente desde la bandeja" } else { "Actualizar automáticamente mientras el instalador esté abierto" },
                        )
                        .changed()
                    {
                        self.config.automatic = Some(automatic);
                        self.persist();
                    }
                    if !self.status.is_empty() {
                        ui.label(RichText::new(&self.status).color(copper));
                    }
                    ui.add_space(12.);
                    ui.separator();
                    ui.heading("Overlord Forever");
                    ui.label(&self.overlord_text);
                    ui.hyperlink_to("Ver descarga oficial", OVERLORD);
                });
            });
    }
}

fn main() -> eframe::Result<()> {
    #[cfg(windows)]
    if std::env::args().any(|arg| arg == "--tray-check") {
        std::process::exit(match background::check() { Ok(true) => 10, Ok(false) => 0, Err(_) => 1 });
    }
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([690., 540.])
            .with_min_inner_size([430., 420.])
            .with_icon(egui::IconData {
                rgba: LOGO.to_vec(),
                width: 112,
                height: 112,
            }),
        ..Default::default()
    };
    eframe::run_native(
        "Tártaro · Instalador",
        options,
        Box::new(|cc| Ok(Box::new(Installer::new(cc)))),
    )
}
