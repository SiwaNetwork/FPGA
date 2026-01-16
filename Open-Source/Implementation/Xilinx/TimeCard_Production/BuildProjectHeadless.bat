@echo off
REM Скрипт для компиляции проекта TimeCard_Production в headless режиме (без GUI)

set PROJECT_DIR=%~dp0
set PROJECT_PATH=%PROJECT_DIR%TimeCard\TimeCard.xpr
set SCRIPT_PATH=%PROJECT_DIR%CreateBinariesStandalone.tcl

echo ============================================
echo TimeCard_Production Build Script (Headless)
echo ============================================
echo.
echo Project path: %PROJECT_PATH%
echo Script path: %SCRIPT_PATH%
echo.

REM Путь к Vivado
set VIVADO_PATH=C:\Xilinx\Vivado\2019.1\bin\vivado.bat
if not exist "%VIVADO_PATH%" (
    set VIVADO_PATH=C:\Xilinx\Vivado\2019.1\bin\vivado.exe
)
if not exist "%VIVADO_PATH%" (
    REM Попробовать найти через PATH
    where vivado >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Vivado not found!
        echo Expected path: C:\Xilinx\Vivado\2019.1\bin\vivado.bat
        echo Please check Vivado installation or update VIVADO_PATH in this script
        pause
        exit /b 1
    )
    set VIVADO_PATH=vivado
)

echo Starting compilation...
echo Vivado path: %VIVADO_PATH%
echo This may take a long time (30-60 minutes or more)...
echo.

REM Запустить компиляцию в headless режиме
"%VIVADO_PATH%" -mode batch -source %SCRIPT_PATH% -log build.log

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo Build completed successfully!
    echo ============================================
    echo.
    echo Binaries location: %PROJECT_DIR%Binaries\
    echo.
) else (
    echo.
    echo ============================================
    echo Build failed! Check build.log for details
    echo ============================================
    echo.
)

pause
