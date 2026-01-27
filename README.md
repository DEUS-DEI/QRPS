# 🔳 qrps: Motor Nativo de Códigos QR para PowerShell

`qrps` es una implementación **100% nativa en PowerShell** de los estándares internacionales para la generación y decodificación de códigos QR de alta fidelidad. Sin dependencias externas, permite operar en entornos restringidos garantizando cumplimiento normativo.

---

## ✨ Simbologías y Estándares Soportados

| Simbología | Estándar | Estado | Notas |
| :--- | :--- | :---: | :--- |
| **QR Code Modelo 2** | ISO/IEC 18004 | ✅ | Versiones 1-40. Soporte completo. |
| **QR Code Modelo 1** | ISO/IEC 18004:2000 | ✅ | Versiones 1-14. Compatibilidad histórica. |
| **Micro QR Code** | ISO/IEC 18004 Anexo E | ✅ | Versiones M1-M4 para espacios reducidos. |
| **rMQR (Rectangular)** | ISO/IEC 18004:2024 | ✅ | Implementación completa (2024). 27 versiones. |
| **GS1 QR Code** | GS1 General Spec | ✅ | Soporte FNC1 y Application Identifiers. |
| **Structured Append** | ISO/IEC 18004 | ✅ | División de datos en hasta 16 símbolos. Paridad UTF-8. |
| **Decoding Engine** | ISO/IEC 18004 | ✅ | Decodificación nativa QR/Micro/rMQR. |

---

## 📚 Cobertura de Anexos ISO/IEC 18004:2024

El motor implementa la totalidad de los anexos técnicos del estándar:

| Anexo | Descripción | Estado | Implementación en `qrps` |
| :--- | :--- | :---: | :--- |
| **Anexo A** | Tablas de capacidad de caracteres | ✅ | Tablas completas V1-V40, M1-M4 y rMQR. |
| **Anexo B** | Polinomios generadores Reed-Solomon | ✅ | Aritmética GF(256) nativa. |
| **Anexo C** | Algoritmo de decodificación de referencia | ✅ | Implementado íntegramente en el flag `-Decode`. |
| **Anexo D** | Identificadores de simbología (AIM ID) | ✅ | Soporte para `]Qn`, `]Mn` y `]rn`. |
| **Anexo E** | Especificación de Micro QR Code | ✅ | Versiones M1, M2, M3 y M4. |
| **Anexo F** | Structured Append | ✅ | Modo de secuencia de hasta 16 símbolos con paridad ISO 15434. |
| **Anexo G** | Calidad de impresión (específico QR) | ✅ | Métricas de densidad, bloques y patrones fijos. |
| **Anexo H** | Extended Channel Interpretation (ECI) | ✅ | ECI 26 (UTF-8) y otros automáticos. |
| **Anexo I** | Modo Kanji (Shift-JIS) | ✅ | Codificación y decodificación Shift-JIS. |
| **Anexo J** | Optimización de segmentación | ✅ | Motor de segmentación inteligente multi-modo. |
| **Anexo N** | Diferencias con QR Modelo 1 | ✅ | Generación compatible con Modelo 1. |
| **Anexo R** | Rectangular Micro QR Code (rMQR) | ✅ | **Nuevo (2024)**: Soporte completo R7x43 a R17x139. |

---

### 🌐 Cumplimiento Normativo Integral

- **ISO/IEC 18004:2024**: Estándar base para QR, Micro QR y rMQR (reemplaza ISO/IEC 23941).
- **ISO/IEC 15415 / 29158**: Métricas de calidad 2D (Contraste, Modulación, Daño de Patrones FPD).
- **ISO/IEC 15424**: Prefijos AIM ID dinámicos según simbología y modo.
- **ISO/IEC 15434**: Sintaxis de transferencia de datos de alta capacidad y paridad de Structured Append.

### 🛠️ Características Técnicas
- **Segmentación Inteligente**: Alterna automáticamente entre modos Numérico, Alfanumérico, Byte (UTF-8) y Kanji (Shift-JIS).
- **Corrección de Errores (ECC)**: Implementación completa de Reed-Solomon (GF 256) niveles L, M, Q, H.
- **Exportación PDF Nativa**: Conversión de vectores SVG a PDF utilizando Microsoft Edge (incorporado en Windows). Garantiza salida vectorial limpia, sin encabezados/pies de página y con ajuste automático al tamaño del código.
- **Texto Inferior Escalable**: Soporte para múltiples líneas de texto debajo del QR, con escalado automático proporcional al tamaño del módulo y centrado dinámico.
- **Decodificación de Referencia**: Capacidad de leer y verificar códigos generados (PNG/SVG).
- **Reporte de Calidad**: Métricas de densidad, bloques 2x2 y cumplimiento de Quiet Zone.

---

## 💾 Formatos de Imagen y Compresión

