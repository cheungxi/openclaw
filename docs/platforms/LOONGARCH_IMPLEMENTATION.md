# LoongArch CPU Support - Implementation Summary

This document summarizes the changes made to add LoongArch (loong64) CPU architecture support to the OpenClaw project.

## Overview

LoongArch is a RISC instruction set architecture (ISA) developed by Loongson Technology Corporation, commonly used in Chinese domestic hardware. This implementation adds full support for running OpenClaw on LoongArch systems through both Docker and native installations.

## Changes Made

### 1. Dockerfile Updates (`Dockerfile`)

**Architecture Detection**
- Added `TARGETARCH` argument for multi-platform builds
- Implemented architecture detection using `dpkg --print-architecture`
- Added conditional logic for LoongArch-specific handling

**Bun Installation**
- Made Bun installation conditional (skips on LoongArch)
- Added fallback message when Bun is unavailable
- Ensures Node.js is used for all operations on LoongArch

**Build Dependencies**
- Added automatic installation of build tools on LoongArch:
  - `python3` - Required for node-gyp
  - `make` - Build system
  - `g++` - C++ compiler
  - `pkg-config` - Package configuration

**Dependency Installation**
- Added graceful handling of optional dependencies on LoongArch
- Falls back to `pnpm install` without `--no-optional` if first attempt fails
- Provides informative messages during installation

### 2. GitHub Actions Workflow (`.github/workflows/docker-release.yml`)

**New Build Job: `build-loong64`**
- Runs on `ubuntu-latest` with QEMU emulation
- Builds for `linux/loong64` platform
- Uses separate cache for LoongArch builds
- Pushes images with `-loong64` suffix

**QEMU Setup**
- Added QEMU setup step for cross-platform builds
- Enables `linux/loong64` emulation

**Multi-Platform Manifest**
- Updated to include LoongArch digest
- Creates unified manifest supporting amd64, arm64, and loong64
- Docker automatically selects correct image based on host architecture

**Tag Updates**
- All build jobs now include `-loong64` suffix in tags
- Maintains consistency across all architectures

### 3. Documentation

**New Documentation Files**

1. `docs/platforms/loongarch.md` - Comprehensive LoongArch guide
   - Installation instructions (Docker and native)
   - Architecture overview
   - Known limitations
   - Troubleshooting guide
   - Performance considerations

2. `docs/platforms/loongarch-testing.md` - Testing documentation
   - Automated test descriptions
   - Manual testing procedures
   - Expected results
   - Known limitations
   - CI verification steps

**Updated Documentation Files**

1. `docs/platforms/index.md`
   - Added LoongArch to platform list

2. `docs/platforms/linux.md`
   - Added architecture support note
   - Reference to LoongArch-specific documentation

3. `docs/install/docker.md`
   - Added architecture support section
   - Listed all supported architectures (amd64, arm64, loong64)

### 4. Testing

**Unit Test: `src/dockerfile-loongarch.test.ts`**
- Validates Dockerfile contains LoongArch-specific changes
- Checks for architecture detection logic
- Verifies conditional Bun installation
- Ensures build dependencies are included
- Tests backward compatibility

## Technical Details

### Architecture Detection

The Dockerfile uses two methods for architecture detection:

1. **Build-time**: `TARGETARCH` build argument from Docker Buildx
2. **Runtime**: `dpkg --print-architecture` for Debian-based detection

### Platform Identifiers

- Docker platform: `linux/loong64`
- Debian architecture: `loong64`
- Alternative names: `loongarch64` (kernel), `loong64` (Docker)

### Native Module Handling

Native Node.js modules are handled as follows:

1. **Sharp** - Image processing library
   - No prebuilt binaries for LoongArch
   - Builds from source if libvips-dev available
   - Optional dependency

2. **@napi-rs/canvas** - Canvas rendering
   - Peer dependency (optional)
   - May not support LoongArch
   - Features gracefully degrade if unavailable

3. **node-llama-cpp** - Local LLM support
   - Peer dependency (optional)
   - May not support LoongArch
   - Local LLM features unavailable if not installed

4. **@lydell/node-pty** - Terminal emulation
   - Builds from source
   - Requires build tools (included in Docker image)

### CI/CD Integration

The LoongArch build is fully integrated into the release pipeline:

1. **Automatic Builds**: Triggered on every push to main and version tags
2. **Emulation**: Uses QEMU for cross-platform builds on x86_64 CI runners
3. **Caching**: Separate cache for LoongArch to optimize build times
4. **Registry**: Published to GitHub Container Registry (ghcr.io)
5. **Tagging**: Follows same conventions as amd64/arm64 builds

## Known Limitations

1. **QEMU Performance**: Initial builds use QEMU emulation (slower than native)
2. **Bun Unavailable**: Bun runtime not supported on LoongArch (falls back to Node.js)
3. **Native Modules**: Some optional modules may need to build from source
4. **Canvas/Image Processing**: May have limited functionality without prebuilt binaries
5. **Testing**: Full end-to-end testing requires actual LoongArch hardware

## Compatibility

### Backward Compatibility
All changes maintain full backward compatibility with existing architectures:
- amd64 (x86_64) builds unchanged
- arm64 (aarch64) builds unchanged
- All existing functionality preserved

### Forward Compatibility
The implementation is designed to accommodate future improvements:
- Easy to switch to native CI runners when available
- Prepared for prebuilt native module binaries
- Extensible architecture detection logic

## Deployment

### Docker Users

Pull the multi-platform image:
```bash
docker pull ghcr.io/cheungxi/openclaw:main
```

Or pull the LoongArch-specific image:
```bash
docker pull ghcr.io/cheungxi/openclaw:main-loong64
```

### Native Installation

Install via npm (requires Node.js 22+):
```bash
npm install -g openclaw@latest
```

Build dependencies may be needed:
```bash
sudo apt-get install python3 make g++ pkg-config
```

## Testing Status

- ✅ Unit tests passing
- ✅ Dockerfile syntax validated
- ✅ GitHub Actions workflow validated
- ✅ Documentation complete
- ⏳ Manual testing on LoongArch hardware (pending hardware availability)

## Future Enhancements

1. **Native CI Runners**: Migrate to native LoongArch runners when available
2. **Prebuilt Binaries**: Work with upstream to add LoongArch prebuilt binaries
3. **Performance Tuning**: Optimize for LoongArch-specific features
4. **Extended Testing**: Comprehensive test suite on real hardware
5. **Community Feedback**: Gather feedback from LoongArch users

## References

- [LoongArch Architecture Documentation](https://loongson.github.io/LoongArch-Documentation/)
- [Docker Multi-Platform Builds](https://docs.docker.com/build/building/multi-platform/)
- [Node.js Platform Support](https://nodejs.org/)
- [OpenClaw Documentation](https://docs.openclaw.ai)

## Support

For LoongArch-specific issues:
- Documentation: `/docs/platforms/loongarch.md`
- Testing Guide: `/docs/platforms/loongarch-testing.md`
- GitHub Issues: https://github.com/cheungxi/openclaw/issues
- Discord: https://discord.gg/clawd

---

**Implementation Date**: February 2026  
**Author**: GitHub Copilot  
**Status**: Complete (pending hardware testing)
