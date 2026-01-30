@echo off
:: install.bat - Copilot Prompts, Instructions & Hooks Installation Script (Windows)
::
:: Creates symlinks to prompts, instructions, and hooks in your project.
::
:: Usage:
::   install.bat <path>              # Install symlinks to target project
::   install.bat --uninstall <path>  # Remove symlinks
::   install.bat --force <path>      # Overwrite existing files

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
echo Copilot Prompts, Instructions ^& Hooks Installation Script (Windows)
echo.
echo Creates symlinks to GitHub Copilot prompts, instructions, and hooks in your project.
echo.
echo Usage: install.bat ^<PATH^> [OPTIONS]
echo.
echo Arguments:
echo   PATH                  Target project directory (required)
echo.
echo Options:
echo   --uninstall           Remove installed symlinks
echo   --force, -f           Overwrite existing files (default: skip with warning)
echo   --dry-run, -n         Preview changes without making them
echo   --help, -h            Show this help message
echo.
echo Examples:
echo   install.bat C:\Projects\my-app             # Install to specified project
echo   install.bat C:\Projects\my-app --dry-run   # Preview what would be installed
echo   install.bat C:\Projects\my-app --force     # Force overwrite existing
echo   install.bat --uninstall C:\Projects\my-app # Remove symlinks
echo.
echo Note: Requires Developer Mode enabled (Windows 10+) or admin privileges
echo       for creating file symlinks.
echo.
echo After Installation:
echo   Copilot prompts: @workspace /review, /test, etc.
echo   Instructions apply automatically based on file type (*.c, *.py, *.sh, etc.)
exit /b 0

::######################################
:: Create file symlink
::######################################
:create_symlink
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
        del "%DEST%" 2>nul
    )
)

if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would create symlink: %DEST% -^> %SRC%
    exit /b 0
)

:: Ensure parent directory exists
for %%i in ("%DEST%") do set "PARENT_DIR=%%~dpi"
if not exist "%PARENT_DIR%" mkdir "%PARENT_DIR%"

:: Create file symlink (requires Developer Mode or admin)
mklink "%DEST%" "%SRC%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to create symlink: %DEST%
    echo         Make sure Developer Mode is enabled or run as Administrator
    exit /b 1
)
echo [OK] Linked %DEST%
exit /b 0

::######################################
:: Add git excludes
::######################################
:add_git_excludes
set "EXCLUDE_FILE=%PROJECT_PATH%\.git\info\exclude"

:: Skip if not a git repo
if not exist "%PROJECT_PATH%\.git" exit /b 0

:: Skip if already has our marker
findstr /C:"dev-ai installed" "%EXCLUDE_FILE%" >nul 2>&1 && exit /b 0

if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would add exclusions to %EXCLUDE_FILE%
    exit /b 0
)

