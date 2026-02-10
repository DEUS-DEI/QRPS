#Requires -Version 5.1

Describe "QR Code Generator - Robustness & Extensions" {
    BeforeAll {
        $ScriptPath = Join-Path $PSScriptRoot "QRCBScript.ps1"
        if (-not (Test-Path $ScriptPath)) {
            throw "QRCBScript.ps1 no encontrado en $ScriptPath"
        }
        # Pester 3.4.0 syntax: Should Be, Should Match, Should Throw
    }

    Context "Robustness - Set-StrictMode" {
        It "Debe ejecutar el script sin errores básicos de sintaxis o variables (StrictMode 2.0)" {
            { & $ScriptPath -Data "Test" -ShowConsole:$false -OutputPath "" } | Should Not Throw
        }
    }

    Context "Extensions - Data URI" {
        It "Debe generar una salida Base64 válida cuando -DataUri está presente" {
            $output = & $ScriptPath -Data "https://trae.ai" -DataUri -ShowConsole:$false
            $output | Should Match "data:image/png;base64,"
        }
    }

    Context "Extensions - ANSI Render" {
        It "ShowConsole no debe lanzar errores con diferentes tamaños de QR" {
            { & $ScriptPath -Data "Small" -ShowConsole -OutputPath "" } | Should Not Throw
            { & $ScriptPath -Data "Un texto mucho más largo para forzar una versión superior del código QR" -ShowConsole -OutputPath "" } | Should Not Throw
        }
    }

    Context "Extensions - EPS Format" {
        It "Debe crear un archivo .eps con cabecera PostScript válida" {
            $testEps = Join-Path $PSScriptRoot "test_unit.eps"
            if (Test-Path $testEps) { Remove-Item $testEps }
            
            & $ScriptPath -Data "EPS Test" -OutputPath $testEps | Out-Null
            
            (Test-Path $testEps) | Should Be $true
            $content = Get-Content $testEps -Raw -TotalCount 50
            $content | Should Match "%!PS-Adobe-3.0 EPSF-3.0"
            
            Remove-Item $testEps
        }
    }

    Context "Core - Type Safety" {
        It "El script principal debe manejar correctamente la generación de QR con tipos estrictos" {
            { & $ScriptPath -Data "TypeTest" -OutputPath "test.png" } | Should Not Throw
        }
    }
}
