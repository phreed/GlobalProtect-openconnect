#!/bin/bash
set -e

# Binary package creation script
# This script creates a binary distribution package

mkdir -p .build/binary
cp .build/tarball/${PKG_NAME}-${VERSION}.tar.gz .build/binary
tar -xzf .build/binary/${PKG_NAME}-${VERSION}.tar.gz -C .build/binary
mkdir -p .build/binary/${PKG_NAME}_${VERSION}/artifacts

# Build the project using pixi build commands
cd .build/binary/${PKG_NAME}-${VERSION}
if [ "${INCLUDE_GUI}" = "1" ]; then
    source scripts/env/setup-pkgconfig.sh && cargo build --release
else
    source scripts/env/setup-pkgconfig.sh && cargo build --release --no-default-features -p gpclient -p gpservice -p gpauth
fi

# Install using the install script with proper environment variables
export BUILD_GUI=${INCLUDE_GUI}
export DESTDIR=$(pwd)/../${PKG_NAME}_${VERSION}/artifacts
../../../pixi-scripts/install.sh
cd ../../..

cp packaging/binary/Makefile.in .build/binary/${PKG_NAME}_${VERSION}/Makefile
tar -cJf .build/binary/${PKG_NAME}_${VERSION}_$(uname -m).bin.tar.xz -C .build/binary ${PKG_NAME}_${VERSION}

cd .build/binary && sha256sum ${PKG_NAME}_${VERSION}_$(uname -m).bin.tar.xz | cut -d' ' -f1 > ${PKG_NAME}_${VERSION}_$(uname -m).bin.tar.xz.sha256
