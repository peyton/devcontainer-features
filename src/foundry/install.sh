#!/usr/bin/env bash

. ./library_scripts.sh

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

echo "Activating feature 'foundry'"

export FOUNDRY_DIR="${FOUNDRY_DIR:-"/usr/local/foundry"}"
export FOUNDRYUP_BRANCH=${BRANCH:-}
export FOUNDRYUP_COMMIT=${COMMIT:-}
export FOUNDRYUP_REPO=${REPO:-}
export FOUNRDYUP_VERSION=${VERSION:-}
UPDATE_RC="${UPDATE_RC:-"true"}"

ensure_nanolayer nanolayer_location "v0.5.6"

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Install curl, git, other dependencies if missing
check_packages curl ca-certificates gnupg2 git cargo

DOWNLOAD_URL="https://foundry.paradigm.xyz"
DOWNLOAD_PATH=$(mktemp)

clean_download ${DOWNLOAD_URL} ${DOWNLOAD_PATH}

chmod +x ${DOWNLOAD_PATH}
bash ${DOWNLOAD_PATH}

export PATH=${FOUNDRY_DIR}/bin:${PATH}

foundryup

# Clean up
rm ${DOWNLOAD_PATH}

# Add FOUNDRY_DIR and bin directory into bashrc/zshrc files (unless disabled)
updaterc "$(cat << EOF
export FOUNDRY_DIR="${FOUNDRY_DIR}"
if [[ "\${PATH}" != *"\${FOUNDRY_DIR}/bin"* ]]; then export PATH="\${FOUNDRY_DIR}/bin:\${PATH}"; fi
EOF
)"
