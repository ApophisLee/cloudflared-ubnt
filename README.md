# cloudflared — UBNT & Multi-Arch Fork

> 🔄 **Auto-synced fork** of [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared) with additional builds for **Ubiquiti (UBNT)** routers and other MIPS devices.

[![Sync Upstream Release](https://github.com/ApophisLee/cloudflared-ubnt/actions/workflows/sync-upstream-release.yml/badge.svg)](https://github.com/ApophisLee/cloudflared-ubnt/actions/workflows/sync-upstream-release.yml)

## What is this?

This repository is a fork of the official [cloudflare/cloudflared](https://github.com/cloudflare/cloudflared) Cloudflare Tunnel client. It adds:

- **Automated upstream sync** — A CI/CD pipeline checks for new upstream releases every 6 hours and automatically builds & publishes them here
- **MIPS architecture support** — Pre-built binaries and `.deb` packages for Ubiquiti (UBNT) devices that are not available in the official releases
- **Multi-architecture releases** — Upstream multi-arch artifacts are synced as-is; this fork additionally builds **linux-mipsle** and **linux-mips64** binaries plus `.deb` packages specifically for UBNT devices

## Supported Architectures

The table below lists architectures supported by `cloudflared` overall.
- ✅ = built and published by **this fork**
- ⬆️ upstream only = available **only from upstream releases** (`cloudflare/cloudflared`)

| Platform | Architecture | Binary | `.deb` | Devices |
| --- | --- | --- | --- | --- |
| Linux | amd64 | ⬆️ upstream only | ⬆️ upstream only | Standard x86_64 servers |
| Linux | arm64 | ⬆️ upstream only | ⬆️ upstream only | Raspberry Pi 3/4/5, AWS Graviton |
| Linux | armhf (ARMv7) | ⬆️ upstream only | ⬆️ upstream only | Raspberry Pi 2, 32-bit ARM |
| Linux | arm (ARMv5) | ⬆️ upstream only | — | Older ARM devices |
| Linux | 386 | ⬆️ upstream only | — | 32-bit x86 |
| Linux | **mipsle** | ✅ | ✅ | **EdgeRouter X / ER-X-SFP** (MT7621) |
| Linux | **mips64** | ✅ | ✅ | **EdgeRouter Lite / ER-4 / ER-6P / ER-12** (Cavium Octeon) |
| macOS | amd64 | ⬆️ upstream only | — | Intel Mac |
| macOS | arm64 | ⬆️ upstream only | — | Apple Silicon (M1/M2/M3/M4) |

## Quick Install — UBNT

### EdgeRouter X / ER-X-SFP (MIPS little-endian)

```bash
# Download and install the latest release
LATEST=$(curl -s https://api.github.com/repos/ApophisLee/cloudflared-ubnt/releases/latest | grep tag_name | cut -d '"' -f4)
curl -L -o /tmp/cloudflared.deb "https://github.com/ApophisLee/cloudflared-ubnt/releases/download/${LATEST}/cloudflared_${LATEST}_mipsel.deb"
sudo dpkg -i /tmp/cloudflared.deb

# Verify installation
cloudflared --version
```

### EdgeRouter Lite / ER-4 / ER-6P / ER-12 (MIPS64 big-endian)

```bash
# Download and install the latest release
LATEST=$(curl -s https://api.github.com/repos/ApophisLee/cloudflared-ubnt/releases/latest | grep tag_name | cut -d '"' -f4)
curl -L -o /tmp/cloudflared.deb "https://github.com/ApophisLee/cloudflared-ubnt/releases/download/${LATEST}/cloudflared_${LATEST}_mips64.deb"
sudo dpkg -i /tmp/cloudflared.deb

# Verify installation
cloudflared --version
```

### Manual binary install (any architecture)

```bash
# Example for mipsle (EdgeRouter X)
LATEST=$(curl -s https://api.github.com/repos/ApophisLee/cloudflared-ubnt/releases/latest | grep tag_name | cut -d '"' -f4)
curl -L -o /tmp/cloudflared "https://github.com/ApophisLee/cloudflared-ubnt/releases/download/${LATEST}/cloudflared-linux-mipsle"
chmod +x /tmp/cloudflared
sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
```

## Quick Install — Other platforms

For standard platforms (amd64, arm64, macOS, etc.), use the [official upstream releases](https://github.com/cloudflare/cloudflared/releases) directly.

See the [official cloudflared documentation](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/downloads/) for more installation options.

## How the Sync Works

```
┌──────────────────────────┐
│  cloudflare/cloudflared   │  Upstream (official)
│  New release tagged       │
└────────────┬─────────────┘
             │  ⏰ Checked every 6 hours
             ▼
┌──────────────────────────┐
│  sync-upstream-release    │  GitHub Actions workflow
│  .yml                     │
├───────────────────────────┤
│ 1. Detect new release tag │
│ 2. Build 2 MIPS binaries  │
│ 3. Package 2 .deb files   │
│ 4. Create GitHub Release  │
└────────────┬──────────────┘
             ▼
┌──────────────────────────┐
│  cloudflared-ubnt/        │  This fork
│  releases                 │  MIPS/UBNT packages only
└───────────────────────────┘
```

The workflow can also be **manually triggered** from the [Actions tab](https://github.com/ApophisLee/cloudflared-ubnt/actions/workflows/sync-upstream-release.yml) with options to:
- Specify a particular upstream tag to sync
- Force re-release an existing tag

## Running cloudflared as a Service on UBNT

After installing, you can set up cloudflared as a tunnel service:

```bash
# Authenticate (follow the URL that appears)
cloudflared tunnel login

# Create a tunnel
cloudflared tunnel create my-tunnel

# Configure your tunnel (edit the config file)
sudo mkdir -p /etc/cloudflared
sudo cat > /etc/cloudflared/config.yml << 'EOF'
tunnel: <YOUR-TUNNEL-ID>
credentials-file: /root/.cloudflared/<YOUR-TUNNEL-ID>.json

ingress:
  - hostname: myapp.example.com
    service: http://localhost:8080
  - service: http_status:404
EOF

# Run the tunnel
cloudflared tunnel run my-tunnel
```

To run on boot, create a systemd service or add to UBNT task-scheduler.

### Configure via EdgeOS config tree

The UBNT package also installs an EdgeOS/Vyatta config-tree template. After each `commit`, the router writes
`/usr/local/etc/cloudflared/config.yml` from `service cloudflared`.

Basic supported parameters:

- `token`
- `tunnel`
- `credentials-file`
- `loglevel`
- `metrics`
- `protocol`
- ordered `ingress` rules with `hostname`, `path`, and `service`

Example:

```bash
configure

set service cloudflared tunnel 11111111-2222-3333-4444-555555555555
set service cloudflared credentials-file /config/auth/cloudflared.json
set service cloudflared loglevel info
set service cloudflared metrics 127.0.0.1:49312
set service cloudflared ingress 10 hostname app.example.com
set service cloudflared ingress 10 service http://127.0.0.1:8080
set service cloudflared ingress 99 service http_status:404

commit
save
exit
```

If `token` is set, it takes precedence over `tunnel` and `credentials-file` when the generated config is written.
Manual editing of `/usr/local/etc/cloudflared/config.yml` is still possible, but config-tree managed changes will
overwrite it on the next `commit`.

## Development

This fork tracks upstream and adds MIPS architecture support to the `Makefile`.

### Cross-compile for UBNT

```bash
# EdgeRouter X (mipsle, softfloat)
make cloudflared TARGET_OS=linux TARGET_ARCH=mipsle TARGET_MIPS=softfloat

# EdgeRouter Lite/4/6P/12 (mips64)
make cloudflared TARGET_OS=linux TARGET_ARCH=mips64

# Build .deb package
make cloudflared-deb TARGET_OS=linux TARGET_ARCH=mipsle TARGET_MIPS=softfloat
```

### Build & test (standard)

```bash
make cloudflared   # Build for current platform
make test          # Run tests
make lint          # Run linters
```

For full development documentation, see the [upstream README](https://github.com/cloudflare/cloudflared#development).

## Upstream Project

This is a fork of [**cloudflare/cloudflared**](https://github.com/cloudflare/cloudflared) — the official Cloudflare Tunnel client.

- 📖 [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)
- 📦 [Official Releases](https://github.com/cloudflare/cloudflared/releases)
- 🐳 [Docker Image](https://hub.docker.com/r/cloudflare/cloudflared)

## License

Same as upstream — [Apache License 2.0](LICENSE)
