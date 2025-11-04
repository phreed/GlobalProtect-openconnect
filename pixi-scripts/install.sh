#!/bin/bash
set -e

# Install script for GlobalProtect OpenConnect
# This script installs all binary files, desktop files, and system integration components

# Install main binaries
install -Dm755 target/release/gpclient $DESTDIR/usr/bin/gpclient
install -Dm755 target/release/gpauth $DESTDIR/usr/bin/gpauth
install -Dm755 target/release/gpservice $DESTDIR/usr/bin/gpservice

# Install GUI helper if built
if [ "$BUILD_GUI" = "1" ]; then
  install -Dm755 target/release/gpgui-helper $DESTDIR/usr/bin/gpgui-helper
fi

# Install GUI binary if available
if [ -f .build/gpgui/gpgui_*/gpgui ]; then
  install -Dm755 .build/gpgui/gpgui_*/gpgui $DESTDIR/usr/bin/gpgui
fi

# Install NetworkManager integration
install -Dm755 packaging/files/usr/lib/NetworkManager/dispatcher.d/pre-down.d/gpclient.down $DESTDIR/usr/lib/NetworkManager/dispatcher.d/pre-down.d/gpclient.down
install -Dm755 packaging/files/usr/lib/NetworkManager/dispatcher.d/gpclient-nm-hook $DESTDIR/usr/lib/NetworkManager/dispatcher.d/gpclient-nm-hook

# Install desktop application files
install -Dm644 packaging/files/usr/share/applications/gpgui.desktop $DESTDIR/usr/share/applications/gpgui.desktop

# Install application icons
install -Dm644 packaging/files/usr/share/icons/hicolor/scalable/apps/gpgui.svg $DESTDIR/usr/share/icons/hicolor/scalable/apps/gpgui.svg
install -Dm644 packaging/files/usr/share/icons/hicolor/32x32/apps/gpgui.png $DESTDIR/usr/share/icons/hicolor/32x32/apps/gpgui.png
install -Dm644 packaging/files/usr/share/icons/hicolor/128x128/apps/gpgui.png $DESTDIR/usr/share/icons/hicolor/128x128/apps/gpgui.png
install -Dm644 packaging/files/usr/share/icons/hicolor/256x256@2/apps/gpgui.png $DESTDIR/usr/share/icons/hicolor/256x256@2/apps/gpgui.png

# Install polkit policy
install -Dm644 packaging/files/usr/share/polkit-1/actions/com.yuezk.gpgui.policy $DESTDIR/usr/share/polkit-1/actions/com.yuezk.gpgui.policy
