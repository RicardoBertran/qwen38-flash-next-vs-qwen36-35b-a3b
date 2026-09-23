[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$LlamaCppDir,
    [Parameter(Mandatory = $true)] [string]$ModelDir
)

$ErrorActionPreference = "Stop"
$cli = Join-Path ([System.IO.Path]::GetFullPath($LlamaCppDir)) "llama-cli.exe"
$model = Join-Path ([System.IO.Path]::GetFullPath($ModelDir)) "Qwen3.8-Flash-Next-GSQ-RCO-GGUF\Q2_0\Qwen3.8-Flash-Next-GSQ-RCO-Q2_0-00001-of-00002.gguf"

if (-not (Test-Path -LiteralPath $cli)) { throw "No existe: $cli" }
if (-not (Test-Path -LiteralPath $model)) { throw "No existe: $model" }

& $cli `
    -m $model `
    -lm mmap `
    --lazy-mode on `
    --fit on `
    -c 16384 `
    -n 2048 `
    -b 256 `
    -ub 128 `
    -fa on `
    -ctk q8_0 `
    -ctv q8_0 `
    --temp 0.6 `
    --top-k 20 `
    --top-p 0.95 `
    --min-p 0

