# Benchmark for QRCBScript.ps1 optimization
param(
    [int]$Iterations = 10,
    [string]$TestData = "https://trae.ai/ - QR Code Power Shell Optimization Test - 2026"
)

$ErrorActionPreference = "Stop"
$scriptDir = if ($MyInvocation.MyCommand.Definition) { Split-Path -Parent $MyInvocation.MyCommand.Definition } else { Get-Location }
if (Test-Path (Join-Path $scriptDir "QRCBScript.ps1")) {
    . (Join-Path $scriptDir "QRCBScript.ps1")
} else {
    . .\QRCBScript.ps1
}

Write-Host "--- Starting Performance Benchmark ---" -ForegroundColor Cyan
Write-Host "Data: $TestData"
Write-Host "Iterations: $Iterations"
Write-Host ""

# Dummy call to warm up the script
$null = New-QRCode -Data "Warmup" -Model "QR" -Version "1" -EC "L" -Quiet 0

function Measure-QRGeneration {
    param([string]$Model, [string]$Version, [string]$EC)
    
    $times = New-Object System.Collections.Generic.List[double]
    for ($i = 0; $i -lt $Iterations; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = New-QRCode -Data $TestData -Model $Model -Version $Version -EC $EC -Quiet 0
        $sw.Stop()
        $times.Add($sw.Elapsed.TotalMilliseconds)
    }
    
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    return @{ Avg = $avg; Min = $min }
}

# Test standard QR
Write-Host "Testing Standard QR (V10, M)..." -NoNewline
$resQR = Measure-QRGeneration -Model "QR" -Version "10" -EC "M"
Write-Host " Avg: $($resQR.Avg.ToString('F2')) ms" -ForegroundColor Green

# Test Micro QR
Write-Host "Testing Micro QR (M4, M)..." -NoNewline
$resMicro = Measure-QRGeneration -Model "MicroQR" -Version "M4" -EC "M"
Write-Host " Avg: $($resMicro.Avg.ToString('F2')) ms" -ForegroundColor Green

# Test rMQR
Write-Host "Testing rMQR (R13x77, M)..." -NoNewline
$resRMQR = Measure-QRGeneration -Model "rMQR" -Version "R13x77" -EC "M"
Write-Host " Avg: $($resRMQR.Avg.ToString('F2')) ms" -ForegroundColor Green

Write-Host ""
Write-Host "Benchmark Completed." -ForegroundColor Cyan