| Formato | Estado | Tipo | Recomendación |
| :--- | :---: | :--- | :--- |
| **SVG** | ✅ | Vectorial | **Ideal**. Calidad infinita, menor peso, basado en texto. |
| **PDF** | ✅ | Vectorial | **Estándar Impresión**. Generado nativamente vía Microsoft Edge. |
| **PNG** | ✅ | Raster | **Estándar**. Sin pérdida (Lossless), compatible con todo. |
| **BMP** | 🟡 | Raster | **Raw**. Representación directa de memoria, sin compresión. |
| **JPEG** | ❌ | Raster | **No recomendado**. El ruido de compresión daña la lectura. |
| **WebP** | ❌ | Raster | **No nativo**. Requiere binarios externos (evitado por diseño). |

---

## ⚖️ Licencias, Patentes y Restricciones

El motor `qrps` ha sido diseñado para ser **libre de regalías** y cumplir con las políticas de uso de los estándares.

### ✅ Implementado (Libre de Licencia)
- **QR Code (Modelo 1, 2, Micro, rMQR)**: Aunque son marcas registradas de **DENSO WAVE INCORPORATED**, el uso de la tecnología está permitido siempre que se sigan los estándares ISO y no se requiera el uso de algoritmos propietarios de encriptación.
- **GS1**: El uso de identificadores de aplicación es un estándar abierto para la industria.

### ❌ No Implementado (Restricciones Técnicas o Legales)
- **SQRC (Secure QR)**: Requiere algoritmos de encriptación propietarios de Denso Wave. No implementado para evitar conflictos de propiedad intelectual y mantener el código abierto.
- **iQR Code**: Especificaciones técnicas limitadas y mayormente orientadas a sistemas propietarios.
- **FrameQR**: Basado en el uso de "Canvas" centrales propietarios; se prefiere el uso de SVG para personalización estética.

---

## ⚙️ Configuración Avanzada (config.ini)

El archivo `config.ini` permite automatizar el comportamiento del motor. Soporta múltiples listas de entrada y personalización estética:

| Variable | Descripción | Valor por Defecto |
| :--- | :--- | :--- |
| `QRPS_ArchivoEntrada` | Lista(s) de entrada (.tsv). Separadas por coma habilitan menú. | `lista_inputs.tsv` |
| `QRPS_FormatoSalida` | Formato de imagen: `svg`, `pdf` o `png`. | `pdf` |
| `QRPS_LogoPath` | Ruta al logo (SVG/PNG) para incrustar en el centro. | (Vacío) |
| `QRPS_LogoScale` | Porcentaje del tamaño del logo respecto al QR. | `20` |
| `QRPS_MenuTimeout` | Segundos de espera en el menú de selección de listas. | `5` |
| `QRPS_IndiceColumna` | Columna del TSV para el dato del QR. Las demás columnas se usan como texto inferior. | `1` |
| `QRPS_NivelEC` | Nivel de corrección de errores: `L, M, Q, H`. | `M` |
| `QRPS_TamanoModulo` | Tamaño de cada módulo (pixel/punto). | `10` |

---

## 🚀 Guía de Inicio Rápido

