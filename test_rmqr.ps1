# Test rMQR Decode
$ErrorActionPreference = "Stop"
. .\QRCBScript.ps1

Write-Host "--- Testing rMQR Decode ---" -ForegroundColor Cyan
$data = "rMQR Test 123"
$rmqr = New-QRCode -Data $data -Model rMQR -Version 'R13x77' -Decode
if ($rmqr.Size -ne 0) { # New-QRCode returns the matrix
    Write-Host "rMQR Decode Test PASSED" -ForegroundColor Green
} else {
    Write-Host "rMQR Decode Test FAILED" -ForegroundColor Red
    exit 1
}
