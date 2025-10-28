# IMAS-easybuild-setup-guide

A reproducible guide for setting up **EasyBuild** and **IMAS software stack** on Red Hat Enterprise Linux 8/9 with Lmod module system.

## Overview

This guide provides complete procedures to install and configure EasyBuild 4.x with Lmod on RHEL-based systems, plus complete IMAS (Integrated Modelling & Analysis Suite) installation. It supports both **userspace installation** (no root required) and **system-wide installation** (for administrators).

## Features

- **🏠 Userspace installation** - No root access needed! Install in your home directory
- **🖥️ System-wide installation** - Traditional setup under `/opt/easybuild` for shared systems
- **📦 Lmod integration** for environment module management
- **👥 Group-based permissions** for collaborative builds (system-wide only)
- **🤖 Automated bootstrap scripts** for quick setup
- **🔬 IMAS installation support** with private ITER repository integration
- **📚 Comprehensive documentation** with Sphinx
- Clear separation of root and user operations

## Quick Start

> 🚀 **New User?** See [USERSPACE_QUICKSTART.md](USERSPACE_QUICKSTART.md) for the fastest way to get started without root access!
> 
> 🤔 **Not sure which method?** See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for a decision tree to help you choose.

### Option 1: Userspace Installation (No Root Required) ⭐ NEW!

Perfect for users without administrative access or personal installations.

```bash
# Clone the repository
git clone https://github.com/prasad-sawantdesai/IMAS-easybuild-setup-guide.git
cd IMAS-easybuild-setup-guide

# Run userspace bootstrap (installs to ~/easybuild)
bash scripts/10_userspace_bootstrap.sh

# Reload environment
source ~/.bashrc

# Test the installation
bash scripts/11_userspace_test_build.sh

# Start using EasyBuild!
eb --search GCC
eb GCC-12.2.0.eb --robot
```

**Key advantages:**
- ✅ No root/sudo required
- ✅ No group management needed
- ✅ Install in 5-10 minutes
- ✅ Full control over your environment
- ✅ Can still share modules with others
- ✅ Easy to remove (just delete directory)

See [docs/userspace_setup.rst](docs/userspace_setup.rst) for full details.

---

### Option 2: System-wide Automated Setup (Requires Root)

Use the provided scripts for system-wide installation. Recommended for administrators managing shared systems.

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

**IMAS Installation:**

For IMAS installation, follow the detailed manual instructions in [docs/imas_installation.rst](docs/imas_installation.rst) or see [IMAS_INSTALL.md](IMAS_INSTALL.md) for a quick reference.

**When to use which approach:**
- **Userspace**: No root access, personal use, testing, quick setup
- **System-wide Automated**: Production deployments with multiple users, standard configurations
- **Manual**: Learning EasyBuild, custom configurations, non-standard requirements

---

### Option 3: Manual Setup

Follow the detailed step-by-step documentation in the `docs/` directory:

**Userspace Setup:**

1. Review [Prerequisites](docs/prerequisites.rst)
2. Follow [Userspace Setup Guide](docs/userspace_setup.rst)
3. Start building software!

**System-wide Setup:**

1. Review [Prerequisites](docs/prerequisites.rst)
2. Set up [Filesystem Layout](docs/filesystem.rst)
3. Install [Lmod](docs/lmod.rst)
4. Install [EasyBuild](docs/easybuild_install.rst)
5. Configure [EasyBuild Settings](docs/config.rst)
6. Set up [Easyconfigs](docs/easyconfigs.rst)
7. Perform [First Build](docs/first_build.rst)

**IMAS Installation:**

8. Follow [IMAS Installation Guide](docs/imas_installation.rst) for complete IMAS setup

---

## Installation Comparison

| Feature | Userspace | System-wide |
|---------|-----------|-------------|
| Root access needed | ❌ No | ✅ Yes (initial) |
| Setup time | 5-10 min | 10-15 min |
| Location | `~/easybuild` | `/opt/easybuild` |
| Group management | ❌ Not needed | ✅ Required |
| Multi-user by default | ❌ No | ✅ Yes |
| Module sharing | Manual | Automatic |
| Easy removal | ✅ Just delete dir | Requires root |
| Best for | Personal, testing | Production, teams |

---

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

**Userspace Installation:**
- **No root**: Everything installs in your home directory
- **No groups**: File ownership is yours alone
- **Independence**: Full control without administrator involvement
- **Sharing**: Optional - make directories readable to share modules

**System-wide Installation:**
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

**Userspace installation defaults:**

- **Install prefix**: `~/easybuild` (customizable with `PREFIX` env var)
- **Software**: `~/easybuild/software`
- **Modules**: `~/easybuild/modules`
- **Source cache**: `~/easybuild/src`
- **Build temp**: `~/easybuild/tmp`
- **Module tool**: Lmod (or EnvironmentModules)
- **No group needed**: Files owned by you

**System-wide installation defaults:**

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
