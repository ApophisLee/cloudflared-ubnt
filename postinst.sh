#!/bin/bash
set -eu
ln -sf /usr/bin/cloudflared /usr/local/bin/cloudflared
mkdir -p /usr/local/etc/cloudflared/
touch /usr/local/etc/cloudflared/.installedFromPackageManager || true

if [ -x /opt/vyatta/sbin/cli-shell-api ] && [ -x /config/scripts/post-config.d/cloudflared-generate-config ]; then
	if ! /config/scripts/post-config.d/cloudflared-generate-config; then
		echo "warning: failed to generate cloudflared config from EdgeOS config tree" >&2
	fi
fi
