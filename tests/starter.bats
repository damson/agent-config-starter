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
  # files. Only directory patterns (trailing /) must be anchored; plain
  # file globs are fine. A missing .gitignore is its own failure, not a
  # vacuous pass.
  [ -f "$REPO_ROOT/.gitignore" ]
  run grep -E '/$' "$REPO_ROOT/.gitignore"
  unanchored=""
  while IFS= read -r line; do
    case "$line" in
      /*|\#*|"") : ;;
      *) unanchored="$unanchored $line" ;;
    esac
  done <<< "$output"
  [ -z "$unanchored" ]
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

@test "something watches the vendored harness pin" {
  # The pin is a commit, so a stale one is indistinguishable from a current one:
  # CI passes either way. This one went three weeks and five harness releases
  # behind before a person noticed.
  local cfg="$REPO_ROOT/.github/dependabot.yml"
  [ -f "$cfg" ]
  run python3 -c "
import sys, yaml
u = yaml.safe_load(open(sys.argv[1]))['updates']
sub = [x for x in u if x['package-ecosystem'] == 'gitsubmodule']
if not sub:
    print('nothing watches the submodule'); sys.exit(1)
# Against develop: a pull request opened against main would bypass the branch
# this repo integrates on, and its CI, on the way in.
if sub[0].get('target-branch') != 'develop':
    print('updates target', sub[0].get('target-branch'), 'rather than develop'); sys.exit(1)
" "$cfg"
  [ "$status" -eq 0 ]
}
