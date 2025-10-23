#!/usr/bin/env bash
# Build sample lightweight modules to validate the pipeline
set -euo pipefail
module purge || true

# Use all CPUs by default
PARALLEL=${PARALLEL:-$(nproc)}

echo "Building EasyBuild module (lightweight test)..."
eb EasyBuild-4.9.0.eb --robot --parallel "$PARALLEL"

echo ""
echo "Building help2man (lightweight test module)..."
eb help2man-1.49.2.eb --robot --parallel "$PARALLEL"

echo ""
echo "Listing modules..."
module avail
echo ""
module spider EasyBuild || true
module spider help2man || true
