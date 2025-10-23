.. _config:

==================================
Global EasyBuild Configuration
==================================

Create `/etc/easybuild.d/easybuild.cfg` (all paths inside `/opt/easybuild` which is group-writable).

.. code-block:: ini
   :caption: /etc/easybuild.d/easybuild.cfg

   [config]
   prefix = /opt/easybuild
   installpath = %(prefix)s/software
   installpath-modules = %(prefix)s/modules
   buildpath = %(prefix)s/tmp
   sourcepath = %(prefix)s/src
   repositorypath = %(prefix)s/ebfiles_repo
   containerpath = %(prefix)s/containers
   umask = 002
   group-writable-installdir = True
   modules-tool = Lmod
   module-naming-scheme = EasyBuildMNS
   robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
   color = True
   allow-source-as-runtime-dependency = True

Make sure directory exists and file readable:

.. code-block:: bash

   [root] mkdir -p /etc/easybuild.d
   [root] install -m 0644 /dev/stdin /etc/easybuild.d/easybuild.cfg <<'EOF'
   [config]
   prefix = /opt/easybuild
   installpath = %(prefix)s/software
   installpath-modules = %(prefix)s/modules
   buildpath = %(prefix)s/tmp
   sourcepath = %(prefix)s/src
   repositorypath = %(prefix)s/ebfiles_repo
   containerpath = %(prefix)s/containers
   umask = 002
   group-writable-installdir = True
   modules-tool = Lmod
   module-naming-scheme = EasyBuildMNS
   robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
   color = True
   allow-source-as-runtime-dependency = True
   EOF

Validate configuration:

.. code-block:: bash

   [user] eb --show-config
   [user] eb --show-config-configpaths
   [user] eb --show-default-configpaths
