#!/bin/bash
set -e

rm -rf .build/gpgui
if [ "$INCLUDE_GUI" = "1" ]; then
  echo "Downloading GlobalProtect GUI..."
  mkdir -p .build/gpgui
  curl -sSL https://github.com/yuezk/GlobalProtect-openconnect/releases/download/${RELEASE_TAG}/gpgui_$(uname -m).bin.tar.xz \
    -o .build/gpgui/gpgui_$(uname -m).bin.tar.xz
  tar -xJf .build/gpgui/*.tar.xz -C .build/gpgui
else
  echo "Skipping GlobalProtect GUI download (INCLUDE_GUI=0)"
fi
