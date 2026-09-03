#!/usr/bin/env bats
#
# The template's own invariants: the things an adopter relies on working the
# moment they clone. Each test was proven able to fail by breaking the thing
# it covers before shipping it.

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test "the registry resolves myproject against this repo, not the harness" {
  run env AGENT_CONFIG_ROOT="$REPO_ROOT" bash -c \
    "source '$REPO_ROOT/.harness/lib/common.sh' && list_domains"
  [ "$status" -eq 0 ]
  [[ "$output" == *"myproject"* ]]
}

@test "AGENTS.md beside the domain CLAUDE.md is a relative symlink to it" {
  [ -L "$REPO_ROOT/workspace/myproject/AGENTS.md" ]
  [ "$(readlink "$REPO_ROOT/workspace/myproject/AGENTS.md")" = "CLAUDE.md" ]
}

@test "the example skill passes the harness structural checks" {
  run "$REPO_ROOT/.harness/bin/validate-skills.sh" "$REPO_ROOT/user-dev/skills"
  [ "$status" -eq 0 ]
}

@test "gitignore directory patterns are anchored with a leading slash" {
  # Unanchored dir patterns match at any depth and silently swallow new
  # files; every committed pattern must start with / (or be a comment).
  run grep -vE '^(/|#|$)' "$REPO_ROOT/.gitignore"
  [ "$status" -ne 0 ]
}

@test "every workspace directory is a registered domain" {
  domains="$(env AGENT_CONFIG_ROOT="$REPO_ROOT" bash -c \
    "source '$REPO_ROOT/.harness/lib/common.sh' && list_domains")"
  missing=""
  for d in "$REPO_ROOT"/workspace/*/; do
    name="$(basename "$d")"
    case " $domains " in
      *" $name "*) : ;;
      *) missing="$missing $name" ;;
    esac
  done
  [ -z "$missing" ]
}
