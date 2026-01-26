#!/bin/bash
# install.sh - Copilot Prompts & Instructions Installation Script
#
# Creates symlinks to prompts and instructions in your project.
#
# Usage:
#   ./install.sh [path]              # Install symlinks (default: git root)
#   ./install.sh --uninstall         # Remove symlinks
#   ./install.sh --force             # Overwrite existing files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this repo is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
MODE=""
PROJECT_PATH=""
FORCE=false
DRY_RUN=false

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
            --uninstall)
                MODE="uninstall"
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

    # Default project path to git root or current directory
    if [[ -z "$PROJECT_PATH" ]]; then
        PROJECT_PATH="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    fi
}

show_help() {
    cat << EOF
Copilot Prompts & Instructions Installation Script

Creates symlinks to GitHub Copilot prompts and instructions in your project.

Usage: ./install.sh [PATH] [OPTIONS]

Arguments:
  PATH                  Target directory (default: git root or current dir)

Options:
  --uninstall           Remove installed symlinks
  --force, -f           Overwrite existing files (default: skip)
  --dry-run, -n         Preview changes without making them
  --help, -h            Show this help message

Examples:
  ./install.sh                    # Install to git root
  ./install.sh ~/my-project       # Install to specified project
  ./install.sh --dry-run          # Preview what would be installed
  ./install.sh --force            # Force overwrite existing files
  ./install.sh --uninstall        # Remove symlinks from current project

After Installation:
  Copilot prompts: @workspace /global/review, /global/test, etc.
  Instructions apply automatically based on file type (*.c, *.py, *.sh, etc.)
EOF
}

#######################################
# Symlink operations
#######################################

create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ "$FORCE" != true ]]; then
            warn "Skipping $dest (exists, use --force to overwrite)"
            return 0
        fi
        rm -rf "$dest"
    fi

    if $DRY_RUN; then
        dry_run_msg "Symlink $dest -> $src"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    success "Linked $dest"
}

#######################################
# Installation
#######################################

install() {
    local target="$PROJECT_PATH"

    if [[ ! -d "$target" ]]; then
        error "Project directory not found: $target"
        exit 1
    fi

    info "Installing Copilot prompts and instructions to $target"

    # Create symlinks
    create_symlink "$SCRIPT_DIR/prompts" "$target/.github/prompts/global"
    create_symlink "$SCRIPT_DIR/instructions" "$target/.github/instructions"
    create_symlink "$SCRIPT_DIR/instructions/copilot-instructions.md" "$target/.github/copilot-instructions.md"

    success "Installation complete"
    echo ""
    info "Usage: In VS Code Copilot Chat, use /global/review, /global/test, etc."
}

#######################################
# Uninstall
#######################################

uninstall() {
    local target="$PROJECT_PATH"

    info "Uninstalling Copilot configs from $target"

    local found=false

    # Remove prompts symlink
    if [[ -e "$target/.github/prompts/global" || -L "$target/.github/prompts/global" ]]; then
        if $DRY_RUN; then
            dry_run_msg "Remove $target/.github/prompts/global"
        else
            rm -rf "$target/.github/prompts/global"
        fi
        success "Removed .github/prompts/global"
        found=true
    fi

    # Remove instructions symlink
    if [[ -e "$target/.github/instructions" || -L "$target/.github/instructions" ]]; then
        if $DRY_RUN; then
            dry_run_msg "Remove $target/.github/instructions"
        else
            rm -rf "$target/.github/instructions"
        fi
        success "Removed .github/instructions"
        found=true
    fi

    # Remove copilot-instructions.md symlink
    if [[ -e "$target/.github/copilot-instructions.md" || -L "$target/.github/copilot-instructions.md" ]]; then
        if $DRY_RUN; then
            dry_run_msg "Remove $target/.github/copilot-instructions.md"
        else
            rm -f "$target/.github/copilot-instructions.md"
        fi
        success "Removed .github/copilot-instructions.md"
        found=true
    fi

    if ! $found; then
        info "No installation found in $target"
    fi
}

#######################################
# Main
#######################################

main() {
    parse_args "$@"

    echo ""
    info "Copilot Prompts & Instructions Installer"
    if $DRY_RUN; then
        warn "DRY RUN MODE - No changes will be made"
    fi
    echo ""

    case $MODE in
        install)
            install
            ;;
        uninstall)
            uninstall
            ;;
    esac

    echo ""
    success "Done!"
}

main "$@"
