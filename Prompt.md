Quiero que generes un programa en lenguaje C, compatible con compilación en Linux usando gcc.

El programa debe cumplir lo siguiente:

1. Recibirá como argumento en la línea de comandos un fichero de entrada con extensión .in.
2. El fichero contendrá varias líneas, cada una con dos números enteros separados por el carácter ';'.
   Ejemplo de línea: 12;7
3. El programa deberá leer cada línea, separar los dos números, sumarlos y escribir el resultado en un fichero de salida.
4. El fichero de salida debe tener el mismo nombre que el fichero de entrada, pero con extensión .out.
   Ejemplo: si el fichero de entrada es datos.in, el de salida será datos.out.
5. Cada resultado debe escribirse en una línea independiente, en el mismo orden que las entradas.
6. El programa debe manejar errores básicos:
   - Si no se pasa un parámetro, mostrar un mensaje de uso.
   - Si el fichero no existe, mostrar un error.
   - Si una línea no tiene el formato correcto, ignorarla o avisar.
7. El código debe ser claro, portable y usar funciones estándar de C (stdio.h, stdlib.h, string.h).
8. No debe usar funciones específicas de sistemas no POSIX.
9. Incluye comentarios explicativos en el código.

Genera el código completo listo para compilar con:
gcc -o sumar sumar.c