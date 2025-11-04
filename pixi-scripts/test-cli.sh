#!/bin/bash
set -e

# Test CLI binaries script
# This script tests that CLI binaries are built correctly and show version info

echo 'Testing CLI binaries...'
./target/release/gpclient --version
./target/release/gpservice --version
./target/release/gpauth --version
