@echo off
:: install.bat - Copilot Prompts & Instructions Installation Script (Windows)
::
:: Creates directory junctions to prompts and instructions in your project.
::
:: Usage:
::   install.bat <path>              # Install junctions to target project
::   install.bat --uninstall <path>  # Remove junctions
::   install.bat --force <path>      # Overwrite existing directories

setlocal enabledelayedexpansion

:: Get script directory (remove trailing backslash)
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Default values
set "MODE=install"
set "PROJECT_PATH="
set "FORCE=0"
set "DRY_RUN=0"

:: Parse arguments
:parse_args
if "%~1"=="" goto :done_args
if /i "%~1"=="--uninstall" (set "MODE=uninstall" & shift & goto :parse_args)
if /i "%~1"=="--force" (set "FORCE=1" & shift & goto :parse_args)
if /i "%~1"=="-f" (set "FORCE=1" & shift & goto :parse_args)
if /i "%~1"=="--dry-run" (set "DRY_RUN=1" & shift & goto :parse_args)
if /i "%~1"=="-n" (set "DRY_RUN=1" & shift & goto :parse_args)
if /i "%~1"=="--help" (call :show_help & exit /b 0)
if /i "%~1"=="-h" (call :show_help & exit /b 0)
if "%~1:~0,1%"=="-" (
    echo [ERROR] Unknown option: %~1
    call :show_help
    exit /b 1
)
set "PROJECT_PATH=%~1"
shift
goto :parse_args
:done_args

:: Require project path
if "%PROJECT_PATH%"=="" (
    echo [ERROR] Missing required argument: PATH
    echo.
    call :show_help
    exit /b 1
)

:: Remove trailing backslash from project path if present
if "%PROJECT_PATH:~-1%"=="\" set "PROJECT_PATH=%PROJECT_PATH:~0,-1%"

echo.
echo [INFO] Copilot Prompts ^& Instructions Installer
if "%DRY_RUN%"=="1" echo [WARN] DRY RUN MODE - No changes will be made
echo.

:: Main logic
if "%MODE%"=="install" call :install
if "%MODE%"=="uninstall" call :uninstall

echo.
echo [OK] Done!
exit /b 0

::######################################
:: Show help
::######################################
:show_help
echo Copilot Prompts ^& Instructions Installation Script (Windows)
echo.
echo Creates directory junctions to GitHub Copilot prompts and instructions in your project.
echo.
echo Usage: install.bat ^<PATH^> [OPTIONS]
echo.
echo Arguments:
echo   PATH                  Target project directory (required)
echo.
echo Options:
echo   --uninstall           Remove installed junctions
echo   --force, -f           Overwrite existing directories (default: skip)
echo   --dry-run, -n         Preview changes without making them
echo   --help, -h            Show this help message
echo.
echo Examples:
echo   install.bat C:\Projects\my-app             # Install to specified project
echo   install.bat C:\Projects\my-app --dry-run   # Preview what would be installed
echo   install.bat C:\Projects\my-app --force     # Force overwrite existing
echo   install.bat --uninstall C:\Projects\my-app # Remove junctions
echo.
echo Note: Uses directory junctions (no admin required). Source and target
echo       must be on the same drive.
echo.
echo After Installation:
echo   Copilot prompts: @workspace /global/review, /global/test, etc.
echo   Instructions apply automatically based on file type (*.c, *.py, *.sh, etc.)
exit /b 0

::######################################
:: Create junction
::######################################
:create_junction
set "SRC=%~1"
set "DEST=%~2"

:: Check if destination exists
if exist "%DEST%" (
    if "%FORCE%"=="0" (
        echo [WARN] Skipping %DEST% (exists, use --force to overwrite)
        exit /b 0
    )
    if "%DRY_RUN%"=="1" (
        echo [DRY-RUN] Would remove: %DEST%
    ) else (
        rmdir "%DEST%" 2>nul
        if exist "%DEST%" rd /s /q "%DEST%"
    )
)

if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would create junction: %DEST% -^> %SRC%
    exit /b 0
)

:: Ensure parent directory exists
for %%i in ("%DEST%") do set "PARENT_DIR=%%~dpi"
if not exist "%PARENT_DIR%" mkdir "%PARENT_DIR%"

:: Create junction
mklink /J "%DEST%" "%SRC%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to create junction: %DEST%
    exit /b 1
)
echo [OK] Linked %DEST%
exit /b 0

::######################################
:: Install
::######################################
:install
set "TARGET=%PROJECT_PATH%"

if not exist "%TARGET%" (
    echo [ERROR] Project directory not found: %TARGET%
    exit /b 1
)

echo [INFO] Installing Copilot prompts and instructions to %TARGET%

:: Create junctions
call :create_junction "%SCRIPT_DIR%\.github\prompts" "%TARGET%\.github\prompts\global"
call :create_junction "%SCRIPT_DIR%\.github\instructions" "%TARGET%\.github\instructions\global"

echo [OK] Installation complete
echo.
echo [INFO] Usage: In VS Code Copilot Chat, use /global/review, /global/test, etc.
exit /b 0

::######################################
:: Uninstall
::######################################
:uninstall
set "TARGET=%PROJECT_PATH%"

echo [INFO] Uninstalling Copilot configs from %TARGET%

set "FOUND=0"

:: Remove prompts junction
if exist "%TARGET%\.github\prompts\global" (
    if "%DRY_RUN%"=="1" (
        echo [DRY-RUN] Would remove: %TARGET%\.github\prompts\global
    ) else (
        rmdir "%TARGET%\.github\prompts\global" 2>nul
    )
    echo [OK] Removed .github\prompts\global
    set "FOUND=1"
)

:: Remove instructions junction
if exist "%TARGET%\.github\instructions\global" (
    if "%DRY_RUN%"=="1" (
        echo [DRY-RUN] Would remove: %TARGET%\.github\instructions\global
    ) else (
        rmdir "%TARGET%\.github\instructions\global" 2>nul
    )
    echo [OK] Removed .github\instructions\global
    set "FOUND=1"
)

if "%FOUND%"=="0" echo [INFO] No installation found in %TARGET%
exit /b 0
