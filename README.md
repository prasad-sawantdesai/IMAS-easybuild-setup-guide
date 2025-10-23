# IMAS-easybuild-setup-guide

A reproducible guide for setting up **EasyBuild** and **IMAS software stack** on Red Hat Enterprise Linux 8/9 with Lmod module system.

## Overview

This guide provides a complete, step-by-step procedure to install and configure EasyBuild 4.x with Lmod on RHEL-based systems, plus complete IMAS (Integrated Modelling & Analysis Suite) installation. It includes system-wide setup instructions, automated bootstrap scripts, and comprehensive documentation for building and managing software modules.

## Features

- **System-wide EasyBuild installation** under `/opt/easybuild`
- **Lmod integration** for environment module management
- **Group-based permissions** for collaborative builds
- **Automated bootstrap scripts** for quick setup
- **IMAS installation support** with private ITER repository integration
- **Comprehensive documentation** with Sphinx
- Clear separation of root and user operations

## Repository Structure

```
.
├── docs/                           # Sphinx documentation
│   ├── index.rst                  # Documentation homepage
│   ├── prerequisites.rst          # System requirements and user model
│   ├── automated_setup.rst        # Automated setup using scripts
│   ├── filesystem.rst             # Directory layout and permissions
│   ├── lmod.rst                   # Lmod installation and configuration
│   ├── easybuild_install.rst      # EasyBuild installation guide
│   ├── config.rst                 # EasyBuild configuration
│   ├── easyconfigs.rst            # Managing easyconfig files
│   ├── first_build.rst            # First test build
│   ├── operations.rst             # Operational best practices
│   ├── troubleshooting.rst        # Common issues and solutions
│   ├── command_log.rst            # Complete command reference
│   ├── conf.py                    # Sphinx configuration
│   └── requirements.txt           # Documentation build dependencies
│
├── scripts/                        # Automated setup scripts
│   ├── 00_init_env.sh             # Environment initialization helper
│   ├── 01_root_bootstrap.sh       # System-level setup (run as root)
│   ├── 02_user_bootstrap.sh       # User-level setup (EasyBuild install)
│   ├── 03_build_example.sh        # Test build script (EasyBuild module)
│   ├── 04_validate.sh             # Validation script for installation
│   ├── 05_install_imas.sh         # IMAS installation script
│   └── 06_validate_imas.sh        # IMAS validation script
│
├── .github/workflows/             # CI/CD workflows
│   ├── test-scripts.yml           # GitHub Actions test workflow
│   └── sphinx.yaml                # Documentation build and deployment
│
├── LICENSE                         # Project license
└── README.md                       # This file
```

## Quick Start

### Option 1: Automated Setup (Recommended)

Use the provided scripts for quick installation. See [docs/automated_setup.rst](docs/automated_setup.rst) for full details.

**Base EasyBuild Setup:**

1. **Run root bootstrap** (as root):
   ```bash
   sudo bash scripts/01_root_bootstrap.sh
   ```

2. **Re-login** to apply group membership, then run user bootstrap:
   ```bash
   bash scripts/02_user_bootstrap.sh
   ```

3. **Test the installation**:
   ```bash
   bash scripts/03_build_example.sh
   ```

4. **Validate the setup** (optional):
   ```bash
   bash scripts/04_validate.sh
   ```

**IMAS Installation (Optional):**

5. **Install IMAS** (requires ITER git access):
   ```bash
   # Install with Intel toolchain
   bash scripts/05_install_imas.sh intel 5.4.3
   
   # Or install with FOSS toolchain
   bash scripts/05_install_imas.sh foss 5.4.3
   ```

6. **Validate IMAS installation**:
   ```bash
   bash scripts/06_validate_imas.sh intel-2023b 5.4.3
   ```

7. **Use IMAS**:
   ```bash
   module load IMAS/5.4.3-intel-2023b
   python3 -c "import imas_core; print('IMAS ready!')"
   ```

See [IMAS_INSTALL.md](IMAS_INSTALL.md) for detailed IMAS installation instructions.

### Option 2: Manual Setup

Follow the detailed step-by-step documentation in the `docs/` directory:

**Base EasyBuild Setup:**

