.. _userspace_setup:

==========================================
Userspace Setup (No Root Access Required)
==========================================

This guide describes how to install EasyBuild entirely in your home directory without requiring root access. This is ideal for:

* Users on shared systems without administrative privileges
* Personal installations on workstations
* Testing and development environments
* Quick setup without system modifications

.. contents:: Page index
   :local:
   :depth: 2

---

Overview
========

The userspace installation differs from the system-wide installation in these key ways:

.. list-table::
   :header-rows: 1
   :widths: 25 35 40

   * - Aspect
     - System-wide (``/opt/easybuild``)
     - Userspace (``~/easybuild``)
   * - Root access
     - Required for initial setup
     - **Not required**
   * - Installation location
     - ``/opt/easybuild``
     - ``$HOME/easybuild`` (or custom)
   * - Group management
     - Uses ``easybuildgrp``
     - **No group needed**
   * - Lmod installation
     - Installed system-wide
     - Uses existing or manual install
   * - Sharing modules
     - Automatic for group members
     - Manual via file permissions
   * - Suitable for
     - Production, multi-user
     - Personal, single-user, testing

**Key Benefits of Userspace Installation:**

* ✓ No root/sudo required
* ✓ No group management needed
* ✓ Full control over your environment
* ✓ Can still share modules with others
* ✓ Easy to remove (just delete directory)
* ✓ Multiple installations possible (different prefixes)

---

Prerequisites
=============

Before starting, ensure you have:

**Required:**

* Python 3 (usually pre-installed)
* Git (for cloning easyconfigs)
* Basic build tools (gcc, make) - usually available
* Internet connectivity

**Optional but recommended:**

* Lmod or Environment Modules (for module management)
  
  - If Lmod is installed system-wide, you can use it
  - If not, you can install Lmod in userspace or use Tcl modules

**Check prerequisites:**

.. code-block:: bash

   # Check Python
   python3 --version
   # Should show Python 3.6 or newer

   # Check Git
   git --version

   # Check if Lmod is available
   module --version
   # If this works, you have Lmod

   # Check for basic build tools
   gcc --version
   make --version

If any tools are missing, you may need to:

* Ask your system administrator to install them
* Use a different system
* Install them in userspace (advanced)

---

Quick Start (Automated)
=======================

Use the provided script for automated setup:

.. code-block:: bash

   # Clone this repository (if you haven't already)
   git clone https://github.com/prasad-sawantdesai/IMAS-easybuild-setup-guide.git
   cd IMAS-easybuild-setup-guide

   # Run the userspace bootstrap script
   bash scripts/10_userspace_bootstrap.sh

   # Reload your environment
   source ~/.bashrc

   # Test the installation
   bash scripts/11_userspace_test_build.sh

**That's it!** Skip to :ref:`userspace_next_steps` to start using EasyBuild.

---

Manual Setup (Step-by-Step)
============================

If you prefer to understand each step or need to customize the installation:

Step 1: Choose Installation Location
-------------------------------------

By default, EasyBuild will be installed in ``~/easybuild``:

.. code-block:: bash

   export PREFIX=$HOME/easybuild
   
   # Or choose a custom location:
   # export PREFIX=$HOME/software/easybuild
   # export PREFIX=/scratch/$USER/easybuild

Step 2: Create Directory Structure
-----------------------------------

.. code-block:: bash

   mkdir -p $PREFIX/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}

**Directory purposes:**

* ``software/`` - Installed software packages
* ``modules/`` - Module files for Lmod/Environment Modules
* ``src/`` - Downloaded source tarballs (cached)
* ``tmp/`` - Temporary build directory
* ``ebfiles_repo/`` - Repository of used easyconfig files
* ``containers/`` - Container images (if using containers)
* ``easyconfigs/`` - Easyconfig files from upstream
* ``local-easyconfigs/`` - Your custom easyconfig files

Step 3: Install EasyBuild
--------------------------

Install EasyBuild using pip to your user site-packages:

.. code-block:: bash

   python3 -m pip install --user "easybuild==4.*"

Ensure ``~/.local/bin`` is in your PATH:

.. code-block:: bash

   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   export PATH="$HOME/.local/bin:$PATH"

Verify installation:

.. code-block:: bash

   eb --version
   # Should show: This is EasyBuild 4.x.x

Step 4: Configure EasyBuild
----------------------------

Create configuration file:

