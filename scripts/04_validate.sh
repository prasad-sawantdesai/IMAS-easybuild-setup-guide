#!/usr/bin/env bash
# Validation script to test EasyBuild installation
set -euo pipefail

PREFIX=${PREFIX:-/opt/easybuild}

echo "=== EasyBuild Installation Validation ==="
echo ""

# Initialize environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_init_env.sh"

echo ""
echo "1. Checking software installation..."
if [ -d "$PREFIX/software/EasyBuild" ]; then
  echo "✓ EasyBuild software directory exists"
  ls -la "$PREFIX/software/EasyBuild/"
else
  echo "✗ EasyBuild software directory not found"
  exit 1
fi

echo ""
echo "2. Checking module files..."
if [ -d "$PREFIX/modules/all/EasyBuild" ]; then
  echo "✓ EasyBuild module directory exists"
  find "$PREFIX/modules/all/EasyBuild" -type f
else
  echo "✗ EasyBuild module directory not found"
  exit 1
fi

echo ""
echo "3. Testing module availability..."
if module avail EasyBuild 2>&1 | grep -q "EasyBuild"; then
  echo "✓ EasyBuild module is available"
else
  echo "✗ EasyBuild module not found in module avail"
  exit 1
fi

echo ""
echo "4. Testing module spider..."
if module spider EasyBuild 2>&1 | grep -q "EasyBuild"; then
  echo "✓ module spider finds EasyBuild"
else
  echo "✗ module spider cannot find EasyBuild"
  exit 1
fi

echo ""
echo "5. Testing module load..."
if module load EasyBuild/4.9.0 2>&1; then
  echo "✓ EasyBuild module loaded successfully"
  module list 2>&1 | grep -i easybuild || true
  eb --version
else
  echo "✗ Failed to load EasyBuild module"
  exit 1
fi

echo ""
echo "=== All validation checks passed! ==="
