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

**Language Bindings:**

* **IMAS-AL-Cpp** - C++ language bindings
* **IMAS-AL-Fortran** - Fortran language bindings
* **IMAS-AL-Java** - Java language bindings
* **IMAS-AL-Matlab** - MATLAB language bindings
* **IMAS-AL-Python** - Python language bindings
* **IMAS-Python** - Additional Python utilities

**Data Backend Support:**

* **IMAS-AL-MDSplus-models** - MDSplus backend models

**Applications:**

* **IDS-Validator** - Validation tools for Interface Data Structures (IDS)
* **IDStools** - Utility tools for working with IDS

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

1. **IMAS-AL-Core** - Core library (required by all other components)
2. **Language-specific bindings** (as needed):
   
   * IMAS-AL-Cpp
   * IMAS-AL-Fortran
   * IMAS-AL-Python
   * IMAS-AL-Java
   * IMAS-AL-Matlab

4. **Backend support**:
   
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

**MDSplus models:**

.. code-block:: bash

   [user] eb IMAS-AL-MDSplus-models-5.4.3-intel-2023b.eb --robot --parallel 8

**Note:** HDF5 Data Container (HDC) backend is included in IMAS-AL-Core and doesn't require a separate module.

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
* IMAS-AL-MDSplus-models-5.4.3
* IDS-Validator-5.4.3
* IDStools-5.4.3
* IMAS-Python-5.4.3
* IMAS-5.4.3 (meta-module)

This represents a complete IMAS installation with all language bindings and backend support.
