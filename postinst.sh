#!/bin/bash
set -eu

readonly UBNT_CONFIG_GENERATOR="/config/scripts/post-config.d/cloudflared-generate-config"

ln -sf /usr/bin/cloudflared /usr/local/bin/cloudflared
mkdir -p /usr/local/etc/cloudflared/
touch /usr/local/etc/cloudflared/.installedFromPackageManager || true

if [ -x /opt/vyatta/sbin/cli-shell-api ] && [ -x "${UBNT_CONFIG_GENERATOR}" ]; then
	if ! "${UBNT_CONFIG_GENERATOR}"; then
		echo "warning: failed to generate cloudflared config from EdgeOS config tree" >&2
	fi
fi
