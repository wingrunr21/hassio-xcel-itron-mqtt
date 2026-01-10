# AGENTS.md

This file provides structured guidance for AI agents working with this codebase.

## Project Context

**Purpose**: Home Assistant addon that bridges Xcel Energy iTron Riva Gen 5 smart meters to MQTT

**Technology Stack**:
- Home Assistant addon framework
- Python (via [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt))
- Docker multi-stage builds
- S6 overlay for service management
- IEEE 2030.5 protocol for meter communication
- MQTT for Home Assistant integration

**Repository Structure**:
```
xcel-itron-mqtt/         # Stable addon version
xcel-itron-mqtt-edge/    # Edge addon version (pre-release)
scripts/                 # Build and maintenance utilities
.devcontainer/           # Development container configuration
```

## Agent Rules

### Code Modification Principles

1. **Home Assistant Conventions**: Always follow Home Assistant addon patterns and standards
2. **Shell Script Standards**:
   - Use `#!/command/with-contenv bashio` shebang for integration with Home Assistant
   - Leverage bashio library for all logging and configuration access
   - Follow shellcheck standards (pre-configured in devcontainer)
3. **Certificate Security**: EC P-256 curve certificates are required by IEEE 2030.5 - do not change certificate generation algorithm
4. **Version Synchronization**: When updating base images or dependencies, update both stable and edge versions unless explicitly instructed otherwise
5. **Upstream Dependency Management**:
   - Python code comes from upstream GitHub via commit SHA
   - Update `XCEL_ITRON2MQTT_SHA` in Dockerfile to change versions
   - Always remove upstream `run.sh` and use S6 overlay service scripts instead

### Testing Requirements

- No automated test suite exists - all changes require manual testing
- Test using Home Assistant development container for integration validation
- Ideally test with actual iTron meter hardware or mock server
- Verify MQTT integration after any protocol or communication changes

## Architecture Reference

### Addon Components

**Configuration Files**:
- `config.yaml` - Addon metadata, user configuration schema, and options
- `build.yaml` - Docker build settings and base image specifications
- `Dockerfile` - Multi-stage build downloading upstream Python code
- `rootfs/` - Files deployed to addon container filesystem

**Service Structure** (S6 overlay in `rootfs/etc/s6-overlay/s6-rc.d/`):
- **init-xcel-itron-mqtt**: One-time initialization service
  - Generates SSL certificates using OpenSSL
  - Calculates LFDI (Local Device Functional Identifier) from certificate
  - Runs before main service starts
- **xcel-itron-mqtt**: Main application service
  - Runs Python bridge connecting meter to MQTT
  - Depends on init service completion

### Data Flow

1. Addon connects to iTron smart meter over local network (IEEE 2030.5 protocol)
2. Meter data collected and formatted by Python library
3. Data published to Home Assistant's MQTT broker
4. Home Assistant auto-discovers devices via MQTT discovery protocol

### Certificate Management

- **Algorithm**: EC P-256 curve (required by IEEE 2030.5 standard)
- **Storage**: `/config/certs` directory (persisted in Home Assistant addon_configs)
- **LFDI Calculation**: First 40 characters of certificate SHA-256 fingerprint
- **Auto-generation**: Init service creates certificates on first run if missing

### Configuration Schema

**User-configurable options** (`config.yaml`):
- `meter_ip`: Required - iTron meter IP address
- `meter_port`: Default 8081 - iTron meter communication port
- `cert_dir`: Certificate storage location (default `/config/certs`)
- `lfdi`: Auto-calculated from certificates (read-only)

**Build configuration** (`build.yaml`):
- Base image: Home Assistant base-python image
- Architectures: aarch64, amd64, armv7, armhf, i386

## Common Development Tasks

### Building Addons Locally

**Using utility scripts** (recommended):
```bash
# Build both stable and edge versions
./scripts/build-local.sh both

# Build only stable version
./scripts/build-local.sh stable

# Build edge version without cache
./scripts/build-local.sh edge --no-cache
```

**Manual Docker builds**:
```bash
# Stable addon (check build.yaml for current base image version)
cd xcel-itron-mqtt
docker build --build-arg BUILD_FROM="ghcr.io/hassio-addons/base-python:13.1.3" \
  -t local/hassio-xcel-itron-mqtt .

# Edge addon
cd xcel-itron-mqtt-edge
docker build --build-arg BUILD_FROM="ghcr.io/hassio-addons/base-python:13.1.3" \
  -t local/hassio-xcel-itron-mqtt-edge .
```

### Updating Base Images

**Update to latest version** (recommended):
```bash
# Dry-run to preview changes (fetches latest from GitHub)
./scripts/update-base-version.sh --dry-run

# Apply updates to latest version
./scripts/update-base-version.sh

# Update only edge addon to latest
./scripts/update-base-version.sh --target edge
```

**Update to specific version**:
```bash
# Dry-run to preview changes
./scripts/update-base-version.sh 17.0.0 --dry-run

# Apply updates to specific version
./scripts/update-base-version.sh 17.0.0

# Update only stable addon
./scripts/update-base-version.sh 17.0.0 --target stable
```

**Script features**:
- Defaults to latest version from GitHub if no version specified
- Supports `--target stable|edge|both` to update specific addons
- Supports `--dry-run` to preview changes before applying
- Shows confirmation message when files are updated

### Updating Upstream Python Dependency

