#!/usr/bin/env bash
# Build sample lightweight modules to validate the pipeline
set -euo pipefail
module purge || true

# Use all CPUs by default
PARALLEL=${PARALLEL:-$(nproc)}

echo "Building EasyBuild module (lightweight test)..."
eb EasyBuild-4.9.0.eb --robot --parallel "$PARALLEL"

echo ""
echo "Building bzip2 1.0.8 (lightweight test module)..."
eb bzip2-1.0.8.eb --robot --parallel "$PARALLEL"

echo ""
echo "Listing modules..."
module avail
echo ""
module spider EasyBuild || true
module spider bzip2 || true
