#!/bin/bash
set -e

# Debug environment information script
# This script displays environment debug information for troubleshooting

echo 'Environment Debug Information:'
echo 'CONDA_PREFIX:' $CONDA_PREFIX
echo 'PATH:' $PATH
echo 'PKG_CONFIG_PATH:' $PKG_CONFIG_PATH
which pkg-config
