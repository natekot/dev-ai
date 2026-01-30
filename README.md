# GitHub Copilot Prompts & Instructions

A collection of reusable GitHub Copilot prompts and language-specific instructions for common development tasks. Install once and use across all your projects.

## Quick Start

### Linux / macOS

```bash
./install.sh /path/to/your/project
```

### Windows

```cmd
install.bat C:\path\to\your\project
```

Note: The Windows installer creates file symlinks, which requires Developer Mode enabled (Windows 10+) or Administrator privileges.

## What Gets Installed

Individual symlinks are created for each prompt and instruction file:

### Prompts
| File | Location | Purpose |
|------|----------|---------|
| `resolve.prompt.md` | `.github/prompts/` | Resolve merge conflicts in the working tree |
| `pr.prompt.md` | `.github/prompts/` | Create a PR with generated description |
| `ship.prompt.md` | `.github/prompts/` | Stage all, commit, and push |
| `ship-staged.prompt.md` | `.github/prompts/` | Commit staged changes and push |

### Instructions (Language-Specific)
| File | Applies To | Purpose |
|------|------------|---------|
| `global.instructions.md` | All files (`**`) | Global token efficiency guidelines |
| `c.instructions.md` | `*.c`, `*.h` | C language + K&R style |
| `python.instructions.md` | `*.py` | Python guidelines |
| `bash.instructions.md` | `*.sh`, `*.bash` | Bash/Shell guidelines |
| `testing.instructions.md` | `test_*.py`, `*_test.c`, etc. | Testing patterns |
| `security.instructions.md` | All files | Security guidelines |

### Hooks
| File | Type | Purpose |
|------|------|---------|
| `security.json` | `.github/hooks/` | Hook configuration (preToolUse, postToolUse, session events) |
| `validate-command.sh` | `.github/hooks/scripts/` | Block dangerous commands before execution |
| `audit-log.sh` | `.github/hooks/scripts/` | Log tool executions with timestamps |

## Usage After Installation

In VS Code Copilot Chat, invoke prompts using the `/` syntax:

```
/resolve
/pr
/ship
/ship-staged
```

## Managing Installations

```bash
# Linux / macOS
./install.sh /path/to/project --force     # Force overwrite existing files
./install.sh /path/to/project --dry-run   # Preview what would be installed
./install.sh --uninstall /path/to/project # Remove installed symlinks

# Windows
install.bat C:\path\to\project --force     # Force overwrite existing
install.bat C:\path\to\project --dry-run   # Preview what would be installed
install.bat --uninstall C:\path\to\project # Remove installed junctions
```

## Project Structure

```
├── install.sh                     # Installation script (Linux/macOS)
├── install.bat                    # Installation script (Windows)
├── README.md                      # This file
├── examples/                      # Demo files
│   └── sample.py
│
└── .github/                       # Source prompts, instructions & hooks
    ├── hooks/                     # Copilot coding-agent hooks
    │   ├── security.json          # Hook configuration
    │   └── scripts/
    │       ├── validate-command.sh
    │       └── audit-log.sh
    ├── instructions/              # All instructions (including global)
    │   ├── global.instructions.md
    │   ├── c.instructions.md
    │   ├── python.instructions.md
    │   ├── bash.instructions.md
    │   ├── testing.instructions.md
    │   └── security.instructions.md
    └── prompts/
        ├── resolve.prompt.md
        ├── pr.prompt.md
        ├── ship.prompt.md
        └── ship-staged.prompt.md
```

### Installation Target Structure

When you run the installer, individual file symlinks are created:

```
your-repo/.github/
├── hooks/
│   ├── security.json              ->  dev-ai/.github/hooks/security.json
│   └── scripts/
│       ├── validate-command.sh    ->  dev-ai/.github/hooks/scripts/validate-command.sh
│       └── audit-log.sh           ->  dev-ai/.github/hooks/scripts/audit-log.sh
├── instructions/
│   ├── bash.instructions.md       ->  dev-ai/.github/instructions/bash.instructions.md
│   ├── python.instructions.md     ->  dev-ai/.github/instructions/python.instructions.md
│   ├── ...                        (other instruction symlinks)
│   └── my.instructions.md         (your repo's own instructions, untouched)
└── prompts/
    ├── resolve.prompt.md          ->  dev-ai/.github/prompts/resolve.prompt.md
    ├── pr.prompt.md               ->  dev-ai/.github/prompts/pr.prompt.md
    ├── ...                        (other prompt symlinks)
    └── my-prompt.prompt.md        (your repo's own prompts, untouched)
```

If a file already exists in your project, it will be skipped (use `--force` to overwrite). Instructions apply automatically based on file patterns in their `applyTo` frontmatter.

## Available Prompts

### `/resolve`
Resolves merge conflicts in the working tree:
- Finds conflicted files via `git diff --name-only --diff-filter=U`
- Reads conflict markers and understands both sides
- Resolves clear-cut conflicts automatically; asks about ambiguous ones
- Stages each resolved file and verifies no conflicts remain

### `/pr`
Creates a pull request with a generated description:
- Compares the current branch against the default branch
- Reads the commit log and diff
- Generates a conventional-commit-style title and structured description
- Creates the PR using `gh pr create`

### `/ship`
Stages all changes, commits, and pushes:
- Runs `git add -A` to stage everything
- Writes a conventional commit message from the diff
- Pushes to the current branch's upstream

### `/ship-staged`
Commits already-staged changes and pushes:
- Commits only what is already staged
- Writes a conventional commit message from the diff
- Pushes to the current branch's upstream

## Hooks

The installer also sets up Copilot coding-agent hooks in `.github/hooks/`. These hooks run automatically during Copilot sessions:

### `validate-command.sh` (preToolUse)
Intercepts tool calls before execution and blocks dangerous commands:
- `rm -rf /`, `rm -rf ~`, `sudo rm`
- `chmod 777`, `git push --force`, `git reset --hard`
- Destructive disk operations (`mkfs`, `dd if=`, `> /dev/sda`)

Uses `jq` for JSON parsing when available, falls back to `python3`.

### `audit-log.sh` (postToolUse)
Logs every tool execution with an ISO-8601 timestamp to `.github/hooks/audit.log` for compliance and debugging. Never blocks — always exits successfully.

### `security.json`
Configuration file that wires the scripts into Copilot's hook lifecycle:
- **preToolUse** — runs `validate-command.sh` before shell commands
- **postToolUse** — runs `audit-log.sh` after any tool use
- **sessionStart / sessionEnd** — appends session markers to the audit log

## Copilot Chat Participants

Type `@` in Copilot Chat to access specialized participants:

| Participant | Purpose | Example |
|-------------|---------|---------|
| `@workspace` | Codebase context | `@workspace how is authentication implemented?` |
| `@terminal` | Terminal/shell expertise | `@terminal list the 5 largest files here` |
| `@vscode` | VS Code settings and features | `@vscode how to enable word wrapping?` |
| `@github` | GitHub features and web search | `@github what are my open PRs?` |

## Further Reading

- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [GitHub Copilot Prompt Files](https://docs.github.com/en/copilot/tutorials/customization-library/prompt-files)
- [Asking GitHub Copilot Questions in Your IDE](https://docs.github.com/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
