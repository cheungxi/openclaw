# LoongArch Support Testing Checklist

This document outlines the testing approach for LoongArch CPU support in OpenClaw.

## Automated Tests

### Unit Tests
- [x] `src/dockerfile-loongarch.test.ts` - Validates Dockerfile contains LoongArch-specific changes
  - Checks for `loong64` architecture detection
  - Verifies conditional Bun installation
  - Validates build dependencies for native modules
  - Ensures backward compatibility

### Integration Tests
Due to the lack of LoongArch hardware/VMs in the CI environment, integration tests must be performed manually on LoongArch systems.

## Manual Testing (Requires LoongArch Hardware)

### Prerequisites
- LoongArch hardware or VM (e.g., Loongson 3A5000/3C5000)
- Linux distribution with LoongArch support (e.g., Loongnix, Debian, Arch Linux)
- Docker installed
- Node.js 22+ available

### Docker Build Test

```bash
# Clone the repository
git clone https://github.com/cheungxi/openclaw.git
cd openclaw

# Build the LoongArch Docker image
docker build --platform linux/loong64 -t openclaw:loong64-test .

# Check the image was created
docker images | grep openclaw

# Run a test container
docker run -it --rm openclaw:loong64-test node --version

# Test the gateway
docker run -d -p 18789:18789 --name openclaw-test openclaw:loong64-test
docker logs openclaw-test

# Clean up
docker stop openclaw-test
docker rm openclaw-test
```

### Native Installation Test

```bash
# Install Node.js 22+ on LoongArch
node --version  # Should be >= 22.12.0

# Install build dependencies
sudo apt-get update
sudo apt-get install -y python3 make g++ pkg-config

# Install OpenClaw from npm
npm install -g openclaw@latest

# Verify installation
openclaw --version

# Run basic functionality test
openclaw gateway --port 18789 --verbose &
sleep 10
openclaw message send --to test --message "Hello LoongArch"

# Check gateway status
openclaw gateway status

# Stop gateway
pkill -f openclaw-gateway
```

### Native Module Build Test

```bash
# Test building native modules from source
cd /tmp
mkdir loongarch-test
cd loongarch-test

# Initialize test project
npm init -y

# Try installing native dependencies
npm install sharp@0.34.5
npm install @lydell/node-pty@1.2.0-beta.3

# Check which modules built successfully
npm ls
```

### Expected Results

#### Docker Build
- ✅ Image builds successfully for linux/loong64
- ✅ Bun installation is skipped with appropriate message
- ✅ Build dependencies are installed
- ✅ pnpm install completes (with or without optional dependencies)
- ✅ Application starts and listens on port 18789

#### Native Installation
- ✅ OpenClaw installs via npm
- ✅ Gateway starts successfully
- ✅ Basic message routing works
- ⚠️ Some native modules may build from source (expected)
- ⚠️ Canvas/image features may have limitations (documented)

### Known Limitations

1. **Sharp (image processing)**
   - No prebuilt binaries for LoongArch
   - Will build from source if libvips-dev is available
   - May fail if build dependencies are missing

2. **@napi-rs/canvas**
   - Peer dependency, optional
   - May not have LoongArch support
   - Canvas features may be unavailable

3. **node-llama-cpp**
   - Peer dependency, optional
   - May not support LoongArch architecture
   - Local LLM features may be unavailable

4. **Bun runtime**
   - Not available on LoongArch
   - Falls back to Node.js (fully functional)

## GitHub Actions CI

The LoongArch build is integrated into the Docker release workflow:

- Job: `build-loong64`
- Platform: `linux/loong64`
- Emulation: QEMU (until native LoongArch runners available)
- Registry: GitHub Container Registry
- Tags: `-loong64` suffix

### CI Verification

Check the CI build status at:
- https://github.com/cheungxi/openclaw/actions/workflows/docker-release.yml

Expected CI results:
- ✅ `build-loong64` job completes successfully
- ✅ Image is pushed to GitHub Container Registry
- ✅ Multi-platform manifest includes loong64

## Reporting Issues

If you encounter issues on LoongArch:

1. Check this testing checklist
2. Review [LoongArch documentation](/docs/platforms/loongarch.md)
3. Search [GitHub Issues](https://github.com/cheungxi/openclaw/issues)
4. Create a new issue with:
   - LoongArch system details (CPU model, OS, kernel version)
   - Node.js version
   - Full error logs
   - Steps to reproduce

## Future Improvements

1. **Native CI Runners**: Once GitHub Actions supports LoongArch runners, switch from QEMU emulation
2. **Prebuilt Binaries**: Work with native module maintainers to add LoongArch prebuilt binaries
3. **Performance Optimization**: Benchmark and optimize for LoongArch-specific features
4. **Extended Testing**: Add more comprehensive test coverage once hardware is available
