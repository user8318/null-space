@echo off
setlocal DisableDelayedExpansion

set "SPACE_DIR=%~dp0"
if "%SPACE_DIR:~3,1%"=="" (
    set "SPACE_DIR=%SPACE_DIR%."
) else (
    set "SPACE_DIR=%SPACE_DIR:~0,-1%"
)

reg.exe add "HKCU\Environment" /v space_path /t REG_SZ /d "%SPACE_DIR%" /f >nul 2>&1
if errorlevel 1 exit /b 1

set "USER_PATH="
for /f "tokens=1,2,*" %%A in ('reg.exe query "HKCU\Environment" /v Path 2^>nul') do if /i "%%A"=="Path" set "USER_PATH=%%C"

reg.exe query "HKCU\Environment" /v Path 2>nul | findstr.exe /i /c:"%%space_path%%" >nul
if errorlevel 1 (
    if defined USER_PATH (
        reg.exe add "HKCU\Environment" /v Path /t REG_EXPAND_SZ /d "%USER_PATH%;%%space_path%%" /f >nul 2>&1
    ) else (
        reg.exe add "HKCU\Environment" /v Path /t REG_EXPAND_SZ /d "%%space_path%%" /f >nul 2>&1
    )
    if errorlevel 1 exit /b 1
)

rundll32.exe user32.dll,UpdatePerUserSystemParameters >nul 2>&1

attrib.exe +s +h "%SPACE_DIR%\*" /d >nul 2>&1
if errorlevel 1 exit /b 1
attrib.exe +s +h "%SPACE_DIR%" >nul 2>&1
if errorlevel 1 exit /b 1

exit /b 0
