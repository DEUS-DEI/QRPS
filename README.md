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
- **Exportación PDF Nativa (Puro PowerShell)**: Generación directa de archivos PDF binarios sin dependencias externas (sin necesidad de Microsoft Edge). Soporta vectores limpios, marcos decorativos, múltiples líneas de texto, incrustación de logos (PNG/JPG) y degradados (lineales/radiales) con soporte total para caracteres especiales (ñ, á, é, etc.).
- **Layouts y Conversión de Imágenes**: Sistema de rejillas (Grid 4x4, 4x5, 6x6) para catálogos automáticos y conversor integrado de carpetas de imágenes a PDF manteniendo el aspecto original.
- **Texto Inferior y Etiquetas**: Soporte para múltiples líneas de texto debajo del QR. En procesamiento por lotes, detecta automáticamente columnas `Label1` a `Label5` y soporta el carácter `\n` para saltos de línea manuales con centrado dinámico e independiente por línea.
- **Marcos Decorativos (Frames)**: Capacidad de añadir un marco sólido con texto personalizado (ej: "ESCANEAME") en la parte superior, ideal para llamadas a la acción.
- **Personalización Estética**: Soporte para colores sólidos, degradados (lineales y radiales), módulos redondeados y máscaras automáticas para logos.
- **Procesamiento Multi-formato**: Permite generar simultáneamente SVG, PDF y PNG en un solo proceso por lotes.
- **Formatos Estructurados**: Funciones integradas para generar tarjetas de contacto (vCard) y configuraciones de WiFi.
- **Decodificación de Referencia**: Capacidad de leer y verificar códigos generados (PNG/SVG).
- **Reporte de Calidad**: Métricas de densidad, bloques 2x2 y cumplimiento de Quiet Zone.

---

## 📄 Cumplimiento de Estándares PDF

El motor de exportación PDF de `qrps` es una implementación binaria nativa diseñada para cumplir con los estándares de archivo y accesibilidad más exigentes sin dependencias de terceros.

### 🏛️ Estándares Base e ISO
| Estándar | Descripción | Estado | Notas Técnicas |
| :--- | :--- | :---: | :--- |
| **ISO 32000-1:2008** | PDF 1.7 | ✅ | Estándar base de la arquitectura del motor. |
| **ISO 19005-2** | PDF/A-2b (Archivo) | ✅ | Cumplimiento de preservación visual a largo plazo. |
| **ISO 14289-1** | PDF/UA-1 (Accesibilidad) | ✅ | Estructura lógica dinámica (`StructTreeRoot`), etiquetas de figura y mapeo `/Pg`. |
| **ISO 16684-1** | XMP (Metadatos) | ✅ | Inclusión de esquemas Dublin Core y PDF/A-ID. |
| **ISO 32000-1 Anexo G** | PDF Linearizado | 🟡 | Diccionario de linealización (Obj 1) presente para optimización básica. |
| **ISO 10646** | Unicode (ToUnicode) | ✅ | Mapeo CMap para garantizar extracción de texto correcta. |
| **ICC.1:2022** | Perfiles de Color sRGB | ✅ | Perfil de color incrustado para consistencia cromática. |

### 🛠️ Detalles de Implementación (Anexos ISO 32000-1)
- **Anexo A (Gráficos)**: Soporte completo de operadores de trazado (rect, fill, stroke).
- **Anexo E (Coordenadas)**: Uso estricto del sistema de coordenadas de usuario PDF.
- **Anexo K (Tagged PDF)**: Implementación de contenido marcado (`BDC`/`EMC`), árbol de estructura dinámico y población automática del array `/K` en `StructTreeRoot`.
- **Accesibilidad Avanzada**: Vinculación de elementos estructurales con páginas específicas mediante referencias `/Pg` para navegación fluida en lectores de pantalla.

