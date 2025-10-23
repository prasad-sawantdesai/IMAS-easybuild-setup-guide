.. _imas_installation:

============================
IMAS Modules Installation
============================

Once the EasyBuild setup is working, you can proceed to install IMAS (Integrated Modelling & Analysis Suite) modules. This guide covers setting up the ITER private repository, understanding IMAS module structure, and installing the complete IMAS stack.

Overview of IMAS Modules
=========================

IMAS consists of multiple Access Layer (AL) components that provide different language bindings and functionality:

**Core Components:**

* **IMAS-AL-Core** - Core library providing the foundation for all other components
* **IMAS-AL-Common** - Common utilities and shared functionality
* **IDS-Validator** - Validation tools for Interface Data Structures (IDS)
* **IDStools** - Utility tools for working with IDS

**Language Bindings:**

* **IMAS-AL-Cpp** - C++ language bindings
* **IMAS-AL-Fortran** - Fortran language bindings
* **IMAS-AL-Java** - Java language bindings
* **IMAS-AL-Matlab** - MATLAB language bindings
* **IMAS-AL-Python** - Python language bindings
* **IMAS-Python** - Additional Python utilities

**Data Backend Support:**

* **IMAS-AL-HDC** - HDF5 Data Container backend
* **IMAS-AL-MDSplus-models** - MDSplus backend models

**Complete Suite:**

* **IMAS** - Meta-module that loads the complete IMAS environment

Toolchain Versions
==================

IMAS modules are available for different toolchains, primarily:

* **foss-2023b** - Free Open Source Software compiler toolchain (GCC-based)
* **intel-2023b** - Intel compiler toolchain

Example naming convention:

* ``IMAS-AL-Core-5.4.3-foss-2023b.eb``
* ``IMAS-AL-Core-5.4.3-intel-2023b.eb``

Choose the toolchain that best fits your needs. The ``foss`` toolchain is more portable and open, while ``intel`` may offer better performance on Intel hardware.

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

Verify the Clone
----------------

Check that the repository was cloned successfully:

.. code-block:: bash

   [user] ls -la /opt/easybuild/local-easyconfigs/imas-easyconfigs/

You should see directories for each IMAS component:

.. code-block:: text

   IDS-Validator/
   IDStools/
   IMAS/
   IMAS-AL-Common/
   IMAS-AL-Core/
   IMAS-AL-Cpp/
   IMAS-AL-Fortran/
   IMAS-AL-HDC/
   IMAS-AL-Java/
   IMAS-AL-Matlab/
   IMAS-AL-MDSplus-models/
   IMAS-AL-Python/
   IMAS-Python/

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

Understanding IMAS-AL-Core EasyConfig
======================================

Let's examine the structure of a typical IMAS easyconfig using ``IMAS-AL-Core`` as an example:

.. code-block:: python
   :caption: IMAS-AL-Core-5.4.3-intel-2023b.eb

   easyblock = 'CMakePythonPackage'

   name = 'IMAS-AL-Core'
   version = '5.4.3'

   description = 'IMAS Access Layer core library'
   homepage = 'https://imas.iter.org/'

   toolchain = {'name': 'intel', 'version': '2023b'}

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

   source_urls = ['https://git.iter.org/rest/api/latest/projects/IMAS/repos/al-core/archive'
                  '?at=tags/%(version)s&format=tar.gz&filename=']
   sources = ['al-core-%(version)s.tar.gz']
   checksums = ['c6bb8319e92c59184701de85d68479d4a63c8ad44d8d72a57b3b192349a4a801']

   build_type = 'RelWithDebInfo'
   configopts = (
       # Don't download dependencies
       '-D AL_DOWNLOAD_DEPENDENCIES=OFF '
       # Enable all backends
       '-D AL_BACKEND_HDF5=ON '
       '-D AL_BACKEND_MDSPLUS=ON '
       '-D AL_BACKEND_UDA=ON '
       # Don't build MDSplus models
       '-D AL_BUILD_MDSPLUS_MODELS=OFF '
       # Build Python bindings
       '-D AL_PYTHON_BINDINGS=ON '
       # Don't build tests and examples
       '-D AL_EXAMPLES=OFF '
       '-D AL_TESTS=OFF '
       '-D AL_PYTHON_BINDINGS=no-build-isolation '
   )

   options = {'modulename': 'imas_core'}
   sanity_check_paths = {
       'dirs': ['lib', 'include'],
       'files': [],
   }

   moduleclass = 'tools'

   modextrapaths = {
       'AL_COMMON_PATH': 'share/common',
   }

   modextravars = {
       'IMAS_HOME': '/work/imas',
       'AL_VERSION': '%(version)s',
       'HDF5_USE_FILE_LOCKING': 'FALSE',
       'IMAS_LOCAL_HOSTS': 'uda.iter.org',
   }

