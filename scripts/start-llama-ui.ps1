[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LlamaCppDir,

    [Parameter(Mandatory = $true)]
    [string]$ModelDir,

    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"

$llamaRoot = [System.IO.Path]::GetFullPath($LlamaCppDir)
$modelRoot = [System.IO.Path]::GetFullPath($ModelDir).TrimEnd('\')
$server = Join-Path $llamaRoot "llama-server.exe"
$repoRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $repoRoot "config\modelos-web.ini"
$generatedDir = Join-Path $repoRoot ".generated"
$generatedIni = Join-Path $generatedDir "modelos-web.local.ini"

if (-not (Test-Path -LiteralPath $server)) { throw "No existe: $server" }
if (-not (Test-Path -LiteralPath $template)) { throw "No existe: $template" }

$requiredFiles = @(
    (Join-Path $modelRoot "Qwen3.8-Flash-Next-GSQ-RCO-GGUF\Q2_0\Qwen3.8-Flash-Next-GSQ-RCO-Q2_0-00001-of-00002.gguf"),
    (Join-Path $modelRoot "Qwen3.8-Flash-Next-GSQ-RCO-GGUF\Q2_0\Qwen3.8-Flash-Next-GSQ-RCO-Q2_0-00002-of-00002.gguf"),
    (Join-Path $modelRoot "Qwen3.6-35B-A3B-GGUF\Qwen_Qwen3.6-35B-A3B-IQ2_XXS.gguf")
)

$missing = $requiredFiles | Where-Object { -not (Test-Path -LiteralPath $_) }
if ($missing) {
    throw "Faltan archivos de modelo:`n$($missing -join "`n")"
}

New-Item -ItemType Directory -Force -Path $generatedDir | Out-Null
$content = Get-Content -LiteralPath $template -Raw
$content = $content.Replace("__MODEL_DIR__", $modelRoot)
Set-Content -LiteralPath $generatedIni -Value $content -Encoding utf8

Write-Host "Llama UI: http://127.0.0.1:$Port/#/"
Write-Host "Preset: $generatedIni"

Push-Location $llamaRoot
try {
    & $server `
        --models-preset $generatedIni `
        --models-max 1 `
        --host 127.0.0.1 `
        --port $Port
}
finally {
    Pop-Location
}

