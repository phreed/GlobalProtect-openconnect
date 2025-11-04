#!/bin/bash
set -e

# Build Rust components with environment setup
# This script sources the pkgconfig environment and builds CLI components only
# to avoid webkit dependencies that aren't available in conda-forge

source scripts/env/setup-pkgconfig.sh
setup_pkgconfig_path
export PKG_CONFIG_PATH
cargo build --release --no-default-features -p gpclient -p gpservice -p gpauth
