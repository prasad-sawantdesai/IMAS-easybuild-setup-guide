# Complete IMAS Module List

This document lists all modules required for a complete IMAS installation with the latest available versions.

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
# Core library (required) - Latest stable version
eb IMAS-AL-Core-5.4.3-${TOOLCHAIN}.eb --robot --parallel 8

# Or use latest version
eb IMAS-AL-Core-5.5.0-${TOOLCHAIN}.eb --robot --parallel 8
```

### 4. IMAS Language Bindings

Install the language bindings you need. Note that language bindings require a Data Dictionary (DD) version.

**For IMAS 4.0.0 (latest):**

```bash
# C++ bindings
eb IMAS-AL-Cpp-5.4.0-${TOOLCHAIN}-DD-4.0.0.eb --robot --parallel 8

# Fortran bindings
eb IMAS-AL-Fortran-5.4.0-${TOOLCHAIN}-DD-4.0.0.eb --robot --parallel 8

# Python bindings
eb IMAS-AL-Python-5.4.0-${TOOLCHAIN}-DD-4.0.0.eb --robot --parallel 8

# Java bindings (optional)
eb IMAS-AL-Java-5.4.0-${TOOLCHAIN}-DD-4.0.0.eb --robot --parallel 8

# MATLAB bindings (optional)
eb IMAS-AL-Matlab-5.4.0-${TOOLCHAIN}-DD-4.0.0.eb --robot --parallel 8
```

**For IMAS 3.42.0:**

```bash
# C++ bindings
eb IMAS-AL-Cpp-5.3.0-${TOOLCHAIN}-DD-3.42.0.eb --robot --parallel 8

# Fortran bindings
eb IMAS-AL-Fortran-5.3.0-${TOOLCHAIN}-DD-3.42.0.eb --robot --parallel 8

# Python bindings
eb IMAS-AL-Python-5.4.0-${TOOLCHAIN}-DD-3.42.0.eb --robot --parallel 8

# Java bindings (optional)
eb IMAS-AL-Java-5.3.0-${TOOLCHAIN}-DD-3.42.0.eb --robot --parallel 8

# MATLAB bindings (optional)
eb IMAS-AL-Matlab-5.3.0-${TOOLCHAIN}-DD-3.42.0.eb --robot --parallel 8
```

### 5. IMAS Backend Support

```bash
# MDSplus backend models (toolchain-independent for some versions)
# For IMAS 4.0.0
eb IMAS-AL-MDSplus-models-5.2.2-GCCcore-13.2.0-DD-4.0.0.eb --robot --parallel 8

# For IMAS 3.42.0
eb IMAS-AL-MDSplus-models-5.2.2-GCCcore-13.2.0-DD-3.42.0.eb --robot --parallel 8

# Or with specific toolchain
eb IMAS-AL-MDSplus-models-5.2.2-${TOOLCHAIN}-DD-4.0.0.eb --robot --parallel 8
```

**Note:** HDC (HDF5 Data Container) backend is typically included in IMAS-AL-Core and doesn't require a separate module.

### 6. IMAS Utility Tools (Optional)

```bash
# IDStools - Utility tools for working with IDS
eb IDStools-2.3.0-${TOOLCHAIN}.eb --robot --parallel 8
```

**Note:** Other utility tools like IDS-Validator and IMAS-Python may be included in the main IMAS module or available separately depending on your easyconfig repository.

### 7. IMAS Complete Suite

```bash
# Meta-module that loads complete IMAS environment
# For latest version (4.0.0)
eb IMAS-4.0.0-${TOOLCHAIN}.eb --robot --parallel 8
# Or with date suffix
eb IMAS-4.0.0-2024.12-${TOOLCHAIN}.eb --robot --parallel 8

# For stable version (3.42.0)
eb IMAS-3.42.0-${TOOLCHAIN}.eb --robot --parallel 8
# Or with date suffix
eb IMAS-3.42.0-2024.09-${TOOLCHAIN}.eb --robot --parallel 8
```

**Available IMAS Versions:**
- **IMAS 4.0.0** (December 2024) - Latest version with DD 4.0.0
- **IMAS 3.42.0** (September 2024) - Stable version with DD 3.42.0

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
| IMAS-AL-Core | 5.4.3 / 5.5.0 | IMAS core library | Yes |
| IMAS-AL-Cpp | 5.4.0 + DD-4.0.0 | C++ bindings | Recommended |
| IMAS-AL-Fortran | 5.4.0 + DD-4.0.0 | Fortran bindings | Recommended |
| IMAS-AL-Python | 5.4.0 + DD-4.0.0 | Python bindings | Recommended |
| IMAS-AL-Java | 5.4.0 + DD-4.0.0 | Java bindings | Optional |
| IMAS-AL-Matlab | 5.4.0 + DD-4.0.0 | MATLAB bindings | Optional |
| IMAS-AL-MDSplus-models | 5.2.2 + DD-4.0.0 | MDSplus models | Yes |
| IDStools | 2.3.0 | IDS utility tools | Recommended |
| IMAS | 4.0.0 / 3.42.0 | Complete suite | Yes |

**Note:** Language bindings require matching Data Dictionary (DD) versions. Use DD-4.0.0 for IMAS 4.0.0 or DD-3.42.0 for IMAS 3.42.0.

### FOSS Toolchain Modules (foss-2023b)

Same modules as Intel, but with `foss-2023b` instead of `intel-2023b`.

## Minimal Installation

For a minimal working IMAS installation with Python support only:

**For IMAS 4.0.0 (Latest):**

```bash
# Base toolchain
eb intel-2023b.eb --robot --parallel 8

# Dependencies (will be auto-installed with --robot)
# - CMake, Ninja, Python build tools
# - HDF5, MDSplus, UDA, Boost, SciPy-bundle

