#!/bin/bash
# Visible terminal demo for issue #525. Real commands; sleeps hold each beat.
set -u
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export COLUMNS=160
export LINES=48
cd /workspace/osc-bulk-1119/diagram-design/wt-claude-skill-zip

LOG=/tmp/claude-skill-zip-demo/commands.log
{
  echo "# commands.log — real stdout/stderr from the Claude Desktop skill ZIP demo"
  echo "# host: Linux, Python $(python3 --version 2>&1 | awk '{print $2}')"
  echo "# cwd: $(pwd)"
  echo "# branch: $(git rev-parse --abbrev-ref HEAD) $(git rev-parse --short HEAD)"
  echo "# date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$LOG"

run() {
  local cmd=$1
  printf '\n\033[1;32m$\033[0m %s\n' "$cmd"
  {
    echo
    echo "\$ $cmd"
  } >> "$LOG"
  set +e
  eval "$cmd" > /tmp/claude-skill-zip-demo/_out.txt 2> /tmp/claude-skill-zip-demo/_err.txt
  local ec=$?
  set -e
  cat /tmp/claude-skill-zip-demo/_out.txt
  if [[ -s /tmp/claude-skill-zip-demo/_err.txt ]]; then
    cat /tmp/claude-skill-zip-demo/_err.txt >&2
  fi
  {
    cat /tmp/claude-skill-zip-demo/_out.txt
    if [[ -s /tmp/claude-skill-zip-demo/_err.txt ]]; then
      echo "[stderr]"
      cat /tmp/claude-skill-zip-demo/_err.txt
    fi
    echo "exit $ec"
  } >> "$LOG"
  return 0
}

hold() { sleep "$1"; }

printf '\033[2J\033[H'
printf '\033[1;37mClaude Desktop skill ZIP\033[0m  —  issue #525\n'
printf 'feat/claude-skill-zip  from  upstream/main d74d8c2\n'
hold 3

printf '\n\033[1;36m1. Naive zip of skills/diagram-design\033[0m  (host upload limit: 200 files)\n'
run 'find skills/diagram-design -type f | wc -l'
hold 3

run 'python3 -m zipfile -c /tmp/naive-diagram-design.zip skills/diagram-design'
run 'python3 /tmp/count_zip.py /tmp/naive-diagram-design.zip'
printf 'naive ZIP is over the 200-file upload limit.\n'
hold 4

printf '\n\033[1;36m2. Bounded builder (git index, include rule, deterministic ZIP)\033[0m\n'
run 'python3 scripts/build-claude-skill-zip.py'
hold 3

run 'python3 scripts/build-claude-skill-zip.py --check'
hold 4

printf '\n\033[1;36m3. Top of dist/diagram-design-claude-skill.zip\033[0m\n'
run 'python3 /tmp/head_zip.py dist/diagram-design-claude-skill.zip 14'
hold 5

printf '\nClaude Desktop is not installed on this Linux box; the macOS import was not tried.\n'
hold 4
printf '\n'
