using System;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

internal sealed class TartaroTray : ApplicationContext {
    const string MutexName = @"Local\Tartaro.Instalador.Tray";
    const string OpenEvent = @"Local\Tartaro.Instalador.Open";
    readonly NotifyIcon icon;
    readonly EventWaitHandle open, checkProgram;
    readonly ToolStripMenuItem updateItem;
    Task<ProgramUpdates.Candidate> checking;
    Task<string> downloading;
    ProgramUpdates.Candidate available;
    string readyDir;
    Version announced;
    DateTime nextProgramCheck = DateTime.UtcNow;
    bool requested, programBalloon;
    const string CheckEvent = @"Local\Tartaro.Instalador.Check";
    readonly System.Windows.Forms.Timer timer;
    readonly string executable = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tartaro-installer.exe");
    Process window, worker;
    DateTime nextCheck = DateTime.UtcNow;
    bool quitting;
    [DllImport("user32.dll")] static extern bool ShowWindowAsync(IntPtr hwnd, int command);
    [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr hwnd);

    [STAThread]
    static void Main(string[] args) {
        if (args.Length == 4 && args[0] == "--apply") { ProgramUpdates.Apply(args); return; }
        bool manual = Array.IndexOf(args, "--program-check") >= 0;
        bool first;
        using (var mutex = new Mutex(true, MutexName, out first)) {
            bool quiet = Array.IndexOf(args, "--background") >= 0;
            if (!first) {
                if (!quiet) {
                    for (int i = 0; i < 20; ++i) {
                        try { using (var signal = EventWaitHandle.OpenExisting(manual ? CheckEvent : OpenEvent)) signal.Set(); break; }
                        catch (WaitHandleCannotBeOpenedException) { Thread.Sleep(50); }
                    }
                }
                return;
            }
            Application.EnableVisualStyles();
            using (var tray = new TartaroTray(quiet)) Application.Run(tray);
        }
    }

