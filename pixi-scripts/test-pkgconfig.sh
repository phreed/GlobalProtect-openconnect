#!/bin/bash
set -e

# Test pkgconfig script
# This script tests the pkgconfig environment setup

echo "Testing pkgconfig environment..."
chmod +x scripts/env/setup-pkgconfig.sh
scripts/env/setup-pkgconfig.sh test

echo "Pkgconfig test completed."
