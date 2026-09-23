[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$LlamaCppDir,
    [Parameter(Mandatory = $true)] [string]$ModelDir
)

$ErrorActionPreference = "Stop"
$cli = Join-Path ([System.IO.Path]::GetFullPath($LlamaCppDir)) "llama-cli.exe"
$model = Join-Path ([System.IO.Path]::GetFullPath($ModelDir)) "Qwen3.6-35B-A3B-GGUF\Qwen_Qwen3.6-35B-A3B-IQ2_XXS.gguf"

if (-not (Test-Path -LiteralPath $cli)) { throw "No existe: $cli" }
if (-not (Test-Path -LiteralPath $model)) { throw "No existe: $model" }

& $cli `
    -m $model `
    -ngl auto `
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