### ⚠️ Limitaciones y No Implementados (Razones Técnicas)
| Estándar | Estado | Razón Técnica |
| :--- | :---: | :--- |
| **ISO 32000-2:2020 (PDF 2.0)** | ❌ | Requiere cambios en el manejo de namespaces y cifrado no críticos para QR. |
| **ISO 32000-1 Anexo B (Compresión)** | ❌ | Los flujos se mantienen sin comprimir para maximizar la velocidad en PowerShell. |
| **ISO 32000-1 Anexo C (Cifrado)** | ❌ | Implementar AES/RC4 de forma nativa en PS sin DLLs externas compromete la portabilidad. |
| **ISO 32000-1 Anexo I (JavaScript)** | ❌ | Excluido por diseño para garantizar la seguridad del documento. |
| **ISO 15930 (PDF/X)** | ❌ | Orientado a pre-prensa profesional; requiere gestión de color CMYK avanzada. |
| **ETSI PAdES / Firmas** | ❌ | Requiere infraestructura de clave pública (PKI) compleja para una implementación nativa. |

---

## 🖼️ Cumplimiento de Estándares PNG y SVG

El motor `qrps` genera archivos PNG y SVG utilizando métodos nativos de .NET y generación de texto XML, respectivamente, cumpliendo con los estándares de la industria para máxima compatibilidad.

### 🖼️ Estándares PNG (Portable Network Graphics)
| Estándar / Norma | Estado | Notas Técnicas |
| :--- | :---: | :--- |
| **ISO/IEC 15948 (PNG)** | ✅ | Estándar principal. Generado vía `System.Drawing.Bitmap`. |
| **RFC 1950 / 1951 (ZLIB/Deflate)** | ✅ | Utilizado internamente por el motor de compresión de .NET. |
| **IEC 61966-2-1 (sRGB)** | ✅ | Espacio de color estándar para visualización web. |
| **ICC.1 (Perfiles de Color)** | 🟡 | Se asume sRGB por defecto; no se incrustan perfiles personalizados para mantener la simplicidad binaria. |
| **ISO/IEC 10646 (Unicode)** | ✅ | Soporte para renderizado de texto en etiquetas inferiores. |
| **IANA MIME image/png** | ✅ | Identificación correcta para transporte y servidores web. |

### 🎨 Estándares SVG (Scalable Vector Graphics)
| Estándar / Norma | Estado | Notas Técnicas |
| :--- | :---: | :--- |
| **W3C SVG 1.1 (2nd Edition)** | ✅ | Perfil base de generación para máxima compatibilidad. |
| **W3C XML 1.0 / Namespaces** | ✅ | Generación estricta con declaración de encoding UTF-8. |
| **W3C CSS (Inline Styles)** | ✅ | Uso de estilos en línea y @import para Google Fonts. |
| **W3C XLink** | ✅ | Soporte para incrustación de logos PNG en Base64. |
| **W3C Accessibility (WCAG)** | ✅ | Inclusión de tags `title`, `desc`, `role="img"` y `aria-labelledby` para máxima accesibilidad (WCAG 2.1). |
| **MIME image/svg+xml** | ✅ | Registro estándar para entrega web segura. |

### ⚠️ Limitaciones PNG y SVG (Razones Técnicas)
| Estándar / Característica | Estado | Razón Técnica |
| :--- | :---: | :--- |
| **APNG (Animated PNG)** | ❌ | No relevante para códigos QR estáticos; incrementa complejidad innecesariamente. |
| **MNG/JNG (Multi-image)** | ❌ | Estándares obsoletos o de nicho no soportados por .NET nativo. |
| **SVG SMIL (Animación)** | ❌ | Las animaciones XML pueden comprometer la legibilidad del código QR por parte de los escáneres. |
| **SVG Filter Effects (Blur/Shadow)** | ❌ | Se evitan para mantener la nitidez de los bordes (`crispEdges`), crítica para la decodificación. |
| **ECMAScript (Scripts en SVG)** | ❌ | Excluido por diseño para cumplir con políticas de seguridad (CSP) y evitar falsos positivos de malware. |

