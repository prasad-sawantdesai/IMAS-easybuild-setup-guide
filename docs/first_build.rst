.. _first_build:

=========================
First Build: GCCcore 13.2
=========================

Test the pipeline by building a core compiler. Use `--robot` so dependencies resolve automatically; use parallel builds where safe.

.. code-block:: bash

   [user] module purge
   [user] eb GCCcore-13.2.0.eb --robot --parallel 8

After success you should see:

* Software under `/opt/easybuild/software`
* Modules under `/opt/easybuild/modules/all`

Inspect modules:

.. code-block:: bash

   [user] module avail
   [user] module spider GCCcore
