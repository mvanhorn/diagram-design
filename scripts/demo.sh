#!/bin/sh
# Real commands for the box-plot accent-notation demo.
# Each comparison holds on screen about 3 seconds.
set -eu
export PYTHONUNBUFFERED=1
ROOT=/workspace/osc-bulk-1119/diagram-design/wt-box-plot-accent-notations
REPRO=/tmp/box-plot-accent-repro
MAIN=/tmp/main-box-plot/scripts/verify-box-plot.py
BRANCH="$ROOT/scripts/verify-box-plot.py"
cd "$ROOT"

C0=$(printf '\033[0m')
C1=$(printf '\033[1;37m')
C2=$(printf '\033[1;32m')
C3=$(printf '\033[1;33m')
C4=$(printf '\033[1;31m')
CD=$(printf '\033[2m')

pause() { sleep "${1:-3}"; }

banner() {
  printf '\n%s%s%s\n' "$C3" "$1" "$C0"
}

run_one() {
  checker=$1
  file=$2
  printf '%s$ python3 scripts/verify-box-plot.py %s%s\n' "$C1" "$(basename "$file")" "$C0"
  set +e
  python3 "$checker" "$file"
  code=$?
  set -e
  if [ "$code" -eq 0 ]; then
    printf '%sexit %s%s\n' "$C2" "$code" "$C0"
  else
    printf '%sexit %s%s\n' "$C4" "$code" "$C0"
  fi
}

printf '\033[2J\033[H'
printf '%sdiagram-design  verify-box-plot.py%s\n' "$C1" "$C0"
printf 'issue #487 item 5 — accent in hwb(), lab(), oklch(), currentColor\n'
printf '%supstream/main d74d8c2  vs  feat/box-plot-accent-notations%s\n' "$CD" "$C0"
pause 3

banner "1/4  hwb() of the light accent on the muted Auth series"
printf 'Auth box fill="hwb(13.96 12.55%% 25.1%%)"  (Checkout already accented)\n'
printf '\n-- upstream/main --\n'
run_one "$MAIN" "$REPRO/light-hwb.html"
pause 3
printf '\n-- this branch --\n'
run_one "$BRANCH" "$REPRO/light-hwb.html"
pause 3

printf '\033[2J\033[H'
banner "2/4  lab() of the light accent on the muted Auth series"
printf 'Auth box fill="lab(46.9%% 48.61 47.51)"\n'
printf '\n-- upstream/main --\n'
run_one "$MAIN" "$REPRO/light-lab.html"
pause 3
printf '\n-- this branch --\n'
run_one "$BRANCH" "$REPRO/light-lab.html"
pause 3

printf '\033[2J\033[H'
banner "3/4  oklch() of the light accent on the muted Auth series"
printf 'Auth box fill="oklch(0.5544 0.1643 36.71)"\n'
printf '\n-- upstream/main --\n'
run_one "$MAIN" "$REPRO/light-oklch.html"
pause 3
printf '\n-- this branch --\n'
run_one "$BRANCH" "$REPRO/light-oklch.html"
pause 3

printf '\033[2J\033[H'
banner "4/4  currentColor with an accent color on the muted Auth series"
printf 'Auth box fill="currentColor" color="#bf4520"\n'
printf '\n-- upstream/main --\n'
run_one "$MAIN" "$REPRO/light-currentColor_attr.html"
pause 3
printf '\n-- this branch --\n'
run_one "$BRANCH" "$REPRO/light-currentColor_attr.html"
pause 3

printf '\033[2J\033[H'
banner "Shipped examples still pass on this branch"
printf '%s$ python3 scripts/verify-box-plot.py --all%s\n' "$C1" "$C0"
set +e
python3 "$BRANCH" --all
code=$?
set -e
printf '%sexit %s%s\n' "$C2" "$code" "$C0"
pause 3

printf '\n%sDone. Rule 7 now reads hwb/lab/lch/oklab/oklch and currentColor.%s\n' "$C1" "$C0"
pause 3
