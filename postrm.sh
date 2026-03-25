#!/bin/bash
set -eu

readonly UBNT_CONFIG_MARKER="/usr/local/etc/cloudflared/.ubnt-config-tree-managed"

rm -f /usr/local/bin/cloudflared
rm -f /usr/local/etc/cloudflared/.installedFromPackageManager

if [ -f "${UBNT_CONFIG_MARKER}" ]; then
	rm -f /usr/local/etc/cloudflared/config.yml
	rm -f "${UBNT_CONFIG_MARKER}"
fi
