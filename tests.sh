#!/usr/bin/env bash
set -u

ROOT="$(pwd)"
SUMAR="$ROOT/sumar"
TMPDIR=$(mktemp -d)
failures=0
REPORT="$ROOT/tests_report.txt"
# start fresh report
: > "$REPORT"

run_test() {
  name="$1"
  in="$2"
  expected_out="$3"
  expected_err="$4"

  inpath="$TMPDIR/${name}.in"
  outpath="$TMPDIR/${name}.out"
  errpath="$TMPDIR/${name}.err"

  printf "%s" "$in" > "$inpath"

  # remove any previous output
  rm -f "$outpath"

  "$SUMAR" "$inpath" > "$outpath" 2> "$errpath"
  rc=$?

  ok_out=1
  ok_err=1

  if [ -f "$expected_out" ]; then
    diff -u "$expected_out" "$outpath" >/dev/null 2>&1 || ok_out=0
  else
    # compare inline expected
    printf "%s" "$expected_out" > "$TMPDIR/exp.tmp"
    diff -u "$TMPDIR/exp.tmp" "$outpath" >/dev/null 2>&1 || ok_out=0
  fi

  if [ -f "$expected_err" ]; then
    # allow the program to print warnings, compare expected substring
    if [ -s "$expected_err" ]; then
      grep -F -f "$expected_err" "$errpath" >/dev/null 2>&1 || ok_err=0
    else
      # expect no stderr
      if [ -s "$errpath" ]; then ok_err=0; fi
    fi
  else
    printf "%s" "$expected_err" > "$TMPDIR/err.tmp"
    if [ -s "$TMPDIR/err.tmp" ]; then
      grep -F -f "$TMPDIR/err.tmp" "$errpath" >/dev/null 2>&1 || ok_err=0
    else
      if [ -s "$errpath" ]; then ok_err=0; fi
    fi
  fi

  if [ $ok_out -eq 1 ] && [ $ok_err -eq 1 ]; then
    printf "[PASS] %s\n" "$name"
    printf "[PASS] %s\n" "$name" >> "$REPORT"
  else
    printf "[FAIL] %s\n" "$name"
    printf "[FAIL] %s\n" "$name" >> "$REPORT"
    printf "  input:\n";
    sed -n '1,10p' "$inpath" | sed 's/^/    /'
    printf "  expected out:\n";
    sed -n '1,10p' "$expected_out" 2>/dev/null | sed 's/^/    /' || printf "    (inline)\n    %s\n" "$expected_out"
    printf "  actual out:\n";
    sed -n '1,10p' "$outpath" | sed 's/^/    /'
    printf "  stderr:\n";
    sed -n '1,10p' "$errpath" | sed 's/^/    /'
    # also append details to report
    printf "  input:\n" >> "$REPORT"
    sed -n '1,10p' "$inpath" | sed 's/^/    /' >> "$REPORT"
    printf "  expected out:\n" >> "$REPORT"
    sed -n '1,10p' "$expected_out" 2>/dev/null | sed 's/^/    /' >> "$REPORT" 2>/dev/null || printf "    (inline)\n    %s\n" "$expected_out" >> "$REPORT"
    printf "  actual out:\n" >> "$REPORT"
    sed -n '1,10p' "$outpath" | sed 's/^/    /' >> "$REPORT"
    printf "  stderr:\n" >> "$REPORT"
    sed -n '1,10p' "$errpath" | sed 's/^/    /' >> "$REPORT"
    failures=$((failures+1))
  fi
}

# Prepare inline expected outputs and expected stderr patterns

# 1: Caso válido simple
cat > "$TMPDIR/exp1.out" <<'EOF'
19
EOF
run_test "valid-simple" "12;7" "$TMPDIR/exp1.out" ""

# 2: Espacios alrededor
cat > "$TMPDIR/exp2.out" <<'EOF'
6
EOF
run_test "spaces" " 4 ; 2 " "$TMPDIR/exp2.out" ""

# 3: Negativo
cat > "$TMPDIR/exp3.out" <<'EOF'
-2
EOF
run_test "negative" "-5;3" "$TMPDIR/exp3.out" ""

# 4: Falta separador
run_test "missing-sep" "12 7" "ERROR: linea 1 formato inválido (falta ';'): '12 7'" "falta ';'"

# 5: No numérico
run_test "non-numeric" "foo;2" "ERROR: linea 1 primer número inválido: 'foo'" "primer número inválido"

# 6: Empty field
run_test "empty-field" ";5" "ERROR: linea 1 primer número inválido: ''" "primer número inválido"

# 7: File name without .in -> output name check
# create file 'plain' and run, check output file name
name_check_in="$TMPDIR/plain"
echo "1;2" > "$name_check_in"
"$SUMAR" "$name_check_in" >/dev/null 2> "$TMPDIR/name.err"
if [ -f "$name_check_in.out" ]; then
  printf "[PASS] name-output\n"
else
  printf "[FAIL] name-output (expected %s.out)\n" "$name_check_in"
  failures=$((failures+1))
fi
rm -f "$name_check_in.out"

# summary
if [ $failures -eq 0 ]; then
  printf "\nAll tests passed\n"
  printf "\nAll tests passed\n" >> "$REPORT"
else
  printf "\n%d test(s) failed\n" "$failures"
  printf "\n%d test(s) failed\n" "$failures" >> "$REPORT"
fi

# cleanup
rm -rf "$TMPDIR"
exit $failures
