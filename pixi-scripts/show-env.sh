#!/bin/bash
set -e

# Show environment script
# This script displays the current pkgconfig environment information

echo "Displaying environment information..."
chmod +x scripts/env/setup-pkgconfig.sh
scripts/env/setup-pkgconfig.sh info

echo "Environment information display completed."
