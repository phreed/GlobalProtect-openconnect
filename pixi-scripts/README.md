# Pixi Scripts Directory

This directory contains shell scripts that have been extracted from long `cmd` entries in `pixi.toml` to improve maintainability and readability. These scripts are specifically used by pixi tasks and are separated from general utility scripts.

## Script Mapping

The following scripts correspond to pixi tasks with long or complex commands:

### Build Scripts
- `build-rust.sh` → `pixi run build-rust`
- `build-cli.sh` → `pixi run build-cli`
- `build-frontend.sh` → `pixi run build-frontend`

### Testing Scripts
- `test-cli.sh` → `pixi run test-cli`
- `test-cli-comprehensive.sh` → `pixi run test-cli-comprehensive`
- `test-pkgconfig.sh` → `pixi run test-pkgconfig`

### Environment Setup Scripts
- `setup-env.sh` → `pixi run setup-env`
- `show-env.sh` → `pixi run show-env`
- `debug-env.sh` → `pixi run debug-env`
- `verify-pkgconfig.sh` → `pixi run verify-pkgconfig`
- `verify-webkit-deps.sh` → `pixi run verify-webkit-deps`
- `debug-build.sh` → `pixi run debug-build`

### Packaging Scripts
- `check-ppa.sh` → `pixi run check-ppa`
- `rpm.sh` → `pixi run rpm`
- `init-pkgbuild.sh` → `pixi run init-pkgbuild`
- `pkgbuild.sh` → `pixi run pkgbuild`
- `binary.sh` → `pixi run binary`

### Package Management Scripts
- `show-package-status.sh` → `pixi run show-package-status`
- `view-package-contents.sh` → `pixi run view-package-contents`
- `install-global-cli.sh` → `pixi run install-global-cli`
- `install-global-full.sh` → `pixi run install-global-full`

### Installation Scripts
- `install.sh` → `pixi run install`
- `uninstall.sh` → `pixi run uninstall`

### Code Quality Scripts
- `lint-code.sh` → `pixi run lint-code`

### Cleanup Scripts
- `clean-all.sh` → `pixi run clean-all`

### Documentation Scripts
- `build-docs-html.sh` → `pixi run build-docs-html`
- `build-docs-pdf.sh` → `pixi run build-docs-pdf`
- `view-docs-dev.sh` → `pixi run view-docs-dev`
- `view-docs-ops.sh` → `pixi run view-docs-ops`
- `view-docs-all.sh` → `pixi run view-docs-all`

### Publishing Scripts
- `publish-cli.sh` → `pixi run publish-cli`

### Help Scripts
- `show-help.sh` → `pixi run show-help`

## Existing Scripts

The following scripts were already present in the repository:
- `create-gp-version-override.sh`
- `deb-install.sh`
- `deb.sh`
- `download-gui.sh`
- `gh-release.sh`
- `init-debian.sh`
- `init-rpm.sh` (already existed, corresponds to `pixi run init-rpm`)
- `openconnect-gp`
- `ppa.sh`
- `setup-pkgconfig.sh`
- `setup-prefix-publishing.sh`
- `tarball.sh`
- `task-runner.sh`
- `test-gp-override.sh`
- `verify-published-package.sh`

Note: The `show-help` script renders a markdown help file (`doc/help.md`) as formatted text in the terminal.

## Usage

All scripts are designed to be run from the project root directory. They maintain the same working directory and environment expectations as their corresponding pixi tasks.

### Example Usage

```bash
# Instead of: pixi run build-cli
./pixi-scripts/build-cli.sh

# Instead of: pixi run test-cli
./pixi-scripts/test-cli.sh

# Instead of: pixi run clean-all
./pixi-scripts/clean-all.sh

# Instead of: pixi run show-help
./pixi-scripts/show-help.sh
```

### Directory Structure

These scripts are specifically for pixi tasks and are located in `./pixi-scripts/` to distinguish them from general utility scripts in `./scripts/`.

## Script Standards

All scripts follow these conventions:
- Include `#!/bin/bash` shebang
- Use `set -e` for early exit on errors
- Include descriptive comments explaining the script's purpose
- Maintain the same functionality as the original pixi task commands
- Are executable (`chmod +x`)

## Environment Variables

Many scripts rely on environment variables that are typically set by pixi or the build environment:
- `VERSION` - Project version
- `REVISION` - Build revision
- `PKG_NAME` - Package name
- `OFFLINE` - Offline build flag
- `BUILD_GUI` - GUI build flag
- `INCLUDE_GUI` - GUI inclusion flag
- `DESTDIR` - Installation destination directory
- `RATTLER_AUTH_FILE` - Authentication file for publishing

## Dependencies

Scripts may depend on various tools and environments:
- Rust toolchain (cargo, clippy, rustfmt)
- Node.js and pnpm (for frontend builds)
- System packaging tools (rpmbuild, makepkg)
- Documentation tools (asciidoctor, asciidoctor-pdf)
- Package management tools (pixi, rattler-build)