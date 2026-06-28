#!/usr/bin/env bash
set -euo pipefail

# Native Linux X11 GUI launcher for KLayout, Magic, Xschem, GTKWave.
# For Wayland sessions, XWayland usually works if DISPLAY is set.
#
# Usage:
#   ./scripts/run-gui-linux-x11.sh
#
# Then inside container:
#   klayout &
#   xschem &
#   magic &
#   gtkwave &

XAUTH=/tmp/.docker.xauth

if [[ -z "${DISPLAY:-}" ]]; then
  echo "ERROR: DISPLAY is not set. Start from a graphical Linux terminal."
  exit 1
fi

touch "$XAUTH"
xauth nlist "$DISPLAY" 2>/dev/null | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge - 2>/dev/null || true

docker compose run --rm \
  -e DISPLAY="$DISPLAY" \
  -e XAUTHORITY="$XAUTH" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v "$XAUTH":"$XAUTH":rw \
  eda
