# Casos de prueba para la aplicación `sumar`

## Objetivo
Verificar comportamiento correcto y robusto de `sumar` ante entradas válidas, errores de formato, límites numéricos y condiciones de fichero.

## Formato esperado
Cada línea de entrada: `N1;N2`  (dos enteros en base 10 separados por `;`). El programa escribe la suma por línea en el fichero de salida.

## Casos básicos
- **Caso válido simple:**
  - Entrada: `12;7`  → Salida esperada: `19`.
- **Cero y negativo:**
  - Entrada: `0;0` → `0`
  - Entrada: `-5;3` → `-2`
- **Espacios alrededor de números:**
  - Entrada: ` 4 ; 2 ` → `6` (aceptar espacios entre y alrededor)

## Casos de formato inválido
- **Falta separador:**
  - Entrada: `12 7` → Aviso en stderr, línea ignorada (no escribir salida).
- **Separador múltiple / campos extra:**
  - Entrada: `1;2;3` → Comportamiento esperado: tratar como `1` y `2;3` como segundo campo; si `2;3` no es un entero válido, avisar y omitir.
- **Campo vacío:**
  - Entrada: `;5` o `5;` → Aviso de número inválido, línea ignorada.
- **Caracteres no numéricos:**
  - Entrada: `foo;2` → Aviso, línea ignorada.
  - Entrada: `2;3bar` → Aviso de caracteres extra, línea ignorada.
- **Números con signos y más formatos:**
  - Entrada: `+3;-2` → `1` (acepta signos `+` y `-`).
  - Entrada: `3.5;2` → Aviso (no aceptar decimales para enteros).

## Límite y robustez numérica
- **Valores muy grandes (overflow):**
  - Entrada: valores cercanos a `LONG_MAX`/`LONG_MIN` para comprobar detección `ERANGE` y/o comportamiento de suma (puede desbordar). Esperado: detectar conversión inválida o documentar comportamiento de overflow.
- **Suma que desborda `long`:**
  - Diseñar caso que provoque overflow en la suma y verificar cómo se documenta/gestiona (si no hay manejo, observar resultado para decidir mejoras).

## Casos de fichero y nombres
- **Nombre sin extensión `.in`:**
  - Entrada: `datos` → Comprobar que el fichero de salida se llama `datos.out`.
- **Nombre con otra extensión:**
  - Entrada: `archivo.txt` → salida `archivo.txt.out` si no termina en `.in`.
- **Fichero inexistente:**
  - Ejecutar con nombre de fichero que no existe → error claro en stderr y código de salida `!= 0`.
- **Permisos insuficientes:**
  - Archivo de salida no escribible → mensaje de error y salida con fallo.

## Casos con líneas especiales
- **Líneas vacías y solo saltos de línea:**
  - Línea vacía o sólo `\n` → ignorar (no escribir ni avisar)
- **Finales CRLF (`\r\n`):**
  - Entrada con `\r\n` → comprobar que se recortan `\r` y `\n` correctamente.
- **Archivo con muchas líneas (performance):**
  - Archivo grande (p. ej. 1M líneas) → medir tiempo y uso de memoria; comprobar que no falle por buffer fijo.

## Mensajes y códigos de salida
- **Errores de argumento:**
  - Sin argumentos o con >1 argumento → mensaje de uso y salida con `EXIT_FAILURE`.
- **Mensajes informativos:**
  - Avisos por línea mal formateada deben indicar número de línea y motivo.

## Tests automáticos sugeridos
- Script que: crea ficheros de entrada temporales para cada caso, ejecuta `./sumar`, comprueba fichero de salida y captura stderr y código de salida.
- Probar casos de límites usando `ulimit` y entradas generadas automáticamente.

## Prioridad de pruebas
1. Casos básicos (válidos y formatos comunes)
2. Formato inválido y mensajes de error
3. Ficheros y permisos
4. Límite numérico y overflow
5. Rendimiento con ficheros grandes

---

Si quieres, preparo un script `tests.sh` que ejecute estas pruebas básicas automáticamente y verifique resultados.
