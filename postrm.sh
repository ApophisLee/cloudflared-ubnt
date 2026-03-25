#!/bin/bash
set -eu
rm -f /usr/local/bin/cloudflared
rm -f /usr/local/etc/cloudflared/.installedFromPackageManager

if [ -f /usr/local/etc/cloudflared/.ubnt-config-tree-managed ]; then
	rm -f /usr/local/etc/cloudflared/config.yml
	rm -f /usr/local/etc/cloudflared/.ubnt-config-tree-managed
fi
