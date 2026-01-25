# 🚧 Estándares y Variantes QR Faltantes

## Resumen Ejecutivo

El generador actual implementa **QR Code Model 1 y Model 2** según ISO/IEC 18004, pero existen múltiples estándares, variantes y anexos adicionales que no están implementados. Este documento identifica las especificaciones faltantes y su relevancia para una implementación completa.

### Faltantes Dentro de QR Model 2
- **Decodificación** no implementada (solo generación)

---

## 📊 Tabla de Estándares Faltantes

| **Estándar/Variante** | **Estado** | **Estándar ISO** | **Prioridad** | **Complejidad** |
|:---|:---:|:---|:---:|:---:|
| **QR Code Model 1** | ✅ | ISO/IEC 18004:2000 | 🟡 Media | 🟢 Baja |
| **Micro QR Code** | ✅ | ISO/IEC 18004 Anexo | 🔴 Alta | 🟡 Media |
| **rMQR (Rectangular)** | ✅ | ISO/IEC 23941:2022 | 🔴 Alta | 🔴 Alta |
| **SQRC (Secure QR)** | ❌ | Propietario Denso | 🟡 Media | 🔴 Alta |
| **FrameQR** | ❌ | Propietario Denso | 🟢 Baja | 🟡 Media |
| **iQR Code** | ❌ | Propietario Denso | 🟡 Media | 🔴 Alta |
| **GS1 QR Code** | ✅ | GS1 General Spec | 🔴 Alta | 🟢 Baja |
| **Structured Append** | ✅ | ISO/IEC 18004 | 🟡 Media | 🟡 Media |
| **FNC1 Mode** | ✅ | ISO/IEC 18004 | 🔴 Alta | 🟢 Baja |
| **HCC2D (Prototype)** | ❌ | Experimental | 🟢 Baja | 🔴 Alta |

---

## 🔍 Análisis Detallado de Estándares Faltantes

### 1. **QR Code Model 1** ✅
**Estándar**: ISO/IEC 18004:2000 (Retirado)  
**Prioridad**: 🟡 Media | **Complejidad**: 🟢 Baja

#### Características:
- Versión original del QR Code (1994-2000)
- Sin patrones de alineación (alignment patterns)
- Máximo 14 versiones (vs 40 en Model 2)
- Capacidad limitada: máximo 707 caracteres numéricos
- Regiones funcionales diferentes en esquinas inferiores

#### Diferencias vs Model 2:
- **Patrones de Alineación**: Ausentes en Model 1
- **Capacidad**: ~50% menor que Model 2
- **Versiones**: V1-V14 únicamente
- **Compatibilidad**: Lectores modernos pueden leer ambos

#### Implementación:
- Soporte de versiones V1-V14
- Eliminación de patrones de alineación
- Compatibilidad con lectores modernos

---

### 2. **Micro QR Code** ✅
**Estándar**: ISO/IEC 18004 Anexo E  
**Prioridad**: 🔴 Alta | **Complejidad**: 🟡 Media

#### Características:
- **Tamaños**: 11×11, 13×13, 15×15, 17×17 módulos
- **Versiones**: M1, M2, M3, M4
- **Un solo patrón finder** (esquina superior izquierda)
- **Capacidad máxima**: 35 numéricos, 21 alfanuméricos, 15 bytes
- **Niveles EC**: Solo L y M (no Q ni H)

#### Especificaciones Técnicas:
| **Versión** | **Tamaño** | **Numérico** | **Alfanumérico** | **Byte** | **EC** |
|:---:|:---:|:---:|:---:|:---:|:---:|
| M1 | 11×11 | 5 | - | - | Solo detección |
| M2 | 13×13 | 10 | 6 | - | L, M |
| M3 | 15×15 | 23 | 14 | 9 | L, M |
| M4 | 17×17 | 35 | 21 | 15 | L, M |

#### Casos de Uso:
- Componentes electrónicos pequeños
- Etiquetas de medicamentos
- Joyería y relojes
- Circuitos impresos (PCB)

---

### 3. **rMQR (Rectangular Micro QR)** ✅
**Estándar**: ISO/IEC 23941:2022  
**Prioridad**: 🔴 Alta | **Complejidad**: 🔴 Alta

#### Estado:
Implementado experimentalmente. Soporta versiones R7x43 a R17x139.

#### Características:
- **Forma rectangular** (no cuadrada)
- **27 versiones**: R7×43 hasta R17×139
- **Ratio máximo**: 1:19 (ancho:alto)
- **Capacidad**: 10× mayor que Micro QR
- **Compatibilidad**: Espacios donde se usan códigos 1D

#### Especificaciones:
- **Versiones**: R7×43, R9×43, R11×27, R13×27, R15×43, R17×43, R7×59, R9×59, R11×43, R13×43, R15×59, R17×59, R7×77, R9×77, R11×59, R13×59, R15×77, R17×77, R7×99, R9×99, R11×77, R13×77, R15×99, R17×99, R7×139, R9×139, R11×99, R13×99, R15×139, R17×139
- **Finder patterns**: 2 patrones (esquinas opuestas)
- **Alignment patterns**: Según versión
- **Error correction**: L, M, H (no Q)

