param([Parameter(Mandatory)][string]$Core)
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    Copy-Item -LiteralPath $Core -Destination tartaro-installer.exe -Force
    & "$env:WINDIR/Microsoft.NET/Framework64/v4.0.30319/csc.exe" /nologo /target:winexe /codepage:65001 /optimize+ /win32icon:Tartaro.ico /out:Tartaro.exe /reference:System.Windows.Forms.dll /reference:System.Drawing.dll Tray.cs
    if ($LASTEXITCODE) { throw "Falló la compilación del ícono de bandeja." }
    $compiler = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    $iscc = if ($compiler) { $compiler.Source } else { "${env:ProgramFiles(x86)}/Inno Setup 6/ISCC.exe" }
    & $iscc setup.iss
    if ($LASTEXITCODE) { throw "Falló la creación del instalador." }
} finally { Pop-Location }
