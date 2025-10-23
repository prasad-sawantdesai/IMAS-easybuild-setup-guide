.. _first_build:

============================
First Build: Test Examples
============================

Test the EasyBuild pipeline by building software modules. This section covers common test builds to verify your installation.

EasyBuild Module (Lightweight Test)
====================================

The quickest way to test your installation is to build the EasyBuild module itself:

.. code-block:: bash

   [user] module purge
   [user] eb EasyBuild-4.9.0.eb --robot --parallel 8

This is a lightweight build that validates:

* EasyBuild can resolve dependencies
* Module files are created correctly
* Software is installed to the right location

After success you should see:

* Software under ``/opt/easybuild/software/EasyBuild``
* Module under ``/opt/easybuild/modules/all/EasyBuild``

Verify the installation:

.. code-block:: bash

   [user] module avail EasyBuild
   [user] module spider EasyBuild
   [user] module load EasyBuild/4.9.0
   [user] eb --version

GCCcore (Compiler Test)
========================

For a more comprehensive test, build a core compiler like GCCcore. This takes longer but validates the full toolchain:

.. code-block:: bash

   [user] module purge
   [user] eb GCCcore-13.2.0.eb --robot --parallel 8

After success you should see:

* Software under ``/opt/easybuild/software/GCCcore``
* Module under ``/opt/easybuild/modules/all/GCCcore``

Inspect modules:

.. code-block:: bash

   [user] module avail
   [user] module spider GCCcore
   [user] module load GCCcore/13.2.0
   [user] gcc --version

**Note:** Building GCCcore takes significantly longer than EasyBuild (15-30 minutes vs 1-2 minutes) but provides a more thorough validation of your setup.
