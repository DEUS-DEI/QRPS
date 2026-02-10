@echo off
setlocal enabledelayedexpansion

:: ==========================================================
:: qrps - Lanzador Fácil para PowerShell
:: ==========================================================

title qrps - Generador de QR

:main_menu
cls
echo.
echo  ==========================================================
echo     qrps: Motor Nativo de Codigos QR para PowerShell
echo  ==========================================================
echo.
echo  1. Ejecutar procesamiento por lotes (config.ini / lista_inputs.tsv)
echo  2. Generar un QR rapido (Modo Interactivo)
echo  3. Decodificar un archivo (PNG/SVG)
echo  4. Salir
echo.

set /p choice="Selecciona una opcion (1-4): "

if "%choice%"=="1" goto batch_mode
if "%choice%"=="2" goto quick_qr
if "%choice%"=="3" goto decode_mode
if "%choice%"=="4" exit /b 0
goto main_menu

:batch_mode
echo.
echo [INFO] Iniciando procesamiento por lotes...
echo Se usaran los valores de config.ini a menos que se indiquen overrides.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\QRCBScript.ps1"
pause
goto main_menu

:quick_qr
echo.
echo --- CONFIGURACION BASICA ---
set /p qrdata="[1/8] Ingresa el texto o URL para el QR: "
set /p qrname="[2/8] Nombre del archivo (ej: out.pdf, out.svg, out.png): "

echo.
echo --- PERSONALIZACION (Presiona Enter para valores por defecto) ---
set /p qrlogo="[3/8] Ruta del logo (SVG/PNG) o Enter: "
set qrscale=20
if not "!qrlogo!"=="" (
    set /p qrscale="[4/8] Escala del logo (1-30, default 20): "
)

set /p qrcolor="[5/8] Color principal (HEX, ej #0000FF para azul) o Enter: "
set /p qrrounded="[6/8] Redondeado (0 a 0.5, ej 0.3) o Enter: "
set /p qrtext="[7/8] Texto inferior (ej: Escaneame) o Enter: "
set /p qrframe="[8/8] Texto en MARCO superior o Enter: "

echo.
echo [INFO] Generando QR...

:: Construir comando dinámicamente
set ps_cmd=powershell -ExecutionPolicy Bypass -File QRCode.ps1 -Data "!qrdata!" -OutputPath "!qrname!"

if not "!qrlogo!"=="" set ps_cmd=!ps_cmd! -LogoPath "!qrlogo!" -LogoScale !qrscale!
if not "!qrcolor!"=="" set ps_cmd=!ps_cmd! -ForegroundColor "!qrcolor!"
if not "!qrrounded!"=="" set ps_cmd=!ps_cmd! -Rounded !qrrounded!
if not "!qrtext!"=="" set ps_cmd=!ps_cmd! -BottomText "!qrtext!"
if not "!qrframe!"=="" set ps_cmd=!ps_cmd! -FrameText "!qrframe!"

!ps_cmd!

echo.
echo [OK] Proceso finalizado.
pause
goto main_menu

:decode_mode
echo.
set /p decodePath="Arrastra el archivo o ingresa la ruta (PNG/SVG): "
echo.
echo [INFO] Decodificando...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\QRCBScript.ps1" -Decode -InputPath "!decodePath!"
pause
goto main_menu
