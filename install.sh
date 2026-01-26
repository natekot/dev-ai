#!/bin/bash
# install.sh - dev-ai Installation Script (Copilot-only)
#
# Installs Copilot prompts and instructions to project-level directories.
#
# Usage:
#   ./install.sh [path]              # Install prompts + instructions (default: current dir)
#   ./install.sh --instructions [path] # Install only instructions
#   ./install.sh --check             # Check for available updates
#   ./install.sh --update            # Update existing installations
#   ./install.sh --uninstall         # Remove installed files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where dev-ai is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
MODE=""
PROJECT_PATH=""
FORCE=false
DRY_RUN=false
VERBOSE=false

# Version tracking
VERSION_FILE="$SCRIPT_DIR/VERSION"
CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "unknown")

#######################################
# Output functions
#######################################

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

dry_run_msg() {
    if $DRY_RUN; then
        echo -e "${YELLOW}[DRY-RUN]${NC} Would: $1"
    fi
}

#######################################
# Parse command line arguments
#######################################

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                MODE="check"
                shift
                ;;
            --update)
                MODE="update"
                shift
                ;;
            --uninstall)
                MODE="uninstall"
                shift
                ;;
            --instructions)
                MODE="instructions"
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    PROJECT_PATH="$2"
                    shift
                fi
                shift
                ;;
            --force|-f)
                FORCE=true
                shift
                ;;
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                # Positional argument: treat as project path
                PROJECT_PATH="$1"
                shift
                ;;
        esac
    done

    # Default to install mode if no mode specified
    if [[ -z "$MODE" ]]; then
        MODE="install"
    fi

    # Default project path to current directory for install/instructions modes
    if [[ -z "$PROJECT_PATH" && ( "$MODE" == "install" || "$MODE" == "instructions" ) ]]; then
        PROJECT_PATH="$(pwd)"
    fi
}

show_help() {
    cat << EOF
dev-ai Installation Script v${CURRENT_VERSION}

Installs GitHub Copilot prompts and instructions to your project.

Usage: ./install.sh [PATH] [OPTIONS]

Arguments:
  PATH                  Target directory (default: current dir)

Options:
  --instructions        Install only instructions (no prompts)
  --check               Check if updates are available
  --update              Update existing installations
  --uninstall           Remove installed files
  --force, -f           Overwrite existing files (default: skip)
  --dry-run, -n         Preview changes without making them
  --verbose, -v         Show detailed output
  --help, -h            Show this help message

Examples:
  ./install.sh                    # Install to current directory
  ./install.sh ~/my-project       # Install to specified project
  ./install.sh --instructions     # Install only instructions
  ./install.sh --dry-run          # Preview what would be installed
  ./install.sh --check            # Check for updates
  ./install.sh --update --force   # Force update all installations

After Installation:
  Copilot prompts: @workspace /global/review, /global/test, etc.
  Instructions apply automatically based on file type (*.c, *.py, *.sh, etc.)
EOF
}

#######################################
# File operations
#######################################

copy_file() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [[ -f "$dest" && "$FORCE" != true ]]; then
        warn "Skipping $desc (exists, use --force to overwrite)"
        return 0
    fi

    if $DRY_RUN; then
        dry_run_msg "Copy $src -> $dest"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    success "Installed $desc"
}

