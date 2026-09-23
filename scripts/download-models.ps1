[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModelDir
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command hf -ErrorAction SilentlyContinue)) {
    throw "No se encuentra 'hf'. Instala la CLI con: pip install -U `"huggingface_hub[cli]`""
}

$root = [System.IO.Path]::GetFullPath($ModelDir)
$flashDir = Join-Path $root "Qwen3.8-Flash-Next-GSQ-RCO-GGUF"
$qwen36Dir = Join-Path $root "Qwen3.6-35B-A3B-GGUF"

New-Item -ItemType Directory -Force -Path $flashDir, $qwen36Dir | Out-Null

Write-Host "Descargando Qwen3.8-Flash-Next GSQ-RCO Q2_0 (2 shards, ~66,4 GB)..."
& hf download "ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF" `
    --include "Q2_0/*" `
    --local-dir $flashDir
if ($LASTEXITCODE -ne 0) { throw "Falló la descarga de Qwen3.8-Flash-Next." }

Write-Host "Descargando Qwen3.6-35B-A3B IQ2_XXS (~10,7 GB)..."
& hf download "bartowski/Qwen_Qwen3.6-35B-A3B-GGUF" `
    "Qwen_Qwen3.6-35B-A3B-IQ2_XXS.gguf" `
    --local-dir $qwen36Dir
if ($LASTEXITCODE -ne 0) { throw "Falló la descarga de Qwen3.6-35B-A3B." }

Write-Host "Descargas terminadas en: $root"

