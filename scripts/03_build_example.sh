#!/usr/bin/env bash
# Build sample lightweight modules to validate the pipeline
set -euo pipefail

# Source Lmod initialization if available
if [ -f /etc/profile.d/z00_lmod.sh ]; then
  source /etc/profile.d/z00_lmod.sh
elif [ -f /usr/share/lmod/lmod/init/bash ]; then
  source /usr/share/lmod/lmod/init/bash
fi

# Add EasyBuild modules to MODULEPATH
PREFIX=${PREFIX:-/opt/easybuild}
export MODULEPATH="$PREFIX/modules/all${MODULEPATH:+:$MODULEPATH}"

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
module spider EasyBuild || true
