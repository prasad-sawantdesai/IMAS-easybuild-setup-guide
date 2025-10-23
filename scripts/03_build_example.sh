#!/usr/bin/env bash
# Build sample lightweight modules to validate the pipeline
set -euo pipefail

# Initialize EasyBuild environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_init_env.sh"

module purge || true

# Use all CPUs by default
PARALLEL=${PARALLEL:-$(nproc)}

echo "Building EasyBuild module (lightweight test)..."
eb EasyBuild-4.9.0.eb --robot --parallel "$PARALLEL"

echo ""
echo "Current MODULEPATH: $MODULEPATH"
echo ""
echo "Checking installed software..."
test -d "$PREFIX/software/EasyBuild" && ls -la "$PREFIX/software/EasyBuild/" || echo "No EasyBuild software directory found"
echo ""
echo "Checking module files..."
test -d "$PREFIX/modules/all" && find "$PREFIX/modules/all" -name "*.lua" -o -name "*.tcl" || echo "No module files found"
echo ""
echo "Listing modules..."
module avail
echo ""
echo "Testing module spider..."
module spider EasyBuild || true
echo ""
echo "Testing module load..."
module load EasyBuild/4.9.0 && echo "✓ EasyBuild module loaded successfully" || echo "✗ Failed to load EasyBuild module"
module list 2>&1 || true
