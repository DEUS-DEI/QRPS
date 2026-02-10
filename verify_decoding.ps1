
. .\QRCBScript.ps1

function Test-QRDecoding {
    Write-Host "--- Test 1: Standard QR Decoding ---"
    $data = "Hello QR"
    $qr = New-QRCode -Data $data -ECLevel 'M' -Symbol 'QR' -ShowConsole:$false
    $decoded = ConvertFrom-QRCodeMatrix $qr
    if ($decoded.Text -eq $data) {
        Write-Host "SUCCESS: Standard QR decoded correctly." -ForegroundColor Green
    } else {
        Write-Host "FAILURE: Expected '$data', got '$($decoded.Text)'" -ForegroundColor Red
    }

    Write-Host "`n--- Test 2: rMQR Decoding ---"
    $dataRMQR = "rMQR Test"
    $rmqr = New-QRCode -Data $dataRMQR -Symbol 'rMQR' -Version "R11x43" -ShowConsole:$false
    $decodedRMQR = ConvertFrom-RMQRMatrix $rmqr
    if ($decodedRMQR.Text -eq $dataRMQR) {
        Write-Host "SUCCESS: rMQR decoded correctly." -ForegroundColor Green
    } else {
        Write-Host "FAILURE: Expected '$dataRMQR', got '$($decodedRMQR.Text)'" -ForegroundColor Red
    }

    Write-Host "`n--- Test 3: QR Decoding with RS Correction ---"
    $dataRS = "Error Correction Works"
    $qrRS = New-QRCode -Data $dataRS -ECLevel 'H' -Symbol 'QR' -ShowConsole:$false
    
    # Introduce an error: flip a bit in a non-functional module
    $found = $false
    for ($r=0; $r -lt $qrRS.Size; $r++) {
        for ($c=0; $c -lt $qrRS.Size; $c++) {
            if (-not [bool]$qrRS.Func.GetValue($r,$c)) {
                $qrRS.Mod.SetValue(1 - [int]$qrRS.Mod.GetValue($r,$c), $r, $c)
                $found = $true
                Write-Host "Introduced error at ($r,$c)"
                break
            }
        }
        if ($found) { break }
    }

    $decodedRS = ConvertFrom-QRCodeMatrix $qrRS
    if ($decodedRS.Text -eq $dataRS) {
        Write-Host "SUCCESS: QR with error decoded correctly using RS." -ForegroundColor Green
    } else {
        Write-Host "FAILURE: Expected '$dataRS', got '$($decodedRS.Text)'" -ForegroundColor Red
    }

    # Test 4: RS function directly
    try {
        Write-Host "`n--- Test 4: Reed-Solomon Direct Test ---"
        # GF(256) test: [3, 2, 1] with 2 EC bytes
        $msg = @(1, 2, 3, 0, 0) # 3 data, 2 EC
        # Use New-RS and ConvertFrom-ReedSolomon assuming they are available in QRCBScript.ps1
        $ec = New-RS @(1, 2, 3) 2
        $full = @(1, 2, 3) + $ec
        $full[1] = $full[1] -bxor 0x55 # Introduce an error
        $corrected = ConvertFrom-ReedSolomon $full 2
        if ($corrected.Data[0] -eq 1 -and $corrected.Data[1] -eq 2 -and $corrected.Data[2] -eq 3) {
            Write-Host "SUCCESS: RS Direct Test passed."
        } else {
            Write-Host "FAILURE: RS Direct Test failed. Got $($corrected.Data -join ',')"
        }
    } catch {
        Write-Host "ERROR in Test 4: $($_.Exception.Message)"
    }
}

Test-QRDecoding
