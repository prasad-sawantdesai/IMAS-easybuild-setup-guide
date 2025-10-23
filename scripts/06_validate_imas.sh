#!/bin/bash
################################################################################
# 06_validate_imas.sh
#
# Validate IMAS installation and test functionality
# Run as regular user after IMAS installation
#
# Usage:
#   ./06_validate_imas.sh [toolchain] [version]
#
# Examples:
#   ./06_validate_imas.sh intel-2023b 5.4.3
#   ./06_validate_imas.sh foss-2023b 5.4.3
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TOOLCHAIN="${1:-intel-2023b}"
IMAS_VERSION="${2:-5.4.3}"

# Expected modules
EXPECTED_MODULES=(
    "IMAS-AL-Core/${IMAS_VERSION}-${TOOLCHAIN}"
    "IMAS-AL-Cpp/${IMAS_VERSION}-${TOOLCHAIN}"
    "IMAS-AL-Fortran/${IMAS_VERSION}-${TOOLCHAIN}"
    "IMAS-AL-Python/${IMAS_VERSION}-${TOOLCHAIN}"
    "IMAS/${IMAS_VERSION}-${TOOLCHAIN}"
)

# Expected environment variables
EXPECTED_VARS=(
    "IMAS_HOME"
    "AL_VERSION"
    "AL_COMMON_PATH"
)

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}======================================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_module_system() {
    print_header "Checking Module System"
    
    if command -v module &> /dev/null; then
        print_success "Module command found"
        
        # Check module version
        if module --version &> /dev/null; then
            local MODULE_VERSION=$(module --version 2>&1 | head -n1)
            print_info "Module system: ${MODULE_VERSION}"
        fi
    else
        print_error "Module command not found"
        return 1
    fi
    
    echo ""
}

check_imas_modules() {
    print_header "Checking IMAS Modules"
    
    local FOUND_COUNT=0
    local MISSING_COUNT=0
    
    for MODULE in "${EXPECTED_MODULES[@]}"; do
        if module avail -t "${MODULE}" 2>&1 | grep -q "${MODULE}"; then
            print_success "Found: ${MODULE}"
            ((FOUND_COUNT++))
        else
            print_warning "Missing: ${MODULE}"
            ((MISSING_COUNT++))
        fi
    done
    
    echo ""
    print_info "Found ${FOUND_COUNT}/${#EXPECTED_MODULES[@]} expected modules"
    
    if [[ ${MISSING_COUNT} -gt 0 ]]; then
        print_warning "${MISSING_COUNT} modules are missing"
        return 1
    fi
    
    echo ""
}

load_imas_module() {
    print_header "Loading IMAS Module"
    
    module purge
    
    if module load "IMAS/${IMAS_VERSION}-${TOOLCHAIN}" 2>&1; then
        print_success "Successfully loaded IMAS/${IMAS_VERSION}-${TOOLCHAIN}"
        
        # Show loaded modules
        echo ""
        print_info "Loaded modules:"
        module list 2>&1 | grep -v "Currently" || true
    else
        print_error "Failed to load IMAS module"
        return 1
    fi
    
    echo ""
}

check_environment_variables() {
    print_header "Checking Environment Variables"
    
    local ALL_SET=true
    
    for VAR in "${EXPECTED_VARS[@]}"; do
        if [[ -n "${!VAR}" ]]; then
            print_success "${VAR} = ${!VAR}"
        else
            print_error "${VAR} is not set"
            ALL_SET=false
        fi
    done
    
    echo ""
    
    if ! ${ALL_SET}; then
        return 1
    fi
}

test_python_import() {
    print_header "Testing Python Imports"
    
    # Test imas_core import
    print_info "Testing: import imas_core"
    if python3 -c "import imas_core; print('  Version:', getattr(imas_core, '__version__', 'unknown'))" 2>&1; then
        print_success "imas_core import successful"
    else
        print_warning "imas_core import failed (may not be available)"
    fi
    
    echo ""
    
    # Test sys.path
    print_info "Python path includes:"
    python3 -c "import sys; [print('  -', p) for p in sys.path if 'imas' in p.lower() or 'easybuild' in p.lower()]" 2>&1 || true
    
    echo ""
}

test_library_paths() {
    print_header "Checking Library Paths"
    
    # Check LD_LIBRARY_PATH
    if [[ -n "${LD_LIBRARY_PATH}" ]]; then
        print_info "LD_LIBRARY_PATH contains:"
        echo "${LD_LIBRARY_PATH}" | tr ':' '\n' | grep -i imas | head -5 | sed 's/^/  - /' || print_info "  (no IMAS paths found)"
    else
        print_warning "LD_LIBRARY_PATH is not set"
    fi
    
    echo ""
}