:: Append our exclusions
echo.>> "%EXCLUDE_FILE%"
echo # dev-ai installed prompts/instructions/hooks>> "%EXCLUDE_FILE%"
echo .github/prompts/*.prompt.md>> "%EXCLUDE_FILE%"
echo .github/instructions/*.instructions.md>> "%EXCLUDE_FILE%"
echo .github/hooks/*.json>> "%EXCLUDE_FILE%"
echo .github/hooks/scripts/>> "%EXCLUDE_FILE%"

echo [OK] Added git exclusions (files hidden from git status)
exit /b 0

::######################################
:: Remove git excludes
::######################################
:remove_git_excludes
set "EXCLUDE_FILE=%PROJECT_PATH%\.git\info\exclude"

:: Skip if exclude file doesn't exist
if not exist "%EXCLUDE_FILE%" exit /b 0

:: Skip if our marker is not present
findstr /C:"dev-ai installed" "%EXCLUDE_FILE%" >nul 2>&1 || exit /b 0

if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would remove exclusions from %EXCLUDE_FILE%
    exit /b 0
)

:: Create temp file without our section
set "TEMP_FILE=%EXCLUDE_FILE%.tmp"
set "SKIP_LINES=0"
(
    for /f "usebackq delims=" %%a in ("%EXCLUDE_FILE%") do (
        if "%%a"=="# dev-ai installed prompts/instructions/hooks" (
            set "SKIP_LINES=4"
        ) else if !SKIP_LINES! gtr 0 (
            set /a "SKIP_LINES=!SKIP_LINES!-1"
        ) else (
            echo %%a
        )
    )
) > "%TEMP_FILE%"

:: Replace original with temp (remove trailing blank line if present)
move /y "%TEMP_FILE%" "%EXCLUDE_FILE%" >nul

echo [OK] Removed git exclusions
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

:: Ensure target directories exist
if not "%DRY_RUN%"=="1" (
    if not exist "%TARGET%\.github\prompts" mkdir "%TARGET%\.github\prompts"
    if not exist "%TARGET%\.github\instructions" mkdir "%TARGET%\.github\instructions"
)

:: Symlink each prompt file
for %%f in ("%SCRIPT_DIR%\.github\prompts\*.prompt.md") do (
    call :create_symlink "%%f" "%TARGET%\.github\prompts\%%~nxf"
)

:: Symlink each instruction file
for %%f in ("%SCRIPT_DIR%\.github\instructions\*.instructions.md") do (
    call :create_symlink "%%f" "%TARGET%\.github\instructions\%%~nxf"
)

:: Symlink hook config files
if not "%DRY_RUN%"=="1" (
    if not exist "%TARGET%\.github\hooks" mkdir "%TARGET%\.github\hooks"
)
for %%f in ("%SCRIPT_DIR%\.github\hooks\*.json") do (
    call :create_symlink "%%f" "%TARGET%\.github\hooks\%%~nxf"
)

:: Symlink hook scripts
if not "%DRY_RUN%"=="1" (
    if not exist "%TARGET%\.github\hooks\scripts" mkdir "%TARGET%\.github\hooks\scripts"
)
for %%f in ("%SCRIPT_DIR%\.github\hooks\scripts\*") do (
    call :create_symlink "%%f" "%TARGET%\.github\hooks\scripts\%%~nxf"
)

:: Add git excludes to hide symlinked files from git status
call :add_git_excludes

echo [OK] Installation complete
echo.
echo [INFO] Usage: In VS Code Copilot Chat, use /review, /test, etc.
exit /b 0

::######################################
:: Uninstall
::######################################
:uninstall
set "TARGET=%PROJECT_PATH%"

echo [INFO] Uninstalling Copilot configs from %TARGET%

set "FOUND=0"

:: Remove prompt symlinks that correspond to files in this repo
if exist "%TARGET%\.github\prompts" (
    for %%f in ("%SCRIPT_DIR%\.github\prompts\*.prompt.md") do (
        set "TARGET_FILE=%TARGET%\.github\prompts\%%~nxf"
        call :remove_if_symlink "!TARGET_FILE!"
    )
)

:: Remove instruction symlinks that correspond to files in this repo
if exist "%TARGET%\.github\instructions" (
    for %%f in ("%SCRIPT_DIR%\.github\instructions\*.instructions.md") do (
        set "TARGET_FILE=%TARGET%\.github\instructions\%%~nxf"
        call :remove_if_symlink "!TARGET_FILE!"
    )
)

:: Remove hook config symlinks that correspond to files in this repo
if exist "%TARGET%\.github\hooks" (
    for %%f in ("%SCRIPT_DIR%\.github\hooks\*.json") do (
        set "TARGET_FILE=%TARGET%\.github\hooks\%%~nxf"
        call :remove_if_symlink "!TARGET_FILE!"
    )
)

:: Remove hook script symlinks that correspond to files in this repo
if exist "%TARGET%\.github\hooks\scripts" (
    for %%f in ("%SCRIPT_DIR%\.github\hooks\scripts\*") do (
        set "TARGET_FILE=%TARGET%\.github\hooks\scripts\%%~nxf"
        call :remove_if_symlink "!TARGET_FILE!"
    )
)

:: Also remove old-style global directory junctions if present (migration)
if exist "%TARGET%\.github\prompts\global" (
    if "%DRY_RUN%"=="1" (
        echo [DRY-RUN] Would remove: %TARGET%\.github\prompts\global (old-style)
    ) else (
        rmdir "%TARGET%\.github\prompts\global" 2>nul
    )
    echo [OK] Removed .github\prompts\global (old-style)
    set "FOUND=1"
)

if exist "%TARGET%\.github\instructions\global" (
    if "%DRY_RUN%"=="1" (
        echo [DRY-RUN] Would remove: %TARGET%\.github\instructions\global (old-style)
    ) else (
        rmdir "%TARGET%\.github\instructions\global" 2>nul
    )
    echo [OK] Removed .github\instructions\global (old-style)
    set "FOUND=1"
)

:: Remove git excludes
call :remove_git_excludes

if "%FOUND%"=="0" echo [INFO] No installation found in %TARGET%
exit /b 0

::######################################
:: Remove file if it's a symlink
::######################################
:remove_if_symlink
set "FILE_PATH=%~1"

:: Check if file exists and is a symlink (has reparse point attribute)
if not exist "%FILE_PATH%" exit /b 0

:: Use dir to check for SYMLINK attribute
dir /AL "%FILE_PATH%" >nul 2>&1
if errorlevel 1 exit /b 0

:: It's a symlink, remove it
if "%DRY_RUN%"=="1" (
    echo [DRY-RUN] Would remove: %FILE_PATH%
) else (
    del "%FILE_PATH%" 2>nul
)

for %%i in ("%FILE_PATH%") do echo [OK] Removed %%~nxi
set "FOUND=1"
exit /b 0
