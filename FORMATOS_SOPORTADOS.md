# Formatos de Imagen Soportados y Análisis Técnico

Este documento detalla los formatos de exportación soportados por el motor `qrps`, así como un análisis de las mejores opciones según el caso de uso.

## 🚀 Formatos Soportados Actualmente

| Formato | Tipo | Estado | Razón Técnica |
| :--- | :--- | :--- | :--- |
| **PNG** | Raster | ✅ Soportado | Es el estándar para códigos de barras. Compresión sin pérdida (lossless) y soporte para paleta indexada de 1 bit. |
| **SVG** | Vectorial | ✅ Soportado | Calidad infinita con el menor tamaño de archivo posible. Basado en texto (XML), ideal para web e impresión. |
| **BMP** | Raster | 🟡 Parcial | Soportado internamente por .NET. Es la representación más cercana al "raw" o crudo de la memoria. |
| **JPEG** | Raster | ❌ No recomendado | Introduce artefactos de compresión (ruido) en los bordes de los módulos, lo que puede romper la decodificación. |
| **WebP** | Raster | ❌ No nativo | Requiere librerías externas o PowerShell 7+. No disponible en PowerShell 5.1 estándar. |

---

## 🔍 Análisis de Calidad y Compresión

### 1. ¿Cuál es la imagen más pequeña posible sin pérdida?
La imagen más pequeña posible es un **PNG de 1x1 píxel por módulo**.
*   Para un QR V1 (21x21) + 4 módulos de margen, la imagen sería de **29x29 píxeles**.
*   Al usar una paleta de 1 bit (blanco y negro), el tamaño del archivo puede ser de apenas **~100-200 bytes**.

### 2. Formato "Raw" de Mayor Calidad
El formato **BMP (Bitmap)** es el más cercano al origen de la imagen en memoria. No tiene compresión, por lo que cada píxel se mapea directamente. Sin embargo, para códigos QR, un **PNG** es idéntico en calidad (píxel por píxel) pero mucho más eficiente en almacenamiento.

### 3. Mayor Compresión Sin Pérdida (Lossless)
El ganador es **SVG**. Al ser un formato vectorial, no almacena píxeles sino instrucciones matemáticas (ej. "dibuja un cuadrado en X,Y"). 
*   Para un rMQR grande, un SVG puede ocupar un **90% menos** que un PNG de alta resolución.

### 4. Mayor Compresión con Pérdida (Perceptualmente aceptable)
Aunque se podría usar **JPEG** con alta calidad (>90), el riesgo de error de lectura es alto. **WebP** es superior en este aspecto, permitiendo archivos minúsculos con bordes mucho más limpios que JPEG, aunque sigue siendo inferior a PNG para este caso de uso específico.

---

## 🛠️ Limitaciones Técnicas

1.  **JPEG**: No se incluye por defecto porque el algoritmo de compresión por bloques (DCT) difumina los bordes de los módulos negros, creando "fantasmas" grises que confunden a los escáneres láser y de cámara.
2.  **WebP/HEIF**: No se incluyen para mantener el script **"Pure PowerShell"** sin dependencias de binarios externos o instalaciones complejas.
3.  **TIFF**: Soportado por .NET, pero rara vez usado en aplicaciones modernas de códigos QR debido a su complejidad y peso.

---
*Documento generado para el motor qrps - 2026*
