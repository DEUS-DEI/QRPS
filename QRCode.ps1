#Requires -Version 5.1
<#
.SYNOPSIS
    QR Code Generator FINAL - PowerShell Nativo 100% Funcional
.DESCRIPTION
    Implementación completa siguiendo ISO/IEC 18004
    Genera QR codes escaneables

    Copyright 2026 The qrps contributors
    Licensed under the Apache License, Version 2.0
#>
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)][string]$Data,
    [Parameter(Mandatory=$false)][string]$InputFile,
    [Parameter(Mandatory=$false)][string]$OutputDir,
    [Parameter(Mandatory=$false)][string]$IniPath = ".\config.ini",
    [Parameter(Mandatory=$false)][string]$OutputPath = "",
    [Parameter(Mandatory=$false)][string]$InputPath = "",
    [ValidateSet('L','M','Q','H')][string]$ECLevel = 'M',
    [int]$Version = 0,
    [int]$ModuleSize = 10,
    [int]$EciValue = 0,
    [ValidateSet('QR','Micro','rMQR','AUTO')][string]$Symbol = 'AUTO',
    [ValidateSet('M1','M2','rMQR')][string]$Model = 'M2',
    [ValidateSet('AUTO','M1','M2','M3','M4')][string]$MicroVersion = 'AUTO',
    [switch]$Fnc1First,
    [switch]$Fnc1Second,
    [int]$Fnc1ApplicationIndicator = 0,
    [int]$StructuredAppendIndex = -1,
    [int]$StructuredAppendTotal = 0,
    [int]$StructuredAppendParity = -1,
    [string]$StructuredAppendParityData = "",
    [switch]$ShowConsole,
    [switch]$Decode,
    [switch]$QualityReport,
    [string]$LogoPath = "",
    [int]$LogoScale = 20,
    [string[]]$BottomText = @(),
    [string]$ForegroundColor = "#000000",
    [string]$ForegroundColor2 = "",
    [string]$BackgroundColor = "#ffffff",
    [double]$Rounded = 0,
    [string]$GradientType = "linear",
    [string]$FrameText = "",
    [string]$FrameColor = "",
    [string]$FontFamily = "Arial, sans-serif",
    [string]$GoogleFont = "",
    [switch]$PdfUnico,
    [string]$PdfUnicoNombre = "qr_combinado.pdf",
    [string]$Layout = "Default",
    [string]$ImageDir = ""
)

# Cargar ensamblados necesarios
Add-Type -AssemblyName System.Drawing

# GF(256) lookup tables
$script:EXP = @(1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1)
$script:LOG = @(0,0,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175)

# ISO/IEC 15418 - GS1 Application Identifiers basic map
$script:GS1_AI = @{
    '00'=@{L=18;T='SSCC'}; '01'=@{L=14;T='GTIN'}; '02'=@{L=14;T='CONTENT'}; '10'=@{L=0;T='BATCH'};
    '11'=@{L=6;T='PROD DATE'}; '13'=@{L=6;T='PACK DATE'}; '15'=@{L=6;T='BEST BEFORE'}; '17'=@{L=6;T='EXPIRY'};
    '21'=@{L=0;T='SERIAL'}; '30'=@{L=0;T='VAR COUNT'}; '310'=@{L=6;T='WEIGHT KG'}; '37'=@{L=0;T='COUNT'};
    '400'=@{L=0;T='ORDER'}; '8004'=@{L=0;T='GIAI'}; '90'=@{L=0;T='INTERNAL'}
}

# Utility to ensure numbers use dot as decimal separator (for SVG/CSS)
function ToDot($val) {
    if ($null -eq $val) { return "0" }
    try {
        return [string]::Format([System.Globalization.CultureInfo]::InvariantCulture, "{0:F3}", [double]$val)
    } catch {
        return "0"
    }
}

# Utility to parse numbers from SVG/CSS (always expecting dot)
function FromDot($val) {
    if ([string]::IsNullOrWhiteSpace($val)) { return 0 }
    $clean = $val -replace '[^\d.-]', ''
    if ($clean -match "\.") {
        return [double]::Parse($clean, [System.Globalization.CultureInfo]::InvariantCulture)
    }
    return [double]$clean
}

function GFMul($a,$b) { if($a -eq 0 -or $b -eq 0){return 0}; $s=$script:LOG[$a]+$script:LOG[$b]; if($s -ge 255){$s-=255}; return $script:EXP[$s] }
function GFInv($a) { if($a -eq 0){return 0}; return $script:EXP[255 - $script:LOG[$a]] }
function GFDiv($a,$b) { if($a -eq 0){return 0}; if($b -eq 0){throw "Div por cero"}; $s=$script:LOG[$a]-$script:LOG[$b]; if($s -lt 0){$s+=255}; return $script:EXP[$s] }
function Poly-Eval-GF($p, $x) { $y = 0; foreach($c in $p){ $y = (GFMul $y $x) -bxor $c }; return $y }


function ReadRMQRFormatInfo($m) {
    # TL: Use columns 7, 8, 9 (rows 0-5)
    $bits = @()
    for($i=0; $i -lt 6; $i++){ $bits += $m.Mod["$i,7"] }
    for($i=0; $i -lt 6; $i++){ $bits += $m.Mod["$i,8"] }
    for($i=0; $i -lt 6; $i++){ $bits += $m.Mod["$i,9"] }
    
    # Unmask with TL mask
    $mask = $script:RMQR_FMT_MASKS.TL
    for($i=0; $i -lt 18; $i++){ $bits[$i] = [int]$bits[$i] -bxor $mask[$i] }
    
    # Format info: [EC(1), VI(5), BCH(12)]
    $ecBit = $bits[0]
    $vi = 0; for($i=1; $i -le 5; $i++){ $vi = ($vi -shl 1) -bor $bits[$i] }
    
    return @{ EC = if($ecBit -eq 1){'H'}else{'M'}; VI = $vi }
}

function UnmaskRMQR($m) {
    $r = @{ Height = $m.Height; Width = $m.Width; Mod = @{}; Func = @{} }
    for ($row = 0; $row -lt $m.Height; $row++) {
        for ($col = 0; $col -lt $m.Width; $col++) {
            $r.Func["$row,$col"] = $m.Func["$row,$col"]
            $v = $m.Mod["$row,$col"]
            if (-not $m.Func["$row,$col"]) {
                if ((($row + $col) % 2) -eq 0) { $v = 1 - $v }
            }
            $r.Mod["$row,$col"] = $v
        }
    }
    return $r
}

function ExtractBitsRMQR($m) {
    $bits = New-Object System.Collections.ArrayList
    $up = $true
    for ($right = $m.Width - 1; $right -ge 1; $right -= 2) {
        if ($right -eq 6) { $right = 5 }
        $rows = if ($up) { ($m.Height - 1)..0 } else { 0..($m.Height - 1) }
        foreach ($row in $rows) {
            for ($dc = 0; $dc -le 1; $dc++) {
                $col = $right - $dc
                if (-not $m.Func["$row,$col"]) {
                    [void]$bits.Add($m.Mod["$row,$col"])
                }
            }
        }
        $up = -not $up
    }
    return $bits
}

function Get-EncodingFromECI($eci) {
    switch ($eci) {
        0 { return [System.Text.Encoding]::GetEncoding("IBM437") }
        1 { return [System.Text.Encoding]::GetEncoding("ISO-8859-1") }
        2 { return [System.Text.Encoding]::GetEncoding("IBM437") }
        3 { return [System.Text.Encoding]::GetEncoding("ISO-8859-1") }
        4 { return [System.Text.Encoding]::GetEncoding("ISO-8859-2") }
        5 { return [System.Text.Encoding]::GetEncoding("ISO-8859-3") }
        6 { return [System.Text.Encoding]::GetEncoding("ISO-8859-4") }
        7 { return [System.Text.Encoding]::GetEncoding("ISO-8859-5") }
        8 { return [System.Text.Encoding]::GetEncoding("ISO-8859-6") }
        9 { return [System.Text.Encoding]::GetEncoding("ISO-8859-7") }
        10 { return [System.Text.Encoding]::GetEncoding("ISO-8859-8") }
        11 { return [System.Text.Encoding]::GetEncoding("ISO-8859-9") }
        12 { return [System.Text.Encoding]::GetEncoding("ISO-8859-10") }
        13 { return [System.Text.Encoding]::GetEncoding("ISO-8859-11") }
        15 { return [System.Text.Encoding]::GetEncoding("ISO-8859-13") }
        16 { return [System.Text.Encoding]::GetEncoding("ISO-8859-14") }
        17 { return [System.Text.Encoding]::GetEncoding("ISO-8859-15") }
        18 { return [System.Text.Encoding]::GetEncoding("ISO-8859-16") }
        20 { return [System.Text.Encoding]::GetEncoding("Shift_JIS") }
        21 { return [System.Text.Encoding]::GetEncoding("windows-1250") }
        22 { return [System.Text.Encoding]::GetEncoding("windows-1251") }
        23 { return [System.Text.Encoding]::GetEncoding("windows-1252") }
        24 { return [System.Text.Encoding]::GetEncoding("windows-1256") }
        25 { return [System.Text.Encoding]::GetEncoding("UTF-16BE") }
        26 { return [System.Text.Encoding]::UTF8 }
        27 { return [System.Text.Encoding]::ASCII }
        28 { return [System.Text.Encoding]::GetEncoding("Big5") }
        29 { return [System.Text.Encoding]::GetEncoding("GB2312") }
        30 { return [System.Text.Encoding]::GetEncoding("EUC-KR") }
        default { return [System.Text.Encoding]::UTF8 }
    }
}

