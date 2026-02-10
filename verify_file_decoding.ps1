
. .\QRCode.ps1

function Test-FileDecoding {
    $testDir = "test_files"
    if (-not (Test-Path $testDir)) { New-Item -ItemType Directory $testDir }

    Write-Host "--- Test A: Decode PNG (Standard QR) ---"
    $dataA = "PNG Decoding Test"
    $pngPath = Join-Path $testDir "test.png"
    # Generate
    $m_orig = New-QRCode -Data $dataA -OutputPath $pngPath -Symbol 'QR' -ShowConsole:$false
    
    # Import
    $m_imp = Import-QRCode $pngPath
    
    # Compare
    $diffs = 0
    for($r=0; $r -lt $m_orig.Size; $r++) {
        for($c=0; $c -lt $m_orig.Size; $c++) {
            if ($m_orig.Mod["$r,$c"] -ne $m_imp.Mod["$r,$c"]) {
                $diffs++
            }
        }
    }
    Write-Host "Diferencias encontradas entre matriz original e importada: $diffs"
    
    # Decode
    $cmd = ".\QRCode.ps1 -Decode -InputPath '$pngPath'"
    Write-Host "Running: $cmd"
    $output = Invoke-Expression $cmd
    $foundA = $false
    foreach($line in $output) { if ($line -match "Contenido:.*$dataA") { $foundA = $true; break } }
    if ($foundA) {
        Write-Host "SUCCESS: PNG decoded correctly." -ForegroundColor Green
    } else {
        Write-Host "FAILURE: PNG decoding failed." -ForegroundColor Red
    }

    Write-Host "`n--- Test B: Decode SVG (rMQR) ---"
    $dataB = "rMQR SVG Test"
    $svgPath = Join-Path $testDir "test.svg"
    # Generate
    New-QRCode -Data $dataB -OutputPath $svgPath -Symbol 'rMQR' -ShowConsole:$false
    # Decode
    $cmd = ".\QRCBScript.ps1 -Decode -InputPath '$svgPath'"
    Write-Host "Running: $cmd"
    $output = Invoke-Expression $cmd
    Write-Host ($output -join "`n")
    $foundB = $false
    foreach($line in $output) { if ($line -match "Contenido:.*rMQR SVG Test") { $foundB = $true; break } }
    if ($foundB) {
        Write-Host "SUCCESS: SVG decoded correctly." -ForegroundColor Green
    } else {
        Write-Host "FAILURE: SVG decoding failed." -ForegroundColor Red
    }
}

Test-FileDecoding
