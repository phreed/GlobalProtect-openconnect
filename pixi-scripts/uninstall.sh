#!/bin/bash
set -e

# Uninstall script for GlobalProtect OpenConnect
# This script removes all installed binary files, desktop files, and system integration components

# Remove main binaries
rm -f $DESTDIR/usr/bin/gpclient
rm -f $DESTDIR/usr/bin/gpauth
rm -f $DESTDIR/usr/bin/gpservice
rm -f $DESTDIR/usr/bin/gpgui-helper
rm -f $DESTDIR/usr/bin/gpgui

# Remove NetworkManager integration
rm -f $DESTDIR/usr/lib/NetworkManager/dispatcher.d/pre-down.d/gpclient.down
rm -f $DESTDIR/usr/lib/NetworkManager/dispatcher.d/gpclient-nm-hook

# Remove desktop application files
rm -f $DESTDIR/usr/share/applications/gpgui.desktop

# Remove application icons
rm -f $DESTDIR/usr/share/icons/hicolor/scalable/apps/gpgui.svg
rm -f $DESTDIR/usr/share/icons/hicolor/32x32/apps/gpgui.png
rm -f $DESTDIR/usr/share/icons/hicolor/128x128/apps/gpgui.png
rm -f $DESTDIR/usr/share/icons/hicolor/256x256@2/apps/gpgui.png

# Remove polkit policy
rm -f $DESTDIR/usr/share/polkit-1/actions/com.yuezk.gpgui.policy
