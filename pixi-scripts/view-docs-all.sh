#!/bin/bash
set -e

# View all documentation script
# This script opens the main index HTML documentation in the default browser

echo "Opening main documentation index..."
python -c "import webbrowser; webbrowser.open('file://' + __import__('os').path.abspath('output/docs/index.html'))"
