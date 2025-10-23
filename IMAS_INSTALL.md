# IMAS Installation Guide

Quick reference for installing IMAS (Integrated Modelling & Analysis Suite) using EasyBuild.

## Prerequisites

1. **Complete base EasyBuild setup** - Follow the main README or automated setup scripts
2. **ITER git access** - Credentials for git.iter.org
3. **Disk space** - At least 50GB free for complete IMAS installation
4. **Time** - Plan for 3-5 hours of automated compilation

## Quick Start

### Manual Installation

Follow the detailed step-by-step instructions in [docs/imas_installation.rst](docs/imas_installation.rst).

For a quick reference of all required modules, see [IMAS_MODULES.md](IMAS_MODULES.md).

**Basic installation order:**

1. Setup ITER private repository
2. Install base toolchain (intel-2023b or foss-2023b)
3. Install IMAS-AL-Core
4. Install language bindings (Cpp, Fortran, Python, etc.)
5. Install backend support (MDSplus-models)
6. Install utilities (IDS-Validator, IDStools)
7. Install IMAS meta-module

See the full documentation for detailed commands and troubleshooting.

## IMAS Modules Overview

The installation includes:

**Core Components:**
- IMAS-AL-Core - Core library (required)

**Language Bindings:**
- IMAS-AL-Cpp - C++ bindings
- IMAS-AL-Fortran - Fortran bindings
- IMAS-AL-Python - Python bindings
- IMAS-AL-Java - Java bindings (optional)
- IMAS-AL-Matlab - MATLAB bindings (optional)

**Backend Support:**
- IMAS-AL-Core - Includes HDC (HDF5 Data Container) backend
- IMAS-AL-MDSplus-models - MDSplus backend

**Utilities:**
- IDS-Validator - Validation tools
- IDStools - Utility tools
- IMAS-Python - Python utilities

**Complete Suite:**
- IMAS - Meta-module loading complete environment

## Manual Installation

If you prefer step-by-step control:

```bash
# 1. Clone ITER easyconfigs
cd /opt/easybuild/local-easyconfigs
git clone https://git.iter.org/scm/imex/easybuild-easyconfigs.git imas-easyconfigs

# 2. Create IMAS work directory
sudo mkdir -p /work/imas
sudo chown :easybuildgrp /work/imas
sudo chmod 2775 /work/imas

# 3. Install toolchain
module load EasyBuild
eb intel-2023b.eb --robot --parallel 8

# 4. Install IMAS Core
eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8

# 5. Install other modules as needed
eb IMAS-AL-Python-5.4.3-intel-2023b.eb --robot --parallel 8
eb IMAS-5.4.3-intel-2023b.eb --robot --parallel 8
```

## Authentication Setup

### SSH Keys (Recommended)

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your.email@iter.org"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Copy public key
cat ~/.ssh/id_rsa.pub
# Add this to your ITER git account settings
```

### HTTPS with Credentials

If SSH is not available, HTTPS with credentials will be used (you'll be prompted).

## Toolchain Comparison

| Aspect | Intel (intel-2023b) | FOSS (foss-2023b) |
|--------|---------------------|-------------------|
| Compiler | Intel C/C++/Fortran | GCC |
| Performance | Optimized for Intel CPUs | Good general performance |
| License | Requires Intel license | Fully open source |
| Portability | Intel hardware | Any hardware |
| Support | Commercial | Community |
| Recommended for | Production, Intel systems | Development, portability |

## Troubleshooting

### Authentication Failed

**Problem:** Cannot access git.iter.org

**Solution:**
```bash
# Test connection
ssh -T git@git.iter.org
# or
curl -I https://git.iter.org

# Configure proxy if needed
git config --global http.proxy http://proxy:port
```

### Build Timeout

**Problem:** Build takes too long or times out

**Solution:**
```bash
# Use more parallel jobs (if you have CPU cores available)
eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 16

# Or build dependencies separately first
eb HDF5-1.14.3-intel-2023b.eb --robot --parallel 8
eb MDSplus-7.132.0-intel-2023b.eb --robot --parallel 8
```

### Permission Denied

**Problem:** Cannot write to installation directory

**Solution:**
```bash
# Check group membership
groups  # Should show 'easybuildgrp'

