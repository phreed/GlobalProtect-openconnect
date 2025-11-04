#!/bin/bash
set -e

# Install global full package script
# This script installs the full conda package globally using pixi

if ls output/linux-64/globalprotect-openconnect-*.conda >/dev/null 2>&1; then
    PACKAGE_FILE=$(ls output/linux-64/globalprotect-openconnect-*.conda | grep -v cli | head -n 1)
    echo "Installing full package: $PACKAGE_FILE"
    pixi global install --force-reinstall $(pwd)/$PACKAGE_FILE
else
    echo 'Error: No conda package found. Run pixi run package first.'
    exit 1
fi
