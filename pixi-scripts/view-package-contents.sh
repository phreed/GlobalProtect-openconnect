#!/bin/bash
set -e

# View package contents script
# This script displays the contents of built conda packages

echo "Viewing package contents..."

if [ ! -d "output/linux-64" ]; then
    echo "Error: output/linux-64 directory not found. No packages have been built."
    exit 1
fi

cd output/linux-64

# Check if any conda packages exist
if ! ls *.conda >/dev/null 2>&1; then
    echo "Error: No conda packages found in output/linux-64/"
    exit 1
fi

# List conda package files
echo "=== Conda Package Files ==="
unzip -l *.conda

echo ""
echo "=== Package Contents ==="
# Extract and show package contents
unzip -q *.conda
tar -tf pkg-*.tar.zst
