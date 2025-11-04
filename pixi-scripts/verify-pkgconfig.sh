#!/bin/bash
set -e

# Verify pkgconfig script
# This script verifies the pkgconfig environment setup

echo "Verifying pkgconfig environment..."
chmod +x scripts/env/setup-pkgconfig.sh
scripts/env/setup-pkgconfig.sh info

echo "Pkgconfig verification completed."
