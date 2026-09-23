# Metodología y lectura de resultados

## Protocolo

1. Misma máquina, build de `llama.cpp`, contexto de 16K, KV `q8_0`, batch 256/128, sampling y límite de salida.
2. Un solo modelo cargado a la vez mediante `--models-max 1`.
3. Espera hasta completar la carga; el cold start no se mezcla con los tokens por segundo.
4. Prompt de calentamiento, chat limpio y ejecución grabada.
5. Los cuatro prompts funcionales se repiten literalmente en ambos modelos.
6. La prueba larga se detiene al alcanzar `n-predict = 2048` en ambos casos.
7. VRAM y uso de GPU se observan con `nvidia-smi`; RAM con el Administrador de tareas.

## Qué se igualó

- Hardware y sistema.
- Build principal: b11053 / commit 1af554f8f.
- Contexto, salida máxima, KV cache, batch, parallel y Flash Attention.
- Temperatura, top-k, top-p, min-p y penalizaciones.
- Prompts y orden de medición.

## Qué no se pudo igualar

- Tamaño y arquitectura de los modelos.
- Método de cuantización: GSQ-RCO `Q2_0` frente a `IQ2_XXS`.
- Estrategia de carga: Flash Next necesitó `mmap + lazy-mode + fit`; Qwen3.6 usó offload automático.
- El primer contador de prompt de la prueba MoE no fue comparable por diferencias de caché/chat template, así que se excluyó de la media de procesamiento de entrada.

## Observaciones cualitativas

- **MoE:** ambos explicaron el concepto; Flash respetó mejor la concisión solicitada.
- **Razonamiento:** ambos obtuvieron 96 €, aunque Qwen3.6 tuvo un desliz de redacción.
- **Instrucciones:** ambos respetaron el formato; Flash dio una muestra más limpia.
- **Código:** ambos resolvieron la tarea. Flash eligió directamente `heapq.nlargest`, apropiado para obtener solo cinco máximos; Qwen3.6 ordenó la colección completa y después sugirió la alternativa más eficiente.

## Interpretación prudente

La VRAM quedó casi llena con ambos modelos, pero la utilización de GPU fue muy diferente. Eso es compatible con un cuello de botella fuera del cómputo puro de la GPU para Flash Next —movimiento/acceso a pesos, RAM y CPU—, pero esta medición por sí sola no demuestra una causa única.

Estas cifras describen este hardware, build, cuantización y conjunto pequeño de prompts. No deben interpretarse como un benchmark general de calidad de los modelos base.

