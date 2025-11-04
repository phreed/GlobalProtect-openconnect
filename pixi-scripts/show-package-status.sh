#!/bin/bash
set -e

# Show package status script
# This script displays information about built conda packages

echo "Checking package status..."
ls -lh output/linux-64/*.conda
echo 'Package successfully built!'
