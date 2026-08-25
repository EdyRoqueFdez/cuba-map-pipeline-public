#!/usr/bin/env bash
# MPC-03 size budget gate: fail if the generated MBTiles exceeds 40 MiB.
# Runs BEFORE release publication so an oversized build stays red and
# publishes no new GitHub Release.
set -euo pipefail

FILE="${1:-cuba_transport.mbtiles}"
MAX_BYTES=$((40 * 1024 * 1024))

if [ ! -f "$FILE" ]; then
	echo "error: MBTiles file not found: $FILE" >&2
	exit 1
fi

SIZE=$(stat -c%s "$FILE")

echo "MPC-03 size budget: $FILE = ${SIZE} bytes (limit ${MAX_BYTES} bytes / 40 MiB)"

if [ "$SIZE" -gt "$MAX_BYTES" ]; then
	echo "error: $FILE exceeds the 40MiB budget (${SIZE} > ${MAX_BYTES} bytes) — release blocked (spec MPC-03)" >&2
	exit 1
fi

echo "OK: $FILE within the 40MiB budget"
