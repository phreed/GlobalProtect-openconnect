#!/bin/bash
set -e

# Build GUI components with webkit dependencies
# This script provides instructions for building GUI components that require webkit

echo "=== GUI Component Build ==="
echo ""
echo "The GUI components (gpgui-helper) require webkit2gtk development libraries"
echo "which are not available in the conda-forge pixi environment."
echo ""
echo "Options to build GUI components:"
echo ""
echo "1. SYSTEM INSTALL (Recommended for Fedora-based systems):"
echo "   sudo dnf install webkit2gtk4.1-devel gtk3-devel cairo-devel pango-devel gdk-pixbuf2-devel"
echo "   Then run: cargo build --release -p gpgui-helper"
echo ""
echo "2. IMMUTABLE OS (rpm-ostree systems like Bluefin/Silverblue):"
echo "   rpm-ostree install webkit2gtk4.1-devel gtk3-devel cairo-devel"
echo "   Then reboot and run: cargo build --release -p gpgui-helper"
echo ""
echo "3. CONTAINER BUILD (using distrobox):"
echo "   distrobox create --name gpoc-gui --image fedora:latest"
echo "   distrobox enter gpoc-gui"
echo "   # Inside container:"
echo "   sudo dnf install -y webkit2gtk4.1-devel gtk3-devel cairo-devel pango-devel gdk-pixbuf2-devel rust cargo"
echo "   cd /path/to/project"
echo "   cargo build --release -p gpgui-helper"
echo ""
echo "4. SKIP GUI (CLI-only build):"
echo "   The CLI components have already been built successfully with 'pixi run build-rust'"
echo "   GUI components are optional for most use cases."
echo ""

# Check if system webkit dependencies are available
echo "Checking system webkit availability..."
if pkg-config --exists webkit2gtk-4.1 2>/dev/null; then
    echo "✓ System webkit2gtk-4.1 found - attempting build..."

    # Try to build GUI components with system libraries
    if cargo build --release -p gpgui-helper; then
        echo "✓ GUI components built successfully!"
        exit 0
    else
        echo "✗ Build failed even with system webkit available"
        exit 1
    fi
else
    echo "✗ webkit2gtk-4.1 not found in system pkg-config paths"
    echo ""
    echo "To install webkit dependencies, choose one of the options above."
    echo "For now, GUI components will be skipped."
    echo ""
    echo "Note: CLI components are fully functional without GUI components."
    exit 0
fi