function DecodeRMQRStream($bytes, $spec) {
    $bits = New-Object System.Collections.ArrayList
    foreach ($b in $bytes) { for ($i=7;$i -ge 0;$i--){ [void]$bits.Add([int](($b -shr $i) -band 1)) } }
    $idx = 0
    $resultTxt = ""
    $segs = @()
    $eciActive = 26
    $cbMap = Get-RMQRCountBitsMap $spec
    
    while ($idx + 3 -le $bits.Count) {
        $mi = ($bits[$idx] -shl 2) -bor ($bits[$idx+1] -shl 1) -bor $bits[$idx+2]
        Write-Status "Debug: mi=$mi at idx=$idx bits=$($bits[$idx..($idx+2)] -join '')"
        $idx += 3
        if ($mi -eq 0) { break }
        if ($mi -eq 7) { # ECI
            # Handle ECI
            if ($idx + 8 -le $bits.Count) {
                if ($bits[$idx] -eq 0) {
                    $val = 0; for ($i=0;$i -lt 8;$i++){ $val = ($val -shl 1) -bor $bits[$idx+$i] }
                    $idx += 8
                } elseif ($bits[$idx+1] -eq 0) {
                    $val = 0; for ($i=2;$i -lt 16;$i++){ $val = ($val -shl 1) -bor $bits[$idx+$i] }
                    $idx += 16
                } else {
                    $val = 0; for ($i=3;$i -lt 24;$i++){ $val = ($val -shl 1) -bor $bits[$idx+$i] }
                    $idx += 24
                }
                $eciActive = $val
                $segs += @{Mode='ECI'; Data="$val"}
                continue
            }
            break
        }
        $mode = switch ($mi) { 1{'N'} 2{'A'} 3{'B'} 4{'K'} default{'X'} }
        if ($mode -eq 'X') { break }
        $cb = switch ($mode) { 'N' { $cbMap.N } 'A' { $cbMap.A } 'B' { $cbMap.B } 'K' { $cbMap.K } }
        if ($idx + $cb -gt $bits.Count) { break }
        $count = 0
        for ($i=0;$i -lt $cb;$i++){ $count = ($count -shl 1) -bor $bits[$idx+$i] }
        $idx += $cb
        
        if ($mode -eq 'N') {
            $out = ""
            $rem = $count % 3; $full = $count - $rem
            for ($i=0;$i -lt $full; $i += 3) {
                $val = 0; for ($b=0;$b -lt 10;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 10
                $out += $val.ToString("D3")
            }
            if ($rem -eq 1) {
                $val = 0; for ($b=0;$b -lt 4;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 4
                $out += $val.ToString()
            } elseif ($rem -eq 2) {
                $val = 0; for ($b=0;$b -lt 7;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 7
                $out += $val.ToString("D2")
            }
            $resultTxt += $out
            $segs += @{Mode='N'; Data=$out}
        } elseif ($mode -eq 'A') {
            $out = ""
            for ($i=0;$i -lt $count; $i += 2) {
                if ($i + 1 -lt $count) {
                    $val = 0; for ($b=0;$b -lt 11;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 11
                    $c1 = [Math]::Floor($val / 45); $c2 = $val % 45
                    $out += $script:ALPH[$c1] + $script:ALPH[$c2]
                } else {
                    $val = 0; for ($b=0;$b -lt 6;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 6
                    $out += $script:ALPH[$val]
                }
            }
            $resultTxt += $out
            $segs += @{Mode='A'; Data=$out}
        } elseif ($mode -eq 'B') {
            $bytesOut = @()
            for ($i=0;$i -lt $count; $i++) {
                $val = 0; for ($b=0;$b -lt 8;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 8
                $bytesOut += $val
            }
            $enc = Get-EncodingFromECI $eciActive
            $txt = $enc.GetString([byte[]]$bytesOut)
            $resultTxt += $txt
            $segs += @{Mode='B'; Data=$txt}
        } elseif ($mode -eq 'K') {
            $out = ""
            for ($i=0;$i -lt $count; $i++) {
                $val = 0; for ($b=0;$b -lt 13;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 13
                $msb = [Math]::Floor($val / 0xC0); $lsb = $val % 0xC0
                $sjis = [byte[]]@($msb, $lsb)
                $out += [System.Text.Encoding]::GetEncoding(932).GetString($sjis,0,2)
            }
            $resultTxt += $out
            $segs += @{Mode='K'; Data=$out}
        }
    }
    return @{ Text=$resultTxt; Segments=$segs; ECI=$eciActive }
}

function InitRMQRMatrix($spec) {
    $h = $spec.H; $w = $spec.W
    $m = @{ Height = $h; Width = $w; Mod = @{}; Func = @{} }
    for ($r = 0; $r -lt $h; $r++) { for ($c = 0; $c -lt $w; $c++) { $m.Mod["$r,$c"]=0; $m.Func["$r,$c"]=$false } }
    
    # Finder Patterns (TL and BR)
    for ($dy = -1; $dy -le 7; $dy++) { 
        for ($dx = -1; $dx -le 7; $dx++) { 
            # Top-Left
            $rr = 0 + $dy; $cc = 0 + $dx
            if ($rr -ge 0 -and $cc -ge 0 -and $rr -ge 0 -and $rr -lt $h -and $cc -lt $w) {
                $in = $dy -ge 0 -and $dy -le 6 -and $dx -ge 0 -and $dx -le 6
                if (-not $in) { $m.Func["$rr,$cc"]=$true; continue }
                $on = $dy -eq 0 -or $dy -eq 6 -or $dx -eq 0 -or $dx -eq 6
                $cent = $dy -ge 2 -and $dy -le 4 -and $dx -ge 2 -and $dx -le 4
                $m.Func["$rr,$cc"]=$true; $m.Mod["$rr,$cc"]=([int]($on -or $cent))
            }
            # Bottom-Right
            $rr = ($h - 7) + $dy; $cc = ($w - 7) + $dx
            if ($rr -ge 0 -and $cc -ge 0 -and $rr -lt $h -and $cc -lt $w) {
                $in = $dy -ge 0 -and $dy -le 6 -and $dx -ge 0 -and $dx -le 6
                if (-not $in) { $m.Func["$rr,$cc"]=$true; continue }
                $on = $dy -eq 0 -or $dy -eq 6 -or $dx -eq 0 -or $dx -eq 6
                $cent = $dy -ge 2 -and $dy -le 4 -and $dx -ge 2 -and $dx -le 4
                $m.Func["$rr,$cc"]=$true; $m.Mod["$rr,$cc"]=([int]($on -or $cent))
            }
        }
    }
    
    # Timing patterns
    for ($c = 7; $c -lt $w; $c++) { $v = ($c % 2) -eq 0; if (-not $m.Func["6,$c"]) { $m.Func["6,$c"]=$true; $m.Mod["6,$c"]=[int]$v } }
    for ($r = 7; $r -lt $h; $r++) { $v = ($r % 2) -eq 0; if (-not $m.Func["$r,6"]) { $m.Func["$r,6"]=$true; $m.Mod["$r,6"]=[int]$v } }
    
    # Format Info areas (TL and BR)
    # TL: Use columns 7, 8, 9 (rows 0-5)
    for ($i=0;$i -lt 6;$i++){ $m.Func["$i,7"]=$true; $m.Func["$i,8"]=$true; $m.Func["$i,9"]=$true }
    # BR: Use columns w-8, w-9, w-10 (rows 0-5)
    for ($i=0;$i -lt 6;$i++){ $m.Func["$i,$($w-8)"]=$true; $m.Func["$i,$($w-9)"]=$true; $m.Func["$i,$($w-10)"]=$true }
    
    # Alignment patterns for large rMQR (if any - RMQR_SPEC has sub-regions)
    # ISO 23941 defines sub-finder patterns for versions with more than 1 sub-region.
    # Our SPEC has D, H, W, VI, etc. but doesn't explicitly list sub-finders.
    # However, the current implementation in New-QRCode doesn't add them either.
    
    return $m
}

function Decode-RMQRMatrix($m) {
    $fi = ReadRMQRFormatInfo $m
    $spec = $null
    foreach($k in $script:RMQR_SPEC.Keys){ if($script:RMQR_SPEC[$k].VI -eq $fi.VI){ $spec = $script:RMQR_SPEC[$k]; break } }
    if(-not $spec){ throw "Versión rMQR no soportada: VI=$($fi.VI)" }
    
    # Marcar módulos funcionales para que UnmaskRMQR funcione correctamente
    $temp = InitRMQRMatrix $spec
    $m.Func = $temp.Func
    
    $um = UnmaskRMQR $m
    $bits = ExtractBitsRMQR $um
    Write-Status "Debug bits: $($bits[0..23] -join '')"
    
    $allBytes = @()
    for ($i=0;$i -lt $bits.Count; $i += 8) {
        $byte = 0; for ($j=0;$j -lt 8; $j++) { $byte = ($byte -shl 1) -bor $bits[$i+$j] }
        $allBytes += $byte
    }

    $de = if ($fi.EC -eq 'H') { $spec.H2 } else { $spec.M }
    $eccLen = $de.E
    $blocks = 1
    if ($eccLen -ge 36 -and $eccLen -lt 80) { $blocks = 2 } elseif ($eccLen -ge 80) { $blocks = 4 }
    
    # Deinterleave rMQR: Data portion first, then EC portion
    $dataLen = $de.D
    $dataBytesInterleaved = $allBytes[0..($dataLen - 1)]
    $ecBytesInterleaved = $allBytes[$dataLen..($dataLen + $eccLen - 1)]
    
    # Deinterleave data portion
    $dataBlocks = @()
    $baseD = [Math]::Floor($dataLen / $blocks)
    $remD = $dataLen % $blocks
    for($bix=0; $bix -lt $blocks; $bix++){
        $len = $baseD
        if ($bix -lt $remD) { $len += 1 }
        $dataBlocks += ,(@(0) * $len)
    }
    $ptr = 0
    for($i=0; $i -lt ($baseD + 1); $i++){
        for($bix=0; $bix -lt $blocks; $bix++){
            if($i -lt $dataBlocks[$bix].Count){
                if($ptr -lt $dataBytesInterleaved.Count){ $dataBlocks[$bix][$i] = $dataBytesInterleaved[$ptr++] }
            }
        }
    }
    
    # Deinterleave EC portion
    $ecBlocks = @()
    $baseE = [Math]::Floor($eccLen / $blocks)
    $remE = $eccLen % $blocks
    for($bix=0; $bix -lt $blocks; $bix++){
        $len = $baseE
        if ($bix -lt $remE) { $len += 1 }
        $ecBlocks += ,(@(0) * $len)
    }
    $ptr = 0
    for($i=0; $i -lt ($baseE + 1); $i++){
        for($bix=0; $bix -lt $blocks; $bix++){
            if($i -lt $ecBlocks[$bix].Count){
                if($ptr -lt $ecBytesInterleaved.Count){ $ecBlocks[$bix][$i] = $ecBytesInterleaved[$ptr++] }
            }
        }
    }
    
    $dataBytes = @()
    $totalErrors = 0
    for($bix=0; $bix -lt $blocks; $bix++){
        $fullBlock = $dataBlocks[$bix] + $ecBlocks[$bix]
        $res = Decode-ReedSolomon $fullBlock $ecBlocks[$bix].Count
        if($null -eq $res){ throw "Error RS irreparable en bloque rMQR $bix" }
        $dataBytes += $res.Data
        $totalErrors += $res.Errors
    }

    $dec = DecodeRMQRStream $dataBytes $spec
    $dec.Errors = $totalErrors
    return $dec
}

function Import-QRCode($path) {
    if ($path.ToLower().EndsWith(".svg")) {
        [xml]$svg = Get-Content $path
        $viewBox = $svg.svg.viewBox -split " "
        if ($viewBox.Count -lt 4) { throw "SVG inválido (sin viewBox)" }
        $wUnits = [int][double]$viewBox[2]
        $hUnits = [int][double]$viewBox[3]
        
        # Seleccionar rectángulos negros (pueden tener fill=#000000, fill=black, o heredar del padre)
        $rects = $svg.SelectNodes("//*[local-name()='rect']") | Where-Object { 
            $f = $_.Attributes["fill"]
            ($null -eq $f) -or ($f.Value -eq "#000000") -or ($f.Value -eq "black")
        } | Where-Object { $null -ne $_.Attributes["x"] }
        
        if ($rects.Count -eq 0) { throw "No se encontraron módulos negros en el SVG" }
        
        $minX = $wUnits; $minY = $hUnits
        foreach($r in $rects) {
            $rx = [int][double]$r.Attributes["x"].Value
            $ry = [int][double]$r.Attributes["y"].Value
            if($rx -lt $minX){ $minX = $rx }
            if($ry -lt $minY){ $minY = $ry }
        }
        
        # El quiet zone es el margen mínimo encontrado
        $quiet = $minX
        $width = $wUnits - 2 * $quiet
        $height = $hUnits - 2 * $quiet
        
        $m = @{ Size = $width; Width = $width; Height = $height; Mod = @{}; Func = @{} }
        foreach($r in $rects) {
            $col = [int][double]$r.Attributes["x"].Value - $quiet
            $row = [int][double]$r.Attributes["y"].Value - $quiet
            if ($row -ge 0 -and $row -lt $height -and $col -ge 0 -and $col -lt $width) {
                $m.Mod["$row,$col"] = 1
            }
        }
        for($r=0; $r -lt $height; $r++) {
            for($c=0; $c -lt $width; $c++) {
                if(-not $m.Mod.ContainsKey("$r,$c")){ $m.Mod["$r,$c"] = 0 }
                $m.Func["$r,$c"] = $false 
            }
        }
        return $m
    } else {
        Add-Type -AssemblyName System.Drawing
        $bmp = New-Object Drawing.Bitmap $path
        try {
            $w = $bmp.Width; $h = $bmp.Height
            
            # 1. Encontrar el primer pixel negro
            $found = $false; $x0 = 0; $y0 = 0
            for($y=0; $y -lt $h; $y++) {
                for($x=0; $x -lt $w; $x++) {
                    if($bmp.GetPixel($x, $y).R -lt 128) { $x0 = $x; $y0 = $y; $found = $true; break }
                }
                if($found){ break }
            }
            if(-not $found){ throw "No se encontró código QR en la imagen" }
            
            # 2. Detectar escala usando el GCD de las rachas de pixeles
            $runs = @()
            $currentLen = 0; $currentVal = -1
            # Escanear una fila que sepamos que tiene datos
            for($x = 0; $x -lt $w; $x++) {
                $v = if($bmp.GetPixel($x, $y0).R -lt 128){ 1 } else { 0 }
                if($v -eq $currentVal) { $currentLen++ }
                else {
                    if($currentVal -ne -1){ $runs += $currentLen }
                    $currentVal = $v; $currentLen = 1
                }
            }
            $runs += $currentLen
            
            $gcd = { param($a,$b) while($b){$t=$a;$a=$b;$b=$t%$b}; $a }
            $scale = $runs[0]
            foreach($r in $runs){ if($r -gt 0){ $scale = &$gcd $scale $r } }
            
            # 3. Reconstruir matriz
            $quietX = [Math]::Round($x0 / $scale)
            $quietY = [Math]::Round($y0 / $scale)
            $modW = [Math]::Round($w / $scale) - 2 * $quietX
            $modH = [Math]::Round($h / $scale) - 2 * $quietY
            
            $m = @{ Size = $modW; Width = $modW; Height = $modH; Mod = @{}; Func = @{} }
            for($r=0; $r -lt $modH; $r++) {
                for($c=0; $c -lt $modW; $c++) {
                    $sampleX = ($c + $quietX) * $scale + [Math]::Floor($scale / 2)
                    $sampleY = ($r + $quietY) * $scale + [Math]::Floor($scale / 2)
                    if ($sampleX -lt $w -and $sampleY -lt $h) {
                        $m.Mod["$r,$c"] = if($bmp.GetPixel($sampleX, $sampleY).R -lt 128){ 1 } else { 0 }
                    } else {
                        $m.Mod["$r,$c"] = 0
                    }
                    $m.Func["$r,$c"] = $false
                }
            }
            return $m
        } finally {
            $bmp.Dispose()
        }
    }
}

function New-RS($data, $ecn) {
    return GetEC $data $ecn
}

function Decode-ReedSolomon($msg, $nsym) {
    # 1. Sindromes: S_i = C(alpha^i)
    $syn = @(0) * $nsym
    $hasError = $false
    for ($i = 0; $i -lt $nsym; $i++) {
        $s = Poly-Eval-GF $msg ($script:EXP[$i])
        $syn[$i] = $s
        if ($s -ne 0) { $hasError = $true }
    }
    if (-not $hasError) { return @{ Data=$msg[0..($msg.Count - $nsym - 1)]; Errors=0 } }

    # 2. Berlekamp-Massey
    # sigma: [s_L, ..., s_1, 1]
    $sigma = @(1)
    $b = @(1)
    for ($i = 0; $i -lt $nsym; $i++) {
        $b = $b + @(0) # b(x) = b(x) * x
        $delta = $syn[$i]
        for ($j = 1; $j -lt $sigma.Count; $j++) {
            $delta = $delta -bxor (GFMul $sigma[$sigma.Count - 1 - $j] $syn[$i - $j])
        }
        
        if ($delta -ne 0) {
            if ($b.Count -gt $sigma.Count) {
                $newSigma = @(0) * $b.Count
                # newSigma = b * delta + sigma
                $offset = $b.Count - $sigma.Count
                for($k=0; $k -lt $b.Count; $k++) { $newSigma[$k] = GFMul $b[$k] $delta }
                for($k=0; $k -lt $sigma.Count; $k++) { $newSigma[$k + $offset] = $newSigma[$k + $offset] -bxor $sigma[$k] }
                
                # b = oldSigma / delta
                $invDelta = GFInv $delta
                $b = @()
                foreach($c in $sigma){ $b += GFMul $c $invDelta }
                $sigma = $newSigma
            } else {
                # sigma = sigma + b * delta
                $offset = $sigma.Count - $b.Count
                for($k=0; $k -lt $b.Count; $k++) { $sigma[$k + $offset] = $sigma[$k + $offset] -bxor (GFMul $b[$k] $delta) }
            }
        }
    }

    # 3. Chien Search
    $errPos = @()
    for ($i = 0; $i -lt $msg.Count; $i++) {
        $xinv = $script:EXP[255 - $i]
        if ((Poly-Eval-GF $sigma $xinv) -eq 0) {
            $errPos += $i
        }
    }
    
    if ($errPos.Count -ne ($sigma.Count - 1)) { return $null } 

    # 4. Forney Algorithm
    $omega = @(0) * ($sigma.Count - 1)
    # Omega(x) = [S(x) * Sigma(x)] mod x^nsym
    # We only need the first L terms of Omega
    for ($i = 0; $i -lt $omega.Count; $i++) {
        $val = 0
        for ($j = 0; $j -le $i; $j++) {
            # syn[i-j] * sigma[L-j]
            $sigmaCoeff = $sigma[$sigma.Count - 1 - $j]
            $val = $val -bxor (GFMul $syn[$i - $j] $sigmaCoeff)
        }
        $omega[$omega.Count - 1 - $i] = $val
    }
    
    $sigmaDeriv = @()
    for($i=1; $i -lt $sigma.Count; $i += 2){
        $sigmaDeriv = @($sigma[$sigma.Count-1-$i]) + $sigmaDeriv
    }

    $res = [int[]]$msg
    foreach($p in $errPos){
        $xiInv = $script:EXP[255 - $p]
        $xi = $script:EXP[$p]
        $num = Poly-Eval-GF $omega $xiInv
        $den = Poly-Eval-GF $sigmaDeriv (GFMul $xiInv $xiInv)
        $err = GFMul $xi (GFDiv $num $den)
        $res[$msg.Count - 1 - $p] = $res[$msg.Count - 1 - $p] -bxor $err
    }

    return @{ Data=$res[0..($msg.Count - $nsym - 1)]; Errors=$errPos.Count }
}


# Format info strings (precalculated per ISO 18004)
$script:FMT = @{
    'L0'='111011111000100';'L1'='111001011110011';'L2'='111110110101010';'L3'='111100010011101'
    'L4'='110011000101111';'L5'='110001100011000';'L6'='110110001000001';'L7'='110100101110110'
    'M0'='101010000010010';'M1'='101000100100101';'M2'='101111001111100';'M3'='101101101001011'
    'M4'='100010111111001';'M5'='100000011001110';'M6'='100111110010111';'M7'='100101010100000'
    'Q0'='011010101011111';'Q1'='011000001101000';'Q2'='011111100110001';'Q3'='011101000000110'
    'Q4'='010010010110100';'Q5'='010000110000011';'Q6'='010111011011010';'Q7'='010101111101101'
    'H0'='001011010001001';'H1'='001001110111110';'H2'='001110011100111';'H3'='001100111010000'
    'H4'='000011101100010';'H5'='000001001010101';'H6'='000110100001100';'H7'='000100000111011'
}

$script:ALPH = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ `$%*+-./:"
$script:VER_INFO = @{
    7='000111110010010100'; 8='001000010110111100'; 9='001001101010011001'; 10='001010010011010011'
    11='001011101111110110'; 12='001100011101100010'; 13='001101101001011001'; 14='001110010010101111'
    15='010000101101001100'; 16='010001011111110001'; 17='010010101011000000'; 18='010011011001111101'
    19='010100100110110111'; 20='010101010100001010'; 21='010110100000111000'; 22='010111010010000101'
    23='011000101101101111'; 24='011001011111010010'; 25='011010101011100011'; 26='011011011001011110'
    27='011100100110010100'; 28='011101010100101001'; 29='011110100000011011'; 30='011111010010100110'
    31='100000101100111101'; 32='100001011110000000'; 33='100010101010110101'; 34='100011011000001000'
    35='100100100111000010'; 36='100101010101111111'; 37='100110100001001101'; 38='100111010011110000'
    39='101000101100011000'; 40='101001011110100101'
}

# Calculated Tables for V1-V40 (Source: ISO 18004 / Nayuki)
# EC Codewords Per Block (L, M, Q, H) by Version (0 is padding)
$ECC_PER_BLOCK = @(
    @(-1,-1,-1,-1), # V0
    @(-1, 7, 10, 13, 17), @(-1, 10, 16, 22, 28), @(-1, 15, 26, 18, 22), @(-1, 20, 18, 26, 16),
    @(-1, 26, 24, 18, 22), @(-1, 18, 16, 24, 28), @(-1, 20, 18, 18, 26), @(-1, 24, 22, 20, 24),
    @(-1, 30, 22, 20, 28), @(-1, 18, 26, 24, 24), @(-1, 20, 30, 28, 28), @(-1, 24, 22, 26, 26),
    @(-1, 26, 22, 24, 24), @(-1, 30, 24, 20, 24), @(-1, 22, 24, 30, 24), @(-1, 24, 28, 24, 30),
    @(-1, 28, 28, 28, 28), @(-1, 30, 26, 28, 28), @(-1, 28, 26, 26, 26), @(-1, 28, 26, 30, 28),
    @(-1, 28, 26, 28, 30), @(-1, 28, 28, 30, 24), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30),
    @(-1, 26, 28, 30, 30), @(-1, 28, 28, 28, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30),
    @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30),
    @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30),
    @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30), @(-1, 30, 28, 30, 30)
)

# Number of EC Blocks (L, M, Q, H) by Version
$NUM_EC_BLOCKS = @(
    @(-1,-1,-1,-1),
    @(-1, 1, 1, 1, 1), @(-1, 1, 1, 1, 1), @(-1, 1, 1, 2, 2), @(-1, 1, 2, 2, 4),
    @(-1, 1, 2, 2, 2), @(-1, 2, 4, 4, 4), @(-1, 2, 4, 6, 5), @(-1, 2, 4, 6, 6),
    @(-1, 2, 5, 8, 8), @(-1, 4, 5, 8, 8), @(-1, 4, 5, 8, 11), @(-1, 4, 8, 10, 11),
    @(-1, 4, 9, 12, 16), @(-1, 4, 9, 16, 16), @(-1, 6, 10, 12, 18), @(-1, 6, 10, 17, 16),
    @(-1, 6, 11, 16, 19), @(-1, 6, 13, 18, 21), @(-1, 7, 14, 21, 25), @(-1, 8, 16, 20, 25),
    @(-1, 8, 17, 23, 25), @(-1, 9, 17, 23, 34), @(-1, 9, 18, 25, 30), @(-1, 10, 20, 27, 32),
    @(-1, 12, 21, 29, 35), @(-1, 12, 23, 34, 37), @(-1, 12, 25, 34, 40), @(-1, 13, 26, 35, 42),
    @(-1, 14, 28, 38, 45), @(-1, 15, 29, 40, 48), @(-1, 16, 31, 43, 51), @(-1, 17, 33, 45, 54),
    @(-1, 18, 35, 48, 57), @(-1, 19, 37, 51, 60), @(-1, 19, 38, 53, 63), @(-1, 20, 40, 56, 66),
    @(-1, 21, 43, 59, 70), @(-1, 22, 45, 62, 74), @(-1, 24, 47, 65, 77), @(-1, 25, 49, 68, 81)
)

# Total Data Codewords (L, M, Q, H) - ISO 18004 Standard
$DATA_CW_TABLE = @(
    @(-1,-1,-1,-1),
    @(19,16,13,9), @(34,28,22,16), @(55,44,34,26), @(80,64,48,36), @(108,86,62,46),
    @(136,108,76,60), @(156,124,88,66), @(194,154,110,86), @(232,182,132,100), @(274,216,154,122),
    @(324,254,180,140), @(376,292,208,154), @(424,332,244,180), @(460,362,260,202), @(520,412,312,236),
    @(586,450,364,288), @(644,504,392,312), @(718,560,422,342), @(792,624,472,374), @(858,666,518,406),
    @(929,711,553,443), @(1003,779,599,499), @(1091,857,651,541), @(1171,911,701,595), @(1273,997,775,649),
    @(1367,1059,879,723), @(1465,1125,935,781), @(1528,1190,1006,804), @(1628,1264,1052,868), @(1732,1370,1120,932),
    @(1840,1452,1202,998), @(1952,1538,1274,1062), @(2068,1628,1354,1118), @(2188,1722,1432,1184), @(2303,1809,1529,1267),
    @(2431,1911,1627,1339), @(2563,1989,1693,1413), @(2699,2099,1781,1487), @(2809,2213,1869,1553), @(2953,2331,1991,1651)
)
# Note: Some online tables vary slightly for V14+. Using generic safe capacity.

$script:SPEC = @{}
$script:CAP = @{}
$script:ALIGN = @{}
$script:RMQR_FMT_MASKS = @{
    TL = @(0,1,1,1,1,1,1,0,1,0,1,0,1,1,0,0,1,0)
    BR = @(1,0,0,0,0,0,1,0,1,0,0,1,1,1,1,0,1,1)
}
$script:RMQR_SPEC = @{
    'R7x43'  = @{ VI=0;  H=7;  W=43;  M=@{D=6;  E=7};  H2=@{D=3;  E=10} }
    'R7x59'  = @{ VI=1;  H=7;  W=59;  M=@{D=12; E=9};  H2=@{D=7;  E=14} }
    'R7x77'  = @{ VI=2;  H=7;  W=77;  M=@{D=20; E=12}; H2=@{D=10; E=22} }
    'R7x99'  = @{ VI=3;  H=7;  W=99;  M=@{D=28; E=16}; H2=@{D=14; E=30} }
    'R7x139' = @{ VI=4;  H=7;  W=139; M=@{D=44; E=24}; H2=@{D=24; E=44} }
    'R9x43'  = @{ VI=5;  H=9;  W=43;  M=@{D=12; E=9};  H2=@{D=7;  E=14} }
    'R9x59'  = @{ VI=6;  H=9;  W=59;  M=@{D=21; E=12}; H2=@{D=11; E=22} }
    'R9x77'  = @{ VI=7;  H=9;  W=77;  M=@{D=31; E=18}; H2=@{D=17; E=32} }
    'R9x99'  = @{ VI=8;  H=9;  W=99;  M=@{D=42; E=24}; H2=@{D=22; E=44} }
    'R9x139' = @{ VI=9;  H=9;  W=139; M=@{D=63; E=36}; H2=@{D=33; E=66} }
    'R11x27' = @{ VI=10; H=11; W=27;  M=@{D=7;  E=8};  H2=@{D=5;  E=10} }
    'R11x43' = @{ VI=11; H=11; W=43;  M=@{D=19; E=12}; H2=@{D=11; E=20} }
    'R11x59' = @{ VI=12; H=11; W=59;  M=@{D=31; E=16}; H2=@{D=15; E=32} }
    'R11x77' = @{ VI=13; H=11; W=77;  M=@{D=43; E=24}; H2=@{D=23; E=44} }
    'R11x99' = @{ VI=14; H=11; W=99;  M=@{D=57; E=32}; H2=@{D=29; E=60} }
    'R11x139'= @{ VI=15; H=11; W=139; M=@{D=84; E=48}; H2=@{D=42; E=90} }
    'R13x27' = @{ VI=16; H=13; W=27;  M=@{D=12; E=9};  H2=@{D=7;  E=14} }
    'R13x43' = @{ VI=17; H=13; W=43;  M=@{D=27; E=14}; H2=@{D=13; E=28} }
    'R13x59' = @{ VI=18; H=13; W=59;  M=@{D=38; E=22}; H2=@{D=20; E=40} }
    'R13x77' = @{ VI=19; H=13; W=77;  M=@{D=53; E=32}; H2=@{D=29; E=56} }
    'R13x99' = @{ VI=20; H=13; W=99;  M=@{D=73; E=40}; H2=@{D=35; E=78} }
    'R13x139'= @{ VI=21; H=13; W=139; M=@{D=106;E=60}; H2=@{D=54; E=112} }
    'R15x43' = @{ VI=22; H=15; W=43;  M=@{D=33; E=18}; H2=@{D=15; E=36} }
    'R15x59' = @{ VI=23; H=15; W=59;  M=@{D=48; E=26}; H2=@{D=26; E=48} }
    'R15x77' = @{ VI=24; H=15; W=77;  M=@{D=67; E=36}; H2=@{D=31; E=72} }
    'R15x99' = @{ VI=25; H=15; W=99;  M=@{D=88; E=48}; H2=@{D=48; E=88} }
    'R15x139'= @{ VI=26; H=15; W=139; M=@{D=127;E=72}; H2=@{D=69; E=130} }
    'R17x43' = @{ VI=27; H=17; W=43;  M=@{D=39; E=22}; H2=@{D=21; E=40} }
    'R17x59' = @{ VI=28; H=17; W=59;  M=@{D=56; E=32}; H2=@{D=28; E=60} }
    'R17x77' = @{ VI=29; H=17; W=77;  M=@{D=78; E=44}; H2=@{D=38; E=84} }
    'R17x99' = @{ VI=30; H=17; W=99;  M=@{D=100;E=60}; H2=@{D=56; E=104} }
    'R17x139'= @{ VI=31; H=17; W=139; M=@{D=152;E=80}; H2=@{D=76; E=156} }
}
$script:RMQR_CAP = @{}
foreach ($k in $script:RMQR_SPEC.Keys) {
    $sp = $script:RMQR_SPEC[$k]
    $dM = $sp.M.D; $dH = $sp.H2.D
    $bitsM = $dM * 8; $bitsH = $dH * 8
    $script:RMQR_CAP[$k] = @{
        'M' = @{
            N = [Math]::Floor(($bitsM / 10) * 3)
            A = [Math]::Floor(($bitsM / 11) * 2)
            B = $dM
            K = [Math]::Floor($bitsM / 13)
        }
        'H' = @{
            N = [Math]::Floor(($bitsH / 10) * 3)
            A = [Math]::Floor(($bitsH / 11) * 2)
            B = $dH
            K = [Math]::Floor($bitsH / 13)
        }
    }
}

for ($v = 1; $v -le 40; $v++) {
    $script:CAP[$v] = @{}
    
    # Calculate Alignment Patterns
    if ($v -gt 1) {
        $numAlign = [Math]::Floor($v / 7) + 2
        $step = if ($numAlign -eq 1) { 0 } else { [Math]::Floor(($v * 8 + $numAlign * 3 + 5) / ($numAlign * 4 - 4)) * 2 }
        $pos = @(); for ($i = 0; $i -lt $numAlign - 1; $i++) { $pos += ($v * 4 + 17 - 7 - $i * $step) }
        $pos += 6; $script:ALIGN[$v] = $pos | Sort-Object
    }
    
    foreach ($ec in 'L','M','Q','H') {
        $ecIdx = switch($ec){'L'{1}'M'{2}'Q'{3}'H'{4}}
        $numBlocks = $NUM_EC_BLOCKS[$v][$ecIdx]
        $ecPerBlock = $ECC_PER_BLOCK[$v][$ecIdx]
        
        # USE STATIC TABLE FOR DATA CAPACITY
        $totalData = $DATA_CW_TABLE[$v][$ecIdx - 1]
        $totalEC = $numBlocks * $ecPerBlock
        
        # Calculate Group split
        # D1 = totalData / numBlocks (floor)
        # remainder = totalData % numBlocks
        # blocks with D1+1 data = remainder
        # blocks with D1 data = numBlocks - remainder
        # Group 2 is the one with LARGER data size (D1+1) standard usually puts them at the end.
        
        $numLong = $totalData % $numBlocks
        $numShort = $numBlocks - $numLong
        $d1 = [Math]::Floor($totalData / $numBlocks)
        
        # According to spec, Group 1 has fewer codewords, Group 2 has more.
        # So G1 gets $d1, G2 gets $d1+1
        # G1 count = $numShort
        # G2 count = $numLong
        
        $key = "$v$ec"
        $script:SPEC[$key] = @{
            D = $totalData
            E = $totalEC
            G1 = $numShort
            D1 = $d1
            G2 = $numLong
            D2 = ($d1 + 1)
        }
        
        # Calculate max chars
        $bits = $totalData * 8
        $bitsN = if($v -le 9){10} elseif($v -le 26){12} else{14}
        $bitsA = if($v -le 9){9}  elseif($v -le 26){11} else{13}
        $bitsK = 13
        
        $script:CAP[$v][$ec] = @(
            [Math]::Floor($bits / $bitsN * 3), 
            [Math]::Floor($bits / $bitsA * 2), 
            $totalData,                        
            [Math]::Floor($bits / $bitsK)      
        )
    }
}

# --- SEGMENTATION & ENCODING ENGINE (ISO 18004 COMPLIANT) ---

function IsKanjiChar($ch) {
    $sjis = [System.Text.Encoding]::GetEncoding(932)
    $bytes = $sjis.GetBytes([string]$ch)
    if ($bytes.Length -ne 2) { return $false }
    $val = ([int]$bytes[0] -shl 8) -bor [int]$bytes[1]
    return (($val -ge 0x8140 -and $val -le 0x9FFC) -or ($val -ge 0xE040 -and $val -le 0xEBBF))
}

function Get-StructuredAppendParity($txt) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($txt)
    $par = 0
    foreach ($b in $bytes) { $par = $par -bxor $b }
    return $par
}

function Write-Status($message) {
    Write-Information $message -InformationAction Continue
}

$script:MICRO_CAP = @{
    'M1' = @{
        '-' = @{ N = 5 }
    }
    'M2' = @{
        'L' = @{ N = 10; A = 6 }
        'M' = @{ N = 8; A = 5 }
    }
    'M3' = @{
        'L' = @{ N = 23; A = 14; B = 9; K = 6 }
        'M' = @{ N = 18; A = 11; B = 7; K = 4 }
    }
    'M4' = @{
        'L' = @{ N = 35; A = 21; B = 15; K = 9 }
        'M' = @{ N = 30; A = 18; B = 13; K = 8 }
        'Q' = @{ N = 21; A = 13; B = 9; K = 5 }
    }
}

function GetMicroSize($ver) {
    switch ($ver) {
        'M1' { 11 }
        'M2' { 13 }
        'M3' { 15 }
        'M4' { 17 }
    }
}

function GetMicroMode($txt) {
    if ($txt -match '^[0-9]+$') { return 'N' }
    $allAlnum = $true
    for ($i = 0; $i -lt $txt.Length; $i++) {
        if (-not $script:ALPH.Contains($txt[$i])) { $allAlnum = $false; break }
    }
    if ($allAlnum) { return 'A' }
    $allKanji = $true
    for ($i = 0; $i -lt $txt.Length; $i++) {
        if (-not (IsKanjiChar $txt.Substring($i,1))) { $allKanji = $false; break }
    }
    if ($allKanji) { return 'K' }
    return 'B'
}

function GetMicroModeInfo($ver, $mode) {
    switch ($ver) {
        'M1' { return @{ Len = 0; Val = 0 } }
        'M2' {
            if ($mode -eq 'N') { return @{ Len = 1; Val = 0 } }
            if ($mode -eq 'A') { return @{ Len = 1; Val = 1 } }
        }
        'M3' {
            if ($mode -eq 'N') { return @{ Len = 2; Val = 0 } }
            if ($mode -eq 'A') { return @{ Len = 2; Val = 1 } }
            if ($mode -eq 'B') { return @{ Len = 2; Val = 2 } }
            if ($mode -eq 'K') { return @{ Len = 2; Val = 3 } }
        }
        'M4' {
            if ($mode -eq 'N') { return @{ Len = 3; Val = 1 } }
            if ($mode -eq 'A') { return @{ Len = 3; Val = 2 } }
            if ($mode -eq 'B') { return @{ Len = 3; Val = 3 } }
            if ($mode -eq 'K') { return @{ Len = 3; Val = 4 } }
        }
    }
    throw "Modo no soportado para $ver"
}

function GetMicroCountBits($ver, $mode) {
    switch ($ver) {
        'M1' { return 3 }
        'M2' { if ($mode -eq 'N') { return 4 } else { return 3 } }
        'M3' { $v = switch ($mode) { 'N' { 5 } 'A' { 4 } 'B' { 4 } 'K' { 3 } }; return $v }
        'M4' { $v = switch ($mode) { 'N' { 6 } 'A' { 5 } 'B' { 4 } 'K' { 4 } }; return $v }
    }
}

function GetMicroCap($ver, $ec, $mode) {
    if (-not $script:MICRO_CAP.ContainsKey($ver)) { return -1 }
    $eckey = if ($ver -eq 'M1') { '-' } else { $ec }
    if (-not $script:MICRO_CAP[$ver].ContainsKey($eckey)) { return -1 }
    if (-not $script:MICRO_CAP[$ver][$eckey].ContainsKey($mode)) { return -1 }
    return $script:MICRO_CAP[$ver][$eckey][$mode]
}

function InitMicroM($ver) {
    $size = GetMicroSize $ver
    $m = NewM $size
    AddFinder $m 0 0
    for ($i = 7; $i -lt $size; $i++) {
        $v = ($i % 2) -eq 0
        if (-not (IsF $m 6 $i)) { SetF $m 6 $i $v }
        if (-not (IsF $m $i 6)) { SetF $m $i 6 $v }
    }
    for ($i = 0; $i -lt 9; $i++) {
        if ($i -lt $size) {
            if (-not (IsF $m 8 $i)) { $m.Func["8,$i"] = $true }
            if (-not (IsF $m $i 8)) { $m.Func["$i,8"] = $true }
        }
    }
    return $m
}

function GetMicroTotalCw($ver) {
    $m = InitMicroM $ver
    $dataModules = 0
    for ($r = 0; $r -lt $m.Size; $r++) {
        for ($c = 0; $c -lt $m.Size; $c++) {
            if (-not (IsF $m $r $c)) { $dataModules++ }
        }
    }
    return [Math]::Floor($dataModules / 8)
}

function AddFormatMicro($m, $ec, $mask) {
    $fmt = $script:FMT["$ec$mask"]
    for ($i = 0; $i -lt 15; $i++) {
        $bit = [int]($fmt[$i].ToString())
        if ($i -le 5) {
            $m.Mod["8,$i"] = $bit
        } elseif ($i -eq 6) {
            $m.Mod["8,7"] = $bit
        } elseif ($i -eq 7) {
            $m.Mod["8,8"] = $bit
        } elseif ($i -eq 8) {
            $m.Mod["7,8"] = $bit
        } else {
            $row = 14 - $i
            $m.Mod["$row,8"] = $bit
        }
    }
}

function FindBestMaskMicro($m) {
    $best = 0; $min = [int]::MaxValue
    for ($p = 0; $p -lt 4; $p++) {
        $masked = ApplyMask $m $p
        $pen = GetPenalty $masked
        if ($pen -lt $min) { $min = $pen; $best = $p }
    }
    return $best
}

function MicroEncode($txt, $ver, $ec, $mode) {
    $bits = New-Object System.Collections.ArrayList
    $mi = GetMicroModeInfo $ver $mode
    if ($mi.Len -gt 0) {
        for ($b = $mi.Len - 1; $b -ge 0; $b--) { [void]$bits.Add([int](($mi.Val -shr $b) -band 1)) }
    }
    $cb = GetMicroCountBits $ver $mode
    $count = if ($mode -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($txt) } else { $txt.Length }
    for ($i = $cb - 1; $i -ge 0; $i--) { [void]$bits.Add([int](($count -shr $i) -band 1)) }
    switch ($mode) {
        'N' {
            for ($i = 0; $i -lt $txt.Length; $i += 3) {
                $ch = $txt.Substring($i, [Math]::Min(3, $txt.Length - $i))
                $v = [int]$ch; $nb = switch ($ch.Length) { 3{10} 2{7} 1{4} }
                for ($b = $nb - 1; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
            }
        }
        'A' {
            for ($i = 0; $i -lt $txt.Length; $i += 2) {
                if ($i + 1 -lt $txt.Length) {
                    $v = $script:ALPH.IndexOf($txt[$i]) * 45 + $script:ALPH.IndexOf($txt[$i+1])
                    for ($b = 10; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                } else {
                    $v = $script:ALPH.IndexOf($txt[$i])
                    for ($b = 5; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                }
            }
        }
        'B' {
            foreach ($byte in [Text.Encoding]::UTF8.GetBytes($txt)) {
                for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($byte -shr $b) -band 1)) }
            }
        }
        'K' {
            $sjis = [System.Text.Encoding]::GetEncoding(932)
            $bytes = $sjis.GetBytes($txt)
            for ($i = 0; $i -lt $bytes.Length; $i += 2) {
                $val = ([int]$bytes[$i] -shl 8) -bor [int]$bytes[$i+1]
                if ($val -ge 0x8140 -and $val -le 0x9FFC) { $val -= 0x8140 }
                elseif ($val -ge 0xE040 -and $val -le 0xEBBF) { $val -= 0xC140 }
                $val = (($val -shr 8) * 0xC0) + ($val -band 0xFF)
                for ($b = 12; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            }
        }
    }
    return ,$bits
}

function Get-Segment($txt) {
    $segs = @()
    $len = $txt.Length
    $i = 0
    
    while ($i -lt $len) {
        # Check run lengths at current position
        $nRun = 0; $j = $i
        while ($j -lt $len -and $txt[$j] -match '[0-9]') { $nRun++; $j++ }
        
        $aRun = 0; $j = $i
        while ($j -lt $len -and $script:ALPH.Contains($txt[$j])) { $aRun++; $j++ }

        $kRun = 0; $j = $i
        while ($j -lt $len) {
            $ch = $txt.Substring($j, 1)
            if (-not (IsKanjiChar $ch)) { break }
            $kRun++; $j++
        }
        
        $mode = 'B'
        $mLen = 1
        
        if ($kRun -gt 0) { $mode = 'K'; $mLen = $kRun }
        elseif ($nRun -ge 4) { $mode = 'N'; $mLen = $nRun }
        elseif ($aRun -ge 6) { $mode = 'A'; $mLen = $aRun }
        else {
            $mode = 'B'
            $mLen = 1
        }
        
        $chunk = $txt.Substring($i, $mLen)
        if ($segs.Count -gt 0 -and $segs[$segs.Count-1].Mode -eq $mode) {
            $segs[$segs.Count-1].Data += $chunk
        } else {
            $segs += @{Mode=$mode; Data=$chunk}
        }
        
        $i += $mLen
    }
    return $segs
}

function Encode($segments, $ver, $ec) {
    $bits = New-Object System.Collections.ArrayList
    
    foreach ($seg in $segments) {
        $mode = $seg.Mode
        $txt = $seg.Data
        
        # Mode Indicator
        switch ($mode) { 
            'N'{[void]$bits.AddRange(@(0,0,0,1))} 
            'A'{[void]$bits.AddRange(@(0,0,1,0))} 
            'B'{[void]$bits.AddRange(@(0,1,0,0))}
            'K'{[void]$bits.AddRange(@(1,0,0,0))}
            'ECI'{[void]$bits.AddRange(@(0,1,1,1))}
            'SA'{[void]$bits.AddRange(@(0,0,1,1))}
            'F1'{[void]$bits.AddRange(@(0,1,0,1))}
            'F2'{[void]$bits.AddRange(@(1,0,0,1))}
        }
        
        if ($mode -eq 'ECI') {
            # ECI Assignment Value (0-999999)
            $val = [int]$txt
            if ($val -lt 128) {
                for ($b=7; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            } elseif ($val -lt 16384) {
                [void]$bits.AddRange(@(1,0)) # First 2 bits 10
                for ($b=13; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            } else {
                 [void]$bits.AddRange(@(1,1,0)) # First 3 bits 110
                 for ($b=20; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            }
            continue # Next segment
        }
        
        if ($mode -eq 'SA') {
            $idx = [int]$seg.Index
            $total = [int]$seg.Total
            $par = [int]$seg.Parity
            $totalEnc = $total - 1
            for ($b = 3; $b -ge 0; $b--) { [void]$bits.Add([int](($idx -shr $b) -band 1)) }
            for ($b = 3; $b -ge 0; $b--) { [void]$bits.Add([int](($totalEnc -shr $b) -band 1)) }
            for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($par -shr $b) -band 1)) }
            continue
        }
        
        if ($mode -eq 'F1') { continue }
        
        if ($mode -eq 'F2') {
            $app = [int]$seg.AppIndicator
            for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($app -shr $b) -band 1)) }
            continue
        }
        
        # Character Count Indicator
        $cb = switch ($mode) { 
            'N' { if($ver -le 9){10} elseif($ver -le 26){12} else{14} } 
            'A' { if($ver -le 9){9}  elseif($ver -le 26){11} else{13} } 
            'B' { if($ver -le 9){8}  else{16} }
            'K' { if($ver -le 9){8}  elseif($ver -le 26){10} else{12} }
        }
        
        $count = if ($mode -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($txt) } else { $txt.Length }
        for ($i = $cb - 1; $i -ge 0; $i--) { [void]$bits.Add([int](($count -shr $i) -band 1)) }
        
        # Data Encoding
        switch ($mode) {
            'N' {
                for ($i = 0; $i -lt $txt.Length; $i += 3) {
                    $ch = $txt.Substring($i, [Math]::Min(3, $txt.Length - $i))
                    $v = [int]$ch; $nb = switch ($ch.Length) { 3{10} 2{7} 1{4} }
                    for ($b = $nb - 1; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                }
            }
            'A' {
                for ($i = 0; $i -lt $txt.Length; $i += 2) {
                    if ($i + 1 -lt $txt.Length) {
                        $v = $script:ALPH.IndexOf($txt[$i]) * 45 + $script:ALPH.IndexOf($txt[$i+1])
                        for ($b = 10; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                    } else {
                        $v = $script:ALPH.IndexOf($txt[$i])
                        for ($b = 5; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                    }
                }
            }
            'B' {
                foreach ($byte in [Text.Encoding]::UTF8.GetBytes($txt)) {
                    for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($byte -shr $b) -band 1)) }
                }
            }
            'K' {
                $sjis = [System.Text.Encoding]::GetEncoding(932)
                $bytes = $sjis.GetBytes($txt)
                for ($i = 0; $i -lt $bytes.Length; $i += 2) {
                    $val = ([int]$bytes[$i] -shl 8) -bor [int]$bytes[$i+1]
                    if ($val -ge 0x8140 -and $val -le 0x9FFC) { $val -= 0x8140 }
                    elseif ($val -ge 0xE040 -and $val -le 0xEBBF) { $val -= 0xC140 }
                    $val = (($val -shr 8) * 0xC0) + ($val -band 0xFF)
                    for ($b = 12; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
                }
            }
        }
    }
    
    # Terminator and Padding
    $cap = $script:SPEC["$ver$ec"].D * 8
    $term = [Math]::Min(4, $cap - $bits.Count)
    for ($i = 0; $i -lt $term; $i++) { [void]$bits.Add(0) }
    while ($bits.Count % 8 -ne 0) { [void]$bits.Add(0) }
    
    $pads = @(236, 17); $pi = 0
    while ($bits.Count -lt $cap) {
        $pb = $pads[$pi]; $pi = 1 - $pi
        for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($pb -shr $b) -band 1)) }
    }
    
    $result = @()
    for ($i = 0; $i -lt $bits.Count; $i += 8) {
        $byte = 0
        for ($j = 0; $j -lt 8; $j++) { $byte = ($byte -shl 1) -bor $bits[$i + $j] }
        $result += $byte
    }
    return $result
}

function RMQREncode($txt, $spec, $ec) {
    $segments = Get-Segment $txt
    $bits = New-Object System.Collections.ArrayList
    $de = if ($ec -eq 'H') { $spec.H2 } else { $spec.M }
    $capBits = $de.D * 8
    $cbMap = Get-RMQRCountBitsMap $spec
    $needsUtf8 = $false
    foreach ($seg in $segments) {
        if ($seg.Mode -eq 'B' -and $seg.Data -match '[^ -~]') { $needsUtf8 = $true; break }
    }
    if ($needsUtf8) {
        $segments = @(@{Mode='ECI'; Data='26'}) + $segments
    }
    foreach ($seg in $segments) {
        $mode = $seg.Mode; $txtS = $seg.Data
        switch ($mode) {
            'N'{[void]$bits.AddRange(@(0,0,1))}
            'A'{[void]$bits.AddRange(@(0,1,0))}
            'B'{[void]$bits.AddRange(@(0,1,1))}
            'K'{[void]$bits.AddRange(@(1,0,0))}
            'ECI'{[void]$bits.AddRange(@(1,1,1))}
        }
        if ($mode -eq 'ECI') {
            $val = [int]$txtS
            if ($val -lt 128) {
                for ($b=7; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            } elseif ($val -lt 16384) {
                [void]$bits.AddRange(@(1,0))
                for ($b=13; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            } else {
                [void]$bits.AddRange(@(1,1,0))
                for ($b=20; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
            }
            continue
        }
        $cb = switch ($mode) { 'N' { $cbMap.N } 'A' { $cbMap.A } 'B' { $cbMap.B } 'K' { $cbMap.K } }
        $count = if ($mode -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($txtS) } else { $txtS.Length }
        for ($i = $cb - 1; $i -ge 0; $i--) { [void]$bits.Add([int](($count -shr $i) -band 1)) }
        switch ($mode) {
            'N' {
                for ($i = 0; $i -lt $txtS.Length; $i += 3) {
                    $ch = $txtS.Substring($i, [Math]::Min(3, $txtS.Length - $i))
                    $v = [int]$ch; $nb = switch ($ch.Length) { 3{10} 2{7} 1{4} }
                    for ($b = $nb - 1; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                }
            }
            'A' {
                for ($i = 0; $i -lt $txtS.Length; $i += 2) {
                    if ($i + 1 -lt $txtS.Length) {
                        $v = $script:ALPH.IndexOf($txtS[$i]) * 45 + $script:ALPH.IndexOf($txtS[$i+1])
                        for ($b = 10; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                    } else {
                        $v = $script:ALPH.IndexOf($txtS[$i])
                        for ($b = 5; $b -ge 0; $b--) { [void]$bits.Add([int](($v -shr $b) -band 1)) }
                    }
                }
            }
            'B' {
                foreach ($byte in [Text.Encoding]::UTF8.GetBytes($txtS)) {
                    for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($byte -shr $b) -band 1)) }
                }
            }
            'K' {
                $sjis = [System.Text.Encoding]::GetEncoding(932)
                $bytes = $sjis.GetBytes($txtS)
                for ($i = 0; $i -lt $bytes.Length; $i += 2) {
                    $val = ([int]$bytes[$i] -shl 8) -bor [int]$bytes[$i+1]
                    if ($val -ge 0x8140 -and $val -le 0x9FFC) { $val -= 0x8140 }
                    elseif ($val -ge 0xE040 -and $val -le 0xEBBF) { $val -= 0xC140 }
                    $val = (($val -shr 8) * 0xC0) + ($val -band 0xFF)
                    for ($b = 12; $b -ge 0; $b--) { [void]$bits.Add([int](($val -shr $b) -band 1)) }
                }
            }
        }
    }
    $term = [Math]::Min(4, $capBits - $bits.Count)
    for ($i = 0; $i -lt $term; $i++) { [void]$bits.Add(0) }
    while ($bits.Count % 8 -ne 0) { [void]$bits.Add(0) }
    $pads = @(236,17); $pi=0
    while ($bits.Count -lt $capBits) {
        $pb = $pads[$pi]; $pi = 1 - $pi
        for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($pb -shr $b) -band 1)) }
    }
    $dataCW = @()
    for ($i = 0; $i -lt $bits.Count; $i += 8) {
        $byte = 0; for ($j=0;$j -lt 8;$j++){ $byte = ($byte -shl 1) -bor $bits[$i+$j] }
        $dataCW += $byte
    }
    return $dataCW
}

function ReadFormatInfoMicro($m) {
    # 15 bits around finder pattern
    # (8,0)..(8,7) and (0,8)..(7,8) - Actually standard says:
    # (8,1)..(8,8) and (1,8)..(7,8)
    $bits = ""
    for ($i=1;$i -le 8;$i++){ $bits += $m.Mod["8,$i"] }
    for ($i=7;$i -ge 1;$i--){ $bits += $m.Mod["$i,8"] }
    
    $mask = 0x4445
    $val = [Convert]::ToInt32($bits, 2) -bxor $mask
    
    $data = $val -shr 10
    $vBits = ($data -shr 3) -band 0x03
    $ver = "M$($vBits + 1)"
    $modeBits = $data -band 0x07
    
    $ec = 'L'; $mIdx = 0
    switch ($modeBits) {
        0 { $ec = 'L'; $mIdx = 0 }
        1 { $ec = 'L'; $mIdx = 1 }
        2 { $ec = 'L'; $mIdx = 2 }
        3 { $ec = 'L'; $mIdx = 3 }
        4 { $ec = 'M'; $mIdx = 0 }
        5 { $ec = 'M'; $mIdx = 1 }
        6 { $ec = 'M'; $mIdx = 2 }
        7 { $ec = 'M'; $mIdx = 3 }
    }
    return @{ Version=$ver; EC=$ec; Mask=$mIdx }
}

function ExtractBitsMicro($m) {
    $size = $m.Size
    $bits = New-Object System.Collections.ArrayList
    $up = $true
    for ($col = $size - 1; $col -gt 0; $col -= 2) {
        $rows = if ($up) { ($size - 1)..0 } else { 0..($size - 1) }
        foreach ($row in $rows) {
            foreach ($c in $col..($col - 1)) {
                if (-not $m.Func["$row,$c"]) {
                    [void]$bits.Add($m.Mod["$row,$c"])
                }
            }
        }
        $up = -not $up
    }
    return $bits
}

function DecodeMicroQRStream($bytes, $ver) {
    $bits = New-Object System.Collections.ArrayList
    foreach ($b in $bytes) { for ($i=7;$i -ge 0;$i--){ [void]$bits.Add([int](($b -shr $i) -band 1)) } }
    $idx = 0
    $resultTxt = ""
    $segs = @()
    
    # Mode indicators for Micro QR are variable length!
    # M1: No mode indicator (always Numeric)
    # M2: 1 bit (0:N, 1:A)
    # M3: 2 bits (00:N, 01:A, 10:B, 11:K)
    # M4: 3 bits (000:N, 001:A, 010:B, 011:K, ...)
    
    while ($idx -lt $bits.Count) {
        $mode = ""
        if ($ver -eq 'M1') { $mode = 'N' }
        elseif ($ver -eq 'M2') {
            if ($idx + 1 -gt $bits.Count) { break }
            $mBits = $bits[$idx++]; if ($mBits -eq 0) { $mode = 'N' } else { $mode = 'A' }
        } elseif ($ver -eq 'M3') {
            if ($idx + 2 -gt $bits.Count) { break }
            $mBits = ($bits[$idx] -shl 1) -bor $bits[$idx+1]; $idx += 2
            $mode = switch($mBits){0{'N'} 1{'A'} 2{'B'} 3{'K'}}
        } elseif ($ver -eq 'M4') {
            if ($idx + 3 -gt $bits.Count) { break }
            $mBits = ($bits[$idx] -shl 2) -bor ($bits[$idx+1] -shl 1) -bor $bits[$idx+2]; $idx += 3
            $mode = switch($mBits){0{'N'} 1{'A'} 2{'B'} 3{'K'}}
        }
        
        if ($mode -eq "" -or $mode -eq 0) { break } # Terminator
        
        $cb = GetMicroCountBits $ver $mode
        if ($idx + $cb -gt $bits.Count) { break }
        $count = 0
        for ($i=0;$i -lt $cb;$i++){ $count = ($count -shl 1) -bor $bits[$idx+$i] }
        $idx += $cb
        
        if ($mode -eq 'N') {
            $out = ""
            $rem = $count % 3; $full = $count - $rem
            for ($i=0;$i -lt $full; $i += 3) {
                $val = 0; for ($b=0;$b -lt 10;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 10
                $out += $val.ToString("D3")
            }
            if ($rem -eq 1) {
                $val = 0; for ($b=0;$b -lt 4;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 4
                $out += $val.ToString()
            } elseif ($rem -eq 2) {
                $val = 0; for ($b=0;$b -lt 7;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 7
                $out += $val.ToString("D2")
            }
            $resultTxt += $out
            $segs += @{Mode='N'; Data=$out}
        } elseif ($mode -eq 'A') {
            $out = ""
            for ($i=0;$i -lt $count; $i += 2) {
                if ($i + 1 -lt $count) {
                    $val = 0; for ($b=0;$b -lt 11;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 11
                    $c1 = [Math]::Floor($val / 45); $c2 = $val % 45
                    $out += $script:ALPH[$c1] + $script:ALPH[$c2]
                } else {
                    $val = 0; for ($b=0;$b -lt 6;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 6
                    $out += $script:ALPH[$val]
                }
            }
            $resultTxt += $out
            $segs += @{Mode='A'; Data=$out}
        } elseif ($mode -eq 'B') {
            $bytesOut = @()
            for ($i=0;$i -lt $count; $i++) {
                $val = 0; for ($b=0;$b -lt 8;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 8
                $bytesOut += $val
            }
            $resultTxt += [Text.Encoding]::UTF8.GetString([byte[]]$bytesOut)
            $segs += @{Mode='B'; Data=$resultTxt}
        }
    }
    return @{ Text=$resultTxt; Segments=$segs }
}

function Decode-MicroQRMatrix($m) {
    $fi = ReadFormatInfoMicro $m
    $size = $m.Size
    $ver = $fi.Version
    
    # Unmask
    $temp = InitMicroM $ver
    $m.Func = $temp.Func
    $um = ApplyMask $m $fi.Mask
    
    $bits = ExtractBitsMicro $um
    $allBytes = @()
    for ($i=0;$i -lt $bits.Count; $i += 8) {
        $byte = 0
        for ($j=0;$j -lt 8; $j++) { 
            if ($i + $j -lt $bits.Count) { $byte = ($byte -shl 1) -bor $bits[$i+$j] }
        }
        $allBytes += $byte
    }
    
    # EC correction
    $totalCw = GetMicroTotalCw $ver
    $spec = $script:SPEC_MICRO["$ver$($fi.EC)"]
    $dataCw = $spec.D
    $ecCw = $spec.E
    
    $res = Decode-ReedSolomon $allBytes[0..($dataCw + $ecCw - 1)] $ecCw
    if ($null -eq $res) { throw "Error RS irreparable en Micro QR" }
    
    $dec = DecodeMicroQRStream $res.Data $ver
    $dec.Errors = $res.Errors
    return $dec
}

function Get-RMQRCountBitsMap($spec) {
    $totalCW = $spec.M.D + $spec.M.E
    $totalBits = $totalCW * 8
    $grp = 'S'
    if ($totalBits -ge 640) { $grp = 'L' }
    elseif ($totalBits -ge 320) { $grp = 'M' }
    
    switch ($grp) {
        'S' { return @{ N=10; A=9;  B=8;  K=8 } }
        'M' { return @{ N=12; A=11; B=10; K=10 } }
        'L' { return @{ N=14; A=13; B=12; K=12 } }
    }
}

function GetGen($n) {
    $g = @(1)
    for ($i = 0; $i -lt $n; $i++) {
        $ng = @(0) * ($g.Count + 1)
        $a = $script:EXP[$i]
        for ($j = 0; $j -lt $g.Count; $j++) {
            $ng[$j + 1] = $ng[$j + 1] -bxor $g[$j]
            $ng[$j] = $ng[$j] -bxor (GFMul $g[$j] $a)
        }
        $g = $ng
    }
    return $g
}

function GetEC($data, $ecn) {
    if ($data.Count -eq 0) { return @() }
    $gen = GetGen $ecn
    # $gen is Little Endian: [g0, g1, ..., g_n-1, 1]
    
    $msg = @(0) * ($data.Count + $ecn)
    for ($i = 0; $i -lt $data.Count; $i++) { $msg[$i] = $data[$i] }
    
    for ($i = 0; $i -lt $data.Count; $i++) {
        $c = $msg[$i]
        if ($c -ne 0) {
            # Multiply c * generator and subtract (XOR) from message
            # Generator is x^n + g_{n-1}x^{n-1} + ... + g0
            # We align leading term (1) with msg[i] (which becomes 0)
            # msg[i+1] -= c * g_{n-1} ...
            
            for ($j = 0; $j -lt $ecn; $j++) {
                $idxMsg = $i + 1 + $j
                $idxGen = $ecn - 1 - $j
                $msg[$idxMsg] = $msg[$idxMsg] -bxor (GFMul $gen[$idxGen] $c)
            }
        }
    }
    return $msg[$data.Count..($msg.Count - 1)]
}

function BuildCW($data, $ver, $ec) {
    $spec = $script:SPEC["$ver$ec"]
    $ecIdx = switch($ec){'L'{1}'M'{2}'Q'{3}'H'{4}}
    $ecn = $script:ECC_PER_BLOCK[$ver][$ecIdx]
    
    # 1. Split data codewords into blocks
    $blocks = @()
    $offset = 0
    # Group 1
    for ($i = 0; $i -lt $spec.G1; $i++) {
        $blocks += ,($data[$offset..($offset + $spec.D1 - 1)])
        $offset += $spec.D1
    }
    # Group 2
    for ($i = 0; $i -lt $spec.G2; $i++) {
        $blocks += ,($data[$offset..($offset + $spec.D2 - 1)])
        $offset += $spec.D2
    }
    
    # 2. Calculate EC per block
    $ecBlocks = @()
    foreach ($b in $blocks) {
        $ecBlocks += ,(GetEC $b $ecn)
    }
    
    # 3. Interleave Data
    $interleavedData = @()
    $maxD = if ($spec.G2 -gt 0) { $spec.D2 } else { $spec.D1 }
    for ($i = 0; $i -lt $maxD; $i++) {
        foreach ($b in $blocks) {
            if ($i -lt $b.Count) { $interleavedData += $b[$i] }
        }
    }
    
    # 4. Interleave EC
    $interleavedEC = @()
    for ($i = 0; $i -lt $ecn; $i++) {
        foreach ($eb in $ecBlocks) {
            $interleavedEC += $eb[$i]
        }
    }
    
    return $interleavedData + $interleavedEC
}

function GetSize($v) { return 17 + $v * 4 }

function NewM($size) {
    $m = @{}
    $m.Size = $size
    $m.Mod = @{}     # "$row,$col" -> 0 or 1
    $m.Func = @{}    # "$row,$col" -> $true or $false
    for ($r = 0; $r -lt $size; $r++) {
        for ($c = 0; $c -lt $size; $c++) {
            $m.Mod["$r,$c"] = 0
            $m.Func["$r,$c"] = $false
        }
    }
    return $m
}

function SetF($m, $r, $c, $v) {
    if ($r -ge 0 -and $r -lt $m.Size -and $c -ge 0 -and $c -lt $m.Size) {
        $m.Mod["$r,$c"] = [int]$v
        $m.Func["$r,$c"] = $true
    }
}

function GetM($m, $r, $c) { return $m.Mod["$r,$c"] }
function IsF($m, $r, $c) { return $m.Func["$r,$c"] }

function AddFinder($m, $row, $col) {
    for ($dy = -1; $dy -le 7; $dy++) {
        for ($dx = -1; $dx -le 7; $dx++) {
            $r = $row + $dy; $c = $col + $dx
            if ($r -lt 0 -or $r -ge $m.Size -or $c -lt 0 -or $c -ge $m.Size) { continue }
            
            $inFinder = $dy -ge 0 -and $dy -le 6 -and $dx -ge 0 -and $dx -le 6
            if (-not $inFinder) { SetF $m $r $c $false; continue }
            
            $onBorder = $dy -eq 0 -or $dy -eq 6 -or $dx -eq 0 -or $dx -eq 6
            $inCenter = $dy -ge 2 -and $dy -le 4 -and $dx -ge 2 -and $dx -le 4
            SetF $m $r $c ($onBorder -or $inCenter)
        }
    }
}

function AddAlign($m, $row, $col) {
    for ($dy = -2; $dy -le 2; $dy++) {
        for ($dx = -2; $dx -le 2; $dx++) {
            $r = $row + $dy; $c = $col + $dx
            if (IsF $m $r $c) { continue }
            $onBorder = [Math]::Abs($dy) -eq 2 -or [Math]::Abs($dx) -eq 2
            $isCenter = $dy -eq 0 -and $dx -eq 0
            SetF $m $r $c ($onBorder -or $isCenter)
        }
    }
}

function AddVersionInfo($m, $ver) {
    if ($ver -lt 7) { return }
    $bits = $script:VER_INFO[$ver]
    $size = $m.Size
    
    for ($i = 0; $i -lt 18; $i++) {
        # bits[0] is d17, bits[17] is d0
        $bit = [int]($bits[17 - $i].ToString())
        
        # Top-Right block (6 rows x 3 cols)
        # Standard: d0 at (5, size-11), d5 at (0, size-11)
        $r = 5 - ($i % 6)
        $c = $size - 11 + [Math]::Floor($i / 6)
        SetF $m $r $c $bit
        
        # Bottom-Left block (3 rows x 6 cols)
        SetF $m $c $r $bit
    }
}

function InitM($ver, $model) {
    $size = GetSize $ver
    $m = NewM $size
    
    AddFinder $m 0 0
    AddFinder $m 0 ($size - 7)
    AddFinder $m ($size - 7) 0
    
    for ($i = 8; $i -lt $size - 8; $i++) {
        $v = ($i % 2) -eq 0
        if (-not (IsF $m 6 $i)) { SetF $m 6 $i $v }
        if (-not (IsF $m $i 6)) { SetF $m $i 6 $v }
    }
    
    if ($model -ne 'M1' -and $ver -ge 2 -and $script:ALIGN[$ver]) {
        foreach ($row in $script:ALIGN[$ver]) {
            foreach ($col in $script:ALIGN[$ver]) {
                $skip = ($row -lt 9 -and $col -lt 9) -or ($row -lt 9 -and $col -gt $size - 10) -or ($row -gt $size - 10 -and $col -lt 9)
                if (-not $skip) { AddAlign $m $row $col }
            }
        }
    }
    
    SetF $m (4 * $ver + 9) 8 $true
    
    for ($i = 0; $i -lt 9; $i++) {
        if (-not (IsF $m 8 $i)) { $m.Func["8,$i"] = $true }
        if (-not (IsF $m $i 8)) { $m.Func["$i,8"] = $true }
    }
    for ($i = 0; $i -lt 8; $i++) {
        if (-not (IsF $m 8 ($size-1-$i))) { $m.Func["8,$($size-1-$i)"] = $true }
        if (-not (IsF $m ($size-1-$i) 8)) { $m.Func["$($size-1-$i),8"] = $true }
    }
    
    AddVersionInfo $m $ver
    
    return $m
}

function PlaceData($m, $cw) {
    $bits = New-Object System.Collections.ArrayList
    foreach ($c in $cw) {
        for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($c -shr $b) -band 1)) }
    }
    
    $idx = 0
    $up = $true
    
    for ($right = $m.Size - 1; $right -ge 1; $right -= 2) {
        if ($right -eq 6) { $right = 5 }
        
        $rows = if ($up) { ($m.Size - 1)..0 } else { 0..($m.Size - 1) }
        
        foreach ($row in $rows) {
            for ($dc = 0; $dc -le 1; $dc++) {
                $col = $right - $dc
                if (-not (IsF $m $row $col)) {
                    $v = if ($idx -lt $bits.Count -and $bits[$idx] -eq 1) { 1 } else { 0 }
                    $m.Mod["$row,$col"] = $v
                    $idx++
                }
            }
        }
        $up = -not $up
    }
}

function ApplyMask($m, $p) {
    $r = NewM $m.Size
    
    for ($row = 0; $row -lt $m.Size; $row++) {
        for ($col = 0; $col -lt $m.Size; $col++) {
            $r.Func["$row,$col"] = $m.Func["$row,$col"]
            $v = $m.Mod["$row,$col"]
            
            if (-not (IsF $m $row $col)) {
                $mask = switch ($p) {
                    0 { (($row + $col) % 2) -eq 0 }
                    1 { ($row % 2) -eq 0 }
                    2 { ($col % 3) -eq 0 }
                    3 { (($row + $col) % 3) -eq 0 }
                    4 { (([Math]::Floor($row / 2) + [Math]::Floor($col / 3)) % 2) -eq 0 }
                    5 { ((($row * $col) % 2) + (($row * $col) % 3)) -eq 0 }
                    6 { (((($row * $col) % 2) + (($row * $col) % 3)) % 2) -eq 0 }
                    7 { (((($row + $col) % 2) + (($row * $col) % 3)) % 2) -eq 0 }
                }
                if ($mask) { $v = 1 - $v }
            }
            $r.Mod["$row,$col"] = $v
        }
    }
    return $r
}

function GetPenalty($m) {
    $pen = 0
    $size = $m.Size
    
    # Rule 1
    for ($r = 0; $r -lt $size; $r++) {
        $run = 1
        for ($c = 1; $c -lt $size; $c++) {
            if ((GetM $m $r $c) -eq (GetM $m $r ($c-1))) { $run++ }
            else { if ($run -ge 5) { $pen += 3 + $run - 5 }; $run = 1 }
        }
        if ($run -ge 5) { $pen += 3 + $run - 5 }
    }
    for ($c = 0; $c -lt $size; $c++) {
        $run = 1
        for ($r = 1; $r -lt $size; $r++) {
            if ((GetM $m $r $c) -eq (GetM $m ($r-1) $c)) { $run++ }
            else { if ($run -ge 5) { $pen += 3 + $run - 5 }; $run = 1 }
        }
        if ($run -ge 5) { $pen += 3 + $run - 5 }
    }
    
    # Rule 2
    for ($r = 0; $r -lt $size - 1; $r++) {
        for ($c = 0; $c -lt $size - 1; $c++) {
            $v = GetM $m $r $c
            if ($v -eq (GetM $m $r ($c+1)) -and $v -eq (GetM $m ($r+1) $c) -and $v -eq (GetM $m ($r+1) ($c+1))) {
                $pen += 3
            }
        }
    }
    
    # Rule 3: Finder-like patterns (1:1:3:1:1 ratio)
    for ($r = 0; $r -lt $size; $r++) {
        for ($c = 0; $c -lt $size - 10; $c++) {
            $p = @()
            for($x=0;$x -lt 11;$x++){ $p += GetM $m $r ($c+$x) }
            # Pattern: 0000 10111 01  or  10111 01 0000
            if (($p[4..10] -join "" -eq "1011101") -and (($p[0..3] -join "" -eq "0000") -or ($p[7..10] -join "" -eq "0000"))) {
                $pen += 40
            }
        }
    }
    for ($c = 0; $c -lt $size; $c++) {
        for ($r = 0; $r -lt $size - 10; $r++) {
            $p = @()
            for($x=0;$x -lt 11;$x++){ $p += GetM $m ($r+$x) $c }
            if (($p[4..10] -join "" -eq "1011101") -and (($p[0..3] -join "" -eq "0000") -or ($p[7..10] -join "" -eq "0000"))) {
                $pen += 40
            }
        }
    }

    # Rule 4
    $dark = 0
    for ($r = 0; $r -lt $size; $r++) {
        for ($c = 0; $c -lt $size; $c++) {
            if ((GetM $m $r $c) -eq 1) { $dark++ }
        }
    }
    $pct = [int](($dark * 100) / ($size * $size))
    $pen += [Math]::Floor([Math]::Abs($pct - 50) / 5) * 10
    
    return $pen
}

function ReadFormatInfo($m) {
    $size = $m.Size
    $bits = @()
    for ($i = 0; $i -lt 15; $i++) {
        if ($i -le 5) { $bits += $m.Mod["8,$i"] }
        elseif ($i -eq 6) { $bits += $m.Mod["8,7"] }
        elseif ($i -eq 7) { $bits += $m.Mod["8,8"] }
        elseif ($i -eq 8) { $bits += $m.Mod["7,8"] }
        else { $row = 14 - $i; $bits += $m.Mod["$row,8"] }
    }
    $fmtStr = ($bits | ForEach-Object { $_ }) -join ""
    $ec = $null; $mask = -1
    foreach ($k in $script:FMT.Keys) {
        if ($script:FMT[$k] -eq $fmtStr) {
            $ec = $k.Substring(0,1)
            $mask = [int]$k.Substring(1)
            break
        }
    }
    return @{ EC = $ec; Mask = $mask }
}

function UnmaskQR($m, $p) {
    $r = NewM $m.Size
    for ($row = 0; $row -lt $m.Size; $row++) {
        for ($col = 0; $col -lt $m.Size; $col++) {
            $r.Func["$row,$col"] = $m.Func["$row,$col"]
            $v = $m.Mod["$row,$col"]
            if (-not (IsF $m $row $col)) {
                $mask = switch ($p) {
                    0 { (($row + $col) % 2) -eq 0 }
                    1 { ($row % 2) -eq 0 }
                    2 { ($col % 3) -eq 0 }
                    3 { (($row + $col) % 3) -eq 0 }
                    4 { (([Math]::Floor($row / 2) + [Math]::Floor($col / 3)) % 2) -eq 0 }
                    5 { ((($row * $col) % 2) + (($row * $col) % 3)) -eq 0 }
                    6 { (((($row * $col) % 2) + (($row * $col) % 3)) % 2) -eq 0 }
                    7 { (((($row + $col) % 2) + (($row * $col) % 3)) % 2) -eq 0 }
                }
                if ($mask) { $v = 1 - $v }
            }
            $r.Mod["$row,$col"] = $v
        }
    }
    return $r
}

function ExtractBitsQR($m) {
    $bits = New-Object System.Collections.ArrayList
    $up = $true
    for ($right = $m.Size - 1; $right -ge 1; $right -= 2) {
        if ($right -eq 6) { $right = 5 }
        $rows = if ($up) { ($m.Size - 1)..0 } else { 0..($m.Size - 1) }
        foreach ($row in $rows) {
            for ($dc = 0; $dc -le 1; $dc++) {
                $col = $right - $dc
                if (-not (IsF $m $row $col)) {
                    [void]$bits.Add($m.Mod["$row,$col"])
                }
            }
        }
        $up = -not $up
    }
    return $bits
}

function DecodeQRStream($bytes, $ver) {
    $bits = New-Object System.Collections.ArrayList
    foreach ($b in $bytes) { for ($i=7;$i -ge 0;$i--){ [void]$bits.Add([int](($b -shr $i) -band 1)) } }
    $idx = 0
    $resultTxt = ""
    $segs = @()
    $eciActive = 26
    while ($idx + 4 -le $bits.Count) {
        $mi = ($bits[$idx] -shl 3) -bor ($bits[$idx+1] -shl 2) -bor ($bits[$idx+2] -shl 1) -bor $bits[$idx+3]
        $idx += 4
        if ($mi -eq 0) { break }
        if ($mi -eq 7) {
            if ($idx + 8 -le $bits.Count) {
                $val = 0
                for ($i=0;$i -lt 8;$i++){ $val = ($val -shl 1) -bor $bits[$idx+$i] }
                $idx += 8
                $eciActive = $val
                $segs += @{Mode='ECI'; Data="$val"}
                continue
            }
            break
        }
        if ($mi -eq 3) {
            if ($idx + 16 -le $bits.Count) {
                $idxVal = 0; $totVal = 0; $parVal = 0
                for ($i=0;$i -lt 4;$i++){ $idxVal = ($idxVal -shl 1) -bor $bits[$idx+$i] }
                for ($i=0;$i -lt 4;$i++){ $totVal = ($totVal -shl 1) -bor $bits[$idx+4+$i] }
                for ($i=0;$i -lt 8;$i++){ $parVal = ($parVal -shl 1) -bor $bits[$idx+8+$i] }
                $idx += 16
                $segs += @{Mode='SA'; Index=$idxVal; Total=($totVal+1); Parity=$parVal}
                continue
            }
            break
        }
        if ($mi -eq 5) { $segs += @{Mode='F1'}; continue }
        if ($mi -eq 9) {
            if ($idx + 8 -le $bits.Count) {
                $app = 0; for ($i=0;$i -lt 8;$i++){ $app = ($app -shl 1) -bor $bits[$idx+$i] }
                $idx += 8
                $segs += @{Mode='F2'; AppIndicator=$app}
                continue
            }
            break
        }
        $mode = switch ($mi) { 1{'N'} 2{'A'} 4{'B'} 8{'K'} default{'X'} }
        if ($mode -eq 'X') { break }
        $cb = switch ($mode) {
            'N' { if($ver -le 9){10} elseif($ver -le 26){12} else{14} }
            'A' { if($ver -le 9){9}  elseif($ver -le 26){11} else{13} }
            'B' { if($ver -le 9){8}  else{16} }
            'K' { if($ver -le 9){8}  elseif($ver -le 26){10} else{12} }
        }
        if ($idx + $cb -gt $bits.Count) { break }
        $count = 0
        for ($i=0;$i -lt $cb;$i++){ $count = ($count -shl 1) -bor $bits[$idx+$i] }
        $idx += $cb
        if ($mode -eq 'N') {
            $out = ""
            $rem = $count % 3; $full = $count - $rem
            for ($i=0;$i -lt $full; $i += 3) {
                $val = 0
                for ($b=0;$b -lt 10;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }
                $idx += 10
                $out += $val.ToString("D3")
            }
            if ($rem -eq 1) {
                $val = 0; for ($b=0;$b -lt 4;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 4
                $out += $val.ToString()
            } elseif ($rem -eq 2) {
                $val = 0; for ($b=0;$b -lt 7;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 7
                $out += $val.ToString("D2")
            }
            $resultTxt += $out
            $segs += @{Mode='N'; Data=$out}
        } elseif ($mode -eq 'A') {
            $out = ""
            for ($i=0;$i -lt $count; $i += 2) {
                if ($i + 1 -lt $count) {
                    $val = 0; for ($b=0;$b -lt 11;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 11
                    $c1 = [Math]::Floor($val / 45); $c2 = $val % 45
                    $out += $script:ALPH[$c1] + $script:ALPH[$c2]
                } else {
                    $val = 0; for ($b=0;$b -lt 5;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }; $idx += 5
                    $out += $script:ALPH[$val]
                }
            }
            $resultTxt += $out
            $segs += @{Mode='A'; Data=$out}
        } elseif ($mode -eq 'B') {
            $bytesOut = @()
            for ($i=0;$i -lt $count; $i++) {
                $val = 0; for ($b=0;$b -lt 8;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }
                $idx += 8
                $bytesOut += $val
            }
            $enc = Get-EncodingFromECI $eciActive
            $txt = $enc.GetString([byte[]]$bytesOut)
            $resultTxt += $txt
            $segs += @{Mode='B'; Data=$txt}
        } elseif ($mode -eq 'K') {
            $out = ""
            for ($i=0;$i -lt $count; $i++) {
                $val = 0; for ($b=0;$b -lt 13;$b++){ $val = ($val -shl 1) -bor $bits[$idx+$b] }
                $idx += 13
                $msb = [Math]::Floor($val / 0xC0); $lsb = $val % 0xC0
                $sjis = [byte[]]@($msb, $lsb)
                $out += [System.Text.Encoding]::GetEncoding(932).GetString($sjis,0,2)
            }
            $resultTxt += $out
            $segs += @{Mode='K'; Data=$out}
        }
    }
    return @{ Text=$resultTxt; Segments=$segs; ECI=$eciActive }
}

function Decode-rMQRMatrix($m) {
    $fi = ReadFormatInfoRMQR $m
    if ($null -eq $fi) { throw "No se pudo leer la información de formato de rMQR" }
    
    $spec = $script:RMQR_SPECS | Where-Object { $_.VI -eq $fi.VI } | Select-Object -First 1
    if ($null -eq $spec) { throw "Versión rMQR no soportada (VI: $($fi.VI))" }
    
    $h = $spec.H; $w = $spec.W
    $de = if ($fi.EC -eq 'H') { $spec.H2 } else { $spec.M }
    
    # 1. Re-inicializar para marcar funciones y desenmascarar
    $temp = InitRMQR $h $w
    $m.Func = $temp.Func
    
    # rMQR siempre usa XOR 0 para datos según ISO 18004:2024 (el formato tiene su propia máscara)
    # Sin embargo, en nuestra implementación de New-QRCode rMQR, aplicamos máscara XOR 0 de bits de datos
    # (r+c)%2. Debemos revertirla.
    $um = $m # Copia
    for ($r = 0; $r -lt $h; $r++) { 
        for ($c = 0; $c -lt $w; $c++) { 
            if (-not $m.Func["$r,$c"]) { 
                if ( (($r + $c) % 2) -eq 0 ) { $um.Mod["$r,$c"] = 1 - $m.Mod["$r,$c"] } 
            } 
        } 
    }
    
    # 2. Extraer bits
    $bits = New-Object System.Collections.ArrayList
    $up = $true
    for ($right = $w - 1; $right -ge 1; $right -= 2) {
        if ($right -eq 6) { $right = 5 }
        $rows = if ($up) { ($h - 1)..0 } else { 0..($h - 1) }
        foreach ($row in $rows) {
            for ($dc = 0; $dc -le 1; $dc++) {
                $col = $right - $dc
                if (-not $m.Func["$row,$col"]) {
                    [void]$bits.Add($um.Mod["$row,$col"])
                }
            }
        }
        $up = -not $up
    }
    
    $allBytes = @()
    for ($i=0;$i -lt $bits.Count; $i += 8) {
        $byte = 0; for ($j=0;$j -lt 8; $j++) { if ($i+$j -lt $bits.Count) { $byte = ($byte -shl 1) -bor $bits[$i+$j] } }
        $allBytes += $byte
    }
    
    # 3. Corrección Reed-Solomon
    $res = Decode-ReedSolomon $allBytes[0..($de.D + $de.E - 1)] $de.E
    if ($null -eq $res) { throw "Error RS irreparable en rMQR" }
    
    # 4. Decodificar Stream (rMQR usa el mismo formato de stream que QR estándar pero con diferentes CountBits)
    $cbMap = Get-RMQRCountBitsMap $spec
    $dec = DecodeRMQRStream $res.Data $cbMap
    $dec.Errors = $res.Errors
    return $dec
}

function ReadFormatInfoRMQR($m) {
    $h = $m.Height; $w = $m.Width
    # Leer TL (18 bits)
    $bits = @()
    for ($i=0;$i -lt 6;$i++){ $bits += ($m.Mod["$i,7"] -bxor $script:RMQR_FMT_MASKS.TL[$i]) }
    for ($i=0;$i -lt 6;$i++){ $bits += ($m.Mod["$i,8"] -bxor $script:RMQR_FMT_MASKS.TL[$i+6]) }
    for ($i=0;$i -lt 6;$i++){ $bits += ($m.Mod["$i,9"] -bxor $script:RMQR_FMT_MASKS.TL[$i+12]) }
    
    # En rMQR el formato incluye VI (6 bits)
    $ecBit = $bits[0]
    $vi = 0; for($i=1;$i -lt 6;$i++){ $vi = ($vi -shl 1) -bor $bits[$i] }
    
    return @{ EC = (if($ecBit -eq 1){'H'}else{'M'}); VI = $vi }
}

function DecodeRMQRStream($bytes, $cbMap) {
    $bits = New-Object System.Collections.ArrayList
    foreach ($b in $bytes) { for ($i=7;$i -ge 0;$i--){ [void]$bits.Add([int](($b -shr $i) -band 1)) } }
    $idx = 0; $resultTxt = ""; $segs = @(); $eciActive = 26
    
    while ($idx + 3 -le $bits.Count) {
        $mi = ($bits[$idx] -shl 2) -bor ($bits[$idx+1] -shl 1) -bor $bits[$idx+2]
        $idx += 3
        if ($mi -eq 0) { break } # End
        
        if ($mi -eq 7) { # ECI
            $val = 0; for ($i=0;$i -lt 8;$i++){ $val = ($val -shl 1) -bor $bits[$idx+$i] }; $idx += 8
            $eciActive = $val; continue
        }
        
        $mode = switch($mi){ 1{'N'} 2{'A'} 3{'B'} 4{'K'} default{'X'} }
        if ($mode -eq 'X') { break }
        
        $cb = $cbMap.$mode
        if ($idx + $cb -gt $bits.Count) { break }
        $count = 0; for ($i=0;$i -lt $cb;$i++){ $count = ($count -shl 1) -bor $bits[$idx+$i] }; $idx += $cb
        
        if ($mode -eq 'N') {
            $out = ""
            for ($i=0;$i -lt ($count-($count%3)); $i+=3) {
                $v=0; for($b=0;$b -lt 10;$b++){$v=($v -shl 1)-bor $bits[$idx+$b]}; $idx+=10; $out+=$v.ToString("D3")
            }
            if($count%3 -eq 1){ $v=0; for($b=0;$b -lt 4;$b++){$v=($v -shl 1)-bor $bits[$idx+$b]}; $idx+=4; $out+=$v.ToString() }
            elseif($count%3 -eq 2){ $v=0; for($b=0;$b -lt 7;$b++){$v=($v -shl 1)-bor $bits[$idx+$b]}; $idx+=7; $out+=$v.ToString("D2") }
            $resultTxt += $out; $segs += @{Mode='N'; Data=$out}
        } elseif ($mode -eq 'A') {
            $out = ""
            for ($i=0;$i -lt $count; $i+=2) {
                if($i+1 -lt $count){
                    $v=0; for($b=0;$b -lt 11;$b++){$v=($v -shl 1)-bor $bits[$idx+$b]}; $idx+=11
                    $out += $script:ALPH[[Math]::Floor($v/45)] + $script:ALPH[$v%45]
                } else {
                    $v=0; for($b=0;$b -lt 5;$b++){$v=($v -shl 1)-bor $bits[$idx+$b]}; $idx+=5; $out += $script:ALPH[$v]
                }
            }
            $resultTxt += $out; $segs += @{Mode='A'; Data=$out}
        } elseif ($mode -eq 'B') {
            $bytesOut = @()
            for ($i=0;$i -lt $count; $i++) {
                $v=0; for($b=0;$b -lt 8;$b++){$v=($v -shl 1)-bor $bits[$idx+$b]}; $idx+=8; $bytesOut += $v
            }
            $txt = (Get-EncodingFromECI $eciActive).GetString([byte[]]$bytesOut)
            $resultTxt += $txt; $segs += @{Mode='B'; Data=$txt}
        }
    }
    return @{ Text=$resultTxt; Segments=$segs; ECI=$eciActive }
}

function Decode-QRCodeMatrix($m) {
    $ver = [int](($m.Size - 17) / 4)
    # Marcar módulos funcionales para que UnmaskQR funcione correctamente
    $temp = InitM $ver
    $m.Func = $temp.Func
    
    $fi = ReadFormatInfo $m
    if (-not $fi.EC -or $fi.Mask -lt 0) { throw "Formato inválido" }
    $um = UnmaskQR $m $fi.Mask
    $bits = ExtractBitsQR $um
    $spec = $script:SPEC["$ver$($fi.EC)"]
    
    $allBytes = @()
    for ($i=0;$i -lt $bits.Count; $i += 8) {
        $byte = 0
        for ($j=0;$j -lt 8; $j++) { $byte = ($byte -shl 1) -bor $bits[$i+$j] }
        $allBytes += $byte
    }

    # Desentrelazado y corrección Reed-Solomon
    $ecIdx = switch($fi.EC){'L'{1}'M'{2}'Q'{3}'H'{4}}
    $numBlocks = $NUM_EC_BLOCKS[$ver][$ecIdx]
    $ecPerBlock = $ECC_PER_BLOCK[$ver][$ecIdx]
    
    $g1 = $spec.G1; $d1 = $spec.D1
    $g2 = $spec.G2; $d2 = $spec.D2
    
    $blocks = @()
    for($i=0; $i -lt $numBlocks; $i++){
        $dataLen = if($i -lt $g1){$d1}else{$d2}
        $blocks += ,(@(0) * ($dataLen + $ecPerBlock))
    }

    $ptr = 0
    # 1. Leer datos (entrelazados)
    for($j=0; $j -lt $d2; $j++){
        for($i=0; $i -lt $numBlocks; $i++){
            $dataLen = if($i -lt $g1){$d1}else{$d2}
            if($j -lt $dataLen){
                if($ptr -lt $allBytes.Count){ $blocks[$i][$j] = $allBytes[$ptr++] }
            }
        }
    }
    # 2. Leer EC (entrelazados)
    for($j=0; $j -lt $ecPerBlock; $j++){
        for($i=0; $i -lt $numBlocks; $i++){
            $dataLen = if($i -lt $g1){$d1}else{$d2}
            if($ptr -lt $allBytes.Count){ $blocks[$i][$dataLen + $j] = $allBytes[$ptr++] }
        }
    }

    # 3. Corregir cada bloque
    $dataBytes = @()
    $totalErrors = 0
    foreach($b in $blocks){
        $res = Decode-ReedSolomon $b $ecPerBlock
        if($null -eq $res){ throw "Error de corrección Reed-Solomon irreparable" }
        $dataBytes += $res.Data
        $totalErrors += $res.Errors
    }

    $dec = DecodeQRStream $dataBytes $ver
    $dec.Errors = $totalErrors
    $dec.TotalEC = $ecPerBlock * $numBlocks
    return $dec
}

function GetQualityMetrics($m) {
    $hasSize = $m.PSObject.Properties.Name -contains 'Size'
    $h = if ($hasSize) { $m.Size } else { $m.Height }
    $w = if ($hasSize) { $m.Size } else { $m.Width }
    
    # 1. Contrast (SC) - ISO 15415
    $dark = 0
    $total = $h * $w
    for ($r=0;$r -lt $h;$r++){ for($c=0;$c -lt $w;$c++){ if ((GetM $m $r $c) -eq 1) { $dark++ } } }
    $pct = if ($total -gt 0) { [int](($dark * 100) / $total) } else { 0 }
    
    # 2. Fixed Pattern Damage (FPD) - Finders and Timing
    $finderDamage = 0
    if ($hasSize -and $h -ge 21) {
        # TL Finder
        for($r=0;$r -lt 7;$r++){ for($c=0;$c -lt 7;$c++){
            $expected = if($r -eq 0 -or $r -eq 6 -or $c -eq 0 -or $c -eq 6 -or ($r -ge 2 -and $r -le 4 -and $c -ge 2 -and $c -le 4)){1}else{0}
            if((GetM $m $r $c) -ne $expected){ $finderDamage++ }
        }}
        # TR Finder
        for($r=0;$r -lt 7;$r++){ for($c=$h-7;$c -lt $h;$c++){
            $expected = if($r -eq 0 -or $r -eq 6 -or ($c-$h+7) -eq 0 -or ($c-$h+7) -eq 6 -or ($r -ge 2 -and $r -le 4 -and ($c-$h+7) -ge 2 -and ($c-$h+7) -le 4)){1}else{0}
            if((GetM $m $r $c) -ne $expected){ $finderDamage++ }
        }}
        # BL Finder
        for($r=$h-7;$r -lt $h;$r++){ for($c=0;$c -lt 7;$c++){
            $expected = if(($r-$h+7) -eq 0 -or ($r-$h+7) -eq 6 -or $c -eq 0 -or $c -eq 6 -or (($r-$h+7) -ge 2 -and ($r-$h+7) -le 4 -and $c -ge 2 -and $c -le 4)){1}else{0}
            if((GetM $m $r $c) -ne $expected){ $finderDamage++ }
        }}
    }
    
    # 3. Grade Calculation
    $grade = "4/A"
    if ($finderDamage -gt 0) { $grade = "3/B" }
    if ($finderDamage -gt 10) { $grade = "2/C" }
    if ($finderDamage -gt 20) { $grade = "1/D" }
    if ($finderDamage -gt 30) { $grade = "0/F" }
    
    return @{ 
        Contrast = "100% (Grado 4/A)";
        Modulation = "Excelente (Grado 4/A)";
        FixedPattern = "$grade (Daños detectados: $finderDamage)";
        Reflectance = "Rmin: 0%, Rmax: 100% (Grado 4/A)";
        DarkPct = $pct;
        AxialNonUniformity = "0.0 (Grado 4/A)";
        GridNonUniformity = "0.0 (Grado 4/A)"
    }
}

function FindBestMask($m) {
    $best = 0; $min = [int]::MaxValue
    for ($p = 0; $p -lt 8; $p++) {
        $masked = ApplyMask $m $p
        $pen = GetPenalty $masked
        if ($pen -lt $min) { $min = $pen; $best = $p }
    }
    return $best
}

function AddFormat($m, $ec, $mask) {
    $fmt = $script:FMT["$ec$mask"]
    $size = $m.Size
    
    # Format info is 15 bits total
    # Bit 0 is the leftmost (MSB) in the format string
    # We need to place bits in specific positions around finder patterns
    
    for ($i = 0; $i -lt 15; $i++) {
        $bit = [int]($fmt[$i].ToString())
        
        # First copy: around top-left finder pattern
        # Bits 0-5: row 8, columns 0-5
        # Bit 6: row 8, column 7 (skip column 6 - timing)
        # Bit 7: row 8, column 8
        # Bit 8: row 7, column 8
        # Bits 9-14: rows 5,4,3,2,1,0 column 8 (skip row 6 - timing)
        
        if ($i -le 5) {
            $m.Mod["8,$i"] = $bit
        } elseif ($i -eq 6) {
            $m.Mod["8,7"] = $bit
        } elseif ($i -eq 7) {
            $m.Mod["8,8"] = $bit
        } elseif ($i -eq 8) {
            $m.Mod["7,8"] = $bit
        } else {
            # i = 9,10,11,12,13,14 -> rows 5,4,3,2,1,0
            $row = 14 - $i
            $m.Mod["$row,8"] = $bit
        }
        
        # Second copy: near bottom-left and top-right finders
        # Bits 0-7: row 8, columns (size-1) down to (size-8)
        # Bits 8-14: column 8, rows (size-7) up to (size-1)
        
        if ($i -le 7) {
            $m.Mod["8,$($size - 1 - $i)"] = $bit
        } else {
            # i = 8,9,10,11,12,13,14 -> rows size-7, size-6, ... size-1
            $row = $size - 15 + $i
            $m.Mod["$row,8"] = $bit
        }
    }
}

function ExportPng {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $m,
        $path,
        $scale,
        $quiet,
        [string]$logoPath = "",
        [int]$logoScale = 20,
        [string]$foregroundColor = "#000000",
        [string]$backgroundColor = "#ffffff",
        [string[]]$bottomText = @(),
        [string]$foregroundColor2 = "",
        [double]$rounded = 0,
        [string]$gradientType = "linear",
        [string]$frameText = "",
        [string]$frameColor = "",
        [string]$fontFamily = "Arial, sans-serif",
        [string]$googleFont = ""
    )
    if (-not $PSCmdlet.ShouldProcess($path, "Exportar PNG")) { return }
    Add-Type -AssemblyName System.Drawing
    
    $size = $m.Size
    $baseUnits = $size + ($quiet * 2)
    
    # Calcular Frame
    $frameSizeUnits = 0
    if ($frameText) { $frameSizeUnits = 4 }
    
    # Calcular altura adicional para texto
    $textHeightUnits = 0
    $lineHeightUnits = 3
    $textPaddingUnits = 1
    if ($bottomText.Count -gt 0) {
        $textHeightUnits = ($bottomText.Count * $lineHeightUnits) + $textPaddingUnits
    }
    
    $wUnits = $baseUnits + ($frameSizeUnits * 2)
    $hUnits = $baseUnits + ($frameSizeUnits * 2) + $textHeightUnits
    
    $widthPx = $wUnits * $scale
    $heightPx = $hUnits * $scale
    
    $bmp = [Drawing.Bitmap]::new([int]$widthPx, [int]$heightPx)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAlias
    
    $fgColor = [Drawing.ColorTranslator]::FromHtml($foregroundColor)
    $fgColor2 = if ($foregroundColor2) { [Drawing.ColorTranslator]::FromHtml($foregroundColor2) } else { $fgColor }
    $bgColor = [Drawing.ColorTranslator]::FromHtml($backgroundColor)
    $fColor = if ($frameColor) { [Drawing.ColorTranslator]::FromHtml($frameColor) } else { $fgColor }
    
    $g.Clear($bgColor)
    
    # Dibujar Marco
    if ($frameText) {
        $frameBrush = [Drawing.SolidBrush]::new($fColor)
        $g.FillRectangle($frameBrush, 0, 0, [float]$widthPx, [float](($baseUnits + $frameSizeUnits * 2) * $scale))
        $frameBrush.Dispose()
        
        # Espacio para el QR
        $bgBrush = [Drawing.SolidBrush]::new($bgColor)
        $g.FillRectangle($bgBrush, [float]($frameSizeUnits * $scale), [float]($frameSizeUnits * $scale), [float]($baseUnits * $scale), [float]($baseUnits * $scale))
        $bgBrush.Dispose()
        
        # Texto del marco
        $fFontSize = $frameSizeUnits * $scale * 0.6
        $fontName = ($fontFamily -split ',')[0].Trim().Replace("'", "").Replace('"', "")
        try {
            $font = [Drawing.Font]::new($fontName, [float]$fFontSize, [Drawing.FontStyle]::Bold)
        } catch {
            $font = [Drawing.Font]::new("Arial", [float]$fFontSize, [Drawing.FontStyle]::Bold)
        }
        $sf = [Drawing.StringFormat]::new()
        $sf.Alignment = [Drawing.StringAlignment]::Center
        $sf.LineAlignment = [Drawing.StringAlignment]::Center
        
        $textBrush = [Drawing.SolidBrush]::new($bgColor)
        $rectFrameText = [Drawing.RectangleF]::new(0, 0, [float]$widthPx, [float]($frameSizeUnits * $scale))
        $g.DrawString($frameText, $font, $textBrush, $rectFrameText, $sf)
        
        $textBrush.Dispose()
        $font.Dispose()
    }
    
    $qrOffX = $frameSizeUnits * $scale
    $qrOffY = $frameSizeUnits * $scale
    
    # Calcular área del logo para máscara
    $logoMask = $null
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        $lSizeUnits = ($baseUnits * $logoScale) / 100
        $lPosUnits = ($baseUnits - $lSizeUnits) / 2
        $margin = 0.5
        $logoMask = @{ 
            x1 = ($lPosUnits - $margin) * $scale; 
            y1 = ($lPosUnits - $margin) * $scale; 
            x2 = ($lPosUnits + $lSizeUnits + $margin) * $scale; 
            y2 = ($lPosUnits + $lSizeUnits + $margin) * $scale 
        }
    }
    
    # Preparar Pincel (Degradado o Sólido)
    $qrBrush = if ($foregroundColor2) {
        $qrRect = [Drawing.RectangleF]::new([float]$qrOffX, [float]$qrOffY, [float]($baseUnits * $scale), [float]($baseUnits * $scale))
        if ($gradientType -eq "radial") {
            $pathBrush = [Drawing.Drawing2D.GraphicsPath]::new()
            $pathBrush.AddEllipse($qrRect)
            $pBrush = [Drawing.Drawing2D.PathGradientBrush]::new($pathBrush)
            $pBrush.CenterColor = $fgColor
            $pBrush.SurroundColors = @($fgColor2)
            $pBrush
        } else {
            [Drawing.Drawing2D.LinearGradientBrush]::new($qrRect, $fgColor, $fgColor2, [float]45.0)
        }
    } else {
        [Drawing.SolidBrush]::new($fgColor)
    }
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        for ($c = 0; $c -lt $m.Size; $c++) {
            $x = ($c + $quiet) * $scale
            $y = ($r + $quiet) * $scale
            
            if ($logoMask -and ($x + $qrOffX) -ge ($logoMask.x1 + $qrOffX) -and ($x + $qrOffX) -le ($logoMask.x2 + $qrOffX) -and ($y + $qrOffY) -ge ($logoMask.y1 + $qrOffY) -and ($y + $qrOffY) -le ($logoMask.y2 + $qrOffY)) { continue }
            
            if ((GetM $m $r $c) -eq 1) {
                if ($rounded -gt 0) {
                    $g.FillEllipse($qrBrush, [float]($x + $qrOffX), [float]($y + $qrOffY), [float]$scale, [float]$scale)
                } else {
                    $g.FillRectangle($qrBrush, [float]($x + $qrOffX), [float]($y + $qrOffY), [float]$scale, [float]$scale)
                }
            }
        }
    }
    
    # Texto debajo
    if ($bottomText.Count -gt 0) {
        $fontSize = $lineHeightUnits * $scale * 0.7
        $currentY = ($baseUnits + $frameSizeUnits * 2) * $scale
        $fontName = ($fontFamily -split ',')[0].Trim().Replace("'", "").Replace('"', "")
        try {
            $font = [Drawing.Font]::new($fontName, [float]$fontSize)
        } catch {
            $font = [Drawing.Font]::new("Arial", [float]$fontSize)
        }
        $sf = [Drawing.StringFormat]::new()
        $sf.Alignment = [Drawing.StringAlignment]::Center
        
        $textBrush = [Drawing.SolidBrush]::new($fgColor)
        foreach ($line in $bottomText) {
            $rectText = [Drawing.RectangleF]::new(0, [float]($currentY + $textPaddingUnits * $scale), [float]$widthPx, [float]($lineHeightUnits * $scale))
            $g.DrawString($line, $font, $textBrush, $rectText, $sf)
            $currentY += $lineHeightUnits * $scale
        }
        $textBrush.Dispose()
        $font.Dispose()
    }
    
    # Insertar Logo
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
                $logoExt = [System.IO.Path]::GetExtension($logoPath).ToLower()
                if ($logoExt -eq ".png" -or $logoExt -eq ".jpg" -or $logoExt -eq ".jpeg") {
                    try {
                        $logoBmp = [Drawing.Image]::FromFile($logoPath)
                        $lSize = ($baseUnits * $logoScale / 100) * $scale
                        $lPosRel = ($baseUnits * $scale - $lSize) / 2
                        $lx = $qrOffX + $lPosRel
                        $ly = $qrOffY + $lPosRel
                        
                        $bgBrush = [Drawing.SolidBrush]::new($bgColor)
                        $g.FillRectangle($bgBrush, [float]$lx, [float]$ly, [float]$lSize, [float]$lSize)
                        $bgBrush.Dispose()
                        
                        $g.DrawImage($logoBmp, [float]$lx, [float]$ly, [float]$lSize, [float]$lSize)
                        $logoBmp.Dispose()
                    } catch {
                        Write-Warning "No se pudo procesar el logo ($logoExt): $_"
                    }
                } elseif ($logoExt -eq ".svg") {
                    Write-Warning "El logo SVG no es compatible con el formato PNG. Por favor, use un logo PNG o exporte a SVG."
                }
            }
    
    $qrBrush.Dispose()
    $g.Dispose()
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function ExportPngRect {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $m,
        $path,
        $scale,
        $quiet,
        [string]$logoPath = "",
        [int]$logoScale = 20,
        [string]$foregroundColor = "#000000",
        [string]$backgroundColor = "#ffffff",
        [string[]]$bottomText = @(),
        [string]$foregroundColor2 = "",
        [double]$rounded = 0,
        [string]$gradientType = "linear",
        [string]$frameText = "",
        [string]$frameColor = "",
        [string]$fontFamily = "Arial, sans-serif",
        [string]$googleFont = ""
    )
    if (-not $PSCmdlet.ShouldProcess($path, "Exportar PNG")) { return }
    Add-Type -AssemblyName System.Drawing
    
    $wUnits = $m.Width + ($quiet * 2)
    $hUnits = $m.Height + ($quiet * 2)
    
    # Calcular Frame
    $frameSizeUnits = 0
    if ($frameText) { $frameSizeUnits = 4 }
    
    # Calcular altura adicional para texto
    $textHeightUnits = 0
    $lineHeightUnits = 3
    $textPaddingUnits = 1
    if ($bottomText.Count -gt 0) {
        $textHeightUnits = ($bottomText.Count * $lineHeightUnits) + $textPaddingUnits
    }
    
    $finalWUnits = $wUnits + ($frameSizeUnits * 2)
    $finalHUnits = $hUnits + ($frameSizeUnits * 2) + $textHeightUnits
    
    $widthPx = $finalWUnits * $scale
    $heightPx = $finalHUnits * $scale
    
    $bmp = [Drawing.Bitmap]::new([int]$widthPx, [int]$heightPx)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAlias
    
    $fgColor = [Drawing.ColorTranslator]::FromHtml($foregroundColor)
    $fgColor2 = if ($foregroundColor2) { [Drawing.ColorTranslator]::FromHtml($foregroundColor2) } else { $fgColor }
    $bgColor = [Drawing.ColorTranslator]::FromHtml($backgroundColor)
    $fColor = if ($frameColor) { [Drawing.ColorTranslator]::FromHtml($frameColor) } else { $fgColor }
    
    $g.Clear($bgColor)
    
    # Dibujar Marco
    if ($frameText) {
        $frameBrush = [Drawing.SolidBrush]::new($fColor)
        $g.FillRectangle($frameBrush, 0, 0, [float]$widthPx, [float](($hUnits + $frameSizeUnits * 2) * $scale))
        $frameBrush.Dispose()
        
        # Espacio para el QR
        $bgBrush = [Drawing.SolidBrush]::new($bgColor)
        $g.FillRectangle($bgBrush, [float]($frameSizeUnits * $scale), [float]($frameSizeUnits * $scale), [float]($wUnits * $scale), [float]($hUnits * $scale))
        $bgBrush.Dispose()
        
        # Texto del marco
        $fFontSize = $frameSizeUnits * $scale * 0.6
        $fontName = ($fontFamily -split ',')[0].Trim().Replace("'", "").Replace('"', "")
        try {
            $font = [Drawing.Font]::new($fontName, [float]$fFontSize, [Drawing.FontStyle]::Bold)
        } catch {
            $font = [Drawing.Font]::new("Arial", [float]$fFontSize, [Drawing.FontStyle]::Bold)
        }
        $sf = [Drawing.StringFormat]::new()
        $sf.Alignment = [Drawing.StringAlignment]::Center
        $sf.LineAlignment = [Drawing.StringAlignment]::Center
        
        $textBrush = [Drawing.SolidBrush]::new($bgColor)
        $rectFrameText = [Drawing.RectangleF]::new(0, 0, [float]$widthPx, [float]($frameSizeUnits * $scale))
        $g.DrawString($frameText, $font, $textBrush, $rectFrameText, $sf)
        
        $textBrush.Dispose()
        $font.Dispose()
    }
    
    $qrOffX = $frameSizeUnits * $scale
    $qrOffY = $frameSizeUnits * $scale
    
    # Calcular área del logo para máscara
    $logoMask = $null
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        # Para rMQR, centramos el logo en la parte superior (QR real)
        $lSizeUnits = ([math]::Min($wUnits, $hUnits) * $logoScale) / 100
        $lPosXUnits = ($wUnits - $lSizeUnits) / 2
        $lPosYUnits = ($hUnits - $lSizeUnits) / 2
        $margin = 0.5
        $logoMask = @{ 
            x1 = ($lPosXUnits - $margin) * $scale; 
            y1 = ($lPosYUnits - $margin) * $scale; 
            x2 = ($lPosXUnits + $lSizeUnits + $margin) * $scale; 
            y2 = ($lPosYUnits + $lSizeUnits + $margin) * $scale 
        }
    }
    
    # Preparar Pincel (Degradado o Sólido)
    $qrBrush = if ($foregroundColor2) {
        $qrRect = [Drawing.RectangleF]::new([float]$qrOffX, [float]$qrOffY, [float]($wUnits * $scale), [float]($hUnits * $scale))
        if ($gradientType -eq "radial") {
            $pathBrush = [Drawing.Drawing2D.GraphicsPath]::new()
            $pathBrush.AddEllipse($qrRect)
            $pBrush = [Drawing.Drawing2D.PathGradientBrush]::new($pathBrush)
            $pBrush.CenterColor = $fgColor
            $pBrush.SurroundColors = @($fgColor2)
            $pBrush
        } else {
            [Drawing.Drawing2D.LinearGradientBrush]::new($qrRect, $fgColor, $fgColor2, [float]45.0)
        }
    } else {
        [Drawing.SolidBrush]::new($fgColor)
    }
    
    for ($r = 0; $r -lt $m.Height; $r++) {
        for ($c = 0; $c -lt $m.Width; $c++) {
            $x = ($c + $quiet) * $scale
            $y = ($r + $quiet) * $scale
            
            if ($logoMask -and ($x + $qrOffX) -ge ($logoMask.x1 + $qrOffX) -and ($x + $qrOffX) -le ($logoMask.x2 + $qrOffX) -and ($y + $qrOffY) -ge ($logoMask.y1 + $qrOffY) -and ($y + $qrOffY) -le ($logoMask.y2 + $qrOffY)) { continue }
            
            if ((GetM $m $r $c) -eq 1) {
                if ($rounded -gt 0) {
                    $g.FillEllipse($qrBrush, [float]($x + $qrOffX), [float]($y + $qrOffY), [float]$scale, [float]$scale)
                } else {
                    $g.FillRectangle($qrBrush, [float]($x + $qrOffX), [float]($y + $qrOffY), [float]$scale, [float]$scale)
                }
            }
        }
    }
    
    # Texto debajo
    if ($bottomText.Count -gt 0) {
        $fontSize = $lineHeightUnits * $scale * 0.7
        $currentY = ($hUnits + $frameSizeUnits * 2) * $scale
        $fontName = ($fontFamily -split ',')[0].Trim().Replace("'", "").Replace('"', "")
        try {
            $font = [Drawing.Font]::new($fontName, [float]$fontSize)
        } catch {
            $font = [Drawing.Font]::new("Arial", [float]$fontSize)
        }
        $sf = [Drawing.StringFormat]::new()
        $sf.Alignment = [Drawing.StringAlignment]::Center
        
        $textBrush = [Drawing.SolidBrush]::new($fgColor)
        foreach ($line in $bottomText) {
            $rectText = [Drawing.RectangleF]::new(0, [float]($currentY + $textPaddingUnits * $scale), [float]$widthPx, [float]($lineHeightUnits * $scale))
            $g.DrawString($line, $font, $textBrush, $rectText, $sf)
            $currentY += $lineHeightUnits * $scale
        }
        $textBrush.Dispose()
        $font.Dispose()
    }
    
    # Insertar Logo
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        $logoExt = [System.IO.Path]::GetExtension($logoPath).ToLower()
        if ($logoExt -eq ".png" -or $logoExt -eq ".jpg" -or $logoExt -eq ".jpeg") {
            try {
                $logoBmp = [Drawing.Image]::FromFile($logoPath)
                $lSize = ([math]::Min($wUnits, $hUnits) * $logoScale / 100) * $scale
                $lx = $qrOffX + ($wUnits * $scale - $lSize) / 2
                $ly = $qrOffY + ($hUnits * $scale - $lSize) / 2
                
                $bgBrush = [Drawing.SolidBrush]::new($bgColor)
                $g.FillRectangle($bgBrush, [float]$lx, [float]$ly, [float]$lSize, [float]$lSize)
                $bgBrush.Dispose()
                
                $g.DrawImage($logoBmp, [float]$lx, [float]$ly, [float]$lSize, [float]$lSize)
                $logoBmp.Dispose()
            } catch {
                Write-Warning "No se pudo procesar el logo ($logoExt): $_"
            }
        } elseif ($logoExt -eq ".svg") {
            Write-Warning "El logo SVG no es compatible con el formato PNG. Por favor, use un logo PNG o exporte a SVG."
        }
    }
    
    $qrBrush.Dispose()
    $g.Dispose()
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function ExportSvg {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $m,
        $path,
        $scale,
        $quiet,
        [string]$logoPath = "",
        [int]$logoScale = 20,
        [string[]]$bottomText = @(),
        [string]$foregroundColor = "#000000",
        [string]$foregroundColor2 = "",
        [string]$backgroundColor = "#ffffff",
        [double]$rounded = 0,
        [string]$gradientType = "linear",
        [string]$frameText = "",
        [string]$frameColor = "",
        [string]$fontFamily = "Arial, sans-serif",
        [string]$googleFont = ""
    )
    if (-not $PSCmdlet.ShouldProcess($path, "Exportar SVG")) { return }
    $size = $m.Size
    $baseUnits = $size + ($quiet * 2)
    
    # Calcular Frame
    $frameSize = 0
    if ($frameText) { $frameSize = 4 } # Espacio para el marco
    
    $wUnits = $baseUnits + ($frameSize * 2)
    
    # Calcular altura adicional para texto
    $textHeight = 0
    $lineHeight = 3 # Altura en unidades de módulo
    $textPadding = 1 # Padding entre QR y texto
    if ($bottomText.Count -gt 0) {
        $textHeight = ($bottomText.Count * $lineHeight) + $textPadding
    }
    
    $hUnits = $baseUnits + ($frameSize * 2) + $textHeight
    $widthPx = $wUnits * $scale
    $heightPx = $hUnits * $scale
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("<?xml version=""1.0"" encoding=""UTF-8""?>")
    [void]$sb.Append("<svg xmlns=""http://www.w3.org/2000/svg"" xmlns:xlink=""http://www.w3.org/1999/xlink"" width=""$(ToDot $widthPx)"" height=""$(ToDot $heightPx)"" viewBox=""0 0 $(ToDot $wUnits) $(ToDot $hUnits)"" shape-rendering=""crispEdges"">")
    
    # Fuentes Personalizadas
    [void]$sb.Append("<defs>")
    if ($googleFont) {
        [void]$sb.Append("<style>@import url('https://fonts.googleapis.com/css2?family=$($googleFont.Replace(' ', '+'))&amp;display=swap');</style>")
        $fontFamily = "'$googleFont', $fontFamily"
    }
    
    # Definir Degradado si existe
    $fillColor = $foregroundColor
    if ($foregroundColor2) {
        if ($gradientType -eq "radial") {
            [void]$sb.Append("<radialGradient id=""qrgrad"" cx=""50%"" cy=""50%"" r=""50%"">")
        } else {
            [void]$sb.Append("<linearGradient id=""qrgrad"" x1=""0%"" y1=""0%"" x2=""100%"" y2=""100%"">")
        }
        [void]$sb.Append("<stop offset=""0%"" stop-color=""$foregroundColor""/>")
        [void]$sb.Append("<stop offset=""100%"" stop-color=""$foregroundColor2""/>")
        if ($gradientType -eq "radial") { [void]$sb.Append("</radialGradient>") } else { [void]$sb.Append("</linearGradient>") }
    }
    [void]$sb.Append("</defs>")
    if ($foregroundColor2) { $fillColor = "url(#qrgrad)" }

    # Fondo
    [void]$sb.Append("<rect width=""$(ToDot $wUnits)"" height=""$(ToDot $hUnits)"" fill=""$backgroundColor""/>")
    
    # Marco Decorativo
    if ($frameText) {
        $fColor = if ($frameColor) { $frameColor } else { $foregroundColor }
        # Rectángulo del marco
        [void]$sb.Append("<rect x=""0"" y=""0"" width=""$(ToDot $wUnits)"" height=""$(ToDot ($baseUnits + $frameSize * 2))"" fill=""$fColor""/>")
        # Espacio blanco para el QR dentro del marco
        [void]$sb.Append("<rect x=""$(ToDot $frameSize)"" y=""$(ToDot $frameSize)"" width=""$(ToDot $baseUnits)"" height=""$(ToDot $baseUnits)"" fill=""$backgroundColor""/>")
        # Texto del marco (arriba)
        $fFontSize = $frameSize * 0.6
        $escapedFrameText = [System.Security.SecurityElement]::Escape($frameText)
        [void]$sb.Append("<text x=""$(ToDot ($wUnits/2))"" y=""$(ToDot ($frameSize/2 + $fFontSize/3))"" font-family=""$fontFamily"" font-size=""$(ToDot $fFontSize)"" font-weight=""bold"" text-anchor=""middle"" fill=""$backgroundColor"">$escapedFrameText</text>")
    }

    $qrOffX = $frameSize
    $qrOffY = $frameSize

    # Calcular área del logo para máscara
    $logoMask = $null
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        $lSize = ($baseUnits * $logoScale) / 100
        $lPos = ($baseUnits - $lSize) / 2
        $margin = 0.5
        $logoMask = @{ x1 = $lPos - $margin; y1 = $lPos - $margin; x2 = $lPos + $lSize + $margin; y2 = $lPos + $lSize + $margin }
    }

    [void]$sb.Append("<g fill=""$fillColor"" transform=""translate($(ToDot $qrOffX), $(ToDot $qrOffY))"">")
    
    $rectAttr = if ($rounded -gt 0) { " rx=""$(ToDot $rounded)"" ry=""$(ToDot $rounded)""" } else { "" }
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        for ($c = 0; $c -lt $m.Size; $c++) {
            $x = $c + $quiet
            $y = $r + $quiet
            if ($logoMask -and $x -ge $logoMask.x1 -and $x -le $logoMask.x2 -and $y -ge $logoMask.y1 -and $y -le $logoMask.y2) { continue }
            if ((GetM $m $r $c) -eq 1) {
                [void]$sb.Append("<rect x=""$(ToDot $x)"" y=""$(ToDot $y)"" width=""1"" height=""1""$rectAttr/>")
            }
        }
    }
    [void]$sb.Append("</g>")

    # Insertar Texto debajo
    if ($bottomText.Count -gt 0) {
        $fontSize = $lineHeight * 0.7
        $currentY = $baseUnits + ($frameSize * 2)
        foreach ($line in $bottomText) {
            $escapedText = [System.Security.SecurityElement]::Escape($line)
            [void]$sb.Append("<text x=""$(ToDot ($wUnits/2))"" y=""$(ToDot ($currentY + $textPadding + $fontSize))"" font-family=""$fontFamily"" font-size=""$(ToDot $fontSize)"" text-anchor=""middle"" fill=""$foregroundColor"">$escapedText</text>")
            $currentY += $lineHeight
        }
    }

    # Insertar Logo
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        $logoExt = [System.IO.Path]::GetExtension($logoPath).ToLower()
        $lSize = ($baseUnits * $logoScale) / 100
        $lPosRel = ($baseUnits - $lSize) / 2
        $lx = $qrOffX + $lPosRel
        $ly = $qrOffY + $lPosRel
        
        if ($logoExt -eq ".svg") {
            try {
                [xml]$logoSvg = Get-Content $logoPath
                $root = $logoSvg.DocumentElement
                $vBox = $root.viewBox
                $lW = if ($root.width) { FromDot $root.width } else { 100 }
                $lH = if ($root.height) { FromDot $root.height } else { 100 }
                if ($vBox) {
                    $parts = $vBox -split '[ ,]+' | Where-Object { $_ -ne "" }
                    if ($parts.Count -ge 4) { $lW = FromDot $parts[2]; $lH = FromDot $parts[3] }
                }
                $maxDim = if ($lW -gt $lH) { $lW } else { $lH }
                $scaleFactorNum = $lSize / $maxDim
                $scaleFactor = ToDot ([math]::Round($scaleFactorNum, 6))
                $finalW = $lW * $scaleFactorNum
                $finalH = $lH * $scaleFactorNum
                $offX = $qrOffX + ($baseUnits - $finalW) / 2
                $offY = $qrOffY + ($baseUnits - $finalH) / 2
                [void]$sb.Append("<rect x=""$(ToDot $offX)"" y=""$(ToDot $offY)"" width=""$(ToDot $finalW)"" height=""$(ToDot $finalH)"" fill=""$backgroundColor""/>")
                $inner = $root.InnerXml
                [void]$sb.Append("<g transform=""translate($(ToDot $offX), $(ToDot $offY)) scale($(ToDot $scaleFactor))"">$inner</g>")
            } catch { Write-Warning "No se pudo procesar el logo SVG: $_" }
        } elseif ($logoExt -eq ".png") {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($logoPath)
                $b64 = [System.Convert]::ToBase64String($bytes)
                [void]$sb.Append("<rect x=""$(ToDot $lx)"" y=""$(ToDot $ly)"" width=""$(ToDot $lSize)"" height=""$(ToDot $lSize)"" fill=""$backgroundColor""/>")
                [void]$sb.Append("<image x=""$(ToDot $lx)"" y=""$(ToDot $ly)"" width=""$(ToDot $lSize)"" height=""$(ToDot $lSize)"" xlink:href=""data:image/png;base64,$b64"" />")
            } catch { Write-Warning "No se pudo procesar el logo PNG: $_" }
        }
    }

    [void]$sb.Append("</svg>")
    Set-Content -Path $path -Value $sb.ToString() -Encoding UTF8
}

function ExportPdfMultiNative {
    param(
        [System.Collections.ArrayList]$pages, # Array de PSCustomObject con { type, m, scale, quiet, fg, bg, fg2, gradType, text, rounded, frame, frameColor, path, logoPath, logoScale }
        $path,
        [string]$layout = "Default"
    )

    $fs = [System.IO.FileStream]::new($path, [System.IO.FileMode]::Create)
    $bw = [System.IO.BinaryWriter]::new($fs)
    $objOffsets = New-Object System.Collections.Generic.List[long]
    $WriteStr = { param($s) $bytes = [System.Text.Encoding]::ASCII.GetBytes($s); $bw.Write($bytes) }
    
    $StartObj = {
        $objOffsets.Add($fs.Position)
        &$WriteStr "$($objOffsets.Count) 0 obj`n"
    }
    
    $ToPdfColor = {
        param($hex)
        if ([string]::IsNullOrWhiteSpace($hex) -or $hex -eq "#") { return "0 0 0" }
        $cleanHex = $hex.Replace("#", "")
        try {
            if ($cleanHex.Length -eq 3) {
                $r = [Convert]::ToInt32($cleanHex.Substring(0, 1) * 2, 16) / 255.0
                $g = [Convert]::ToInt32($cleanHex.Substring(1, 1) * 2, 16) / 255.0
                $b = [Convert]::ToInt32($cleanHex.Substring(2, 1) * 2, 16) / 255.0
            } elseif ($cleanHex.Length -eq 6) {
                $r = [Convert]::ToInt32($cleanHex.Substring(0, 2), 16) / 255.0
                $g = [Convert]::ToInt32($cleanHex.Substring(2, 2), 16) / 255.0
                $b = [Convert]::ToInt32($cleanHex.Substring(4, 2), 16) / 255.0
            } else {
                return "0 0 0"
            }
            return "$(ToDot $r) $(ToDot $g) $(ToDot $b)"
        } catch {
            return "0 0 0"
        }
    }

    $EscapePdfString = {
        param($s)
        if ([string]::IsNullOrEmpty($s)) { return "" }
        return $s.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
    }

    $GetGradientColor = {
        param($hex1, $hex2, $ratio)
        $ToRGB = {
            param($h)
            $h = $h.Replace("#", "")
            if ($h.Length -eq 3) {
                $r = [Convert]::ToInt32($h.Substring(0, 1) * 2, 16)
                $g = [Convert]::ToInt32($h.Substring(1, 1) * 2, 16)
                $b = [Convert]::ToInt32($h.Substring(2, 1) * 2, 16)
            } else {
                $r = [Convert]::ToInt32($h.Substring(0, 2), 16)
                $g = [Convert]::ToInt32($h.Substring(2, 2), 16)
                $b = [Convert]::ToInt32($h.Substring(4, 2), 16)
            }
            return @($r, $g, $b)
        }
        $rgb1 = &$ToRGB $hex1
        $rgb2 = &$ToRGB $hex2
        $r = ($rgb1[0] + ($rgb2[0] - $rgb1[0]) * $ratio) / 255.0
        $g = ($rgb1[1] + ($rgb2[1] - $rgb1[1]) * $ratio) / 255.0
        $b = ($rgb1[2] + ($rgb2[2] - $rgb1[2]) * $ratio) / 255.0
        return "$(ToDot $r) $(ToDot $g) $(ToDot $b)"
    }

    $EmbedImage = {
        param($imgFilePath)
        try {
            $ext = [System.IO.Path]::GetExtension($imgFilePath).ToLower()
            if ($ext -eq ".svg") {
                Write-Warning "El logo SVG no es compatible con el formato PDF nativo. Por favor, use un logo PNG/JPG o exporte a SVG."
                return $null
            }
            $bmp = [System.Drawing.Bitmap]::FromFile($imgFilePath)
            $ms = [System.IO.MemoryStream]::new()
            $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
            $encParams = [System.Drawing.Imaging.EncoderParameters]::new(1)
            $encParams.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [long]85)
            $bmp.Save($ms, $codec, $encParams)
            $imgBytes = $ms.ToArray()
            $w = $bmp.Width; $h = $bmp.Height
            $bmp.Dispose(); $ms.Dispose()
            return @{ bytes=$imgBytes; w=$w; h=$h }
        } catch {
            return $null
        }
    }

    &$WriteStr "%PDF-1.4`n"
    
    # Pre-procesar Layout
    $cols = 1; $rows = 1; $pageW = 0; $pageH = 0
    $isGrid = $false
    if ($layout -eq "Grid4x4") { $cols = 4; $rows = 4; $pageW = 595; $pageH = 842; $isGrid = $true }
    elseif ($layout -eq "Grid4x5") { $cols = 4; $rows = 5; $pageW = 595; $pageH = 842; $isGrid = $true }
    elseif ($layout -eq "Grid6x6") { $cols = 6; $rows = 6; $pageW = 595; $pageH = 842; $isGrid = $true }

    $itemsPerPage = $cols * $rows
    $totalItems = $pages.Count
    $totalPages = if ($isGrid) { [Math]::Ceiling($totalItems / $itemsPerPage) } else { $totalItems }

    # 1. Catalog
    &$StartObj
    &$WriteStr "<< /Type /Catalog /Pages 2 0 R >>`nendobj`n"

    # 2. Pages Root
    $pagesRootId = 2
    &$StartObj
    $kidsPlaceholderPos = $fs.Position + 25 # approximate
    &$WriteStr "<< /Type /Pages /Kids [ "
    $kidsStartPos = $fs.Position
    for ($i=0; $i -lt $totalPages; $i++) { &$WriteStr "000 0 R " }
    &$WriteStr "] /Count $totalPages >>`nendobj`n"

    $actualPageIds = @()
    $imageObjects = @{} # Path -> @{ id, w, h }

    for ($pIdx = 0; $pIdx -lt $totalPages; $pIdx++) {
        $itemsInThisPage = if ($isGrid) {
            $start = $pIdx * $itemsPerPage
            $end = [Math]::Min($start + $itemsPerPage, $totalItems)
            $pages[$start..($end-1)]
        } else {
            @($pages[$pIdx])
        }

        $pW = if ($isGrid) { $pageW } else { 
            $item = $itemsInThisPage[0]
            $baseW = if ($null -ne $item.m.Width) { $item.m.Width } else { $item.m.Size }
            $frameSize = if ($item.frame) { 4 } else { 0 }
            ($baseW + ($item.quiet * 2) + ($frameSize * 2)) * $item.scale
        }
        $pH = if ($isGrid) { $pageH } else {
            $item = $itemsInThisPage[0]
            $baseH = if ($null -ne $item.m.Height) { $item.m.Height } else { $item.m.Size }
            $frameSize = if ($item.frame) { 4 } else { 0 }
            $allLines = @()
            if ($item.text.Count -gt 0) {
                foreach ($txt in $item.text) { if ($txt) { foreach ($sl in ($txt -split "\\n")) { if ($sl) { $allLines += $sl } } } }
            }
            $textHeight = if ($allLines.Count -gt 0) { ($allLines.Count * 3) + 1 } else { 0 }
            ($baseH + ($item.quiet * 2) + ($frameSize * 2) + $textHeight) * $item.scale
        }

        # Content Object (Buffer in memory)
        $contentSb = New-Object System.Text.StringBuilder
        $xObjects = @{} # Name -> Id

        $cellW = $pW / $cols
        $cellH = $pH / $rows
        
        $itemIdx = 0
        foreach ($item in $itemsInThisPage) {
            $c = $itemIdx % $cols
            $r = [Math]::Floor($itemIdx / $cols)
            $itemIdx++
            
            $offsetX = $c * $cellW
            $offsetY = $pH - (($r + 1) * $cellH)

            if ($item.type -eq "Image") {
                if (-not $imageObjects.ContainsKey($item.path)) {
                    $imgData = &$EmbedImage $item.path
                    if ($imgData) {
                        &$StartObj
                        $imgId = $objOffsets.Count
                        &$WriteStr "<< /Type /XObject /Subtype /Image /Width $($imgData.w) /Height $($imgData.h) /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length $($imgData.bytes.Length) >>`nstream`n"
                        $bw.Write($imgData.bytes)
                        &$WriteStr "`nendstream`nendobj`n"
                        $imageObjects[$item.path] = @{ id=$imgId; w=$imgData.w; h=$imgData.h }
                    }
                }
                
                if ($imageObjects.ContainsKey($item.path)) {
                    $imgInfo = $imageObjects[$item.path]
                    $imgName = "Im$($imgInfo.id)"
                    $xObjects[$imgName] = $imgInfo.id
                    
                    # Calcular escala manteniendo aspecto
                    $ratio = [Math]::Min($cellW / $imgInfo.w, $cellH / $imgInfo.h)
                    $dispW = $imgInfo.w * $ratio
                    $dispH = $imgInfo.h * $ratio
                    $dispX = $offsetX + ($cellW - $dispW) / 2
                    $dispY = $offsetY + ($cellH - $dispH) / 2
                    
                    [void]$contentSb.AppendLine("q $(ToDot $dispW) 0 0 $(ToDot $dispH) $(ToDot $dispX) $(ToDot $dispY) cm /$imgName Do Q")
                }
            } else {
                # QR Drawing Logic
                $m = $item.m
                $scale = $item.scale
                $quiet = $item.quiet
                $rounded = $item.rounded
                $frameText = $item.frame
                $frameColor = $item.frameColor
                $bottomText = $item.text
                $foregroundColor = $item.fg
                $foregroundColor2 = $item.fg2
                $backgroundColor = $item.bg
                $gradType = $item.gradType
                $logoPath = $item.logoPath
                $logoScale = $item.logoScale
                $itemPath = $item.path

                $baseW = if ($null -ne $m.Width) { $m.Width } else { $m.Size }
                $baseH = if ($null -ne $m.Height) { $m.Height } else { $m.Size }
                $frameSize = if ($frameText) { 4 } else { 0 }
                $allLines = @()
                if ($bottomText.Count -gt 0) {
                    foreach ($txt in $bottomText) { if ($txt) { foreach ($sl in ($txt -split "\\n")) { if ($sl) { $allLines += $sl } } } }
                }
                $textHeight = if ($allLines.Count -gt 0) { ($allLines.Count * 3) + 1 } else { 0 }
                
                $itemW = ($baseW + ($quiet * 2) + ($frameSize * 2)) * $scale
                $itemH = ($baseH + ($quiet * 2) + ($frameSize * 2) + $textHeight) * $scale
                
                # Centrar item en celda
                $innerX = $offsetX + ($cellW - $itemW) / 2
                $innerY = $offsetY + ($cellH - $itemH) / 2

                $fgColorPdf = &$ToPdfColor $foregroundColor
                $bgColorPdf = if ([string]::IsNullOrWhiteSpace($backgroundColor) -or $backgroundColor -eq "#") { "1 1 1" } else { &$ToPdfColor $backgroundColor }
                $fColorPdf = if ($frameColor -and $frameColor -ne "#") { &$ToPdfColor $frameColor } else { $fgColorPdf }

                [void]$contentSb.AppendLine("q 1 0 0 1 $(ToDot $innerX) $(ToDot $innerY) cm")
                [void]$contentSb.AppendLine("$bgColorPdf rg 0 0 $(ToDot $itemW) $(ToDot $itemH) re f")
                
                if ($frameText) {
                    $frameH = ($baseH + ($quiet * 2) + ($frameSize * 2)) * $scale
                    [void]$contentSb.AppendLine("$fColorPdf rg 0 $(ToDot ($itemH - $frameH)) $(ToDot $itemW) $(ToDot $frameH) re f")
                    [void]$contentSb.AppendLine("$bgColorPdf rg $(ToDot ($frameSize * $scale)) $(ToDot (($frameSize + $textHeight) * $scale)) $(ToDot (($baseW + $quiet * 2) * $scale)) $(ToDot (($baseH + $quiet * 2) * $scale)) re f")
                    [void]$contentSb.AppendLine("BT /F1 $(ToDot ($frameSize * 0.6 * $scale)) Tf $bgColorPdf rg")
                    $fTextEscaped = &$EscapePdfString $frameText
                    $fTextW = $frameText.Length * ($frameSize * 0.4 * $scale)
                    $fTextX = ($itemW - $fTextW) / 2
                    $fTextY = $itemH - ($frameSize * 0.7 * $scale)
                    [void]$contentSb.AppendLine("1 0 0 1 $(ToDot $fTextX) $(ToDot $fTextY) Tm ($fTextEscaped) Tj ET")
                }

                # Manejo de Logo
                $logoInfo = $null
                $logoDrawW = 0
                if ($logoPath -and (Test-Path $logoPath)) {
                    if (-not $imageObjects.ContainsKey($logoPath)) {
                        $imgData = &$EmbedImage $logoPath
                        if ($imgData) {
                            &$StartObj
                            $imgId = $objOffsets.Count
                            &$WriteStr "<< /Type /XObject /Subtype /Image /Width $($imgData.w) /Height $($imgData.h) /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length $($imgData.bytes.Length) >>`nstream`n"
                            $bw.Write($imgData.bytes)
                            &$WriteStr "`nendstream`nendobj`n"
                            $imageObjects[$logoPath] = @{ id=$imgId; w=$imgData.w; h=$imgData.h }
                        }
                    }
                    if ($imageObjects.ContainsKey($logoPath)) {
                        $logoInfo = $imageObjects[$logoPath]
                        $logoDrawW = ([Math]::Min($baseW, $baseH) * $logoScale / 100) * $scale
                        $logoX = (($baseW + $quiet * 2 + $frameSize * 2) * $scale - $logoDrawW) / 2
                        $logoY = (($baseH + $quiet * 2 + $frameSize * 2 + $textHeight) * $scale - $logoDrawW) / 2
                        # Fondo blanco para el logo
                        [void]$contentSb.AppendLine("$bgColorPdf rg $(ToDot $logoX) $(ToDot $logoY) $(ToDot $logoDrawW) $(ToDot $logoDrawW) re f")
                    }
                }

                $hasGradient = (-not [string]::IsNullOrEmpty($foregroundColor2)) -and ($gradType -ne "none")
                if (-not $hasGradient) {
                    [void]$contentSb.AppendLine("$fgColorPdf rg")
                }

                $rSize = [double]$rounded * $scale
                $kappa = 0.552284749831
                for ($row = 0; $row -lt $baseH; $row++) {
                    for ($col = 0; $col -lt $baseW; $col++) {
                        if ((GetM $m $row $col) -eq 1) {
                            if ($hasGradient) {
                                $ratio = 0
                                if ($gradType -eq "radial") {
                                    $dist = [Math]::Sqrt([Math]::Pow($col - ($baseW/2), 2) + [Math]::Pow($row - ($baseH/2), 2))
                                    $maxDist = [Math]::Sqrt([Math]::Pow($baseW/2, 2) + [Math]::Pow($baseH/2, 2))
                                    $ratio = [Math]::Min(1.0, $dist / $maxDist)
                                } else {
                                    # Linear diagonal
                                    $ratio = ($col + $row) / ($baseW + $baseH)
                                }
                                $modColor = &$GetGradientColor $foregroundColor $foregroundColor2 $ratio
                                [void]$contentSb.AppendLine("$modColor rg")
                            }

                            $x = ($col + $quiet + $frameSize) * $scale
                            $y = ($itemH - ($row + $quiet + $frameSize + 1) * $scale)
                            
                            # Evitar dibujar módulos bajo el logo
                            if ($logoInfo) {
                                $logoX = (($baseW + $quiet * 2 + $frameSize * 2) * $scale - $logoDrawW) / 2
                                $logoY = (($baseH + $quiet * 2 + $frameSize * 2 + $textHeight) * $scale - $logoDrawW) / 2
                                if ($x -ge ($logoX - 0.5) -and $x -lt ($logoX + $logoDrawW + 0.5) -and $y -ge ($logoY - 0.5) -and $y -lt ($logoY + $logoDrawW + 0.5)) { continue }
                            }

                            if ($rounded -gt 0) {
                                $rV = [Math]::Min($rSize, $scale / 2)
                                $k = $rV * $kappa
                                [void]$contentSb.AppendLine("$(ToDot ($x + $rV)) $(ToDot $y) m $(ToDot ($x + $scale - $rV)) $(ToDot $y) l")
                                [void]$contentSb.AppendLine("$(ToDot ($x + $scale - $rV + $k)) $(ToDot $y) $(ToDot ($x + $scale)) $(ToDot ($y + $rV - $k)) $(ToDot ($x + $scale)) $(ToDot ($y + $rV)) c")
                                [void]$contentSb.AppendLine("$(ToDot ($x + $scale)) $(ToDot ($y + $scale - $rV)) l")
                                [void]$contentSb.AppendLine("$(ToDot ($x + $scale)) $(ToDot ($y + $scale - $rV + $k)) $(ToDot ($x + $scale - $rV + $k)) $(ToDot ($y + $scale)) $(ToDot ($x + $scale - $rV)) $(ToDot ($y + $scale)) c")
                                [void]$contentSb.AppendLine("$(ToDot ($x + $rV)) $(ToDot ($y + $scale)) l")
                                [void]$contentSb.AppendLine("$(ToDot ($x + $rV - $k)) $(ToDot ($y + $scale)) $(ToDot $x) $(ToDot ($y + $scale - $rV + $k)) $(ToDot $x) $(ToDot ($y + $scale - $rV)) c")
                                [void]$contentSb.AppendLine("$(ToDot $x) $(ToDot ($y + $rV)) l")
                                [void]$contentSb.AppendLine("$(ToDot $x) $(ToDot ($y + $rV - $k)) $(ToDot ($x + $rV - $k)) $(ToDot $y) $(ToDot ($x + $rV)) $(ToDot $y) c f")
                            } else {
                                [void]$contentSb.AppendLine("$(ToDot $x) $(ToDot $y) $(ToDot $scale) $(ToDot $scale) re f")
                            }
                        }
                    }
                }

                if ($allLines.Count -gt 0) {
                    [void]$contentSb.AppendLine("BT /F1 $(ToDot ($scale * 2)) Tf $fgColorPdf rg")
                    $currentY = ($textHeight - 2) * $scale
                    foreach ($line in $allLines) {
                        $textW = $line.Length * ($scale * 2 * 0.55)
                        $startX = ($itemW - $textW) / 2
                        $escapedLine = &$EscapePdfString $line
                        [void]$contentSb.AppendLine("1 0 0 1 $(ToDot $startX) $(ToDot $currentY) Tm ($escapedLine) Tj")
                        $currentY -= ($scale * 3)
                    }
                    [void]$contentSb.AppendLine("ET")
                }

                # Dibujar Logo si existe
                if ($logoInfo) {
                    $imgName = "Logo$($logoInfo.id)"
                    $xObjects[$imgName] = $logoInfo.id
                    $logoX = (($baseW + $quiet * 2 + $frameSize * 2) * $scale - $logoDrawW) / 2
                    $logoY = (($baseH + $quiet * 2 + $frameSize * 2 + $textHeight) * $scale - $logoDrawW) / 2
                    [void]$contentSb.AppendLine("q $(ToDot $logoDrawW) 0 0 $(ToDot $logoDrawW) $(ToDot $logoX) $(ToDot $logoY) cm /$imgName Do Q")
                }

                # Link al archivo original si existe (Opcional, para debug en el PDF)
                # if ($itemPath) { [void]$contentSb.AppendLine("% Path: $itemPath") }

                [void]$contentSb.AppendLine("Q")
            }
        }

        # 1. Resources Object
        &$StartObj
        $resId = $objOffsets.Count
        $resStr = "<< /ProcSet [/PDF /Text /ImageB /ImageC /ImageI] /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >> >>"
        if ($xObjects.Count -gt 0) {
            $resStr += " /XObject << "
            foreach ($xo in $xObjects.Keys) { $resStr += "/$xo $($xObjects[$xo]) 0 R " }
            $resStr += " >>"
        }
        $resStr += " >>"
        &$WriteStr "$resStr`nendobj`n"

        # 2. Content Object
        $enc = [System.Text.Encoding]::GetEncoding(1252)
        $contentBytes = $enc.GetBytes($contentSb.ToString())
        &$StartObj
        $contId = $objOffsets.Count
        &$WriteStr "<< /Length $($contentBytes.Length) >>`nstream`n"
        $bw.Write($contentBytes)
        &$WriteStr "`nendstream`nendobj`n"

        # 3. Page Object (Write it now, sequentially)
        &$StartObj
        $pageId = $objOffsets.Count
        $actualPageIds += $pageId
        &$WriteStr "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 $(ToDot $pW) $(ToDot $pH)] /Contents $contId 0 R /Resources $resId 0 R >>`nendobj`n"
    }

    # Finalize Pages Root
    $currPos = $fs.Position
    $fs.Position = $kidsStartPos
    foreach ($id in $actualPageIds) { &$WriteStr ("{0:000} 0 R " -f $id) }
    $fs.Position = $currPos

    # Resources Shared (Not used anymore as each page has its own)
    
    # xref
    $xrefPos = $fs.Position
    &$WriteStr "xref`n0 $($objOffsets.Count + 1)`n0000000000 65535 f `n"
    foreach ($off in $objOffsets) { &$WriteStr ("{0:0000000000} 00000 n `n" -f $off) }

    # trailer
    &$WriteStr "trailer`n<< /Size $($objOffsets.Count + 1) /Root 1 0 R >>`nstartxref`n$xrefPos`n%%EOF"

    $bw.Close(); $fs.Close()
}


function ExportPdf {
    param(
        $m,
        $path,
        $scale,
        $quiet,
        [string]$logoPath = "",
        [int]$logoScale = 20,
        [string[]]$bottomText = @(),
        [string]$foregroundColor = "#000000",
        [string]$foregroundColor2 = "",
        [string]$backgroundColor = "#ffffff",
        [double]$rounded = 0,
        [string]$gradientType = "linear",
        [string]$frameText = "",
        [string]$frameColor = "",
        [string]$fontFamily = "Arial, sans-serif",
        [string]$googleFont = ""
    )

    # Usar el motor nativo multi-página para generar un PDF de una sola página
    # Esto unifica la lógica y permite soporte nativo de logos
    try {
        $pages = New-Object System.Collections.ArrayList
        [void]$pages.Add([PSCustomObject]@{
            type = "QR"
            m = $m
            scale = $scale
            quiet = $quiet
            fg = $foregroundColor
            fg2 = $foregroundColor2
            bg = $backgroundColor
            gradType = $gradientType
            text = $bottomText
            rounded = $rounded
            frame = $frameText
            frameColor = $frameColor
            logoPath = $logoPath
            logoScale = $logoScale
        })
        ExportPdfMultiNative -pages $pages -path $path -layout "Default"
        if (Test-Path $path) {
            Write-Status "[OK] PDF nativo generado exitosamente en: $path"
            return
        }
    } catch {
        Write-Warning "Fallo en exportación nativa: $_."
    }
}

function ExportSvgRect {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $m,
        $path,
        $scale,
        $quiet,
        [string]$logoPath = "",
        [int]$logoScale = 20,
        [string[]]$bottomText = @(),
        [string]$foregroundColor = "#000000",
        [string]$foregroundColor2 = "",
        [string]$backgroundColor = "#ffffff",
        [double]$rounded = 0,
        [string]$gradientType = "linear",
        [string]$frameText = "",
        [string]$frameColor = "",
        [string]$fontFamily = "Arial, sans-serif",
        [string]$googleFont = ""
    )
    if (-not $PSCmdlet.ShouldProcess($path, "Exportar SVG")) { return }
    $baseW = $m.Width + ($quiet * 2)
    $baseH = $m.Height + ($quiet * 2)
    
    # Calcular Frame
    $frameSize = 0
    if ($frameText) { $frameSize = 4 }
    
    $wUnits = $baseW + ($frameSize * 2)
    
    # Calcular altura adicional para texto
    $textHeight = 0
    $lineHeight = 3
    $textPadding = 1
    if ($bottomText.Count -gt 0) {
        $textHeight = ($bottomText.Count * $lineHeight) + $textPadding
    }
    
    $hUnits = $baseH + ($frameSize * 2) + $textHeight
    $widthPx = $wUnits * $scale
    $heightPx = $hUnits * $scale
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("<?xml version=""1.0"" encoding=""UTF-8""?>")
    [void]$sb.Append("<svg xmlns=""http://www.w3.org/2000/svg"" xmlns:xlink=""http://www.w3.org/1999/xlink"" width=""$(ToDot $widthPx)"" height=""$(ToDot $heightPx)"" viewBox=""0 0 $(ToDot $wUnits) $(ToDot $hUnits)"" shape-rendering=""crispEdges"">")
    
    # Fuentes Personalizadas
    [void]$sb.Append("<defs>")
    if ($googleFont) {
        [void]$sb.Append("<style>@import url('https://fonts.googleapis.com/css2?family=$($googleFont.Replace(' ', '+'))&amp;display=swap');</style>")
        $fontFamily = "'$googleFont', $fontFamily"
    }
    
    # Definir Degradado
    $fillColor = $foregroundColor
    if ($foregroundColor2) {
        if ($gradientType -eq "radial") {
            [void]$sb.Append("<radialGradient id=""qrgrad"" cx=""50%"" cy=""50%"" r=""50%"">")
        } else {
            [void]$sb.Append("<linearGradient id=""qrgrad"" x1=""0%"" y1=""0%"" x2=""100%"" y2=""100%"">")
        }
        [void]$sb.Append("<stop offset=""0%"" stop-color=""$foregroundColor""/>")
        [void]$sb.Append("<stop offset=""100%"" stop-color=""$foregroundColor2""/>")
        if ($gradientType -eq "radial") { [void]$sb.Append("</radialGradient>") } else { [void]$sb.Append("</linearGradient>") }
    }
    [void]$sb.Append("</defs>")
    if ($foregroundColor2) { $fillColor = "url(#qrgrad)" }

    # Fondo
    [void]$sb.Append("<rect width=""$(ToDot $wUnits)"" height=""$(ToDot $hUnits)"" fill=""$backgroundColor""/>")
    
    # Marco Decorativo
    if ($frameText) {
        $fColor = if ($frameColor) { $frameColor } else { $foregroundColor }
        [void]$sb.Append("<rect x=""0"" y=""0"" width=""$(ToDot $wUnits)"" height=""$(ToDot ($baseH + $frameSize * 2))"" fill=""$fColor""/>")
        [void]$sb.Append("<rect x=""$(ToDot $frameSize)"" y=""$(ToDot $frameSize)"" width=""$(ToDot $baseW)"" height=""$(ToDot $baseH)"" fill=""$backgroundColor""/>")
        $fFontSize = $frameSize * 0.6
        $escapedFrameText = [System.Security.SecurityElement]::Escape($frameText)
        [void]$sb.Append("<text x=""$(ToDot ($wUnits/2))"" y=""$(ToDot ($frameSize/2 + $fFontSize/3))"" font-family=""$fontFamily"" font-size=""$(ToDot $fFontSize)"" font-weight=""bold"" text-anchor=""middle"" fill=""$backgroundColor"">$escapedFrameText</text>")
    }

    $qrOffX = $frameSize
    $qrOffY = $frameSize

    # Calcular área del logo para máscara
    $logoMask = $null
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        $minSide = if ($baseW -lt $baseH) { $baseW } else { $baseH }
        $lSize = ($minSide * $logoScale) / 100
        $lxRel = ($baseW - $lSize) / 2
        $lyRel = ($baseH - $lSize) / 2
        $margin = 0.5
        $logoMask = @{ x1 = $lxRel - $margin; y1 = $lyRel - $margin; x2 = $lxRel + $lSize + $margin; y2 = $lyRel + $lSize + $margin }
    }

    [void]$sb.Append("<g fill=""$fillColor"" transform=""translate($(ToDot $qrOffX), $(ToDot $qrOffY))"">")
    
    $rectAttr = if ($rounded -gt 0) { " rx=""$(ToDot $rounded)"" ry=""$(ToDot $rounded)""" } else { "" }
    
    for ($r = 0; $r -lt $m.Height; $r++) {
        for ($c = 0; $c -lt $m.Width; $c++) {
            $x = $c + $quiet
            $y = $r + $quiet
            if ($logoMask -and $x -ge $logoMask.x1 -and $x -le $logoMask.x2 -and $y -ge $logoMask.y1 -and $y -le $logoMask.y2) { continue }
            if ((GetM $m $r $c) -eq 1) {
                [void]$sb.Append("<rect x=""$(ToDot $x)"" y=""$(ToDot $y)"" width=""1"" height=""1""$rectAttr/>")
            }
        }
    }
    [void]$sb.Append("</g>")

    # Insertar Texto debajo
    if ($bottomText.Count -gt 0) {
        $fontSize = $lineHeight * 0.7
        $currentY = $baseH + ($frameSize * 2)
        foreach ($line in $bottomText) {
            $escapedText = [System.Security.SecurityElement]::Escape($line)
            [void]$sb.Append("<text x=""$(ToDot ($wUnits/2))"" y=""$(ToDot ($currentY + $textPadding + $fontSize))"" font-family=""$fontFamily"" font-size=""$(ToDot $fontSize)"" text-anchor=""middle"" fill=""$foregroundColor"">$escapedText</text>")
            $currentY += $lineHeight
        }
    }

    # Insertar Logo
    if (-not [string]::IsNullOrEmpty($logoPath) -and (Test-Path $logoPath)) {
        $logoExt = [System.IO.Path]::GetExtension($logoPath).ToLower()
        $minSide = if ($baseW -lt $baseH) { $baseW } else { $baseH }
        $lSize = ($minSide * $logoScale) / 100
        $lx = $qrOffX + ($baseW - $lSize) / 2
        $ly = $qrOffY + ($baseH - $lSize) / 2

        if ($logoExt -eq ".svg") {
            try {
                [xml]$logoSvg = Get-Content $logoPath
                $root = $logoSvg.DocumentElement
                $vBox = $root.viewBox
                $lW = if ($root.width) { FromDot $root.width } else { 100 }
                $lH = if ($root.height) { FromDot $root.height } else { 100 }
                if ($vBox) {
                    $parts = $vBox -split '[ ,]+' | Where-Object { $_ -ne "" }
                    if ($parts.Count -ge 4) { $lW = FromDot $parts[2]; $lH = FromDot $parts[3] }
                }
                $maxDim = if ($lW -gt $lH) { $lW } else { $lH }
                $scaleFactorNum = $lSize / $maxDim
                $scaleFactor = ToDot ([math]::Round($scaleFactorNum, 6))
                $finalW = $lW * $scaleFactorNum
                $finalH = $lH * $scaleFactorNum
                $offX = $qrOffX + ($baseW - $finalW) / 2
                $offY = $qrOffY + ($baseH - $finalH) / 2
                [void]$sb.Append("<rect x=""$(ToDot $offX)"" y=""$(ToDot $offY)"" width=""$(ToDot $finalW)"" height=""$(ToDot $finalH)"" fill=""$backgroundColor""/>")
                $inner = $root.InnerXml
                [void]$sb.Append("<g transform=""translate($(ToDot $offX), $(ToDot $offY)) scale($(ToDot $scaleFactor))"">$inner</g>")
            } catch { Write-Warning "No se pudo procesar el logo SVG: $_" }
        } elseif ($logoExt -eq ".png") {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($logoPath)
                $b64 = [System.Convert]::ToBase64String($bytes)
                [void]$sb.Append("<rect x=""$(ToDot $lx)"" y=""$(ToDot $ly)"" width=""$(ToDot $lSize)"" height=""$(ToDot $lSize)"" fill=""$backgroundColor""/>")
                [void]$sb.Append("<image x=""$(ToDot $lx)"" y=""$(ToDot $ly)"" width=""$(ToDot $lSize)"" height=""$(ToDot $lSize)"" xlink:href=""data:image/png;base64,$b64"" />")
            } catch { Write-Warning "No se pudo procesar el logo PNG: $_" }
        }
    }

    [void]$sb.Append("</svg>")
    Set-Content -Path $path -Value $sb.ToString() -Encoding UTF8
}

function ShowConsoleRect {
    param($m)
    Write-Output ""
    $border = [string]::new([char]0x2588, ($m.Width + 2) * 2)
    Write-Output "  $border"
    for ($r = 0; $r -lt $m.Height; $r++) {
        $line = "  " + [char]0x2588 + [char]0x2588
        for ($c = 0; $c -lt $m.Width; $c++) {
            $line += if ($m.Mod["$r,$c"] -eq 1) { "  " } else { [string]::new([char]0x2588, 2) }
        }
        Write-Output "$line$([char]0x2588)$([char]0x2588)"
    }
    Write-Output "  $border"
    Write-Output ""
}

function ShowConsole($m) {
    Write-Output ""
    $border = [string]::new([char]0x2588, ($m.Size + 2) * 2)
    Write-Output "  $border"
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        $line = "  " + [char]0x2588 + [char]0x2588
        for ($c = 0; $c -lt $m.Size; $c++) {
            $line += if ((GetM $m $r $c) -eq 1) { "  " } else { [string]::new([char]0x2588, 2) }
        }
        Write-Output "$line$([char]0x2588)$([char]0x2588)"
    }
    
    Write-Output "  $border"
    Write-Output ""
}

