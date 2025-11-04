#!/bin/bash
set -e

# Lint code with Clippy
# This script sources the pkgconfig environment and runs cargo clippy with strict warnings

source scripts/env/setup-pkgconfig.sh && cargo clippy -- -D warnings
