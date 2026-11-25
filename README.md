# app-pain — Agent Skill for app-store pain-point mining

[![GitHub stars](https://img.shields.io/github/stars/hawkmill/app-pain-skill?style=flat-square)](https://github.com/hawkmill/app-pain-skill/stargazers)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)

An [Agent Skill](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) for [Claude Code](https://claude.com/code), Cursor, Codex and any agent that reads `SKILL.md`: mine iOS/Android app-store negative reviews into **structured pain points** — share %, severity, verbatim evidence — and compare competitors side by side.

**Keywords**: MCP server · app store reviews · review mining · competitor analysis · pain points · Claude skills · Cursor · Codex · ASO intelligence

Backed by the [App Pain API](https://hawkmill.com) (MCP-over-HTTP). **No API key needed** to start: the keyless allowance includes unlimited cached results (124 popular apps, plugins and extensions pre-analyzed) plus a few new analyses per day.

## Why a skill instead of the MCP server?

Same engine, different packaging:

| | MCP server | Skill (this repo) |
|---|---|---|
| Token cost | Tool schemas live in context **every session** | Loaded **on demand** when a review-mining task appears |
| Setup | Register in client config | Drop into your skills directory |
| Works with | MCP clients only | Anything that reads SKILL.md (Claude Code, Cursor, human eyes) |

Prefer MCP? The server is at `https://hawkmill.com/mcp` — one-click install buttons at https://hawkmill.com/docs#mcp.

## Install

```bash
npx skills add hawkmill/app-pain-skill
```

or manually: clone this repo and point your agent at the `SKILL.md`.

## Upgrade

The skill is a local copy of this repo — it does not auto-update. When the keyless allowance errors or docs drift, refresh:

```bash
npx skills update app-pain
```

Current version lives in `SKILL.md` frontmatter (`version:`). The MCP server needs no upgrade — it is remote and always current.

## Example prompts

- *"What do users hate most about Duolingo, and is it getting better?"*
- *"Compare the top 4 habit tracker apps' pain points and find a product gap."*
- *"Mine the 1-star reviews of this Android app id and cluster the complaints."*

## Free tier

| | Keyless | Free key | Paid |
|---|---|---|---|
| Cached results | unlimited | unlimited | unlimited |
| New (cold) analyses | few/day | 30/mo + 10 bonus (after a 14-day Starter trial) | more |
| Get it | nothing to do | https://hawkmill.com/#get-key | /buy |

Optional env: `APP_PAIN_API_KEY` (your key), `APP_PAIN_PROXY` (only if your network needs it), `APP_PAIN_MCP_URL` (override endpoint).

## Links

- API docs: https://hawkmill.com/docs
- MCP endpoint: `https://hawkmill.com/mcp`
- Official MCP Registry: `io.github.hawkmill/app-pain-api`
