# agent-config-starter

**A ready-to-run instance of [agent-config-harness](https://github.com/damson/agent-config-harness)** — agent instruction files managed like code: registered in a domain registry, structurally tested, and scored on a five-dimension rubric with a number that moves when the config gets worse.

This repo is the on-ramp. The harness holds the machinery and is vendored here
as a pinned submodule; everything you edit is config.

## Quickstart

```bash
gh repo create my-agent-config --template damson/agent-config-starter --private --clone
cd my-agent-config
git submodule update --init
just setup    # symlink configs and skills into ~/.claude
just check    # health-check every domain and link
just test     # secret lint + skill structure
```

Scoring needs the Claude CLI and an API key — everything else runs without one:

```bash
just eval            # score every domain on the rubric
just eval myproject  # one domain
```

## What you edit

| Path | What it is |
|---|---|
| `config/domains.conf` | The domain registry — one line per domain |
| `workspace/<domain>/CLAUDE.md` | Rules loaded when working in that domain |
| `user-dev/CLAUDE.md` | Your global rules, linked to `~/.claude/CLAUDE.md` |
| `user-dev/skills/` | Your own skills — each held to the structural checks |
| `user-pers/` | Personal identity files, scored on the same rubric |

Everything under `.harness/` is the engine, pinned to a reviewed commit. To
update it: bump the submodule, run `just test-harness`, commit the new pin.
Never edit it in place — the change is lost on the next update.

## The rules that keep this working

- `CLAUDE.md` is the single source of truth per domain; `AGENTS.md` beside it
  is a symlink. Editing the symlink target is editing the truth; turning it
  into a real file reintroduces drift the eval will score down.
- Keep `CLAUDE.md` files under ~100 lines. They load every session; procedures
  and rationale belong in docs they point to.
- A new skill needs frontmatter `name:` matching its folder, a `## Procedure`
  section, and a `## When to STOP` section — `just test` enforces all three.

The reasoning behind all of this lives in the harness's
[docs](https://github.com/damson/agent-config-harness/tree/main/docs).
