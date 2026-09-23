# MTP: prueba separada y motivo de exclusión

## Qué se probó

MTP (Multi-Token Prediction) usa un head de borrador que propone varios tokens y deja que el modelo principal los verifique. Para Flash Next se ensayaron heads del repositorio [`unsloth/Qwen3.8-Flash-Next-GGUF`](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF/tree/main/MTP).

El head `shared-Q8_0` no llegó a funcionar en el entorno inicial por el mecanismo de tensores compartidos. La prueba que sí arrancó utilizó el head autocontenido:

```text
MTP/mtp-Qwen3.8-Flash-Next-Q4_K_M.gguf
```

y una build especial de Unsloth, identificada durante la prueba como:

```text
0.4.0-dev, build 10830, commit 0cd7a79f5
```

## Descarga opcional

MTP no es necesario para reproducir el vídeo principal. Si aun así quieres repetir el ensayo:

```powershell
hf download unsloth/Qwen3.8-Flash-Next-GGUF `
  "MTP/mtp-Qwen3.8-Flash-Next-Q4_K_M.gguf" `
  --local-dir "D:\models\Qwen3.8-Flash-Next-MTP"
```

Necesitas una build compatible con el MTP específico de Qwen3.8-Flash-Next; una build stock que muestre opciones genéricas de `draft-mtp` no garantiza compatibilidad con este head.

## Comando ensayado a 4K

```powershell
.\llama-cli.exe `
  -m "D:\models\Qwen3.8-Flash-Next-GSQ-RCO-GGUF\Q2_0\Qwen3.8-Flash-Next-GSQ-RCO-Q2_0-00001-of-00002.gguf" `
  -md "D:\models\Qwen3.8-Flash-Next-MTP\MTP\mtp-Qwen3.8-Flash-Next-Q4_K_M.gguf" `
  -lm mmap `
  --lazy-mode on `
  --fit on `
  --spec-type draft-mtp `
  --spec-draft-n-max 2 `
  --spec-draft-n-min 1 `
  -c 4096 `
  -ctk q8_0 `
  -ctv q8_0
```

## Resultado

| Configuración de Flash Next | Prompt | Generación |
|---|---:|---:|
| 4K sin MTP | 4,7 t/s | 9,7 t/s |
| 4K + MTP `Q4_K_M` | 3,7 t/s | 3,1 t/s |

En este equipo, MTP redujo la generación aproximadamente un 68 %. La explicación más plausible es que la presión adicional de memoria y el coste de generar/verificar borradores superaron cualquier ganancia, posiblemente desplazando más trabajo fuera de la GPU. Es una inferencia coherente con las mediciones, no una causa demostrada de forma aislada.

## Por qué quedó fuera del benchmark principal

- Fue más lento en la prueba real.
- Requirió una build distinta de la usada con Qwen3.6.
- Añadió una optimización exclusiva de un modelo.
- La comparativa principal buscaba una base común, estable y reproducible a 16K.

MTP puede rendir de forma diferente con más VRAM, otra build, otro head o un tipo de carga distinto. Este resultado no invalida la técnica; solo documenta que no compensó en la RTX 5070 de 12 GB usada para el vídeo.

