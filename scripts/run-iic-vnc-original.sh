#!/usr/bin/env bash
set -euo pipefail

# Runs the upstream IIC-OSIC-TOOLS image directly with its browser/noVNC workflow.
# This is useful if you want a full desktop environment instead of only terminal.
#
# Browser usually: http://localhost:8080 or port printed by the container.
# Designs are mounted at /foss/designs.

mkdir -p designs

docker run --rm -it \
  --name iic-osic-tools-vnc \
  -p 8080:80 \
  -p 5901:5901 \
  -v "$PWD/designs:/foss/designs" \
  hpretl/iic-osic-tools:latest
