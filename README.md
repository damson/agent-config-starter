# agent-config-starter

[![ci](https://github.com/damson/agent-config-starter/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/damson/agent-config-starter/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/damson/agent-config-starter)](LICENSE)

**Your agent instructions, managed like code.**

Hi! 👋 This is the on-ramp to
[agent-config-harness](https://github.com/damson/agent-config-harness): a
ready-to-run repo where your `CLAUDE.md` files are registered, structurally
tested, and graded A to F by a rubric that notices when they get worse. The
robots read these files before touching your code; this starter is how you
stop feeding them folklore.

Everything here is pre-wired. The harness holds the machinery, vendored as a
pinned submodule; every file you actually edit is config. Clone it, rename
one example domain, and you are under management in five minutes.

## Quickstart

```bash
gh repo create my-agent-config --template damson/agent-config-starter --private --clone
cd my-agent-config
git submodule update --init
just setup    # symlink configs and skills into ~/.claude
just check    # health-check every domain and link
just test     # secret lint + skill structure
```

> ⚠️ **Before `just setup`:** it points `~/.claude/CLAUDE.md` and
> `~/.claude/preferences.md` at this repo. An existing regular file there is
> moved aside to a timestamped `.bak` (and the run says so); a symlink owned
> by another config repo makes setup refuse rather than silently take over.
> Your old config survives either way, but read the output.

Scoring needs the Claude CLI and an API key. Everything else runs without one:

```bash
just eval            # score every domain on the rubric
just eval myproject  # one domain
```

## What's in the box

A worked example of every moving part, each file carrying comments that say
what to replace and why:

- **One registered domain** (`workspace/myproject/`) showing the
  one-`CLAUDE.md`-per-domain pattern, symlinked `AGENTS.md` included.
- **A global layer** (`user-dev/`) for the rules you want in every project,
  plus one `example-skill` that passes the structural checks and exists to be
  copied.
- **An identity layer** (`user-pers/`) for how the assistant writes as you
  and to you. Templates only; your actual personality is bring-your-own.
- **CI that means it**: secret lint, skill structure, and a check that the
  registry resolves against *this* repo rather than the engine's examples.

## What you edit

| Path | What it is |
|---|---|
| `config/domains.conf` | The domain registry: one line per domain |
| `workspace/<domain>/CLAUDE.md` | Rules loaded when working in that domain |
| `user-dev/CLAUDE.md` | Your global rules, linked to `~/.claude/CLAUDE.md` |
| `user-dev/skills/` | Your own skills, each held to the structural checks |
| `user-pers/` | Personal identity files, scored on the same rubric |

Everything under `.harness/` is the engine, pinned to a reviewed commit. To
update it: bump the submodule, run `just test-harness`, commit the new pin.
Never edit it in place; the change is lost on the next update.

## The rules that keep this working

- `CLAUDE.md` is the single source of truth per domain; `AGENTS.md` beside it
  is a symlink. Editing the symlink target is editing the truth; turning it
  into a real file reintroduces drift the eval will score down.
- Keep `CLAUDE.md` files under ~100 lines. They load every session; procedures
  and rationale belong in docs they point to.
- A new skill needs frontmatter `name:` matching its folder, a `## Procedure`
  section, and a `## When to STOP` section. `just test` enforces all three.

The reasoning behind all of this lives in the harness's
[docs](https://github.com/damson/agent-config-harness/tree/main/docs).

## License

[MIT](LICENSE). Fork it, gut it, make it yours: that is what a starter is for.
