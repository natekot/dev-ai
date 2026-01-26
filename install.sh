#!/bin/bash
# install.sh - Global AI Config Repository Installation Script
#
# Installs dev-ai configs to user-level (~/.claude/) and/or project-level directories.
#
# Usage:
#   ./install.sh --user              # Install to ~/.claude/
#   ./install.sh --project [path]    # Install commands/prompts to target repo
#   ./install.sh --all [path]        # Both user + project
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
            --user)
                MODE="user"
                shift
                ;;
            --project)
                MODE="project"
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    PROJECT_PATH="$2"
                    shift
                fi
                shift
                ;;
            --all)
                MODE="all"
                if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                    PROJECT_PATH="$2"
                    shift
                fi
                shift
                ;;
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
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Default project path to current directory if not specified
    if [[ -z "$PROJECT_PATH" && ("$MODE" == "project" || "$MODE" == "all") ]]; then
        PROJECT_PATH="$(pwd)"
    fi
}

show_help() {
    cat << EOF
dev-ai Installation Script v${CURRENT_VERSION}

Usage: ./install.sh [OPTIONS]

Installation Modes:
  --user              Install global configs to ~/.claude/
  --project [PATH]    Install commands/prompts to target repo (default: current dir)
  --all [PATH]        Install both user-level and project-level configs
  --check             Check if updates are available
  --update            Update existing installations
  --uninstall         Remove all installed files

Options:
  --force, -f         Overwrite existing files (default: skip)
  --dry-run, -n       Preview changes without making them
  --verbose, -v       Show detailed output
  --help, -h          Show this help message

Examples:
  ./install.sh --user                    # Install global configs
  ./install.sh --project .               # Install to current repo
  ./install.sh --all ~/my-project        # Install both to specified project
  ./install.sh --check                   # Check for updates
  ./install.sh --update --force          # Force update all installations

After Installation:
  - Claude commands: /project:global/review, /project:global/test, etc.
  - Copilot prompts: /global/review, /global/test, etc.
EOF
}

#######################################
# Check dependencies
#######################################

