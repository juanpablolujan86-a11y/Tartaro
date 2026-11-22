using System;
using System.IO;
internal static class Tests {
    static void Require(bool ok) { if (!ok) throw new Exception("Falló la prueba del actualizador"); }
    public static void Main() {
        var v = new Version("0.3.0");
        Require(ProgramUpdates.ParseTag("instalador-v0.3.0")==v);
        Require(ProgramUpdates.ParseTag("v0.3.1")==null);
        Require(ProgramUpdates.ParseTag("instalador-v0.3.1-beta")==null);
        Require(ProgramUpdates.ParseTag("instalador-v0.10.0")>v);
        var a = new ProgramUpdates.Asset {name=ProgramUpdates.SetupName, size=12,
            digest="sha256:"+new string('0',64),browser_download_url="https://github.com/juanpablolujan86-a11y/Tartaro/releases/download/instalador-v0.3.0/"+ProgramUpdates.SetupName};
        var r = new ProgramUpdates.Release {tag_name="instalador-v0.3.0",assets=new[]{a}};
        Require(ProgramUpdates.Select(r,v)!=null);
        r.prerelease=true; Require(ProgramUpdates.Select(r,v)==null);
        r.prerelease=false; r.draft=true; Require(ProgramUpdates.Select(r,v)==null);
        r.draft=false; a.digest=null; Require(ProgramUpdates.Select(r,v)==null);
        a.digest="sha256:"+new string('0',64); a.browser_download_url="https://example.com/setup.exe";
        Require(ProgramUpdates.Select(r,v)==null);
        using (var m=new MemoryStream()) Require(ProgramUpdates.Hash(m)=="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
    }
}
