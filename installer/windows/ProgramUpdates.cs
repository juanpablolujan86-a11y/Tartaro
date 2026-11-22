using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.Windows.Forms;

internal static class ProgramUpdates {
    internal const string Prefix = "instalador-v";
    internal const string SetupName = "Tartaro-Setup-Windows-x64.exe";
    const string Repo = "juanpablolujan86-a11y/Tartaro";
    const long MaxBytes = 64L * 1024 * 1024;
    static readonly HttpClient client = CreateClient();

    internal sealed class Candidate { public Version Version; public string Url, Digest; public long Size; }
    internal sealed class TagRef { public string @ref {get;set;} }
    internal sealed class Asset { public string name {get;set;} public string browser_download_url {get;set;} public string digest {get;set;} public long size {get;set;} }
    internal sealed class Release { public string tag_name {get;set;} public bool draft {get;set;} public bool prerelease {get;set;} public Asset[] assets {get;set;} }

    static HttpClient CreateClient() {
        ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;
        var c = new HttpClient { Timeout = TimeSpan.FromSeconds(90), MaxResponseContentBufferSize = MaxBytes };
        c.DefaultRequestHeaders.UserAgent.ParseAdd("Tartaro-Desktop/0.3");
        return c;
    }
    internal static Version ParseTag(string tag) {
        if (tag == null || !Regex.IsMatch(tag, @"^instalador-v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")) return null;
        Version version;
        return Version.TryParse(tag.Substring(Prefix.Length), out version) ? version : null;
    }
    internal static Candidate Select(Release release, Version version) {
        string tag = Prefix + version;
        if (release.draft || release.prerelease || release.tag_name != tag) return null;
        string url = "https://github.com/" + Repo + "/releases/download/" + tag + "/" + SetupName;
        var asset = (release.assets ?? new Asset[0]).SingleOrDefault(a => a.name == SetupName);
        if (asset == null || asset.browser_download_url != url || asset.size <= 0 || asset.size > MaxBytes ||
            !Regex.IsMatch(asset.digest ?? "", "^sha256:[0-9a-fA-F]{64}$")) return null;
        return new Candidate { Version=version, Url=url, Digest=asset.digest.Substring(7), Size=asset.size };
    }
    internal static Candidate Check(Version current) {
        string api = "https://api.github.com/repos/" + Repo + "/";
        var json = new JavaScriptSerializer();
        var refs = json.Deserialize<TagRef[]>(client.GetStringAsync(api+"git/matching-refs/tags/"+Prefix).GetAwaiter().GetResult());
        foreach (var version in refs.Where(r=>r.@ref != null && r.@ref.StartsWith("refs/tags/",StringComparison.Ordinal))
            .Select(r=>ParseTag(r.@ref.Substring(10))).Where(v=>v != null && v > current).OrderByDescending(v=>v)) {
            using (var res = client.GetAsync(api+"releases/tags/"+Prefix+version).GetAwaiter().GetResult()) {
                if (res.StatusCode == HttpStatusCode.NotFound) continue;
                res.EnsureSuccessStatusCode();
                var candidate = Select(json.Deserialize<Release>(res.Content.ReadAsStringAsync().GetAwaiter().GetResult()), version);
                if (candidate != null) return candidate;
            }
        }
        return null;
    }
    internal static string Hash(Stream stream) {
        using (var sha=SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-","").ToLowerInvariant();
    }
    internal static string Download(Candidate candidate) {
        var bytes=client.GetByteArrayAsync(candidate.Url).GetAwaiter().GetResult();
        using (var input=new MemoryStream(bytes)) {
            if (bytes.LongLength != candidate.Size || !Hash(input).Equals(candidate.Digest,StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Falló la verificación de la descarga.");
        }
        string dir=Path.Combine(Path.GetTempPath(),"Tartaro-actualizacion-"+Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(dir);
        File.WriteAllBytes(Path.Combine(dir,SetupName),bytes);
        File.Copy(Application.ExecutablePath,Path.Combine(dir,"Aplicar.exe"));
        return dir;
    }
    internal static void Handoff(string dir,string digest) {
        Process.Start(new ProcessStartInfo(Path.Combine(dir,"Aplicar.exe"),
            "--apply "+Process.GetCurrentProcess().Id+" "+digest+" \""+Application.ExecutablePath+"\"") {UseShellExecute=false});
    }
    internal static int Apply(string[] args) {
        string setup=Path.Combine(AppDomain.CurrentDomain.BaseDirectory,SetupName);
        try {
            // Keep the verified installer locked against modification during execution.
            using (var input=new FileStream(setup,FileMode.Open,FileAccess.Read,FileShare.Read)) {
                if (!Hash(input).Equals(args[2],StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("El instalador cambió después de la descarga.");
                try { using (var parent=Process.GetProcessById(int.Parse(args[1]))) {
                    if (!parent.WaitForExit(60000)) throw new TimeoutException("Tártaro todavía está ocupado.");
                }} catch (ArgumentException) { }
                using (var child=Process.Start(new ProcessStartInfo(setup,"/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR=\""+Path.GetDirectoryName(args[3])+"\"") {UseShellExecute=false})) {
                    child.WaitForExit();
                    if (child.ExitCode!=0) throw new IOException("Windows no completó la actualización.");
                }
            }
            File.Delete(setup);
        } catch(Exception err) {
            MessageBox.Show(err.Message,"Actualización de Tártaro",MessageBoxButtons.OK,MessageBoxIcon.Warning);
        }
        if (File.Exists(args[3])) Process.Start(new ProcessStartInfo(args[3]) {UseShellExecute=false});
        return 0;
    }
}
