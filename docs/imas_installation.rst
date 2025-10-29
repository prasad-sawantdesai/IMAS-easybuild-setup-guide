.. _imas_installation:

============================
IMAS Modules Installation
============================

Once the EasyBuild setup is working, you can proceed to install IMAS (Integrated Modelling & Analysis Suite) modules. This guide covers setting up the ITER private repository, understanding IMAS module structure, and installing the complete IMAS stack.

Overview of IMAS Modules
=========================

IMAS consists of multiple Access Layer (AL) components. This guide demonstrates installation using **IMAS-AL-Fortran** as an example.

**Key Components:**

* **IMAS-AL-Core** - Core library (required dependency for all other components)
* **IMAS-AL-Fortran** - Fortran language bindings (example module)
* **IMAS-AL-MDSplus-models** - MDSplus backend models (required for data access)
* **Data-Dictionary** - IMAS data structure definitions

The same installation process applies to other IMAS language bindings (Python, C++, Java, MATLAB).

Toolchain Versions
==================

IMAS modules are available for different toolchains:

* **foss-2023b** - Free Open Source Software compiler toolchain (GCC-based)
* **intel-2023b** - Intel compiler toolchain (used in this guide)

Example: ``IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb``

Setting Up ITER Private Repository
====================================

IMAS easyconfig files are stored in a private ITER repository. You need proper authentication and access permissions to clone this repository.

Prerequisites
-------------

1. **ITER Git Access**: Ensure you have credentials for ``git.iter.org``
2. **Network Access**: Verify you can reach the ITER git server
3. **SSH Keys or Credentials**: Set up authentication (SSH keys recommended)

Clone the Repository
--------------------

Clone the ITER EasyBuild easyconfigs repository into the local-easyconfigs directory:

.. code-block:: bash

   [user] cd /opt/easybuild/local-easyconfigs
   [user] git clone https://git.iter.org/scm/imex/easybuild-easyconfigs.git imas-easyconfigs

If you're using SSH authentication:

.. code-block:: bash

   [user] git clone git@git.iter.org:imex/easybuild-easyconfigs.git imas-easyconfigs

**Note:** You may need to enter your credentials or configure SSH keys for authentication.

Update Robot Paths
-------------------

Ensure EasyBuild can find the IMAS easyconfigs by updating the robot-paths configuration:

.. code-block:: bash

   [root] cat >> /etc/easybuild.d/easybuild.cfg <<'EOF'
   
   # Add IMAS easyconfigs to search path
   robot-paths = %(prefix)s/local-easyconfigs/imas-easyconfigs:%(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
   EOF

Verify the configuration:

.. code-block:: bash

   [user] eb --show-config | grep robot-paths

Creating IMAS Work Directory
=============================

IMAS requires a work directory for data storage. Create it before installation:

.. code-block:: bash

   [root] mkdir -p /work/imas
   [root] chown :easybuildgrp /work/imas
   [root] chmod 2775 /work/imas

This directory is referenced by the ``IMAS_HOME`` environment variable in the module file.

Installing IMAS Dependencies
==============================

Understanding Dependencies from EasyConfig Files
------------------------------------------------

Before installing, examine the EasyConfig file to understand dependencies. For ``IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb``:

.. code-block:: python

   builddependencies = [
       ('CMake', '3.27.6'),
       ('Saxon-HE', '12.4', '-Java-21', SYSTEM),
   ]
   
   dependencies = [
       ('IMAS-AL-Core', '5.4.3'),
       ('IMAS-AL-MDSplus-models', '5.2.2', '-DD-3.39.0'),
   ]

This shows:

* **Build dependencies**: Required only during build (CMake, Saxon-HE)
* **Runtime dependencies**: Required for the module to function (IMAS-AL-Core, IMAS-AL-MDSplus-models)

IMAS-AL-Core Dependencies
--------------------------

The core library (``IMAS-AL-Core-5.4.3-intel-2023b.eb``) requires:

.. code-block:: python

   builddependencies = [
       ('CMake', '3.27.6'),
       ('Ninja', '1.11.1'),
       ('scikit-build-core', '0.9.3'),
       ('Cython', '3.0.10'),
       ('cython-cmake', '0.2.0'),
   ]
   
   dependencies = [
       ('HDF5', '1.14.3'),
       ('MDSplus', '7.132.0'),
       ('UDA', '2.8.0'),
       ('Boost', '1.83.0'),
       ('SciPy-bundle', '2023.12'),
   ]

IMAS-AL-MDSplus-models Dependencies
------------------------------------

The MDSplus models (``IMAS-AL-MDSplus-models-5.2.2-intel-2023b-DD-3.39.0.eb``) require:

.. code-block:: python

   builddependencies = [
       ('CMake', '3.27.6'),
       ('IMAS-AL-Core', '5.4.1'),
       ('MDSplus', '7.132.0'),
       ('Saxon-HE', '12.4', '-Java-21', SYSTEM),
   ]
   
   dependencies = [
       ('Data-Dictionary', '3.39.0'),
   ]

Install Dependencies with EasyBuild
------------------------------------

**Option 1: Automatic dependency resolution** (Recommended)

Let EasyBuild resolve and build all dependencies automatically:

.. code-block:: bash

   [user] module load EasyBuild
   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8

The ``--robot`` flag enables automatic dependency resolution. EasyBuild will:

1. Parse the dependency tree
2. Build missing dependencies in the correct order
3. Install IMAS-AL-Fortran

**Option 2: Dry-run to preview** (Review before building)

.. code-block:: bash

   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --dry-run

This shows all modules that will be built without actually building them.

**Option 3: Manual dependency installation** (For troubleshooting)

Installing IMAS Modules
========================

Installation Order and Dependencies
------------------------------------

IMAS modules have a specific dependency hierarchy:

1. **IMAS-AL-Core** - Core library (foundation for all components)
2. **IMAS-AL-MDSplus-models** - Backend support (depends on IMAS-AL-Core)
3. **IMAS-AL-Fortran** - Fortran bindings (depends on both above)

Install IMAS-AL-Fortran with Dependencies
------------------------------------------

The simplest method is to let EasyBuild handle all dependencies:

.. code-block:: bash

   [user] module purge
   [user] module load EasyBuild
   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8

This single command will:

1. Check for missing dependencies
2. Build the intel-2023b toolchain (if needed)
3. Build all required libraries (HDF5, MDSplus, UDA, Boost, SciPy-bundle, etc.)
4. Build IMAS-AL-Core
5. Build Data-Dictionary
6. Build IMAS-AL-MDSplus-models
7. Build IMAS-AL-Fortran

**Note:** First-time installation may take 1-3 hours depending on your system.

Manual Step-by-Step Installation
---------------------------------

If you prefer to install dependencies manually or need to troubleshoot:

**Step 1: Install the toolchain**

.. code-block:: bash

   [user] eb intel-2023b.eb --robot --parallel 8

**Step 2: Install IMAS-AL-Core**

.. code-block:: bash

   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8

**Step 3: Install IMAS-AL-MDSplus-models**

.. code-block:: bash

   [user] eb IMAS-AL-MDSplus-models-5.2.2-intel-2023b-DD-3.39.0.eb --robot --parallel 8

**Step 4: Install IMAS-AL-Fortran**

.. code-block:: bash

   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8

Verifying IMAS Installation
============================

Check Installed Modules
------------------------

Verify that IMAS-AL-Fortran and its dependencies are installed:

.. code-block:: bash

   [user] module avail IMAS-AL-Fortran
   [user] module spider IMAS-AL-Fortran

Load and Verify Module
-----------------------

Load the module and check environment variables:

.. code-block:: bash

   [user] module purge
   [user] module load IMAS-AL-Fortran/5.4.0-intel-2023b-DD-3.42.0
   [user] module list

This will automatically load all required dependencies (IMAS-AL-Core, IMAS-AL-MDSplus-models, etc.).

Check environment variables:

.. code-block:: bash

   [user] echo $IMAS_HOME
   [user] echo $AL_VERSION
   [user] echo $AL_COMMON_PATH

Test the Installation
----------------------

Create a simple test to verify the Fortran bindings work:

.. code-block:: fortran
   :caption: test_imas.f90

   program test_imas
     use imas
     implicit none
     
     print *, "IMAS Fortran bindings loaded successfully!"
   end program test_imas

Compile and run:

.. code-block:: bash

   [user] module load IMAS-AL-Fortran/5.4.0-intel-2023b-DD-3.42.0
   [user] ifort test_imas.f90 -o test_imas $(pkg-config --cflags --libs al-fortran)
   [user] ./test_imas

Maintaining IMAS Installation
==============================

Update IMAS Easyconfigs
------------------------

Periodically update the ITER easyconfigs repository:

.. code-block:: bash

   [user] cd /opt/easybuild/local-easyconfigs/imas-easyconfigs
   [user] git pull origin main

Check for new versions:

.. code-block:: bash

   [user] ls -la IMAS-AL-Fortran/

Building Multiple Versions
---------------------------

You can install multiple versions side-by-side:

.. code-block:: bash

   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8
   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-4.0.0.eb --robot --parallel 8

Users switch between versions:

.. code-block:: bash

   [user] module load IMAS-AL-Fortran/5.4.0-intel-2023b-DD-3.42.0
   # or
   [user] module load IMAS-AL-Fortran/5.5.0-intel-2023b-DD-3.43.0

Cleaning Up Build Artifacts
----------------------------

After successful builds, clean up temporary files:

.. code-block:: bash

   [user] eb --clean-tmpdir

Or manually:

.. code-block:: bash

   [root] rm -rf /opt/easybuild/tmp/eb-*

Troubleshooting IMAS Installation
==================================

Authentication Issues
---------------------

**Problem:** Cannot clone ITER repository

**Solution:** Set up SSH keys or configure git credentials:

.. code-block:: bash

   [user] ssh-keygen -t rsa -b 4096 -C "your.email@iter.org"
   [user] eval "$(ssh-agent -s)"
   [user] ssh-add ~/.ssh/id_rsa

Add the public key to your ITER git account.

Source Download Failures
-------------------------

**Problem:** Cannot download IMAS source code

**Solution:** Check network connectivity:

.. code-block:: bash

   [user] curl -I https://git.iter.org

Configure proxy or VPN if needed.

Missing Dependencies
--------------------

**Problem:** Build fails due to missing dependencies

**Solution:** Use ``--robot`` for automatic dependency resolution:

.. code-block:: bash

   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --dry-run
   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8

Build Failures
--------------

**Problem:** Compilation errors during build

**Solution:** Check the build log:

.. code-block:: bash

   [user] eb IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb --robot --parallel 8 2>&1 | tee build.log

Review errors and verify all dependencies are compatible versions.

Permission Errors
-----------------

**Problem:** Cannot write to installation directory

**Solution:** Check group membership:

.. code-block:: bash

   [user] groups  # Should show 'easybuildgrp'
   [root] usermod -aG easybuildgrp username  # If needed

User must log out and back in for group changes to take effect.

Understanding EasyConfig Files
===============================

Key Sections in IMAS EasyConfig Files
--------------------------------------

**Example from IMAS-AL-Fortran-5.4.0-intel-2023b-DD-3.42.0.eb:**

.. code-block:: python

   easyblock = 'CMakeMake'  # Build system used
   
   name = 'IMAS-AL-Fortran'
   version = '5.4.0'
   versionsuffix = '-DD-3.42.0'  # Data Dictionary version
   
   toolchain = {'name': 'intel', 'version': '2023b'}
   
   builddependencies = [  # Only needed during build
       ('CMake', '3.27.6'),
       ('Saxon-HE', '12.4', '-Java-21', SYSTEM),
   ]
   
   dependencies = [  # Required at runtime
       ('IMAS-AL-Core', '5.4.3'),
       ('IMAS-AL-MDSplus-models', '5.2.2', '-DD-3.39.0'),
   ]
   
   source_urls = [...]  # Where to download source
   sources = [SOURCE_TAR_GZ]
   checksums = [...]  # Verify download integrity
   
   configopts = (...)  # CMake configuration options

Applying to Other IMAS Modules
-------------------------------

The same installation process applies to other IMAS language bindings:

**Python bindings:**

.. code-block:: bash

   [user] eb IMAS-AL-Python-5.4.3-intel-2023b.eb --robot --parallel 8

**C++ bindings:**

.. code-block:: bash

   [user] eb IMAS-AL-Cpp-5.4.3-intel-2023b.eb --robot --parallel 8

All follow the same dependency pattern and build process.