check_dependencies() {
    local missing=()

    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Optional dependency not found: ${missing[*]}"
        warn "JSON merging will use fallback method (may overwrite existing settings)"
    fi
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
# Merge settings.json using jq
#######################################

merge_settings_json() {
    local src="$1"
    local dest="$2"
    local desc="$3"

    if [[ ! -f "$dest" ]]; then
        copy_file "$src" "$dest" "$desc"
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        if $FORCE; then
            copy_file "$src" "$dest" "$desc"
        else
            warn "Cannot merge $desc without jq (use --force to overwrite)"
        fi
        return 0
    fi

    if $DRY_RUN; then
        dry_run_msg "Merge hooks from $src into $dest"
        return 0
    fi

    # Create a merged version that combines hooks arrays
    local merged
    merged=$(jq -s '
        def merge_hooks:
            if .[0] == null then .[1]
            elif .[1] == null then .[0]
            else .[0] + .[1] | unique
            end;

        .[0] as $existing | .[1] as $new |
        $existing * {
            hooks: {
                PreToolUse: ([$existing.hooks.PreToolUse, $new.hooks.PreToolUse] | merge_hooks),
                PostToolUse: ([$existing.hooks.PostToolUse, $new.hooks.PostToolUse] | merge_hooks)
            }
        }
    ' "$dest" "$src" 2>/dev/null)

    if [[ -n "$merged" ]]; then
        echo "$merged" > "$dest"
        success "Merged $desc (combined hooks)"
    else
        error "Failed to merge $desc"
        return 1
    fi
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

    echo "$CURRENT_VERSION" > "$marker"
}

#######################################
# Installation functions
#######################################

install_user_level() {
    info "Installing user-level configs to ~/.claude/"

    local user_claude_dir="$HOME/.claude"
    local user_hooks_dir="$user_claude_dir/hooks"

    # Create directories
    if ! $DRY_RUN; then
        mkdir -p "$user_claude_dir"
        mkdir -p "$user_hooks_dir"
    fi

    # Install CLAUDE.md
    copy_file "$SCRIPT_DIR/global/CLAUDE.md" "$user_claude_dir/CLAUDE.md" "CLAUDE.md"

    # Merge or install settings.json
    merge_settings_json "$SCRIPT_DIR/global/settings.json" "$user_claude_dir/settings.json" "settings.json"

    # Install hook scripts
    copy_file "$SCRIPT_DIR/hooks/validate-command.sh" "$user_hooks_dir/validate-command.sh" "hooks/validate-command.sh"
    copy_file "$SCRIPT_DIR/hooks/audit-log.sh" "$user_hooks_dir/audit-log.sh" "hooks/audit-log.sh"

    # Make hooks executable
    if ! $DRY_RUN; then
        chmod +x "$user_hooks_dir"/*.sh 2>/dev/null || true
    fi

    # Track version
    track_version "$user_claude_dir"

    success "User-level installation complete"
}

install_project() {
    local target="$PROJECT_PATH"

    if [[ ! -d "$target" ]]; then
        error "Project directory not found: $target"
        exit 1
    fi

    info "Installing project-level configs to $target"

    local claude_commands_dir="$target/.claude/commands/global"
    local github_prompts_dir="$target/.github/prompts/global"
    local claude_hooks_dir="$target/.claude/hooks"

    # Create directories
    if ! $DRY_RUN; then
        mkdir -p "$claude_commands_dir"
        mkdir -p "$github_prompts_dir"
        mkdir -p "$claude_hooks_dir"
    fi

    # Install Claude commands to global/ subdirectory
    info "Installing Claude commands to .claude/commands/global/"
    copy_directory "$SCRIPT_DIR/commands" "$claude_commands_dir" ".claude/commands/global"

    # Install Copilot prompts to global/ subdirectory
    info "Installing Copilot prompts to .github/prompts/global/"
    copy_directory "$SCRIPT_DIR/prompts" "$github_prompts_dir" ".github/prompts/global"

    # Install hook scripts
    info "Installing hook scripts to .claude/hooks/"
    copy_file "$SCRIPT_DIR/hooks/validate-command.sh" "$claude_hooks_dir/validate-command.sh" ".claude/hooks/validate-command.sh"
    copy_file "$SCRIPT_DIR/hooks/format-file.sh" "$claude_hooks_dir/format-file.sh" ".claude/hooks/format-file.sh"
    copy_file "$SCRIPT_DIR/hooks/audit-log.sh" "$claude_hooks_dir/audit-log.sh" ".claude/hooks/audit-log.sh"

    # Make hooks executable
    if ! $DRY_RUN; then
        chmod +x "$claude_hooks_dir"/*.sh 2>/dev/null || true
    fi

    # Track version
    track_version "$target/.claude"

    success "Project-level installation complete"
    echo ""
    info "Usage after installation:"
    echo "  Claude commands: /project:global/review, /project:global/test, etc."
    echo "  Copilot prompts: /global/review, /global/test, etc."
}

#######################################
# Check for updates
#######################################

check_updates() {
    info "Checking for updates (current version: $CURRENT_VERSION)"

    local updates_available=false

    # Check user-level installation
    local user_marker="$HOME/.claude/.dev-ai-version"
    local user_version=$(get_installed_version "$user_marker")
    if [[ -n "$user_version" ]]; then
        if [[ "$user_version" != "$CURRENT_VERSION" ]]; then
            warn "User-level: installed $user_version, available $CURRENT_VERSION"
            updates_available=true
        else
            success "User-level: up to date ($user_version)"
        fi
    else
        info "User-level: not installed"
    fi

    # Check current directory for project-level installation
    local project_marker=".claude/.dev-ai-version"
    local project_version=$(get_installed_version "$project_marker")
    if [[ -n "$project_version" ]]; then
        if [[ "$project_version" != "$CURRENT_VERSION" ]]; then
            warn "Project-level (./): installed $project_version, available $CURRENT_VERSION"
            updates_available=true
        else
            success "Project-level (./): up to date ($project_version)"
        fi
    else
        info "Project-level (./): not installed"
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

    # Update user-level if installed
    local user_marker="$HOME/.claude/.dev-ai-version"
    if [[ -f "$user_marker" ]]; then
        local user_version=$(get_installed_version "$user_marker")
        if [[ "$user_version" != "$CURRENT_VERSION" ]] || $FORCE; then
            install_user_level
        else
            success "User-level already up to date"
        fi
    fi

    # Update project-level if installed in current directory
    local project_marker=".claude/.dev-ai-version"
    if [[ -f "$project_marker" ]]; then
        local project_version=$(get_installed_version "$project_marker")
        if [[ "$project_version" != "$CURRENT_VERSION" ]] || $FORCE; then
            PROJECT_PATH="$(pwd)"
            install_project
        else
            success "Project-level already up to date"
        fi
    fi
}

#######################################
# Uninstall
#######################################

uninstall() {
    info "Uninstalling dev-ai configs"

    # Uninstall user-level
    local user_claude_dir="$HOME/.claude"
    if [[ -f "$user_claude_dir/.dev-ai-version" ]]; then
        info "Removing user-level installation..."
        if $DRY_RUN; then
            dry_run_msg "Remove $user_claude_dir/CLAUDE.md"
            dry_run_msg "Remove $user_claude_dir/hooks/validate-command.sh"
            dry_run_msg "Remove $user_claude_dir/hooks/audit-log.sh"
            dry_run_msg "Remove $user_claude_dir/.dev-ai-version"
        else
            rm -f "$user_claude_dir/CLAUDE.md"
            rm -f "$user_claude_dir/hooks/validate-command.sh"
            rm -f "$user_claude_dir/hooks/audit-log.sh"
            rm -f "$user_claude_dir/.dev-ai-version"
            # Note: Not removing settings.json as it may have user customizations
            warn "Note: ~/.claude/settings.json preserved (may contain customizations)"
        fi
        success "User-level uninstalled"
    fi

    # Uninstall project-level from current directory
    if [[ -f ".claude/.dev-ai-version" ]]; then
        info "Removing project-level installation from current directory..."
        if $DRY_RUN; then
            dry_run_msg "Remove .claude/commands/global/"
            dry_run_msg "Remove .github/prompts/global/"
            dry_run_msg "Remove .claude/hooks/ (shared hook scripts)"
            dry_run_msg "Remove .claude/.dev-ai-version"
        else
            rm -rf ".claude/commands/global"
            rm -rf ".github/prompts/global"
            rm -f ".claude/hooks/validate-command.sh"
            rm -f ".claude/hooks/format-file.sh"
            rm -f ".claude/hooks/audit-log.sh"
            rm -f ".claude/.dev-ai-version"
        fi
        success "Project-level uninstalled"
    fi
}

#######################################
# Main
#######################################

main() {
    parse_args "$@"

    if [[ -z "$MODE" ]]; then
        error "No mode specified"
        show_help
        exit 1
    fi

    check_dependencies

    echo ""
    info "dev-ai v${CURRENT_VERSION}"
    if $DRY_RUN; then
        warn "DRY RUN MODE - No changes will be made"
    fi
    echo ""

    case $MODE in
        user)
            install_user_level
            ;;
        project)
            install_project
            ;;
        all)
            install_user_level
            echo ""
            install_project
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