test_cmake_packages() {
    print_header "Checking CMake Package Configs"
    
    # Check for IMAS CMake configs
    if [[ -n "${CMAKE_PREFIX_PATH}" ]]; then
        print_info "CMAKE_PREFIX_PATH is set"
        
        # Look for IMAS-related cmake files
        for PATH_ENTRY in $(echo "${CMAKE_PREFIX_PATH}" | tr ':' '\n'); do
            if [[ -d "${PATH_ENTRY}" ]]; then
                local CMAKE_FILES=$(find "${PATH_ENTRY}" -name "*IMAS*.cmake" 2>/dev/null | head -3)
                if [[ -n "${CMAKE_FILES}" ]]; then
                    print_success "Found IMAS CMake configs in ${PATH_ENTRY}"
                    echo "${CMAKE_FILES}" | sed 's/^/  - /'
                    break
                fi
            fi
        done
    else
        print_info "CMAKE_PREFIX_PATH is not set (this is normal)"
    fi
    
    echo ""
}

test_file_permissions() {
    print_header "Checking File Permissions"
    
    local IMAS_INSTALL_DIR="/opt/easybuild/software/IMAS/${IMAS_VERSION}-${TOOLCHAIN}"
    
    if [[ -d "${IMAS_INSTALL_DIR}" ]]; then
        print_success "IMAS installation directory exists: ${IMAS_INSTALL_DIR}"
        
        # Check directory permissions
        local DIR_PERMS=$(stat -c "%a" "${IMAS_INSTALL_DIR}")
        print_info "Directory permissions: ${DIR_PERMS}"
        
        # Check if group writable
        if [[ "${DIR_PERMS:1:1}" -ge 7 ]] || [[ "${DIR_PERMS:1:1}" -ge 5 ]]; then
            print_success "Directory is group accessible"
        else
            print_warning "Directory may not be group accessible"
        fi
    else
        print_warning "IMAS installation directory not found: ${IMAS_INSTALL_DIR}"
    fi
    
    echo ""
}

generate_test_script() {
    print_header "Generating Test Scripts"
    
    local TEST_SCRIPT="/tmp/test_imas_${IMAS_VERSION}.py"
    
    cat > "${TEST_SCRIPT}" <<'EOF'
#!/usr/bin/env python3
"""
Test script for IMAS installation
"""

import sys

def test_imas_core():
    """Test IMAS core import"""
    try:
        import imas_core
        print("✓ imas_core imported successfully")
        if hasattr(imas_core, '__version__'):
            print(f"  Version: {imas_core.__version__}")
        return True
    except ImportError as e:
        print(f"✗ Failed to import imas_core: {e}")
        return False

def test_numpy():
    """Test NumPy (required by IMAS)"""
    try:
        import numpy as np
        print(f"✓ NumPy {np.__version__} available")
        return True
    except ImportError as e:
        print(f"✗ Failed to import NumPy: {e}")
        return False

def test_scipy():
    """Test SciPy (required by IMAS)"""
    try:
        import scipy
        print(f"✓ SciPy {scipy.__version__} available")
        return True
    except ImportError as e:
        print(f"✗ Failed to import SciPy: {e}")
        return False

def main():
    print("=" * 60)
    print("IMAS Python Environment Test")
    print("=" * 60)
    print()
    
    print(f"Python version: {sys.version}")
    print(f"Python executable: {sys.executable}")
    print()
    
    tests = [
        test_numpy,
        test_scipy,
        test_imas_core,
    ]
    
    results = [test() for test in tests]
    
    print()
    print("=" * 60)
    if all(results):
        print("✓ All tests passed!")
        return 0
    else:
        print("✗ Some tests failed")
        return 1

if __name__ == '__main__':
    sys.exit(main())
EOF
    
    chmod +x "${TEST_SCRIPT}"
    print_success "Test script created: ${TEST_SCRIPT}"
    
    echo ""
    print_info "Running test script..."
    python3 "${TEST_SCRIPT}" || print_warning "Some Python tests failed"
    
    echo ""
}

print_summary() {
    print_header "Validation Summary"
    
    cat <<EOF
IMAS validation complete!

Configuration:
  - IMAS Version: ${IMAS_VERSION}
  - Toolchain: ${TOOLCHAIN}

Next Steps:
  1. Try loading IMAS: module load IMAS/${IMAS_VERSION}-${TOOLCHAIN}
  2. Test in your application
  3. Check IMAS documentation at https://imas.iter.org/

Troubleshooting:
  - If modules are missing, check installation logs
  - If imports fail, verify PYTHONPATH is set correctly
  - For access issues, verify group membership (easybuildgrp)

For more information, see: docs/imas_installation.rst
EOF
    
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "IMAS Installation Validation"
    echo "Validating IMAS ${IMAS_VERSION} with toolchain ${TOOLCHAIN}"
    echo "Started at: $(date)"
    echo ""
    
    local ALL_CHECKS_PASSED=true
    
    # Run checks
    check_module_system || ALL_CHECKS_PASSED=false
    check_imas_modules || ALL_CHECKS_PASSED=false
    load_imas_module || ALL_CHECKS_PASSED=false
    check_environment_variables || ALL_CHECKS_PASSED=false
    test_library_paths
    test_python_import
    test_cmake_packages
    test_file_permissions
    generate_test_script
    
    # Print summary
    print_summary
    
    if ${ALL_CHECKS_PASSED}; then
        print_success "All critical checks passed!"
        return 0
    else
        print_warning "Some checks failed - review output above"
        return 1
    fi
}

# Run main function
main "$@"
