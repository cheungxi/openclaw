---
summary: "LoongArch CPU support and installation guide"
read_when:
  - Installing OpenClaw on LoongArch systems
  - Running OpenClaw on Chinese domestic hardware
  - Understanding LoongArch-specific limitations
title: "LoongArch Support"
---

# LoongArch Support

OpenClaw now supports LoongArch (loong64) CPU architecture, enabling deployment on Chinese domestic hardware platforms.

## Overview

LoongArch is a RISC instruction set architecture (ISA) developed by Loongson Technology Corporation. OpenClaw provides LoongArch support through:

- Multi-architecture Docker images
- Node.js runtime compatibility (Node 22+)
- Graceful handling of native module limitations

## Installation

### Docker (Recommended)

The easiest way to run OpenClaw on LoongArch is using Docker:

```bash
# Pull the LoongArch-specific image
docker pull ghcr.io/cheungxi/openclaw:main-loong64

# Or use the multi-platform manifest (auto-detects architecture)
docker pull ghcr.io/cheungxi/openclaw:main

# Run the container
docker run -d \
  -p 18789:18789 \
  -v ~/.openclaw:/home/node/.openclaw \
  --name openclaw-gateway \
  ghcr.io/cheungxi/openclaw:main
```

### Native Installation

For native installation on LoongArch Linux systems:

1. **Install Node.js 22+**

   ```bash
   # Using NodeSource repository
   curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Verify installation
   node --version  # Should be >= 22.12.0
   ```

2. **Install OpenClaw**

   ```bash
   npm install -g openclaw@latest
   ```

3. **Run onboarding**

   ```bash
   openclaw onboard --install-daemon
   ```

## Known Limitations

### Native Module Compatibility

Some optional native modules may not have prebuilt binaries for LoongArch and will be built from source during installation:

- **sharp** - Image processing library (may require building from source)
- **@napi-rs/canvas** - Canvas rendering (peer dependency, optional)
- **node-llama-cpp** - Local LLM support (peer dependency, optional)
- **@lydell/node-pty** - Terminal emulation (built from source)

### Build Dependencies

When installing from npm on LoongArch, ensure you have build tools installed:

```bash
sudo apt-get update
sudo apt-get install -y python3 make g++ pkg-config
```

### Bun Runtime

Bun is not currently available for LoongArch. OpenClaw will automatically fall back to using Node.js for all operations when running on LoongArch systems.

## Docker Build Details

The LoongArch Docker image:

- Uses QEMU emulation for cross-platform builds on GitHub Actions
- Installs additional build dependencies (python3, make, g++, pkg-config)
- Gracefully handles optional native modules
- Uses pnpm exclusively (skips Bun installation)

## Performance Considerations

- **QEMU Emulation**: Initial Docker image builds use QEMU emulation, which may be slower than native builds
- **Native Modules**: Building native modules from source during installation takes longer than using prebuilt binaries
- **Runtime Performance**: Once installed, OpenClaw runs at native LoongArch speed with excellent performance

## Troubleshooting

### Installation Fails with Native Module Errors

If installation fails due to native module build errors:

1. Install build dependencies:
   ```bash
   sudo apt-get install -y python3 make g++ pkg-config libvips-dev
   ```

2. Try installing without optional dependencies:
   ```bash
   npm install -g openclaw@latest --no-optional
   ```

3. For Docker, ensure you're using the LoongArch-specific image:
   ```bash
   docker pull ghcr.io/cheungxi/openclaw:main-loong64
   ```

### Gateway Won't Start

1. Check Node.js version:
   ```bash
   node --version  # Must be >= 22.12.0
   ```

2. Check gateway logs:
   ```bash
   openclaw gateway logs
   ```

3. Try running in verbose mode:
   ```bash
   openclaw gateway --verbose
   ```

### Canvas/Image Processing Issues

If canvas or image processing features don't work:

1. Install system libraries:
   ```bash
   sudo apt-get install -y libvips-dev libcairo2-dev libpango1.0-dev
   ```

2. Rebuild native modules:
   ```bash
   npm rebuild sharp @napi-rs/canvas
   ```

## Testing

To verify LoongArch support:

```bash
# Check architecture
uname -m  # Should show: loongarch64

# Verify OpenClaw installation
openclaw --version

# Test gateway
openclaw gateway --port 18789 --verbose

# Send a test message (in another terminal)
openclaw message send --to test --message "Hello from LoongArch"
```

## CI/CD Integration

The LoongArch build is integrated into the OpenClaw CI/CD pipeline:

- Automatically builds on every release
- Uses GitHub Actions with QEMU emulation
- Publishes to GitHub Container Registry
- Included in multi-platform manifests

## Contributing

To improve LoongArch support:

1. Test OpenClaw on real LoongArch hardware
2. Report issues specific to LoongArch
3. Contribute build fixes for native modules
4. Help improve documentation

## Support

For LoongArch-specific issues:

- Check [GitHub Issues](https://github.com/cheungxi/openclaw/issues)
- Join [Discord](https://discord.gg/clawd)
- See general [Linux support documentation](/platforms/linux)

## Additional Resources

- [LoongArch Architecture](https://loongson.github.io/LoongArch-Documentation/)
- [Node.js on LoongArch](https://nodejs.org/)
- [Docker Multi-Platform Images](https://docs.docker.com/build/building/multi-platform/)
- [OpenClaw Docker Guide](/install/docker)
