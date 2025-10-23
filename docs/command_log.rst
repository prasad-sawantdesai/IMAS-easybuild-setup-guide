.. _command_log:

=================
Command Log
=================

Normalized command history across setup sections.

Root Setup (01_root_bootstrap.sh)
==================================

.. code-block:: bash

   [root] dnf -y groupinstall "Development Tools"
   [root] dnf -y install python3 python3-pip tcl lua lua-posix git rsync make wget bzip2 xz tar unzip which file
   [root] dnf -y install epel-release
   [root] dnf -y install Lmod
   [root] mkdir -p /opt/easybuild/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}
   [root] groupadd -f easybuildgrp
   [root] chgrp -R easybuildgrp /opt/easybuild
   [root] chmod -R 2775 /opt/easybuild
   [root] usermod -aG easybuildgrp <username>
   [root] mkdir -p /etc/lmod/modulespath.d
   [root] echo "/opt/easybuild/modules/all" > /etc/lmod/modulespath.d/easybuild.path
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

User Setup (02_user_bootstrap.sh)
==================================

.. code-block:: bash

   [user] echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   [user] python3 -m pip install --user "easybuild==4.*"
   [user] eb --version
   [user] mkdir -p /opt/easybuild/easyconfigs/upstream
   [user] git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git /opt/easybuild/easyconfigs/upstream
   [user] rsync -rl --no-perms --no-owner --no-group --no-times /opt/easybuild/easyconfigs/upstream/easybuild/easyconfigs/ /opt/easybuild/easyconfigs/
   [user] eb --show-config

Environment Initialization (00_init_env.sh)
============================================

.. code-block:: bash

   [user] source /etc/profile.d/z00_lmod.sh
   # or
   [user] source /usr/share/lmod/lmod/init/bash
   [user] source /etc/profile.d/easybuild_modules.sh
   [user] export MODULEPATH="/opt/easybuild/modules/all:$MODULEPATH"
   [user] module avail EasyBuild

Test Build (03_build_example.sh)
=================================

.. code-block:: bash

   [user] source scripts/00_init_env.sh
   [user] module purge
   [user] eb EasyBuild-4.9.0.eb --robot --parallel $(nproc)
   [user] module avail
   [user] module spider EasyBuild
   [user] module load EasyBuild/4.9.0
   [user] module list

Validation (04_validate.sh)
============================

.. code-block:: bash

   [user] source scripts/00_init_env.sh
   [user] test -d /opt/easybuild/software/EasyBuild
   [user] test -d /opt/easybuild/modules/all/EasyBuild
   [user] module avail EasyBuild
   [user] module spider EasyBuild
   [user] module load EasyBuild/4.9.0
   [user] eb --version

Additional Common Commands
==========================

.. code-block:: bash

   # Check Lmod version
   [user] module --version

   # Update upstream easyconfigs
   [user] cd /opt/easybuild/easyconfigs/upstream
   [user] git pull --ff-only
   [user] rsync -rl --no-perms --no-owner --no-group --no-times easybuild/easyconfigs/ /opt/easybuild/easyconfigs/

   # Build GCCcore compiler (longer test)
   [user] eb GCCcore-13.2.0.eb --robot --parallel 8

   # Search for available easyconfigs
   [user] eb --search GCC
   
   # Show dependency graph
   [user] eb GCCcore-13.2.0.eb --dry-run --robot
