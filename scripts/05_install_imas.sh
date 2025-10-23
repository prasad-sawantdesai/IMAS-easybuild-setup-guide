#!/bin/bash
################################################################################
# 05_install_imas.sh
#
# Install complete IMAS suite with specified toolchain
# Run as regular user (member of easybuildgrp)
#
# Usage:
#   ./05_install_imas.sh [intel|foss] [version]
#
# Examples:
#   ./05_install_imas.sh intel 5.4.3
#   ./05_install_imas.sh foss 5.4.3
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TOOLCHAIN_TYPE="${1:-intel}"  # Default to intel
TOOLCHAIN_VERSION="2023b"
TOOLCHAIN="${TOOLCHAIN_TYPE}-${TOOLCHAIN_VERSION}"
IMAS_VERSION="${2:-5.4.3}"  # Default to 5.4.3
PARALLEL_JOBS="${3:-8}"     # Default to 8 parallel jobs

# Directories
EASYBUILD_PREFIX="/opt/easybuild"
LOCAL_EASYCONFIGS="${EASYBUILD_PREFIX}/local-easyconfigs"
IMAS_EASYCONFIGS="${LOCAL_EASYCONFIGS}/imas-easyconfigs"
IMAS_WORK_DIR="/work/imas"

# IMAS modules in installation order
IMAS_MODULES=(
    "IMAS-AL-Core-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-AL-Cpp-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-AL-Fortran-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-AL-Python-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-AL-HDC-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-AL-MDSplus-models-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IDS-Validator-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IDStools-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-Python-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-${IMAS_VERSION}-${TOOLCHAIN}.eb"
)

# Optional modules (comment out if not needed)
OPTIONAL_MODULES=(
    "IMAS-AL-Java-${IMAS_VERSION}-${TOOLCHAIN}.eb"
    "IMAS-AL-Matlab-${IMAS_VERSION}-${TOOLCHAIN}.eb"
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

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if running as user (not root)
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root"
        print_info "Run as a regular user who is member of easybuildgrp"
        exit 1
    fi
    
    # Check group membership
    if ! groups | grep -q easybuildgrp; then
        print_error "User $(whoami) is not member of easybuildgrp"
        print_info "Run as root: usermod -aG easybuildgrp $(whoami)"
        print_info "Then log out and log back in"
        exit 1
    fi
    print_success "User $(whoami) is member of easybuildgrp"
    
    # Check if EasyBuild is available
    if ! command -v eb &> /dev/null; then
        print_error "EasyBuild (eb) command not found"
        print_info "Please install EasyBuild first"
        exit 1
    fi
    print_success "EasyBuild found: $(eb --version)"
    
    # Check if module command exists
    if ! command -v module &> /dev/null; then
        print_error "module command not found"
        print_info "Please install Lmod first"
        exit 1
    fi
    print_success "Lmod found"
    
    # Check if IMAS easyconfigs exist
    if [[ ! -d "${IMAS_EASYCONFIGS}" ]]; then
        print_warning "IMAS easyconfigs not found at ${IMAS_EASYCONFIGS}"
        print_info "Will attempt to clone from ITER repository"
        clone_imas_easyconfigs
    else
        print_success "IMAS easyconfigs found at ${IMAS_EASYCONFIGS}"
    fi
    
    # Check if IMAS work directory exists
    if [[ ! -d "${IMAS_WORK_DIR}" ]]; then
        print_warning "IMAS work directory not found: ${IMAS_WORK_DIR}"
        print_info "Creating IMAS work directory (requires sudo)"
        create_imas_work_dir
    else
        print_success "IMAS work directory exists: ${IMAS_WORK_DIR}"
    fi
    
    echo ""
}

clone_imas_easyconfigs() {
    print_info "Cloning ITER EasyBuild easyconfigs repository..."
    
    # Create local-easyconfigs directory if it doesn't exist
    if [[ ! -d "${LOCAL_EASYCONFIGS}" ]]; then
        mkdir -p "${LOCAL_EASYCONFIGS}" || {
            print_error "Cannot create ${LOCAL_EASYCONFIGS}"
            print_info "Run as root: mkdir -p ${LOCAL_EASYCONFIGS} && chown :easybuildgrp ${LOCAL_EASYCONFIGS} && chmod 2775 ${LOCAL_EASYCONFIGS}"
            exit 1
        }
    fi
    
    cd "${LOCAL_EASYCONFIGS}"
    
    # Try HTTPS first
    if git clone https://git.iter.org/scm/imex/easybuild-easyconfigs.git imas-easyconfigs; then
        print_success "Successfully cloned IMAS easyconfigs via HTTPS"
    else
        print_warning "HTTPS clone failed, trying SSH..."
        if git clone git@git.iter.org:imex/easybuild-easyconfigs.git imas-easyconfigs; then
            print_success "Successfully cloned IMAS easyconfigs via SSH"
        else
            print_error "Failed to clone IMAS easyconfigs"
            print_info "Please ensure you have access to git.iter.org and proper authentication"
            print_info "You may need to set up SSH keys or configure credentials"
            exit 1
        fi
    fi
}