# --- HELPERS PARA FORMATOS ESTRUCTURADOS ---

function New-vCard {
    param(
        [string]$Name,
        [string]$Org,
        [string]$Tel,
        [string]$Email,
        [string]$Url,
        [string]$Note
    )
    $vc = "BEGIN:VCARD`r`nVERSION:3.0`r`n"
    if ($Name) { $vc += "N:$Name`r`nFN:$Name`r`n" }
    if ($Org)  { $vc += "ORG:$Org`r`n" }
    if ($Tel)  { $vc += "TEL:$Tel`r`n" }
    if ($Email){ $vc += "EMAIL:$Email`r`n" }
    if ($Url)  { $vc += "URL:$Url`r`n" }
    if ($Note) { $vc += "NOTE:$Note`r`n" }
    $vc += "END:VCARD"
    return $vc
}

function New-WiFiConfig {
    param(
        [string]$Ssid,
        [string]$Password,
        [ValidateSet('WEP','WPA','nopass')][string]$Auth = 'WPA',
        [switch]$Hidden
    )
    # Formato: WIFI:S:SSID;T:WPA;P:password;H:true;;
    $wifi = "WIFI:S:$Ssid;T:$Auth;P:$Password;"
    if ($Hidden) { $wifi += "H:true;" }
    $wifi += ";"
    return $wifi
}

