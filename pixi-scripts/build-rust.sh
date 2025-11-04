#!/bin/bash
set -e

# Build Rust components with environment setup
# This script sources the pkgconfig environment and builds Rust code

source scripts/env/setup-pkgconfig.sh && cargo build --release
