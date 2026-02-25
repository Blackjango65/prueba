# Proyecto `sumar`

Instrucciones rápidas para usar desde VS Code Remote-SSH:

- Conéctate al host remoto con Remote-SSH y abre la carpeta del proyecto.
- Instala en el remoto `build-essential` y `gdb` si es necesario:

```bash
sudo apt update
sudo apt install build-essential gdb
```

- Compilar desde VS Code: `Terminal > Run Task...` → `build` (usa `gcc -g -std=c11 -Wall sumar.c -o sumar`).
- Depurar: abre la vista Run/Debug y ejecuta "Debug sumar (gdb)". Pon breakpoints en `sumar.c`.

Archivos añadidos:
- `sumar.c` : código fuente.
- `.vscode/tasks.json` : tarea de compilación.
- `.vscode/launch.json` : configuración de depuración con GDB.
- `.vscode/c_cpp_properties.json` : configuración para IntelliSense.
- `datos.in` : ejemplo de entrada.

Ejemplo de uso en remoto:

```bash
./sumar datos.in
cat datos.out
```