    TartaroTray(bool quiet) {
        open = new EventWaitHandle(false, EventResetMode.AutoReset, OpenEvent);
        checkProgram = new EventWaitHandle(false, EventResetMode.AutoReset, CheckEvent);
        var menu = new ContextMenuStrip();
        menu.Items.Add("Abrir Tártaro", null, (s,e) => OpenWindow());
        updateItem = new ToolStripMenuItem("Buscar actualización del programa");
        updateItem.Click += (s,e) => { if (available != null) BeginDownload(); else RequestCheck(); };
        menu.Items.Add(updateItem);
        menu.Items.Add("Salir", null, (s,e) => Quit());
        icon = new NotifyIcon { Text = "Tártaro", Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath),
            ContextMenuStrip = menu, Visible = true };
        icon.MouseClick += (s,e) => { if (e.Button == MouseButtons.Left) OpenWindow(); };
        icon.BalloonTipClicked += (s,e) => { if (programBalloon && available != null) ShowOffer(); else OpenWindow(); };
        timer = new System.Windows.Forms.Timer { Interval = 500 };
        timer.Tick += (s,e) => Tick();
        timer.Start();
        if (!quiet) OpenWindow();
    }

    Process Start(string args) {
        return Process.Start(new ProcessStartInfo(executable, args) { UseShellExecute = false });
    }

    void OpenWindow() {
        if (quitting) return;
        if (window != null && !window.HasExited) {
            var hwnd = window.MainWindowHandle;
            if (hwnd != IntPtr.Zero) { ShowWindowAsync(hwnd, 9); SetForegroundWindow(hwnd); }
            return;
        }
        if (window != null) window.Dispose();
        window = Start("--resident-ui");
    }

    void RequestCheck() {
        if (quitting || downloading != null) return;
        if (available != null) { ShowOffer(); return; }
        requested = true;
        nextProgramCheck = DateTime.UtcNow;
    }

    void ShowOffer() {
        if (downloading != null || quitting || available == null) return;
        using (var dialog = new Form { Text = "Actualización del programa Tártaro", Width = 430, Height = 155,
            StartPosition = FormStartPosition.CenterScreen, FormBorderStyle = FormBorderStyle.FixedDialog,
            MaximizeBox = false, MinimizeBox = false, TopMost = true }) {
            dialog.Controls.Add(new Label { Text = "Está disponible Tártaro " + available.Version +
                ". El programa se reiniciará al actualizar.", Left = 16, Top = 16, Width = 390, Height = 40 });
            var later = new Button {Text="Más tarde", Left=192, Top=66, Width=96, DialogResult=DialogResult.Cancel};
            var apply = new Button {Text="Actualizar", Left=300, Top=66, Width=96, DialogResult=DialogResult.OK};
            dialog.Controls.Add(later); dialog.Controls.Add(apply); dialog.CancelButton=later;
            if (dialog.ShowDialog()==DialogResult.OK) BeginDownload();
        }
    }

    void BeginDownload() {
        if (downloading != null || quitting || available == null) return;
        var candidate = available;
        updateItem.Enabled=false; updateItem.Text="Descargando actualización…";
        downloading=Task.Run(()=>ProgramUpdates.Download(candidate));
    }

    void UpdateProgram() {
        if (checkProgram.WaitOne(0)) RequestCheck();
        if (checking == null && available == null && DateTime.UtcNow >= nextProgramCheck) {
            nextProgramCheck=DateTime.UtcNow.AddHours(1);
            checking=Task.Run(()=>ProgramUpdates.Check(new Version(Application.ProductVersion)));
        }
        if (checking != null && checking.IsCompleted) {
            var completed=checking; checking=null;
            bool manual=requested; requested=false;
            nextProgramCheck=DateTime.UtcNow.AddHours(1);
            try { available=completed.GetAwaiter().GetResult(); }
            catch(Exception) {
                if (manual) MessageBox.Show("No se pudo consultar GitHub. Volvé a intentarlo.","Tártaro");
                return;
            }
            if (available != null) {
                updateItem.Text="Actualizar programa a " + available.Version;
                if (manual) ShowOffer();
                else if (announced != available.Version) {
                    announced=available.Version; programBalloon=true;
                    icon.ShowBalloonTip(9000,"Nueva versión del programa Tártaro",
                        "Tártaro " + available.Version + " está disponible. Tocá para actualizar.",ToolTipIcon.Info);
                }
            } else if (manual) MessageBox.Show("El programa Tártaro está al día.","Tártaro");
        }
        if (downloading != null && downloading.IsCompleted) {
            var completed=downloading; downloading=null;
            try { readyDir=completed.GetAwaiter().GetResult(); Quit(); }
            catch(Exception err) {
                updateItem.Enabled=true; updateItem.Text="Reintentar actualización del programa";
                MessageBox.Show("No se pudo actualizar. "+err.Message,"Tártaro");
            }
        }
    }

    void FinishQuit() {
        if (readyDir != null) {
            try { ProgramUpdates.Handoff(readyDir,available.Digest); }
            catch(Exception err) {
                quitting=false; readyDir=null; updateItem.Enabled=true; updateItem.Text="Reintentar actualización";
                MessageBox.Show(err.Message,"Tártaro"); return;
            }
            readyDir=null;
        }
        ExitThread();
    }

    void Tick() {
        if (open.WaitOne(0)) OpenWindow();
        if (!quitting) UpdateProgram();
        if (worker != null && worker.HasExited) {
            int code = worker.ExitCode;
            worker.Dispose(); worker = null;
            if (code == 10) { programBalloon=false; icon.ShowBalloonTip(6000, "Tártaro actualizado",
                "La actualización está instalada. Hacé /reload cuando puedas.", ToolTipIcon.Info); }
            icon.Text = code == 1 ? "Tártaro · No se pudo comprobar la actualización" : "Tártaro";
        }
        if (quitting) {
            if (window != null && !window.HasExited) window.CloseMainWindow();
            if (worker == null && (window == null || window.HasExited)) FinishQuit();
            return;
        }
        if (worker == null && DateTime.UtcNow >= nextCheck) {
            worker = Start("--tray-check");
            nextCheck = DateTime.UtcNow.AddHours(1);
        }
    }

    void Quit() {
        if (downloading != null) return;
        quitting = true;
        if (window != null && !window.HasExited) window.CloseMainWindow();
        if (worker == null && (window == null || window.HasExited)) FinishQuit();
    }

    protected override void Dispose(bool disposing) {
        if (disposing) {
            timer.Dispose(); open.Dispose(); checkProgram.Dispose(); icon.Visible = false;
            icon.ContextMenuStrip.Dispose(); icon.Icon.Dispose(); icon.Dispose();
            if (window != null) window.Dispose();
            if (worker != null) worker.Dispose();
        }
        base.Dispose(disposing);
    }
}
