#Requires -Version 5.1
<#
<#
.SYNOPSIS
    QR Code Generator FINAL - PowerShell Nativo 100% Funcional
.DESCRIPTION
    Implementación completa siguiendo ISO/IEC 18004
    Genera QR codes escaneables
#>
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)][string]$Data,
    [Parameter(Mandatory=$false)][string]$InputFile,
    [Parameter(Mandatory=$false)][string]$OutputDir,
    [Parameter(Mandatory=$false)][string]$IniPath = ".\config.ini",
    [string]$OutputPath = "",
    [ValidateSet('L','M','Q','H')][string]$ECLevel = 'M',
    [int]$Version = 0,
    [int]$ModuleSize = 10,
    [int]$EciValue = 0,
    [switch]$ShowConsole
)

# GF(256) lookup tables
$script:EXP = @(1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1)
$script:LOG = @(0,0,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175)

function GFMul($a,$b) { if($a -eq 0 -or $b -eq 0){return 0}; $s=$script:LOG[$a]+$script:LOG[$b]; if($s -ge 255){$s-=255}; return $script:EXP[$s] }

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

function Get-Segments($txt) {
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

function InitM($ver) {
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
    
    if ($ver -ge 2 -and $script:ALIGN[$ver]) {
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

function ExportPng($m, $path, $scale, $quiet) {
    Add-Type -AssemblyName System.Drawing
    
    $img = ($m.Size + $quiet * 2) * $scale
    $bmp = New-Object Drawing.Bitmap $img, $img
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.Clear([Drawing.Color]::White)
    
    $black = [Drawing.Brushes]::Black
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        for ($c = 0; $c -lt $m.Size; $c++) {
            if ((GetM $m $r $c) -eq 1) {
                $x = ($c + $quiet) * $scale
                $y = ($r + $quiet) * $scale
                $g.FillRectangle($black, $x, $y, $scale, $scale)
            }
        }
    }
    
    $g.Dispose()
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function ShowConsole($m) {
    Write-Host ""
    $border = [string]::new([char]0x2588, ($m.Size + 2) * 2)
    Write-Host "  $border"
    
    for ($r = 0; $r -lt $m.Size; $r++) {
        $line = "  " + [char]0x2588 + [char]0x2588
        for ($c = 0; $c -lt $m.Size; $c++) {
            $line += if ((GetM $m $r $c) -eq 1) { "  " } else { [string]::new([char]0x2588, 2) }
        }
        Write-Host "$line$([char]0x2588)$([char]0x2588)"
    }
    
    Write-Host "  $border"
    Write-Host ""
}

function New-QRCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Data,
        [ValidateSet('L','M','Q','H')][string]$ECLevel = 'M',
        [int]$Version = 0,
        [string]$OutputPath,
        [int]$ModuleSize = 10,
        [int]$EciValue = 0,
        [switch]$ShowConsole
    )
    
    $sw = [Diagnostics.Stopwatch]::StartNew()
    
    # 1. Segment Data
    $segments = Get-Segments $Data
    
    if ($EciValue -gt 0) {
        $segments = @(@{Mode='ECI'; Data="$EciValue"}) + $segments
    } else {
        $needsUtf8 = $false
        foreach ($seg in $segments) {
            if ($seg.Mode -eq 'B' -and $seg.Data -match '[^ -~]') { $needsUtf8 = $true; break }
        }
        if ($needsUtf8) {
            $segments = @(@{Mode='ECI'; Data="26"}) + $segments
        }
    }
    
    # Display Segments info
    $modesStr = ($segments | ForEach-Object { $_.Mode }) -join "+"
    Write-Host "Modos: $modesStr" -ForegroundColor Cyan
    
    # 2. Determine Version
    if ($Version -eq 0) {
        # Try versions 1 to 40
        for ($v = 1; $v -le 40; $v++) {
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
        
        if ($Version -eq 0) { throw "Datos muy largos (max soportado: Version 40)" }
    }
    
    Write-Host "Version: $Version ($(GetSize $Version)x$(GetSize $Version))" -ForegroundColor Cyan
    Write-Host "EC: $ECLevel" -ForegroundColor Cyan
    
    Write-Host "Codificando..." -ForegroundColor Yellow
    $dataCW = Encode $segments $Version $ECLevel
    
    Write-Host "Reed-Solomon..." -ForegroundColor Yellow
    $allCW = BuildCW $dataCW $Version $ECLevel
    
    Write-Host "Matriz..." -ForegroundColor Yellow
    $matrix = InitM $Version
    
    Write-Host "Datos..." -ForegroundColor Yellow
    PlaceData $matrix $allCW
    
    Write-Host "Mascaras..." -ForegroundColor Yellow
    $mask = FindBestMask $matrix
    Write-Host "Mascara: $mask" -ForegroundColor Cyan
    
    $final = ApplyMask $matrix $mask
    AddFormat $final $ECLevel $mask
    
    $sw.Stop()
    Write-Host "Tiempo: $($sw.ElapsedMilliseconds)ms" -ForegroundColor Green
    
    if ($ShowConsole) { ShowConsole $final }
    if ($OutputPath) {
        ExportPng $final $OutputPath $ModuleSize 4
        Write-Host "Guardado: $OutputPath" -ForegroundColor Green
    }
    
    return $final
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

function Start-BatchProcessing {
    param(
        [string]$IniPath = ".\config.ini",
        [string]$InputFileOverride = "",
        [string]$OutputDirOverride = ""
    )
    
    if (-not (Test-Path $IniPath) -and [string]::IsNullOrEmpty($InputFileOverride)) { 
        Write-Host "No se encontro config.ini ni archivo de entrada." -ForegroundColor Red
        return 
    }
    
    $iniContent = if (Test-Path $IniPath) { Get-Content $IniPath -Raw } else { "" }
    
    # 1. Determinar Archivo de Entrada
    $selectedFile = ""
    if (-not [string]::IsNullOrEmpty($InputFileOverride)) {
        $selectedFile = $InputFileOverride
    } else {
        $inputFilesRaw = Get-IniValue $iniContent "QRPS" "QRPS_ArchivoEntrada" "lista_inputs.tsv"
        # Asegurar que es un array si tiene múltiples elementos
        if ($inputFilesRaw -match ',') {
            $inputFiles = @($inputFilesRaw -split ',' | ForEach-Object { $_.Trim() })
        } else {
            $inputFiles = @($inputFilesRaw.Trim())
        }
        
        if ($inputFiles.Count -eq 1) {
            $selectedFile = $inputFiles[0]
        } else {
            Write-Host "`n=== SELECCION DE LISTA DE ENTRADA ===" -ForegroundColor Cyan
            for ($i=0; $i -lt $inputFiles.Count; $i++) {
                $prefixMenu = if ($i -eq 0) { " [ENTER/1]" } else { " [$($i+1)]" }
                Write-Host "$prefixMenu $($inputFiles[$i])"
            }
            Write-Host "Seleccione (Default en 5s: $($inputFiles[0])): " -NoNewline -ForegroundColor Yellow
            
            $timeout = 5
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
            Write-Host "`nUsando: $selectedFile" -ForegroundColor Cyan
        }
    }

    # 2. Leer resto de configuración
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
    $colIndex = [int](Get-IniValue $iniContent "QRPS" "QRPS_IndiceColumna" "1") - 1
    if ($colIndex -lt 0) { $colIndex = 0 }
    
    # Validar entrada
    $inputPath = if ([System.IO.Path]::IsPathRooted($selectedFile)) { $selectedFile } else { Join-Path $PSScriptRoot $selectedFile }
    if (-not (Test-Path $inputPath)) {
        Write-Host "Archivo de entrada no encontrado: $selectedFile" -ForegroundColor Red
        return
    }
    
    # Determinar carpeta salida
    $outPath = if ([System.IO.Path]::IsPathRooted($outDir)) { $outDir } else { Join-Path $PSScriptRoot $outDir }
    if (-not (Test-Path $outPath)) {
        New-Item -ItemType Directory -Force -Path $outPath | Out-Null
    }
    
    # Procesar líneas
    $lines = Get-Content $inputPath -Encoding UTF8
    $count = 1
    
    foreach ($line in $lines) {
        $trim = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trim) -or $trim.StartsWith("#")) { continue }
        
        # Procesar columnas si hay tabs
        $cols = $trim -split "\t"
        $dataToEncode = if ($colIndex -lt $cols.Count) { $cols[$colIndex].Trim() } else { $cols[0].Trim() }
        
        # Determinar nombre base
        $baseName = ""
        if ($useConsec) {
            $baseName = "$count"
        } else {
            # Sanitizar nombre basado únicamente en los datos de la columna seleccionada
            $baseName = $dataToEncode -replace '[^a-zA-Z0-9]', '_'
            if ($baseName.Length -gt 30) { $baseName = $baseName.Substring(0, 30) }
        }
        
        # Construir nombre completo
        $nameParts = @($prefix, $baseName)
        if (-not [string]::IsNullOrEmpty($suffix)) { $nameParts += $suffix }
        if ($useTs) { $nameParts += "_" + (Get-Date -Format $tsFormat) }
        
        $name = ($nameParts -join "") + ".png"
        
        $finalPath = Join-Path $outPath $name
        
        try {
            New-QRCode -Data $dataToEncode -OutputPath $finalPath -ECLevel $ecLevel -Version $version -ModuleSize $modSize -EciValue $eciVal
        } catch {
            Write-Host "Error generando QR para '$dataToEncode': $_" -ForegroundColor Red
        }
        $count++
    }
    
    Write-Host "Proceso completado. QRs guardados en: $outDir" -ForegroundColor Green
}

# Ejecutar proceso batch si existe config.ini y se llama el script directamente
# ENTRY POINT
if (-not [string]::IsNullOrEmpty($Data)) {
    # Modo CLI Directo (Un solo QR)
    New-QRCode -Data $Data -OutputPath $OutputPath -ECLevel $ECLevel -Version $Version -ModuleSize $ModuleSize -EciValue $EciValue -ShowConsole:$ShowConsole
} else {
    # Modo Batch (Por Archivo o Config)
    if (-not [string]::IsNullOrEmpty($InputFile) -or (Test-Path $IniPath)) {
        Start-BatchProcessing -IniPath $IniPath -InputFileOverride $InputFile -OutputDirOverride $OutputDir
    } else {
        Write-Host "`n  [QR] QR Generator FINAL - PowerShell Nativo`n" -ForegroundColor Magenta
        Write-Host "  Uso CLI QR:      .\QRCode.ps1 -Data 'Texto' -OutputPath 'out.png'"
        Write-Host "  Uso CLI Batch:   .\QRCode.ps1 -InputFile 'lista.tsv' -OutputDir 'resultados'"
        Write-Host "  Uso Automatico:  Crear config.ini y ejecutar .\QRCode.ps1"
    }
}
