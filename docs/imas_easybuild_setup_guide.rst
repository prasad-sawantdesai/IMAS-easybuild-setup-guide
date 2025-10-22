.. _easybuild_rocky:

=============================================
EasyBuild on RHEL (system-wide, Lmod)
============================================

A concise, repeatable procedure to install **Lmod** and **EasyBuild 4.x** on Red Hat Enterprise Linux 8/9, build
modules under `/opt/easybuild`, and keep permissions sane for multiple users.

This guide is written as a set of **.rst pages** you can drop into a Sphinx project for GitHub Pages.
It clearly marks **[root]** vs **[user]** commands and provides copy-paste blocks.

.. contents:: Page index
:local:
:depth: 2

---

1. Prerequisites

---

**Supported OS**: Red Hat Enterprise Linux 8/9 (RHEL). (Also works on compatible clones.) Network access required for source downloads.

**User/Group model**

* Create a dedicated Unix group (here `easybuildgrp`) whose members are allowed to build into
  `/opt/easybuild`.
* Build with a normal **user** account that is in `easybuildgrp`. Avoid building as `root`.

**Legend**

* `[root]` → run as root (use `sudo -i` or prefix with `sudo`)
* `[user]` → run as your regular user (must be in `easybuildgrp`)

---

2. OS packages and base toolchain

---

Install development tools and common utilities.

.. code-block:: bash
:caption: Base packages

[root] dnf -y groupinstall "Development Tools"
[root] dnf -y install \
python3 python3-pip tcl lua lua-posix git rsync make wget \
bzip2 xz tar unzip which file

Enable EPEL (for extra packages) and install Lmod.

.. code-block:: bash
:caption: EPEL + Lmod

[root] dnf -y install epel-release
[root] dnf -y install Lmod
[user] module --version

If `module` is not found for your user shell, start a new login shell (or re-login).

---

3. Filesystem layout plan

---

We will install all EasyBuild outputs under `/opt/easybuild`. Root will create the tree and set
**setgid** permissions so newly created files inherit the group.

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

---

4. Install EasyBuild (4.x)

---

Prefer a **user install** (no root needed) using `pip --user` or a Python venv. This keeps the
EasyBuild tooling separate from system Python.

.. code-block:: bash
:caption: User-local EasyBuild

[user] python3 -m pip install --user "easybuild==4.*"
[user] eb --version

If `eb` isn’t found, ensure `~/.local/bin` is on your `PATH`:

.. code-block:: bash

[user] echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
[user] exec "$SHELL" -l

---

5. Point Lmod to module install

---

Tell Lmod where EasyBuild will place modules by adding a search path file (Lmod reads `/etc/lmod/modulespath.d/*.path`).

.. code-block:: bash
:caption: Register module path with Lmod

[root] mkdir -p /etc/lmod/modulespath.d
[root] printf "/opt/easybuild/modules/all\n" > /etc/lmod/modulespath.d/easybuild.path
[user] module avail

Note the directory is **modulespath.d** (with an **s**). Avoid using `modulepath.d`.

---

6. EasyBuild system-wide config

---

Create a global EasyBuild config under `/etc/easybuild.d/easybuild.cfg`. Root creates the file, but
all **values point inside** `/opt/easybuild` which is writable by the `easybuildgrp` group.

.. code-block:: ini
:caption: /etc/easybuild.d/easybuild.cfg

[config]
prefix = /opt/easybuild

# Top-level install roots

installpath = %(prefix)s/software
installpath-modules = %(prefix)s/modules

# Working and cache locations

buildpath = %(prefix)s/tmp
sourcepath = %(prefix)s/src
repositorypath = %(prefix)s/ebfiles_repo
containerpath = %(prefix)s/containers

# Permissions & group settings

umask = 002
group-writable-installdir = True

# Module system

modules-tool = Lmod
module-naming-scheme = EasyBuildMNS

# Where EB finds easyconfigs (.eb files)

robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs

# Quality of life

color = True
allow-source-as-runtime-dependency = True

Make sure the config directory exists and is readable by users:

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

Validate the loaded configuration:

.. code-block:: bash

[user] eb --show-config
[user] eb --show-config-configpaths
[user] eb --show-default-configpaths

---

7. Populate easyconfigs (upstream .eb)

---

Pull the upstream `easybuild-easyconfigs` into the **read-only** `upstream` location, then (optionally)
**rsync** a snapshot into your writable tree.

.. code-block:: bash
:caption: Clone upstream easyconfigs

[root] mkdir -p /opt/easybuild/easyconfigs/upstream
[user] git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git \
/opt/easybuild/easyconfigs/upstream

Expose upstream to EasyBuild by **syncing** into your active search path or by adding upstream directly
to `robot-paths`. Here we sync to keep a flat tree:

.. code-block:: bash

[root] rsync -a /opt/easybuild/easyconfigs/upstream/easybuild/easyconfigs/ \
/opt/easybuild/easyconfigs/

Your local site customizations go in `/opt/easybuild/local-easyconfigs`.

---

8. First build: GCCcore 13.2

---

Test the pipeline by building a core compiler. Use **--robot** so dependencies resolve automatically,
run with parallel builds where safe.

.. code-block:: bash

[user] module purge
[user] eb GCCcore-13.2.0.eb --robot --parallel 8

After success you should see:

* Software under `/opt/easybuild/software`
* Modules under `/opt/easybuild/modules/all` (discoverable by Lmod)

List the module tree:

.. code-block:: bash

