.. _lmod:

=============================
Lmod & Base OS Packages
=============================

Install development tools and common utilities:

.. code-block:: bash
   :caption: Base packages

   [root] dnf -y groupinstall "Development Tools"
   [root] dnf -y install \
   python3 python3-pip tcl lua lua-posix git rsync make wget \
   bzip2 xz tar unzip which file

Enable EPEL (for extra packages) and install Lmod:

.. code-block:: bash
   :caption: EPEL + Lmod

   [root] dnf -y install epel-release
   [root] dnf -y install Lmod
   [user] module --version

If `module` is not found for your user shell, start a new login shell (or re-login).

Point Lmod to the EasyBuild module tree:

.. code-block:: bash
   :caption: Register module path with Lmod

   [root] mkdir -p /etc/lmod/modulespath.d
   [root] printf "/opt/easybuild/modules/all\n" > /etc/lmod/modulespath.d/easybuild.path
   [user] module avail

Note: directory is `modulespath.d` (with an **s**).
