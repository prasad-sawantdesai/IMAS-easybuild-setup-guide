# Using EasyBuild Scripts in CI/CD

When running EasyBuild commands in CI/CD environments (like GitHub Actions), you need to properly initialize the Lmod environment. Here's how:

## Method 1: Use the Validation Script

The easiest way is to use the provided validation script:

```bash
su - testuser -c "cd $GITHUB_WORKSPACE && bash scripts/04_validate.sh"
```

## Method 2: Source the Environment Initialization

For custom commands, source the environment initialization script first:

```bash
su - testuser -c "cd $GITHUB_WORKSPACE && source scripts/00_init_env.sh && module spider EasyBuild"
```

## Method 3: Run Commands in Sequence

If running multiple module commands, initialize once and run all commands in the same shell:

```bash
su - testuser -c "
  cd $GITHUB_WORKSPACE
  source scripts/00_init_env.sh
  module spider EasyBuild
  module load EasyBuild/4.9.0
  eb --version
"
```

## Why This is Needed

In CI/CD environments:
1. Each command runs in a fresh shell session
2. The shell may not be a login shell, so `/etc/profile.d/` scripts aren't automatically sourced
3. Lmod initialization must be explicitly performed
4. The custom module paths need to be added to `MODULEPATH`

## Script Overview

- `00_init_env.sh` - Initializes the EasyBuild + Lmod environment (source this first)
- `01_root_bootstrap.sh` - System-level setup (requires root)
- `02_user_bootstrap.sh` - User-level setup (installs EasyBuild)
- `03_build_example.sh` - Builds a test module (uses `00_init_env.sh`)
- `04_validate.sh` - Comprehensive validation test (uses `00_init_env.sh`)

## GitHub Actions Example

```yaml
- name: Run build example
  run: su - testuser -c "cd $GITHUB_WORKSPACE && bash scripts/03_build_example.sh"
  shell: bash

- name: Validate installation
  run: su - testuser -c "cd $GITHUB_WORKSPACE && bash scripts/04_validate.sh"
  shell: bash

- name: Test module command
  run: su - testuser -c "source scripts/00_init_env.sh && module avail EasyBuild"
  shell: bash
  working-directory: ${{ github.workspace }}
```
