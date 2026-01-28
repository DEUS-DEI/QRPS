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
- **Limitación**: Los logos SVG se convierten a raster al exportar a PNG.

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

**Uso del Lanzador Interactivo:**
Ejecuta `run_qrps.bat` para un menú guiado sin necesidad de comandos.

---

## ⚙️ Configuración (config.ini)

El archivo `config.ini` centraliza las preferencias globales:

| Variable | Descripción | Valor por Defecto |
| :--- | :--- | :--- |
| `QRPS_FormatoSalida` | Formatos: `svg, pdf, png` | `pdf` |
| `QRPS_LogoPath` | Ruta al logo central | (Vacío) |
| `QRPS_ColorFront` | Color del QR (HEX) | `#000000` |
| `QRPS_Redondeado` | Redondeado de módulos (0-0.5) | `0` |
| `QRPS_PdfUnico` | Combinar todo en un solo PDF | `no` |

---

## 📊 Formatos de Datos Soportados

El motor reconoce y valida automáticamente los siguientes formatos:

- **vCard / MeCard**: Tarjetas de contacto.
- **WIFI**: Configuración de red (`WIFI:S:SSID;T:WPA;P:PASS;;`).
- **GS1**: Identificadores de aplicación (GTIN, Lote, Exp.) vía FNC1.
- **EPC (Próximamente)**: Formatos de transferencia bancaria SEPA.
- **URL / Email / Tel**: Acciones automáticas estándar.
- **Texto Plano**: Soporte total para UTF-8 y Kanji.

---

## ⚖️ Licencia y Patentes

- **Licencia**: Apache 2.0 (Libre uso, modificación y distribución).
- **Patentes**: Basado en estándares abiertos de **ISO/IEC 18004**. La tecnología QR es una marca de DENSO WAVE INCORPORATED, utilizada aquí bajo el derecho de uso de estándares internacionales.
- **Restricción**: No implementa **SQRC** o **iQR** por requerir algoritmos propietarios de cifrado.

---
*Documentación actualizada al 27 de enero de 2026. Cumplimiento verificado bajo estándares ISO/IEC 18004:2024.*
