#!/usr/bin/env bash
set -euo pipefail

if command -v quarto &> /dev/null; then
    quarto render
else
    echo "Quarto not available. Using pre-built _site directory."
    if [ ! -d "_site" ]; then
        echo "Error: _site directory not found and quarto is not installed."
        exit 1
    fi
fi
