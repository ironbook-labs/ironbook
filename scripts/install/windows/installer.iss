[Setup]
AppName=IronBook
AppVersion=0.1.3-alpha
AppPublisher=Abled-Taha
DefaultDirName={localappdata}\Programs\IronBook
DefaultGroupName=IronBook
DisableProgramGroupPage=yes
OutputBaseFilename=IronBook-Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=lowest
UninstallDisplayIcon={app}\ironbook.exe

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Types]
Name: "stable"; Description: "Stable Release"
Name: "prerelease"; Description: "Pre-Release (Latest)"

[Components]
Name: "stable"; Description: "Install Stable Release"; Types: stable; Flags: exclusive
Name: "prerelease"; Description: "Install Pre-Release"; Types: prerelease; Flags: exclusive

[Code]
var
  InstallChannel: String;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  PowerShellPath: String;
  ScriptPath: String;
  Params: String;
begin
  if CurStep = ssInstall then
  begin
    // Determine user channel selection from component choices
    if WizardIsComponentSelected('prerelease') then
      InstallChannel := 'prerelease'
    else
      InstallChannel := 'stable';

    PowerShellPath := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');
    ScriptPath := ExpandConstant('{tmp}\fetch_and_install.ps1');

    // Extract embedded PowerShell script to temporary directory
    ExtractTemporaryFile('fetch_and_install.ps1');

    // Execute PowerShell script silently
    Params := Format('-NoProfile -ExecutionPolicy Bypass -File "%s" -TargetDir "%s" -Channel "%s"', [
      ScriptPath,
      ExpandConstant('{app}'),
      InstallChannel
    ]);

    WizardForm.StatusLabel.Caption := 'Fetching and verifying latest Iron Book assets...';

    if not Exec(PowerShellPath, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) or (ResultCode <> 0) then
    begin
      RaiseException('Failed to download or verify Iron Book release assets. Check your network connection.');
    end;
  end;
end;

[Files]
Source: "fetch_and_install.ps1"; DestDir: "{tmp}"; Flags: ignoreversion deleteafterinstall

[Icons]
Name: "{group}\IronBook"; Filename: "{app}\ironbook.exe"; WorkingDir: "{app}"
Name: "{userdesktop}\IronBook"; Filename: "{app}\ironbook.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