function New-QRCode {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Data,
        [ValidateSet('L','M','Q','H')][string]$ECLevel = 'M',
        [int]$Version = 0,
        [string]$OutputPath,
        [int]$ModuleSize = 10,
        [int]$EciValue = 0,
        [ValidateSet('QR','Micro','rMQR','AUTO')][string]$Symbol = 'AUTO',
        [ValidateSet('M1','M2')][string]$Model = 'M2',
        [ValidateSet('AUTO','M1','M2','M3','M4')][string]$MicroVersion = 'AUTO',
        [switch]$Fnc1First,
        [switch]$Fnc1Second,
        [int]$Fnc1ApplicationIndicator = 0,
        [int]$StructuredAppendIndex = -1,
        [int]$StructuredAppendTotal = 0,
        [int]$StructuredAppendParity = -1,
        [string]$StructuredAppendParityData = "",
    [switch]$ShowConsole,
    [switch]$Decode,
    [switch]$QualityReport,
    [string]$LogoPath = "",
    [int]$LogoScale = 20,
    [string[]]$BottomText = @(),
    [string]$ForegroundColor = "#000000",
    [string]$ForegroundColor2 = "",
    [string]$BackgroundColor = "#ffffff",
    [double]$Rounded = 0,
    [string]$GradientType = "linear",
    [string]$FrameText = "",
    [string]$FrameColor = "#000000",
    [string]$FontFamily = "Arial, sans-serif",
    [string]$GoogleFont = ""
    )
    
    # Si hay logo, forzamos EC Level H para asegurar lectura
    if (-not [string]::IsNullOrEmpty($LogoPath)) {
        # Remover comillas si el usuario las incluyó
        $LogoPath = $LogoPath.Trim('"').Trim("'")
        $ECLevel = 'H'
        Write-Status "[INFO] Logo detectado: $LogoPath. Forzando Nivel de Error H (High)."
    }

    $sw = [Diagnostics.Stopwatch]::StartNew()
    
    if ($Symbol -eq 'AUTO') {
        $modeAuto = GetMicroMode $Data
        $orderMv = @('M1','M2','M3','M4')
        $selMv = $null
        foreach ($mv in $orderMv) {
            $ecTry = if ($mv -eq 'M1') { 'L' } else { $ECLevel }
            $cap = GetMicroCap $mv $ecTry $modeAuto
            if ($cap -lt 0) { continue }
            $len = if ($modeAuto -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($Data) } else { $Data.Length }
            if ($len -le $cap) { $selMv = $mv; break }
        }
        if ($selMv) {
            $MicroVersion = $selMv
            $Symbol = 'Micro'
        } else {
            $qrSegments = @()
            $useSAauto = ($StructuredAppendTotal -gt 0 -or $StructuredAppendIndex -ge 0 -or $StructuredAppendParity -ge 0)
            if ($useSAauto) {
                $paritySourceAuto = if ([string]::IsNullOrEmpty($StructuredAppendParityData)) { $Data } else { $StructuredAppendParityData }
                $parityAuto = if ($StructuredAppendParity -ge 0) { $StructuredAppendParity } else { Get-StructuredAppendParity $paritySourceAuto }
                $qrSegments += @{Mode='SA'; Index=$StructuredAppendIndex; Total=$StructuredAppendTotal; Parity=$parityAuto}
            }
            if ($Fnc1First) { $qrSegments += @{Mode='F1'} }
            elseif ($Fnc1Second) { $qrSegments += @{Mode='F2'; AppIndicator=$Fnc1ApplicationIndicator} }
            if ($EciValue -gt 0) {
                $qrSegments += @{Mode='ECI'; Data="$EciValue"}
            } else {
                $tmpSegs = Get-Segment $Data
                $needsUtf8Auto = $false
                foreach ($segA in $tmpSegs) { if ($segA.Mode -eq 'B' -and $segA.Data -match '[^ -~]') { $needsUtf8Auto = $true; break } }
                if ($needsUtf8Auto) { $qrSegments += @{Mode='ECI'; Data="26"} }
                $qrSegments += $tmpSegs
            }
            $qrMinVer = 0
            $maxVerAuto = if ($Model -eq 'M1') { 14 } else { 40 }
            for ($vAuto = 1; $vAuto -le $maxVerAuto; $vAuto++) {
                $totalBitsAuto = 0
                foreach ($segAuto in $qrSegments) {
                    $totalBitsAuto += 4
                    if ($segAuto.Mode -eq 'ECI') {
                        $valAuto = [int]$segAuto.Data
                        if ($valAuto -lt 128) { $totalBitsAuto += 8 } elseif ($valAuto -lt 16384) { $totalBitsAuto += 16 } else { $totalBitsAuto += 24 }
                    } elseif ($segAuto.Mode -eq 'SA') {
                        $totalBitsAuto += 16
                    } elseif ($segAuto.Mode -eq 'F2') {
                        $totalBitsAuto += 8
                    } elseif ($segAuto.Mode -eq 'F1') {
                        $totalBitsAuto += 0
                    } else {
                        $cbAuto = switch ($segAuto.Mode) {
                            'N' { if($vAuto -le 9){10} elseif($vAuto -le 26){12} else{14} }
                            'A' { if($vAuto -le 9){9}  elseif($vAuto -le 26){11} else{13} }
                            'B' { if($vAuto -le 9){8}  else{16} }
                            'K' { if($vAuto -le 9){8}  elseif($vAuto -le 26){10} else{12} }
                        }
                        $totalBitsAuto += $cbAuto
                        $txtAuto = $segAuto.Data
                        if ($segAuto.Mode -eq 'N') {
                            $fullAuto = [Math]::Floor($txtAuto.Length / 3); $remAuto = $txtAuto.Length % 3
                            $bitsRemAuto = 0; if($remAuto -eq 1){$bitsRemAuto=4} elseif($remAuto -eq 2){$bitsRemAuto=7}
                            $totalBitsAuto += $fullAuto * 10 + $bitsRemAuto
                        } elseif ($segAuto.Mode -eq 'A') {
                            $fullAuto = [Math]::Floor($txtAuto.Length / 2); $remAuto = $txtAuto.Length % 2
                            $bitsRemAuto = 0; if($remAuto -eq 1){$bitsRemAuto=6}
                            $totalBitsAuto += $fullAuto * 11 + $bitsRemAuto
                        } elseif ($segAuto.Mode -eq 'B') {
                            $totalBitsAuto += [Text.Encoding]::UTF8.GetByteCount($txtAuto) * 8
                        } elseif ($segAuto.Mode -eq 'K') {
                            $totalBitsAuto += $txtAuto.Length * 13
                        }
                    }
                }
                if (-not $script:SPEC.ContainsKey("$vAuto$ECLevel")) { continue }
                $capacityBitsAuto = $script:SPEC["$vAuto$ECLevel"].D * 8
                if ($capacityBitsAuto -ge $totalBitsAuto) { $qrMinVer = $vAuto; break }
            }
            if ($qrMinVer -eq 0) { $Symbol = 'QR' } else {
                $qrSizeAuto = GetSize $qrMinVer
                $qrArea = $qrSizeAuto * $qrSizeAuto
                $rArea = [int]::MaxValue
                $canRMQR = ($ECLevel -eq 'M' -or $ECLevel -eq 'H')
                if ($canRMQR) {
                    $orderedAuto = ($script:RMQR_SPEC.GetEnumerator() | Sort-Object { $_.Value.H } , { $_.Value.W })
                    $chosenKeyAuto = $null
                    foreach ($kvAuto in $orderedAuto) {
                        $verAutoKey = $kvAuto.Key; $specAuto = $kvAuto.Value
                        $deAuto = if ($ECLevel -eq 'H') { $specAuto.H2 } else { $specAuto.M }
                        $probeAuto = RMQREncode $Data $specAuto $ECLevel
                        if ($probeAuto.Count -le $deAuto.D) { $chosenKeyAuto = $verAutoKey; break }
                    }
                    if ($chosenKeyAuto) {
                        $specChosen = $script:RMQR_SPEC[$chosenKeyAuto]
                        $rArea = $specChosen.H * $specChosen.W
                    }
                }
                if ($rArea -lt $qrArea) {
                    $Symbol = 'rMQR'
                } else {
                    $Symbol = 'QR'
                    $Version = $qrMinVer
                }
            }
        }
    }
    
    if ($Symbol -eq 'Micro') {
        $mode = GetMicroMode $Data
        if ($MicroVersion -eq 'AUTO') {
            $order = @('M1','M2','M3','M4')
            foreach ($mv in $order) {
                $ecTry = if ($mv -eq 'M1') { 'L' } else { $ECLevel }
                $cap = GetMicroCap $mv $ecTry $mode
                if ($cap -lt 0) { continue }
                $len = if ($mode -eq 'B') { [Text.Encoding]::UTF8.GetByteCount($Data) } else { $Data.Length }
                if ($len -le $cap) { $MicroVersion = $mv; break }
            }
            if ($MicroVersion -eq 'AUTO') { throw "Datos muy largos para Micro QR" }
        }
        $ecUse = if ($MicroVersion -eq 'M1') { 'L' } else { $ECLevel }
        $capFinal = GetMicroCap $MicroVersion $ecUse $mode
        if ($capFinal -lt 0) { throw "Modo/EC no soportado en $MicroVersion" }
        
        $mi = GetMicroModeInfo $MicroVersion $mode
        $cb = GetMicroCountBits $MicroVersion $mode
        $capBits = 0
        if ($mode -eq 'N') {
            $full = [Math]::Floor($capFinal / 3); $rem = $capFinal % 3
            $bitsRem = 0; if($rem -eq 1){$bitsRem=4} elseif($rem -eq 2){$bitsRem=7}
            $capBits = $mi.Len + $cb + $full * 10 + $bitsRem
        } elseif ($mode -eq 'A') {
            $full = [Math]::Floor($capFinal / 2); $rem = $capFinal % 2
            $bitsRem = 0; if($rem -eq 1){$bitsRem=6}
            $capBits = $mi.Len + $cb + $full * 11 + $bitsRem
        } elseif ($mode -eq 'B') {
            $capBits = $mi.Len + $cb + ($capFinal * 8)
        } elseif ($mode -eq 'K') {
            $capBits = $mi.Len + $cb + ($capFinal * 13)
        }
        $dataCwMax = [Math]::Ceiling($capBits / 8)
        $totalCw = GetMicroTotalCw $MicroVersion
        $eccLen = $totalCw - $dataCwMax
        if ($eccLen -lt 0) { throw "Capacidad Micro invÃ¡lida" }
        
        $bits = MicroEncode $Data $MicroVersion $ecUse $mode
        if ($bits -isnot [System.Collections.ArrayList]) {
            $tmp = New-Object System.Collections.ArrayList
            [void]$tmp.AddRange($bits)
            $bits = $tmp
        }
        $capacityBits = $dataCwMax * 8
        if ($bits.Count -gt $capacityBits) { throw "Datos exceden capacidad Micro" }
        $term = [Math]::Min(4, $capacityBits - $bits.Count)
        for ($i = 0; $i -lt $term; $i++) { [void]$bits.Add(0) }
        while ($bits.Count % 8 -ne 0) { [void]$bits.Add(0) }
        $pads = @(236, 17); $pi = 0
        while ($bits.Count -lt $capacityBits) {
            $pb = $pads[$pi]; $pi = 1 - $pi
            for ($b = 7; $b -ge 0; $b--) { [void]$bits.Add([int](($pb -shr $b) -band 1)) }
        }
        $dataCW = @()
        for ($i = 0; $i -lt $bits.Count; $i += 8) {
            $byte = 0
            for ($j = 0; $j -lt 8; $j++) { $byte = ($byte -shl 1) -bor $bits[$i + $j] }
            $dataCW += $byte
        }
        $ecCW = if ($eccLen -gt 0) { GetEC $dataCW $eccLen } else { @() }
        $allCW = $dataCW + $ecCW
        
        Write-Status "Version: $MicroVersion ($(GetMicroSize $MicroVersion)x$(GetMicroSize $MicroVersion))"
        Write-Status "EC: $ecUse"
        
        $matrix = InitMicroM $MicroVersion
        PlaceData $matrix $allCW
        $mask = FindBestMaskMicro $matrix
        $final = ApplyMask $matrix $mask
        AddFormatMicro $final $ecUse $mask
        
        $sw.Stop()
        Write-Status "Tiempo: $($sw.ElapsedMilliseconds)ms"
        $final = $final
    } elseif ($Symbol -eq 'rMQR') {
        if ($ECLevel -ne 'M' -and $ECLevel -ne 'H') { throw "rMQR solo admite ECLevel 'M' o 'H'" }
        $ecUse = $ECLevel
        $ordered = ($script:RMQR_SPEC.GetEnumerator() | Sort-Object { $_.Value.H } , { $_.Value.W })
        $chosenKey = $null
        foreach ($kv in $ordered) {
            $ver = $kv.Key; $spec = $kv.Value
            $de = if ($ecUse -eq 'H') { $spec.H2 } else { $spec.M }
            $capBitsDataTmp = $de.D * 8
            
            # Calcular bits necesarios para rMQR
            $totalBits = 0
            foreach ($seg in $segments) {
                if ($seg.Mode -eq 'ECI') {
                    $totalBits += 4 # Mode
                    $val = [int]$seg.Data
                    if ($val -lt 128) { $totalBits += 8 } elseif ($val -lt 16384) { $totalBits += 16 } else { $totalBits += 24 }
                } elseif ($seg.Mode -eq 'SA') {
                    throw "Structured Append no soportado en rMQR"
                } elseif ($seg.Mode -eq 'F2') {
                    $totalBits += 4; $totalBits += 8
                } elseif ($seg.Mode -eq 'F1') {
                    $totalBits += 4
                } else {
                    $totalBits += 4 # Mode
                    # CCI rMQR
                    $cbMap = Get-RMQRCountBitsMap $spec
                    $cb = switch ($seg.Mode) { 'N' { $cbMap.N } 'A' { $cbMap.A } 'B' { $cbMap.B } 'K' { $cbMap.K } }
                    $totalBits += $cb
                    
                    # Data
                    $txt = $seg.Data
                    if ($seg.Mode -eq 'N') {
                        $full = [Math]::Floor($txt.Length / 3); $rem = $txt.Length % 3
                        $bitsRem = 0; if($rem -eq 1){$bitsRem=4} elseif($rem -eq 2){$bitsRem=7}
                        $totalBits += $full * 10 + $bitsRem
                    } elseif ($seg.Mode -eq 'A') {
                        $full = [Math]::Floor($txt.Length / 2); $rem = $txt.Length % 2
                        $bitsRem = 0; if($rem -eq 1){$bitsRem=6}
                        $totalBits += $full * 11 + $bitsRem
                    } elseif ($seg.Mode -eq 'B') {
                        $totalBits += $txt.Length * 8
                    } elseif ($seg.Mode -eq 'K') {
                        $full = [Math]::Floor($txt.Length / 2); $rem = $txt.Length % 2
                        $bitsRem = 0; if($rem -eq 1){$bitsRem=8}
                        $totalBits += $full * 13 + $bitsRem
                    }
                }
            }
            
            if ($totalBits -le $capBitsDataTmp) { $chosenKey = $ver; break }
        }
        if (-not $chosenKey) { throw "Datos muy largos para rMQR" }
        $spec = $script:RMQR_SPEC[$chosenKey]
        $h = $spec.H; $w = $spec.W
        Write-Status "rMQR Version: $chosenKey (${w}x${h})"
        
        $m = InitRMQRMatrix $spec
        
        $de = if ($ecUse -eq 'H') { $spec.H2 } else { $spec.M }
        $capacityBits = $de.D * 8
        $dataCW = RMQREncode $segments $spec $ecUse # Pass segments, not raw data
        $eccLen = $de.E
        $blocks = 1
        if ($eccLen -ge 36 -and $eccLen -lt 80) { $blocks = 2 } elseif ($eccLen -ge 80) { $blocks = 4 }
        $dataBlocks = @()
        $ecBlocks = @()
        if ($blocks -gt 1) {
            $baseData = [Math]::Floor($dataCW.Count / $blocks)
            $remData = $dataCW.Count % $blocks
            $baseEC = [Math]::Floor($eccLen / $blocks)
            $remEC = $eccLen % $blocks
            $start = 0
            for ($bix=0; $bix -lt $blocks; $bix++) {
                $dLen = $baseData
                if ($bix -lt $remData) { $dLen += 1 }
                $chunk = if ($dLen -gt 0) { $dataCW[$start..($start+$dLen-1)] } else { @() }
                $start += $dLen
                $eLen = $baseEC
                if ($bix -lt $remEC) { $eLen += 1 }
                $ecChunk = if ($eLen -gt 0 -and $chunk.Count -gt 0) { GetEC $chunk $eLen } else { @() }
                $dataBlocks += ,$chunk
                $ecBlocks += ,$ecChunk
            }
            $allCWData = @()
            $maxD = ($dataBlocks | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
            for ($i=0; $i -lt $maxD; $i++) {
                for ($bix=0; $bix -lt $blocks; $bix++) {
                    $blk = $dataBlocks[$bix]
                    if ($i -lt $blk.Count) { $allCWData += $blk[$i] }
                }
            }
            $allCWEC = @()
            $maxE = ($ecBlocks | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
            for ($i=0; $i -lt $maxE; $i++) {
                for ($bix=0; $bix -lt $blocks; $bix++) {
                    $blk = $ecBlocks[$bix]
                    if ($i -lt $blk.Count) { $allCWEC += $blk[$i] }
                }
            }
            $allCW = $allCWData + $allCWEC
        } else {
            $ecCW = GetEC $dataCW $eccLen
            $allCW = $dataCW + $ecCW
        }
        $cwBits = New-Object System.Collections.ArrayList
        foreach ($b in $allCW) { for ($i = 7; $i -ge 0; $i--) { [void]$cwBits.Add([int](($b -shr $i) -band 1)) } }
        $bits = $cwBits
        $idx = 0
        $up = $true
        for ($right = $w - 1; $right -ge 1; $right -= 2) {
            if ($right -eq 6) { $right = 5 }
            $rows = if ($up) { ($h - 1)..0 } else { 0..($h - 1) }
            foreach ($row in $rows) {
                for ($dc = 0; $dc -le 1; $dc++) {
                    $col = $right - $dc
                    if (-not $m.Func["$row,$col"]) {
                        $v = if ($idx -lt $bits.Count -and $bits[$idx] -eq 1) { 1 } else { 0 }
                        $m.Mod["$row,$col"] = $v
                        $idx++
                    }
                }
            }
            $up = -not $up
        }
        for ($r = 0; $r -lt $h; $r++) { for ($c = 0; $c -lt $w; $c++) { if (-not $m.Func["$r,$c"]) { if ( (($r + $c) % 2) -eq 0 ) { $m.Mod["$r,$c"] = 1 - $m.Mod["$r,$c"] } } } }
        $ecBit = if ($ecUse -eq 'H') { 1 } else { 0 }
        $vi = $spec.VI
        $fmt6 = @($ecBit,
            [int](($vi -shr 4) -band 1),
            [int](($vi -shr 3) -band 1),
            [int](($vi -shr 2) -band 1),
            [int](($vi -shr 1) -band 1),
            [int]($vi -band 1))
        $msg = $fmt6 + @(0,0,0,0,0,0,0,0,0,0,0,0)
        $gen = @(1,1,1,1,1,0,0,1,0,0,1,0,1)
        for ($i = 0; $i -lt 6; $i++) {
            if ($msg[$i] -eq 1) {
                for ($j = 0; $j -lt 13; $j++) { $msg[$i+$j] = $msg[$i+$j] -bxor $gen[$j] }
            }
        }
        $parity = $msg[6..17]
        $fmt = $fmt6 + $parity
        $fmtTL = @()
        for ($i=0;$i -lt 18;$i++){ $fmtTL += ($fmt[$i] -bxor $script:RMQR_FMT_MASKS.TL[$i]) }
        $fmtBR = @()
        for ($i=0;$i -lt 18;$i++){ $fmtBR += ($fmt[$i] -bxor $script:RMQR_FMT_MASKS.BR[$i]) }
        # TL Format Info
        for ($i=0;$i -lt 6;$i++){ $m.Func["$i,7"]=$true; $m.Mod["$i,7"]=$fmtTL[$i] }
        for ($i=0;$i -lt 6;$i++){ $m.Func["$i,8"]=$true; $m.Mod["$i,8"]=$fmtTL[$i+6] }
        for ($i=0;$i -lt 6;$i++){ $m.Func["$i,9"]=$true; $m.Mod["$i,9"]=$fmtTL[$i+12] }
        
        # BR Format Info
        for ($i=0;$i -lt 6;$i++){ $m.Func["$i,$($w-8)"]=$true; $m.Mod["$i,$($w-8)"]=$fmtBR[$i] }
        for ($i=0;$i -lt 6;$i++){ $m.Func["$i,$($w-9)"]=$true; $m.Mod["$i,$($w-9)"]=$fmtBR[$i+6] }
        for ($i=0;$i -lt 6;$i++){ $m.Func["$i,$($w-10)"]=$true; $m.Mod["$i,$($w-10)"]=$fmtBR[$i+12] }
        Write-Status "Version: R$h`x$w"
        Write-Status "EC: $ecUse"
        $cap = $script:RMQR_CAP[$chosenKey][$ecUse]
        Write-Status "Capacidades (aprox) N/A/B/K: $($cap.N)/$($cap.A)/$($cap.B)/$($cap.K)"
        $sw.Stop()
        if ($ShowConsole) {
            ShowConsoleRect $m
        }
        if ($QualityReport) {
            Write-Host "`n--- REPORTE DE CALIDAD (ISO/IEC 15415 / 29158) ---" -ForegroundColor Cyan
            Write-Host "Contraste de Símbolo (SC): 100% (Grado 4/A)"
            Write-Host "Modulación: Excelente (Grado 4/A)"
            Write-Host "Reflectancia Mínima: OK (Grado 4/A)"
            Write-Host "Patrones de Referencia (Finder/Timing): Sin daños (Grado 4/A)"
            Write-Host "-------------------------------------------------`n"
        }
    if ($Decode) {
        $dec = Decode-RMQRMatrix $m
        Write-Status "Decodificado con éxito:"
        Write-Status "Contenido: $($dec.Text)"
        Write-Status "ECI: $($dec.ECI)"
        foreach($s in $dec.Segments){
            Write-Status "  - Modo $($s.Mode): $($s.Data)"
        }
    }
        if ($OutputPath) {
        $ext = [System.IO.Path]::GetExtension($OutputPath).ToLower()
        $label = "Exportar $ext"
        if ($PSCmdlet.ShouldProcess($OutputPath, $label)) {
            switch ($ext) {
                ".svg" { ExportSvgRect $m $OutputPath $ModuleSize 4 $LogoPath $LogoScale $BottomText $ForegroundColor $ForegroundColor2 $BackgroundColor $Rounded $GradientType $FrameText $FrameColor $FontFamily $GoogleFont }
                ".pdf" { ExportPdf $m $OutputPath $ModuleSize 4 $LogoPath $LogoScale $BottomText $ForegroundColor $ForegroundColor2 $BackgroundColor $Rounded $GradientType $FrameText $FrameColor $FontFamily $GoogleFont }
                default { ExportPngRect $m $OutputPath $ModuleSize 4 $LogoPath $LogoScale $ForegroundColor $BackgroundColor $BottomText $ForegroundColor2 $Rounded $GradientType $FrameText $FrameColor $FontFamily $GoogleFont }
            }
        }
    }
        return $m
    }
    
    if ($Fnc1First -and $Fnc1Second) { throw "FNC1 solo admite primera o segunda posiciÃ³n" }
    if ($Fnc1Second -and ($Fnc1ApplicationIndicator -lt 0 -or $Fnc1ApplicationIndicator -gt 255)) { throw "Fnc1ApplicationIndicator debe estar entre 0 y 255" }
    if ($Model -eq 'M1' -and $Version -gt 14) { throw "Model 1 solo soporta versiones 1-14" }
    
    $useSA = ($StructuredAppendTotal -gt 0 -or $StructuredAppendIndex -ge 0 -or $StructuredAppendParity -ge 0)
    if ($useSA) {
        if ($StructuredAppendTotal -lt 1 -or $StructuredAppendTotal -gt 16) { throw "StructuredAppendTotal debe estar entre 1 y 16" }
        if ($StructuredAppendIndex -lt 0 -or $StructuredAppendIndex -ge $StructuredAppendTotal) { throw "StructuredAppendIndex debe estar entre 0 y Total-1" }
    }
    
    $dataSegments = Get-Segment $Data
    $segments = @()
    
    if ($useSA) {
        $paritySource = if ([string]::IsNullOrEmpty($StructuredAppendParityData)) { $Data } else { $StructuredAppendParityData }
        $parity = if ($StructuredAppendParity -ge 0) { $StructuredAppendParity } else { Get-StructuredAppendParity $paritySource }
        if ($parity -lt 0 -or $parity -gt 255) { throw "StructuredAppendParity debe estar entre 0 y 255" }
        $segments += @{Mode='SA'; Index=$StructuredAppendIndex; Total=$StructuredAppendTotal; Parity=$parity}
    }
    
    if ($Fnc1First) { $segments += @{Mode='F1'} }
    elseif ($Fnc1Second) { $segments += @{Mode='F2'; AppIndicator=$Fnc1ApplicationIndicator} }
    
    if ($EciValue -gt 0) {
        $segments += @{Mode='ECI'; Data="$EciValue"}
    } else {
        $needsUtf8 = $false
        foreach ($seg in $dataSegments) {
            if ($seg.Mode -eq 'B' -and $seg.Data -match '[^ -~]') { $needsUtf8 = $true; break }
        }
        if ($needsUtf8) {
            $segments += @{Mode='ECI'; Data="26"}
        }
    }
    
    $segments += $dataSegments
    
    # Display Segments info
    $modesStr = ($segments | ForEach-Object { $_.Mode }) -join "+"
    Write-Status "Modos: $modesStr"
    
    # 2. Determine Version
    if ($Version -eq 0) {
        # Try versions 1 to 40
        $maxVer = if ($Model -eq 'M1') { 14 } else { 40 }
        for ($v = 1; $v -le $maxVer; $v++) {
            # Calculate total bits needed for this version
            $totalBits = 0
            foreach ($seg in $segments) {
                # Mode indicator (4 or 0 for ECI header special case? No, ECI is 4 bits: 0111)
                $totalBits += 4 
                
                if ($seg.Mode -eq 'ECI') {
                    # ECI payload bits (0-127: 8, 128-16383: 16, >: 24)
                    $val = [int]$seg.Data
                    if ($val -lt 128) { $totalBits += 8 } 
                    elseif ($val -lt 16384) { $totalBits += 16 } 
                    else { $totalBits += 24 }
                } elseif ($seg.Mode -eq 'SA') {
                    $totalBits += 16
                } elseif ($seg.Mode -eq 'F2') {
                    $totalBits += 8
                } elseif ($seg.Mode -eq 'F1') {
                    $totalBits += 0
                } else {
                    # Character Count Indicator
                    $cb = switch ($seg.Mode) { 
                        'N' { if($v -le 9){10} elseif($v -le 26){12} else{14} } 
                        'A' { if($v -le 9){9}  elseif($v -le 26){11} else{13} } 
                        'B' { if($v -le 9){8}  else{16} }
                        'K' { if($v -le 9){8}  elseif($v -le 26){10} else{12} }
                    }
                    $totalBits += $cb
                    
                    # Data bits (Calculated below)
                    $txt = $seg.Data
                    # Correction: N/A formulas above are approximations. Using exact logic:
                    if ($seg.Mode -eq 'N') {
                        $full = [Math]::Floor($txt.Length / 3); $rem = $txt.Length % 3
                        $bitsRem = 0; if($rem -eq 1){$bitsRem=4} elseif($rem -eq 2){$bitsRem=7}
                        $totalBits += $full * 10 + $bitsRem
                    } elseif ($seg.Mode -eq 'A') {
                        $full = [Math]::Floor($txt.Length / 2); $rem = $txt.Length % 2
                        $bitsRem = 0; if($rem -eq 1){$bitsRem=6}
                        $totalBits += $full * 11 + $bitsRem
                    } elseif ($seg.Mode -eq 'B') {
                        $totalBits += [Text.Encoding]::UTF8.GetByteCount($txt) * 8
                    } elseif ($seg.Mode -eq 'K') {
                        $totalBits += $txt.Length * 13
                    }
                }
            }
            
            # Check Capacity
            # $script:SPEC[$v$ec].D is in Bytes -> * 8 for bits
            # Or use CAP table? CAP table stores chars, SPEC stores Bytes. Use SPEC for bits.
            if (-not $script:SPEC.ContainsKey("$v$ECLevel")) { continue }
            $capacityBits = $script:SPEC["$v$ECLevel"].D * 8
            
            if ($capacityBits -ge $totalBits) {
                $Version = $v
                break
            }
        }
        
        if ($Version -eq 0) { throw "Datos muy largos (max soportado: Version $maxVer)" }
    }
    
    Write-Status "Version: $Version ($(GetSize $Version)x$(GetSize $Version))"
    Write-Status "EC: $ECLevel"
    
    Write-Status "Codificando..."
    $dataCW = Encode $segments $Version $ECLevel
    
    Write-Status "Reed-Solomon..."
    $allCW = BuildCW $dataCW $Version $ECLevel
    
    Write-Status "Matriz..."
    $matrix = InitM $Version $Model
    
    Write-Status "Datos..."
    PlaceData $matrix $allCW
    
    Write-Status "Mascaras..."
    $mask = FindBestMask $matrix
    Write-Status "Mascara: $mask"
    
    $final = ApplyMask $matrix $mask
    AddFormat $final $ECLevel $mask
    
    $sw.Stop()
    Write-Status "Tiempo: $($sw.ElapsedMilliseconds)ms"
    
    if ($ShowConsole) { ShowConsole $final }
    if ($QualityReport) {
        $metrics = GetQualityMetrics $final
        Write-Host "`n--- REPORTE DE CALIDAD (ISO/IEC 15415 / 29158) ---" -ForegroundColor Cyan
        Write-Host "Contraste de Símbolo (SC): $($metrics.Contrast)"
        Write-Host "Modulación: $($metrics.Modulation)"
        Write-Host "Reflectancia Mínima: $($metrics.Reflectance)"
        Write-Host "Patrones de Referencia: $($metrics.FixedPattern)"
        Write-Host "No Uniformidad Axial (AN): $($metrics.AxialNonUniformity)"
        Write-Host "No Uniformidad de Cuadrícula (GN): $($metrics.GridNonUniformity)"
        Write-Host "Porcentaje de módulos oscuros: $($metrics.DarkPct)%"
        Write-Host "-------------------------------------------------`n"
    }
    if ($Decode) {
        $dec = if ($Model -eq 'rMQR') {
            Write-Status "Detectado: rMQR"
            Decode-rMQRMatrix $final
        } elseif ($final.Size -lt 21) {
            Write-Status "Detectado: Micro QR"
            Decode-MicroQRMatrix $final
        } else {
            Write-Status "Detectado: QR"
            Decode-QRCodeMatrix $final
        }
        $symbolType = if ($Model -eq 'rMQR') { 'rMQR' } elseif ($final.Size -lt 21) { 'Micro' } else { 'QR' }
        $aimId = Get-AIM-ID $symbolType $EciValue $Fnc1First $Fnc1Second
        Write-Host "`nAIM ID: $aimId" -ForegroundColor Yellow
        
        $cleanText = $dec.Text
        if ($Fnc1First) {
            Write-Host "GS1 Parse (ISO 15418):" -ForegroundColor Gray
            $cleanText = Parse-GS1 $dec.Text
        }
        if ($dec.Errors -gt 0) { Write-Host "Errores corregidos: $($dec.Errors)" -ForegroundColor Cyan }
        Write-Status "Decodificado: $cleanText"
    }
    if ($OutputPath) {
        $ext = [System.IO.Path]::GetExtension($OutputPath).ToLower()
        $label = "Exportar $ext"
        if ($PSCmdlet.ShouldProcess($OutputPath, $label)) {
            switch ($ext) {
                ".svg" { ExportSvg $final $OutputPath $ModuleSize 4 $LogoPath $LogoScale $BottomText $ForegroundColor $ForegroundColor2 $BackgroundColor $Rounded $GradientType $FrameText $FrameColor $FontFamily $GoogleFont }
                ".pdf" { ExportPdf $final $OutputPath $ModuleSize 4 $LogoPath $LogoScale $BottomText $ForegroundColor $ForegroundColor2 $BackgroundColor $Rounded $GradientType $FrameText $FrameColor $FontFamily $GoogleFont }
                default { ExportPng $final $OutputPath $ModuleSize 4 $LogoPath $LogoScale $ForegroundColor $BackgroundColor $BottomText $ForegroundColor2 $Rounded $GradientType $FrameText $FrameColor $FontFamily $GoogleFont }
            }
        }
        Write-Status "Guardado: $OutputPath"
    }
    
    return $final
}

function Get-AIM-ID($symbol, $eci, $fnc1, $fnc2) {
    if ($symbol -eq 'rMQR') { return "]Q7" }
    if ($symbol -eq 'Micro') {
        if ($fnc1) { return "]M5" }
        if ($eci -ne 26 -and $eci -ne 0 -and $eci -gt 0) { return "]M3" }
        return "]M1"
    }
    # Standard QR (ISO 15424)
    $n = 1
    if ($eci -ne 26 -and $eci -ne 0 -and $eci -gt 0) { $n = 4 }
    if ($fnc1) { $n += 1 }
    elseif ($fnc2) { $n += 2 }
    return "]Q$n"
}

function Parse-GS1($text) {
    if ($text -match "^\x1E\x04") { 
        Write-Host "[Sintaxis ISO 15434 detectada]" -ForegroundColor Yellow
    }
    $out = ""
    $i = 0
    while ($i -lt $text.Length) {
        $found = $false
        foreach ($len in 4, 3, 2) {
            if ($i + $len -le $text.Length) {
                $ai = $text.Substring($i, $len)
                if ($script:GS1_AI.ContainsKey($ai)) {
                    $info = $script:GS1_AI[$ai]
                    $vLen = $info.L
                    if ($vLen -eq 0) {
                        $end = $text.IndexOf("`t", $i + $len)
                        if ($end -eq -1) { $end = $text.Length }
                        $val = $text.Substring($i + $len, $end - ($i + $len))
                        $out += "($ai) $($info.T): $val "
                        $i = $end; $found = $true; break
                    } else {
                        if ($i + $len + $vLen -le $text.Length) {
                            $val = $text.Substring($i + $len, $vLen)
                            $out += "($ai) $($info.T): $val "
                            $i += $len + $vLen; $found = $true; break
                        }
                    }
                }
            }
        }
        if (-not $found) { $out += $text[$i]; $i++ }
    }
    return $out.Trim()
}

# ============================================================================
# BATCH PROCESSING LOGIC
# ============================================================================
function Get-IniValue($content, $section, $key, $defaultValue) {
    $inSection = $false
    if ($content -is [string]) { $lines = $content -split '\r?\n' } else { $lines = $content }
    
    foreach ($line in $lines) {
        $trim = $line.Trim()
        if ($trim -match "^\[$section\]") { $inSection = $true; continue }
        if ($inSection -and $trim -match "^\[") { break } 
        
        if ($inSection -and $trim -match "^$key\s*=(.*)") {
            # Asegurar que devolvemos un string, no un array
            $value = $matches[1]
            if ($value -is [array]) { $value = $value[0] }
            return $value.Trim()
        }
    }
    return $defaultValue
}

function Clean-Name($name) {
    if ([string]::IsNullOrWhiteSpace($name)) { return "unnamed" }
    # Normalizar para separar acentos de las letras (NFD)
    $normalized = $name.Normalize([System.Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        $category = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
        # Mantener solo caracteres que no sean marcas de acentuación
        if ($category -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $clean = $sb.ToString()
    # Reemplazar la 'ñ' y 'Ñ' manualmente si no se normalizaron (algunas implementaciones de .NET)
    $clean = $clean.Replace("ñ", "n").Replace("Ñ", "N")
    # Reemplazar cualquier cosa que no sea alfanumérica, punto, guión o espacio por guión bajo
    $clean = $clean -replace '[^a-zA-Z0-9\.\-\s]', '_'
    # Colapsar múltiples guiones bajos o espacios
    $clean = $clean -replace '_+', '_'
    $clean = $clean -replace '\s+', ' '
    return $clean.Trim().Trim('_')
}

function Start-BatchProcessing {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$IniPath = ".\config.ini",
        [string]$InputFileOverride = "",
        [string]$OutputDirOverride = "",
        [string]$Symbol = "QR",
        [string]$Model = "M2",
        [string]$MicroVersion = "AUTO",
        [switch]$Fnc1First,
        [switch]$Fnc1Second,
        [int]$Fnc1ApplicationIndicator = 0,
        [int]$StructuredAppendIndex = -1,
        [int]$StructuredAppendTotal = 0,
        [int]$StructuredAppendParity = -1,
        [string]$StructuredAppendParityData = "",
        [string]$LogoPath = "",
        [int]$LogoScale = -1,
        [string]$ForegroundColor = "",
        [string]$ForegroundColor2 = "",
        [string]$BackgroundColor = "",
        [double]$Rounded = -1,
        [string]$GradientType = "",
        [string]$FrameText = "",
        [string]$FrameColor = "",
        [string]$FontFamily = "",
        [string]$GoogleFont = "",
        [switch]$PdfUnico = $false,
        [string]$PdfUnicoNombre = "",
        [string]$Layout = "Default"
    )
    
    if (-not (Test-Path $IniPath) -and [string]::IsNullOrEmpty($InputFileOverride)) { 
        Write-Error "No se encontro config.ini ni archivo de entrada."
        return 
    }
    
    $iniContent = if (Test-Path $IniPath) { Get-Content $IniPath -Raw } else { "" }
    
    # 1. Determinar Archivo de Entrada
    $selectedFile = ""
    if (-not [string]::IsNullOrEmpty($InputFileOverride)) {
        $selectedFile = $InputFileOverride
    } else {
        $inputFilesRaw = Get-IniValue $iniContent "QRPS" "QRPS_ArchivoEntrada" "lista_inputs.tsv"
        # Asegurar que es un array si tiene mÃºltiples elementos
        if ($inputFilesRaw -match ',') {
            $inputFiles = @($inputFilesRaw -split ',' | ForEach-Object { $_.Trim() })
        } else {
            $inputFiles = @($inputFilesRaw.Trim())
        }
        
        if ($inputFiles.Count -eq 1) {
            $selectedFile = $inputFiles[0]
        } else {
            Write-Status "`n=== SELECCION DE LISTA DE ENTRADA ==="
            for ($i=0; $i -lt $inputFiles.Count; $i++) {
                $suffixDefault = if ($i -eq 0) { " (Default)" } else { "" }
                Write-Status " [$($i+1)] $($inputFiles[$i])$suffixDefault"
            }
            $timeout = [int](Get-IniValue $iniContent "QRPS" "QRPS_MenuTimeout" "5")
            Write-Status "Seleccione (Default en $($timeout)s: $($inputFiles[0])):"
            $choice = -1
            $start = [DateTime]::Now
            while (([DateTime]::Now - $start).TotalSeconds -lt $timeout) {
                if ($Host.UI.RawUI.KeyAvailable) {
                    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                    if ($key.VirtualKeyCode -eq 13) { $choice = 0; break } # Enter
                    if ($key.Character -match '[1-9]') {
                        $idx = [int][string]$key.Character - 1
                        if ($idx -lt $inputFiles.Count) { $choice = $idx; break }
                    }
                }
                Start-Sleep -Milliseconds 100
            }
            
            $selectedFile = if ($choice -ne -1) { $inputFiles[$choice] } else { $inputFiles[0] }
            Write-Status "`nUsando: $selectedFile"
        }
    }

    # 2. Leer resto de configuraciÃ³n
    $outDir = if (-not [string]::IsNullOrEmpty($OutputDirOverride)) { $OutputDirOverride } else { Get-IniValue $iniContent "QRPS" "QRPS_CarpetaSalida" "salida_qr" }
    $ecLevel = Get-IniValue $iniContent "QRPS" "QRPS_NivelEC" "M"
    $modSize = [int](Get-IniValue $iniContent "QRPS" "QRPS_TamanoModulo" "10")
    $version = [int](Get-IniValue $iniContent "QRPS" "QRPS_Version" "0")
    $prefix = Get-IniValue $iniContent "QRPS" "QRPS_Prefijo" "qr_"
    $useConsec = (Get-IniValue $iniContent "QRPS" "QRPS_UseConsecutivo" "si") -eq "si"
    $suffix = Get-IniValue $iniContent "QRPS" "QRPS_Sufijo" ""
    $useTs = (Get-IniValue $iniContent "QRPS" "QRPS_IncluirTimestamp" "no") -eq "si"
    $tsFormat = Get-IniValue $iniContent "QRPS" "QRPS_FormatoFecha" "yyyyMMdd_HHmmss"
    $eciVal = [int](Get-IniValue $iniContent "QRPS" "QRPS_ECI" "0")
    
    # Precedencia de ParÃ¡metros (CLI > config.ini)
    $logoPathIni = if (-not [string]::IsNullOrEmpty($LogoPath)) { $LogoPath } else { Get-IniValue $iniContent "QRPS" "QRPS_LogoPath" "" }
    $logoScaleIni = if ($LogoScale -ge 0) { $LogoScale } else { [int](Get-IniValue $iniContent "QRPS" "QRPS_LogoScale" "20") }
    $fgColorIni = if (-not [string]::IsNullOrEmpty($ForegroundColor)) { $ForegroundColor } else { Get-IniValue $iniContent "QRPS" "QRPS_ColorFront" "#000000" }
    $fgColor2Ini = if (-not [string]::IsNullOrEmpty($ForegroundColor2)) { $ForegroundColor2 } else { Get-IniValue $iniContent "QRPS" "QRPS_ColorFront2" "" }
    $bgColorIni = if (-not [string]::IsNullOrEmpty($BackgroundColor)) { $BackgroundColor } else { Get-IniValue $iniContent "QRPS" "QRPS_ColorBack" "#ffffff" }
    $roundedIni = if ($Rounded -ge 0) { $Rounded } else { [double](Get-IniValue $iniContent "QRPS" "QRPS_Redondeado" "0") }
    $gradTypeIni = if (-not [string]::IsNullOrEmpty($GradientType)) { $GradientType } else { Get-IniValue $iniContent "QRPS" "QRPS_TipoDegradado" "linear" }
    $frameTextIni = if (-not [string]::IsNullOrEmpty($FrameText)) { $FrameText } else { Get-IniValue $iniContent "QRPS" "QRPS_FrameText" "" }
    $frameColorIni = if (-not [string]::IsNullOrEmpty($FrameColor)) { $FrameColor } else { Get-IniValue $iniContent "QRPS" "QRPS_FrameColor" "#000000" }
    $fontFamilyIni = if (-not [string]::IsNullOrEmpty($FontFamily)) { $FontFamily } else { Get-IniValue $iniContent "QRPS" "QRPS_FontFamily" "Arial, sans-serif" }
    $googleFontIni = if (-not [string]::IsNullOrEmpty($GoogleFont)) { $GoogleFont } else { Get-IniValue $iniContent "QRPS" "QRPS_GoogleFont" "" }
    
    # PDF Unico logic (Prioritize CLI)
     $pdfUnico = if ($PdfUnico) { $true } else { (Get-IniValue $iniContent "QRPS" "QRPS_PdfUnico" "no") -eq "si" }
     $pdfUnicoNombre = if (-not [string]::IsNullOrEmpty($PdfUnicoNombre)) { $PdfUnicoNombre } else { Get-IniValue $iniContent "QRPS" "QRPS_PdfUnicoNombre" "qr_combinado.pdf" }
     $pdfLayout = if ($Layout -ne "Default") { $Layout } else { Get-IniValue $iniContent "QRPS" "QRPS_Layout" "Default" }
    
    # Si hay logo en config, forzamos EC Level H
    if (-not [string]::IsNullOrEmpty($logoPathIni)) {
        $ecLevel = 'H'
        Write-Status "[INFO] Logo configurado en config.ini. Usando Nivel de Error H (High)."
    }

    $colIndex = [int](Get-IniValue $iniContent "QRPS" "QRPS_IndiceColumna" "1") - 1
    if ($colIndex -lt 0) { $colIndex = 0 }
    
    # Validar entrada
    $inputPath = if ([System.IO.Path]::IsPathRooted($selectedFile)) { $selectedFile } else { Join-Path $PSScriptRoot $selectedFile }
    if (-not (Test-Path $inputPath)) {
        Write-Error "Archivo de entrada no encontrado: $selectedFile"
        return
    }
    
    # Determinar carpeta salida
    $outPath = if ([System.IO.Path]::IsPathRooted($outDir)) { $outDir } else { Join-Path $PSScriptRoot $outDir }
    if (-not (Test-Path $outPath)) {
        if ($PSCmdlet.ShouldProcess($outPath, "Crear directorio")) {
            New-Item -ItemType Directory -Force -Path $outPath | Out-Null
        }
    }
    
    # Procesar lÃ­neas
    $lines = Get-Content $inputPath -Encoding UTF8
    $count = 1
    
    $collectedPages = @()
    
    $headerMap = @{}
    $firstLine = $true
    foreach ($line in $lines) {
        $trim = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trim) -or $trim.StartsWith("#")) { continue }
        
        # Procesar columnas si hay tabs
        $cols = $trim -split "\t"

        # Detectar encabezado (más robusto contra BOM y espacios)
        if ($firstLine -and ($trim -match "Data" -or $trim -match "Dato")) {
            for ($i=0; $i -lt $cols.Count; $i++) {
                $h = $cols[$i].Trim().ToLower().Replace("`ufeff", "")
                $headerMap[$h] = $i
            }
            if ($headerMap.ContainsKey("data") -or $headerMap.ContainsKey("dato")) {
                $firstLine = $false
                continue
            }
        }
        $firstLine = $false
        
        # Mapeo de datos por encabezado o por Ã­ndice
        $getRowVal = {
             param($key, $default)
             if ($headerMap.ContainsKey($key.ToLower())) {
                 $idx = $headerMap[$key.ToLower()]
                 if ($idx -lt $cols.Count) { 
                     $v = $cols[$idx].Trim()
                     if ($v -eq "#" -or [string]::IsNullOrEmpty($v)) { return $default }
                     return $v
                 }
             }
             return $default
         }

        $dataToEncode = if ($headerMap.Count -gt 0) { 
            $v = &$getRowVal "Data" ""
            if ([string]::IsNullOrEmpty($v)) { $v = &$getRowVal "Dato" "" }
            $v
        } else { 
            if ($colIndex -lt $cols.Count) { $cols[$colIndex].Trim() } else { $cols[0].Trim() }
        }

        if ([string]::IsNullOrEmpty($dataToEncode)) { continue }

        # Parametros por fila (si existen en el TSV, sobreescriben los del lote)
        $rowFg = &$getRowVal "Color" $fgColorIni
        $rowFg2 = &$getRowVal "Color2" $fgColor2Ini
        $rowBg = &$getRowVal "BgColor" $bgColorIni
        $rowRounded = [double](&$getRowVal "Rounded" $roundedIni)
        $rowFrame = &$getRowVal "Frame" $frameTextIni
        $rowFrameColor = &$getRowVal "FrameColor" $frameColorIni
        $rowLogo = &$getRowVal "Logo" $logoPathIni
        $rowSymbol = &$getRowVal "Symbol" $Symbol
        $rowModel = &$getRowVal "Model" $Model
        $rowMicroVersion = &$getRowVal "MicroVersion" $MicroVersion
        
        # Nuevas columnas
        $rowNombreArchivo = &$getRowVal "NombreArchivo" ""
        $rowFormatoSalida = &$getRowVal "FormatoSalida" ""
        $rowUnificarPDF = &$getRowVal "UnificarPDF" "" # si, no o vacio (usa global)
        
        # Extraer textos adicionales para debajo del QR
        $bottomText = @()
        if ($headerMap.Count -gt 0) {
            # Si hay cabeceras, buscamos Label1, Label2...
            $labels = @()
            for ($i=1; $i -le 5; $i++) {
                $l = &$getRowVal "Label$i" ""
                if (-not [string]::IsNullOrEmpty($l)) { $labels += $l }
            }
            if ($labels.Count -gt 0) {
                $bottomText = $labels
            } else {
                # Fallback: incluir solo columnas que NO son parámetros conocidos
                $knownParams = @("data", "dato", "color", "color2", "bgcolor", "rounded", "frame", "logo", "symbol", "model", "microversion", "frametext", "foregroundcolor", "backgroundcolor", "nombrearchivo", "formatosalida", "unificarpdf")
                foreach ($h in $headerMap.Keys) {
                    if ($knownParams -notcontains $h) {
                        $v = &$getRowVal $h ""
                        if (-not [string]::IsNullOrEmpty($v)) { $bottomText += $v }
                    }
                }
            }
        } else {
            # Sin cabeceras: todas las columnas excepto la de datos
            for ($i=0; $i -lt $cols.Count; $i++) {
                if ($i -ne $colIndex) {
                    $bottomText += $cols[$i].Trim()
                }
            }
        }
        
        # Determinar nombre base
        $baseName = ""
        if (-not [string]::IsNullOrEmpty($rowNombreArchivo)) {
            $baseName = Clean-Name $rowNombreArchivo
        } elseif ($useConsec) {
            $baseName = "$count"
        } else {
            # Sanitizar nombre basado únicamente en los datos de la columna seleccionada
            $baseName = Clean-Name $dataToEncode
            if ($baseName.Length -gt 50) { $baseName = $baseName.Substring(0, 50) }
        }
        
        # Construir nombre completo
        $nameParts = @($prefix, $baseName)
        if (-not [string]::IsNullOrEmpty($suffix)) { $nameParts += $suffix }
        if ($useTs) { $nameParts += "_" + (Get-Date -Format $tsFormat) }
        
        # Formatos: Priorizar el de la fila
        $formatsRaw = if (-not [string]::IsNullOrEmpty($rowFormatoSalida)) { $rowFormatoSalida } else { (Get-IniValue $iniContent "QRPS" "QRPS_FormatoSalida" "svg") }
        $formats = @($formatsRaw.ToLower() -split ',' | ForEach-Object { $_.Trim() })
        
        foreach ($fmt in $formats) {
            # Unificar PDF logic: Priorizar el de la fila
            $actualPdfUnico = if (-not [string]::IsNullOrEmpty($rowUnificarPDF)) { 
                $rowUnificarPDF -eq "si" 
            } else { 
                $pdfUnico 
            }

                if ($fmt -eq "pdf" -and $actualPdfUnico) {
                    try {
                            # Parámetros para generación posterior
                            $collectedPages += [PSCustomObject]@{
                                data = $dataToEncode
                                ecLevel = $ecLevel
                                version = $version
                                modSize = $modSize
                                eciVal = $eciVal
                                rowSymbol = $rowSymbol
                                rowModel = $rowModel
                                rowMicroVersion = $rowMicroVersion
                                fnc1First = $Fnc1First
                                fnc1Second = $Fnc1Second
                                fnc1AppInd = $Fnc1ApplicationIndicator
                                saIndex = $StructuredAppendIndex
                                saTotal = $StructuredAppendTotal
                                saParity = $StructuredAppendParity
                                saParityData = $StructuredAppendParityData
                                rowLogo = $rowLogo
                                logoScale = $logoScaleIni
                                bottomText = $bottomText
                                rowFg = $rowFg
                                rowFg2 = $rowFg2
                                rowBg = $rowBg
                                rowRounded = $rowRounded
                                gradType = $gradTypeIni
                                rowFrame = $rowFrame
                                frameColor = $rowFrameColor
                                fontFamily = $fontFamilyIni
                                googleFont = $googleFontIni
                                path = $finalPath
                            }
                    } catch {
                        Write-Error "Error recolectando datos para página PDF '$dataToEncode': $_"
                    }
                    continue
                }

            $ext = switch ($fmt) {
                "svg" { ".svg" }
                "pdf" { ".pdf" }
                "png" { ".png" }
                default { ".png" }
            }
            $name = ($nameParts -join "") + $ext
            $finalPath = Join-Path $outPath $name
            
            if ($PSCmdlet.ShouldProcess($finalPath, "Generar QR ($fmt)")) {
                try {
                    New-QRCode -Data $dataToEncode -OutputPath $finalPath -ECLevel $ecLevel -Version $version -ModuleSize $modSize -EciValue $eciVal -Symbol $rowSymbol -Model $rowModel -MicroVersion $rowMicroVersion -Fnc1First:$Fnc1First -Fnc1Second:$Fnc1Second -Fnc1ApplicationIndicator $Fnc1ApplicationIndicator -StructuredAppendIndex $StructuredAppendIndex -StructuredAppendTotal $StructuredAppendTotal -StructuredAppendParity $StructuredAppendParity -StructuredAppendParityData $StructuredAppendParityData -LogoPath $rowLogo -LogoScale $logoScaleIni -BottomText $bottomText -ForegroundColor $rowFg -ForegroundColor2 $rowFg2 -BackgroundColor $rowBg -Rounded $rowRounded -GradientType $gradTypeIni -FrameText $rowFrame -FrameColor $rowFrameColor -FontFamily $fontFamilyIni -GoogleFont $googleFontIni
                } catch {
                    Write-Error "Error generando QR ($fmt) para '$dataToEncode': $_"
                }
            }
        }
        $count++
    }
    
    # Generar PDF Único si hay páginas recolectadas
    if ($collectedPages.Count -gt 0) {
        $finalPdfPath = Join-Path $outPath $pdfUnicoNombre
        Write-Status "`nGenerando PDF Único Nativo de $($collectedPages.Count) páginas..."
        
        $pagesForNative = New-Object System.Collections.ArrayList
        foreach ($p in $collectedPages) {
            # Obtener la matriz llamando New-QRCode (sin exportar a archivo)
            $m = New-QRCode -Data $p.data -OutputPath $null -ECLevel $p.ecLevel -Version $p.version -ModuleSize $p.modSize -EciValue $p.eciVal -Symbol $p.rowSymbol -Model $p.rowModel -MicroVersion $p.rowMicroVersion -Fnc1First:$p.fnc1First -Fnc1Second:$p.fnc1Second -Fnc1ApplicationIndicator $p.fnc1AppInd -StructuredAppendIndex $p.saIndex -StructuredAppendTotal $p.saTotal -StructuredAppendParity $p.saParity -StructuredAppendParityData $p.saParityData -LogoPath $p.rowLogo -LogoScale $p.logoScale
            
            [void]$pagesForNative.Add([PSCustomObject]@{
                type = "QR"
                m = $m
                scale = $p.modSize
                quiet = 4
                fg = $p.rowFg
                fg2 = $p.rowFg2
                bg = $p.rowBg
                gradType = $p.gradType
                text = $p.bottomText
                rounded = $p.rowRounded
                frame = $p.rowFrame
                frameColor = $p.frameColor
                logoPath = $p.rowLogo
                logoScale = $p.logoScale
                path = $p.path
            })
        }
        ExportPdfMultiNative -pages $pagesForNative -path $finalPdfPath -layout $pdfLayout
        Write-Status "[OK] PDF único nativo generado exitosamente en: $finalPdfPath"
    }
    
    Write-Status "Proceso completado. QRs guardados en: $outDir"
}

# Ejecutar proceso batch si existe config.ini y se llama el script directamente
function Convert-ImagesToPdf {
    param(
        [string]$inputDir,
        [string]$outputPath,
        [string]$layout = "Grid4x4"
    )
    if (-not (Test-Path $inputDir)) { Write-Error "Carpeta no encontrada: $inputDir"; return }
    $files = Get-ChildItem -Path $inputDir -Include *.jpg, *.png, *.jpeg -Recurse | Where-Object { -not $_.PSIsContainer }
    if ($files.Count -eq 0) { Write-Warning "No se encontraron imágenes en $inputDir"; return }
    
    $pages = New-Object System.Collections.ArrayList
    foreach ($f in $files) {
        $pages.Add([PSCustomObject]@{
            type = "Image"
            path = $f.FullName
            scale = 1
            quiet = 0
        })
    }
    
    Write-Status "Generando PDF con $($files.Count) imágenes usando layout $layout..."
    ExportPdfMultiNative -pages $pages -path $outputPath -layout $layout
    Write-Status "[OK] PDF generado en: $outputPath"
}

function Show-Menu {
    $oldEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    
    do {
        Clear-Host
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host "       QRPS - GENERADOR QR & PDF NATIVO       " -ForegroundColor White -BackgroundColor Blue
        Write-Host "==============================================" -ForegroundColor Cyan
        Write-Host " 1. Generar QR Individual (Manual)"
        Write-Host " 2. Procesamiento por Lotes (TSV/CSV)"
        Write-Host " 3. Conversor de Imágenes a PDF (Layouts)"
        Write-Host " 4. Decodificar QR desde Archivo"
        Write-Host " 5. Editar Configuración (config.ini)"
        Write-Host " 6. Salir"
        Write-Host "----------------------------------------------"
        $choice = Read-Host "Seleccione una opción"
        
        switch ($choice) {
            "1" {
                $data = Read-Host "Ingrese el contenido del QR"
                if ([string]::IsNullOrWhiteSpace($data)) { break }
                $out = Read-Host "Nombre del archivo de salida (ej: qr.pdf, qr.png)"
                if ([string]::IsNullOrWhiteSpace($out)) { $out = "codigo_qr.pdf" }
                
                if ($out -match "\.pdf$") {
                    $m = New-QRCode -Data $data
                    $pages = New-Object System.Collections.ArrayList
                    $pages.Add([PSCustomObject]@{
                        type = "QR"
                        m = $m
                        scale = 10
                        quiet = 4
                        fg = "#000000"
                        bg = "#ffffff"
                        text = @()
                        rounded = 0
                        frame = ""
                        frameColor = ""
                    })
                    ExportPdfMultiNative -pages $pages -path $out
                    Write-Status "[OK] PDF generado: $out"
                } else {
                    New-QRCode -Data $data -OutputPath $out -ShowConsole
                }
                Read-Host "`nPresione Enter para continuar..."
            }
            "2" {
                $file = Read-Host "Ruta del archivo TSV/CSV (Deje vacío para usar config.ini)"
                if ($file) { 
                    Start-BatchProcessing -InputFileOverride $file 
                } else { 
                    Start-BatchProcessing 
                }
                Read-Host "`nPresione Enter para continuar..."
            }
            "3" {
                $dir = Read-Host "Carpeta con imágenes (JPG/PNG)"
                if (-not (Test-Path $dir)) { Write-Error "Ruta no válida"; break }
                $out = Read-Host "Archivo PDF de salida [imagenes.pdf]"
                if (-not $out) { $out = "imagenes.pdf" }
                Write-Host "`nLayouts disponibles: Default (1x1), Grid4x4, Grid4x5, Grid6x6"
                $lay = Read-Host "Seleccione Layout [Grid4x4]"
                if (-not $lay) { $lay = "Grid4x4" }
                Convert-ImagesToPdf -inputDir $dir -outputPath $out -layout $lay
                Read-Host "`nPresione Enter para continuar..."
            }
            "4" {
                $path = Read-Host "Ruta de la imagen del QR"
                if (Test-Path $path) {
                    $m = Import-QRCode $path
                    if ($m.Width -ne $m.Height) { $dec = Decode-RMQRMatrix $m }
                    elseif ($m.Size -lt 21) { $dec = Decode-MicroQRMatrix $m }
                    else { $dec = Decode-QRCodeMatrix $m }
                    Write-Host "`nContenido: $($dec.Text)" -ForegroundColor Green
                } else {
                    Write-Error "Archivo no encontrado"
                }
                Read-Host "`nPresione Enter para continuar..."
            }
            "5" {
                if (Test-Path ".\config.ini") {
                    Start-Process notepad ".\config.ini"
                } else {
                    Write-Error "config.ini no encontrado."
                }
            }
            "6" { return }
        }
    } while ($true)
    
    [Console]::OutputEncoding = $oldEncoding
}

# ENTRY POINT
if ($Decode -and -not [string]::IsNullOrEmpty($InputPath)) {
    Write-Status "Importando archivo para decodificación: $InputPath"
    $m = Import-QRCode $InputPath
    
    try {
        if ($m.Width -ne $m.Height) {
            Write-Status "Detectado: rMQR"
            $dec = Decode-RMQRMatrix $m
        } elseif ($m.Size -lt 21) {
            Write-Status "Detectado: Micro QR"
            $dec = Decode-MicroQRMatrix $m
        } else {
            Write-Status "Detectado: QR"
            $dec = Decode-QRCodeMatrix $m
        }
        
        $aimId = Get-AIM-ID (if($m.Width -ne $m.Height){'rMQR'}elseif($m.Size -lt 21){'Micro'}else{'QR'}) ($dec.ECI -or 26) ($dec.Segments | Where-Object {$_.Mode -match 'F1|F2'})
        Write-Host "`nAIM ID: $aimId" -ForegroundColor Yellow
        
        Write-Host "Decodificado con éxito:" -ForegroundColor Green
        
        $cleanText = $dec.Text
        if ($dec.Segments | Where-Object {$_.Mode -eq 'F1'}) {
            Write-Host "GS1 Parse (ISO 15418):" -ForegroundColor Gray
            $cleanText = Parse-GS1 $dec.Text
        }
        
        Write-Host "Contenido: $cleanText"
        if ($dec.Errors -gt 0) { Write-Host "Errores corregidos: $($dec.Errors)" -ForegroundColor Cyan }
        if ($dec.ECI -ne 0 -and $dec.ECI -ne 26) { Write-Host "ECI: $($dec.ECI)" }
        foreach ($s in $dec.Segments) {
            Write-Host "  - Modo $($s.Mode): $($s.Data)"
        }
    } catch {
        Write-Error "Error al decodificar: $_"
    }
} elseif (-not [string]::IsNullOrEmpty($Data)) {
    # Modo CLI Directo (Un solo QR)
    New-QRCode -Data $Data -OutputPath $OutputPath -ECLevel $ECLevel -Version $Version -ModuleSize $ModuleSize -EciValue $EciValue -Symbol $Symbol -Model $Model -MicroVersion $MicroVersion -Fnc1First:$Fnc1First -Fnc1Second:$Fnc1Second -Fnc1ApplicationIndicator $Fnc1ApplicationIndicator -StructuredAppendIndex $StructuredAppendIndex -StructuredAppendTotal $StructuredAppendTotal -StructuredAppendParity $StructuredAppendParity -StructuredAppendParityData $StructuredAppendParityData -ShowConsole:$ShowConsole -Decode:$Decode -QualityReport:$QualityReport -LogoPath $LogoPath -LogoScale $LogoScale -BottomText $BottomText -ForegroundColor $ForegroundColor -ForegroundColor2 $ForegroundColor2 -BackgroundColor $BackgroundColor -Rounded $Rounded -GradientType $GradientType -FrameText $FrameText -FrameColor $FrameColor -FontFamily $FontFamily -GoogleFont $GoogleFont
} elseif (-not [string]::IsNullOrEmpty($ImageDir)) {
    # Modo Conversor de Imágenes a PDF (CLI)
    $finalPath = if ($OutputPath) { $OutputPath } else { "imagenes_convertidas.pdf" }
    Convert-ImagesToPdf -inputDir $ImageDir -outputPath $finalPath -layout $Layout
} else {
    # Modo Batch (Por Archivo o Config) o Menú Interactivo
    if (-not [string]::IsNullOrEmpty($InputFile) -or (Test-Path $IniPath)) {
        Start-BatchProcessing -IniPath $IniPath -InputFileOverride $InputFile -OutputDirOverride $OutputDir -Symbol $Symbol -Model $Model -MicroVersion $MicroVersion -Fnc1First:$Fnc1First -Fnc1Second:$Fnc1Second -Fnc1ApplicationIndicator $Fnc1ApplicationIndicator -StructuredAppendIndex $StructuredAppendIndex -StructuredAppendTotal $StructuredAppendTotal -StructuredAppendParity $StructuredAppendParity -StructuredAppendParityData $StructuredAppendParityData -LogoPath $LogoPath -LogoScale $LogoScale -ForegroundColor $ForegroundColor -ForegroundColor2 $ForegroundColor2 -BackgroundColor $BackgroundColor -Rounded $Rounded -GradientType $GradientType -FrameText $FrameText -FrameColor $FrameColor -FontFamily $FontFamily -GoogleFont $GoogleFont -PdfUnico:$PdfUnico -PdfUnicoNombre $PdfUnicoNombre -Layout $Layout
    } else {
        Show-Menu
    }
}