**Key Configuration Elements:**

* **easyblock**: Uses ``CMakePythonPackage`` for CMake-based builds with Python bindings
* **toolchain**: Specifies compiler toolchain (intel-2023b or foss-2023b)
* **builddependencies**: Build-time only dependencies (CMake, Ninja, etc.)
* **dependencies**: Runtime dependencies (HDF5, MDSplus, UDA, Boost, SciPy)
* **source_urls**: Downloads source from ITER git repository
* **configopts**: CMake configuration options for backends and features
* **modextravars**: Environment variables set when module is loaded

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

Before installing IMAS modules, ensure all required dependencies are available. The main dependencies include:

Build the Base Toolchain
--------------------------

First, install the chosen toolchain (intel-2023b or foss-2023b):

.. code-block:: bash

   # For Intel toolchain
   [user] eb intel-2023b.eb --robot --parallel 8

   # OR for FOSS toolchain
   [user] eb foss-2023b.eb --robot --parallel 8

**Note:** This will take considerable time (1-2 hours) as it builds the complete compiler toolchain.

Install Core Dependencies
--------------------------

Install the dependencies required by IMAS-AL-Core:

.. code-block:: bash

   [user] module purge
   [user] module load EasyBuild
   
   # Install HDF5
   [user] eb HDF5-1.14.3-intel-2023b.eb --robot --parallel 8
   
   # Install MDSplus
   [user] eb MDSplus-7.132.0-intel-2023b.eb --robot --parallel 8
   
   # Install UDA (if available in repository)
   [user] eb UDA-2.8.0-intel-2023b.eb --robot --parallel 8
   
   # Install Boost
   [user] eb Boost-1.83.0-intel-2023b.eb --robot --parallel 8
   
   # Install SciPy-bundle (includes NumPy, SciPy, etc.)
   [user] eb SciPy-bundle-2023.12-intel-2023b.eb --robot --parallel 8

**Alternative:** Let EasyBuild resolve dependencies automatically:

.. code-block:: bash

   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8 --dry-run

This will show you all missing dependencies that will be built.

Installing IMAS Modules
========================

Installation Order
------------------

IMAS modules have a specific dependency hierarchy. Install them in this order:

1. **IMAS-AL-Common** - Common utilities (if available as separate module)
2. **IMAS-AL-Core** - Core library (required by all other components)
3. **Language-specific bindings** (as needed):
   
   * IMAS-AL-Cpp
   * IMAS-AL-Fortran
   * IMAS-AL-Python
   * IMAS-AL-Java
   * IMAS-AL-Matlab

4. **Backend support**:
   
   * IMAS-AL-HDC
   * IMAS-AL-MDSplus-models

5. **Utility tools**:
   
   * IDS-Validator
   * IDStools
   * IMAS-Python

6. **IMAS meta-module** - Loads complete environment

Install IMAS-AL-Core
--------------------

Start with the core library:

.. code-block:: bash

   [user] module purge
   [user] module load EasyBuild
   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8

Monitor the build process. This will:

* Download source from ITER git repository
* Build all dependencies (if not already installed)
* Compile IMAS-AL-Core with CMake
* Install to ``/opt/easybuild/software/IMAS-AL-Core/5.4.3-intel-2023b/``
* Create module file at ``/opt/easybuild/modules/all/IMAS-AL-Core/5.4.3-intel-2023b``

Verify the installation:

