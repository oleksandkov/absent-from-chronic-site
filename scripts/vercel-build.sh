#!/usr/bin/env bash
set -euo pipefail

# Install Quarto CLI in Vercel's serverless build environment
# Quarto is needed to render .qmd files into the _site/ output directory

echo "--- Installing Quarto ---"

QUARTO_VERSION="1.9.38"
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
QUARTO_DIR="$(pwd)/.quarto-install"

if command -v quarto &> /dev/null; then
  echo "Quarto already available: $(quarto --version)"
else
  echo "Downloading Quarto ${QUARTO_VERSION}..."
  mkdir -p "$QUARTO_DIR"
  curl -sL "$QUARTO_URL" | tar -xz -C "$QUARTO_DIR" --strip-components=1
  export PATH="$QUARTO_DIR/bin:$PATH"
  echo "Quarto installed: $(quarto --version)"
fi

echo ""
echo "--- Rendering site with Quarto ---"
quarto render

echo ""
echo "--- Build complete ---"
echo "Output in: _site/"
