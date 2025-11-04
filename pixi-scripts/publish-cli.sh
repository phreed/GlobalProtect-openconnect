#!/bin/bash
set -e

# Publish CLI package script
# This script uploads the CLI conda package to prefix.dev meso-forge channel

# Check if RATTLER_AUTH_FILE environment variable is set
if [ -z "$RATTLER_AUTH_FILE" ]; then
    echo 'Error: RATTLER_AUTH_FILE environment variable not set. Please set up rattler authentication first.'
    exit 1
fi

# Check if auth file exists
if [ ! -f "$RATTLER_AUTH_FILE" ]; then
    echo "Error: Auth file not found at $RATTLER_AUTH_FILE"
    exit 1
fi

# Check if CLI package exists
if ls output/linux-64/globalprotect-openconnect-cli-*.conda >/dev/null 2>&1; then
    PACKAGE_FILE=$(ls output/linux-64/globalprotect-openconnect-cli-*.conda | head -n 1)
    echo "Publishing CLI package: $PACKAGE_FILE"
    rattler-build upload prefix --channel meso-forge $PACKAGE_FILE
else
    echo 'Error: No CLI conda package found. Run pixi run ship-cli first.'
    exit 1
fi
