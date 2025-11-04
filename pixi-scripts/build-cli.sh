#!/bin/bash
set -e

# Build CLI components with environment setup
# This script sources the pkgconfig environment and builds specific CLI packages

source scripts/env/setup-pkgconfig.sh && cargo build --release --no-default-features -p gpclient -p gpservice -p gpauth
