#!/bin/bash
set -e

cd .build/deb/${PKG_NAME}-${VERSION} && dch --create --distribution unstable --package ${PKG_NAME} --newversion ${VERSION}-${REVISION} "Bugfix and improvements."
sudo mk-build-deps --install --remove debian/control
debuild --preserve-env -e PATH -us -uc -b
