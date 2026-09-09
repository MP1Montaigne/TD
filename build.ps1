param([string]$Target = 'all')

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot
$PdfDirectory = Join-Path $ProjectRoot 'pdf'
$AuxDirectory = Join-Path $ProjectRoot 'build'

$LatexCommand = Get-Command pdflatex -ErrorAction SilentlyContinue
if ($LatexCommand) {
    $Latex = $LatexCommand.Source
}
elseif ($env:LOCALAPPDATA) {
    $MiKTeXBin = Join-Path $env:LOCALAPPDATA 'Programs\MiKTeX\miktex\bin\x64'
    $Latex = Join-Path $MiKTeXBin 'pdflatex.exe'
}

if (-not $Latex -or -not (Test-Path -LiteralPath $Latex)) {
    throw "pdflatex est introuvable. Installez MiKTeX/TeX Live puis relancez ce script."
}

New-Item -ItemType Directory -Path $PdfDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $AuxDirectory -Force | Out-Null

function Build-Document {
    param([string]$Source, [string]$OutputName)

    Push-Location $ProjectRoot
    try {
        & $Latex -interaction=nonstopmode -halt-on-error "-output-directory=$AuxDirectory" $Source
        if ($LASTEXITCODE -ne 0) { throw "Échec de la première compilation de $Source." }
        & $Latex -interaction=nonstopmode -halt-on-error "-output-directory=$AuxDirectory" $Source
        if ($LASTEXITCODE -ne 0) { throw "Échec de la seconde compilation de $Source." }

        $SourceLeaf = Split-Path $Source -Leaf
        $SourceStem = $SourceLeaf -replace '\.tex$', ''
        $GeneratedPdf = Join-Path $AuxDirectory ($SourceStem + '.pdf')
        Copy-Item -LiteralPath $GeneratedPdf -Destination (Join-Path $PdfDirectory $OutputName) -Force
    }
    finally {
        Pop-Location
    }
}

$TdSources = Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'td') -Filter 'td*.tex' |
    Where-Object { $_.Name -match '^td\d+\.tex$' } |
    Sort-Object Name

if ($Target -eq 'all') {
    foreach ($TdSource in $TdSources) {
        $Stem = $TdSource.BaseName.ToUpper()
        $Number = $Stem.Substring(2)
        Build-Document -Source ('td/' + $TdSource.Name) -OutputName ("TD-$Number.pdf")
    }
}
elseif ($Target -match '^td\d+$') {
    $RequestedSource = Join-Path $ProjectRoot ("td/$Target.tex")
    if (-not (Test-Path -LiteralPath $RequestedSource)) {
        throw "Séance inconnue : $Target"
    }
    $Number = $Target.Substring(2)
    Build-Document -Source ("td/$Target.tex") -OutputName ("TD-$Number.pdf")
}
elseif ($Target -ne 'recueil') {
    throw "Cible inconnue : $Target (utilisez all, recueil ou tdXX)."
}

if ($Target -in @('recueil', 'all')) {
    Build-Document -Source 'recueil.tex' -OutputName 'Recueil-TD.pdf'
}

Write-Host "PDF générés dans $PdfDirectory"
