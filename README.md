# 🔳 qrps: Motor Nativo de Códigos QR para PowerShell

`qrps` es una implementación **100% nativa en PowerShell** de los estándares internacionales para la generación y decodificación de códigos QR de alta fidelidad. Sin dependencias externas, permite operar en entornos restringidos garantizando cumplimiento normativo.

---

## 📋 Tabla de Contenidos
- [✨ Simbologías y Estándares](#-simbologías-y-estándares)
- [🛠️ Características Técnicas](#️-características-técnicas)
- [🏛️ Cumplimiento Normativo (ISO/IEC)](#️-cumplimiento-normativo-isoiec)
  - [PDF (ISO 14289-1 / PDF/UA-1)](#pdf-iso-14289-1--pdfua-1)
  - [SVG (WCAG 2.1)](#svg-wcag-21)
  - [PNG (ISO/IEC 15948)](#png-isoiec-15948)
- [🚀 Guía de Inicio Rápido](#-guía-de-inicio-rápido)
  - [Instalación](#instalación)
  - [Ejemplos de Uso](#ejemplos-de-uso)
- [⚙️ Configuración (config.ini)](#️-configuración-configini)
- [📊 Formatos de Datos Soportados](#-formatos-de-datos-soportados)
- [⚖️ Licencia y Patentes](#️-licencia-y-patentes)

---

## ✨ Simbologías y Estándares

| Simbología | Estándar | Estado | Notas |
| :--- | :--- | :---: | :--- |
| **QR Code Modelo 2** | ISO/IEC 18004 | ✅ | Versiones 1-40. Soporte completo. |
| **QR Code Modelo 1** | ISO/IEC 18004:2000 | ✅ | Versiones 1-14. Compatibilidad histórica. |
| **Micro QR Code** | ISO/IEC 18004 Anexo E | ✅ | Versiones M1-M4 para espacios reducidos. |
| **rMQR (Rectangular)** | ISO/IEC 18004:2024 | ✅ | Implementación completa (2024). 27 versiones. |
| **GS1 QR Code** | GS1 General Spec | ✅ | Soporte FNC1 y Application Identifiers. |
| **Structured Append** | ISO/IEC 18004 | ✅ | División de datos en hasta 16 símbolos. |
| **Decoding Engine** | ISO/IEC 18004 | ✅ | Decodificación nativa QR/Micro/rMQR. |

---

## 🛠️ Características Técnicas

- **Segmentación Inteligente**: Alterna automáticamente entre modos Numérico, Alfanumérico, Byte (UTF-8) y Kanji (Shift-JIS).
- **Corrección de Errores (ECC)**: Implementación completa de Reed-Solomon (GF 256) niveles L, M, Q, H.
- **Exportación Multi-formato**: Generación simultánea de **PDF, SVG y PNG** en un solo proceso.
- **Personalización Estética**: Soporte para colores sólidos, degradados (lineales/radiales), módulos redondeados y marcos decorativos ("ESCANEAME").
- **Procesamiento por Lotes**: Motor robusto para procesar archivos **TSV** con mapeo dinámico de columnas y personalización por fila.
- **Incrustación de Logos**: Soporte para logos PNG/JPG/SVG con ajuste automático de nivel de error a **H (High)**.
- **Layouts de Impresión**: Generación de catálogos con rejillas automáticas (Grid 4x4, 4x5, 6x6).

---

## 🏛️ Cumplimiento Normativo (ISO/IEC)

### 📄 PDF (ISO 14289-1 / PDF/UA-1)
Motor binario nativo diseñado para accesibilidad y archivo a largo plazo.
- **Accesibilidad**: Estructura lógica dinámica (`StructTreeRoot`), etiquetas de figura y mapeo `/Pg`.
- **Estándares**: Cumple con **ISO 32000-1 (PDF 1.7)** y **ISO 19005-2 (PDF/A-2b)**.
- **Unicode**: Mapeo CMap (ToUnicode) para extracción de texto garantizada.
- **Optimización**: Diccionario de linealización (Obj 1) para visualización rápida.

### 🎨 SVG (WCAG 2.1)
Generación vectorial limpia basada en XML.
- **Accesibilidad**: Inclusión de tags `title`, `desc`, `role="img"` y `aria-labelledby` según **WCAG 2.1**.
- **Compatibilidad**: Cumple con **W3C SVG 1.1** y soporta **Google Fonts** vía `@import`.
- **Seguridad**: Sin scripts (ECMAScript) para cumplir con políticas CSP.

### 🖼️ PNG (ISO/IEC 15948)
Salida rasterizada de alta compatibilidad.
- **Compresión**: Uso de **ZLIB/Deflate** (RFC 1950/1951) vía .NET.
- **Color**: Espacio de color **sRGB** (IEC 61966-2-1).
- **Consistencia**: Soporte para módulos redondeados (`-Rounded`) normalizado mediante `GraphicsPath`.
- **Limitaciones Técnicas**:
  - **Degradados**: Debido a restricciones de la librería nativa `System.Drawing` en entornos sin dependencias GDI+ avanzadas, el formato PNG solo soporta colores sólidos para garantizar la portabilidad absoluta.
  - **Logos Mixtos**: Los logos SVG no se incrustan en PNG para evitar dependencias de renderizado externo; se recomienda usar logos PNG/JPG para salidas raster.

---

## 🚀 Guía de Inicio Rápido

### Instalación
1. Descarga o clona el repositorio.
2. Asegúrate de tener PowerShell 5.1 o superior (Core soportado).
3. No requiere instalación de módulos externos.

### Ejemplos de Uso

**Generación Básica (SVG):**
```powershell
.\QRCode.ps1 -Data "https://github.com" -OutputPath "codigo.svg"
```

**Generación con Estilo (PDF):**
```powershell
.\QRCode.ps1 -Data "Dato" -ForegroundColor "#0000FF" -Rounded 0.5 -FrameText "ESCANEAME" -OutputPath "estilo.pdf"
```

**Procesamiento por Lotes (TSV):**
```powershell
.\QRCode.ps1 -InputFile "lista.tsv" -PdfUnico -PdfUnicoNombre "catalogo.pdf"
```

**vCard y Pagos SEPA:**
```powershell
# Ejemplo: Generar una vCard (Contacto)
$contacto = New-vCard -Name "Juan Perez" -Tel "+34600000000" -Email "juan@ejemplo.com"
.\QRCode.ps1 -Data $contacto -OutputPath "contacto.pdf"

# Ejemplo: Generar un Pago SEPA (EPC)
$pago = New-EPC -Beneficiary "Empresa S.L." -IBAN "ES211234..." -Amount 125.50 -Information "Factura 2024-01"
.\QRCode.ps1 -Data $pago -OutputPath "pago_sepa.pdf"
```

**Uso del Lanzador Interactivo:**
Ejecuta `run_qrps.bat` para un menú guiado sin necesidad de comandos.

---

## ⚙️ Configuración (config.ini)

El archivo `config.ini` permite centralizar las preferencias globales. Los parámetros pasados por línea de comandos (CLI) tienen prioridad sobre este archivo.

| Variable | Descripción | Valor por Defecto |
| :--- | :--- | :--- |
| `QRPS_FormatoSalida` | Formatos a generar (pueden ser varios: `svg,pdf,png`) | `pdf` |
| `QRPS_CarpetaSalida` | Directorio donde se guardarán los archivos | `salida_qr` |
| `QRPS_ArchivoEntrada` | Nombre del archivo TSV para procesamiento por lotes | `lista_inputs.tsv` |
| `QRPS_LogoPath` | Ruta absoluta o relativa al logo central | (Vacío) |
| `QRPS_LogoScale` | Porcentaje de ocupación del logo (1-30) | `20` |
| `QRPS_ColorFront` | Color principal del código QR (HEX) | `#000000` |
| `QRPS_ColorFront2` | Segundo color para degradados (HEX) | (Vacío) |
| `QRPS_TipoDegradado` | Tipo de degradado: `linear` o `radial` | `linear` |
| `QRPS_ColorBack` | Color de fondo (HEX) | `#ffffff` |
| `QRPS_Redondeado` | Nivel de redondeo de los módulos (0 a 0.5) | `0` |
| `QRPS_NivelEC` | Nivel de corrección de errores (`L, M, Q, H`) | `M` |
| `QRPS_TamanoModulo` | Tamaño en píxeles de cada módulo | `10` |
| `QRPS_PdfUnico` | Combinar múltiples QRs en un solo archivo PDF (`si/no`) | `no` |
| `QRPS_PdfUnicoNombre` | Nombre del archivo PDF combinado | `qr_combinado.pdf` |
| `QRPS_Layout` | Layout para PDF único (`Default, Grid4x4, Grid4x5, Grid6x6`) | `Default` |
| `QRPS_MenuTimeout` | Tiempo de espera en segundos para el menú de selección | `5` |

---

## 📊 Formatos de Datos Soportados

El motor reconoce y valida automáticamente los siguientes formatos mediante funciones auxiliares:

- **vCard / MeCard**: Generación de tarjetas de contacto completas.
  ```powershell
  $vcard = New-vCard -Name "Juan" -Tel "123"
  $mecard = New-MeCard -Name "Juan" -Tel "123"
  ```
- **WIFI**: Configuración rápida de red inalámbrica.
  ```powershell
  $wifi = New-WiFiConfig -Ssid "MiRed" -Password "Secret" -Auth "WPA"
  ```
- **EPC (SEPA)**: Transferencias bancarias europeas estándar.
  ```powershell
  $pago = New-EPC -Beneficiary "IBERDROLA" -IBAN "ES21..." -Amount 45.0
  ```
- **GS1**: Soporte para Identificadores de Aplicación (FNC1).
- **URL / Email / Tel / SMS**: Acciones estándar del sistema.
- **Texto Plano**: Soporte completo para UTF-8 y Kanji (Shift-JIS).

---

## 🛠️ Utilidades Adicionales

### Conversión de Imágenes a PDF
Permite tomar una carpeta llena de imágenes (PNG/JPG) y organizarlas automáticamente en un PDF con rejillas de impresión.
```powershell
# Disponible vía Menú (Opción 3) o llamando internamente:
Convert-ImagesToPdf -inputDir ".\fotos" -outputPath "album.pdf" -layout "Grid4x5"
```

### Structured Append
Divide datos grandes en hasta 16 códigos QR vinculados.
```powershell
.\QRCode.ps1 -Data "Datos muy largos..." -StructuredAppendIndex 0 -StructuredAppendTotal 3 -StructuredAppendParity 123
```

---

## ⚖️ Licencia y Patentes

- **Licencia**: Apache 2.0 (Libre uso, modificación y distribución).
- **Patentes**: Basado en estándares abiertos de **ISO/IEC 18004**. La tecnología QR es una marca de DENSO WAVE INCORPORATED, utilizada aquí bajo el derecho de uso de estándares internacionales.
- **Restricción**: No implementa **SQRC** o **iQR** por requerir algoritmos propietarios de cifrado.

---
*Documentación actualizada al 27 de enero de 2026. Cumplimiento verificado bajo estándares ISO/IEC 18004:2024.*
