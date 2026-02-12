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
- [🛠️ Utilidades Adicionales](#️-utilidades-adicionales)
- [🗺️ Roadmap y Futuras Mejoras](#️-roadmap-y-futuras-mejoras)
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
| **Validación Semántica** | vCard/EPC/IBAN | ✅ | Verificación estricta de formatos (MOD 97, RFC 2426). |
| **Auto-split** | ISO/IEC 18004 | ✅ | Fragmentación automática mediante Structured Append. |
| **ECI Extendido** | ISO/IEC 18004 | ✅ | Soporte para Cirílico, Árabe, Griego, etc. |
| **Code 39 (Full)** | ISO/IEC 16388 | ✅ | Alfanumérico industrial. |
| **Code 128 (B)** | ISO/IEC 15417 | ✅ | Densidad alta, ASCII 32-127. |
| **EAN-13** | ISO/IEC 15420 | ✅ | Retail global (con dígito de control). |
| **EAN-8** | ISO/IEC 15420 | ✅ | Retail compacto (con dígito de control). |
| **UPC-A** | ISO/IEC 15420 | ✅ | Retail Norteamérica (con dígito de control). |
| **UPC-E** | ISO/IEC 15420 | ✅ | Zero-suppressed, paridad por check digit. |

---

## 🛠️ Características Técnicas

- **Segmentación Inteligente**: Alterna automáticamente entre modos Numérico, Alfanumérico, Byte (UTF-8) y Kanji (Shift-JIS).
- **Corrección de Errores (ECC)**: Implementación completa de Reed-Solomon (GF 256) niveles L, M, Q, H.
- **Portabilidad Absoluta**: El script es 100% independiente; los identificadores GS1 y la lógica de validación están integrados sin necesidad de archivos JSON o librerías externas.
- **Exportación Multi-formato**: Generación simultánea de **PDF, SVG, PNG, EPS, PBM y PGM** en un solo proceso.
- **Visualización ANSI**: Renderizado de alta resolución en consola mediante medio bloque Unicode.
- **Integración Web**: Salida directa en formato **Data URI (Base64)** para su uso inmediato en aplicaciones web.
- **Payloads Listos**: Generadores nativos para **MailTo, SMS, Tel, WhatsApp, Geo, vEvent y vCalendar**.
- **Validación Extendida**: Validadores para **Email, URL estricta, E.164 y Dominio**.
- **Personalización Estética**: Soporte para colores sólidos, degradados (lineales/radiales), módulos redondeados y marcos decorativos ("ESCANEAME").
- **Procesamiento por Lotes**: Motor robusto para procesar archivos **TSV** con mapeo dinámico de columnas y personalización por fila.
- **Incrustación de Logos**: Soporte para logos PNG/JPG/SVG con ajuste automático de nivel de error a **H (High)**.
- **Layouts de Impresión**: Generación de catálogos con rejillas automáticas (Grid 4x4, 4x5, 6x6).
- **Robustez Industrial**: Implementación de `Set-StrictMode -Version 2.0` y tipado estricto de .NET para máxima estabilidad.
- **Suite de Pruebas**: Validación automatizada completa mediante **Pester** para asegurar la integridad del código.

---

## 🏛️ Cumplimiento Normativo (ISO/IEC)

### 📄 PDF (ISO 14289-1 / PDF/UA-1 / PDF/A-3)
Motor binario nativo diseñado para accesibilidad y archivo a largo plazo.
- **Accesibilidad**: Estructura lógica dinámica (`StructTreeRoot`), etiquetas de figura y mapeo `/Pg`.
- **Estándares**: Cumple con **ISO 32000-1 (PDF 1.7)** y **ISO 19005-3 (PDF/A-3)**.
- **Incrustación**: Soporte para incrustación de archivos fuente (XML, JSON, CSV) mediante `/AF` (Attachment Feature).
- **Unicode**: Mapeo CMap (ToUnicode) para extracción de texto garantizada.
- **Optimización**: Diccionario de linealización (Obj 1) para visualización rápida y compresión `/FlateDecode`.

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

### 📐 EPS (Encapsulated PostScript 3.0)
Exportación vectorial profesional para la industria gráfica.
- **Estándar**: Generación de archivos **EPSF-3.0** compatibles con software de pre-impresión y diseño vectorial.
- **Color**: Conversión precisa de HEX a espacio de color RGB de PostScript.
- **Geometría**: Inversión automática del eje Y para cumplir con el sistema de coordenadas cartesiano de PostScript.

### 🧾 PBM/PGM (Netpbm)
Exportación raster ultra ligera para automatización y entornos sin GDI+ avanzado.
- **PBM (P1)**: Blanco y negro puro para impresoras o pipelines mínimos.
- **PGM (P2)**: Escala de grises simple con valores 0–255.
- **Compatibilidad**: Archivos de texto plano fáciles de inspeccionar y transformar.

---

## 🚀 Guía de Inicio Rápido

### Instalación
1. Descarga o clona el repositorio.
2. Asegúrate de tener PowerShell 5.1 o superior (Core soportado).
3. No requiere instalación de módulos externos.

### Ejemplos de Uso

**Generación Básica (SVG/EPS/PNG):**
```powershell
.\QRCBScript.ps1 -Data "https://github.com" -OutputPath "codigo.svg"
.\QRCBScript.ps1 -Data "https://github.com" -OutputPath "codigo.eps"
```

**Salida Data URI (Base64):**
```powershell
.\QRCBScript.ps1 -Data "Info" -DataUri
```

**Payloads Rápidos (Mail/SMS/WhatsApp/Geo):**
```powershell
$mail = New-MailTo -To "hola@ejemplo.com" -Subject "Info" -Body "Mensaje"
$sms = New-Sms -Number "+34600000000" -Message "Hola"
$wa = New-WhatsApp -Number "+34600000000" -Message "Mensaje"
$geo = New-Geo -Latitude 40.4168 -Longitude -3.7038
.\QRCBScript.ps1 -Data $mail -OutputPath "mail.pbm"
.\QRCBScript.ps1 -Data $sms -OutputPath "sms.pgm"
```

**URI de Pago Genérica (UPI/PIX/Bitcoin):**
```powershell
$pay = New-PaymentUri -Scheme "upi" -Address "usuario@banco" -Params @{ am = "10.50"; cu = "INR" }
.\QRCBScript.ps1 -Data $pay -OutputPath "pago.png"
```

**Validaciones Rápidas (Email/URL/E.164/Dominio):**
```powershell
Test-Email "test@ejemplo.com"
Test-UrlStrict "https://ejemplo.com"
Test-PhoneE164 "+34600000000"
Test-Domain "ejemplo.com"
```

**Generación con Estilo (PDF):**
```powershell
.\QRCBScript.ps1 -Data "Dato" -ForegroundColor "#0000FF" -Rounded 0.5 -FrameText "ESCANEAME" -OutputPath "estilo.pdf"
```

**Procesamiento por Lotes (TSV):**
```powershell
.\QRCBScript.ps1 -InputFile "lista.tsv" -PdfUnico -PdfUnicoNombre "catalogo.pdf"
```

**vCard y Pagos SEPA:**
```powershell
# Ejemplo: Generar una vCard (Contacto)
$contacto = New-vCard -Name "Juan Perez" -Tel "+34600000000" -Email "juan@ejemplo.com"
.\QRCBScript.ps1 -Data $contacto -OutputPath "contacto.pdf"

# Ejemplo: Generar un Pago SEPA (EPC)
$pago = New-EPC -Beneficiary "Empresa S.L." -IBAN "ES211234..." -Amount 125.50 -Information "Factura 2024-01"
.\QRCBScript.ps1 -Data $pago -OutputPath "pago_sepa.pdf"
```

**Eventos con vCalendar (VCALENDAR):**
```powershell
$evt = New-VCalendarEvent -Summary "Reunión" -Start (Get-Date "2026-02-15 10:00") -End (Get-Date "2026-02-15 11:00") -Location "Sala 1"
.\QRCBScript.ps1 -Data $evt -OutputPath "evento.svg"
```

**Uso del Lanzador Interactivo:**
Ejecuta `run_qrps.bat` para un menú guiado sin necesidad de comandos.

---

## ⚙️ Configuración (config.ini)

El archivo `config.ini` permite centralizar las preferencias globales. Los parámetros pasados por línea de comandos (CLI) tienen prioridad sobre este archivo.

| Variable | Descripción | Valor por Defecto |
| :--- | :--- | :--- |
| `QRPS_FormatoSalida` | Formatos a generar (pueden ser varios: `svg,pdf,png,eps,pbm,pgm`) | `pdf` |
| `QRPS_CarpetaSalida` | Directorio donde se guardarán los archivos | `salida_qr` |
| `QRPS_ArchivoEntrada` | Nombre del archivo TSV para procesamiento por lotes | `lista_inputs.tsv` |
| `QRPS_IndiceColumna` | Índice de la columna de datos en el TSV (1-basado) | `1` |
| `QRPS_LogoPath` | Ruta absoluta o relativa al logo central | (Vacío) |
| `QRPS_LogoScale` | Porcentaje de ocupación del logo (1-30) | `20` |
| `QRPS_ColorFront` | Color principal del código QR (HEX) | `#000000` |
| `QRPS_ColorFront2` | Segundo color para degradados (HEX) | (Vacío) |
| `QRPS_TipoDegradado` | Tipo de degradado: `linear` o `radial` | `linear` |
| `QRPS_ColorBack` | Color de fondo (HEX) | `#ffffff` |
| `QRPS_Redondeado` | Nivel de redondeo de los módulos (0 a 0.5) | `0` |
| `QRPS_NivelEC` | Nivel de corrección de errores (`L, M, Q, H`) | `M` |
| `QRPS_Version` | Versión fija del QR (1-40) o `0` para auto | `0` |
| `QRPS_Prefijo` | Prefijo para los nombres de archivo generados | `qr_` |
| `QRPS_UseConsecutivo` | Usar números secuenciales como nombre (`si/no`) | `si` |
| `QRPS_IncluirTimestamp` | Añadir fecha/hora al nombre del archivo (`si/no`) | `no` |
| `QRPS_PdfUnico` | Combinar múltiples QRs en un solo archivo PDF (`si/no`) | `no` |
| `QRPS_PdfUnicoNombre` | Nombre del archivo PDF combinado | `qr_combinado.pdf` |
| `QRPS_Layout` | Layout para PDF único (`Default, Grid4x4, Grid4x5, Grid6x6`) | `Default` |
| `QRPS_FrameText` | Texto decorativo en el marco superior | (Vacío) |
| `QRPS_FrameColor` | Color del marco y su texto | `#000000` |
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
  $wifi = New-WiFiConfig -Ssid "MiRed" -WifiKey "Secret" -Auth "WPA"
  ```
- **EPC (SEPA)**: Transferencias bancarias europeas estándar.
  ```powershell
  $pago = New-EPC -Beneficiary "IBERDROLA" -IBAN "ES21..." -Amount 45.0
  ```
- **GS1**: Soporte para Identificadores de Aplicación (FNC1).
- **MailTo / SMS / Tel / WhatsApp**: Acciones rápidas con payloads nativos.
- **Geo / vEvent / vCalendar**: Geolocalización y eventos completos.
- **URI de Pago (genérica)**: Esquemas locales como `upi`, `pix`, `bitcoin`, etc.
- **URL / Email**: Acciones estándar del sistema.
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
.\QRCBScript.ps1 -Data "Datos muy largos..." -StructuredAppendIndex 0 -StructuredAppendTotal 3 -StructuredAppendParity 123
```

---

## 🗺️ Roadmap y Futuras Mejoras

Para evolucionar `qrps` hacia un motor de grado industrial, se ha dividido el roadmap entre lo que se puede lograr de forma **Nativa en PowerShell** y las capacidades que requerirían **Integraciones Externas**.

### 💻 Implementación Nativa (PowerShell 5.1/7+)
*Estas mejoras pueden desarrollarse directamente dentro del motor actual sin dependencias externas complejas.*

- **📦 Códigos de Barras 1D (Base)**:
  - **UPC-A / UPC-E**: ✅ Implementado (retail Norteamérica).
  - **EAN-8 / EAN-13**: ✅ Implementado (retail global).
  - **Code 39 (Full/Mod43)**: ✅ Implementado (Full).
  - **Code 128 (A/B/C)**: ✅ Implementado (B).
  - **GS1-128 (EAN-128)**: ✅ Implementado (AIs GS1 con FNC1 y reglas de formato).
  - **Interleaved 2 of 5 / ITF-14**: ✅ Implementado (cajas y embalaje).
  - **Codabar / MSI**: ✅ Implementado (bibliotecas, bancos y legacy).
- **🧱 Códigos de Barras 2D (Base)**:
  - **Data Matrix ECC200**: Tamaños 10x10 a 144x144, rectangular 8x18 a 16x48.
  - **GS1 DataMatrix**: AIs GS1, FNC1 y validaciones semánticas.
  - **PDF417 / MicroPDF417**: Filas/columnas configurables, modos y niveles ECC.
  - **Aztec (Compact/Full)**: Capas 1–4 (compact) y 1–32 (full).
  - **MaxiCode**: Modos 2/3/4/5/6 para logística.
- **🧩 Variantes y Reglas**:
  - **Check Digits**: UPC/EAN/ITF-14/Code 39/Code 128.
  - **Quiet Zones**: Cálculo y normalización por simbología.
  - **Escalas y DPI**: Presets para impresión térmica y offset.
  - **Validaciones GS1**: Longitudes, AIs y formatos de datos.
- **⚡ Optimizaciones Propuestas**:
  - **Raster 1D/2D**: Render directo con tablas de barras y run-length.
  - **Salida Vectorial**: SVG/EPS/PDF con paths compactos por símbolos.
  - **Batch Packing**: Layouts automáticos para hojas (A4/Letter).
  - **Pre-cálculo de patrones**: Cache de dígitos y módulos por estándar.

- **⚡ Rendimiento**:
  - **Procesamiento en Paralelo**: ✅ Implementado mediante `RunspacePool` para máxima eficiencia en lotes.
  - **Caché de Símbolos**: ✅ Implementado mediante reutilización de matrices de patrones fijos y máscaras pre-calculadas.
  - **Optimización de Matriz**: ✅ Migración de Hashtables a arrays 1D para reducir memoria y ganar velocidad.
  - **Optimización SVG**: ✅ Agrupación de módulos en un solo `<path>` para reducir el tamaño del archivo.
  - **Compresión PDF**: ✅ Implementación de filtro `/FlateDecode` en streams de contenido nativos.
  - **Máscaras en Paralelo**: ✅ Evaluación concurrente de las 8 máscaras estándar para ganar velocidad en V20+.
  - **Optimización GetPenalty**: ✅ Eliminación de conversiones intermedias de matriz para reducir ciclos de CPU.
  - **Pre-renderizado**: ✅ Sistema de matrices base con patrones fijos pre-calculados por versión.
- **🏗️ Arquitectura**:
  - **Modularización (PSM1)**: Conversión a módulo formal para facilitar la distribución.
- **Generación Directa de Lenguajes de Impresión**: Implementación de conversores a **ZPL (Zebra)** y **ESC/POS**.
- **Robustez**: ✅ Implementado `Set-StrictMode` y tipado estricto de .NET.
- **Pruebas Unitarias**: ✅ Suite de validación automatizada con **Pester**.
- **CI/CD Integration**: Plantillas para GitHub Actions y Azure DevOps.
- **🛡️ Seguridad y Datos**:
  - **Firmas Digitales (ECDSA)**: ✅ Implementado utilizando .NET nativo (`System.Security.Cryptography`).
  - **Compresión de Datos**: ✅ Implementado algoritmos de compresión por diccionario para QR V40.
  - **Nuevos Formatos**: ✅ Soporte para Geo-localización, vEvent, vCalendar, MailTo/SMS/Tel/WhatsApp y URI de pago genérica.
  - **Validación Semántica**: ✅ Verificación estricta de formatos (IBAN, vCard, EPC, Email, URL, E.164, Dominio).
  - **Auto-split**: ✅ Fragmentación automática de datos mediante Structured Append.
  - **Portabilidad GS1**: ✅ Identificadores de aplicación integrados para independencia total del script.
  - **PDF/A-3**: ✅ Cumplimiento del estándar para permitir la incrustación de archivos de datos fuente.
  - **ECI Extendido**: ✅ Soporte para tablas de caracteres adicionales (Cirílico, Árabe, etc.).
- **🎨 Estética y UX**:
  - **Redondeado Avanzado y Formas**: ✅ Implementado uso de `GraphicsPath` para módulos geométricos variados.
  - **Optimización E-Ink**: ✅ Implementado perfiles de alto contraste y desactivación de anti-aliasing.
  - **Logging Estándar**: ✅ Transición a `Write-Verbose` y `Write-Debug` para mejor integración en scripts.
  - **Render ANSI**: ✅ Visualización instantánea en consola mediante caracteres de medio bloque Unicode.
  - **Formato EPS**: ✅ Exportación vectorial profesional para industria gráfica.
  - **PBM/PGM**: ✅ Exportación Netpbm ultra ligera para pipelines simples.
  - **Data URI**: ✅ Salida directa en Base64 para integración web inmediata.

### 🌐 Integraciones y Sistemas Externos
*Estas capacidades requieren servicios adicionales, contenedores o librerías de terceros.*

- **� Infraestructura**:
  - **Servicio Web (API)**: Exponer el motor como un microservicio usando Azure Functions o AWS Lambda.
  - **QR Dinámico**: Requiere una base de datos y un servidor web intermedio para gestionar las redirecciones y analíticas.
- **🖼️ Compatibilidad Multiplataforma**:
  - **Independencia de GDI+**: Migración a `ImageSharp` para soporte completo en Linux/macOS (PowerShell Core), ya que `System.Drawing` está limitado fuera de Windows.
- **⚙️ Aplicaciones de Usuario**:
  - **Interfaz Gráfica (GUI)**: Desarrollo de una App de escritorio en **WPF** o **WinUI** que invoque al script.
- **🔬 Investigación Avanzada**:
  - **Art QR**: Procesamiento de imágenes mediante IA o algoritmos complejos para fusionar arte y códigos QR.
  - **Criptografía Post-Cuántica (PQC)**: Integración de librerías criptográficas de nueva generación una vez estandarizadas por el NIST.
  - **DPM (Direct Part Marking)**: Calibración específica para hardware de grabado láser industrial.

---

## ⚖️ Licencia y Patentes

- **Licencia**: Apache 2.0 (Libre uso, modificación y distribución).
- **Propiedad Intelectual**: Este software es una implementación original en PowerShell de diversos estándares públicos e internacionales.
- **Estándares y Patentes**:
  - **QR Code**: La tecnología QR Code es una marca registrada de **DENSO WAVE INCORPORATED**. Su uso aquí se basa en el estándar abierto **ISO/IEC 18004**. DENSO WAVE no ejerce derechos de patente sobre el uso del estándar en implementaciones conformes.
  - **PDF**: Cumple con **ISO 32000-1** (PDF 1.7) e **ISO 14289-1** (PDF/UA-1 para accesibilidad).
  - **SVG**: Implementación basada en las recomendaciones de la **W3C (Scalable Vector Graphics)** y cumplimiento de **WCAG 2.1** para accesibilidad web.
  - **PNG**: Basado en **ISO/IEC 15948:2004** (especificación W3C para redes).
  - **EPC QR**: Sigue la especificación **EPC069-12** del Consejo Europeo de Pagos para transferencias SEPA.
  - **Contactos**: vCard (IETF **RFC 6350**) and MeCard (estándar de facto de NTT DOCOMO).
- **Entorno de Ejecución**:
  - **PowerShell**: Este software utiliza el motor de automatización de Microsoft. PowerShell Core (7+) está licenciado bajo la **Licencia MIT**, mientras que Windows PowerShell 5.1 es un componente del sistema operativo Windows. Ambos permiten el uso y desarrollo de scripts de forma gratuita para fines personales y comerciales.
- **Restricciones**: No se implementan formatos propietarios cerrados como **SQRC** o **iQR**, ya que requieren algoritmos de cifrado y licencias específicas de DENSO WAVE.

---
*Documentación actualizada al 11 de febrero de 2026. Cumplimiento verificado bajo estándares ISO/IEC 18004:2024.*
