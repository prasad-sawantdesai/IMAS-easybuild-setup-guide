.. _operations:

=============================
Operations & Good Practices
=============================

Daily Operations
================

* Build as user, not root. Keep `/opt/easybuild` group-writable (`2775`) and ensure all builders are in `easybuildgrp`.
* Keep upstream fresh: periodically `git pull` and `rsync` to update easyconfigs.
* Pin EB 4.x in your user install; upgrade intentionally: `pip install --user -U 'easybuild==4.*'`.
* Never set deprecated `installpath-logs` option (removed in EB 4.x).

When to use root vs user:

**Use [root] for:**

* Installing OS packages (`dnf`)
* Installing Lmod and creating files in `/etc`
* Creating and permissioning the top-level `/opt/easybuild` directories
* Managing Unix groups and membership (`groupadd`, `usermod`)

**Use [user] for:**

* Installing EasyBuild with `pip --user` (or in a venv)
* Running `eb` builds
* Cloning upstream easyconfigs (destination must be group-writable)
* Day-to-day module usage (`module avail`, `module load`)

Tip: If you must modify files inside `/opt/easybuild` as root, keep them group-writable and owned by `:easybuildgrp`.

Continuous Integration & Testing
=================================

The repository includes GitHub Actions workflows for automated testing and documentation deployment:

**test-scripts.yml** - Tests the setup scripts on fresh systems:

* Runs on Rocky Linux 9 in a container
* Executes the full bootstrap process (root and user stages)
* Performs a test build (EasyBuild module)
* Validates the installation with the validation script
* Triggers on pushes to `main` or `develop` branches, pull requests, or manual dispatch

**sphinx.yaml** - Builds and deploys documentation:

* Builds Sphinx documentation from the `docs/` directory
* Deploys to GitHub Pages on pushes to the `main` branch
* Can be triggered manually via workflow dispatch

These workflows ensure that:

* Scripts work correctly on fresh installations
* No regressions are introduced by changes
* Documentation stays up-to-date and accessible

Adapting CI for your environment
---------------------------------

To use these workflows in your own environment:

1. Fork or copy the repository
2. Enable GitHub Actions in your repository settings
3. Enable GitHub Pages to deploy documentation
4. Modify `.github/workflows/test-scripts.yml` to test on your target distribution
5. Customize the test build in the workflow if needed (e.g., add custom easyconfigs)

Maintenance Tasks
=================

**Update upstream easyconfigs:**

.. code-block:: bash

   cd /opt/easybuild/easyconfigs/upstream
   git pull --ff-only
   rsync -rl --no-perms --no-owner --no-group --no-times easybuild/easyconfigs/ /opt/easybuild/easyconfigs/

**Clean build directories:**

.. code-block:: bash

   # Review what's consuming space
   du -sh /opt/easybuild/tmp/*
   
   # Remove old build directories (be careful!)
   rm -rf /opt/easybuild/tmp/eb-*

**Upgrade EasyBuild:**

.. code-block:: bash

   pip install --user --upgrade 'easybuild==4.*'
   eb --version

**Add custom easyconfigs:**

Place your custom `.eb` files in `/opt/easybuild/local-easyconfigs/`. They will be automatically discovered due to the `robot-paths` configuration.

**Validate easyconfigs:**

.. code-block:: bash

   # Dry-run to check dependencies
   eb --dry-run --robot MyCustomPackage-1.0.eb
   
   # Check for syntax errors
   eb --check-eb MyCustomPackage-1.0.eb
