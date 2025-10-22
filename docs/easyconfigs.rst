.. _easyconfigs:

==============================
Populate EasyConfigs Repository
==============================

Pull upstream easyconfigs then optionally sync into your writable tree.

.. code-block:: bash
   :caption: Clone upstream easyconfigs

   [root] mkdir -p /opt/easybuild/easyconfigs/upstream
   [user] git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git \
   /opt/easybuild/easyconfigs/upstream

Sync upstream into active search path (keeps flat tree):

.. code-block:: bash

   [root] rsync -a /opt/easybuild/easyconfigs/upstream/easybuild/easyconfigs/ \
   /opt/easybuild/easyconfigs/

Local site customizations: `/opt/easybuild/local-easyconfigs`.
