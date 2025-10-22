.. _operations:

=============================
Operations & Good Practices
=============================

* Build as user, not root. Keep `/opt/easybuild` group-writable (`2775`) and ensure all builders are in `easybuildgrp`.
* Keep upstream fresh: periodically `git pull` and `rsync` to update easyconfigs.
* Pin EB 4.x in your user install; upgrade intentionally: `pip install --user -U 'easybuild==4.*'`.
* Never set deprecated `installpath-logs` option (removed in EB 4.x).

When to use root vs user:

**Use [root] for:**

* Installing OS packages (`dnf`)
* Installing Lmod and creating files in `/etc`
* Creating and permissioning the top-level `/opt/easybuild` directories
* Managing Unix groups and membership (`groupadd`, `usermod`)

**Use [user] for:**

* Installing EasyBuild with `pip --user` (or in a venv)
* Running `eb` builds
* Cloning upstream easyconfigs (destination must be group-writable)
* Day-to-day module usage (`module avail`, `module load`)

Tip: If you must modify files inside `/opt/easybuild` as root, keep them group-writable and owned by `:easybuildgrp`.

Appendix: Command log
---------------------

.. code-block:: bash

   [root] dnf -y groupinstall "Development Tools"
   [root] dnf -y install python3 python3-pip tcl lua lua-posix git rsync make wget bzip2 xz tar unzip which file
   [root] dnf -y install epel-release
   [root] dnf -y install Lmod
   [user] module --version
   [user] python3 -m pip install --user "easybuild==4.*"
   [user] eb
   [root] mkdir -p /opt/easybuild/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}
   [root] groupadd -f easybuildgrp
   [root] chgrp -R easybuildgrp /opt/easybuild && chmod -R 2775 /opt/easybuild
   [root] mkdir -p /etc/easybuild.d
   [root] vim /etc/easybuild.d/easybuild.cfg
   [root] mkdir -p /etc/lmod/modulespath.d
   [root] printf "/opt/easybuild/modules/all\n" > /etc/lmod/modulespath.d/easybuild.path
   [root] mkdir -p /opt/easybuild/easyconfigs/upstream
   [user] git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git /opt/easybuild/easyconfigs/upstream
   [root] rsync -a /opt/easybuild/easyconfigs/upstream/easybuild/easyconfigs/ /opt/easybuild/easyconfigs/
   [user] eb GCCcore-13.2.0.eb --robot --parallel 8
