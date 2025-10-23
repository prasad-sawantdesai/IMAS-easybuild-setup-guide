# IMAS-easybuild-setup-guide

A reproducible guide for setting up **EasyBuild** and **IMAS software stack** on Red Hat Enterprise Linux 8/9 with Lmod module system.

## Overview

This guide provides a complete, step-by-step procedure to install and configure EasyBuild 4.x with Lmod on RHEL-based systems. It includes system-wide setup instructions, automated bootstrap scripts, and comprehensive documentation for building and managing software modules.

## Features

- **System-wide EasyBuild installation** under `/opt/easybuild`
- **Lmod integration** for environment module management
- **Group-based permissions** for collaborative builds
- **Automated bootstrap scripts** for quick setup
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
│   ├── first_build.rst            # First test build (GCCcore)
│   ├── operations.rst             # Operational best practices
│   ├── troubleshooting.rst        # Common issues and solutions
│   ├── command_log.rst            # Complete command reference
│   ├── conf.py                    # Sphinx configuration
│   └── requirements.txt           # Documentation build dependencies
│
├── scripts/                        # Automated setup scripts
│   ├── 01_root_bootstrap.sh       # System-level setup (run as root)
│   ├── 02_user_bootstrap.sh       # User-level setup (EasyBuild install)
│   └── 03_build_example.sh        # Test build script (GCCcore 13.2.0)
│
├── .github/workflows/             # CI/CD workflows
│   └── test-scripts.yml           # GitHub Actions test workflow
│
├── next_steps                      # Post-installation recommendations
├── LICENSE                         # Project license
└── README.md                       # This file
```

## Quick Start

### Option 1: Automated Setup (Recommended)

Use the provided scripts for quick installation. See [docs/automated_setup.rst](docs/automated_setup.rst) for full details.

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

### Option 2: Manual Setup

Follow the detailed step-by-step documentation in the `docs/` directory:

1. Review [Prerequisites](docs/prerequisites.rst)
2. Set up [Filesystem Layout](docs/filesystem.rst)
3. Install [Lmod](docs/lmod.rst)
4. Install [EasyBuild](docs/easybuild_install.rst)
5. Configure [EasyBuild Settings](docs/config.rst)
6. Set up [Easyconfigs](docs/easyconfigs.rst)
7. Perform [First Build](docs/first_build.rst)

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

After successful installation, see the [`next_steps`](next_steps) file for:

- Adding site-specific easyconfig files
- Setting up CI validation
- Maintenance tasks (pruning build directories)

## Testing

The repository includes a GitHub Actions workflow that automatically tests the setup scripts on minimal systems. This ensures:
- Scripts work on fresh installations
- No regressions are introduced
- Multi-distribution compatibility

### Continuous Integration

The GitHub Actions workflow automatically tests the scripts on:
- **Rocky Linux 9** - Full installation with test build
- **Rocky Linux 8** - Installation verification only

The workflow runs automatically on:
- Every push to `main` or `develop` branches
- Every pull request
- Manual trigger via GitHub Actions UI

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
