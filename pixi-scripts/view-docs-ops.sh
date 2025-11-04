#!/bin/bash
set -e

# View operators guide documentation script
# This script opens the operators guide HTML documentation in the default browser

echo "Opening operators guide documentation..."
python -c "import webbrowser; webbrowser.open('file://' + __import__('os').path.abspath('output/docs/operators-guide.html'))"
