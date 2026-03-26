#!/bin/bash

if ! command -v jq &>/dev/null; then
  echo "BLOCKED: block-dangerous-git.sh requires jq but it is not installed. Install jq to enable git guardrails." >&2
  exit 2
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

DANGEROUS_PATTERNS=(
  # Push
  "git push"
  "push --force"

  # Reset
  "git reset --hard"
  "reset --hard"

  # Rebase
  "git rebase"

  # Clean
  "git clean -fd"
  "git clean -f"

  # Branch / tag / remote
  "git branch -D"
  "git tag -d"
  "git remote remove"

  # Working tree restore
  "git checkout \."
  "git restore \."

  # Stash destruction
  "git stash drop"
  "git stash clear"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