1. Review [Prerequisites](docs/prerequisites.rst)
2. Set up [Filesystem Layout](docs/filesystem.rst)
3. Install [Lmod](docs/lmod.rst)
4. Install [EasyBuild](docs/easybuild_install.rst)
5. Configure [EasyBuild Settings](docs/config.rst)
6. Set up [Easyconfigs](docs/easyconfigs.rst)
7. Perform [First Build](docs/first_build.rst)

**IMAS Installation:**

8. Follow [IMAS Installation Guide](docs/imas_installation.rst) for complete IMAS setup

**When to use which approach:**
- **Automated**: Production deployments, quick setup, standard configurations
- **Manual**: Learning EasyBuild, custom configurations, non-standard requirements

## Documentation

Build the documentation locally:

```bash
cd docs
pip install -r requirements.txt
make html
```

View the generated documentation at `docs/_build/html/index.html`.

## Key Concepts

- **Root operations**: System package installation, directory creation, permission setup
- **User operations**: EasyBuild installation, running builds, module management
- **Group model**: Users in `easybuildgrp` can collaboratively build software
- **Setgid permissions**: Ensures new files inherit proper group ownership

## System Requirements

- **OS**: Red Hat Enterprise Linux 8/9 (or compatible clones like Rocky Linux, AlmaLinux)
- **Network**: Internet access for downloading sources
- **Permissions**: Root access for initial setup, regular user for builds
- **Storage**: Adequate space under `/opt/easybuild` for software installations

## Configuration

The default configuration uses:

- **Install prefix**: `/opt/easybuild`
- **Software**: `/opt/easybuild/software`
- **Modules**: `/opt/easybuild/modules`
- **Source cache**: `/opt/easybuild/src`
- **Build temp**: `/opt/easybuild/tmp`
- **Module tool**: Lmod
- **Group**: `easybuildgrp`

## Troubleshooting

Common issues and solutions are documented in [docs/troubleshooting.rst](docs/troubleshooting.rst), including:

- Command not found errors (`eb`, `module`)
- Permission denied issues
- Lmod module path configuration
- Group membership problems

## Next Steps

After successful installation, consider:

**Base EasyBuild:**
- **Adding site-specific easyconfig files** - Place them in `/opt/easybuild/local-easyconfigs`
- **Building additional software** - Use `eb <package>.eb --robot` to build more packages
- **Updating easyconfigs** - Periodically pull latest configs from upstream
- **Maintenance tasks** - Clean up temporary build directories in `/opt/easybuild/tmp`
- **Team collaboration** - Add other users to `easybuildgrp` group
- **Setting up CI** - Adapt the provided GitHub Actions workflows for your environment

**IMAS:**
- **Install IMAS modules** - Follow the IMAS installation guide
- **Configure IMAS backends** - Set up HDF5, MDSplus, and UDA data storage
- **Test IMAS workflows** - Run example simulations and data analysis
- **Multiple versions** - Install different IMAS versions for testing
- **Language bindings** - Install additional language bindings as needed

For detailed operational guidance, see the [operations documentation](docs/operations.rst) and [IMAS installation guide](docs/imas_installation.rst).

## Testing

The repository includes a GitHub Actions workflow that automatically tests the setup scripts on minimal systems. This ensures:
- Scripts work on fresh installations
- No regressions are introduced
- Multi-distribution compatibility

### Continuous Integration

The GitHub Actions workflow automatically tests the scripts on:
- **Rocky Linux 9** - Full installation with test build and validation

The workflow runs automatically on:
- Every push to `main` or `develop` branches
- Every pull request
- Manual trigger via GitHub Actions UI

See `.github/workflows/test-scripts.yml` for the complete CI configuration.

## Contributing

Contributions are welcome! Please ensure:

- Scripts remain idempotent and well-documented
- Documentation follows the existing RST format
- Changes are tested on RHEL 8/9

## License

See [LICENSE](LICENSE) file for details.

## Support

For issues specific to:
- **EasyBuild**: Visit [EasyBuild documentation](https://docs.easybuild.io/)
- **Lmod**: Visit [Lmod documentation](https://lmod.readthedocs.io/)
- **IMAS**: Consult IMAS-specific documentation
