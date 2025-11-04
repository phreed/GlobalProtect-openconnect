#!/bin/bash
set -e

mkdir -p .build/deb
cp .build/tarball/${PKG_NAME}-${VERSION}.tar.gz .build/deb
tar -xzf .build/deb/${PKG_NAME}-${VERSION}.tar.gz -C .build/deb
cd .build/deb/${PKG_NAME}-${VERSION} && debmake
cp -f ../../../packaging/deb/control.in debian/control
cp -f ../../../packaging/deb/rules.in debian/rules
cp -f ../../../packaging/deb/postrm debian/postrm
cp -f ../../../packaging/deb/compat debian/compat
sed -i "s/@OFFLINE@/${OFFLINE}/g" debian/rules
sed -i "s/@BUILD_GUI@/${BUILD_GUI}/g" debian/rules
if [ "$BUILD_GUI" -eq 0 ]; then
  sed -i '/libsecret-1-0/d' debian/control
  sed -i '/libayatana-appindicator3-1/d' debian/control
  sed -i '/gnome-keyring/d' debian/control
  sed -i '/libwebkit2gtk-4.1-dev/d' debian/control
fi
rm -f debian/changelog
