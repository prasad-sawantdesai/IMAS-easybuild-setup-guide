#!/usr/bin/env bash
# Initialize EasyBuild + Lmod environment
# Can be sourced or executed

PREFIX=${PREFIX:-/opt/easybuild}

# Source Lmod initialization if available
if [ -f /etc/profile.d/z00_lmod.sh ]; then
  source /etc/profile.d/z00_lmod.sh
elif [ -f /usr/share/lmod/lmod/init/bash ]; then
  source /usr/share/lmod/lmod/init/bash
fi

# Source EasyBuild modules path if available
if [ -f /etc/profile.d/easybuild_modules.sh ]; then
  source /etc/profile.d/easybuild_modules.sh
fi

# Ensure EasyBuild modules are in MODULEPATH
if [[ ":$MODULEPATH:" != *":$PREFIX/modules/all:"* ]]; then
  export MODULEPATH="$PREFIX/modules/all${MODULEPATH:+:$MODULEPATH}"
fi

# If executed (not sourced), show status
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "EasyBuild environment initialized:"
  echo "  PREFIX: $PREFIX"
  echo "  MODULEPATH: $MODULEPATH"
  echo ""
  echo "Available EasyBuild modules:"
  module avail EasyBuild 2>&1 || echo "  (none found)"
fi
