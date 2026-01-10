#!/bin/bash
# Build addons locally for testing

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
usage() {
    echo "Usage: $0 [addon-name] [options]"
    echo
    echo "Addon names:"
    echo "  stable    Build xcel-itron-mqtt (stable version)"
    echo "  edge      Build xcel-itron-mqtt-edge (edge version)"
    echo "  both      Build both versions (default)"
    echo
    echo "Options:"
    echo "  --no-cache    Build without using Docker cache"
    echo "  --platform    Specify platform (e.g., linux/amd64, linux/arm64)"
    echo
    echo "Examples:"
    echo "  $0                    # Build both addons"
    echo "  $0 stable             # Build stable addon only"
    echo "  $0 edge --no-cache    # Build edge addon without cache"
    echo
    exit 1
}

# Function to get base image version from build.yaml
get_base_version() {
    local build_file="$1"
    if [[ -f "$build_file" ]]; then
        grep "ghcr.io/hassio-addons/base-python:" "$build_file" | head -1 | sed -E 's/.*base-python:([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
    else
        echo ""
    fi
}

# Function to build addon
build_addon() {
    local addon_dir="$1"
    local addon_name="$2"
    local no_cache="$3"
    local platform="$4"

    echo -e "${BLUE}🏗️  Building $addon_name addon...${NC}"

    if [[ ! -d "$addon_dir" ]]; then
        echo -e "${RED}❌ Error: Directory '$addon_dir' not found${NC}" >&2
        return 1
    fi

    local build_file="$addon_dir/build.yaml"
    local base_version
    base_version=$(get_base_version "$build_file")

    if [[ -z "$base_version" ]]; then
        echo -e "${RED}❌ Error: Could not determine base version from $build_file${NC}" >&2
        return 1
    fi

    echo -e "${BLUE}   Base version: $base_version${NC}"

    # Build Docker command
    local docker_cmd=(
        "docker" "build"
        "--build-arg" "BUILD_FROM=ghcr.io/hassio-addons/base-python:$base_version"
        "-t" "local/hassio-$addon_name"
    )

    # Add no-cache if specified
    if [[ "$no_cache" == "true" ]]; then
        docker_cmd+=("--no-cache")
        echo -e "${YELLOW}   Using --no-cache${NC}"
    fi

    # Add platform if specified
    if [[ -n "$platform" ]]; then
        docker_cmd+=("--platform" "$platform")
        echo -e "${YELLOW}   Building for platform: $platform${NC}"
    fi

    # Add context directory
    docker_cmd+=(".")

    # Change to addon directory
    cd "$addon_dir"

    # Show command being executed
    echo -e "${BLUE}   Command: ${docker_cmd[*]}${NC}"
    echo

    # Execute build
    local start_time
    start_time=$(date +%s)

    if "${docker_cmd[@]}"; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo
        echo -e "${GREEN}✅ Successfully built $addon_name addon in ${duration}s${NC}"
        echo -e "${GREEN}   Image: local/hassio-$addon_name${NC}"
    else
        echo
        echo -e "${RED}❌ Failed to build $addon_name addon${NC}" >&2
        cd ..
        return 1
    fi

    cd ..
    return 0
}

# Main script
main() {
    local target="both"
    local no_cache="false"
    local platform=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            stable|edge|both)
                target="$1"
                shift
                ;;
            --no-cache)
                no_cache="true"
                shift
                ;;
            --platform)
                if [[ $# -lt 2 ]]; then
                    echo -e "${RED}Error: --platform requires a value${NC}" >&2
                    usage
                fi
                platform="$2"
                shift 2
                ;;
            --help|-h)
                usage
                ;;
            -*)
                echo -e "${RED}Error: Unknown option $1${NC}" >&2
                usage
                ;;
            *)
                echo -e "${RED}Error: Unknown argument $1${NC}" >&2
                usage
                ;;
        esac
    done

    # Check if Docker is available
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker is not available${NC}" >&2
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker daemon is not running${NC}" >&2
        exit 1
    fi

    echo -e "${BLUE}🐳 Building Home Assistant addons locally${NC}"
    if [[ -n "$platform" ]]; then
        echo -e "${BLUE}   Platform: $platform${NC}"
    fi
    echo

    local success_count=0
    local total_count=0

    # Build based on target
    case "$target" in
        "stable")
            ((total_count++))
            if build_addon "xcel-itron-mqtt" "xcel-itron-mqtt" "$no_cache" "$platform"; then
                ((success_count++))
            fi
            ;;
        "edge")
            ((total_count++))
            if build_addon "xcel-itron-mqtt-edge" "xcel-itron-mqtt-edge" "$no_cache" "$platform"; then
                ((success_count++))
            fi
            ;;
        "both")
            ((total_count+=2))
            if build_addon "xcel-itron-mqtt" "xcel-itron-mqtt" "$no_cache" "$platform"; then
                ((success_count++))
            fi
            echo
            if build_addon "xcel-itron-mqtt-edge" "xcel-itron-mqtt-edge" "$no_cache" "$platform"; then
                ((success_count++))
            fi
            ;;
    esac

    # Summary
    echo
    echo -e "${BLUE}📊 Build Summary:${NC}"
    echo -e "${GREEN}   ✅ Successful: $success_count${NC}"
    if [[ $((total_count - success_count)) -gt 0 ]]; then
        echo -e "${RED}   ❌ Failed: $((total_count - success_count))${NC}"
        exit 1
    fi

    echo
    echo -e "${GREEN}🎉 All builds completed successfully!${NC}"

    # Show built images
    echo
    echo -e "${BLUE}📦 Built images:${NC}"
    docker images | grep "local/hassio-xcel-itron-mqtt" | sed 's/^/   /'
}

# Run main function
main "$@"