#### Aplicaciones:
- Etiquetas de productos alargadas
- Códigos en bordes de cajas
- Reemplazo de códigos de barras 1D
- Espacios rectangulares estrechos

---

### 4. **SQRC (Secure QR Code)** ❌
**Estándar**: Propietario Denso Wave  
**Prioridad**: 🟡 Media | **Complejidad**: 🔴 Alta

#### Características:
- **Encriptación**: Datos privados encriptados
- **Lectura dual**: Pública (todos) + Privada (autorizada)
- **Compatibilidad**: Lectores estándar ven solo datos públicos
- **Seguridad**: Clave de encriptación requerida para datos privados

#### Estructura:
```
[Datos Públicos] + [Datos Encriptados] + [Metadatos de Seguridad]
```

#### Casos de Uso:
- Documentos de identidad
- Tarjetas de acceso
- Información médica confidencial
- Sistemas de autenticación

---

### 5. **FrameQR** ❌
**Estándar**: Propietario Denso Wave  
**Prioridad**: 🟢 Baja | **Complejidad**: 🟡 Media

#### Características:
- **Marco personalizable**: Área central para diseño/logo
- **Funcionalidad completa**: Mantiene capacidad de lectura
- **Estética mejorada**: Integración visual con diseño
- **Canvas central**: Espacio libre para contenido visual

#### Aplicaciones:
- Marketing y publicidad
- Códigos decorativos
- Integración en diseños
- Branding corporativo

---

### 6. **iQR Code** ❌
**Estándar**: Propietario Denso Wave  
**Prioridad**: 🟡 Media | **Complejidad**: 🔴 Alta

#### Características:
- **Forma flexible**: Cuadrado o rectangular
- **Alta capacidad**: Hasta 40,000 caracteres numéricos
- **Múltiples tamaños**: Desde pequeño hasta muy grande
- **Reconstrucción**: Lectura parcial con alta tolerancia a daños

#### Especificaciones:
- **Versiones**: Múltiples configuraciones
- **Capacidad máxima**: 40,000 numéricos / 24,000 alfanuméricos
- **Error correction**: Niveles avanzados
- **Flexibilidad**: Adaptable a diferentes espacios

---

### 7. **GS1 QR Code** ✅
**Estándar**: GS1 General Specifications  
**Prioridad**: 🔴 Alta | **Complejidad**: 🟢 Baja

#### Características:
- **Estructura GS1**: Application Identifiers (AI)
- **FNC1**: Indicador de formato GS1 en primera posición
- **Datos estructurados**: GTIN, fechas, lotes, etc.
- **Trazabilidad**: Cadena de suministro global

#### Estructura de Datos:
```
FNC1 + (01)GTIN + (17)YYMMDD + (10)LOTE + (21)SERIAL
```

#### Application Identifiers Comunes:
- **(01)**: GTIN (Global Trade Item Number)
- **(17)**: Fecha de caducidad
- **(10)**: Número de lote
- **(21)**: Número de serie
- **(30)**: Cantidad variable

#### Implementación:
- FNC1 primera o segunda posición
- Datos GS1 provistos por el usuario con separador GS (ASCII 29)

---

### 8. **Structured Append** ✅
**Estándar**: ISO/IEC 18004 Modo 3  
**Prioridad**: 🟡 Media | **Complejidad**: 🟡 Media

#### Características:
- **Múltiples símbolos**: Datos divididos en varios QR
- **Secuencia ordenada**: Hasta 16 símbolos por secuencia
- **Reconstrucción**: Lectores combinan automáticamente
- **Paridad**: Verificación de integridad de secuencia

#### Estructura:
```
Modo: 0011 (4 bits)
Posición del símbolo: 4 bits (0-15)
Total de símbolos: 4 bits (1-16)
Paridad: 8 bits (XOR de datos)
```

#### Casos de Uso:
- Documentos largos
- Bases de datos extensas
- Información que excede capacidad de un QR
- Sistemas de respaldo distribuido

---

### 9. **FNC1 Mode** ✅
**Estándar**: ISO/IEC 18004 Modos 5 y 9  
**Prioridad**: 🔴 Alta | **Complejidad**: 🟢 Baja

#### Características:
- **Modo 5**: FNC1 en primera posición (GS1)
- **Modo 9**: FNC1 en segunda posición (AIM)
- **Separador de campos**: Carácter especial GS (ASCII 29)
- **Compatibilidad**: Sistemas de inventario y logística

#### Implementación:
- Modo 5 y 9 habilitados
- Application Indicator de 8 bits en modo 9

---

## 🎯 Prioridades de Implementación

### **Prioridad Alta** 🔴
1. **Micro QR Code**: ✅ Implementado
2. **rMQR**: ✅ Implementado
3. **GS1 QR Code**: ✅ Implementado
4. **FNC1 Mode**: ✅ Implementado

