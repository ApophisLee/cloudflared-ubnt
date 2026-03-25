#!/bin/bash
set -eu

readonly UBNT_CONFIG_GENERATOR="/config/scripts/post-config.d/cloudflared-generate-config"

ln -sf /usr/bin/cloudflared /usr/local/bin/cloudflared
mkdir -p /usr/local/etc/cloudflared/
touch /usr/local/etc/cloudflared/.installedFromPackageManager || true

if [ -x /opt/vyatta/sbin/cli-shell-api ] && [ -x "${UBNT_CONFIG_GENERATOR}" ]; then
	if ! output="$("${UBNT_CONFIG_GENERATOR}" 2>&1)"; then
		printf 'warning: failed to generate cloudflared config from EdgeOS config tree: %s\n' "${output}" >&2
	fi
fi
