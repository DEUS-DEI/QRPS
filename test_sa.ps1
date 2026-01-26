# Test Structured Append
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $PSScriptRoot "QRCode.ps1")

$data1 = "Hello "
$data2 = "World!"
$fullData = $data1 + $data2

Write-Host "--- Testing Structured Append ---" -ForegroundColor Cyan

# Calculate Parity
$parity = Get-StructuredAppendParity $fullData
Write-Host "Calculated Parity: $parity"

# Generate two QR codes
$qr1 = New-QRCode -Data $data1 -StructuredAppendIndex 0 -StructuredAppendTotal 2 -StructuredAppendParity $parity -Decode
$qr2 = New-QRCode -Data $data2 -StructuredAppendIndex 1 -StructuredAppendTotal 2 -StructuredAppendParity $parity -Decode

Write-Host "`n--- Verification ---" -ForegroundColor Cyan

function Get-SA-Info($m) {
    if ($m.Size -lt 21) {
        $bits = ExtractBitsMicro $m
        # Micro QR doesn't support SA in the same way? 
        # Actually ISO 18004 says SA is for QR, not Micro QR.
        return $null
    } else {
        $fi = ReadFormatInfo $m
        $um = UnmaskQR $m $fi.Mask
        $bits = ExtractBitsQR $um
        $allBytes = @()
        for ($i=0;$i -lt $bits.Count; $i += 8) {
            $byte = 0; for ($j=0;$j -lt 8; $j++) { $byte = ($byte -shl 1) -bor $bits[$i+$j] }
            $allBytes += $byte
        }
        $spec = $script:SPEC["$(($m.Size - 17) / 4)$($fi.EC)"]
        # Simplified decoding to just get segments
        $dec = DecodeQRStream $allBytes [int](($m.Size - 17) / 4)
        return $dec.Segments | Where-Object { $_.Mode -eq 'SA' }
    }
}

$sa1 = Get-SA-Info $qr1
$sa2 = Get-SA-Info $qr2

Write-Host "QR 1 SA Info: Index=$($sa1.Index), Total=$($sa1.Total), Parity=$($sa1.Parity)"
Write-Host "QR 2 SA Info: Index=$($sa2.Index), Total=$($sa2.Total), Parity=$($sa2.Parity)"

if ($sa1.Index -eq 0 -and $sa1.Total -eq 2 -and $sa1.Parity -eq $parity -and
    $sa2.Index -eq 1 -and $sa2.Total -eq 2 -and $sa2.Parity -eq $parity) {
    Write-Host "Structured Append Test PASSED" -ForegroundColor Green
} else {
    Write-Host "Structured Append Test FAILED" -ForegroundColor Red
    exit 1
}
