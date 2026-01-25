# 🔳 Generador de Códigos QR Nativo (PowerShell)

Este script proporciona una implementación **100% nativa en PowerShell** del estándar **ISO/IEC 18004** para la generación de códigos QR de alta fidelidad. Sin dependencias externas, permite generar imágenes profesionales listas para su uso industrial o comercial.

## ⚙️ Requisitos

- **PowerShell 7.x (Core)** - Recomendado para mejor compatibilidad
- **Windows 10/11** (o PowerShell Core en macOS/Linux)
- **Acceso a System.Drawing** para exportación PNG

### Instalación de PowerShell 7
Si aún tienes PowerShell 5.1, instala PowerShell 7 (Core):

```powershell
# Opción 1: Con winget (Windows 11/10 con winget)
winget install Microsoft.PowerShell

# Opción 2: Descargar desde
# https://github.com/PowerShell/PowerShell/releases

# Verificar la instalación
pwsh -Version
```

## ✨ Características Principales

*   **Simbología Estándar:** Soporte para **QR Modelo 2** (Versiones 1 a 40) y **Modelo 1** (Versiones 1 a 14).
*   **Segmentación Inteligente:** Motor dinámico que optimiza automáticamente el tamaño del código alternando entre modos:
    *   🔢 **Numérico:** Máxima densidad para cifras.
    *   🔠 **Alfanumérico:** Para texto simple y símbolos comunes.
    *   🌐 **Byte (UTF-8):** Compatibilidad universal para tildes, eñes y caracteres especiales.
*   **ECI (Extended Channel Interpretation):** Inserción automática de ECI 26 para que los escáneres identifiquen correctamente los datos en UTF-8.
*   **Kanji (Shift-JIS):** Selección automática de segmentos para caracteres japoneses.
*   **Micro QR:** Soporte para versiones M1-M4 en PowerShell puro.
*   **Structured Append:** Soporte para Modo 3 con encabezado por símbolo.
*   **FNC1 / GS1:** Soporte para modos 5 y 9 con Application Indicator.
*   **Corrección de Errores (ECC):** Soporte total para niveles **L, M, Q y H**, garantizando legibilidad incluso en superficies dañadas.
*   **Exportación Directa:** Genera archivos **PNG** nítidos con control total sobre el tamaño del módulo y bordes (quiet zone).

---

## 🚀 Guía de Inicio Rápido

### Ejecución con PowerShell 7
Para ejecutar con PowerShell 7 explícitamente:

```powershell
# Opción 1: Llamar directamente a pwsh (si está en PATH)
pwsh -NoProfile -File ".\QRCode.ps1" -Data "Hola mundo" -OutputPath "demo.png"

# Opción 2: Ruta completa
C:\Users\[USERNAME]\AppData\Local\Microsoft\WindowsApps\pwsh.exe -NoProfile .\QRCode.ps1
```

### Uso Directo por CLI
```powershell
# Generar un código simple
.\QRCode.ps1 -Data "Hola mundo" -OutputPath "demo.png"

# Con personalización avanzada
.\QRCode.ps1 -Data "Mi Texto" -ECLevel "H" -ModuleSize 15 -OutputPath "personalizado.png"

# Modelo 1 (Versiones 1-14)
.\QRCode.ps1 -Data "Modelo 1" -Model "M1" -Version 4 -OutputPath "model1.png"

# FNC1 GS1 (modo primera posición)
.\QRCode.ps1 -Data "01012345678901281724010110ABC" -Fnc1First -OutputPath "gs1.png"

# Structured Append (símbolo 1 de 2)
.\\QRCode.ps1 -Data "Parte A" -StructuredAppendTotal 2 -StructuredAppendIndex 0 -StructuredAppendParityData "Parte A|Parte B" -OutputPath "sa_1.png"

# Micro QR (auto)
.\\QRCode.ps1 -Data "Micro" -Symbol "Micro" -MicroVersion "AUTO" -OutputPath "micro.png"
```

### Procesamiento por Lotes (Batch)
El script puede procesar múltiples entradas automáticamente:
1.  Configura tus preferencias en `config.ini`.
2.  Agrega los textos que deseas convertir en `lista_inputs.tsv`.
3.  Ejecuta el script sin parámetros:
    ```powershell
    .\QRCode.ps1
    ```

---

## 🛠️ Configuración (`config.ini`)

| Opción | Descripción |
| :--- | :--- |
| `ArchivoEntrada` | Ruta al archivo con los textos a procesar. |
| `CarpetaSalida` | Directorio donde se guardarán las imágenes. |
| `NivelEC` | Nivel de recuperación (L, M, Q, H). |
| `TamanoModulo` | Tamaño en píxeles de cada cuadro (punto) del QR. |
| `Version` | Versión fija (1-40) o `0` para automático. |
| `ECI` | ID de interpretación de canal (ej: 26 para UTF-8). |

---

## 📋 Formato de Entrada (`lista_inputs.tsv`)

El archivo puede contener columnas separadas por tabulación. El script usa la columna indicada en `IndiceColumna` para obtener el dato a codificar y puede ignorar columnas extra usadas como referencia.

```text
https://www.google.com	URL	Modelo2-Auto	.\QRCode.ps1 -Data "https://www.google.com" -OutputPath "qr_url.png"
1234567890	NUMERICO	EC-L	.\QRCode.ps1 -Data "1234567890" -ECLevel "L" -OutputPath "qr_ec_l.png"
BEGIN:VCARD...END:VCARD	VCARD	Modelo2-Auto	.\QRCode.ps1 -Data "BEGIN:VCARD...END:VCARD" -OutputPath "qr_vcard.png"
01012345678901281724010110ABC	GS1	Modelo2-FNC1	.\QRCode.ps1 -Data "01012345678901281724010110ABC" -Fnc1First -OutputPath "qr_gs1.png"
```

---

## ⚙️ Requisitos
*   **Windows PowerShell 5.1** o superior.
*   No requiere privilegios de administrador para la mayoría de las operaciones.
