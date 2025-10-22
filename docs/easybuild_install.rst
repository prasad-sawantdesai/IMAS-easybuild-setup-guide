.. _easybuild_install:

=========================
Install EasyBuild (4.x)
=========================

Prefer a **user install** (no root needed) using `pip --user` or a Python venv. This keeps EasyBuild separate from system Python.

.. code-block:: bash
   :caption: User-local EasyBuild

   [user] python3 -m pip install --user "easybuild==4.*"
   [user] eb --version

If `eb` isn’t found, ensure `~/.local/bin` is on your `PATH`:

.. code-block:: bash

   [user] echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   [user] exec "$SHELL" -l
