---
name: app-pain
description: Mine user pain points from iOS/Android app-store reviews — LLM-clustered negative reviews into structured pain points (share %, severity, verbatim evidence), with cross-app competitor comparison. No API key needed (free keyless allowance; cached results unlimited). Use when the user wants to research user pain points for an app category (meditation, short-video, habit trackers...), compare top apps' common complaints, dig into an app's negative reviews, or run competitor review analysis. Triggers: app pain points, review mining, negative review analysis, competitor comparison, mine pain points.
---

# App Pain — app-store review mining & pain-point comparison

Core value: structured pain-point output (`sharePercent` / `severity` / verbatim evidence / 7-day cache) for "category comparison" and "competitor complaints" tasks. For general web sentiment or community discussions, use a web-search skill instead — this one only mines app-store reviews.

All calls go through `scripts/mcp_call.sh` (handles MCP/SSE plumbing, pretty-prints JSON). **No API key required** — you get unlimited cached results plus a few new (uncached) analyses per day. Heavy use? Get a free key at https://hawkmill.com/#get-key (10 analyses/month + 10 signup bonus):

```bash
SCRIPT=scripts/mcp_call.sh   # adjust path if installed elsewhere

# 1. Find appIds (returns android/ios ids)
$SCRIPT search_apps '{"q":"TikTok","limit":5}'

# 2. Mine pain points (core tool; cold analysis 30-170s — set Bash timeout >= 180s)
$SCRIPT mine_app_pain_points '{"store":"android","appId":"com.zhiliaoapp.musically","reviews":50}'

# 3. Drill into raw reviews (50/page; verify clustering claims against evidence)
$SCRIPT get_app_reviews '{"store":"android","appId":"com.zhiliaoapp.musically","page":1}'
```

Optional: `export APP_PAIN_API_KEY=pa_...` for your own quota; `APP_PAIN_PROXY=http://...` only if your network needs an outbound proxy (direct connection works worldwide, mainland China included).

Multi-app comparison: run `search_apps` for each app first, then fire multiple `mine_app_pain_points` **in parallel** (independent calls — same Bash block).

## Tool quick reference

| Tool | Key params | Notes |
|---|---|---|
| `search_apps` | `q` (required), `store`, `country` (default us), `limit` | always step 1 |
| `mine_app_pain_points` | `store`+`appId` (required), `reviews` (50-500, default 300), `maxRating` (default 3), `country` | 7-day cache |
| `get_app_reviews` | `store`+`appId` (required), `page` (1-10), `sort`, `country` | 50 reviews/page |
| `get_pain_trend` | `store`+`appId`, `days` | pain-point drift over time |
| `get_app_details` | `store`+`appId` | rating history, version info |

## Hard constraints (measured behaviors — follow these)

1. **Use `reviews: 50`. Do not increase it.** Cold analyses with no response bytes for >60s get cut off by proxies/edges; `reviews=50` reliably completes (~30-170s, server sends SSE heartbeats). Prefer consistent 50-review samples across compared apps over one big sample that times out.
2. **Prefer the Android catalog for comparisons.** iOS deep-mining is capped at ~50 reviews by Apple's anti-scraping, some apps' iOS catalogs are unreachable, and review culture within one store is more comparable.
3. **Too few negative reviews? Use `maxRating: 5`.** If `painPoints: []` comes back suggesting sparse negatives, retry with `"reviews":50,"maxRating":5` (the LLM skips pure praise; 4-star reviews with embedded complaints join the clustering).
4. **Empty results pollute the cache and there is no bypass-cache param** (pain cache = 7 days). To retry, vary the cache key: change `country`, `reviews`, or `maxRating`.
5. **Watch `cache.hit` in responses**: `true` = instant; `false` = cold analysis — set Bash timeout >= 180s.

## Report structure (category-comparison tasks)

1. One comparison table: negative-review rate (`negativeReviews`/`analyzedReviews`), each app's top pain point with share % and severity
2. Per-app sections: pain-point title + share + severity + the most striking verbatim evidence (translate if needed, keep the emotion)
3. "Common complaints" section: cross-app patterns and their shared root cause
4. "Differentiated findings": each app's unique pain points, one-line cause each
5. Close with sample notes (review count / store / country / clustering is LLM-based); note that `sharePercent` is over negative reviews, not all reviews

## Troubleshooting

- **Timeout / connection reset**: your network path is dropping long SSE streams. Try `APP_PAIN_PROXY` if you have one, or retry — cached results are instant.
- **"Daily allowance of NEW (uncached) analyses is used up"**: keyless quota exhausted. Register a free key (https://hawkmill.com/#get-key) and `export APP_PAIN_API_KEY=pa_...`.
- **Empty or unparseable output**: re-run with `--raw` to inspect the raw SSE stream.