### 🔡 Estándares Tipográficos y Otros
- **WOFF / WOFF2**: Soportado indirectamente mediante la integración de **Google Fonts** vía CSS `@import`.
- **Open Font Format**: Compatibilidad con fuentes instaladas en el sistema para renderizado PNG.
- **CSP (Content Security Policy)**: Los SVGs generados son compatibles con políticas de seguridad modernas al evitar scripts externos (`ECMAScript` excluido por diseño).

---
| :--- | :---: | :--- | :--- |
| **SVG** | ✅ | Vectorial | **Ideal**. Calidad infinita, menor peso, basado en texto. |
| **PDF** | ✅ | Vectorial | **Estándar Impresión**. Generado 100% nativo (binario) para funciones core. |
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
| `QRPS_FormatoSalida` | Formato de imagen: `svg`, `pdf`, `png` o combinaciones (ej: `svg,pdf`). | `pdf` |
| `QRPS_PdfUnico` | Genera un solo archivo PDF con todas las páginas (`si`/`no`). | `no` |
| `QRPS_PdfUnicoNombre` | Nombre del archivo PDF combinado resultante. | `qr_combinado.pdf` |
| `QRPS_LogoPath` | Ruta al logo (SVG/PNG) para incrustar en el centro. | (Vacío) |
| `QRPS_LogoScale` | Porcentaje del tamaño del logo respecto al QR. | `20` |
| `QRPS_ColorFront` | Color principal del QR (HEX). | `#000000` |
| `QRPS_ColorFront2` | Segundo color para degradados (HEX, opcional). | (Vacío) |
| `QRPS_ColorBack` | Color de fondo (HEX). | `#ffffff` |
| `QRPS_TipoDegradado` | Tipo de degradado: `linear` o `radial`. | `linear` |
| `QRPS_Redondeado` | Nivel de redondeado de módulos (0 a 0.5). | `0` |
| `QRPS_FrameText` | Texto para el marco decorativo (ej: ESCANEAME). | (Vacío) |
| `QRPS_FrameColor` | Color del marco decorativo (HEX). | `#000000` |
| `QRPS_FontFamily` | Familia de fuentes (ej: Arial, sans-serif). | `Arial, sans-serif` |
| `QRPS_GoogleFont` | Nombre de Google Font a importar automáticamente. | (Vacío) |
| `QRPS_MenuTimeout` | Segundos de espera en el menú de selección de listas. | `5` |
| `QRPS_IndiceColumna` | Columna del TSV para el dato del QR. Las demás se usan como texto. | `1` |
| `QRPS_NivelEC` | Nivel de corrección de errores: `L, M, Q, H`. | `M` |
| `QRPS_TamanoModulo` | Tamaño de cada módulo (pixel/punto). | `10` |
| `QRPS_ColorFront` | Color de los módulos (HEX). | `#000000` |
| `QRPS_ColorFront2` | Segundo color para degradado (Opcional). | `""` |
| `QRPS_ColorBack` | Color de fondo (HEX). | `#ffffff` |
| `QRPS_Redondeado` | Nivel de redondeado de módulos (0 a 0.5). | `0` |
| `QRPS_TipoDegradado` | Tipo de degradado (`linear` o `radial`). | `linear` |

---

## 🚀 Guía de Inicio Rápido

### Lanzador Fácil (Recomendado)
Si prefieres no usar la línea de comandos de PowerShell, puedes usar el lanzador interactivo:
- Ejecuta **run_qrps.bat** para acceder al menú simplificado:
  1. Procesamiento por lotes (usando `config.ini`).
  2. Generación rápida (texto manual + opción de logo).
  3. Decodificación de archivos.

### Procesamiento por Lotes Avanzado (TSV)

El motor procesa archivos TSV (separados por tabuladores) permitiendo una personalización total por cada fila. Puedes incluir las siguientes columnas opcionales:

| Columna | Descripción | Ejemplo |
| :--- | :--- | :--- |
| `Data` | El contenido que se codificará en el QR (URL, texto, etc.). | `https://google.com` |
| `Frame` | Texto para el marco decorativo superior. | `ESCANEAME` |
| `FrameColor` | Color hexadecimal para el marco. | `#FF0000` |
| `Rounded` | Nivel de redondeado de los módulos (0 a 1). | `0.5` |
| `ForegroundColor` | Color de los módulos del QR. | `#0000FF` |
| `Label1` ... `Label5` | Líneas de texto adicionales debajo del QR. | `Página 1`, `Línea 2` |

