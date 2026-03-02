#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-$(pwd)}"
SERVER_URL="http://127.0.0.1:4000"
JEKYLL_PID=""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/setup_env.sh" "$REPO_DIR"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - bash)"

cd "$REPO_DIR"

cleanup() {
  if [ -n "$JEKYLL_PID" ] && kill -0 "$JEKYLL_PID" >/dev/null 2>&1; then
    kill "$JEKYLL_PID" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT INT TERM

rbenv exec bundle _2.6.3_ exec jekyll serve --host 127.0.0.1 --port 4000 --livereload &
JEKYLL_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "$SERVER_URL" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if command -v open >/dev/null 2>&1; then
  open -a Safari "$SERVER_URL" || true
fi

wait "$JEKYLL_PID"