1. Find desired commit SHA from [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt)
2. Update `XCEL_ITRON2MQTT_SHA` variable in both Dockerfiles
3. Rebuild and test both addon versions
4. Verify meter connectivity and data publishing

### Development Environment

**Devcontainer features**:
- Image: `ghcr.io/home-assistant/devcontainer:addons`
- Pre-installed extensions: ShellCheck, Prettier
- Auto-formatting on save enabled
- Full Home Assistant development environment

**Working with devcontainer**:
- Use VSCode's "Reopen in Container" feature
- Shell scripts automatically validated by ShellCheck
- Prettier formats YAML and JSON on save

## CI/CD and Automation

### GitHub Actions Workflows

The repository uses GitHub Actions for automated building and publishing:

**Build Edge** (`.github/workflows/build-edge.yaml`):
- **Trigger**: Push to main with changes to `xcel-itron-mqtt-edge/**`
- **Purpose**: Automatically builds and publishes edge addon on every commit
- **Tags**: Version with timestamp (e.g., `1.6.0-20260110-153820`) + `edge` tag
- **Target**: `xcel-itron-mqtt-edge` addon
- **Registry**: GitHub Container Registry (ghcr.io)

**Build Release** (`.github/workflows/build-release.yaml`):
- **Trigger**: Push of version tags (e.g., `v1.5.0`)
- **Purpose**: Builds and publishes stable addon releases
- **Tags**: Specific version from git tag
- **Target**: `xcel-itron-mqtt` (stable addon)
- **Post-build**: Creates GitHub release with auto-generated notes

### Workflow Testing with act

[act](https://github.com/nektos/act) is available for local workflow testing before pushing to GitHub:

```bash
# List all workflows and jobs
act -l

# Test edge workflow (dry run)
act push -W .github/workflows/build-edge.yaml -n \
  --container-architecture linux/amd64 \
  -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Test release workflow
act push -W .github/workflows/build-release.yaml -n \
  --container-architecture linux/amd64 \
  -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

**act limitations**:
- Some GitHub Actions features may not work identically locally
- Home Assistant builder action requires actual registry access
- Multi-architecture builds are challenging to test locally
- Use primarily for syntax validation and workflow structure testing

### Versioning Strategy

**Edge builds**:
- Automatic on every push to main affecting edge addon
- Version format: `{config-version}-{timestamp}` extracted from `config.yaml`
- Example: `1.6.0-20260110-153820`
- Always tagged with `edge` for latest

**Stable releases**:
- Manual via git tags following semver (e.g., `v1.5.0`)
- Version extracted from tag and used for image tagging
- Creates corresponding GitHub release

### Container Registry

**Registry**: GitHub Container Registry (ghcr.io)  
**Namespace**: `ghcr.io/{repository_owner}`  
**Images**:
- `xcel-itron-mqtt` - Stable addon releases
- `xcel-itron-mqtt-edge` - Edge builds with latest changes

## Troubleshooting Guide

### Common Issues and Solutions

**Meter connectivity failures**:
- Root cause: Meter firmware or network issue
- Solution: Meter reboot required (contact Xcel Energy for remote reboot)
- Verification: Check addon logs for connection establishment

**Certificate problems**:
- Symptoms: LFDI errors, authentication failures
- Solution: Delete `/config/certs` directory and restart addon
- Prevention: Ensure certificate generation completes in init service

**MQTT integration issues**:
- Prerequisites: Home Assistant MQTT integration must be configured first
- Verification: Check MQTT broker connectivity before troubleshooting addon
- Discovery: Devices should auto-appear via MQTT discovery protocol

**Build failures**:
- Base image: Verify base image version exists in Home Assistant registry
- Architecture: Ensure building for supported architecture
- Network: Check internet connectivity for upstream Python code download

## File Location Reference

**Key addon files**:
- Configuration: `{addon}/config.yaml`
- Build settings: `{addon}/build.yaml`
- Docker build: `{addon}/Dockerfile`
- Init script: `{addon}/rootfs/etc/s6-overlay/s6-rc.d/init-xcel-itron-mqtt/run`
- Main script: `{addon}/rootfs/etc/s6-overlay/s6-rc.d/xcel-itron-mqtt/run`
- Service dependencies: `{addon}/rootfs/etc/s6-overlay/s6-rc.d/user/contents.d/`

**Utility scripts**:
- Base update checker: `scripts/check-base-updates.sh`
- Version updater: `scripts/update-base-version.sh`
- Local builder: `scripts/build-local.sh`

**Development config**:
- Devcontainer: `.devcontainer/devcontainer.json`
- VSCode tasks: `.vscode/tasks.json`

## Important Constraints

1. **No breaking changes to certificate format** - would break existing installations
2. **Maintain compatibility with Home Assistant addon standards** - must pass addon validation
3. **Preserve MQTT discovery payloads** - changes affect Home Assistant device/entity creation
4. **Keep both addon versions in sync** - architectural changes apply to both stable and edge
5. **Upstream code is external** - cannot modify Python library, only wrap it
6. **Multi-architecture support required** - must build for all specified architectures

## External Dependencies

- Upstream library: [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt)
- Base image: ghcr.io/hassio-addons/base-python (versioned in build.yaml)
- Home Assistant: MQTT integration required for functionality
- Xcel Energy: iTron Riva Gen 5 meter firmware compatibility
