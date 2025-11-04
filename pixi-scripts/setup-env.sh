#!/bin/bash
set -e

# Setup environment script
# This script sets up the pkgconfig environment for the project

echo "Setting up project environment..."
chmod +x scripts/env/setup-pkgconfig.sh
scripts/env/setup-pkgconfig.sh setup

echo "Environment setup completed successfully."