.. code-block:: bash

   mkdir -p ~/.config/easybuild
   cat > ~/.config/easybuild/config.cfg <<EOF
   [config]
   prefix = $HOME/easybuild
   installpath = %(prefix)s
   buildpath = %(prefix)s/tmp
   sourcepath = %(prefix)s/src
   repositorypath = %(prefix)s/ebfiles_repo
   containerpath = %(prefix)s/containers
   umask = 022
   modules-tool = Lmod
   module-naming-scheme = EasyBuildMNS
   robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
   color = auto
   EOF

**Important:** Update the ``prefix`` line if you chose a different installation location.

Step 5: Set Up Environment Variables
-------------------------------------

Add these to your ``~/.bashrc``:

.. code-block:: bash

   # EasyBuild userspace setup
   export EASYBUILD_PREFIX=$HOME/easybuild
   export MODULEPATH=$HOME/easybuild/modules/all${MODULEPATH:+:$MODULEPATH}

If you need Lmod and it's installed system-wide but not auto-loaded:

.. code-block:: bash

   # Add this to ~/.bashrc if Lmod is not already loaded
   if [ -f /usr/share/lmod/lmod/init/bash ]; then
       source /usr/share/lmod/lmod/init/bash
   fi

Apply changes:

.. code-block:: bash

   source ~/.bashrc

Step 6: Get Easyconfig Files
-----------------------------

Clone the official easyconfigs repository:

.. code-block:: bash

   cd $PREFIX/easyconfigs
   git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git upstream
   
   # Sync easyconfigs into active tree
   rsync -rl upstream/easybuild/easyconfigs/ $PREFIX/easyconfigs/

Step 7: Verify Configuration
-----------------------------

.. code-block:: bash

   eb --show-config

You should see output showing your custom prefix and paths.

---

Testing the Installation
=========================

Build a Test Module
-------------------

Build EasyBuild itself as a module (lightweight test):

.. code-block:: bash

   eb EasyBuild-4.9.0.eb --robot

This will:

1. Download required sources
2. Build EasyBuild and dependencies
3. Install to ``~/easybuild/software``
4. Create module file in ``~/easybuild/modules/all``

Check Available Modules
-----------------------

.. code-block:: bash

   module avail
   # Should show EasyBuild/4.9.0

Load and Test the Module
-------------------------

.. code-block:: bash

   module load EasyBuild/4.9.0
   eb --version
   # Should show EasyBuild 4.9.0

---

.. _userspace_sharing:

Sharing Modules with Other Users
=================================

Even though this is a userspace installation, you can share your modules with other users.

Make Your Installation Readable
--------------------------------

.. code-block:: bash

   # Make everything readable by others
   chmod -R a+rX ~/easybuild

**Security note:** This makes your installation readable by all users on the system. Use with caution on shared systems.

Alternative: Share with Specific Users
---------------------------------------

.. code-block:: bash

   # Create a group (if you have permission)
   # Or work with your sysadmin
   
   # Set group ownership
   chgrp -R mygroup ~/easybuild
   chmod -R g+rX ~/easybuild

Tell Others How to Access
--------------------------

Other users can access your modules by adding to their MODULEPATH:

.. code-block:: bash

   # Add to their ~/.bashrc
   export MODULEPATH=/home/yourname/easybuild/modules/all:$MODULEPATH

They can then:

.. code-block:: bash

   module avail  # See your modules
   module load SomePackage/1.0  # Use your modules

**Note:** Other users can load and use the modules, but they cannot modify your installation unless you explicitly grant write permissions.

---

.. _userspace_next_steps:

Next Steps
==========

After successful installation:

Build Software Packages
-----------------------

.. code-block:: bash

   # Search for packages
   eb --search GCC
   
   # Build a package
   eb GCC-12.2.0.eb --robot
   
   # Build with dependency resolution
   eb Python-3.10.8-GCCcore-12.2.0.eb --robot

Create Custom Easyconfigs
--------------------------

Place your custom easyconfig files in ``~/easybuild/local-easyconfigs/``:

.. code-block:: bash

   cd ~/easybuild/local-easyconfigs
   # Create or copy custom .eb files here
   
   # EasyBuild will search here automatically (robot-paths)

Update Easyconfigs
------------------

Periodically update the upstream easyconfigs:

.. code-block:: bash

   cd ~/easybuild/easyconfigs/upstream
   git pull
   rsync -rl easybuild/easyconfigs/ ~/easybuild/easyconfigs/

Multiple Installations
----------------------

You can have multiple EasyBuild installations for different purposes:

.. code-block:: bash

   # Production installation
   PREFIX=$HOME/easybuild bash scripts/10_userspace_bootstrap.sh
   
   # Testing installation
   PREFIX=$HOME/easybuild-test bash scripts/10_userspace_bootstrap.sh
   
   # Switch between them
   export EASYBUILD_PREFIX=$HOME/easybuild  # production
   export EASYBUILD_PREFIX=$HOME/easybuild-test  # testing

Clean Up Build Files
--------------------

Free disk space by cleaning temporary files:

.. code-block:: bash

   # Remove temporary build files
   rm -rf ~/easybuild/tmp/*
   
   # Keep sources for faster rebuilds, or remove them too
   # rm -rf ~/easybuild/src/*

---

Troubleshooting
===============

eb: command not found
---------------------

**Symptom:** After installation, ``eb`` command is not found.

**Solution:**

.. code-block:: bash

   # Ensure ~/.local/bin is in PATH
   export PATH="$HOME/.local/bin:$PATH"
   source ~/.bashrc
   
   # Or open a new terminal

module: command not found
--------------------------

**Symptom:** ``module`` command is not available.

**Solution:**

1. Check if Lmod is installed system-wide:

   .. code-block:: bash

      ls /usr/share/lmod/lmod/init/bash
      # If exists, add to ~/.bashrc:
      source /usr/share/lmod/lmod/init/bash

2. If Lmod is not installed, ask your sysadmin or use Tcl modules:

   .. code-block:: bash

      # In config.cfg, change:
      modules-tool = EnvironmentModulesC

3. Or install Lmod in userspace (advanced):

   See: https://lmod.readthedocs.io/en/latest/030_installing.html

Modules Not Found
-----------------

**Symptom:** ``module avail`` doesn't show your modules.

**Solution:**

.. code-block:: bash

   # Check MODULEPATH
   echo $MODULEPATH
   # Should include ~/easybuild/modules/all
   
   # If not, add it:
   export MODULEPATH=$HOME/easybuild/modules/all:$MODULEPATH

Permission Denied During Build
-------------------------------

**Symptom:** Cannot write to installation directory.

**Solution:**

.. code-block:: bash

   # Check ownership
   ls -ld ~/easybuild
   
   # Should be owned by you
   # If not, fix it:
   chmod -R u+w ~/easybuild

Disk Space Issues
-----------------

**Symptom:** Running out of disk space.

**Solution:**

1. Check quota:

   .. code-block:: bash

      quota -s  # If available
      df -h ~

2. Clean temporary files:

   .. code-block:: bash

      rm -rf ~/easybuild/tmp/*

3. Consider using a different partition:

   .. code-block:: bash

      PREFIX=/scratch/$USER/easybuild bash scripts/10_userspace_bootstrap.sh

---

Comparing Installation Methods
===============================

.. list-table::
   :header-rows: 1
   :widths: 25 35 40

   * - Feature
     - System-wide (``/opt/easybuild``)
     - Userspace (``~/easybuild``)
   * - Root access needed
     - Yes (initial setup)
     - **No**
   * - Setup complexity
     - Moderate (groups, permissions)
     - **Simple**
   * - Multi-user by default
     - Yes (group members)
     - No (manual sharing)
   * - Disk space location
     - System partition
     - Home directory
   * - Installation time
     - 10-15 minutes
     - **5-10 minutes**
   * - Removal
     - Requires root
     - **Just delete directory**
   * - Multiple versions
     - Difficult
     - **Easy**
   * - Best for
     - Production, teams
     - **Personal, testing, no admin**

---

Complete Userspace Setup Summary
=================================

Quick command sequence for userspace installation:

.. code-block:: bash

   # 1. Run automated setup
   bash scripts/10_userspace_bootstrap.sh
   
   # 2. Reload environment
   source ~/.bashrc
   
   # 3. Test installation
   bash scripts/11_userspace_test_build.sh
   
   # 4. Start building software
   eb --search GCC
   eb GCC-12.2.0.eb --robot

**Total time:** ~10-20 minutes (mostly automated)

**Disk space required:** 

* Minimal: ~500 MB
* With GCC toolchain: ~5 GB
* Full scientific stack: 20-50 GB

---

For IMAS Installation
=====================

After completing the userspace EasyBuild setup, you can proceed with IMAS installation following the same procedures as the system-wide installation. Just ensure:

* Use your userspace prefix (``~/easybuild`` instead of ``/opt/easybuild``)
* All paths in easyconfig files point to your installation
* MODULEPATH includes your modules directory

See :doc:`imas_installation` for detailed IMAS installation instructions.