[user] module avail
[user] module spider GCCcore

---

9. Day-2 ops and good practices

---

* **Build as user, not root.** Keep `/opt/easybuild` group-writable (`2775`) and ensure all builders are in
  `easybuildgrp`.
* **Keep upstream fresh**: periodically re-`git pull` and re-`rsync` to update easyconfigs.
* **Pin EB 4.x** in your user install; upgrade intentionally (`pip install --user -U 'easybuild==4.*'`).
* **Never set** the deprecated `installpath-logs` option (removed in recent EB 4.x).

---

10. Troubleshooting FAQ

---

**Q: `eb: command not found`**
Make sure `~/.local/bin` is in `PATH` (see Section 4), or install in a Python venv and activate it.

**Q: `module: command not found`**
Lmod not in your shell environment. Install Lmod (Section 2) and start a new login shell, or source
`/etc/profile.d/lmod.sh`.

**Q: Lmod shows no modules**
Ensure `/etc/lmod/modulespath.d/easybuild.path` contains `/opt/easybuild/modules/all` and that directory
exists with read/execute permissions for your group.

**Q: Permission denied writing to /opt/easybuild**
Confirm your user is in `easybuildgrp` (`id`), the tree is `chgrp -R easybuildgrp` and has `chmod -R 2775`.
New shells may need a re-login to pick up group membership.

**Q: Which directory name is correct: modulespath.d or modulepath.d?**
Use **/etc/lmod/modulespath.d** (with an **s**). `modulepath.d` is incorrect.

**Q: Shared folder mount path case mismatch**
Example: you created `/mnt/DataShare` but mounted to `/mnt/datashare`; fix the case to match exactly.

---

11. Appendix: Command log

---

Below is a normalized version of the command history you provided, mapped to the sections above and
annotated with **[root]** vs **[user]** where applicable.

.. code-block:: bash

# Section 2: Base

[root] dnf -y groupinstall "Development Tools"
[root] dnf -y install python3 python3-pip tcl lua lua-posix git rsync make wget bzip2 xz tar unzip which file
[root] dnf -y install epel-release

# Section 2: Lmod

[root] dnf -y install Lmod
[user] module --version

# Section 4: EasyBuild (user local)

[user] python3 -m pip install --user "easybuild==4.*"
[user] eb  # shows help

# Section 3 & 6: Layout and config

[root] mkdir -p /opt/easybuild/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}
[root] groupadd -f easybuildgrp
[root] chgrp -R easybuildgrp /opt/easybuild && chmod -R 2775 /opt/easybuild
[root] mkdir -p /etc/easybuild.d
[root] vim /etc/easybuild.d/easybuild.cfg  # or use the heredoc shown earlier

# Section 7: easyconfigs

[user] git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git /opt/easybuild/easyconfigs/upstream
[root] rsync -a /opt/easybuild/easyconfigs/upstream/easybuild/easyconfigs/ /opt/easybuild/easyconfigs/

# Section 5: Lmod path registration

[root] mkdir -p /etc/lmod/modulespath.d
[root] printf "/opt/easybuild/modules/all\n" > /etc/lmod/modulespath.d/easybuild.path
[user] module avail

# Section 8: first build

[user] eb GCCcore-13.2.0.eb --robot --parallel 8

---

12. When to use root vs user

---

**Use [root] for:**

* Installing OS packages (`dnf`)
* Installing Lmod and creating files in `/etc` (e.g., `/etc/lmod/modulespath.d` and `/etc/easybuild.d`)
* Creating and permissioning the top-level `/opt/easybuild` directories
* Managing Unix groups and membership (`groupadd`, `usermod`)

**Use [user] for:**

* Installing EasyBuild itself with `pip --user` (or within a venv)
* Running `eb` builds (writes to `/opt/easybuild` via group permissions)
* `git clone` of upstream easyconfigs **if** destination is group-writable (or run via `sudo -u <user>`)
* Day-to-day module usage (`module avail`, `module load`)

Tip: If you must create/modify files inside `/opt/easybuild` as root, ensure they stay group-writable and
owned by `:easybuildgrp` so users can continue building.

---

13. Sphinx project layout

---

For GitHub Pages via Sphinx, a minimal layout might look like:

.. code-block:: text

docs/
├─ conf.py
├─ index.rst
├─ prerequisites.rst
├─ filesystem.rst
├─ lmod.rst
├─ easybuild_install.rst
├─ config.rst
├─ easyconfigs.rst
├─ first_build.rst
├─ operations.rst
└─ troubleshooting.rst

**index.rst**

.. code-block:: rst

# EasyBuild on RHEL

.. toctree::
:maxdepth: 2
:caption: Contents

```
  prerequisites
  filesystem
  lmod
  easybuild_install
  config
  easyconfigs
  first_build
  operations
  troubleshooting
```

**conf.py (snippet)**

.. code-block:: python

project = "EasyBuild on RHEL"
extensions = ["sphinx.ext.autosectionlabel"]
html_theme = "furo"  # or 'alabaster' / 'sphinx_rtd_theme'
html_title = project

Build locally and publish with GitHub Pages (`main` branch, `docs/` folder) or a `gh-pages` workflow.

---

14. Next steps

---

* Add site-specific `.eb` files under `/opt/easybuild/local-easyconfigs`.
* Consider a small CI job that runs `eb --dry-run --robot <your.eb>` to validate updates.
* Periodically prune `buildpath` (`/opt/easybuild/tmp`) if space grows.
