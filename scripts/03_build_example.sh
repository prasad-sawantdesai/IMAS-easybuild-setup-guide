#!/usr/bin/env bash
# Build a sample toolchain component to validate the pipeline
set -euo pipefail
module purge || true

# Use all CPUs by default
PARALLEL=${PARALLEL:-$(nproc)}

echo "Building GCCcore 13.2.0 with --robot..."
eb GCCcore-13.2.0.eb --robot --parallel "$PARALLEL"

echo "Listing modules..."
module avail
module spider GCCcore || true
