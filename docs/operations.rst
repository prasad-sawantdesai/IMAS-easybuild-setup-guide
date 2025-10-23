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
