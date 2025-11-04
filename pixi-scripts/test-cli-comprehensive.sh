#!/bin/bash
set -e

# Comprehensive CLI testing script
# This script runs comprehensive tests for CLI binaries

echo "Running comprehensive CLI tests..."
chmod +x tests/test-cli-final.sh
./tests/test-cli-final.sh

echo "Comprehensive CLI testing completed."
