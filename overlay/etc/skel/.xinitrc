#!/bin/sh
xsetroot -solid '#0d1620' || true
if [ -n "${LEVEOS_OPEN_URL:-}" ]; then
 leveos-open-gui "${LEVEOS_OPEN_MODE:-lite}" "$LEVEOS_OPEN_URL" &
else
 xterm -ls &
fi
exec jwm
