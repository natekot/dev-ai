# Dev AI — Skills, Instructions & Hooks

A collection of reusable skills, language-specific instructions, and security hooks for AI coding agents. Install once and use across all your projects.

## Quick Start

### Linux / macOS

```bash
./install.sh /path/to/your/project
```

### Windows

```cmd
install.bat C:\path\to\your\project
```

Note: The Windows installer creates file symlinks and directory junctions, which requires Developer Mode enabled (Windows 10+) or Administrator privileges.

## What Gets Installed

Skill directories are symlinked as a whole; instruction files and hooks are symlinked individually.

### Skills
| Skill | Description |
|-------|-------------|
| `resolve` | Resolve merge conflicts in the working tree |
| `pr` | Create a pull request with a generated description |
| `ship` | Stage all changes, commit, and push |
| `ship-staged` | Commit only staged changes and push |
| `pdf` | PDF manipulation toolkit — extract, create, merge, split, fill forms |
| `skill-creator` | Guide for creating new skills |

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

Invoke skills using the `/` syntax:

```
/resolve
/pr
/ship
/ship-staged
/pdf
/skill-creator
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
install.bat --uninstall C:\path\to\project # Remove installed symlinks
```

## Project Structure

```
├── install.sh                     # Installation script (Linux/macOS)
├── install.bat                    # Installation script (Windows)
├── README.md                      # This file
├── examples/                      # Demo files
│   └── sample.py
│
└── .github/                       # Source skills, instructions & hooks
    ├── hooks/                     # Coding-agent hooks
    │   ├── security.json          # Hook configuration
    │   └── scripts/
    │       ├── validate-command.sh
    │       └── audit-log.sh
    ├── instructions/              # Language-specific instructions
    │   ├── global.instructions.md
    │   ├── c.instructions.md
    │   ├── python.instructions.md
    │   ├── bash.instructions.md
    │   ├── testing.instructions.md
    │   └── security.instructions.md
    └── skills/                    # Reusable skills
        ├── resolve/
        ├── pr/
        ├── ship/
        ├── ship-staged/
        ├── pdf/
        └── skill-creator/
```

### Installation Target Structure

When you run the installer, skill directories are symlinked as directories and instruction/hook files as individual symlinks:

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
└── skills/
    ├── resolve/                   ->  dev-ai/.github/skills/resolve/
    ├── pr/                        ->  dev-ai/.github/skills/pr/
    ├── ship/                      ->  dev-ai/.github/skills/ship/
    ├── ship-staged/               ->  dev-ai/.github/skills/ship-staged/
    ├── pdf/                       ->  dev-ai/.github/skills/pdf/
    ├── skill-creator/             ->  dev-ai/.github/skills/skill-creator/
    └── my-skill/                  (your repo's own skills, untouched)
```

If a file or directory already exists in your project, it will be skipped (use `--force` to overwrite). Instructions apply automatically based on file patterns in their `applyTo` frontmatter.

## Available Skills

### `/resolve`
Resolve merge conflicts in the working tree:
- Finds conflicted files via `git diff --name-only --diff-filter=U`
- Reads conflict markers and understands both sides
- Resolves clear-cut conflicts automatically; asks about ambiguous ones
- Stages each resolved file and verifies no conflicts remain

### `/pr`
Create a pull request with a generated description:
- Compares the current branch against the default branch
- Reads the commit log and diff
- Generates a conventional-commit-style title and structured description
- Creates the PR using `gh pr create`

### `/ship`
Stage all changes, commit, and push:
- Runs `git add -A` to stage everything
- Writes a conventional commit message from the diff
- Pushes to the current branch's upstream

### `/ship-staged`
Commit only staged changes and push:
- Commits only what is already staged
- Writes a conventional commit message from the diff
- Pushes to the current branch's upstream

### `/pdf`
PDF manipulation toolkit:
- Extract text, tables, and form fields from PDFs
- Create new PDFs programmatically
- Merge and split PDF documents
- Fill fillable forms and annotate non-fillable forms

### `/skill-creator`
Guide for creating new skills:
- Scaffolds new skill directories with SKILL.md and scripts
- Validates skill structure and frontmatter
- Packages skills for distribution

## Hooks

The installer also sets up coding-agent hooks in `.github/hooks/`. These hooks run automatically during coding sessions:

### `validate-command.sh` (preToolUse)
Intercepts tool calls before execution and blocks dangerous commands:
- `rm -rf /`, `rm -rf ~`, `sudo rm`
- `chmod 777`, `git push --force`, `git reset --hard`
- Destructive disk operations (`mkfs`, `dd if=`, `> /dev/sda`)

Uses `jq` for JSON parsing when available, falls back to `python3`.

### `audit-log.sh` (postToolUse)
Logs every tool execution with an ISO-8601 timestamp to `.github/hooks/audit.log` for compliance and debugging. Never blocks — always exits successfully.

### `security.json`
Configuration file that wires the scripts into the hook lifecycle:
- **preToolUse** — runs `validate-command.sh` before shell commands
- **postToolUse** — runs `audit-log.sh` after any tool use
- **sessionStart / sessionEnd** — appends session markers to the audit log

## Further Reading

- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Asking GitHub Copilot Questions in Your IDE](https://docs.github.com/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
