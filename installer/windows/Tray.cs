using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

internal sealed class TartaroTray : ApplicationContext {
    const string MutexName = @"Local\Tartaro.Instalador.Tray";
    const string OpenEvent = @"Local\Tartaro.Instalador.Open";
    readonly NotifyIcon icon;
    readonly EventWaitHandle open;
    readonly System.Windows.Forms.Timer timer;
    readonly string executable = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tartaro-installer.exe");
    Process window, worker;
    DateTime nextCheck = DateTime.UtcNow;
    bool quitting;
    [DllImport("user32.dll")] static extern bool ShowWindowAsync(IntPtr hwnd, int command);
    [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr hwnd);

    [STAThread]
    static void Main(string[] args) {
        bool first;
        using (var mutex = new Mutex(true, MutexName, out first)) {
            bool quiet = Array.IndexOf(args, "--background") >= 0;
            if (!first) {
                if (!quiet) {
                    for (int i = 0; i < 20; ++i) {
                        try { using (var signal = EventWaitHandle.OpenExisting(OpenEvent)) signal.Set(); break; }
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
        var menu = new ContextMenuStrip();
        menu.Items.Add("Abrir Tártaro", null, (s,e) => OpenWindow());
        menu.Items.Add("Salir", null, (s,e) => Quit());
        icon = new NotifyIcon { Text = "Tártaro", Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath),
            ContextMenuStrip = menu, Visible = true };
        icon.MouseClick += (s,e) => { if (e.Button == MouseButtons.Left) OpenWindow(); };
        icon.BalloonTipClicked += (s,e) => OpenWindow();
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

    void Tick() {
        if (open.WaitOne(0)) OpenWindow();
        if (worker != null && worker.HasExited) {
            int code = worker.ExitCode;
            worker.Dispose(); worker = null;
            if (code == 10) icon.ShowBalloonTip(6000, "Tártaro actualizado",
                "La actualización está instalada. Hacé /reload cuando puedas.", ToolTipIcon.Info);
            icon.Text = code == 1 ? "Tártaro · No se pudo comprobar la actualización" : "Tártaro";
        }
        if (quitting) {
            if (window != null && !window.HasExited) window.CloseMainWindow();
            if (worker == null && (window == null || window.HasExited)) ExitThread();
            return;
        }
        if (worker == null && DateTime.UtcNow >= nextCheck) {
            worker = Start("--tray-check");
            nextCheck = DateTime.UtcNow.AddHours(1);
        }
    }

    void Quit() {
        quitting = true;
        if (window != null && !window.HasExited) window.CloseMainWindow();
        if (worker == null && (window == null || window.HasExited)) ExitThread();
    }

    protected override void Dispose(bool disposing) {
        if (disposing) {
            timer.Dispose(); open.Dispose(); icon.Visible = false;
            icon.ContextMenuStrip.Dispose(); icon.Icon.Dispose(); icon.Dispose();
            if (window != null) window.Dispose();
            if (worker != null) worker.Dispose();
        }
        base.Dispose(disposing);
    }
}
