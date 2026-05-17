#!/usr/bin/env bash
# check-prereqs.sh — verify your environment has everything claude-code-mobile-kit needs.
# Run this before bootstrap.sh.

set -uo pipefail

PASS="✓"
FAIL="✗"
WARN="!"

ok=0
missing=0
warned=0

heading() {
  printf "\n\033[1m%s\033[0m\n" "$1"
}

check_cmd() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    local version
    version=$("$cmd" --version 2>&1 | head -1 || echo "version unknown")
    printf "  \033[32m%s\033[0m  %-22s %s\n" "$PASS" "$cmd" "$version"
    ok=$((ok+1))
  else
    printf "  \033[31m%s\033[0m  %-22s missing — %s\n" "$FAIL" "$cmd" "$hint"
    missing=$((missing+1))
  fi
}

check_cmd_optional() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    local version
    version=$("$cmd" --version 2>&1 | head -1 || echo "version unknown")
    printf "  \033[32m%s\033[0m  %-22s %s\n" "$PASS" "$cmd" "$version"
    ok=$((ok+1))
  else
    printf "  \033[33m%s\033[0m  %-22s not found — %s (optional)\n" "$WARN" "$cmd" "$hint"
    warned=$((warned+1))
  fi
}

heading "Required"
check_cmd flutter "install from https://docs.flutter.dev/get-started/install"
check_cmd dart "ships with Flutter; if missing, reinstall Flutter"
check_cmd git "install via your OS package manager"
check_cmd python3 "install Python 3.10+ from python.org or your package manager"

heading "Required for Claude Code workflow"
check_cmd claude "install Claude Code: https://docs.claude.com/en/docs/claude-code"

heading "Required for Play Console deploys"
check_cmd_optional gh "GitHub CLI — install via brew/apt/choco. Optional if you don't use gh for repos."
check_cmd_optional jarsigner "ships with Java JDK. Needed for verifying AAB signatures."

heading "Python packages (for Play Console API)"
if command -v python3 >/dev/null 2>&1; then
  for pkg in "google.oauth2" "googleapiclient"; do
    if python3 -c "import $pkg" 2>/dev/null; then
      printf "  \033[32m%s\033[0m  %-22s installed\n" "$PASS" "$pkg"
      ok=$((ok+1))
    else
      printf "  \033[33m%s\033[0m  %-22s not installed — \`pip3 install google-api-python-client google-auth\`\n" "$WARN" "$pkg"
      warned=$((warned+1))
    fi
  done
fi

heading "Summary"
printf "  Passed:  %d\n" "$ok"
printf "  Missing: %d\n" "$missing"
printf "  Warnings (optional): %d\n" "$warned"

if [[ $missing -gt 0 ]]; then
  printf "\n\033[31mNot ready.\033[0m Install missing items above, then re-run.\n"
  exit 1
fi

printf "\n\033[32mReady.\033[0m You can run scripts/bootstrap.sh next.\n"
if [[ $warned -gt 0 ]]; then
  printf "Optional items missing are fine for kit basics — install them when you reach the relevant phase (deploys, etc.).\n"
fi
exit 0
