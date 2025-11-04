#!/bin/bash
set -e

# Install global CLI package script
# This script installs the CLI conda package globally using pixi

if ls output/linux-64/globalprotect-openconnect-cli-*.conda >/dev/null 2>&1; then
    PACKAGE_FILE=$(ls output/linux-64/globalprotect-openconnect-cli-*.conda | head -n 1)
    echo "Installing CLI package: $PACKAGE_FILE"
    pixi global install --force-reinstall $(pwd)/$PACKAGE_FILE
else
    echo 'Error: No CLI conda package found. Run pixi run package-cli first.'
    exit 1
fi
