#Requires -Version 5.1
<#
<#
.SYNOPSIS
    QR Code Generator FINAL - PowerShell Nativo 100% Funcional
.DESCRIPTION
    ImplementaciÃ³n completa siguiendo ISO/IEC 18004
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
    [ValidateSet('QR','Micro','rMQR')][string]$Symbol = 'QR',
    [ValidateSet('M1','M2')][string]$Model = 'M2',
    [ValidateSet('AUTO','M1','M2','M3','M4')][string]$MicroVersion = 'AUTO',
    [switch]$Fnc1First,
    [switch]$Fnc1Second,
    [int]$Fnc1ApplicationIndicator = 0,
    [int]$StructuredAppendIndex = -1,
    [int]$StructuredAppendTotal = 0,
    [int]$StructuredAppendParity = -1,
    [string]$StructuredAppendParityData = "",
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
        'M2' { return if ($mode -eq 'N') { 4 } else { 3 } }
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
            'N'{[void]$bits.AddRange(@(0,0,0,1))}
            'A'{[void]$bits.AddRange(@(0,0,1,0))}
            'B'{[void]$bits.AddRange(@(0,1,0,0))}
            'K'{[void]$bits.AddRange(@(1,0,0,0))}
            'ECI'{[void]$bits.AddRange(@(0,1,1,1))}
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

