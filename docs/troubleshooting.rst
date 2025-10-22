.. _troubleshooting:

=====================
Troubleshooting FAQ
=====================

**`eb: command not found`**
Ensure `~/.local/bin` is in `PATH` (see EasyBuild install page) or install in a venv and activate it.

**`module: command not found`**
Install Lmod (see Lmod page) and start a new login shell, or source `/etc/profile.d/lmod.sh`.

**Lmod shows no modules**
Ensure `/etc/lmod/modulespath.d/easybuild.path` contains `/opt/easybuild/modules/all` and that directory exists with read/execute permissions.

**Permission denied writing to /opt/easybuild**
Confirm user is in `easybuildgrp` (`id`), tree ownership/group: `chgrp -R easybuildgrp /opt/easybuild`, permissions: `chmod -R 2775 /opt/easybuild`. Re-login if needed.

**Correct directory name?**
Use `/etc/lmod/modulespath.d` (with an **s**). `modulepath.d` is incorrect.
