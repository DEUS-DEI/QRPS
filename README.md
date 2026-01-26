# 🔳 qrps: Motor Nativo de Códigos QR para PowerShell

`qrps` es una implementación **100% nativa en PowerShell** de los estándares internacionales para la generación y decodificación de códigos QR de alta fidelidad. Sin dependencias externas, permite operar en entornos restringidos garantizando cumplimiento normativo.

---

## ✨ Simbologías y Estándares Soportados

| Simbología | Estándar | Estado | Notas |
| :--- | :--- | :---: | :--- |
| **QR Code Modelo 2** | ISO/IEC 18004 | ✅ | Versiones 1-40. Soporte completo. |
| **QR Code Modelo 1** | ISO/IEC 18004:2000 | ✅ | Versiones 1-14. Compatibilidad histórica. |
| **Micro QR Code** | ISO/IEC 18004 Anexo E | ✅ | Versiones M1-M4 para espacios reducidos. |
| **rMQR (Rectangular)** | ISO/IEC 23941:2022 | ✅ | 27 versiones rectangulares optimizadas. |
| **GS1 QR Code** | GS1 General Spec | ✅ | Soporte FNC1 y Application Identifiers. |
| **Structured Append** | ISO/IEC 18004 | ✅ | División de datos en hasta 16 símbolos. |

---

## 📚 Cobertura de Anexos ISO/IEC 18004:2024

El motor implementa la mayoría de los anexos técnicos del estándar:

| Anexo | Descripción | Estado | Implementación en `qrps` |
| :--- | :--- | :---: | :--- |
| **Anexo A** | Tablas de capacidad de caracteres | ✅ | Tablas completas V1-V40 y M1-M4. |
| **Anexo B** | Polinomios generadores Reed-Solomon | ✅ | Aritmética GF(256) nativa. |
| **Anexo C** | Algoritmo de decodificación de referencia | ✅ | Implementado en el flag `-Decode`. |
| **Anexo D** | Identificadores de simbología (AIM ID) | ✅ | Soporte para `]Qn`. |
| **Anexo E** | Especificación de Micro QR Code | ✅ | Versiones M1, M2, M3 y M4. |
| **Anexo F** | Structured Append | ✅ | Modo de secuencia de hasta 16 símbolos. |
| **Anexo G** | Calidad de impresión (específico QR) | ✅ | Métricas de densidad y bloques 2x2. |
| **Anexo H** | Extended Channel Interpretation (ECI) | ✅ | ECI 26 (UTF-8) y otros automáticos. |
| **Anexo I** | Modo Kanji (Shift-JIS) | ✅ | Codificación y decodificación Shift-JIS. |
| **Anexo J** | Optimización de segmentación | ✅ | Motor de segmentación inteligente. |
| **Anexo N** | Diferencias con QR Modelo 1 | ✅ | Generación compatible con Modelo 1. |

### 🌐 Otros Estándares Relacionados
- **ISO/IEC 23941:2022 (rMQR)**: Implementación completa de los 5 anexos (A-E) para códigos rectangulares.
- **ISO/IEC 15418 / 15434**: Soporte de sintaxis GS1 para logística y trazabilidad.
- **ISO/IEC 15424**: Generación de prefijos AIM para lectores industriales.
- **ISO/IEC 15415 (Calidad)**: `qrps` proporciona un análisis preliminar de calidad, aunque no sustituye a un verificador certificado por hardware.

### 🛠️ Características Técnicas
- **Segmentación Inteligente**: Alterna automáticamente entre modos Numérico, Alfanumérico, Byte (UTF-8) y Kanji (Shift-JIS).
- **Corrección de Errores (ECC)**: Implementación completa de Reed-Solomon (GF 256) niveles L, M, Q, H.
- **Decodificación de Referencia**: Capacidad de leer y verificar códigos generados (PNG/SVG).
- **Reporte de Calidad**: Métricas de densidad, bloques 2x2 y cumplimiento de Quiet Zone.

---

## 💾 Formatos de Imagen y Compresión

| Formato | Estado | Tipo | Recomendación |
| :--- | :---: | :--- | :--- |
| **SVG** | ✅ | Vectorial | **Ideal**. Calidad infinita, menor peso, basado en texto. |
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

## 🚀 Guía de Inicio Rápido

### Generación Simple
```powershell
.\QRCode.ps1 -Data "Hola Mundo" -OutputPath "codigo.png"
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
