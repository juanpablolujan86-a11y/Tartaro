[Setup]
AppId=TartaroGuildDesktop
AppName=Tártaro
AppVersion=0.2.0
DefaultDirName={localappdata}\Programs\Tartaro
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DefaultGroupName=Tártaro
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename=Tartaro-Setup-Windows-x64
SetupIconFile=Tartaro.ico
UninstallDisplayIcon={app}\Tartaro.exe
AppMutex=Local\Tartaro.Instalador.Tray
WizardStyle=modern
Compression=lzma2

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "startup"; Description: "Iniciar Tártaro junto al reloj al entrar en Windows"

[Files]
Source: "Tartaro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "tartaro-installer.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{userprograms}\Tártaro"; Filename: "{app}\Tartaro.exe"
Name: "{userstartup}\Tártaro"; Filename: "{app}\Tartaro.exe"; Parameters: "--background"; Tasks: startup

[Run]
Filename: "{app}\Tartaro.exe"; Description: "Abrir Tártaro"; Flags: nowait postinstall skipifsilent
