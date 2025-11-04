#!/bin/bash
set -e

SERIES_VER=$(distro-info --series ${SERIES} -r | cut -d' ' -f1)
echo "Building for ${SERIES} ${SERIES_VER}"
rm -rf .build/deb/${PKG_NAME}-${VERSION}/debian/changelog
cd .build/deb/${PKG_NAME}-${VERSION} && dch --create --distribution ${SERIES} --package ${PKG_NAME} --newversion ${VERSION}-${REVISION}ppa${PPA_REVISION}~ubuntu${SERIES_VER} "Bugfix and improvements."

echo "y" | debuild -e PATH -S -sa -k"${GPG_KEY_ID}" -p"gpg --batch --passphrase ${GPG_KEY_PASS} --pinentry-mode loopback"

if [ "$PUBLISH" -eq 1 ]; then
  dput ppa:yuezk/globalprotect-openconnect ../*.changes
else
  echo "Skipping ppa publish (PUBLISH=0)"
fi