*Nota: También puedes usar `\n` dentro de cualquier celda de texto para forzar saltos de línea adicionales.*

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

### Personalización Estética
```powershell
# QR Azul con fondo gris claro y módulos redondeados
.\QRCode.ps1 -Data "Hola" -ForegroundColor "#0000FF" -BackgroundColor "#F0F0F0" -Rounded 0.3 -OutputPath "qr_estilo.svg"
```

### Personalización Estética (CLI)
```powershell
# QR con degradado lineal, módulos redondeados y marco decorativo
.\QRCode.ps1 -Data "Hola" -ForegroundColor "#0000FF" -ForegroundColor2 "#00FFFF" -GradientType "linear" -Rounded 0.5 -FrameText "ESCANEAME" -FrameColor "#0000FF" -OutputPath "qr_estilo.svg"

# Uso de fuentes personalizadas de Google
.\QRCode.ps1 -Data "Hola" -BottomText "Línea 1" -GoogleFont "Roboto" -FontFamily "Roboto, sans-serif" -OutputPath "qr_google_font.pdf"
```

### Procesamiento por Lotes (CLI)
```powershell
# Procesar una lista y generar un PDF único con todos los QRs
.\QRCode.ps1 -InputFile "lista.tsv" -OutputDir "mis_qrs" -PdfUnico -PdfUnicoNombre "catalogo.pdf"

# Procesar con personalización estética aplicada a todo el lote
.\QRCode.ps1 -InputFile "lista.tsv" -ForegroundColor "#D40000" -Rounded 0.5 -PdfUnico
```

### Formatos Estructurados (vCard / WiFi / Otros)

El motor soporta diversos formatos de datos estándar para acciones automáticas al escanear:

| Tipo | Formato de Datos | Descripción |
| :--- | :--- | :--- |
| **vCard** | `BEGIN:VCARD;VERSION:3.0;FN:Nombre;...;END:VCARD` | Tarjeta de contacto completa |
| **WiFi** | `WIFI:S:MiRed;T:WPA;P:Clave;;` | Configuración de red inalámbrica |
| **Email** | `MATMSG:TO:info@ej.com;SUB:Hola;BODY:Texto;;` | Preparar envío de correo |
| **Teléfono** | `tel:+34911111222` | Iniciar llamada telefónica |
| **SMS** | `SMSTO:+34911111222:Mensaje` | Preparar envío de SMS |
| **Geoloc** | `geo:40.41,-3.70` | Abrir coordenadas en mapas |
| **Calendario** | `BEGIN:VEVENT;SUMMARY:Cita;DTSTART:...;END:VEVENT` | Agregar evento al calendario |

```powershell
# Ejemplo: Generar una vCard (Contacto)
$contacto = New-vCard -Name "Juan Perez" -Tel "+34600000000" -Email "juan@ejemplo.com"
.\QRCode.ps1 -Data $contacto -OutputPath "contacto.pdf"
```

### Biblioteca de Ejemplos (Datos para Lotes)

Copia y pega estos datos en un archivo de texto (ej: `mis_datos.tsv`) para procesarlos por lotes. El formato es `Dato [Tab] Tipo [Tab] Descripción`.

