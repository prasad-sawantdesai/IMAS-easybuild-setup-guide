.. _config:

==================================
Global EasyBuild Configuration
==================================

Create `/etc/easybuild.d/easybuild.cfg` (all paths inside `/opt/easybuild` which is group-writable).

The configuration file is automatically created by the `01_root_bootstrap.sh` script with the following content:

.. code-block:: ini
   :caption: /etc/easybuild.d/easybuild.cfg

   [config]
   prefix = /opt/easybuild
   installpath = %(prefix)s
   buildpath = %(prefix)s/tmp
   sourcepath = %(prefix)s/src
   repositorypath = %(prefix)s/ebfiles_repo
   containerpath = %(prefix)s/containers
   umask = 002
   group-writable-installdir = True
   modules-tool = Lmod
   module-naming-scheme = EasyBuildMNS
   robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
   color = auto

**Configuration Notes:**

* **installpath**: Set to `%(prefix)s` which uses EasyBuild's default subdirectories (`software/` and `modules/all/`)
* **color**: Set to `auto` to automatically detect terminal color support
* **umask**: Set to `002` to ensure group-writable files
* **robot-paths**: Includes both upstream easyconfigs and local custom configs

Manual Configuration (if not using automated scripts)
======================================================

If you're setting up manually without using the scripts, create the configuration file:

.. code-block:: bash

   [root] mkdir -p /etc/easybuild.d
   [root] cat > /etc/easybuild.d/easybuild.cfg <<'EOF'
   [config]
   prefix = /opt/easybuild
   installpath = %(prefix)s
   buildpath = %(prefix)s/tmp
   sourcepath = %(prefix)s/src
   repositorypath = %(prefix)s/ebfiles_repo
   containerpath = %(prefix)s/containers
   umask = 002
   group-writable-installdir = True
   modules-tool = Lmod
   module-naming-scheme = EasyBuildMNS
   robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
   color = auto
   EOF

Validating Configuration
========================

After creating the configuration file, verify it's being read correctly:

.. code-block:: bash

   [user] eb --show-config

This will display all active configuration settings, including those from `/etc/easybuild.d/easybuild.cfg`.

Check configuration file paths:

.. code-block:: bash

   [user] eb --show-config-configpaths
   [user] eb --show-default-configpaths

Understanding the Settings
===========================

Key configuration options explained:

**prefix**
  Base directory for all EasyBuild operations (default: `/opt/easybuild`)

**installpath**
  Where software and modules are installed. When set to `%(prefix)s`, EasyBuild automatically creates:
  
  * `%(prefix)s/software` - Installed software
  * `%(prefix)s/modules/all` - Module files

**buildpath**
  Temporary directory for builds (automatically cleaned after successful builds)

**sourcepath**
  Cache directory for downloaded source files (reused across builds)

**repositorypath**
  Directory where easyconfig files used for builds are archived

**containerpath**
  Directory for container images (if using EasyBuild's container support)

**umask**
  Set to `002` ensures new files are group-writable

**group-writable-installdir**
  Ensures installation directories remain group-writable after installation

**modules-tool**
  Module system to use (Lmod in this setup)

**module-naming-scheme**
  How module files are named (EasyBuildMNS is the default flat naming scheme)

**robot-paths**
  Directories to search for easyconfig files when resolving dependencies

**color**
  Terminal output coloring (`auto`, `always`, or `never`)

Optional Advanced Settings
===========================

You can add these options to the configuration file if needed:

.. code-block:: ini

   # Allow using sources as runtime dependencies (some packages need this)
   allow-source-as-runtime-dependency = True
   
   # Use minimal toolchains where possible
   minimal-toolchains = True
   
   # Set download timeout (in seconds)
   download-timeout = 1000
   
   # Enable experimental features
   experimental = True

After modifying the configuration, always verify with `eb --show-config` to ensure settings are applied correctly.
