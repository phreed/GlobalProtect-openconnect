#!/bin/bash
set -e

# View developers guide documentation script
# This script opens the developers guide HTML documentation in the default browser

echo "Opening developers guide documentation..."
python -c "import webbrowser; webbrowser.open('file://' + __import__('os').path.abspath('output/docs/developers-guide.html'))"
