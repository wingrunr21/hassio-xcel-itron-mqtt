#!/bin/bash
# Update hassio-addons/addon-base-python versions in build.yaml files

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [version] [--target stable|edge|both] [--dry-run]

Options:
  --target stable     Update only xcel-itron-mqtt (stable) addon
  --target edge       Update only xcel-itron-mqtt-edge addon
  --target both       Update both addons (default)
  --dry-run           Show what would be changed without making changes

Arguments:
  version             Specific version number (e.g., 17.0.0)
                      If omitted, fetches and uses the latest release from GitHub

Examples:
  $0                             # Update both addons to latest version
  $0 17.0.0                      # Update both addons to version 17.0.0
  $0 --target edge               # Update only edge addon to latest
  $0 17.0.0 --dry-run            # Preview changes with specific version
EOF
    exit 1
}

get_latest_version() {
    echo "Fetching latest version from GitHub..." >&2
    local latest
    latest=$(curl -s "https://api.github.com/repos/hassio-addons/addon-base-python/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')

    if [[ -z "$latest" || ! "$latest" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Failed to fetch latest version from GitHub" >&2
        exit 1
    fi

    echo "$latest"
}

validate_version() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
        echo "Error: Invalid version format '$1'. Expected format: X.Y.Z" >&2
        exit 1
    }
}

update_build_yaml() {
    local file="$1"
    local new_version="$2"
    local dry_run="$3"

    [[ -f "$file" ]] || {
        echo "Error: File '$file' does not exist" >&2
        return 1
    }

    local current_version
    current_version=$(grep "ghcr.io/hassio-addons/base-python:" "$file" | head -1 | sed -E 's/.*base-python:([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

    [[ -n "$current_version" ]] || {
        echo "Error: Could not find base-python version in '$file'" >&2
        return 1
    }

    if [[ "$current_version" == "$new_version" ]]; then
        echo "$file: Already at version $new_version"
        return 0
    fi

    echo "$file: $current_version → $new_version"

    if [[ "$dry_run" == "true" ]]; then
        return 0
    fi

    # Update the file
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s|ghcr.io/hassio-addons/base-python:$current_version|ghcr.io/hassio-addons/base-python:$new_version|g" "$file"
    else
        sed -i "s|ghcr.io/hassio-addons/base-python:$current_version|ghcr.io/hassio-addons/base-python:$new_version|g" "$file"
    fi

    echo "  ✓ Updated successfully"
}

main() {
    local new_version=""
    local dry_run="false"
    local target="both"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run="true"
                shift
                ;;
            --target)
                [[ -n "${2:-}" && "$2" != --* ]] || {
                    echo "Error: --target requires an argument (stable|edge|both)" >&2
                    usage
                }
                target="$2"
                [[ "$target" =~ ^(stable|edge|both)$ ]] || {
                    echo "Error: Invalid target '$target'. Must be stable, edge, or both" >&2
                    usage
                }
                shift 2
                ;;
            --help|-h)
                usage
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                usage
                ;;
            *)
                [[ -z "$new_version" ]] || {
                    echo "Error: Too many arguments" >&2
                    usage
                }
                new_version="$1"
                shift
                ;;
        esac
    done

    # Handle version argument - default to latest if not provided
    if [[ -z "$new_version" || "$new_version" == "latest" ]]; then
        new_version=$(get_latest_version)
        echo "Latest version: $new_version"
    else
        validate_version "$new_version"
    fi

    # Determine which addons to update
    local addon_dirs=()
    case "$target" in
        stable) addon_dirs=("xcel-itron-mqtt") ;;
        edge) addon_dirs=("xcel-itron-mqtt-edge") ;;
        both) addon_dirs=("xcel-itron-mqtt" "xcel-itron-mqtt-edge") ;;
    esac

    [[ "$dry_run" == "true" ]] && echo "[DRY RUN]"

    # Update build.yaml files
    local updated=0
    local failed=0

    for addon_dir in "${addon_dirs[@]}"; do
        if [[ -d "$addon_dir" ]]; then
            if update_build_yaml "$addon_dir/build.yaml" "$new_version" "$dry_run"; then
                ((updated++))
            else
                ((failed++))
            fi
        else
            echo "Warning: Directory '$addon_dir' not found" >&2
        fi
    done

    [[ $failed -eq 0 ]] || exit 1
}

main "$@"
