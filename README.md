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
└── .github/                       # Source prompts & instructions
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
