# Qwen3.8-Flash-Next vs Qwen3.6-35B-A3B en local

Material reproducible de la comparativa del vídeo de YouTube, ejecutada con `llama.cpp`/Llama UI sobre una RTX 5070 de 12 GB y 32 GB de RAM.

> Este repositorio no contiene modelos. Las cifras son mediciones de una ejecución concreta, no resultados universales.

## Resumen

Se compararon las cuantizaciones que realmente cabían y funcionaban en el equipo de prueba:

| Modelo | Cuantización usada | Tamaño aproximado | Enlace |
|---|---|---:|---|
| Qwen3.8-Flash-Next | GSQ-RCO `Q2_0`, 2 shards | 66,4 GB | [ISTA-DASLab en Hugging Face](https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF/tree/main/Q2_0) |
| Qwen3.6-35B-A3B | `IQ2_XXS` | 10,7 GB | [bartowski en Hugging Face](https://huggingface.co/bartowski/Qwen_Qwen3.6-35B-A3B-GGUF/blob/main/Qwen_Qwen3.6-35B-A3B-IQ2_XXS.gguf) |

No son modelos ni cuantizaciones equivalentes. La pregunta práctica del vídeo fue: **¿qué experiencia ofrece cada uno en el mismo PC?**

## Resultado principal

| Métrica | Qwen3.8 Flash Next | Qwen3.6 35B-A3B |
|---|---:|---:|
| Media de generación, 4 pruebas | **11,46 t/s** | **135,71 t/s** |
| Prueba larga, 2.048 tokens | **11,36 t/s** | **143,99 t/s** |
| RAM estabilizada | **~22,7 GB (71 %)** | **~21,0 GB (66 %)** |
| VRAM visible | **~11.443 MiB** | **~11.199 MiB** |
| Uso de GPU durante generación | **~24–29 %** | **~91–93 %** |

Qwen3.6 generó unas **11,8 veces más rápido de media** en las cuatro pruebas y unas **12,7 veces más rápido** en la prueba larga. Flash Next, sin embargo, siguió mejor algunas instrucciones y eligió la solución de código más eficiente en esta muestra.

Los datos completos están en [`results/resultados.csv`](results/resultados.csv) y el protocolo en [`results/metodologia.md`](results/metodologia.md).

## Condiciones

- GPU: NVIDIA GeForce RTX 5070, 12 GB de VRAM.
- RAM: 32 GB (31,9 GB utilizables observados).
- Sistema: Windows.
- `llama.cpp`: build `b11053`, commit `1af554f8f`, CUDA 13.4.
- Interfaz: Llama UI incluida en `llama-server`.
- Contexto: 16.384 tokens.
- Salida máxima: 2.048 tokens.
- KV cache: `q8_0` para K y V.
- Batch/ubatch: 256/128.
- Parallel: 1.
- Flash Attention: activado.
- Sampling: temperatura 0,6; top-k 20; top-p 0,95; min-p 0.
- MTP: desactivado en la comparativa principal.

Flash Next necesitó `mmap`, `lazy-mode` y ajuste automático para convivir con solo 32 GB de RAM. Por tanto, se igualaron contexto, caché, batch, sampling, build y hardware, pero cada modelo conservó la estrategia de carga necesaria para funcionar.

## Estructura

```text
config/
  modelos-web.ini             Presets limpios a 16K
scripts/
  download-models.ps1         Descarga las cuantizaciones exactas
  start-llama-ui.ps1          Genera un INI local y arranca Llama UI
  run-flash-cli.ps1           Ejecución directa de Flash Next
  run-qwen36-cli.ps1          Ejecución directa de Qwen3.6
prompts/
  pruebas.md                  Prompts usados en el vídeo
results/
  resultados.csv              Datos en formato reutilizable
  metodologia.md              Protocolo y lectura de resultados
docs/
  mtp.md                      Prueba MTP y motivo de exclusión
```

## 1. Descargar los modelos

Instala la CLI de Hugging Face y ejecuta:

```powershell
pip install -U "huggingface_hub[cli]"

.\scripts\download-models.ps1 -ModelDir "D:\models"
```

El script descarga únicamente:

- `Q2_0/*` de `ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF`.
- `Qwen_Qwen3.6-35B-A3B-IQ2_XXS.gguf` de `bartowski/Qwen_Qwen3.6-35B-A3B-GGUF`.

Son aproximadamente 77 GB en total. Comprueba el espacio libre antes de empezar.

## 2. Arrancar Llama UI

Descarga una build compatible de [`llama.cpp`](https://github.com/ggml-org/llama.cpp/releases) y ejecuta:

```powershell
.\scripts\start-llama-ui.ps1 `
  -LlamaCppDir "D:\apps\llama.cpp" `
  -ModelDir "D:\models"
```

Abre `http://127.0.0.1:8080/#/` y selecciona uno de estos presets:

```text
qwen38-flash-next-q2
qwen36-35b-a3b-iq2xxs
```

El servidor usa `--models-max 1`, así que mantiene un solo modelo cargado y cambia bajo demanda.

También puedes ejecutar cada modelo directamente:

```powershell
.\scripts\run-flash-cli.ps1 -LlamaCppDir "D:\apps\llama.cpp" -ModelDir "D:\models"
.\scripts\run-qwen36-cli.ps1 -LlamaCppDir "D:\apps\llama.cpp" -ModelDir "D:\models"
```

## 3. Repetir las pruebas

Los prompts exactos están en [`prompts/pruebas.md`](prompts/pruebas.md). Para cada modelo:

1. Carga el modelo y espera a que esté listo.
2. Lanza un prompt corto de calentamiento y limpia el chat.
3. Empieza cada prueba con un chat limpio.
4. No cambies sampling, contexto ni caché entre modelos.
5. Anota `Prompt t/s`, `Generation t/s`, RAM, VRAM y uso de GPU.

Para monitorizar la GPU:

```powershell
nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu --format=csv -l 1
```

La RAM se midió en Administrador de tareas → Rendimiento → Memoria, con el modelo ya cargado.

## MTP

MTP se probó por separado a 4K con un head autocontenido `Q4_K_M` y una build especial compatible. En este equipo bajó la generación de **9,7 t/s sin MTP** a **3,1 t/s con MTP**, además de reducir el procesamiento del prompt de 4,7 a 3,7 t/s.

No se incluyó en la comparativa principal porque:

- empeoró claramente el rendimiento medido;
- añadía presión de memoria en una GPU de 12 GB;
- requería una build distinta, introduciendo otra variable;
- el objetivo principal era comparar ambos modelos bajo una base común y estable.

La prueba y los comandos están documentados en [`docs/mtp.md`](docs/mtp.md).

## Notas

- En rutas de Windows se escribe `Q2_0`, `IQ2_XXS` y `q8_0`. No añadas una barra antes del guion bajo.
- Para un GGUF dividido, apunta al primer shard `00001-of-00002`; `llama.cpp` localiza el segundo automáticamente si está en la misma carpeta.
- `lazy-mode` requiere carga mediante `mmap`.
- No expongas este servidor sin autenticación a redes no confiables.

