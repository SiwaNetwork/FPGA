@echo off
REM Скрипт для открытия проекта TimeCard_Production в Vivado и компиляции

set PROJECT_DIR=%~dp0
set PROJECT_PATH=%PROJECT_DIR%TimeCard\TimeCard.xpr
set SCRIPT_PATH=%PROJECT_DIR%CreateBinaries.tcl

echo ============================================
echo TimeCard_Production Build Script
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

echo Opening project in Vivado...
echo Vivado path: %VIVADO_PATH%
echo.
echo After Vivado opens, run this command in TCL console:
echo   source %SCRIPT_PATH%
echo.
echo Or use menu: Tools =^> Run Tcl Script... =^> Select CreateBinaries.tcl
echo.

REM Открыть проект в Vivado GUI
"%VIVADO_PATH%" %PROJECT_PATH%

pause
