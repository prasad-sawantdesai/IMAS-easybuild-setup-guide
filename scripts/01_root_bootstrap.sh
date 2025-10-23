#!/usr/bin/env bash
# System bootstrap for EasyBuild + Lmod on Redhat Linux
set -euo pipefail

# ---- Tunables ---------------------------------------------------------------
PREFIX=${PREFIX:-/opt/easybuild}
GROUP=${GROUP:-easybuildgrp}
EB_USER_TO_ADD=${EB_USER_TO_ADD:-}       # Optional: username to add to $GROUP
PKGS=(python3 python3-pip tcl lua lua-posix git rsync make wget bzip2 xz tar unzip which file)
# -----------------------------------------------------------------------------

msg(){ printf "\n==> %s\n" "$*"; }
die(){ printf "ERROR: %s\n" "$*" >&2; exit 1; }

# Basic sanity
command -v dnf >/dev/null 2>&1 || die "This script expects a RHEL/Rocky-like system with dnf."
[[ $EUID -eq 0 ]] || die "Run as root."

msg "Installing Development Tools group and base packages..."
dnf -y groupinstall "Development Tools"
dnf -y install "${PKGS[@]}"

msg "Enabling EPEL and installing Lmod..."
dnf -y install epel-release
dnf -y install Lmod

msg "Creating filesystem layout under $PREFIX..."
mkdir -p "$PREFIX"/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}
groupadd -f "$GROUP"
chgrp -R "$GROUP" "$PREFIX"
chmod -R 2775 "$PREFIX"            # setgid to keep group on new files/dirs

if [[ -n "${EB_USER_TO_ADD}" ]]; then
  if id -u "$EB_USER_TO_ADD" >/dev/null 2>&1; then
    usermod -aG "$GROUP" "$EB_USER_TO_ADD"
    msg "Added user '$EB_USER_TO_ADD' to group '$GROUP' (re-login required)."
  else
    msg "User '$EB_USER_TO_ADD' not found; skipping group membership."
  fi
fi

msg "Configuring Lmod to see EasyBuild module tree..."
mkdir -p /etc/lmod/modulespath.d
echo "$PREFIX/modules/all" > /etc/lmod/modulespath.d/easybuild.path

msg "Writing global EasyBuild config to /etc/easybuild.d/easybuild.cfg..."
mkdir -p /etc/easybuild.d
cat >/etc/easybuild.d/easybuild.cfg <<'EOF'
[config]
prefix = /opt/easybuild
installpath = %(prefix)s
buildpath = %(prefix)s/tmp
sourcepath = %(prefix)s/src
repositorypath = %(prefix)s/ebfiles_repo
containerpath = %(prefix)s/containers
umask = 002
group-writable-installdir = True
modules-tool = Lmod
module-naming-scheme = EasyBuildMNS
robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
color = auto
EOF

msg "Root stage complete."
echo "NOTE: If you added yourself to $GROUP, **log out and back in** (or 'newgrp $GROUP') before running the user stage."
