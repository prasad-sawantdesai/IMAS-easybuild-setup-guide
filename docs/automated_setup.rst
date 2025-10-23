.. _automated_setup:

==================
Automated Setup
==================

This guide describes how to use the provided bootstrap scripts for a quick, automated installation of EasyBuild and Lmod. This is the recommended approach for new installations.

.. contents:: Page index
   :local:
   :depth: 2

---

Overview
========

The repository includes five bash scripts that automate the entire setup process:

1. **00_init_env.sh** - Environment initialization helper (sources Lmod and sets up paths)
2. **01_root_bootstrap.sh** - System-level setup (requires root)
3. **02_user_bootstrap.sh** - User-level EasyBuild installation
4. **03_build_example.sh** - Test build to validate the installation
5. **04_validate.sh** - Comprehensive validation of the installation

These scripts implement the same procedures described in the manual setup documentation but with error handling, validation, and sensible defaults.

---

Prerequisites
=============

Before running the scripts, ensure:

* You have a RHEL 8/9 or compatible system (Rocky Linux, AlmaLinux, etc.)
* You have root access (via ``sudo`` or direct root login)
* The system has internet connectivity
* You have cloned this repository or downloaded the scripts

---

Step 0: Environment Initialization (Optional)
==============================================

The **00_init_env.sh** script is a helper script that initializes the EasyBuild and Lmod environment. It can be sourced in other scripts or executed directly.

**What it does:**

* Sources Lmod initialization scripts
* Adds EasyBuild modules to MODULEPATH
* Displays environment status when executed (not sourced)

This script is automatically sourced by ``03_build_example.sh`` and ``04_validate.sh``, so you typically don't need to run it manually. However, you can use it in your own scripts or source it in your shell session:

.. code-block:: bash

   # Source it in your current shell
   source scripts/00_init_env.sh

   # Or execute it to see the environment status
   bash scripts/00_init_env.sh

Custom prefix
-------------

If you're using a custom installation prefix:

.. code-block:: bash

   PREFIX=/custom/path bash scripts/00_init_env.sh

---

Step 1: Root Bootstrap
======================

The first script sets up the system-level components.

**What it does:**

* Installs Development Tools and required packages
* Installs EPEL repository and Lmod
* Creates the ``/opt/easybuild`` directory structure
* Creates the ``easybuildgrp`` group
* Sets up proper permissions (setgid 2775)
* Adds specified user to the group (optional)
* Configures Lmod to find EasyBuild modules
* Creates global EasyBuild configuration file

Run as root
-----------

.. code-block:: bash

   sudo bash scripts/01_root_bootstrap.sh

With custom parameters
----------------------

You can customize the behavior using environment variables:

.. code-block:: bash

   # Custom prefix (default: /opt/easybuild)
   sudo PREFIX=/custom/path bash scripts/01_root_bootstrap.sh

   # Custom group name (default: easybuildgrp)
   sudo GROUP=mygroup bash scripts/01_root_bootstrap.sh

   # Add a specific user to the group
   sudo EB_USER_TO_ADD=yourname bash scripts/01_root_bootstrap.sh

   # Combine multiple options
   sudo PREFIX=/opt/eb GROUP=ebusers EB_USER_TO_ADD=john \
        bash scripts/01_root_bootstrap.sh

Script output
-------------

The script provides clear progress messages:

.. code-block:: text

   ==> Installing Development Tools group and base packages...
   ==> Enabling EPEL and installing Lmod...
   ==> Creating filesystem layout under /opt/easybuild...
   ==> Configuring Lmod to see EasyBuild module tree...
   ==> Writing global EasyBuild config to /etc/easybuild.d/easybuild.cfg...
   ==> Root stage complete.
   NOTE: If you added yourself to easybuildgrp, **log out and back in**...

**Important:** After running this script, you must **log out and log back in** (or run ``newgrp easybuildgrp``) to activate your group membership.

---

Step 2: User Bootstrap
======================