# If not, add yourself and log out/in
sudo usermod -aG easybuildgrp $USER
# Then log out and log back in

# Or use newgrp temporarily
newgrp easybuildgrp
```

### Python Import Error

**Problem:** Cannot import imas_core

**Solution:**
```bash
# Ensure module is loaded
module purge
module load IMAS/5.4.3-intel-2023b

# Check Python path
echo $PYTHONPATH

# Test import with verbose output
python3 -c "import sys; print(sys.path); import imas_core"
```

## Using IMAS

### Load Module

```bash
module purge
module load IMAS/5.4.3-intel-2023b
```

### Create Alias

```bash
# Add to ~/.bashrc
echo "alias load-imas='module purge && module load IMAS/5.4.3-intel-2023b'" >> ~/.bashrc

# Use it
load-imas
```

### Test Installation

```python
#!/usr/bin/env python3
import imas_core
import os

print(f"IMAS Home: {os.environ.get('IMAS_HOME')}")
print(f"AL Version: {os.environ.get('AL_VERSION')}")
print(f"IMAS Core: {imas_core.__version__ if hasattr(imas_core, '__version__') else 'loaded'}")
print("IMAS is ready!")
```

## Environment Variables

When IMAS module is loaded, these variables are set:

- `IMAS_HOME` - IMAS work directory (/work/imas)
- `AL_VERSION` - Access Layer version (5.4.3)
- `AL_COMMON_PATH` - Common data files location
- `HDF5_USE_FILE_LOCKING` - Disabled for compatibility
- `IMAS_LOCAL_HOSTS` - Local UDA hosts

## Configuration

### Custom IMAS Work Directory

Edit `/etc/easybuild.d/easybuild.cfg` or create custom easyconfig:

```python
modextravars = {
    'IMAS_HOME': '/custom/path/imas',
    # ... other variables
}
```

### Multiple Versions

Install multiple IMAS versions side-by-side:

```bash
# Install version 5.4.3
eb IMAS-5.4.3-intel-2023b.eb --robot --parallel 8

# Install version 5.4.4
eb IMAS-5.4.4-intel-2023b.eb --robot --parallel 8

# Choose which to load
module load IMAS/5.4.3-intel-2023b
# or
module load IMAS/5.4.4-intel-2023b
```

## Maintenance

### Update ITER Easyconfigs

```bash
cd /opt/easybuild/local-easyconfigs/imas-easyconfigs
git pull origin main

# Check for new versions
ls -la IMAS-AL-Core/
```

### Clean Build Artifacts

```bash
# Clean temporary build directories
eb --clean-tmpdir

# Or manually
sudo rm -rf /opt/easybuild/tmp/eb-*
```

### Rebuild Module

```bash
# Force rebuild of a module
eb IMAS-AL-Core-5.4.3-intel-2023b.eb --force --robot --parallel 8
```

## Performance Tips

1. **Use parallel builds:** Increase `--parallel` value based on available CPU cores
2. **Build dependencies first:** Install HDF5, MDSplus, etc. separately before IMAS
3. **Use fast storage:** Ensure `/opt/easybuild` is on fast disk (SSD preferred)
4. **Monitor resources:** Watch CPU, memory, and disk usage during builds
5. **Consider build server:** Use dedicated build server for large installations

## Resources

- **IMAS Documentation:** https://imas.iter.org/
- **EasyBuild Docs:** https://docs.easybuild.io/
- **ITER Git:** https://git.iter.org/
- **This Guide:** See `docs/imas_installation.rst` for detailed information

## Support

For issues:

1. Check this guide and troubleshooting section
2. Review log files in `/tmp/eb_*.log`
3. Check EasyBuild logs in `/opt/easybuild/software/*/easybuild/*.log`
4. Contact ITER support or your local IMAS administrator

## Version Information

- **IMAS Version:** 5.4.3
- **Toolchains:** intel-2023b, foss-2023b
- **EasyBuild:** 4.9.0+
- **Lmod:** 8.7+

Last updated: 2024