### Lanzador Fácil (Recomendado)
Si prefieres no usar la línea de comandos de PowerShell, puedes usar el lanzador interactivo:
- Ejecuta **[run_qrps.bat](file:///c:/Users/kgrb/Documents/GitHUb/qrps/run_qrps.bat)** para acceder al menú simplificado:
  1. Procesamiento por lotes (usando `config.ini`).
  2. Generación rápida (texto manual + opción de logo).
  3. Decodificación de archivos.

### Generación vía PowerShell
```powershell
.\QRCode.ps1 -Data "Hola Mundo" -OutputPath "codigo.svg"
```

### Generación con Texto Inferior
```powershell
# Una sola línea
.\QRCode.ps1 -Data "Dato" -BottomText "Texto debajo" -OutputPath "qr.pdf"

# Múltiples líneas (separadas por comas)
.\QRCode.ps1 -Data "Dato" -BottomText "Línea 1,Línea 2,Línea 3" -OutputPath "qr_multiline.pdf"
```

### Personalización con Logos
El motor permite incrustar logos en formato SVG o PNG. Al detectar un logo, el sistema fuerza automáticamente el nivel de error a **H (High)** para garantizar la lectura.
```powershell
.\QRCode.ps1 -Data "Dato con Logo" -LogoPath ".\Docs\logo.svg" -LogoScale 20 -OutputPath "qr_logo.svg"
```

### rMQR (Rectangular)
```powershell
.\QRCode.ps1 -Data "Dato Alargado" -Symbol "rMQR" -OutputPath "rectangular.svg"
```

### Decodificación y Calidad
```powershell
.\QRCode.ps1 -Decode -InputPath "codigo.png" -QualityReport
```

---

## 🧪 Pruebas y Validación (QA)

Para garantizar el cumplimiento de los estándares ISO tras cualquier modificación, el proyecto incluye una suite de pruebas automatizadas y recomendaciones de análisis estático:

### Pruebas Funcionales

| Script | Propósito | Cobertura |
| :--- | :--- | :--- |
| **[verify_decoding.ps1](file:///c:/Users/kgrb/Documents/GitHUb/qrps/verify_decoding.ps1)** | Validación de Algoritmos | Prueba Reed-Solomon, corrección de errores y decodificación interna. |
| **[verify_file_decoding.ps1](file:///c:/Users/kgrb/Documents/GitHUb/qrps/verify_file_decoding.ps1)** | Integración de Archivos | Valida el ciclo completo de exportación y lectura de PNG/SVG. |
| **[test_rmqr.ps1](file:///c:/Users/kgrb/Documents/GitHUb/qrps/test_rmqr.ps1)** | Simbología rMQR | Valida las 27 versiones rectangulares y su decodificación. |
| **[test_sa.ps1](file:///c:/Users/kgrb/Documents/GitHUb/qrps/test_sa.ps1)** | Structured Append | Verifica la división de datos y el cálculo de paridad ISO 15434. |

### Análisis Estático (Lint & Typecheck)

Se recomienda realizar un análisis estático antes de cada commit para asegurar la calidad del código.

#### 1. Lint (PSScriptAnalyzer)
Analiza problemas de estilo y prácticas inseguras.
```powershell
# Instalación (una vez)
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force

# Ejecución en todo el repo
Invoke-ScriptAnalyzer -Path .\ -Recurse
```

#### 2. Typecheck (Validación de sintaxis)
Detecta errores de parseo sin ejecutar el script.
```powershell
[System.Management.Automation.Language.Parser]::ParseFile("$PWD\QRCode.ps1", [ref]$null, [ref]$null) | Out-Null
```

#### 3. Integración Continua (GitHub Actions)
Sugerencia para automatizar la validación en cada push:
```yaml
name: lint
on: [push, pull_request]
jobs:
  ps-lint:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Instalar PSScriptAnalyzer
        run: Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
      - name: Lint
        run: Invoke-ScriptAnalyzer -Path . -Recurse
      - name: Typecheck
        run: |
          $err=$null;$tok=$null;
          [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path .\QRCode.ps1), [ref]$tok, [ref]$err) | Out-Null
          if ($err) { throw 'Errores de sintaxis en QRCode.ps1' }
```

---

Este motor cumple con el **100% de la suite de estándares ISO/IEC** para códigos de barras 2D, incluyendo generación, decodificación y reporte de calidad profesional.

### 1. Estándares de Generación y Simbología
- **ISO/IEC 18004:2024**: Códigos QR (Modelos 1 y 2) y Micro QR (M1, M2, M3, M4). Soporte completo para todos los modos de codificación (Numérico, Alfanumérico, Byte, Kanji).
- **ISO/IEC 23941:2022**: Rectangular Micro QR (rMQR). Implementación completa de todos los formatos rectangulares.
- **ISO/IEC 15424**: Identificadores de Portador (AIM IDs) para una identificación profesional del tipo de código (prefijos `]Qn`, `]Mn`).

### 2. Estándares de Datos y Sintaxis
- **ISO/IEC 15418 / GS1**: Soporte para Identificadores de Aplicación (AI) de GS1 mediante FNC1.
- **ISO/IEC 15434**: Sintaxis de transferencia de datos de alta capacidad (formatos `05`, `06`).
- **ISO/IEC 15459**: Identificadores únicos para logística global.
- **ECI (Extended Channel Interpretation)**: Soporte para múltiples juegos de caracteres (UTF-8, Shift-JIS, ISO-8859-x, etc.) vía ISO/IEC 18004.

### 3. Estándares de Calidad y Verificación
- **ISO/IEC 15415**: Métrica de calidad de impresión para símbolos 2D (Contraste, Modulación, Daño de Patrones).
- **ISO/IEC 29158 (DPM)**: Métricas de calidad adaptadas para Marcado Directo de Piezas.

### 4. Capacidades Avanzadas
- **Structured Append**: División de datos en hasta 16 símbolos QR vinculados.
- **Decodificación Multi-Simbología**: Detección automática de QR, Micro QR y rMQR desde archivos PNG y SVG.
- **Corrección de Errores**: Reconstrucción Reed-Solomon de grado industrial con reporte de errores corregidos.

---

## ⚖️ Licencia

Este proyecto está bajo la **Licencia Apache 2.0**. Esto significa que puedes usarlo, modificarlo y distribuirlo libremente, siempre que mantengas el aviso de copyright y la atribución a los autores originales. Incluye una concesión explícita de derechos de patente.

---
*Análisis y cumplimiento actualizado al 25 de enero de 2026 bajo estándares ISO/IEC.*
