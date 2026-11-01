#!/usr/bin/env bash
# Call an app-pain-api tool over the MCP endpoint (JSON-RPC), strip the SSE shell, pretty-print.
#
# Usage:
#   mcp_call.sh <tool_name> '<arguments_json>' [request_id]
#   mcp_call.sh --raw <tool_name> '<arguments_json>'   # raw SSE output instead of extracted JSON
#
# Examples:
#   mcp_call.sh search_apps '{"q":"TikTok","limit":5}'
#   mcp_call.sh mine_app_pain_points '{"store":"android","appId":"com.zhiliaoapp.musically","reviews":50}'
#
# Environment (all optional):
#   APP_PAIN_MCP_URL   default https://hawkmill.com/mcp
#   APP_PAIN_API_KEY   optional; without it you get the free keyless allowance
#                      (unlimited cached results + a few new analyses per day)
#   APP_PAIN_PROXY     optional; e.g. http://127.0.0.1:7890 — only if YOUR network needs
#                      an outbound proxy. Default is a direct connection (hawkmill.com is
#                      reachable worldwide, mainland China included).
set -euo pipefail

MCP_URL="${APP_PAIN_MCP_URL:-https://hawkmill.com/mcp}"
API_KEY="${APP_PAIN_API_KEY:-}"
PROXY="${APP_PAIN_PROXY:-}"

RAW=0
if [[ "${1:-}" == "--raw" ]]; then RAW=1; shift; fi
TOOL="${1:?usage: mcp_call.sh [--raw] <tool_name> '<arguments_json>' [id]}"
ARGS="${2:-\{\}}"
ID="${3:-1}"

CURL_ARGS=( -sS --http1.1 -m 170 -X POST "$MCP_URL"
  -H 'Content-Type: application/json'
  -H 'Accept: application/json, text/event-stream' )

[[ -n "$API_KEY" ]] && CURL_ARGS+=( -H "x-api-key: $API_KEY" )
[[ -n "$PROXY" ]] && CURL_ARGS+=( --proxy "$PROXY" )

# -m 170: a cold analysis at reviews<=50 takes ~30-170s; the server sends SSE heartbeats
# so the connection stays alive the whole time. Cached results return in seconds.
RESP="$(curl "${CURL_ARGS[@]}" \
  -d "{\"jsonrpc\":\"2.0\",\"id\":$ID,\"method\":\"tools/call\",\"params\":{\"name\":\"$TOOL\",\"arguments\":$ARGS}}")"

if [[ $RAW -eq 1 ]]; then
  printf '%s\n' "$RESP"
  exit 0
fi

# Strip SSE heartbeat lines (": ping") and event:/data: prefixes; print result.content[].text pretty.
printf '%s\n' "$RESP" \
  | grep '^data: ' | sed 's/^data: //' \
  | python3 -c '
import json, sys
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    r = json.loads(line)
    if "error" in r:
        print(json.dumps(r["error"], ensure_ascii=False, indent=2))
        sys.exit(1)
    res = r.get("result", {})
    if res.get("isError"):
        print("TOOL ERROR:", file=sys.stderr)
    for c in res.get("content", []):
        text = c.get("text", "")
        try:
            print(json.dumps(json.loads(text), ensure_ascii=False, indent=2))
        except json.JSONDecodeError:
            print(text)
'