create_imas_work_dir() {
    print_info "Creating IMAS work directory..."
    
    if sudo mkdir -p "${IMAS_WORK_DIR}"; then
        sudo chown :easybuildgrp "${IMAS_WORK_DIR}"
        sudo chmod 2775 "${IMAS_WORK_DIR}"
        print_success "Created IMAS work directory: ${IMAS_WORK_DIR}"
    else
        print_error "Failed to create IMAS work directory"
        print_info "Please run manually as root:"
        print_info "  mkdir -p ${IMAS_WORK_DIR}"
        print_info "  chown :easybuildgrp ${IMAS_WORK_DIR}"
        print_info "  chmod 2775 ${IMAS_WORK_DIR}"
        exit 1
    fi
}

print_configuration() {
    print_header "Installation Configuration"
    echo "Toolchain:      ${TOOLCHAIN}"
    echo "IMAS Version:   ${IMAS_VERSION}"
    echo "Parallel Jobs:  ${PARALLEL_JOBS}"
    echo "Install Prefix: ${EASYBUILD_PREFIX}"
    echo "IMAS Home:      ${IMAS_WORK_DIR}"
    echo ""
    
    print_info "Modules to install:"
    for MODULE in "${IMAS_MODULES[@]}"; do
        echo "  - ${MODULE}"
    done
    echo ""
    
    if [[ ${#OPTIONAL_MODULES[@]} -gt 0 ]]; then
        print_info "Optional modules (edit script to enable):"
        for MODULE in "${OPTIONAL_MODULES[@]}"; do
            echo "  - ${MODULE}"
        done
        echo ""
    fi
}

check_module_exists() {
    local MODULE_NAME=$1
    local MODULE_VERSION=$2
    
    if module avail -t "${MODULE_NAME}/${MODULE_VERSION}" 2>&1 | grep -q "${MODULE_NAME}/${MODULE_VERSION}"; then
        return 0  # Module exists
    else
        return 1  # Module doesn't exist
    fi
}

install_toolchain() {
    print_header "Installing Toolchain: ${TOOLCHAIN}"
    
    # Check if toolchain already exists
    if check_module_exists "${TOOLCHAIN_TYPE}" "${TOOLCHAIN_VERSION}"; then
        print_success "Toolchain ${TOOLCHAIN} already installed"
        return 0
    fi
    
    print_info "Installing ${TOOLCHAIN} (this may take 1-2 hours)..."
    
    if eb "${TOOLCHAIN}.eb" --robot --parallel "${PARALLEL_JOBS}"; then
        print_success "Successfully installed toolchain ${TOOLCHAIN}"
    else
        print_error "Failed to install toolchain ${TOOLCHAIN}"
        print_info "Try running manually: eb ${TOOLCHAIN}.eb --robot --parallel ${PARALLEL_JOBS}"
        exit 1
    fi
    
    echo ""
}

install_module() {
    local MODULE=$1
    local MODULE_NAME=$(echo "${MODULE}" | cut -d'-' -f1-3)  # Extract module name
    local MODULE_FULL=$(echo "${MODULE}" | sed 's/.eb$//')   # Remove .eb extension
    
    print_info "Installing ${MODULE}..."
    
    # Check if module already exists
    if module avail -t "${MODULE_FULL}" 2>&1 | grep -q "${MODULE_FULL}"; then
        print_warning "Module ${MODULE_FULL} already installed, skipping"
        return 0
    fi
    
    # Attempt installation with progress indication
    if eb "${MODULE}" --robot --parallel "${PARALLEL_JOBS}" 2>&1 | tee "/tmp/eb_${MODULE_NAME}.log"; then
        print_success "Successfully installed ${MODULE}"
        return 0
    else
        print_error "Failed to install ${MODULE}"
        print_info "Check log file: /tmp/eb_${MODULE_NAME}.log"
        return 1
    fi
}

install_imas_modules() {
    print_header "Installing IMAS Modules"
    
    # Load EasyBuild module
    module purge
    module load EasyBuild
    
    local FAILED_MODULES=()
    local INSTALLED_COUNT=0
    local TOTAL_COUNT=${#IMAS_MODULES[@]}
    
    for MODULE in "${IMAS_MODULES[@]}"; do
        echo ""
        echo "Progress: [${INSTALLED_COUNT}/${TOTAL_COUNT}]"
        
        if install_module "${MODULE}"; then
            ((INSTALLED_COUNT++))
        else
            FAILED_MODULES+=("${MODULE}")
        fi
    done
    
    echo ""
    print_header "Installation Summary"
    
    if [[ ${#FAILED_MODULES[@]} -eq 0 ]]; then
        print_success "All modules installed successfully! (${INSTALLED_COUNT}/${TOTAL_COUNT})"
    else
        print_warning "Installation completed with errors"
        print_info "Successfully installed: ${INSTALLED_COUNT}/${TOTAL_COUNT}"
        print_error "Failed modules:"
        for MODULE in "${FAILED_MODULES[@]}"; do
            echo "  - ${MODULE}"
        done
        exit 1
    fi
}

verify_installation() {
    print_header "Verifying Installation"
    
    # Load IMAS module
    module purge
    if module load "IMAS/${IMAS_VERSION}-${TOOLCHAIN}" 2>&1; then
        print_success "IMAS module loaded successfully"
    else
        print_error "Failed to load IMAS module"
        return 1
    fi
    
    # Check environment variables
    print_info "Checking environment variables..."
    
    if [[ -n "${IMAS_HOME}" ]]; then
        print_success "IMAS_HOME = ${IMAS_HOME}"
    else
        print_warning "IMAS_HOME not set"
    fi
    
    if [[ -n "${AL_VERSION}" ]]; then
        print_success "AL_VERSION = ${AL_VERSION}"
    else
        print_warning "AL_VERSION not set"
    fi
    
    if [[ -n "${AL_COMMON_PATH}" ]]; then
        print_success "AL_COMMON_PATH = ${AL_COMMON_PATH}"
    else
        print_warning "AL_COMMON_PATH not set"
    fi
    
    # Test Python import
    print_info "Testing Python import..."
    if python3 -c "import imas_core; print('IMAS Core imported successfully')" 2>&1; then
        print_success "Python import test passed"
    else
        print_warning "Python import test failed (this may be normal if Python bindings were not built)"
    fi
    
    # List loaded modules
    echo ""
    print_info "Loaded modules:"
    module list
    
    echo ""
}

print_usage_instructions() {
    print_header "Usage Instructions"
    
    cat <<EOF
IMAS has been installed successfully!

To use IMAS, load the module:

    module purge
    module load IMAS/${IMAS_VERSION}-${TOOLCHAIN}

To make this easier, you can add an alias to your ~/.bashrc:

    echo "alias load-imas='module purge && module load IMAS/${IMAS_VERSION}-${TOOLCHAIN}'" >> ~/.bashrc

Then simply run:

    load-imas

Check available IMAS modules:

    module avail IMAS
    module spider IMAS

Test IMAS functionality:

    python3 -c "import imas_core; print('IMAS loaded successfully')"

For more information, refer to:
  - IMAS documentation: https://imas.iter.org/
  - This guide: docs/imas_installation.rst

EOF
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "IMAS Installation Script"
    echo "Starting IMAS installation at $(date)"
    echo ""
    
    # Validate toolchain type
    if [[ "${TOOLCHAIN_TYPE}" != "intel" && "${TOOLCHAIN_TYPE}" != "foss" ]]; then
        print_error "Invalid toolchain type: ${TOOLCHAIN_TYPE}"
        print_info "Usage: $0 [intel|foss] [version] [parallel_jobs]"
        print_info "Example: $0 intel 5.4.3 8"
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Print configuration
    print_configuration
    
    # Ask for confirmation
    read -p "Proceed with installation? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled by user"
        exit 0
    fi
    
    # Install toolchain
    install_toolchain
    
    # Install IMAS modules
    install_imas_modules
    
    # Verify installation
    verify_installation
    
    # Print usage instructions
    print_usage_instructions
    
    print_success "IMAS installation completed successfully at $(date)"
}

# Run main function
main "$@"
