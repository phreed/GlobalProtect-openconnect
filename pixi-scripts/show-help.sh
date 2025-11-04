#!/bin/bash
set -e

# Show help script
# This script displays the help content from markdown file as formatted text

HELP_FILE="doc/help.md"

# Check if help file exists
if [ ! -f "$HELP_FILE" ]; then
    echo "Error: Help file not found at $HELP_FILE"
    exit 1
fi

echo ""
echo "============================================================================="
echo "GlobalProtect OpenConnect - Available Tasks"
echo "============================================================================="
echo ""

# Convert markdown to readable text
cat "$HELP_FILE" | \
    sed -e 's/^# //' \
        -e 's/^## /\n/' \
        -e 's/^- \*\*`\([^`]*\)`\*\* - /  \1 - /' \
        -e 's/`\([^`]*\)`/\1/g' \
        -e 's/\*\*\([^*]*\)\*\*/\1/g' \
        -e 's/^- /  • /' \
        -e '/^---$/d' \
        -e '/^\*This help/d' | \
    grep -v "^GlobalProtect OpenConnect - Available Tasks$"

echo ""
echo "============================================================================="
echo ""
