
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <limits.h>

#define LINE_BUF 1024

/*
 * Programa: sumar.c
 * Compilar: gcc -o sumar sumar.c
 * Uso: ./sumar fichero.in
 *   - Lee cada línea de `fichero.in` con formato "N1;N2"
 *   - Escribe en `fichero.out` (mismo nombre, extensión .out) la suma N1+N2 por línea
 * Manejo de errores básico: argumento, apertura de ficheros, líneas mal formateadas.
 */

/* Crea el nombre del fichero de salida: si la entrada termina en .in la reemplaza por .out,
   si no, añade ".out" al final. Devuelve cadena malloc() que el llamador debe liberar. */
char *make_output_name(const char *inname) {
    size_t len = strlen(inname);
    /* reservar espacio extra para posible ".out" y NUL */
    char *out = malloc(len + 5 + 1);
    if (!out) return NULL;
    strcpy(out, inname);
    char *dot = strrchr(out, '.');
    if (dot && strcmp(dot + 1, "in") == 0) {
        /* reemplazar "in" por "out" */
        strcpy(dot + 1, "out");
    } else {
        /* añadir ".out" */
        strcat(out, ".out");
    }
    return out;
}

/* trim al final (quita '\n' y '\r') */
static void rtrim(char *s) {
    size_t n = strlen(s);
    while (n > 0 && (s[n-1] == '\n' || s[n-1] == '\r')) {
        s[n-1] = '\0';
        --n;
    }
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s fichero.in\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *inname = argv[1];
    FILE *fin = fopen(inname, "r");
    if (!fin) {
        fprintf(stderr, "Error al abrir '%s': %s\n", inname, strerror(errno));
        return EXIT_FAILURE;
    }

    char *outname = make_output_name(inname);
    if (!outname) {
        fprintf(stderr, "Error de memoria\n");
        fclose(fin);
        return EXIT_FAILURE;
    }

    FILE *fout = fopen(outname, "w");
    if (!fout) {
        fprintf(stderr, "Error al crear '%s': %s\n", outname, strerror(errno));
        free(outname);
        fclose(fin);
        return EXIT_FAILURE;
    }

    char line[LINE_BUF];
    int lineno = 0;
    while (fgets(line, sizeof(line), fin)) {
        ++lineno;
        rtrim(line);
        if (line[0] == '\0') {
            /* línea vacía: ignorar */
            continue;
        }
        char *sep = strchr(line, ';');
        if (!sep) {
            fprintf(stderr, "Aviso: linea %d formato inválido (falta ';'): '%s'\n", lineno, line);
            fprintf(fout, "ERROR: linea %d formato inválido (falta ';'): '%s'", lineno, line);
            continue;
        }
        *sep = '\0';
        char *a_str = line;
        char *b_str = sep + 1;

        /* convertir con comprobación básica */
        char *endptr;
        errno = 0;
        long a = strtol(a_str, &endptr, 10);
        if (endptr == a_str || (errno == ERANGE && (a == LONG_MIN || a == LONG_MAX))) {
            fprintf(stderr, "Aviso: linea %d primer número inválido: '%s'\n", lineno, a_str);
            fprintf(fout, "ERROR: linea %d primer número inválido: '%s'", lineno, a_str);
            continue;
        }
        /* permitir espacios alrededor del número */
        while (*endptr == ' ' || *endptr == '\t') endptr++;
        if (*endptr != '\0') {
            fprintf(stderr, "Aviso: linea %d primer número con caracteres extra: '%s'\n", lineno, a_str);
            fprintf(fout, "ERROR: linea %d primer número con caracteres extra: '%s'", lineno, a_str);
            continue;
        }

        errno = 0;
        long b = strtol(b_str, &endptr, 10);
        if (endptr == b_str || (errno == ERANGE && (b == LONG_MIN || b == LONG_MAX))) {
            fprintf(stderr, "Aviso: linea %d segundo número inválido: '%s'\n", lineno, b_str);
            fprintf(fout, "ERROR: linea %d segundo número inválido: '%s'", lineno, b_str);
            continue;
        }
        while (*endptr == ' ' || *endptr == '\t') endptr++;
        if (*endptr != '\0') {
            fprintf(stderr, "Aviso: linea %d segundo número con caracteres extra: '%s'\n", lineno, b_str);
            fprintf(fout, "ERROR: linea %d segundo número con caracteres extra: '%s'", lineno, b_str);
            continue;
        }

        long s = a + b;
        fprintf(fout, "%ld\n", s);
    }

    fclose(fin);
    fclose(fout);
    free(outname);

    return EXIT_SUCCESS;
}
