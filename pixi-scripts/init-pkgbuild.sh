#!/bin/bash
set -e

# Initialize PKGBUILD for Arch Linux package creation
# This script sets up the PKGBUILD directory and files

mkdir -p .build/pkgbuild
cp .build/tarball/${PKG_NAME}-${VERSION}.tar.gz .build/pkgbuild
cp packaging/pkgbuild/PKGBUILD.in .build/pkgbuild/PKGBUILD
sed -i "s/@PKG_NAME@/${PKG_NAME}/g" .build/pkgbuild/PKGBUILD
sed -i "s/@VERSION@/${VERSION}/g" .build/pkgbuild/PKGBUILD
sed -i "s/@REVISION@/${REVISION}/g" .build/pkgbuild/PKGBUILD
sed -i "s/@OFFLINE@/${OFFLINE}/g" .build/pkgbuild/PKGBUILD
