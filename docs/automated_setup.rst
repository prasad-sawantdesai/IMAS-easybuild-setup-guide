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

The repository includes three bash scripts that automate the entire setup process:

1. **01_root_bootstrap.sh** - System-level setup (requires root)
2. **02_user_bootstrap.sh** - User-level EasyBuild installation
3. **03_build_example.sh** - Test build to validate the installation

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

Script output
-------------

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

The final script performs a test build to validate the entire setup.

**What it does:**

* Purges any loaded modules
* Builds GCCcore 13.2.0 with automatic dependency resolution
* Lists available modules
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
2. Build GCCcore and its dependencies
3. Install to ``/opt/easybuild/software``
4. Create module files in ``/opt/easybuild/modules/all``

On success, you'll see:

.. code-block:: text

   Building GCCcore 13.2.0 with --robot...
   == building and installing GCCcore/13.2.0...
   == COMPLETED: Installation ended successfully
   Listing modules...
   ------------------------- /opt/easybuild/modules/all --------------------------
   GCCcore/13.2.0

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
   # Should list GCCcore/13.2.0 if test build succeeded

Load and test a module
----------------------

.. code-block:: bash

   module load GCCcore/13.2.0
   gcc --version
   # Should show GCC 13.2.0

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

All scripts support the ``-h`` or ``--help`` flag (if implemented) and are idempotent—safe to run multiple times.

Script locations
----------------

* ``scripts/01_root_bootstrap.sh`` - Run as root
* ``scripts/02_user_bootstrap.sh`` - Run as regular user  
* ``scripts/03_build_example.sh`` - Run as regular user

Environment variables
---------------------

**01_root_bootstrap.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)
* ``GROUP`` - Unix group name (default: ``easybuildgrp``)
* ``EB_USER_TO_ADD`` - Username to add to group (optional)

**02_user_bootstrap.sh:**

* ``PREFIX`` - Installation prefix (default: ``/opt/easybuild``)

**03_build_example.sh:**

* ``PARALLEL`` - Number of parallel build jobs (default: all cores)

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
