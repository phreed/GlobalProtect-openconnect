#!/bin/bash
set -e

if [ "$BUILD_GUI" = "1" ] && [ "$BUILD_FE" = "1" ]; then
  echo "Building frontend..."
  (cd apps/gpgui-helper && pnpm install && pnpm build)
fi

rm -rf apps/gpgui-helper/node_modules
mkdir -p .cargo
mkdir -p .build/tarball

if [ "$OFFLINE" = "1" ]; then
  cargo vendor .vendor > .cargo/config.toml
  tar -cJf vendor.tar.xz .vendor
fi

echo "Creating tarball..."
tar --exclude .vendor --exclude target --transform "s,^,${PKG_NAME}-${VERSION}/," -czf .build/tarball/${PKG_NAME}-${VERSION}.tar.gz * .cargo
