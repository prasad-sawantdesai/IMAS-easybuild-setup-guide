.. _filesystem:

==========================
Filesystem Layout Plan
==========================

All EasyBuild outputs will live under `/opt/easybuild`. Root creates the tree and sets **setgid** so newly created files inherit the group.

.. code-block:: bash
   :caption: Create directories and set permissions

   [root] mkdir -p /opt/easybuild/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}
   [root] groupadd -f easybuildgrp
   [root] chgrp -R easybuildgrp /opt/easybuild
   [root] chmod -R 2775 /opt/easybuild

Add your user to the group and re-login (or run `newgrp easybuildgrp` for the current shell):

.. code-block:: bash

   [root] usermod -aG easybuildgrp <your_login>
   [user] newgrp easybuildgrp    # applies to current shell only (optional)
