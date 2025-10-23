# Complete IMAS Module List

This document lists all modules required for a complete IMAS 5.4.3 installation.

## Installation Order

Modules should be installed in this order to satisfy dependencies:

### 1. Base Toolchain

**Choose ONE:**

```bash
# Option A: Intel Toolchain (recommended for performance)
eb intel-2023b.eb --robot --parallel 8

# Option B: FOSS Toolchain (open source, more portable)
eb foss-2023b.eb --robot --parallel 8
```

**Includes:**
- Compiler (Intel or GCC)
- MPI implementation (Intel MPI or OpenMPI)
- Mathematical libraries (MKL or OpenBLAS, FFTW, ScaLAPACK)

### 2. Core Dependencies

```bash
# Build tools
eb CMake-3.27.6.eb --robot --parallel 8
eb Ninja-1.11.1.eb --robot --parallel 8


# Python build tools
eb scikit-build-core-0.9.3-${TOOLCHAIN}.eb --robot --parallel 8
eb Cython-3.0.10-${TOOLCHAIN}.eb --robot --parallel 8
eb cython-cmake-0.2.0-${TOOLCHAIN}.eb --robot --parallel 8

# Core libraries
eb HDF5-1.14.3-${TOOLCHAIN}.eb --robot --parallel 8
eb MDSplus-7.132.0-${TOOLCHAIN}.eb --robot --parallel 8
eb UDA-2.8.0-${TOOLCHAIN}.eb --robot --parallel 8
eb Boost-1.83.0-${TOOLCHAIN}.eb --robot --parallel 8
eb SciPy-bundle-2023.12-${TOOLCHAIN}.eb --robot --parallel 8
```

**Note:** Replace `${TOOLCHAIN}` with `intel-2023b` or `foss-2023b`

### 3. IMAS Core Components

```bash
# Core library (required)
eb IMAS-AL-Core-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Common utilities (if separate module exists)
eb IMAS-AL-Common-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8
```

### 4. IMAS Language Bindings

Install the language bindings you need:

```bash
# C++ bindings (commonly used)
eb IMAS-AL-Cpp-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Fortran bindings (commonly used)
eb IMAS-AL-Fortran-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Python bindings (commonly used)
eb IMAS-AL-Python-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Java bindings (optional)
eb IMAS-AL-Java-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# MATLAB bindings (optional)
eb IMAS-AL-Matlab-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8
```

### 5. IMAS Backend Support

```bash
# HDF5 Data Container backend
eb IMAS-AL-HDC-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# MDSplus backend models
eb IMAS-AL-MDSplus-models-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8
```

### 6. IMAS Utility Tools

```bash
# Validation tools
eb IDS-Validator-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Utility tools
eb IDStools-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Python utilities
eb IMAS-Python-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8
```

### 7. IMAS Complete Suite

```bash
# Meta-module that loads complete IMAS environment
eb IMAS-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8
```

## Quick Reference Tables

### Intel Toolchain Modules (intel-2023b)

| Module | Version | Purpose | Required |
|--------|---------|---------|----------|
| intel | 2023b | Base toolchain | Yes |
| CMake | 3.27.6 | Build system | Yes |
| Ninja | 1.11.1 | Build tool | Yes |
| scikit-build-core | 0.9.3 | Python build | Yes |
| Cython | 3.0.10 | Python C extensions | Yes |
| cython-cmake | 0.2.0 | CMake Cython integration | Yes |
| HDF5 | 1.14.3 | Data storage | Yes |
| MDSplus | 7.132.0 | Data backend | Yes |
| UDA | 2.8.0 | Data access | Yes |
| Boost | 1.83.0 | C++ libraries | Yes |
| SciPy-bundle | 2023.12 | Python scientific stack | Yes |
| IMAS-AL-Core | 5.4.3 | IMAS core library | Yes |
| IMAS-AL-Cpp | 5.4.3 | C++ bindings | Recommended |
| IMAS-AL-Fortran | 5.4.3 | Fortran bindings | Recommended |
| IMAS-AL-Python | 5.4.3 | Python bindings | Recommended |
| IMAS-AL-Java | 5.4.3 | Java bindings | Optional |
| IMAS-AL-Matlab | 5.4.3 | MATLAB bindings | Optional |
| IMAS-AL-HDC | 5.4.3 | HDF5 backend | Yes |
| IMAS-AL-MDSplus-models | 5.4.3 | MDSplus models | Yes |
| IDS-Validator | 5.4.3 | Validation tools | Recommended |
| IDStools | 5.4.3 | Utility tools | Recommended |
| IMAS-Python | 5.4.3 | Python utilities | Recommended |
| IMAS | 5.4.3 | Complete suite | Yes |

### FOSS Toolchain Modules (foss-2023b)

Same modules as Intel, but with `foss-2023b` instead of `intel-2023b`.

## Minimal Installation

For a minimal working IMAS installation with Python support only:

