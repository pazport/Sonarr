#!/usr/bin/env bash
# Restarts Sonarr if "Process Monitored Downloads" has been running too long,
# then re-triggers download processing. Needs curl and jq.
#
# Run from cron, e.g. every 5 minutes:
#   */5 * * * * SONARR_URL=http://localhost:8989 SONARR_API_KEY=xxx /path/to/sonarr-pmd-watchdog.sh

set -euo pipefail

SONARR_URL="${SONARR_URL:-http://localhost:8989}"
SONARR_API_KEY="${SONARR_API_KEY:?set SONARR_API_KEY}"
MAX_MINUTES="${MAX_MINUTES:-30}"
WAIT_SECONDS="${WAIT_SECONDS:-10}"

api() {
  curl -fsS -H "X-Api-Key: $SONARR_API_KEY" -H "Content-Type: application/json" "$@"
}

# Find a started ProcessMonitoredDownloads command older than MAX_MINUTES
stuck=$(api "$SONARR_URL/api/v3/command" | jq -r --argjson max "$MAX_MINUTES" '
  .[]
  | select(.name == "ProcessMonitoredDownloads" and .status == "started" and .started != null)
  | select((now - (.started | sub("\\.[0-9]+"; "") | sub("Z$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime)) > ($max * 60))
  | "\(.id) \(.started)"' | head -n 1)

if [[ -z "$stuck" ]]; then
  exit 0
fi

echo "$(date -Is) ProcessMonitoredDownloads stuck (id/started: $stuck), restarting Sonarr"

# A running command can't be cancelled through the API, so restart Sonarr.
# On startup Sonarr marks the stuck command as orphaned.
api -X POST "$SONARR_URL/api/v3/system/restart" > /dev/null

# Wait for Sonarr to come back up
for _ in $(seq 1 60); do
  sleep "$WAIT_SECONDS"
  if api "$SONARR_URL/api/v3/system/status" > /dev/null 2>&1; then
    break
  fi
done

# Refresh queue, which queues ProcessMonitoredDownloads again
api -X POST "$SONARR_URL/api/v3/command" -d '{"name":"RefreshMonitoredDownloads"}' > /dev/null

echo "$(date -Is) Sonarr restarted and RefreshMonitoredDownloads queued"