After logging back in, run the user bootstrap script to install EasyBuild and set up easyconfigs.

**What it does:**

* Adds ``~/.local/bin`` to PATH if needed
* Installs EasyBuild 4.x using pip to user site
* Clones the upstream easybuild-easyconfigs repository
* Syncs easyconfigs into the active tree
* Displays the active EasyBuild configuration

Run as regular user
-------------------

.. code-block:: bash

   bash scripts/02_user_bootstrap.sh

With custom prefix
------------------

If you used a custom prefix in step 1, specify it again:

.. code-block:: bash

   PREFIX=/custom/path bash scripts/02_user_bootstrap.sh

Verify group membership
-----------------------

Before running this script, verify you're in the correct group:

.. code-block:: bash

   id
   # Should show easybuildgrp (or your custom group name)

If the group doesn't appear, you need to log out and log back in.

User bootstrap output
---------------------

.. code-block:: text

   ==> Ensuring ~/.local/bin is on PATH...
   ==> Installing EasyBuild 4.x to user site...
   ==> Checking eb version...
   ==> Cloning upstream easyconfigs (if not present)...
   ==> Syncing upstream easyconfigs into active tree...
   ==> Showing EasyBuild config...
   User stage complete.

---

Step 3: Test Build
==================

The third script performs a test build to validate the entire setup. **Note:** This script builds the EasyBuild module itself as a lightweight test, not GCCcore.

**What it does:**

* Sources the environment initialization script (00_init_env.sh)
* Purges any loaded modules
* Builds EasyBuild 4.9.0 module with automatic dependency resolution
* Lists available modules
* Validates that the module can be loaded
* Shows module information

Run the test build
------------------

.. code-block:: bash

   bash scripts/03_build_example.sh

With custom parallelism
-----------------------

By default, the script uses all available CPU cores. You can limit this:

.. code-block:: bash

   PARALLEL=4 bash scripts/03_build_example.sh

What to expect
--------------

The build process will:

1. Download required sources (may take a few minutes)
2. Build EasyBuild module and its dependencies
3. Install to ``/opt/easybuild/software``
4. Create module files in ``/opt/easybuild/modules/all``

On success, you'll see:

.. code-block:: text

   Building EasyBuild module (lightweight test)...
   == building and installing EasyBuild/4.9.0...
   == COMPLETED: Installation ended successfully
   Listing modules...
   ------------------------- /opt/easybuild/modules/all --------------------------
   EasyBuild/4.9.0
   ✓ EasyBuild module loaded successfully

---

Step 4: Validation (Optional)
==============================

The fourth script performs comprehensive validation checks to ensure everything is working correctly.

**What it does:**

* Sources the environment initialization script
* Checks that software directories exist
* Verifies module files are created
* Tests module availability and discovery (``module avail``, ``module spider``)
* Tests module loading
* Verifies EasyBuild command functionality

Run validation
--------------

.. code-block:: bash

   bash scripts/04_validate.sh

Validation output
-----------------

On success, you'll see:

.. code-block:: text

   === EasyBuild Installation Validation ===
   
   1. Checking software installation...
   ✓ EasyBuild software directory exists
   
   2. Checking module files...
   ✓ EasyBuild module directory exists
   
   3. Testing module availability...
   ✓ EasyBuild module is available
   
   4. Testing module spider...
   ✓ module spider finds EasyBuild
   
   5. Testing module load...
   ✓ EasyBuild module loaded successfully
   
   === All validation checks passed! ===

If any check fails, the script will exit with an error and indicate which validation step failed.

---

Troubleshooting Script Issues
==============================

Script fails: Permission denied
--------------------------------

**Symptom:** ``ERROR: Cannot write to /opt/easybuild``

**Solution:** 

* Verify you ran the root bootstrap script first
* Check group membership: ``id`` should show ``easybuildgrp``
* Log out and log back in to activate group membership
* Try: ``newgrp easybuildgrp`` then run the script again

Script fails: Command not found
--------------------------------

