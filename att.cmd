@echo off

fltmc >nul 2>&1
if errorlevel 1 (
    set "SCRIPT_PATH=%~f0"
    powershell -NoProfile -Command "$a = '/d /c ' + [char]34 + $env:SCRIPT_PATH + [char]34; try { $p = Start-Process -FilePath $env:ComSpec -ArgumentList $a -Verb RunAs -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop; exit $p.ExitCode } catch { exit 1 }" >nul 2>&1
    exit /b
)

set "SPACE_NAME=space.vhdx"
set "RAW_NAME=space.raw"
set "SPACE_FILE=%~dp0%SPACE_NAME%"
set "RAW_FILE=%~dp0%RAW_NAME%"

powershell -NoProfile -NonInteractive -Command "$ErrorActionPreference = 'Stop'; try { if (Test-Path -LiteralPath $env:RAW_FILE) { if (Test-Path -LiteralPath $env:SPACE_FILE) { exit 1 }; Move-Item -LiteralPath $env:RAW_FILE -Destination $env:SPACE_FILE -ErrorAction Stop }; if (-not (Test-Path -LiteralPath $env:SPACE_FILE)) { exit 1 }; $image = Get-DiskImage -ImagePath $env:SPACE_FILE -ErrorAction Stop; if (-not $image.Attached) { Mount-DiskImage -ImagePath $env:SPACE_FILE -ErrorAction Stop | Out-Null }; for ($i = 0; $i -lt 10; $i++) { if ((Get-DiskImage -ImagePath $env:SPACE_FILE -ErrorAction Stop).Attached) { exit 0 }; Start-Sleep -Milliseconds 500 }; exit 1 } catch { exit 1 }" >nul 2>&1
exit /b %errorlevel%
