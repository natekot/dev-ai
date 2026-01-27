#!/bin/bash
# install.sh - Copilot Prompts & Instructions Installation Script
#
# Creates symlinks to prompts and instructions in your project.
#
# Usage:
#   ./install.sh <path>              # Install symlinks to target project
#   ./install.sh --uninstall <path>  # Remove symlinks
#   ./install.sh --force <path>      # Overwrite existing files

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

    # Require project path
    if [[ -z "$PROJECT_PATH" ]]; then
        error "Missing required argument: PATH"
        echo ""
        show_help
        exit 1
    fi
}

show_help() {
    cat << EOF
Copilot Prompts & Instructions Installation Script

Creates symlinks to GitHub Copilot prompts and instructions in your project.

Usage: ./install.sh <PATH> [OPTIONS]

Arguments:
  PATH                  Target project directory (required)

Options:
  --uninstall           Remove installed symlinks
  --force, -f           Overwrite existing files (default: skip with warning)
  --dry-run, -n         Preview changes without making them
  --help, -h            Show this help message

Examples:
  ./install.sh ~/my-project             # Install to specified project
  ./install.sh ~/my-project --dry-run   # Preview what would be installed
  ./install.sh ~/my-project --force     # Force overwrite existing files
  ./install.sh --uninstall ~/my-project # Remove symlinks

After Installation:
  Copilot prompts: @workspace /review, /test, etc.
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
# Git exclude operations
#######################################

add_git_excludes() {
    local target="$1"
    local exclude_file="$target/.git/info/exclude"

    # Skip if not a git repo
    [[ ! -d "$target/.git" ]] && return 0

    # Skip if already has our marker
    grep -q "# dev-ai installed" "$exclude_file" 2>/dev/null && return 0

    if $DRY_RUN; then
        dry_run_msg "Add exclusions to $exclude_file"
        return 0
    fi

    # Append our exclusions
    {
        echo ""
        echo "# dev-ai installed prompts/instructions"
        echo ".github/prompts/*.prompt.md"
        echo ".github/instructions/*.instructions.md"
    } >> "$exclude_file"

    success "Added git exclusions (files hidden from git status)"
}

remove_git_excludes() {
    local target="$1"
    local exclude_file="$target/.git/info/exclude"

    [[ ! -f "$exclude_file" ]] && return 0
    ! grep -q "# dev-ai installed" "$exclude_file" && return 0

    if $DRY_RUN; then
        dry_run_msg "Remove exclusions from $exclude_file"
        return 0
    fi

    # Remove our section (blank line + marker + 2 patterns)
    # macOS sed requires '' after -i
    sed -i '' '/^$/N;/# dev-ai installed/,+2d' "$exclude_file"

    success "Removed git exclusions"
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

    # Ensure target directories exist
    if ! $DRY_RUN; then
        mkdir -p "$target/.github/prompts"
        mkdir -p "$target/.github/instructions"
    fi

    # Symlink each prompt file
    for prompt in "$SCRIPT_DIR/.github/prompts"/*.prompt.md; do
        if [[ -f "$prompt" ]]; then
            filename=$(basename "$prompt")
            create_symlink "$prompt" "$target/.github/prompts/$filename"
        fi
    done

    # Symlink each instruction file
    for instr in "$SCRIPT_DIR/.github/instructions"/*.instructions.md; do
        if [[ -f "$instr" ]]; then
            filename=$(basename "$instr")
            create_symlink "$instr" "$target/.github/instructions/$filename"
        fi
    done

    # Add git excludes to hide symlinked files from git status
    add_git_excludes "$target"

    success "Installation complete"
    echo ""
    info "Usage: In VS Code Copilot Chat, use /review, /test, etc."
}

#######################################
# Uninstall
#######################################

uninstall() {
    local target="$PROJECT_PATH"

    info "Uninstalling Copilot configs from $target"

    local found=false

    # Remove prompt symlinks that point to this repo
    if [[ -d "$target/.github/prompts" ]]; then
        for file in "$target/.github/prompts"/*.prompt.md; do
            if [[ -L "$file" ]]; then
                link_target=$(readlink "$file")
                if [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
                    if $DRY_RUN; then
                        dry_run_msg "Remove $file"
                    else
                        rm "$file"
                    fi
                    success "Removed $(basename "$file")"
                    found=true
                fi
            fi
        done
    fi

    # Remove instruction symlinks that point to this repo
    if [[ -d "$target/.github/instructions" ]]; then
        for file in "$target/.github/instructions"/*.instructions.md; do
            if [[ -L "$file" ]]; then
                link_target=$(readlink "$file")
                if [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
                    if $DRY_RUN; then
                        dry_run_msg "Remove $file"
                    else
                        rm "$file"
                    fi
                    success "Removed $(basename "$file")"
                    found=true
                fi
            fi
        done
    fi

    # Also remove old-style global directory symlinks if present (migration)
    if [[ -L "$target/.github/prompts/global" ]]; then
        link_target=$(readlink "$target/.github/prompts/global")
        if [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
            if $DRY_RUN; then
                dry_run_msg "Remove $target/.github/prompts/global (old-style)"
            else
                rm "$target/.github/prompts/global"
            fi
            success "Removed .github/prompts/global (old-style)"
            found=true
        fi
    fi

    if [[ -L "$target/.github/instructions/global" ]]; then
        link_target=$(readlink "$target/.github/instructions/global")
        if [[ "$link_target" == "$SCRIPT_DIR"* ]]; then
            if $DRY_RUN; then
                dry_run_msg "Remove $target/.github/instructions/global (old-style)"
            else
                rm "$target/.github/instructions/global"
            fi
            success "Removed .github/instructions/global (old-style)"
            found=true
        fi
    fi

    # Remove git excludes
    remove_git_excludes "$target"

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