```bash
# Base toolchain
eb intel-2023b.eb --robot --parallel 8

# Dependencies (will be auto-installed with --robot)
# - CMake, Ninja, Python build tools
# - HDF5, MDSplus, UDA, Boost, SciPy-bundle

# IMAS modules
eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8
eb IMAS-AL-Python-5.4.3-intel-2023b.eb --robot --parallel 8
eb IMAS-AL-HDC-5.4.3-intel-2023b.eb --robot --parallel 8
eb IMAS-5.4.3-intel-2023b.eb --robot --parallel 8
```

This provides IMAS with Python bindings and HDF5 backend support.

## Full Installation

For complete IMAS with all language bindings and features:

```bash
# Use the automated script
bash scripts/05_install_imas.sh intel 5.4.3

# Or install manually in order (see sections 1-7 above)
```

## Module Sizes (Approximate)

| Component | Disk Space |
|-----------|------------|
| intel-2023b toolchain | ~8 GB |
| foss-2023b toolchain | ~6 GB |
| Core dependencies | ~4 GB |
| IMAS-AL-Core | ~500 MB |
| Each language binding | ~200-500 MB |
| Backend support | ~300 MB |
| Utility tools | ~100 MB |
| **Total (full install)** | **~15-20 GB** |

## Build Times (Approximate)

On a modern 8-core system:

| Component | Build Time |
|-----------|------------|
| Toolchain (first time) | 1-2 hours |
| Core dependencies | 30-60 minutes |
| IMAS-AL-Core | 15-30 minutes |
| Each language binding | 10-20 minutes |
| Complete IMAS suite | 3-5 hours total |

Times vary significantly based on:
- CPU cores available
- Disk I/O speed
- Network speed (for downloads)
- Whether dependencies are pre-built

## Verification Commands

After installation, verify modules are available:

```bash
# List all IMAS modules
module avail IMAS

# Show module details
module spider IMAS/5.4.3-intel-2023b

# Load and test
module load IMAS/5.4.3-intel-2023b
python3 -c "import imas_core; print('IMAS loaded')"
```

## Module Dependencies Graph

```
intel-2023b (or foss-2023b)
├── CMake-3.27.6
├── Ninja-1.11.1
├── Python-3.11.x (from toolchain)
│   ├── scikit-build-core-0.9.3
│   ├── Cython-3.0.10
│   └── cython-cmake-0.2.0
├── HDF5-1.14.3
├── MDSplus-7.132.0
├── UDA-2.8.0
├── Boost-1.83.0
└── SciPy-bundle-2023.12
    └── NumPy, SciPy, pandas, etc.

IMAS-AL-Core-5.4.3
├── IMAS-AL-Cpp-5.4.3
├── IMAS-AL-Fortran-5.4.3
├── IMAS-AL-Python-5.4.3
├── IMAS-AL-Java-5.4.3 (optional)
├── IMAS-AL-Matlab-5.4.3 (optional)
├── IMAS-AL-HDC-5.4.3
└── IMAS-AL-MDSplus-models-5.4.3

IDS-Validator-5.4.3
IDStools-5.4.3
IMAS-Python-5.4.3

IMAS-5.4.3 (loads all of the above)
```

## Notes

1. **EasyBuild's --robot flag** automatically resolves and builds dependencies
2. **Parallel builds** significantly speed up compilation (use `--parallel N`)
3. **Source caching** means subsequent builds reuse downloaded files
4. **Module loading order** is handled automatically by Lmod
5. **Multiple versions** can coexist (e.g., 5.4.3 and 5.4.4)

## Custom Module Sets

### Development Set
For IMAS development work:
- Base toolchain
- IMAS-AL-Core
- One or two language bindings you use
- Debugging tools

### Production Set
For production simulations:
- Base toolchain
- Complete IMAS suite
- All required language bindings
- Full backend support

### Testing Set
For testing new versions:
- Separate toolchain version
- IMAS modules in test directory
- Isolated from production

## Updating Modules

To update to a newer IMAS version:

```bash
# Update ITER easyconfigs
cd /opt/easybuild/local-easyconfigs/imas-easyconfigs
git pull

# Check available versions
ls IMAS-AL-Core/

# Install new version (old version remains available)
eb IMAS-AL-Core-5.4.4-intel-2023b.eb --robot --parallel 8
eb IMAS-5.4.4-intel-2023b.eb --robot --parallel 8

# Users can choose which version to load
module load IMAS/5.4.3-intel-2023b  # old version
module load IMAS/5.4.4-intel-2023b  # new version
```

## Support

For module-specific issues:
- Check module load errors: `module load IMAS/5.4.3-intel-2023b`
- View module details: `module show IMAS/5.4.3-intel-2023b`
- Check dependencies: `module spider IMAS/5.4.3-intel-2023b`
- Review build logs: `/opt/easybuild/software/*/easybuild/*.log`

For more information:
- [IMAS Installation Guide](IMAS_INSTALL.md)
- [Main Documentation](docs/imas_installation.rst)
- [EasyBuild Documentation](https://docs.easybuild.io/)
