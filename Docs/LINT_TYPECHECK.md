# 🧪 Lint y Typecheck en este repo (PowerShell)

## ¿Qué son y para qué sirven?

### Lint
El lint analiza el código para detectar problemas de estilo, prácticas inseguras y errores potenciales. En PowerShell se usa para mantener scripts legibles, consistentes y con menos fallos en tiempo de ejecución.

### Typecheck
PowerShell es un lenguaje dinámico, por lo que no existe un typecheck formal como en lenguajes tipados. En su lugar se usa validación de sintaxis y análisis estático para detectar errores antes de ejecutar.

---

## Comandos recomendados para este repo

### 1) Lint (PSScriptAnalyzer)

Instalación (una vez por usuario):

```powershell
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force
```

Ejecución en el repo:

```powershell
Invoke-ScriptAnalyzer -Path .\ -Recurse
```

Para solo el archivo principal:

```powershell
Invoke-ScriptAnalyzer -Path .\QRCode.ps1
```

### 2) Typecheck (validación de sintaxis)

```powershell
[System.Management.Automation.Language.Parser]::ParseFile(
  "$PWD\QRCode.ps1",
  [ref]$null,
  [ref]$null
) | Out-Null
```

Si no hay errores, el comando no imprime nada. Si hay errores, PowerShell lanza una excepción con detalles.

---

## Ventajas y desventajas

### PSScriptAnalyzer
**Ventajas**
- Detecta malas prácticas comunes en PowerShell
- Ayuda a mantener estilo consistente
- Fácil de automatizar en CI

**Desventajas**
- Puede generar falsos positivos en scripts muy dinámicos
- Requiere instalación del módulo

### Validación de sintaxis
**Ventajas**
- Rápida y nativa
- Detecta errores de parseo antes de ejecutar

**Desventajas**
- No valida tipos reales ni flujo de datos
- No reemplaza pruebas funcionales

---

## Qué usar y cuándo

- **Lint**: siempre antes de cambios grandes o releases.
- **Sintaxis**: en cada cambio, idealmente antes de ejecutar scripts.

---

## Estado actual del repo

No hay comandos de lint/typecheck definidos en scripts del repo. Los anteriores son la recomendación estándar para PowerShell puro.
