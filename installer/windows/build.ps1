param([Parameter(Mandatory)][string]$Core)
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    $version = (Select-String -LiteralPath ../Cargo.toml -Pattern '^version = "([0-9.]+)"').Matches[0].Groups[1].Value
    $info = Join-Path $env:TEMP ("TartaroVersion-" + [guid]::NewGuid() + ".cs")
    ('[assembly: System.Reflection.AssemblyInformationalVersion("' + $version + '")]') | Set-Content -LiteralPath $info
    Copy-Item -LiteralPath $Core -Destination tartaro-installer.exe -Force
    & "$env:WINDIR/Microsoft.NET/Framework64/v4.0.30319/csc.exe" /nologo /target:winexe /codepage:65001 /optimize+ /win32icon:Tartaro.ico /out:Tartaro.exe /reference:System.Windows.Forms.dll /reference:System.Drawing.dll /reference:System.Net.Http.dll /reference:System.Web.Extensions.dll Tray.cs ProgramUpdates.cs "$info"
    if ($LASTEXITCODE) { throw "Falló la compilación del ícono de bandeja." }
    & "$env:WINDIR/Microsoft.NET/Framework64/v4.0.30319/csc.exe" /nologo /codepage:65001 /out:TestUpdater.exe /reference:System.Windows.Forms.dll /reference:System.Net.Http.dll /reference:System.Web.Extensions.dll ProgramUpdates.cs test-updater.cs
    if ($LASTEXITCODE) { throw "Falló la compilación de pruebas de actualización." }
    & ./TestUpdater.exe
    if ($LASTEXITCODE) { throw "Falló la prueba de selección de publicaciones." }
    $compiler = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    $iscc = if ($compiler) { $compiler.Source } else { "${env:ProgramFiles(x86)}/Inno Setup 6/ISCC.exe" }
    & $iscc "/DProgramVersion=$version" setup.iss
    if ($LASTEXITCODE) { throw "Falló la creación del instalador." }
} finally { Pop-Location }