.. code-block:: bash

   [user] module avail IMAS-AL-Core
   [user] module load IMAS-AL-Core/5.4.3-intel-2023b
   [user] module list

Install Language Bindings
--------------------------

Install the language bindings you need:

**Python bindings:**

.. code-block:: bash

   [user] eb IMAS-AL-Python-5.4.3-intel-2023b.eb --robot --parallel 8

**C++ bindings:**

.. code-block:: bash

   [user] eb IMAS-AL-Cpp-5.4.3-intel-2023b.eb --robot --parallel 8

**Fortran bindings:**

.. code-block:: bash

   [user] eb IMAS-AL-Fortran-5.4.3-intel-2023b.eb --robot --parallel 8

**Java bindings (if needed):**

.. code-block:: bash

   [user] eb IMAS-AL-Java-5.4.3-intel-2023b.eb --robot --parallel 8

**MATLAB bindings (if needed):**

.. code-block:: bash

   [user] eb IMAS-AL-Matlab-5.4.3-intel-2023b.eb --robot --parallel 8

Install Backend Support
------------------------

**HDC backend:**

.. code-block:: bash

   [user] eb IMAS-AL-HDC-5.4.3-intel-2023b.eb --robot --parallel 8

**MDSplus models:**

.. code-block:: bash

   [user] eb IMAS-AL-MDSplus-models-5.4.3-intel-2023b.eb --robot --parallel 8

Install Utility Tools
---------------------

**IDS Validator:**

.. code-block:: bash

   [user] eb IDS-Validator-5.4.3-intel-2023b.eb --robot --parallel 8

**IDS tools:**

.. code-block:: bash

   [user] eb IDStools-5.4.3-intel-2023b.eb --robot --parallel 8

**IMAS Python utilities:**

.. code-block:: bash

   [user] eb IMAS-Python-5.4.3-intel-2023b.eb --robot --parallel 8

Install Complete IMAS Suite
----------------------------

Finally, install the IMAS meta-module that loads the complete environment:

.. code-block:: bash

   [user] eb IMAS-5.4.3-intel-2023b.eb --robot --parallel 8

This module will load all IMAS components in the correct order.

Automated Installation Script
==============================

For convenience, you can install all IMAS modules with a single script:

.. code-block:: bash
   :caption: scripts/05_install_imas.sh

   #!/bin/bash
   # Install complete IMAS suite with intel-2023b toolchain
   
   set -e  # Exit on error
   
   TOOLCHAIN="intel-2023b"
   VERSION="5.4.3"
   PARALLEL_JOBS=8
   
   # Array of IMAS modules in installation order
   IMAS_MODULES=(
       "IMAS-AL-Core-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-AL-Cpp-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-AL-Fortran-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-AL-Python-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-AL-HDC-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-AL-MDSplus-models-${VERSION}-${TOOLCHAIN}.eb"
       "IDS-Validator-${VERSION}-${TOOLCHAIN}.eb"
       "IDStools-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-Python-${VERSION}-${TOOLCHAIN}.eb"
       "IMAS-${VERSION}-${TOOLCHAIN}.eb"
   )
   
   echo "=== IMAS Installation Script ==="
   echo "Toolchain: ${TOOLCHAIN}"
   echo "Version: ${VERSION}"
   echo "Parallel jobs: ${PARALLEL_JOBS}"
   echo ""
   
   # Load EasyBuild
   module purge
   module load EasyBuild
   
   # Install each module
   for MODULE in "${IMAS_MODULES[@]}"; do
       echo "=== Installing ${MODULE} ==="
       if eb "${MODULE}" --robot --parallel "${PARALLEL_JOBS}"; then
           echo "✓ Successfully installed ${MODULE}"
       else
           echo "✗ Failed to install ${MODULE}"
           exit 1
       fi
       echo ""
   done
   
   echo "=== IMAS Installation Complete ==="
   echo "Available modules:"
   module avail IMAS

Save this script and make it executable:

.. code-block:: bash

   [user] chmod +x scripts/05_install_imas.sh
   [user] ./scripts/05_install_imas.sh

Verifying IMAS Installation
============================

Check Available Modules
------------------------

List all installed IMAS modules:

