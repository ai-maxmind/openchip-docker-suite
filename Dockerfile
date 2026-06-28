# syntax=docker/dockerfile:1.7
# OpenChip Docker Suite
# Stable practical base: IIC-OSIC-TOOLS already contains a curated open-source IC design stack:
# SKY130/GF180/IHP PDKs, Yosys, OpenROAD/OpenSTA, Magic, KLayout, Xschem, ngspice,
# OpenRAM, Verilator, Icarus, GHDL, cocotb, pyuvm, Verible, Surelog, sv2v, GTKWave, etc.
#
# Build:
#   docker build -t openchip-eda:latest .
#
# Run:
#   docker run --rm -it -v "$PWD/designs:/foss/designs" -v "$PWD/workspace:/workspace" openchip-eda:latest

ARG BASE_IMAGE=hpretl/iic-osic-tools:latest
FROM ${BASE_IMAGE}

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Extra utilities for serious project work.
# Many EDA tools are already in the base image; this layer adds workflow/dev packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    curl \
    git \
    git-lfs \
    jq \
    less \
    make \
    nano \
    vim \
    tmux \
    tree \
    unzip \
    zip \
    rsync \
    ripgrep \
    fd-find \
    time \
    htop \
    procps \
    python3 \
    python3-pip \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Python packages for verification, SoC assembly, flow scripting and notebooks.
# --break-system-packages is required on Ubuntu 24.04 style Python environments.
RUN python3 -m pip install --no-cache-dir --break-system-packages --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --break-system-packages \
      cocotb \
      pyuvm \
      pytest \
      pytest-xdist \
      pytest-cov \
      numpy \
      scipy \
      pandas \
      matplotlib \
      networkx \
      pyyaml \
      click \
      rich \
      jupyterlab \
      notebook \
      edalize \
      fusesoc \
      amaranth \
      pyverilog \
      hdl21 \
      gdstk \
      gdspy \
      siliconcompiler \
      openlane

# Standard workspace layout.
ENV WORKSPACE=/workspace
ENV DESIGN_HOME=/foss/designs
ENV PDK_ROOT=/foss/pdks
WORKDIR /workspace

# Helper scripts.
COPY scripts/check-tools.sh /usr/local/bin/check-tools
COPY scripts/eda-env.sh /usr/local/bin/eda-env
COPY scripts/run-counter-example.sh /usr/local/bin/run-counter-example
RUN chmod +x /usr/local/bin/check-tools /usr/local/bin/eda-env /usr/local/bin/run-counter-example

# Friendly shell prompt and aliases.
RUN cat >/etc/profile.d/openchip.sh <<'EOF'
export WORKSPACE=/workspace
export DESIGN_HOME=/foss/designs
export PDK_ROOT=${PDK_ROOT:-/foss/pdks}

alias ll='ls -lah'
alias ct='check-tools'
alias edaenv='source /usr/local/bin/eda-env'
alias counter-demo='run-counter-example'

echo "OpenChip EDA container ready."
echo "Try: check-tools"
echo "Try: sak-pdk sky130A | sak-pdk gf180mcuD | sak-pdk ihp-sg13g2"
EOF

CMD ["/bin/bash", "-l"]
