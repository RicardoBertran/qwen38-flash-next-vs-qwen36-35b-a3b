# Prompts de la comparativa

Usar un chat limpio para cada prueba y el mismo prompt, sin modificaciones, en ambos modelos.

## 1. Explicación de MoE

```text
Explícame en tres frases qué es un modelo Mixture of Experts y por qué puede ser más eficiente que un modelo denso.
```

## 2. Razonamiento

```text
Una tienda aplica primero un descuento del 20% y después sube el precio resultante un 20%. Si el precio inicial era de 100 euros, ¿cuál es el precio final? Explica por qué no vuelve a 100.
```

## 3. Seguimiento de instrucciones

```text
Explica qué es la cuantización de modelos de IA. Máximo 120 palabras. Usa exactamente 4 puntos numerados. No uses tablas ni introducción.
```

## 4. Código Python

```text
Escribe una función en Python que reciba una lista de archivos con su tamaño en bytes y devuelva los 5 archivos más grandes ordenados de mayor a menor. Incluye type hints, maneja una lista vacía y explica brevemente la complejidad.
```

## 5. Prueba larga de memoria y GPU

```text
Explica con detalle cómo funciona un modelo Mixture of Experts, qué papel tiene el router, por qué solo se activan algunos expertos por token y cuáles son las ventajas y desventajas frente a un modelo denso.

Incluye:
- un ejemplo numérico sencillo,
- consumo de memoria frente a consumo de cómputo,
- ventajas para inferencia local,
- posibles cuellos de botella.

Responde entre 700 y 900 palabras.
```

Los dos modelos alcanzaron el límite configurado de 2.048 tokens en esta prueba; por eso quedaron cortados a mitad de respuesta. La comparación de rendimiento sigue siendo válida porque generaron exactamente la misma cantidad.

## Prompt corto usado en el ensayo MTP

```text
Explícame en tres frases qué es un modelo Mixture of Experts.
```

