#!/bin/bash
set -e

# Build documentation in PDF format
# This script uses asciidoctor-pdf to generate PDF documentation

mkdir -p output/docs

echo "Building PDF documentation..."
asciidoctor-pdf docs/developers-guide.adoc docs/operators-guide.adoc -D output/docs

echo "PDF documentation built successfully in output/docs/"
