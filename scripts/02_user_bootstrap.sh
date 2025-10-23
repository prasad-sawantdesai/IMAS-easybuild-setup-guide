#!/usr/bin/env bash
# User bootstrap for EasyBuild 4.x and upstream easyconfigs
set -euo pipefail

PREFIX=${PREFIX:-/opt/easybuild}

msg(){ printf "\n==> %s\n" "$*"; }
die(){ printf "ERROR: %s\n" "$*" >&2; exit 1; }

# Ensure we can write to $PREFIX via group
if [[ ! -w "$PREFIX" ]]; then
  die "Cannot write to $PREFIX. Are you in the correct group? Try: id; and re-login if you were just added."
fi

msg "Ensuring ~/.local/bin is on PATH..."
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  export PATH="$HOME/.local/bin:$PATH"
fi

msg "Installing EasyBuild 4.x to user site..."
python3 -m pip install --user "easybuild==4.*"

msg "Checking eb version..."
eb --version || die "eb not found on PATH. Open a new shell or ensure ~/.local/bin is exported."

msg "Cloning upstream easyconfigs (if not present)..."
UPSTREAM_DIR="$PREFIX/easyconfigs/upstream"
mkdir -p "$UPSTREAM_DIR"
if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
  git clone --depth 1 https://github.com/easybuilders/easybuild-easyconfigs.git "$UPSTREAM_DIR"
else
  (cd "$UPSTREAM_DIR" && git pull --ff-only) || true
fi

msg "Syncing upstream easyconfigs into active tree..."
rsync -rl --no-perms --no-owner --no-group --no-times "$UPSTREAM_DIR/easybuild/easyconfigs/" "$PREFIX/easyconfigs/"

msg "Showing EasyBuild config..."
eb --show-config
echo
echo "User stage complete."