.. code-block:: bash

   [user] module avail IMAS
   [user] module spider IMAS

You should see all installed IMAS modules and their versions.

Load and Test IMAS
-------------------

Load the complete IMAS environment:

.. code-block:: bash

   [user] module purge
   [user] module load IMAS/5.4.3-intel-2023b
   [user] module list

Check that environment variables are set:

.. code-block:: bash

   [user] echo $IMAS_HOME
   [user] echo $AL_VERSION
   [user] echo $AL_COMMON_PATH

Test Python bindings:

.. code-block:: bash

   [user] python3 -c "import imas_core; print('IMAS Core loaded successfully')"

Test with a simple Python script:

.. code-block:: python
   :caption: test_imas.py

   #!/usr/bin/env python3
   import imas_core
   
   print(f"IMAS Core version: {imas_core.__version__}")
   print("IMAS Core loaded successfully!")

Run the test:

.. code-block:: bash

   [user] python3 test_imas.py

Permissions and Access Control
===============================

Group Permissions
-----------------

Ensure all IMAS installations are group-writable:

.. code-block:: bash

   [root] find /opt/easybuild/software/IMAS* -type d -exec chmod 2775 {} \;
   [root] find /opt/easybuild/software/IMAS* -type f -exec chmod g+w {} \;

Add Users to EasyBuild Group
-----------------------------

Users who need to build or modify IMAS modules should be in the ``easybuildgrp``:

.. code-block:: bash

   [root] usermod -aG easybuildgrp username

Creating IMAS User Profiles
----------------------------

Create a profile script for easy IMAS loading:

.. code-block:: bash
   :caption: /etc/profile.d/imas.sh

   #!/bin/bash
   # IMAS module environment setup
   
   # Add this to your .bashrc or source it manually
   alias load-imas='module purge && module load IMAS/5.4.3-intel-2023b'
   
   export IMAS_VERSION="5.4.3"
   export IMAS_TOOLCHAIN="intel-2023b"

Users can then simply run:

.. code-block:: bash

   [user] load-imas

Alternative: Using FOSS Toolchain
==================================

If you prefer the open-source FOSS toolchain instead of Intel, follow the same process but use ``foss-2023b`` modules:

.. code-block:: bash

   # Install FOSS toolchain
   [user] eb foss-2023b.eb --robot --parallel 8
   
   # Install IMAS with FOSS toolchain
   [user] eb IMAS-AL-Core-5.4.3-foss-2023b.eb --robot --parallel 8
   [user] eb IMAS-5.4.3-foss-2023b.eb --robot --parallel 8

The FOSS toolchain is based on GCC and fully open-source, making it more portable and easier to troubleshoot.

Maintaining IMAS Installation
==============================

Update IMAS Easyconfigs
------------------------

Periodically update the ITER easyconfigs repository:

.. code-block:: bash

   [user] cd /opt/easybuild/local-easyconfigs/imas-easyconfigs
   [user] git pull origin main

Check for new IMAS versions:

.. code-block:: bash

   [user] ls -la IMAS-AL-Core/

Building Multiple Versions
---------------------------

You can install multiple IMAS versions side-by-side:

.. code-block:: bash

   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8
   [user] eb IMAS-AL-Core-5.4.4-intel-2023b.eb --robot --parallel 8

Users can then choose which version to load:

.. code-block:: bash

   [user] module load IMAS/5.4.3-intel-2023b
   # or
   [user] module load IMAS/5.4.4-intel-2023b

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

.. code-block:: text

   fatal: Authentication failed

**Solution:** Set up SSH keys or configure git credentials:

.. code-block:: bash

   # Generate SSH key
   [user] ssh-keygen -t rsa -b 4096 -C "your.email@iter.org"
   
   # Add to ssh-agent
   [user] eval "$(ssh-agent -s)"
   [user] ssh-add ~/.ssh/id_rsa
   
   # Add public key to ITER git server
   [user] cat ~/.ssh/id_rsa.pub

Then add the public key to your ITER git account settings.

Source Download Failures
-------------------------

**Problem:** Cannot download IMAS source code

.. code-block:: text

   ERROR: Build failed: Failed to download source

