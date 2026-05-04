#!/bin/bash
set -e

cd "$(dirname "$0")/.."

if [[ -z $(git status --porcelain) ]]; then
  echo "Nothing to commit."
  exit 0
fi

MSG="${1:-chore: auto commit $(date '+%Y-%m-%d %H:%M:%S')}"

git add -A
git commit -m "$MSG"
git push origin "$(git symbolic-ref --short HEAD)"

echo "Done: pushed to $(git symbolic-ref --short HEAD)"
