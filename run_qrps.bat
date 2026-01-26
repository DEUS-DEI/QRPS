@echo off
setlocal enabledelayedexpansion

:: ==========================================================
:: qrps - Lanzador Fácil para PowerShell
:: ==========================================================

title qrps - Generador de QR

echo.
echo  ==========================================================
echo     qrps: Motor Nativo de Codigos QR para PowerShell
echo  ==========================================================
echo.

:: Verificar si existe el script principal
if not exist "QRCode.ps1" (
    echo [ERROR] No se encuentra el archivo QRCode.ps1 en este directorio.
    echo Asegurate de ejecutar este .bat desde la carpeta raiz del proyecto.
    pause
    exit /b 1
)

:: Menu de opciones
echo  1. Ejecutar procesamiento por lotes (config.ini / lista_inputs.tsv)
echo  2. Generar un QR rapido (Ingresar texto manualmente)
echo  3. Decodificar un archivo (PNG/SVG)
echo  4. Salir
echo.

set /p choice="Selecciona una opcion (1-4): "

if "%choice%"=="1" (
    echo.
    echo [INFO] Iniciando procesamiento por lotes...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\QRCode.ps1"
    goto end
)

if "%choice%"=="2" (
    echo.
    set /p qrdata="Ingresa el texto o URL para el QR: "
    set /p qrname="Ingresa el nombre del archivo (ej: mi_codigo.png): "
    echo.
    echo [INFO] Generando QR...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\QRCode.ps1" -Data "!qrdata!" -OutputPath "!qrname!"
    goto end
)

if "%choice%"=="3" (
    echo.
    set /p decodePath="Arrastra el archivo o ingresa la ruta (PNG/SVG): "
    echo.
    echo [INFO] Decodificando...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\QRCode.ps1" -Decode -InputPath "!decodePath!"
    goto end
)

if "%choice%"=="4" exit /b 0

:end
echo.
echo [OK] Proceso finalizado.
echo.
pause