### **Prioridad Media** 🟡
1. **QR Code Model 1**: ✅ Implementado
2. **Structured Append**: ✅ Implementado
3. **SQRC**: ❌ Faltante (Aplicaciones de seguridad)
4. **iQR Code**: ❌ Faltante (Casos especializados)

### **Prioridad Baja** 🟢
1. **FrameQR**: ❌ Faltante (Principalmente estético)
2. **HCC2D**: ❌ Faltante (Experimental/prototipo)

---

## 📋 Anexos ISO/IEC 18004 Faltantes

### **Anexo A**: Tablas de Capacidad de Caracteres
- ✅ **Implementado**: Tablas completas V1-V40

### **Anexo B**: Polinomios Generadores
- ✅ **Implementado**: Reed-Solomon completo

### **Anexo C**: Algoritmo de Decodificación de Referencia
- ✅ **Implementado**: Lectura de formato (EC/máscara), desmascarado y extracción de datos para **QR Modelo 2**. Soporta segmentos Numérico, Alfanumérico, Byte (UTF-8), Kanji (Shift-JIS), ECI, FNC1 y Structured Append.
- ℹ️ **Alcance**: Decodificación de referencia para validación; no incluye reconstrucción RS ni rMQR.

### **Anexo D**: Parámetros de Calidad de Producción
- ✅ **Implementado**: Métricas de densidad de módulos oscuros, conteo de bloques 2×2 y recomendación de quiet zone mínima.
- ℹ️ **Uso**: Disponible vía flag `-QualityReport` en CLI.

### **Anexo E**: Micro QR Code
- ✅ **Implementado**: Especificación completa M1-M4

### **Anexo F**: Structured Append
- ✅ **Implementado**: Modo de múltiples símbolos soportado

### **Anexo G**: Ejemplos de Codificación
- ✅ **Implementado**: Ejemplos disponibles en documentación (lista_inputs.tsv)

---

## 🛠️ Roadmap de Implementación

### **Fase 1: Compatibilidad Comercial** (Completado)
- [x] FNC1 Mode (Modos 5 y 9)
- [x] GS1 QR Code con Application Identifiers
- [x] Structured Append básico
- [x] Validación de datos GS1

### **Fase 2: Variantes Compactas** (Completado)
- [x] Micro QR Code (M1-M4)
- [x] Optimización para espacios pequeños
- [x] Detección automática de tamaño óptimo
- [x] Exportación multi-formato (PNG y SVG)

### **Fase 3: Formatos Avanzados** (Completado)
- [x] rMQR (Rectangular Micro QR)
- [x] 27 versiones rectangulares
- [x] Algoritmos de optimización de forma
- [x] Compatibilidad con espacios 1D

### **Fase 4: Características Especializadas** (En progreso)
- [x] QR Code Model 1 (compatibilidad histórica)
- [x] Decodificación de referencia (QR Modelo 2)
- [x] Parámetros de calidad de producción (métricas)
- [ ] SQRC (investigación de encriptación)
- [ ] FrameQR (integración de diseño)
- [ ] iQR Code (análisis de viabilidad)

---

## 💡 Recomendaciones

### **Implementación Completada**
1. **FNC1 Mode / GS1**: ✅ Implementado y validado.
2. **Micro QR Code**: ✅ Implementado (M1-M4).
3. **rMQR**: ✅ Implementado (27 versiones rectangulares).
4. **QR Code Model 1**: ✅ Implementado para compatibilidad histórica.
5. **Decodificación de Referencia**: ✅ Implementada para validación de Modelo 2.
6. **Reporte de Calidad**: ✅ Implementado (densidad, bloques 2x2, quiet zone).

### **Investigación Requerida**
1. **SQRC**: Especificaciones de encriptación no públicas (Denso Wave).
2. **iQR Code**: Documentación técnica limitada y complejidad de reconstrucción.
3. **FrameQR**: Integración de marcos y logos sin comprometer la legibilidad.

### **Mejoras Técnicas Realizadas**
- ✅ **Modo AUTO**: Selección automática de la simbología más eficiente (Micro -> QR -> rMQR).
- ✅ **Modularización**: Estructura de código preparada para nuevas variantes.
- ✅ **Visualización**: Función `ShowConsole` compatible con todas las variantes.
- ✅ **Batch Processing**: Procesamiento masivo vía `lista_inputs.tsv`.

---

## 📊 Impacto en Adopción

### **Sin Implementación de Faltantes**
- ❌ Limitado a aplicaciones básicas (sin encriptación SQRC)
- ❌ Capacidad limitada para datos muy grandes (sin iQR Code)

### **Con Implementación Completa**
- ✅ Compatibilidad comercial total (incluyendo GS1 y espacios pequeños)
- ✅ Soporte para todos los casos de uso
- ✅ Adopción en industria y logística
- ✅ Flexibilidad para aplicaciones futuras

---

*Análisis realizado el 23 de enero de 2026*  
*Basado en estándares ISO/IEC 18004:2024, ISO/IEC 23941:2022 y especificaciones GS1*
