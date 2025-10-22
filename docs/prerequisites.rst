.. _prerequisites:

================
Prerequisites
================

**Supported OS**: Red Hat Enterprise Linux 8/9 (RHEL) and compatible clones. Network access required for source downloads.

**User/Group model**

* Create a dedicated Unix group (here `easybuildgrp`) whose members are allowed to build into `/opt/easybuild`.
* Build with a normal **user** account that is in `easybuildgrp`. Avoid building as `root`.

**Legend**

* `[root]` → run as root (use `sudo -i` or prefix with `sudo`)
* `[user]` → run as your regular user (must be in `easybuildgrp`)