**Symptom:** ``eb: command not found`` or ``module: command not found``

**Solution:**

* For ``eb``: Open a new shell or run ``source ~/.bashrc``
* For ``module``: Start a new login shell or run ``source /etc/profile.d/lmod.sh``

Script fails: dnf not found
----------------------------

**Symptom:** ``ERROR: This script expects a RHEL/Rocky-like system with dnf``

**Solution:** These scripts are designed for RHEL 8/9 and compatible systems. For other distributions, use the manual setup procedure.

Git clone fails
---------------

**Symptom:** Error cloning easybuild-easyconfigs repository

**Solution:**

* Check internet connectivity
* Verify you can access GitHub: ``curl -I https://github.com``
* If behind a proxy, configure git: ``git config --global http.proxy <proxy-url>``

---

Verifying the Installation
===========================

After all three scripts complete successfully, verify the setup:

Check EasyBuild version
-----------------------

.. code-block:: bash

   eb --version
   # Should show: This is EasyBuild 4.x.x

Check EasyBuild configuration
------------------------------

.. code-block:: bash

   eb --show-config
   # Should show settings from /etc/easybuild.d/easybuild.cfg

Check module system
-------------------

.. code-block:: bash

   module --version
   # Should show Lmod version
   
   module avail
   # Should list EasyBuild/4.9.0 if test build succeeded

Load and test a module
----------------------

.. code-block:: bash

   module load EasyBuild/4.9.0
   eb --version
   # Should show EasyBuild 4.9.0

---

Next Steps
==========

After successful automated setup:

1. **Build additional software**: Use ``eb <package>.eb --robot`` to build more packages
2. **Add custom easyconfigs**: Place them in ``/opt/easybuild/local-easyconfigs``
3. **Share with team**: Add other users to ``easybuildgrp`` with ``usermod -aG easybuildgrp <username>``
4. **Update easyconfigs**: Periodically update with:

   .. code-block:: bash

      cd /opt/easybuild/easyconfigs/upstream
      git pull
      rsync -a easybuild/easyconfigs/ /opt/easybuild/easyconfigs/

5. **Review best practices**: See :ref:`operations` for ongoing maintenance

---

Script Reference
================

All scripts support idempotent execution—safe to run multiple times.

Script locations
----------------

* ``scripts/00_init_env.sh`` - Environment initialization (can be sourced or executed)
* ``scripts/01_root_bootstrap.sh`` - Run as root
* ``scripts/02_user_bootstrap.sh`` - Run as regular user  
* ``scripts/03_build_example.sh`` - Run as regular user
* ``scripts/04_validate.sh`` - Run as regular user

Environment variables
---------------------

**00_init_env.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)

**01_root_bootstrap.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)
* ``GROUP`` - Unix group name (default: ``easybuildgrp``)
* ``EB_USER_TO_ADD`` - Username to add to group (optional)

**02_user_bootstrap.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)

**03_build_example.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)
* ``PARALLEL`` - Number of parallel build jobs (default: all cores)

**04_validate.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)

Script features
---------------

* **Error handling**: Scripts exit on first error (``set -euo pipefail``)
* **Validation**: Check prerequisites before proceeding
* **Idempotency**: Safe to run multiple times
* **Clear output**: Progress messages show what's happening
* **Customizable**: Environment variables for common changes

---

Comparing Automated vs Manual Setup
====================================

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Aspect
     - Automated (Scripts)
     - Manual (Step-by-step)
   * - Time required
     - 10-15 minutes
     - 30-60 minutes
   * - Skill level
     - Beginner friendly
     - Requires understanding
   * - Customization
     - Limited (env vars)
     - Full control
   * - Error handling
     - Automatic
     - Manual intervention
   * - Learning value
     - Less educational
     - More educational
   * - Use case
     - Production, quick setup
     - Learning, custom needs

**Recommendation:** Use automated setup for production systems or when you need quick deployment. Use manual setup when learning EasyBuild or if you need custom configurations not supported by the scripts.
