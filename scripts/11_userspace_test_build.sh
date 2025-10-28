#!/usr/bin/env bash
# Test build for userspace EasyBuild installation
set -euo pipefail

PREFIX=${PREFIX:-$HOME/easybuild}
PARALLEL=${PARALLEL:-$(nproc 2>/dev/null || echo 4)}

msg(){ printf "\n==> %s\n" "$*"; }
die(){ printf "ERROR: %s\n" "$*" >&2; exit 1; }

# Source environment
export EASYBUILD_PREFIX=$PREFIX
export MODULEPATH=$PREFIX/modules/all${MODULEPATH:+:$MODULEPATH}

# Try to source Lmod if available
if command -v module >/dev/null 2>&1; then
  : # module command already available
elif [ -f /usr/share/lmod/lmod/init/bash ]; then
  source /usr/share/lmod/lmod/init/bash
elif [ -f /etc/profile.d/z00_lmod.sh ]; then
  source /etc/profile.d/z00_lmod.sh
fi

msg "Testing userspace EasyBuild installation..."
echo "PREFIX: $PREFIX"
echo "MODULEPATH: $MODULEPATH"
echo ""

# Verify eb is available
command -v eb >/dev/null 2>&1 || die "eb command not found. Did you run 10_userspace_bootstrap.sh first?"

msg "Checking EasyBuild version..."
eb --version

msg "Purging modules..."
module purge 2>/dev/null || true

msg "Building EasyBuild module as test..."
eb EasyBuild-4.9.0.eb --robot --parallel "$PARALLEL"

echo ""
msg "Checking installed software..."
if [ -d "$PREFIX/software/EasyBuild" ]; then
  echo "✓ EasyBuild software directory exists"
  ls -la "$PREFIX/software/EasyBuild/"
else
  echo "✗ EasyBuild software directory not found"
  exit 1
fi

echo ""
msg "Checking module files..."
if [ -d "$PREFIX/modules/all" ]; then
  echo "✓ Module directory exists"
  find "$PREFIX/modules/all" -name "*.lua" -o -name "*.tcl" 2>/dev/null | head -10 || true
else
  echo "✗ Module directory not found"
  exit 1
fi

echo ""
msg "Listing available modules..."
module avail 2>&1 || true

echo ""
msg "Testing module spider..."
module spider EasyBuild 2>&1 || true

echo ""
msg "Testing module load..."
if module load EasyBuild/4.9.0 2>&1; then
  echo "✓ EasyBuild module loaded successfully"
  module list 2>&1 || true
  eb --version
else
  echo "✗ Failed to load EasyBuild module"
  exit 1
fi

echo ""
echo "==========================================="
echo "✓ All tests passed!"
echo "==========================================="
echo ""
echo "Your userspace EasyBuild installation is ready!"
echo ""
echo "To build software packages:"
echo "  eb <package>.eb --robot"
echo ""
echo "To search for available packages:"
echo "  eb --search <name>"
echo ""