# IMAS modules
eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8
eb IMAS-AL-Python-5.4.0-intel-2023b-DD-4.0.0.eb --robot --parallel 8
eb IDStools-2.3.0-intel-2023b.eb --robot --parallel 8
eb IMAS-4.0.0-intel-2023b.eb --robot --parallel 8
```

**For IMAS 3.42.0 (Stable):**

```bash
eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8
eb IMAS-AL-Python-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8
eb IDStools-2.3.0-intel-2023b.eb --robot --parallel 8
eb IMAS-3.42.0-intel-2023b.eb --robot --parallel 8
```

This provides IMAS with Python bindings and HDF5 backend support.

## Full Installation

For complete IMAS with all language bindings and features, install modules manually in the order specified in sections 1-7 above.

See [docs/imas_installation.rst](docs/imas_installation.rst) for detailed installation instructions.

**Note:** The installation process typically takes 3-5 hours depending on your system and the modules selected.

## Module Sizes (Approximate)

| Component | Disk Space |
|-----------|------------|
| intel-2023b toolchain | ~8 GB |
| foss-2023b toolchain | ~6 GB |
| Core dependencies | ~4 GB |
| IMAS-AL-Core | ~500 MB |
| Each language binding (with DD) | ~200-500 MB |
| MDSplus models | ~300 MB |
| IDStools | ~50 MB |
| IMAS meta-module | ~100 MB |
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

# Show module details for latest version
module spider IMAS/4.0.0-intel-2023b

# Show module details for stable version
module spider IMAS/3.42.0-intel-2023b

# Load and test (IMAS 4.0.0)
module load IMAS/4.0.0-intel-2023b
python3 -c "import imas; print('IMAS 4.0.0 loaded successfully')"

# Or load stable version (IMAS 3.42.0)
module load IMAS/3.42.0-intel-2023b
python3 -c "import imas; print('IMAS 3.42.0 loaded successfully')"

# Check IMAS-AL-Core version
module avail IMAS-AL-Core
module load IMAS-AL-Core/5.4.3-intel-2023b
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

IMAS-AL-Core-5.4.3 (or 5.5.0)
├── IMAS-AL-Cpp-5.4.0-DD-4.0.0
├── IMAS-AL-Fortran-5.4.0-DD-4.0.0
├── IMAS-AL-Python-5.4.0-DD-4.0.0
├── IMAS-AL-Java-5.4.0-DD-4.0.0 (optional)
├── IMAS-AL-Matlab-5.4.0-DD-4.0.0 (optional)
└── IMAS-AL-MDSplus-models-5.2.2-DD-4.0.0

IDStools-2.3.0 (utility tools)

IMAS-4.0.0-intel-2023b (or IMAS-3.42.0-intel-2023b)
  └── Loads all language bindings, backends, and utilities

Version aliases:
  IMAS/4.0.0-intel-2023b → IMAS/4.0.0-2024.12-intel-2023b
  IMAS/3.42.0-intel-2023b → IMAS/3.42.0-2024.09-intel-2023b
  IMAS-AL-Core/5-intel-2023b → IMAS-AL-Core/5.4.3-intel-2023b
```

**Key Points:**
- Language bindings include Data Dictionary (DD) version suffix
- MDSplus models can use GCCcore instead of full toolchain
- Main IMAS module may include date suffix (e.g., 2024.12)

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
ls IMAS/
ls IMAS-AL-Core/

# Install new version (old version remains available)
eb IMAS-AL-Core-5.5.0-intel-2023b.eb --robot --parallel 8
eb IMAS-4.0.0-intel-2023b.eb --robot --parallel 8

# Users can choose which version to load
module load IMAS/3.42.0-intel-2023b     # stable version (Sep 2024)
module load IMAS/4.0.0-intel-2023b      # latest version (Dec 2024)
module load IMAS/4.0.0-2024.12-intel-2023b  # with date suffix
```

**Available IMAS Versions:**
- **3.42.0** (September 2024) - Stable production version
- **4.0.0** (December 2024) - Latest version with new features

**Available IMAS-AL-Core Versions:**
- 5.2.3, 5.2.5, 5.2.6 - Older stable versions
- 5.3.0, 5.3.2 - Mid-range versions
- 5.4.0, 5.4.1, 5.4.2, 5.4.3 - Current stable versions
- 5.5.0 - Latest version

## Version Compatibility Matrix

| IMAS Version | AL-Core | AL Bindings | Data Dictionary | Release Date |
|--------------|---------|-------------|-----------------|--------------|
| 4.0.0 | 5.4.0+ | 5.4.0 | 4.0.0 | Dec 2024 |
| 3.42.0 | 5.3.0+ | 5.3.0-5.4.0 | 3.42.0 | Sep 2024 |
| 3.41.0 | 5.2.1-5.2.3 | 5.2.1-5.2.3 | 3.41.0 | Earlier 2024 |
| 3.39.0 | 5.2.2+ | 5.3.0+ | 3.39.0 | Earlier 2024 |

**Recommendation:** Use IMAS 4.0.0 for new projects, IMAS 3.42.0 for production stability.

## Support

For module-specific issues:
- Check module load errors: `module load IMAS/4.0.0-intel-2023b`
- View module details: `module show IMAS/4.0.0-intel-2023b`
- Check dependencies: `module spider IMAS/4.0.0-intel-2023b`
- List all available versions: `module avail IMAS`
- Review build logs: `/opt/easybuild/software/*/easybuild/*.log`

For more information:
- [IMAS Installation Guide](IMAS_INSTALL.md)
- [Main Documentation](docs/imas_installation.rst)
- [EasyBuild Documentation](https://docs.easybuild.io/)
- [ITER IMAS Portal](https://imas.iter.org/)
