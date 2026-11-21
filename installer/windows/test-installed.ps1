# Runs on an isolated Windows CI account after installing the actual Setup.
param([Parameter(Mandatory)][string]$AppDir, [switch]$Desktop)
$ErrorActionPreference = 'Stop'

$work = Join-Path ([IO.Path]::GetTempPath()) ("tartaro-tray-test-" + [guid]::NewGuid().ToString("N"))
$game = Join-Path $work 'TartaroTest/_forever_/Interface/AddOns'
$addon = New-Item -ItemType Directory -Force (Join-Path $game Tartaro)
Set-Content (Join-Path $addon.FullName 'Tartaro.toc') '## Version: 0.0.1'
$config = Join-Path $work 'config'
New-Item -ItemType Directory -Force $config | Out-Null
$env:TARTARO_INSTALLER_CONFIG_DIR = $config
$file = Join-Path $config config.json
$bytes = [Text.Encoding]::UTF8.GetBytes((@{folder=$game;automatic=$true}|ConvertTo-Json))
$stream = [IO.File]::Open($file,[IO.FileMode]::CreateNew)
try { $stream.Write($bytes,0,$bytes.Length) } finally { $stream.Dispose() }
$launcher = Join-Path $AppDir Tartaro.exe
$core = Join-Path $AppDir tartaro-installer.exe
try {
    $resident = Start-Process $launcher -ArgumentList '--background' -PassThru
    $deadline = [DateTime]::UtcNow.AddSeconds(110)
    while (!(Test-Path (Join-Path $addon.FullName 'Core.lua'))) {
        if ($resident.HasExited -or [DateTime]::UtcNow -gt $deadline) { throw 'Falló la actualización sin ventana.' }
        Start-Sleep -Milliseconds 400
    }
    if (!$Desktop) { return }
    foreach ($attempt in 1..2) {
        $duplicate = Start-Process $launcher -PassThru
        if (!$duplicate.WaitForExit(10000)) { throw 'Se abrió otro residente.' }
        $deadline = [DateTime]::UtcNow.AddSeconds(20)
        do {
            Start-Sleep -Milliseconds 250
            $window = Get-Process 'tartaro-installer' -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $core -and $_.MainWindowTitle }
        } until ($window -or [DateTime]::UtcNow -gt $deadline)
        if (!$window -or !$window.CloseMainWindow() -or !$window.WaitForExit(10000)) { throw 'Falló el ciclo abrir/cerrar de la interfaz.' }
        if ($resident.HasExited) { throw 'La X cerró el residente.' }
    }
} finally {
    if ($resident -and !$resident.HasExited) { $resident.Kill(); $resident.WaitForExit() }
    Get-Process 'tartaro-installer' -ErrorAction SilentlyContinue | Where-Object Path -eq $core | Stop-Process
    Remove-Item -LiteralPath $file
}
