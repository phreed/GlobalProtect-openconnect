#!/bin/bash
set -e

# PKGBUILD script for Arch Linux package creation
# This script builds the package using makepkg

cd .build/pkgbuild && makepkg -s --noconfirm
