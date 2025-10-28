#!/usr/bin/env bash
# Userspace bootstrap for EasyBuild - No root required!
# This script sets up EasyBuild entirely in user's home directory
set -euo pipefail

# ---- Tunables ---------------------------------------------------------------
PREFIX=${PREFIX:-$HOME/easybuild}
PARALLEL=${PARALLEL:-$(nproc 2>/dev/null || echo 4)}
# -----------------------------------------------------------------------------

msg(){ printf "\n==> %s\n" "$*"; }
die(){ printf "ERROR: %s\n" "$*" >&2; exit 1; }

msg "Starting EasyBuild userspace installation..."
echo "Installation prefix: $PREFIX"
echo ""

# Check for required commands
for cmd in python3 git rsync; do
  command -v $cmd >/dev/null 2>&1 || die "$cmd is required but not found. Please install it first."
done

msg "Creating directory structure under $PREFIX..."
mkdir -p "$PREFIX"/{software,modules,src,tmp,ebfiles_repo,containers,easyconfigs,local-easyconfigs}

msg "Ensuring ~/.local/bin is on PATH..."
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  export PATH="$HOME/.local/bin:$PATH"
fi

msg "Installing EasyBuild 4.x to user site..."
python3 -m pip install --user "easybuild==4.*"

# Verify eb is available
if ! command -v eb >/dev/null 2>&1; then
  die "eb not found on PATH after installation. Try opening a new shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

msg "Checking eb version..."
eb --version

msg "Creating EasyBuild configuration in ~/.config/easybuild/config.cfg..."
mkdir -p ~/.config/easybuild
cat > ~/.config/easybuild/config.cfg <<EOF
[config]
prefix = $PREFIX
installpath = %(prefix)s
buildpath = %(prefix)s/tmp
sourcepath = %(prefix)s/src
repositorypath = %(prefix)s/ebfiles_repo
containerpath = %(prefix)s/containers
umask = 022
modules-tool = Lmod
module-naming-scheme = EasyBuildMNS
robot-paths = %(prefix)s/easyconfigs:%(prefix)s/local-easyconfigs
color = auto
EOF

msg "Setting up environment variables..."
# Add to bashrc if not already present
if ! grep -q "# EasyBuild userspace setup" ~/.bashrc; then
  cat >> ~/.bashrc <<EOF

# EasyBuild userspace setup
export EASYBUILD_PREFIX=$PREFIX
export MODULEPATH=$PREFIX/modules/all\${MODULEPATH:+:\$MODULEPATH}
EOF
fi

# Export for current session
export EASYBUILD_PREFIX=$PREFIX
export MODULEPATH=$PREFIX/modules/all${MODULEPATH:+:$MODULEPATH}

msg "Checking if Lmod is available..."
if command -v module >/dev/null 2>&1; then
  echo "✓ Lmod is available"
elif [ -f /usr/share/lmod/lmod/init/bash ]; then
  msg "Sourcing Lmod from /usr/share/lmod/lmod/init/bash..."
  source /usr/share/lmod/lmod/init/bash
  # Add to bashrc if not present
  if ! grep -q "/usr/share/lmod/lmod/init/bash" ~/.bashrc; then
    echo "source /usr/share/lmod/lmod/init/bash" >> ~/.bashrc
  fi
  echo "✓ Lmod sourced successfully"
elif [ -f /etc/profile.d/z00_lmod.sh ]; then
  msg "Sourcing Lmod from /etc/profile.d/z00_lmod.sh..."
  source /etc/profile.d/z00_lmod.sh
  echo "✓ Lmod sourced successfully"
else
  echo "⚠ Warning: Lmod not found. You may need to install it or use Tcl modules."
  echo "  For userspace Lmod installation, see: https://lmod.readthedocs.io/en/latest/030_installing.html"
fi

msg "Cloning upstream easyconfigs (if not present)..."
UPSTREAM_DIR="$PREFIX/easyconfigs/upstream"
mkdir -p "$UPSTREAM_DIR"
if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
  git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git "$UPSTREAM_DIR"
else
  (cd "$UPSTREAM_DIR" && git pull --ff-only) || true
fi

msg "Syncing upstream easyconfigs into active tree..."
rsync -rl "$UPSTREAM_DIR/easybuild/easyconfigs/" "$PREFIX/easyconfigs/"

msg "Showing EasyBuild config..."
eb --show-config

echo ""
echo "==========================================="
echo "✓ Userspace installation complete!"
echo "==========================================="
echo ""
echo "Installation location: $PREFIX"
echo ""
echo "IMPORTANT: To use EasyBuild in new shells, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or manually set:"
echo "  export EASYBUILD_PREFIX=$PREFIX"
echo "  export MODULEPATH=$PREFIX/modules/all:\$MODULEPATH"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal or run: source ~/.bashrc"
echo "  2. Test build: bash scripts/11_userspace_test_build.sh"
echo "  3. Build software: eb <package>.eb --robot"
echo ""
echo "To share modules with other users:"
echo "  - Make $PREFIX readable: chmod -R a+rX $PREFIX"
echo "  - Others can add to their MODULEPATH:"
echo "    export MODULEPATH=$PREFIX/modules/all:\$MODULEPATH"
echo ""