function Get-RMQRCountBitsMap($spec) {
    $h = $spec.H; $w = $spec.W
    $grp = $null
    if ($w -ge 99) { $grp = 'L' }
    elseif ($h -le 9) { $grp = (if ($w -ge 77) { 'M' } else { 'S' }) }
    elseif ($h -le 13) { $grp = 'M' }
    else { $grp = 'L' }
    switch ($grp) {
        'S' { return @{ N=10; A=9;  B=8;  K=8 } }
        'M' { return @{ N=12; A=11; B=16; K=10 } }
        'L' { return @{ N=14; A=13; B=16; K=12 } }
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
        $quiet
    )
    if (-not $PSCmdlet.ShouldProcess($path, "Exportar PNG")) { return }
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

function ExportPngRect {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $m,
        $path,
        $scale,
        $quiet
    )
    if (-not $PSCmdlet.ShouldProcess($path, "Exportar PNG")) { return }
    Add-Type -AssemblyName System.Drawing
    $imgW = ($m.Width + $quiet * 2) * $scale
    $imgH = ($m.Height + $quiet * 2) * $scale
    $bmp = New-Object Drawing.Bitmap $imgW, $imgH
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.Clear([Drawing.Color]::White)
    $black = [Drawing.Brushes]::Black
    for ($r = 0; $r -lt $m.Height; $r++) {
        for ($c = 0; $c -lt $m.Width; $c++) {
            if ($m.Mod["$r,$c"] -eq 1) {
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

function New-QRCode {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Data,
        [ValidateSet('L','M','Q','H')][string]$ECLevel = 'M',
        [int]$Version = 0,
        [string]$OutputPath,
        [int]$ModuleSize = 10,
        [int]$EciValue = 0,
        [ValidateSet('QR','Micro','rMQR')][string]$Symbol = 'QR',
        [ValidateSet('M1','M2')][string]$Model = 'M2',
        [ValidateSet('AUTO','M1','M2','M3','M4')][string]$MicroVersion = 'AUTO',
        [switch]$Fnc1First,
        [switch]$Fnc1Second,
        [int]$Fnc1ApplicationIndicator = 0,
        [int]$StructuredAppendIndex = -1,
        [int]$StructuredAppendTotal = 0,
        [int]$StructuredAppendParity = -1,
        [string]$StructuredAppendParityData = "",
        [switch]$ShowConsole
    )
    
    $sw = [Diagnostics.Stopwatch]::StartNew()
    
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
        if ($ShowConsole) { ShowConsole $final }
        if ($OutputPath -and $PSCmdlet.ShouldProcess($OutputPath, "Exportar PNG")) {
            ExportPng $final $OutputPath $ModuleSize 2
            Write-Status "Guardado: $OutputPath"
        }
        return $final
    }
    
    if ($Symbol -eq 'rMQR') {
        if ($ECLevel -ne 'M' -and $ECLevel -ne 'H') { throw "rMQR solo admite ECLevel 'M' o 'H'" }
        $ecUse = $ECLevel
        $ordered = ($script:RMQR_SPEC.GetEnumerator() | Sort-Object { $_.Value.H } , { $_.Value.W })
        $chosenKey = $null
        foreach ($kv in $ordered) {
            $ver = $kv.Key; $spec = $kv.Value
            $de = if ($ecUse -eq 'H') { $spec.H2 } else { $spec.M }
            $capBitsDataTmp = $de.D * 8
            $probe = RMQREncode $Data $spec $ecUse
            if ($probe.Count -le $de.D) { $chosenKey = $ver; break }
        }
        if (-not $chosenKey) { throw "Datos muy largos para rMQR" }
        $spec = $script:RMQR_SPEC[$chosenKey]
        $h = $spec.H; $w = $spec.W
        $m = @{}
        $m.Height = $h; $m.Width = $w; $m.Mod=@{}; $m.Func=@{}
        for ($r = 0; $r -lt $h; $r++) { for ($c = 0; $c -lt $w; $c++) { $m.Mod["$r,$c"]=0; $m.Func["$r,$c"]=$false } }
        for ($dy = -1; $dy -le 7; $dy++) { for ($dx = -1; $dx -le 7; $dx++) { $rr = 0 + $dy; $cc = 0 + $dx; if ($rr -lt 0 -or $cc -lt 0 -or $rr -ge $h -or $cc -ge $w) { continue } $in = $dy -ge 0 -and $dy -le 6 -and $dx -ge 0 -and $dx -le 6; if (-not $in) { $m.Func["$rr,$cc"]=$true; $m.Mod["$rr,$cc"]=0; continue } $on = $dy -eq 0 -or $dy -eq 6 -or $dx -eq 0 -or $dx -eq 6; $cent = $dy -ge 2 -and $dy -le 4 -and $dx -ge 2 -and $dx -le 4; $m.Func["$rr,$cc"]=$true; $m.Mod["$rr,$cc"]=([int]($on -or $cent)) } }
        for ($dy = -1; $dy -le 7; $dy++) { for ($dx = -1; $dx -le 7; $dx++) { $rr = ($h - 7) + $dy; $cc = ($w - 7) + $dx; if ($rr -lt 0 -or $cc -lt 0 -or $rr -ge $h -or $cc -ge $w) { continue } $in = $dy -ge 0 -and $dy -le 6 -and $dx -ge 0 -and $dx -le 6; if (-not $in) { $m.Func["$rr,$cc"]=$true; $m.Mod["$rr,$cc"]=0; continue } $on = $dy -eq 0 -or $dy -eq 6 -or $dx -eq 0 -or $dx -eq 6; $cent = $dy -ge 2 -and $dy -le 4 -and $dx -ge 2 -and $dx -le 4; $m.Func["$rr,$cc"]=$true; $m.Mod["$rr,$cc"]=([int]($on -or $cent)) } }
        for ($c = 7; $c -lt $w; $c++) { $v = ($c % 2) -eq 0; if (-not $m.Func["6,$c"]) { $m.Func["6,$c"]=$true; $m.Mod["6,$c"]=[int]$v } }
        for ($r = 7; $r -lt $h; $r++) { $v = ($r % 2) -eq 0; if (-not $m.Func["$r,6"]) { $m.Func["$r,6"]=$true; $m.Mod["$r,6"]=[int]$v } }
        $de = if ($ecUse -eq 'H') { $spec.H2 } else { $spec.M }
        $capacityBits = $de.D * 8
        $dataCW = RMQREncode $Data $spec $ecUse
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
                $dLen = $baseData + (if ($bix -lt $remData) { 1 } else { 0 })
                $chunk = if ($dLen -gt 0) { $dataCW[$start..($start+$dLen-1)] } else { @() }
                $start += $dLen
                $eLen = $baseEC + (if ($bix -lt $remEC) { 1 } else { 0 })
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
        for ($i=0;$i -lt 9;$i++){
            $m.Func["7,$i"]=$true; $m.Mod["7,$i"]=$fmtTL[$i]
        }
        for ($i=9;$i -lt 18;$i++){
            $m.Func["$($i-9),7"]=$true; $m.Mod["$($i-9),7"]=$fmtTL[$i]
        }
        for ($i=0;$i -lt 9;$i++){
            $m.Func["$($h-8),$($w-1-$i)"]=$true; $m.Mod["$($h-8),$($w-1-$i)"]=$fmtBR[$i]
        }
        for ($i=9;$i -lt 18;$i++){
            $m.Func["$($h-1-($i-9)),$($w-8)"]=$true; $m.Mod["$($h-1-($i-9)),$($w-8)"]=$fmtBR[$i]
        }
        Write-Status "Version: R$h`x$w"
        Write-Status "EC: $ecUse"
        $cap = $script:RMQR_CAP[$chosenKey][$ecUse]
        Write-Status "Capacidades (aprox) N/A/B/K: $($cap.N)/$($cap.A)/$($cap.B)/$($cap.K)"
        $sw.Stop()
        if ($ShowConsole) {
            ShowConsoleRect $m
        }
        if ($OutputPath -and $PSCmdlet.ShouldProcess($OutputPath, "Exportar PNG")) {
            ExportPngRect $m $OutputPath $ModuleSize 4
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
    if ($OutputPath -and $PSCmdlet.ShouldProcess($OutputPath, "Exportar PNG")) {
        ExportPng $final $OutputPath $ModuleSize 4
        Write-Status "Guardado: $OutputPath"
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
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$IniPath = ".\config.ini",
        [string]$InputFileOverride = "",
        [string]$OutputDirOverride = "",
        [ValidateSet('QR','Micro','rMQR')][string]$Symbol = 'QR',
        [ValidateSet('M1','M2')][string]$Model = 'M2',
        [ValidateSet('AUTO','M1','M2','M3','M4')][string]$MicroVersion = 'AUTO',
        [switch]$Fnc1First,
        [switch]$Fnc1Second,
        [int]$Fnc1ApplicationIndicator = 0,
        [int]$StructuredAppendIndex = -1,
        [int]$StructuredAppendTotal = 0,
        [int]$StructuredAppendParity = -1,
        [string]$StructuredAppendParityData = ""
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
                $prefixMenu = if ($i -eq 0) { " [ENTER/1]" } else { " [$($i+1)]" }
                Write-Status "$prefixMenu $($inputFiles[$i])"
            }
            Write-Status "Seleccione (Default en 5s: $($inputFiles[0])):"
            
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
            # Sanitizar nombre basado Ãºnicamente en los datos de la columna seleccionada
            $baseName = $dataToEncode -replace '[^a-zA-Z0-9]', '_'
            if ($baseName.Length -gt 30) { $baseName = $baseName.Substring(0, 30) }
        }
        
        # Construir nombre completo
        $nameParts = @($prefix, $baseName)
        if (-not [string]::IsNullOrEmpty($suffix)) { $nameParts += $suffix }
        if ($useTs) { $nameParts += "_" + (Get-Date -Format $tsFormat) }
        
        $name = ($nameParts -join "") + ".png"
        
        $finalPath = Join-Path $outPath $name
        
        if ($PSCmdlet.ShouldProcess($finalPath, "Generar QR")) {
            try {
                New-QRCode -Data $dataToEncode -OutputPath $finalPath -ECLevel $ecLevel -Version $version -ModuleSize $modSize -EciValue $eciVal -Symbol $Symbol -Model $Model -MicroVersion $MicroVersion -Fnc1First:$Fnc1First -Fnc1Second:$Fnc1Second -Fnc1ApplicationIndicator $Fnc1ApplicationIndicator -StructuredAppendIndex $StructuredAppendIndex -StructuredAppendTotal $StructuredAppendTotal -StructuredAppendParity $StructuredAppendParity -StructuredAppendParityData $StructuredAppendParityData
            } catch {
                Write-Error "Error generando QR para '$dataToEncode': $_"
            }
        }
        $count++
    }
    
    Write-Status "Proceso completado. QRs guardados en: $outDir"
}

# Ejecutar proceso batch si existe config.ini y se llama el script directamente
# ENTRY POINT
if (-not [string]::IsNullOrEmpty($Data)) {
    # Modo CLI Directo (Un solo QR)
    New-QRCode -Data $Data -OutputPath $OutputPath -ECLevel $ECLevel -Version $Version -ModuleSize $ModuleSize -EciValue $EciValue -Symbol $Symbol -Model $Model -MicroVersion $MicroVersion -Fnc1First:$Fnc1First -Fnc1Second:$Fnc1Second -Fnc1ApplicationIndicator $Fnc1ApplicationIndicator -StructuredAppendIndex $StructuredAppendIndex -StructuredAppendTotal $StructuredAppendTotal -StructuredAppendParity $StructuredAppendParity -StructuredAppendParityData $StructuredAppendParityData -ShowConsole:$ShowConsole
} else {
    # Modo Batch (Por Archivo o Config)
    if (-not [string]::IsNullOrEmpty($InputFile) -or (Test-Path $IniPath)) {
        Start-BatchProcessing -IniPath $IniPath -InputFileOverride $InputFile -OutputDirOverride $OutputDir -Symbol $Symbol -Model $Model -MicroVersion $MicroVersion -Fnc1First:$Fnc1First -Fnc1Second:$Fnc1Second -Fnc1ApplicationIndicator $Fnc1ApplicationIndicator -StructuredAppendIndex $StructuredAppendIndex -StructuredAppendTotal $StructuredAppendTotal -StructuredAppendParity $StructuredAppendParity -StructuredAppendParityData $StructuredAppendParityData
    } else {
        Write-Status "`n  [QR] QR Generator FINAL - PowerShell Nativo`n"
        Write-Status "  Uso CLI QR:      .\QRCode.ps1 -Data 'Texto' -OutputPath 'out.png'"
        Write-Status "  Uso CLI Batch:   .\QRCode.ps1 -InputFile 'lista.tsv' -OutputDir 'resultados'"
        Write-Status "  Uso Automatico:  Crear config.ini y ejecutar .\QRCode.ps1"
    }
}