| Dato | Tipo | Descripción |
| :--- | :--- | :--- |
| `https://github.com/DEUS-DEI/qrps` | `URL` | Repositorio Oficial |
| `WIFI:S:MiRed;T:WPA;P:Contraseña123;;` | `WIFI` | Configuración WiFi |
| `BEGIN:VCARD;VERSION:3.0;FN:Juan Perez;TEL:+34911111222;EMAIL:juan@ejemplo.com;END:VCARD` | `VCARD` | Contacto VCF |
| `tel:+34911111222` | `TEL` | Teléfono Soporte |
| `SMSTO:+34911111222:Hola` | `SMS` | Mensaje SMS |
| `geo:40.4168,-3.7038` | `GEO` | Puerta del Sol, Madrid |
| `MATMSG:TO:soporte@ejemplo.com;SUB:Consulta;BODY:Hola;;` | `EMAIL` | Email de Soporte |
| `BEGIN:VEVENT;SUMMARY:Reunion;DTSTART:20260124T100000Z;DTEND:20260124T110000Z;END:VEVENT` | `CALENDAR` | Evento Calendario |
| `01012345678901281724010110ABC` | `GS1` | GS1 (GTIN + Exp + Lote) |
| `Dato con SA` | `SA` | Structured Append (Auto-split) |
| `Micro QR Data` | `MICRO` | Micro QR Code |
| `Rectangular QR` | `RMQR` | rMQR (Rectangular) |
| `漢字東京` | `KANJI` | Texto en Kanji |
| `Datos con Ñ, á, é...` | `UTF8` | Caracteres Especiales |

### Personalización con Logos

El motor permite incrustar logos en formato **SVG, PNG o JPG**. Al detectar un logo, el sistema fuerza automáticamente el nivel de error a **H (High)** para garantizar la lectura, incluso con la obstrucción central.

#### 🛠️ Matriz de Compatibilidad de Logos

| Formato Salida | Logo SVG | Logo PNG/JPG | Notas |
| :--- | :---: | :---: | :--- |
| **SVG** | ✅ | ✅ | El logo SVG se incrusta como vectores; el PNG como Base64. |
| **PDF (Nativo)** | ❌ | ✅ | Requiere logos rasterizados (PNG/JPG) para el motor binario. |
| **PNG** | ❌ | ✅ | Requiere logos rasterizados (PNG/JPG). |

> [!TIP]
> Si utilizas el procesamiento por lotes (TSV), asegúrate de que el nombre de la columna sea exactamente `Logo`. El motor es ahora robusto contra caracteres invisibles (BOM) en los encabezados.

```powershell
# Ejemplo: Generar QR con logo PNG (máxima compatibilidad)
.\QRCode.ps1 -Data "Dato con Logo" -LogoPath ".\logo.png" -LogoScale 20 -OutputPath "qr_final.pdf"
```

### rMQR (Rectangular)
```powershell
.\QRCode.ps1 -Data "Dato Alargado" -Symbol "rMQR" -OutputPath "rectangular.svg"
```

### Layouts y Conversión de Imágenes (CLI)
```powershell
# Generar PDF por lotes con Layout Grid4x4
.\QRCode.ps1 -InputFile "lista.tsv" -PdfUnico -Layout "Grid4x4" -OutputPath "catalogo_4x4.pdf"

# Convertir carpeta de imágenes a PDF con Layout Grid6x6
.\QRCode.ps1 -ImageDir ".\MisFotos" -Layout "Grid6x6" -OutputPath "galeria.pdf"
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
| **verify_decoding.ps1** | Validación de Algoritmos | Prueba Reed-Solomon, corrección de errores y decodificación interna. |
| **verify_file_decoding.ps1** | Integración de Archivos | Valida el ciclo completo de exportación y lectura de PNG/SVG. |
| **test_rmqr.ps1** | Simbología rMQR | Valida las 27 versiones rectangulares y su decodificación. |
| **test_sa.ps1** | Structured Append | Verifica la división de datos y el cálculo de paridad ISO 15434. |

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
- **ISO/IEC 18004:2024**: Códigos QR (Modelos 1 y 2), Micro QR (M1-M4) y **rMQR (Rectangular)**. Soporte completo para todos los modos de codificación (Numérico, Alfanumérico, Byte, Kanji).
- **ISO/IEC 15424**: Identificadores de Portador (AIM IDs) para una identificación profesional del tipo de código (prefijos `]Qn`, `]Mn`, `]rn`).

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
*Análisis y cumplimiento actualizado al 27 de enero de 2026 bajo estándares ISO/IEC.*
