#!/bin/bash
set -e

# Build documentation in HTML format
# This script uses asciidoctor to generate HTML documentation

mkdir -p output/docs

echo "Building HTML documentation..."
asciidoctor docs/developers-guide.adoc docs/operators-guide.adoc docs/index.adoc -D output/docs

echo "HTML documentation built successfully in output/docs/"
