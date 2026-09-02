# Agent config, managed by the harness.
#
# This repo holds CONFIG. The machinery lives in the agent-config-harness
# submodule at .harness/, pinned to a reviewed commit and pointed back here by
# AGENT_CONFIG_ROOT. After cloning: git submodule update --init

export AGENT_CONFIG_ROOT := justfile_directory()

# Show all recipes.
default:
    @just --list --unsorted

# Link configs and skills into ~/.claude; install the pre-push hook.
setup:
    @./.harness/bin/setup.sh

# Health-check every registered domain and global symlink.
check:
    @./.harness/bin/check-health.sh

# Structural checks: secret lint + skill structure.
test:
    @./.harness/bin/lint-secrets.sh
    @./.harness/bin/validate-skills.sh

# Score config quality on the 5-dimension rubric. Needs the claude CLI.
eval domain="all":
    @./.harness/evals/run-eval.sh {{domain}}

# Run the harness's own suite at the pinned commit.
test-harness:
    @cd .harness && bats tests/
