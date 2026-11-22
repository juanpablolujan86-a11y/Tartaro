param(
    [Parameter(Mandatory)][string]$Core,
    [switch]$Signed,
    [string]$CertificateThumbprint
)
$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    if ($Signed -or $PSBoundParameters.ContainsKey('CertificateThumbprint')) {
        if ($CertificateThumbprint -notmatch '^[0-9a-fA-F]{40}$') {
            throw "Indicá la huella del certificado de firma de código de Windows."
        }
        $certificate = Get-Item -LiteralPath "Cert:/CurrentUser/My/$CertificateThumbprint" -ErrorAction Stop
        if (!$certificate.HasPrivateKey) { throw "El certificado requiere acceso a su clave privada." }
        $signTool = (Get-Command signtool.exe -ErrorAction Stop).Source
        $signArgs = @('sign','/sha1',$certificate.Thumbprint,'/fd','SHA256','/tr','http://timestamp.digicert.com','/td','SHA256')
        $Signed = $true
    }
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
    $setupArgs = @("/DProgramVersion=$version")
    if ($Signed) {
        foreach ($binary in 'Tartaro.exe','tartaro-installer.exe') {
            & $signTool @signArgs $binary
            if ($LASTEXITCODE) { throw "Falló la firma de $binary" }
            & $signTool verify /pa /tw $binary
            if ($LASTEXITCODE) { throw "Firma inválida en $binary" }
        }
        $command = '"{0}" {1} $f' -f $signTool,($signArgs -join ' ')
        $setupArgs += '/DSignedBuild',("/Startaro=" + $command)
    }
    & $iscc @setupArgs setup.iss
    if ($LASTEXITCODE) { throw "Falló la creación del instalador." }
    if ($Signed) {
        & $signTool verify /pa /tw dist/Tartaro-Setup-Windows-x64.exe
        if ($LASTEXITCODE) { throw "El instalador no pasó la verificación de firma y sello de tiempo." }
    }
} finally { Pop-Location }
