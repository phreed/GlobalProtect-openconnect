#!/bin/bash
set -e

# Debug build script
# This script sources the pkgconfig environment and tests the build environment

source scripts/env/setup-pkgconfig.sh

echo 'Testing build environment...'
cargo check --release --no-default-features -p gpclient
