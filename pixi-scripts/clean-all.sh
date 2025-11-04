#!/bin/bash
set -e

# Clean all build artifacts and dependencies
# This script performs a comprehensive cleanup of the project

cargo clean
rm -rf apps/gpgui-helper/node_modules
rm -rf apps/gpgui-helper/dist
rm -rf .build
rm -rf .vendor
rm -f vendor.tar.xz
