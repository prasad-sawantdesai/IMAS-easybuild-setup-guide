.. _prerequisites_page:

================
Prerequisites
================

**Supported OS**: Red Hat Enterprise Linux 8/9 (RHEL) and compatible clones. Network access required for source downloads.

**Installation Options**

This guide supports two installation models:

1. **Userspace Installation** (No root required)

   * Install EasyBuild entirely in your home directory (e.g., ``~/easybuild``)
   * No administrative privileges needed
   * No group management required
   * Perfect for personal use or when you don't have root access
   * See :doc:`userspace_setup` for details

2. **System-wide Installation** (Root required)

   * Install EasyBuild in a shared location (e.g., ``/opt/easybuild``)
   * Requires initial root access for setup
   * Uses Unix group (e.g., ``easybuildgrp``) for collaborative access
   * Build with a normal **user** account that is in the group
   * Best for production systems with multiple users
   * See :doc:`automated_setup` for details

**Legend**

* `[root]` → run as root (use `sudo -i` or prefix with `sudo`) - only for system-wide installation
* `[user]` → run as your regular user account