**Solution:** Check network connectivity and authentication:

.. code-block:: bash

   # Test connection to ITER git server
   [user] curl -I https://git.iter.org
   
   # Try manual download
   [user] wget "https://git.iter.org/rest/api/latest/projects/IMAS/repos/al-core/archive?at=tags/5.4.3&format=tar.gz"

If downloads fail, you may need to configure proxy settings or VPN access.

Missing Dependencies
--------------------

**Problem:** Build fails due to missing dependencies

.. code-block:: text

   ERROR: Failed to process easyconfig: Unresolved dependencies

**Solution:** Use ``--robot`` to automatically resolve dependencies:

.. code-block:: bash

   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --dry-run

This shows what will be built. Then run the actual build:

.. code-block:: bash

   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 8

Python Import Errors
--------------------

**Problem:** Cannot import IMAS Python modules

.. code-block:: text

   ModuleNotFoundError: No module named 'imas_core'

**Solution:** Ensure the module is loaded and PYTHONPATH is set:

.. code-block:: bash

   [user] module load IMAS-AL-Core/5.4.3-intel-2023b
   [user] echo $PYTHONPATH
   [user] python3 -c "import sys; print(sys.path)"

Check that the IMAS installation directory is in the Python path.

Build Timeout Issues
--------------------

**Problem:** Build times out or takes too long

**Solution:** Increase parallel jobs or build on a more powerful machine:

.. code-block:: bash

   # Use more CPU cores
   [user] eb IMAS-AL-Core-5.4.3-intel-2023b.eb --robot --parallel 16
   
   # Or build dependencies separately first
   [user] eb HDF5-1.14.3-intel-2023b.eb --robot --parallel 8
   [user] eb MDSplus-7.132.0-intel-2023b.eb --robot --parallel 8

Permission Errors
-----------------

**Problem:** Cannot write to installation directory

.. code-block:: text

   ERROR: Failed to create directory: Permission denied

**Solution:** Check group membership and permissions:

.. code-block:: bash

   # Check group membership
   [user] groups
   
   # Should show 'easybuildgrp'
   # If not, add user to group
   [root] usermod -aG easybuildgrp username
   
   # User must log out and back in for group change to take effect

Next Steps
==========

After successfully installing IMAS, you can:

1. **Set up user environments** - Create module profiles for easy access
2. **Test IMAS functionality** - Run IMAS test cases and examples
3. **Integrate with workflows** - Use IMAS in your simulation pipelines
4. **Monitor performance** - Profile IMAS applications for optimization
5. **Set up data storage** - Configure IMAS data backends (HDF5, MDSplus, UDA)

For advanced usage, refer to:

* IMAS official documentation: https://imas.iter.org/
* ITER technical documentation and user guides
* IMAS training materials and tutorials

Complete Module List for IMAS Setup
====================================

For reference, here's the complete list of modules typically required for a full IMAS installation:

**Base Toolchain:**

* GCCcore-13.2.0 (for foss) or intel-compiler-2023.2.1 (for intel)
* foss-2023b or intel-2023b

**Core Dependencies:**

* HDF5-1.14.3
* MDSplus-7.132.0
* UDA-2.8.0
* Boost-1.83.0
* SciPy-bundle-2023.12 (includes NumPy, SciPy, pandas)

**Build Tools:**

* CMake-3.27.6
* Ninja-1.11.1
* scikit-build-core-0.9.3
* Cython-3.0.10
* cython-cmake-0.2.0

**IMAS Modules:**

* IMAS-AL-Core-5.4.3
* IMAS-AL-Cpp-5.4.3
* IMAS-AL-Fortran-5.4.3
* IMAS-AL-Python-5.4.3
* IMAS-AL-Java-5.4.3 (optional)
* IMAS-AL-Matlab-5.4.3 (optional)
* IMAS-AL-HDC-5.4.3
* IMAS-AL-MDSplus-models-5.4.3
* IDS-Validator-5.4.3
* IDStools-5.4.3
* IMAS-Python-5.4.3
* IMAS-5.4.3 (meta-module)

This represents a complete IMAS installation with all language bindings and backend support.
