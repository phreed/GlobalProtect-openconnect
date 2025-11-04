#!/bin/bash
set -e

# Verify WebKit dependencies script
# This script sources the pkgconfig environment and checks WebKit dependencies

source scripts/env/setup-pkgconfig.sh

echo 'Checking WebKit dependencies...'

if pkg-config --exists webkit2gtk-4.1; then
    echo 'webkit2gtk-4.1: OK'
else
    echo 'webkit2gtk-4.1: MISSING'
fi

if pkg-config --exists javascriptcoregtk-4.1; then
    echo 'javascriptcoregtk-4.1: OK'
else
    echo 'javascriptcoregtk-4.1: MISSING'
fi

echo 'If missing, see WebKit Dependencies section in docs/developers-guide.adoc'