copy_directory() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if $DRY_RUN; then
        dry_run_msg "Copy directory $src -> $dest"
        return 0
    fi

    mkdir -p "$dest"
    for file in "$src"/*; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            copy_file "$file" "$dest/$filename" "$desc/$filename"
        fi
    done
}

#######################################
# Version tracking
#######################################

get_installed_version() {
    local marker="$1"
    if [[ -f "$marker" ]]; then
        cat "$marker"
    else
        echo ""
    fi
}

track_version() {
    local target_dir="$1"
    local marker="$target_dir/.dev-ai-version"

    if $DRY_RUN; then
        dry_run_msg "Write version $CURRENT_VERSION to $marker"
        return 0
    fi

    mkdir -p "$target_dir"
    echo "$CURRENT_VERSION" > "$marker"
}

#######################################
# Installation functions
#######################################

install_instructions() {
    local target="$PROJECT_PATH"

    if [[ ! -d "$target" ]]; then
        error "Project directory not found: $target"
        exit 1
    fi

    info "Installing Copilot instructions to $target"

    local github_instructions_dir="$target/.github/instructions"
    local github_copilot_instructions="$target/.github/copilot-instructions.md"

    # Create directory
    if ! $DRY_RUN; then
        mkdir -p "$github_instructions_dir"
    fi

    # Install global copilot-instructions.md
    copy_file "$SCRIPT_DIR/instructions/copilot-instructions.md" "$github_copilot_instructions" ".github/copilot-instructions.md"

    # Install language-specific instructions
    info "Installing instructions to .github/instructions/"
    for file in "$SCRIPT_DIR/instructions"/*.instructions.md; do
        if [[ -f "$file" ]]; then
            local filename=$(basename "$file")
            copy_file "$file" "$github_instructions_dir/$filename" ".github/instructions/$filename"
        fi
    done

    # Track version
    track_version "$target/.github/instructions"

    success "Instructions installation complete"
    echo ""
    info "Instructions apply automatically based on file type (*.c, *.py, *.sh, etc.)"
}

install_project() {
    local target="$PROJECT_PATH"

    if [[ ! -d "$target" ]]; then
        error "Project directory not found: $target"
        exit 1
    fi

    info "Installing Copilot prompts and instructions to $target"

    local github_prompts_dir="$target/.github/prompts/global"

    # Create directory
    if ! $DRY_RUN; then
        mkdir -p "$github_prompts_dir"
    fi

    # Install Copilot prompts
    info "Installing prompts to .github/prompts/global/"
    copy_directory "$SCRIPT_DIR/prompts" "$github_prompts_dir" ".github/prompts/global"

    # Track version for prompts
    track_version "$target/.github/prompts/global"

    # Install instructions
    install_instructions

    success "Installation complete"
    echo ""
    info "Usage: In VS Code Copilot Chat, use /global/review, /global/test, etc."
}

#######################################
# Check for updates
#######################################

check_updates() {
    info "Checking for updates (current version: $CURRENT_VERSION)"

    local updates_available=false

    # Check current directory for prompts installation
    local prompts_marker=".github/prompts/global/.dev-ai-version"
    local prompts_version=$(get_installed_version "$prompts_marker")
    if [[ -n "$prompts_version" ]]; then
        if [[ "$prompts_version" != "$CURRENT_VERSION" ]]; then
            warn "Prompts (./): installed $prompts_version, available $CURRENT_VERSION"
            updates_available=true
        else
            success "Prompts (./): up to date ($prompts_version)"
        fi
    else
        info "Prompts (./): not installed"
    fi

    # Check current directory for instructions installation
    local instructions_marker=".github/instructions/.dev-ai-version"
    local instructions_version=$(get_installed_version "$instructions_marker")
    if [[ -n "$instructions_version" ]]; then
        if [[ "$instructions_version" != "$CURRENT_VERSION" ]]; then
            warn "Instructions (./): installed $instructions_version, available $CURRENT_VERSION"
            updates_available=true
        else
            success "Instructions (./): up to date ($instructions_version)"
        fi
    else
        info "Instructions (./): not installed"
    fi

    if $updates_available; then
        echo ""
        info "Run './install.sh --update' to update installations"
        info "Run './install.sh --update --force' to force update (overwrites customizations)"
    fi
}

#######################################
# Update existing installations
#######################################

update_installations() {
    info "Updating existing installations"

    PROJECT_PATH="$(pwd)"
    local updated=false

    # Update prompts if installed in current directory
    local prompts_marker=".github/prompts/global/.dev-ai-version"
    if [[ -f "$prompts_marker" ]]; then
        local prompts_version=$(get_installed_version "$prompts_marker")
        if [[ "$prompts_version" != "$CURRENT_VERSION" ]] || $FORCE; then
            info "Updating prompts..."
            local github_prompts_dir="$PROJECT_PATH/.github/prompts/global"
            copy_directory "$SCRIPT_DIR/prompts" "$github_prompts_dir" ".github/prompts/global"
            track_version "$PROJECT_PATH/.github/prompts/global"
            updated=true
        else
            success "Prompts already up to date"
        fi
    fi

    # Update instructions if installed in current directory
    local instructions_marker=".github/instructions/.dev-ai-version"
    if [[ -f "$instructions_marker" ]]; then
        local instructions_version=$(get_installed_version "$instructions_marker")
        if [[ "$instructions_version" != "$CURRENT_VERSION" ]] || $FORCE; then
            info "Updating instructions..."
            install_instructions
            updated=true
        else
            success "Instructions already up to date"
        fi
    fi

    if ! $updated && [[ ! -f "$prompts_marker" && ! -f "$instructions_marker" ]]; then
        info "No installation found in current directory"
    fi
}

#######################################
# Uninstall
#######################################

uninstall() {
    info "Uninstalling dev-ai configs"

    local found=false

    # Uninstall prompts from current directory
    if [[ -f ".github/prompts/global/.dev-ai-version" ]] || [[ -d ".github/prompts/global" ]]; then
        info "Removing prompts from current directory..."

        if $DRY_RUN; then
            dry_run_msg "Remove .github/prompts/global/"
        else
            rm -rf ".github/prompts/global"
        fi
        success "Copilot prompts uninstalled"
        found=true
    fi

    # Uninstall instructions from current directory
    if [[ -f ".github/instructions/.dev-ai-version" ]] || [[ -d ".github/instructions" ]]; then
        info "Removing instructions from current directory..."

        if $DRY_RUN; then
            dry_run_msg "Remove .github/instructions/"
            dry_run_msg "Remove .github/copilot-instructions.md"
        else
            rm -rf ".github/instructions"
            rm -f ".github/copilot-instructions.md"
        fi
        success "Copilot instructions uninstalled"
        found=true
    fi

    if ! $found; then
        info "No installation found in current directory"
    fi
}

#######################################
# Main
#######################################

main() {
    parse_args "$@"

    echo ""
    info "dev-ai v${CURRENT_VERSION}"
    if $DRY_RUN; then
        warn "DRY RUN MODE - No changes will be made"
    fi
    echo ""

    case $MODE in
        install)
            install_project
            ;;
        instructions)
            install_instructions
            ;;
        check)
            check_updates
            ;;
        update)
            update_installations
            ;;
        uninstall)
            uninstall
            ;;
    esac

    echo ""
    success "Done!"
}

main "$@"
