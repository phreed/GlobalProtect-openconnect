#!/bin/bash
set -e

# RPM build script
# This script builds RPM packages using rpmbuild

rm -rf $HOME/rpmbuild
rpmdev-setuptree
cp .build/tarball/${PKG_NAME}-${VERSION}.tar.gz $HOME/rpmbuild/SOURCES/${PKG_NAME}.tar.gz
rpmbuild -ba .build/rpm/globalprotect-openconnect.spec
cp $HOME/rpmbuild/RPMS/$(uname -m)/${PKG_NAME}*.rpm .build/rpm

if [ "$(uname -m)" = "x86_64" ]; then
  cp $HOME/rpmbuild/SRPMS/${PKG_NAME}*.rpm .build/rpm
fi
