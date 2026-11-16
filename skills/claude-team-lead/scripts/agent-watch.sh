#!/usr/bin/env bash
# Print "<agent>: <state>" whenever a herdr agent leaves `working` (idle, blocked, done, gone).
# Silent while nothing changes.
# Usage: bash agent-watch.sh [--once] [interval_seconds] [name ...]
#   --once: exit after the first event. Run it as a background Bash command (up to 2 h) and re-run
#           it after handling the event: one wake-up per event, no expiry notices.
#   without: stream every event (for a Monitor, which expires after 30 min).
#   names:  watch only these agents, so other TLs' agents in the same herdr session don't wake you.
# Only named agents count (`herdr agent start <name>`): the TL and other sessions have no name.
ONCE=0; [ "${1:-}" = "--once" ] && { ONCE=1; shift; }
INTERVAL="${1:-15}"; [ $# -gt 0 ] && shift
# python3 where it runs; on Windows `python3` is often only the Microsoft Store stub.
PY=python3; python3 -c '' 2>/dev/null || PY=python
hit=0
declare -A prev
while true; do
  snap=$(herdr agent list 2>/dev/null | "$PY" -c '
import sys, json
only = set(sys.argv[1:])
for a in json.load(sys.stdin)["result"]["agents"]:
    if a.get("name") and (not only or a["name"] in only): print(a["name"], a.get("agent_status"))
' "$@" 2>/dev/null) || { sleep "$INTERVAL"; continue; }
  declare -A now=()
  while read -r name state; do
    [ -z "$name" ] && continue
    now[$name]=$state
    if [ "${prev[$name]:-}" != "$state" ] && [ "$state" != "working" ] && [ -n "${prev[$name]+x}" ]; then echo "$name: $state"; hit=1; fi
  done <<< "$snap"
  for name in "${!prev[@]}"; do [ -z "${now[$name]+x}" ] && { echo "$name: gone"; hit=1; }; done
  [ "$ONCE" = 1 ] && [ "$hit" = 1 ] && exit 0
  prev=(); for k in "${!now[@]}"; do prev[$k]=${now[$k]}; done
  unset now
  sleep "$INTERVAL"
done
